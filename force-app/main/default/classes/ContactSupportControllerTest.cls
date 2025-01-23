@isTest
private class ContactSupportControllerTest {
    @isTest
    static void testSubmitCase() {
        Case newCase = new Case(Subject = 'Test Case', Description = 'This is a test case');
        Test.startTest();
        contactSupportController.submitCase(newCase);
        Test.stopTest();
        List<Case> cases = [SELECT Id, Subject, Description FROM Case WHERE Subject = 'Test Case'];
        System.assertEquals(1, cases.size(), 'There should be one case with the subject "Test Case"');
        System.assertEquals('This is a test case', cases[0].Description, 'The case description should be "This is a test case"');
    }

    @isTest
static void testSubmitCaseFail() {
    Case newCase = new Case(Subject = 'Test Case', Description = 'This is a test case', SuppliedEmail = 'Error');
    Test.startTest();
    try {
        contactSupportController.submitCase(newCase);
        System.assert(false, 'Expected exception was not thrown');
    } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception was thrown');
    }
    Test.stopTest();
}
    
    @isTest
    static void testSubmitLead() {
        Lead newLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company');
        Test.startTest();
        contactSupportController.submitLead(newLead);
        Test.stopTest();
        List<Lead> leads = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE FirstName = 'Test'];
        System.assertEquals(1, leads.size(), 'There should be one lead with the first name "Test"');
        System.assertEquals('Lead', leads[0].LastName, 'The lead last name should be "Lead"');
    }

    @isTest
    static void testSubmitLeadFail() {
        Lead newLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Email = 'Error');
        Test.startTest();
        try {
            contactSupportController.submitLead(newLead);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception was thrown');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserInfo() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='standardTTSuserForTest@testorg.com');
        System.runAs(u){
            Test.startTest();
            User currentUser = contactSupportController.getUserInfo();
            Test.stopTest();
            System.assertEquals(UserInfo.getUserId(), currentUser.Id, 'The user Id should be the same as the current user Id');
            System.assertEquals(UserInfo.getFirstName(), currentUser.FirstName, 'The user first name should be the same as the current user first name');
            System.assertEquals(UserInfo.getLastName(), currentUser.LastName, 'The user last name should be the same as the current user last name');
            System.assertEquals(UserInfo.getUserEmail(), currentUser.Email, 'The user email should be the same as the current user email');
        }
    }
}