@isTest(SeeAllData=true)
private with sharing class TTS_Store_RegistrationHandlerTest {

    @isTest
    static void testScriptFutureMethod() {
        //Get all customer users that uses a Contact and not a Person Account
        List<User> userList = [SELECT Id,ContactId,FirstName,LastName,Contact.RecordType.Name, 
        IsActive, IsPortalEnabled, Username, Email, FederationIdentifier, CommunityNickname,
        Phone, CompanyName, Alias, languagelocalekey, localesidkey, emailEncodingKey, timezonesidkey, ProfileId
        FROM User WHERE ContactId != null ORDER BY CreatedDate DESC NULLS LAST LIMIT 2];
        System.debug('userList: '+userList);

        Map<String, String> userDataMap = new Map<String, String>();
        List<User> savedUsers = new List<User>();
        //Get all Contact Ids
        List<String> contactIds = new List<String>();
        for (User us : userList){
        contactIds.add(us.ContactId);
        userDataMap.put(us.Id+'+Username', us.Username);
        userDataMap.put(us.Id+'+Email', us.Email);
        userDataMap.put(us.Id+'+FederationIdentifier', us.FederationIdentifier);
        savedUsers.add(us);
        }
        System.debug('contactIds: '+contactIds);

        //Get the Contacts to convert to Person Accounts (CURRENTLY HARDCODED TO CONVERT ONLY ONE CONTACT FOR TESTING PURPOSES)
        List<Contact> contactsToConvert = [SELECT Id, Email, Account.RecordTypeId, AccountId, Account.Name, FirstName, LastName, Account.OwnerId, OwnerId FROM Contact WHERE Id IN :contactIds];
        System.debug('contactsToConvert: '+contactsToConvert);

        Map<String, String> userContactMap = new Map<String, String>();
        //Need to deactivate all users that are not using Person Accounts
        for (User us : userList){
        us.IsActive = false;
        us.IsPortalEnabled = false;
        us.Username = us.Username + 'xxx';
        us.Email = us.Email + 'xxx';
        us.FederationIdentifier = us.FederationIdentifier + 'xxx';
        us.CommunityNickname = 'deactivated' + us.CommunityNickname.left(28);
        userContactMap.put(us.ContactId, JSON.serialize(us));
        }
        update userList;

        System.Test.startTest();
        TTS_Store_RegistrationHandler.contactToPAConversion(JSON.serialize(contactsToConvert), JSON.serialize(savedUsers), JSON.serialize(userContactMap), JSON.serialize(userDataMap));
        System.Test.stopTest();
    }

    @isTest
    static void testCanCreateUser() {
        // Create a mock Auth.UserData object
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('language', 'en_US');
        attributeMap.put('identifiers', '{"username":"testuserlong"}');
        attributeMap.put('email', 'testuse8888r@example.org');
        Auth.UserData sampleData = new Auth.UserData(
            'testId', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMap
        );

        Map<String, String> attributeMapFail = new Map<String, String>();
        attributeMapFail.put('language', 'en_US');
        attributeMapFail.put('identifiers', '{"username":"testuserlong"}');
        Auth.UserData sampleDataFail = new Auth.UserData(
            'testId', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMapFail
        );

        // Instantiate the RegistrationHandler
        TTS_Store_RegistrationHandler handler = new TTS_Store_RegistrationHandler();

        // Test canCreateUser
        System.assertEquals(true, handler.canCreateUser(sampleData), 'Can create user');
        System.assertEquals(false, handler.canCreateUser(sampleDataFail), 'Cant create user');
    }

    @isTest
    static void testCreateUser(){
        Id portalId = null;

        // Create a mock Auth.UserData object
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('language', 'en_US');
        attributeMap.put('identifiers', '{"username":"testuserlong"}');
        attributeMap.put('email', 'testuse8888r@example.org');
        Auth.UserData sampleData = new Auth.UserData(
            'testId', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMap
        );

        Map<String, String> attributeMapFail = new Map<String, String>();
        attributeMapFail.put('language', 'en_US');
        attributeMapFail.put('identifiers', '{"username":"testuserlong"}');
        Auth.UserData sampleDataFail = new Auth.UserData(
            'testId', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMapFail
        );

        // Instantiate the RegistrationHandler
        TTS_Store_RegistrationHandler handler = new TTS_Store_RegistrationHandler();

        // Test createUser
        System.assert(handler.createUser(portalId, sampleData) != null, 'Can create user');
        System.assert(handler.createUser(portalId, sampleDataFail) == null, 'Cant create user');
    }

    @isTest
    static void testUpdateUser(){
        Id portalId = null;

        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'test@user.com';
        u.Username = 'test@user2702.com';
        u.Alias = 'testUser';
        u.CommunityNickname = 'testUserLong';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        insert u;

        // Create a mock Auth.UserData object
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('language', 'en_US');
        attributeMap.put('identifiers', '{"username":"testuserlong2"}');
        attributeMap.put('email', 'testuse8888r@example.org');
        attributeMap.put('phone_number', '1234567890');
        attributeMap.put('company', 'Test Company');

        Auth.UserData sampleData = new Auth.UserData(
            u.Id, 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMap
        );

        // Instantiate the RegistrationHandler
        TTS_Store_RegistrationHandler handler = new TTS_Store_RegistrationHandler();

        // Test updateUser
        Test.startTest();
        handler.updateUser(u.Id, portalId, sampleData);
        Test.stopTest();

        User updatedUser = [SELECT Id, FirstName, LastName, Email, Username, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, Phone, CompanyName FROM User WHERE Id = :u.Id];
        System.assertEquals('testFirst', updatedUser.FirstName, 'First name should be updated');
        System.assertEquals('testLast', updatedUser.LastName, 'Last name should be updated');
        System.assertEquals('testuse8888r@example.org', updatedUser.Email, 'Email should be updated');
    }

    @isTest 
    static void testHandleAccountCreation(){
        // Create a mock Auth.UserData object
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('language', 'en_US');
        attributeMap.put('identifiers', '{"username":"testuserlong2"}');
        attributeMap.put('email', 'testuse8888r@example.org');
        attributeMap.put('phone_number', '1234567890');
        attributeMap.put('company', 'Test Company');

        Auth.UserData sampleData = new Auth.UserData(
            'testId', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMap
        );

        // Instantiate the RegistrationHandler
        TTS_Store_RegistrationHandler handler = new TTS_Store_RegistrationHandler();

        // Test handleAccountCreation
        Test.startTest();
        Id a = handler.handleAccountCreation(sampleData, attributeMap);
        Test.stopTest();

        System.assert(a != null, 'Account should be created');
    }

    @isTest
    static void testHandleAccountCreation2(){      
        Account ttsSiteAccount = new Account(
            Name = 'TTS Sites Users'
        );
        insert ttsSiteAccount;
        // Create a contact
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'User';
        c.Email = 'testuse8888r@example.org';
        c.Phone = '1234567890';
        c.AccountId = ttsSiteAccount.Id;
        insert c;

        // Create a mock Auth.UserData object
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('language', 'en_US');
        attributeMap.put('identifiers', '{"username":"testuserlong2"}');
        attributeMap.put('email', 'testuse8888r@example.org');
        attributeMap.put('phone_number', '1234567890');
        attributeMap.put('company', 'Test Company');

        Auth.UserData sampleData = new Auth.UserData(
            'testId', 
            'testFirst', 
            'testLast',
            'testFirst testLast', 
            'testuse8888r@example.org', 
            null, 
            'testuserlong', 
            'en_US', 
            'facebook',
            null, 
            attributeMap
        );

        // Instantiate the RegistrationHandler
        TTS_Store_RegistrationHandler handler = new TTS_Store_RegistrationHandler();

        // Test handleAccountCreation
        Test.startTest();
        Id a = handler.handleAccountCreation(sampleData, attributeMap);
        Test.stopTest();

        System.assert(a != null, 'Account should be created');
    }

    @isTest
    static void testHandlePermissions(){
        User testUser = [SELECT Id, Username FROM User WHERE Name = 'Saltbox TestUser' LIMIT 1];

        // Create a test PermissionSetGroup record
        PermissionSetGroup testPSG = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'TTS_Store_Users'];

        if (testPSG.Status != 'Updated') {
            Test.calculatePermissionSetGroup(testPSG.Id);
          }

        // Call the method
        Test.startTest();
        //TTS_Store_RegistrationHandler.handlePermissions(testUser.Username);
        Test.stopTest();

        // Verify the results
        PermissionSetAssignment psa = [
            SELECT PermissionSetGroupId, AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :testUser.Id AND PermissionSetGroupId = :testPSG.Id
        ];
        System.assertEquals(testPSG.Id, psa.PermissionSetGroupId);
    }

    @isTest
    static void testUpdateAccountInfo() {
        // Create a test Account record
        Account testAccount = new Account(
            LastName = 'Test',
            FirstName = 'User',
            PersonEmail = 'test@example.com'
        );
        insert testAccount;

        // Prepare the parameters
        String aId = testAccount.Id;
        String email = 'updated@example.com';
        String phone = '1234567890';
        String firstName = 'Updated';
        String lastName = 'User';
        String company = 'Test Company';
        String source = 'Test Source';
        String country = 'US'; 
        Map<String, String> idMap = new Map<String, String>{'username' => 'updatedUser'};

        // Call the method
        Test.startTest();
        TTS_Store_RegistrationHandler.updateAccountInfo(aId, email, phone, firstName, lastName, company, source, country, idMap);
        Test.stopTest();

        // Verify the results
        Account updatedAccount = [SELECT PersonEmail, LastName, FirstName, Strivacity_Username__pc, PersonMobilePhone, Company__pc, How_did_you_hear_about_us__pc, Country_of_Residence__pc FROM Account WHERE Id = :aId];
        System.assertEquals(email, updatedAccount.PersonEmail);
        System.assertEquals(lastName, updatedAccount.LastName);
        System.assertEquals(firstName, updatedAccount.FirstName);
        System.assertEquals(idMap.get('username'), updatedAccount.Strivacity_Username__pc);
        System.assertEquals(phone, updatedAccount.PersonMobilePhone);
        System.assertEquals(company, updatedAccount.Company__pc);
        System.assertEquals(source, updatedAccount.How_did_you_hear_about_us__pc);
        System.assertEquals(country, updatedAccount.Country_of_Residence__pc);
    }
}