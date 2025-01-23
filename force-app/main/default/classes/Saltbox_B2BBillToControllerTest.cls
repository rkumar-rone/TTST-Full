/**
 * @description       : Class that retrieve Contact Point Address
 * @author            : Rodrigo Hernandez
 * @last modified on  : 08-18-2023
 * @last modified by  : Rodrigo Hernandez
**/
@isTest(SeeAllData=true)
public with sharing class Saltbox_B2BBillToControllerTest {
    /**
    * @description Test class setup, Account,contact,Contact Point Addresses, profile and user iserted.
    * @return void
    */
    private static void setup() {
        
        Account account =[Select Id from Account Where Id=:System.Label.Saltbox_Effective_Account_Id LIMIT 1];

       // The cpas are related to the account (and through it to the contact)
       ContactPointAddress cpa1 = new ContactPointAddress(Name='CPA1', Street='Street1', City='city1', StateCode='CA',
               CountryCode='US', PostalCode='90251', IsDefault=true, AddressType='Billing', ParentId=account.Id);
       ContactPointAddress cpa2 = new ContactPointAddress(Name='CPA2', Street='Street2', City='city2', StateCode='CA',
               CountryCode='US', PostalCode='90251', IsDefault=false, AddressType='Billing', ParentId=account.Id);
    
    insert cpa1;
    insert cpa2;
    }

    /**
    * @description Test Get Contact Point Address
    * @return void
    */
    @isTest
    public static void testgetContactPointAddresses() {
        List<ContactPointAddress> returnContactPointAddresses = new List<ContactPointAddress>();
        setup();
        Test.startTest();
        User u = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        System.runAs(u) {
            returnContactPointAddresses= Saltbox_B2BBillToController.getContactPointAddresses();
            //System.assert(returnContactPointAddresses.size()>0);
        }
        Test.stopTest();
        // System.assertEquals(2, returnContactPointAddresses.size());
    }

    /**
    * @description Test Get Countries and States Picklist Values
    * @return void
    */
    @isTest
    public static void testgetCountriesAndStates() {
        Test.startTest();

        Map<String, Object> actualResult;
        try{
            actualResult = Saltbox_B2BBillToController.getCountriesAndStates();
            System.debug('actualResult = ' + actualResult);
        } catch (Exception e){}
        System.assertNotEquals(null, actualResult);

        Test.stopTest();
    }
}