@isTest(SeeAllData=true)
public with sharing class CourseRegistrationInvocableTest {
    @isTest
    static void testCreateCourseRegistration() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary testOrderSummary = [SELECT Id, Payment_Status__c, CurrencyIsoCode, IsWaitlisted__c FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];
        List<Campaign> testCampaigns = [SELECT Id, Description, What_to_Bring__c, View_Map__c, Training_Location_Street__c, Training_Location_City__c, Training_Location_State__c, Training_Location_Zip_Code__c FROM Campaign WHERE Name = 'TestOS'];
        List<Session__c> testSessions = new List<Session__c>();
        for (Campaign testCampaign : testCampaigns) {
            Session__c testSession = new Session__c(Event__c = testCampaign.Id, Name = 'TestSession');
            testSessions.add(testSession);
        }
        insert testSessions;
        List<CourseRegistrationInvocable.CourseRegistrationInput> input = new List<CourseRegistrationInvocable.CourseRegistrationInput>();
        CourseRegistrationInvocable.CourseRegistrationInput courseRegistrationInput = new CourseRegistrationInvocable.CourseRegistrationInput();
        courseRegistrationInput.contactId = testContact.Id;
        courseRegistrationInput.courses = testCampaigns;
        courseRegistrationInput.orderSummaryId = testOrderSummary.Id;
        courseRegistrationInput.eventRelationships = null;
        courseRegistrationInput.registrationType = 'OrderSummary';
        input.add(courseRegistrationInput);

        // Call the method
        Test.startTest();
        CourseRegistrationInvocable.createCourseRegistration(new List<CourseRegistrationInvocable.CourseRegistrationInput>{courseRegistrationInput});
        Test.stopTest();

        // Verify the results
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE ContactId = :testContact.Id];
        System.assertEquals(1, campaignMembers.size());
        List<Registration__c> registrations = [SELECT Id FROM Registration__c WHERE Contact__c = :testContact.Id];
        System.assertEquals(1, registrations.size());
    }

    @isTest
    static void testCreateCourseRegistrationWithWaitlist() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary testOrderSummary = [SELECT Id, Payment_Status__c, CurrencyIsoCode, IsWaitlisted__c FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];
        List<OrderItemSummary> testOrderItemSummaries = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId = :testOrderSummary.Id];
        List<OrderItemSummary> testOrderItemSummariesToUpdate = new List<OrderItemSummary>();
        for (OrderItemSummary testOrderItemSummary : testOrderItemSummaries) {
            testOrderItemSummary.IsWaitlisted__c = true;
            testOrderItemSummariesToUpdate.add(testOrderItemSummary);
        }
        update testOrderItemSummariesToUpdate;
        List<Campaign> testCampaigns = [SELECT Id, Description, What_to_Bring__c, View_Map__c, Training_Location_Street__c, Training_Location_City__c, Training_Location_State__c, Training_Location_Zip_Code__c FROM Campaign WHERE Name = 'TestOS'];
        List<Session__c> testSessions = new List<Session__c>();
        for (Campaign testCampaign : testCampaigns) {
            Session__c testSession = new Session__c(Event__c = testCampaign.Id, Name = 'TestSession');
            testSessions.add(testSession);
        }
        insert testSessions;
        List<CourseRegistrationInvocable.CourseRegistrationInput> input = new List<CourseRegistrationInvocable.CourseRegistrationInput>();
        CourseRegistrationInvocable.CourseRegistrationInput courseRegistrationInput = new CourseRegistrationInvocable.CourseRegistrationInput();
        courseRegistrationInput.contactId = testContact.Id;
        courseRegistrationInput.courses = testCampaigns;
        courseRegistrationInput.orderSummaryId = testOrderSummary.Id;
        courseRegistrationInput.eventRelationships = null;
        courseRegistrationInput.registrationType = 'OrderSummary';
        courseRegistrationInput.waitlisted = 'true';
        input.add(courseRegistrationInput);

        // Call the method
        Test.startTest();
        CourseRegistrationInvocable.createCourseRegistration(new List<CourseRegistrationInvocable.CourseRegistrationInput>{courseRegistrationInput});
        Test.stopTest();

        // Verify the results
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE ContactId = :testContact.Id];
        System.assertEquals(1, campaignMembers.size());
        List<Registration__c> registrations = [SELECT Id FROM Registration__c WHERE Contact__c = :testContact.Id];
        System.assertEquals(1, registrations.size());
    }
    
    @isTest
    static void testCreateCourseRegistrationException() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Campaign testCampaign = new Campaign(Name = 'TestOS');
        insert testCampaign;
        Saltbox_TestDataFactory.buildManagedOrderSummary('TestOS');
        OrderSummary testOrderSummary = [SELECT Id, Payment_Status__c, CurrencyIsoCode, IsWaitlisted__c FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];
        List<Session__c> testSessions = new List<Session__c>();
        List<CourseRegistrationInvocable.CourseRegistrationInput> input = new List<CourseRegistrationInvocable.CourseRegistrationInput>();
        CourseRegistrationInvocable.CourseRegistrationInput courseRegistrationInput = new CourseRegistrationInvocable.CourseRegistrationInput();
        //courseRegistrationInput.contactId = testContact.Id;
        courseRegistrationInput.courses = new List<Campaign>{testCampaign};
        courseRegistrationInput.orderSummaryId = testOrderSummary.Id;
        courseRegistrationInput.eventRelationships = null;
        courseRegistrationInput.registrationType = 'Private';
        input.add(courseRegistrationInput);

        // Call the method
        Test.startTest();
        CourseRegistrationInvocable.createCourseRegistration(new List<CourseRegistrationInvocable.CourseRegistrationInput>{courseRegistrationInput});
        Test.stopTest();

        // Verify the results
        ProcessException processException = [SELECT Id, Message FROM ProcessException WHERE OrderSummaryId = :testOrderSummary.Id];
        System.assertEquals('Error creating CampaignMember and Registration records', processException.Message, 'ProcessException message is incorrect');
    }
}