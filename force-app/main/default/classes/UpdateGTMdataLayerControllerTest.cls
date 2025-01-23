@isTest(SeeAllData=true)
public with sharing class UpdateGTMdataLayerControllerTest {
    
    @isTest
    static void getGTMEventDataTest(){

        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create a test User record
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser2702@example.com'
        );
        insert testUser;

        // Create a test OrderSummary record
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');

        OrderSummary testOrderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];

        Test.startTest();
        UpdateGTMdataLayerController.GTMEventData gtmEventData = (UpdateGTMdataLayerController.GTMEventData) JSON.deserialize(UpdateGTMdataLayerController.getGTMEventData(testOrderSummary.Id), UpdateGTMdataLayerController.GTMEventData.class);
        
        System.debug('>>> gtmEventData: '+ JSON.serialize(gtmEventData));

        System.assertEquals(true, gtmEventData.gtmItems.size() > 0);

        Test.stopTest();

    }

}