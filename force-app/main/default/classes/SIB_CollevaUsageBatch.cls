/**
 * Created by junaidmohammed on 2/14/25.
 */

public with sharing class SIB_CollevaUsageBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    // Execute method to process records
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id,Name, Contact.Id, ContactId, ' +
                        ' Contact.Colleva_Id__c FROM User WHERE CollevaAccess__c = TRUE ';
        if (Test.isRunningTest())
        {
            query += 'Order By LastModifiedDate DESC NULLS LAST LIMIT 1';
        }else {
            query += 'Order By CreatedDate DESC';
        }
        return Database.getQueryLocator( query );
    }

    // Execute batch job to update records
    public void execute(Database.BatchableContext context, List<User> scope) {
        for (User userObject : scope)
        {
            populateCollevaUsageDetails(userObject);
        }
    }

    public static void populateCollevaUsageDetails(User userObject)
    {
        Contact loggedInContact = null;
        Decimal collevaId = 0;
        List<Contact> lstContacts = [SELECT Id,Colleva_Id__c,
                                        (SELECT Id, Colleva_Id__c FROM SIB_Colleva_Details__r)
                                        FROM Contact WHERE Id=:userObject.ContactId];
        if(lstContacts!=null && lstContacts.size()>0)
        {
            loggedInContact = lstContacts[0];
            if(loggedInContact!=null)
            {
                if(loggedInContact.Colleva_Id__c>0)
                {
                    collevaId = loggedInContact.Colleva_Id__c;
                }else
                {
                    List<SIB_Colleva_Details__c> lstSIBCollevaDetails = loggedInContact.SIB_Colleva_Details__r;
                    if (lstSIBCollevaDetails != null && lstSIBCollevaDetails.size() > 0)
                    {
                        for (SIB_Colleva_Details__c collevaDetails : lstSIBCollevaDetails)
                        {
                            if (collevaDetails.Colleva_Id__c > 0)
                            {
                                collevaId = collevaDetails.Colleva_Id__c;
                            }
                        }
                    }
                }
                if(collevaId>0)
                {
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('CollevaId', String.valueOf(collevaId));
                    // Instantiate and start the Flow
                    Flow.Interview.Colleva_API_Allowed_Usage collevaApiCall = new Flow.Interview.Colleva_API_Allowed_Usage(params);
                    collevaApiCall.start();
                    SIB_CollevaAPIDataVO collevaApiDataVO = (SIB_CollevaAPIDataVO) collevaApiCall.responsedata;
                    updateCollevaUsageData(collevaApiDataVO , userObject , collevaId);
                }
            }
        }
    }

    public static void updateCollevaUsageData(SIB_CollevaAPIDataVO collevaApiDataVO , User userObject , Decimal collevaId)
    {
        String externalId = '';
        Boolean isValid = false;
        Boolean blnUpdateUser = false;
        if(collevaApiDataVO != null)
        {
            List<SIB_CollevaAPIActiveProductsVO> activeProducts = (List<SIB_CollevaAPIActiveProductsVO>) collevaApiDataVO.activeProducts;
            System.debug('collevaApiCall : ' + activeProducts);
            List<SIB_Colleva_Details__c> collevaDetailList = new List<SIB_Colleva_Details__c>();
            for (SIB_CollevaAPIActiveProductsVO activeProduct : activeProducts)
            {
                if (activeProduct.externalId != 'TTS_additionalMinutes' &&
                        Date.valueOf(activeProduct.validUntil) >= System.today()
                        && collevaApiDataVO.minutesLeft >= 0)
                {
                    externalId = activeProduct.externalId;
                    isValid = true;
                } else
                {
                    //Update the User record to disable Colleva Access
                    userObject.CollevaAccess__c = false;
                    blnUpdateUser = true;
                }
                SIB_Colleva_Details__c collevaDetail = new SIB_Colleva_Details__c();
                collevaDetail.Contact__c = userObject.ContactId;
                collevaDetail.Name = userObject.Name;
                collevaDetail.Colleva_Id__c = collevaId;
                collevaDetail.ExternalId__c = userObject.ContactId + '__' + collevaId + '__' + activeProduct.externalId;
                collevaDetail.HasUsageLeft__c = collevaApiDataVO.hasUsageLeft;
                collevaDetail.IsUnlimited__c = collevaApiDataVO.isUnlimited;
                collevaDetail.MinutesLeft__c = collevaApiDataVO.minutesLeft;
                collevaDetail.MinutesLimit__c = collevaApiDataVO.minutesLimit;
                collevaDetail.SessionsLeft__c = collevaApiDataVO.sessionsLeft;
                collevaDetail.SessionsLimit__c = collevaApiDataVO.sessionsLimit;
                collevaDetail.ProductName__c = activeProduct.productName;
                collevaDetail.PurchaseType__c = activeProduct.purchaseType;
                collevaDetail.UsageType__c = activeProduct.usageType;
                collevaDetail.ValidUntil__c = activeProduct.validUntil;
                System.debug('collevaDetail.ExternalId__c : '+JSON.serialize(collevaDetail.ExternalId__c));
                collevaDetailList.add(collevaDetail);
            }
            if (collevaDetailList != null && !collevaDetailList.isEmpty())
            {
                System.debug('Updating Colleva Detail Usage : '+JSON.serialize(collevaDetailList.size()));
                Database.upsert(collevaDetailList, SIB_Colleva_Details__c.externalId__c);
            }
            System.debug('Updating User Colleva Accesss : '+JSON.serialize(blnUpdateUser));
            if(blnUpdateUser)
            {
                update userObject;
            }
        }
    }

    // Finish method
    public void finish(Database.BatchableContext context) {

    }
}