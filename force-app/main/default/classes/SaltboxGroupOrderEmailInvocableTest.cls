@isTest(SeeAllData=true)
public with sharing class SaltboxGroupOrderEmailInvocableTest {

    @isTest
    static void emailInvocableTest_validRequest_success(){

        Account testerAccount = [SELECT Id FROM Account WHERE Name = 'Saltbox TestUser' LIMIT 1];

        List<SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest> requestList = new List<SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest>();
        SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest request = new SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest();

        Campaign eventRecord = new Campaign();
        eventRecord.Name = 'Test Event';
        insert eventRecord;

        Group_Recepient__c groupRecipient = new Group_Recepient__c();
        groupRecipient.First_Name__c = 'TestFN';
        groupRecipient.Last_Name__c = 'TestLN';
        groupRecipient.Recepient_Email__c = 'testgrouprecipient@example.com';
        groupRecipient.TTS_Event__c = eventRecord.Id;
        insert groupRecipient;

        List<Group_Recepient__c> groupRecipients = new List<Group_Recepient__c>{groupRecipient};

        request.groupRecepients = groupRecipients;
        request.sender = 'info@trainingthestreet.com';
        request.subject = 'test subject';
        request.generatedRegistrationLink = 'test link';
        request.orderAccountName = 'test name';
        request.fromCompanyUniversity = 'test company';
        request.templateName = 'Group Order';
        request.personAccountId = testerAccount.Id;
        request.decisionMakerEmail = 'nicolas+te@saltboxmgmt.com';

        requestList.add(request);
        Test.startTest();
        SaltboxGroupOrderEmailInvocable.sendGroupOrderEmail(requestList);
        Test.stopTest();
    }


    @isTest
    static void emailInvocableTest_emptyRequest_failure(){

        List<SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest> requestList = new List<SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest>();
        Test.startTest();
        SaltboxGroupOrderEmailInvocable.sendGroupOrderEmail(requestList);
        Test.stopTest();
    }

    @isTest
    static void emailInvocableTest_notAnOrgWideEmail_failure(){

        Account testerAccount = [SELECT Id FROM Account WHERE Name = 'Saltbox TestUser' LIMIT 1];

        List<SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest> requestList = new List<SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest>();
        SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest request = new SaltboxGroupOrderEmailInvocable.GroupOrderEmailRequest();
        
        Campaign eventRecord = new Campaign();
        eventRecord.Name = 'Test Event';
        insert eventRecord;

        Group_Recepient__c groupRecipient = new Group_Recepient__c();
        groupRecipient.First_Name__c = 'TestFN';
        groupRecipient.Last_Name__c = 'TestLN';
        groupRecipient.Recepient_Email__c = 'testgrouprecipient@example.com';
        groupRecipient.TTS_Event__c = eventRecord.Id;
        insert groupRecipient;

        List<Group_Recepient__c> groupRecipients = new List<Group_Recepient__c>{groupRecipient};

        request.groupRecepients = groupRecipients;
        request.sender = 'info@trainingthestreet.com';
        request.subject = 'test subject';
        request.generatedRegistrationLink = 'test link';
        request.orderAccountName = 'test name';
        request.fromCompanyUniversity = 'test company';
        request.templateName = 'Group Order';
        request.personAccountId = testerAccount.Id;
        request.decisionMakerEmail = 'nicolas+te@saltboxmgmt.com';
        
        requestList.add(request);
        Test.startTest();
        SaltboxGroupOrderEmailInvocable.sendGroupOrderEmail(requestList);
        Test.stopTest();
    }
}