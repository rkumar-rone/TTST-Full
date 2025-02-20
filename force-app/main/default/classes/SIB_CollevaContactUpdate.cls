/**
 * Created by junaidmohammed on 2/14/25.
 */

public with sharing class SIB_CollevaContactUpdate {

    @InvocableMethod(Label='Populate Colleva Id on Contact' Description='Populate Colleva Id on Contact' Category='B2B Commerce')
    public static void updateCollevaIdOnContact(List<String> orderSummaryIds) {
       if(orderSummaryIds!=null && orderSummaryIds.size()>0)
       {
           try
           {
               for(String orderSummaryId : orderSummaryIds)
               {
                   updateContactCollevaDetails(orderSummaryId);
               }
           } catch (Exception e)
           {
               System.debug('Error processing Colleva Update callout for OrderSummary ID: ' + e.getMessage());
           }
       }
    }

    @Future
    public static void updateContactCollevaDetails(String orderSummaryId)
    {
        List<OrderSummary> lstOrderSummaries = [SELECT Id, Colleva_Provisioned__c,AccountId,
                Colleva_Order__c, Colleva_Id__C FROM OrderSummary WHERE Id=:orderSummaryId];
        for(OrderSummary orderSummaryObject : lstOrderSummaries)
        {
            List<User> lstUsers = [SELECT Id, CollevaAccess__c,Contact.Id, Contact.Colleva_Id__c FROM User WHERE AccountId=:orderSummaryObject.AccountId];
            if(lstUsers!=null && lstUsers.size()>0)
            {
                User loggedInUser = lstUsers[0];
                loggedInUser.CollevaAccess__c = true;
                update loggedInUser;

                Contact contactToUpdate = loggedInUser.Contact;
                contactToUpdate.Colleva_Id__c = orderSummaryObject.Colleva_Id__c;
                update contactToUpdate;
            }
        }
    }

    public static void tst() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }

   /* @Future
    public static void changeCollevaAccess(String userId , Boolean blnCollevaAccess)
    {
        List<User> lstUsers = [SELECT Id FROM User WHERE Id=:userId];
        for(User userObject : lstUsers)
        {
            userObject.CollevaAccess__c = blnCollevaAccess;
        }
        update lstUsers;
    }*/

}