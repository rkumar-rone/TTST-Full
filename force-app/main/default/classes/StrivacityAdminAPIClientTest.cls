@isTest
public class StrivacityAdminAPIClientTest {

    @isTest
    public static void testSendStrivacityUpdate() {
        // Get the ID of the 'Person Account' record type
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Test User'       
        );
        insert testAccount;

        // Create a test Contact record
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert testContact;

        // Update the Account record
        Account accToUpdate = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        accToUpdate.RecordTypeId = recordTypeId;
        update accToUpdate;

        Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccount.Id];
        
        // Create a Strivacity_Profile_Update__e platform event for testing
        Strivacity_Profile_Update__e profileEvent = new Strivacity_Profile_Update__e(
            ContactId__c = acc.PersonContactId,
            FirstName__c = 'Test',
            LastName__c = 'User123',
            Username__c = 'test_username',
            Phone__c = '+12177141112'
        );
        
        // Add the event to a list
        List<Strivacity_Profile_Update__e> profileEvents = new List<Strivacity_Profile_Update__e>();
        profileEvents.add(profileEvent);

        // Create a mock response for the authentication request
        String authResponse = '{"access_token": "mockAccessToken"}';
        HttpCalloutMock authMock = new MockHttpResponseGenerator(authResponse);

        // Create a mock response for the PUT request
        String putResponse = '{"result": "Success"}';
        HttpCalloutMock putMock = new MockHttpResponseGenerator(putResponse);

        // Set up the mock for the authentication request
        Test.setMock(HttpCalloutMock.class, authMock);

        // Test the sendStrivacityUpdate method
        Test.startTest();
        StrivacityAdminAPIClient.sendStrivacityUpdate(profileEvents);
        Test.stopTest();

        // Add assertions here to validate the behavior of the method
    }

    @isTest
    static void testGenerateContactJSON() {
        // Create a test Strivacity_Profile_Update__e record
        Strivacity_Profile_Update__e testProfile = new Strivacity_Profile_Update__e(
            ContactId__c = '0035g000003T0UKAA0',
            FirstName__c = 'Test',
            LastName__c = 'User',
            Username__c = 'testUser',
            Phone__c = '1234567890'
        );

        // Call the method
        String result = StrivacityAdminAPIClient.generateContactJSON(testProfile);

        // Verify the results
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(testProfile.ContactId__c, ((Map<String, Object>) resultMap.get('sfdc')).get('contactId'));
        System.assertEquals(testProfile.FirstName__c, ((Map<String, Object>) resultMap.get('name')).get('givenName'));
        System.assertEquals(testProfile.LastName__c, ((Map<String, Object>) resultMap.get('name')).get('familyName'));
        System.assertEquals(testProfile.Username__c, resultMap.get('userName'));
        System.assertEquals(testProfile.Phone__c, ((Map<String, Object>) resultMap.get('phoneNumbers')).get('primaryPhoneNumber'));
    }

    @isTest
    static void testSendAuthRequest(){
        StrivacityAdminAPIClientMock mock = new StrivacityAdminAPIClientMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = StrivacityAdminAPIClient.sendAuthRequest();
        System.assertEquals('mockAccessToken', result);
    }

    @isTest
    static void testMakePutRequest(){
        StrivacityAdminAPIClientMock mock = new StrivacityAdminAPIClientMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = StrivacityAdminAPIClient.makePutRequest('mockAccessToken', 'mockBody', 'test');
        System.assertEquals('{"access_token": "mockAccessToken"}', result);
    }
}