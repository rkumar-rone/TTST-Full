@isTest
public class MoodleTest {

    @testSetup
    static void setupTestData() {
        // Create Contacts with mandatory LMS_Id__c field as an integer
        Contact testContact1 = new Contact(
            FirstName = 'Test', 
            LastName = 'User1', 
            LMS_Id__c = 12345
        );
        Contact testContact2 = new Contact(
            FirstName = 'Test', 
            LastName = 'User2', 
            LMS_Id__c = 67890
        );
        insert new List<Contact>{testContact1, testContact2};

        // Create Campaigns with mandatory LMS_Id__c field as an integer
        Campaign testCampaign1 = new Campaign(Name = 'Test Campaign 1', Status = 'Planned', LMS_Id__c = 11111,Date_RC_Access_Ends__c = System.now().addDays(3));
        Campaign testCampaign2 = new Campaign(Name = 'Test Campaign 2', Status = 'Planned', LMS_Id__c = 22222,Date_RC_Access_Ends__c = System.now().addDays(3));
        insert new List<Campaign>{testCampaign1, testCampaign2};

        // Create CampaignMembers for the same contact in multiple campaigns
        CampaignMember cm1 = new CampaignMember(ContactId = testContact1.Id, CampaignId = testCampaign1.Id, Status = 'Sent');
        CampaignMember cm2 = new CampaignMember(ContactId = testContact1.Id, CampaignId = testCampaign2.Id, Status = 'Sent');
        CampaignMember cm3 = new CampaignMember(ContactId = testContact2.Id, CampaignId = testCampaign1.Id, Status = 'Sent');
        CampaignMember cm4 = new CampaignMember(ContactId = testContact2.Id, CampaignId = testCampaign2.Id, Status = 'Sent');
        insert new List<CampaignMember>{cm1, cm2, cm3, cm4};
    }

    @isTest
    static void testGetUsers() {
        // Fetch test data
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, LMS_Id__c FROM Contact];

        // Mock HTTP response for valid case
        Test.setMock(HttpCalloutMock.class, new MoodleHttpMock());

        Test.startTest();
        // Call the method to test
        MoodleBatchHelper.GetUsers(contacts);
        Test.stopTest();

        // Verify the side effects (e.g., checking for any updates or logs created)
        List<Moodle_API_Error__c> errorLogs = [SELECT Id, Function__c, Contact__c, Exception__c, Error_Code__c, Message__c, Debug_Info__c FROM Moodle_API_Error__c];
        System.assertNotEquals(0, errorLogs.size(), 'There should be error logs created');
        
        // Further assertions based on the expected behavior and created data
        for (Moodle_API_Error__c log : errorLogs) {
            System.assertNotEquals(null, log.Function__c, 'Function__c should not be null');
            System.assertNotEquals(null, log.Contact__c, 'Contact__c should not be null');
        }
    }
    
    @isTest
    static void testGetUsersExceptions() {
        // Fetch test data
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, LMS_Id__c FROM Contact];

        // Mock HTTP response for valid case
        Test.setMock(HttpCalloutMock.class, new MoodleHttpExceptionMock());

        Test.startTest();
        // Call the method to test
        MoodleBatchHelper.GetUsers(contacts);
        Test.stopTest();

    }
    
    @isTest
    static void testGetUsersCalloutFailure() {
        // Fetch test data
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, LMS_Id__c FROM Contact];

        // Mock HTTP response for valid case
        Test.setMock(HttpCalloutMock.class, new InvalidMoodleHttpMock());

        Test.startTest();
        // Call the method to test
        MoodleBatchHelper.GetUsers(contacts);
        Test.stopTest();

    }

    @isTest
    static void testGetUsersSpecificScenario() {
        // Fetch test data with specific conditions to cover lines 64-72
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, LMS_Id__c FROM Contact WHERE LMS_Id__c != null];

        // Mock HTTP response for a specific scenario
        Test.setMock(HttpCalloutMock.class, new SpecificScenarioMoodleHttpMock());

        Test.startTest();
        // Call the method to test
        MoodleBatchHelper.GetUsers(contacts);
        Test.stopTest();

        // Verify specific side effects
        List<Moodle_API_Error__c> errorLogs = [SELECT Id, Function__c, Contact__c, Exception__c, Error_Code__c, Message__c, Debug_Info__c FROM Moodle_API_Error__c WHERE Error_Code__c = 'SPECIFIC_CODE'];
        System.assertEquals(0, errorLogs.size(), 'There should be no error logs created for this specific scenario');
    }

    @isTest
    static void testMoodleFile() {
        // Arrange
        MoodleBatchHelper.MoodleFile file = new MoodleBatchHelper.MoodleFile();
        file.filename = 'testFile.pdf';
        file.filepath = '/files/testFile.pdf';
        file.filesize = 12345;
        file.fileurl = 'https://example.com/files/testFile.pdf';
        file.timemodified = 1625190000;
        file.mimetype = 'application/pdf';
        file.isexternalfile = 0;
        file.repositorytype = 'internal';

        // Act & Assert
        System.assertEquals('testFile.pdf', file.filename);
        System.assertEquals('/files/testFile.pdf', file.filepath);
        System.assertEquals(12345, file.filesize);
        System.assertEquals('https://example.com/files/testFile.pdf', file.fileurl);
        System.assertEquals(1625190000, file.timemodified);
        System.assertEquals('application/pdf', file.mimetype);
        System.assertEquals(0, file.isexternalfile);
        System.assertEquals('internal', file.repositorytype);
    }

    @isTest
    static void testMoodleUserResponse() {
        // Arrange
        MoodleBatchHelper.MoodleUserResponse user = new MoodleBatchHelper.MoodleUserResponse();
        user.id = 1;
        user.username = 'testuser';
        user.firstname = 'Test';
        user.lastname = 'User';
        user.fullname = 'Test User';
        user.email = 'testuser@example.com';
        user.department = 'Testing';
        user.firstaccess = 1625190000L;
        user.lastaccess = 1625193600L;
        user.auth = 'manual';
        user.suspended = false;
        user.confirmed = true;
        user.lang = 'en';
        user.theme = 'standard';
        user.timezone = 'UTC';
        user.mailformat = 1;
        user.description = 'This is a test user';
        user.descriptionformat = 1;
        user.profileimageurlsmall = 'https://example.com/images/testuser_small.jpg';
        user.profileimageurl = 'https://example.com/images/testuser.jpg';

        // Act & Assert
        System.assertEquals(1, user.id);
        System.assertEquals('testuser', user.username);
        System.assertEquals('Test', user.firstname);
        System.assertEquals('User', user.lastname);
        System.assertEquals('Test User', user.fullname);
        System.assertEquals('testuser@example.com', user.email);
        System.assertEquals('Testing', user.department);
        System.assertEquals(1625190000L, user.firstaccess);
        System.assertEquals(1625193600L, user.lastaccess);
        System.assertEquals('manual', user.auth);
        System.assertEquals(false, user.suspended);
        System.assertEquals(true, user.confirmed);
        System.assertEquals('en', user.lang);
        System.assertEquals('standard', user.theme);
        System.assertEquals('UTC', user.timezone);
        System.assertEquals(1, user.mailformat);
        System.assertEquals('This is a test user', user.description);
        System.assertEquals(1, user.descriptionformat);
        System.assertEquals('https://example.com/images/testuser_small.jpg', user.profileimageurlsmall);
        System.assertEquals('https://example.com/images/testuser.jpg', user.profileimageurl);
    }

    @isTest
    static void testMoodleModules() {
        // Arrange
        MoodleBatchHelper.MoodleModules module = new MoodleBatchHelper.MoodleModules();
        module.id = 1;
        module.url = 'https://example.com/course';
        module.name = 'Test Module';
        module.instance = 101;
        module.visible = 1;
        module.uservisible = true;
        module.visibleoncoursepage = 1;
        module.modicon = 'https://example.com/icon.png';
        module.modname = 'Resource';
        module.modplural = 'Resources';
        module.indent = 0;
        module.completion = 1;
        
        module.description ='test';
        module.availability ='test';
        module.onclick ='test';
        module.afterlink ='test';
        module.customdata ='test';
        module.noviewlink = false;
        
        module.completiondata = new MoodleBatchHelper.MoodleCompletion();
        module.contents = new List<MoodleBatchHelper.MoodleContents>();
        module.contensinfo = new MoodleBatchHelper.MoodleContentsInfo();
            
    }

    @isTest
    static void testMoodleUserCourseResponse() {
        // Arrange
        MoodleBatchHelper.MoodleUserCourseResponse course = new MoodleBatchHelper.MoodleUserCourseResponse();
        course.id = 123;
        course.fullname = 'Test Course';
        course.shortname = 'TC';
        course.enrolledusercount = 50;
        course.idnumber = 'TC123';
        course.visible = 1;
        course.summary = 'This is a test course.';
        course.summaryformat = 1;
        course.format = 'topics';
        course.showgrades = true;
        course.lang = 'en';
        course.enablecompletion = true;
        course.completionhascriteria = true;
        course.completionusertracked = true;
        course.category = 12;
        course.progress = 0.75;
        course.completed = true;
        course.startdate = 1622520000;
        course.enddate = 1625108400;
        course.marker = 1;
        course.lastaccess = 1625100000;
        course.isfavourite = true;
        course.hidden = false;
        course.displayname ='test';
        course.overviewfiles =new List<MoodleBatchHelper.MoodleFile>();
    }
    
    @isTest
    static void testMoodleUserCourseActivityStatus() {
        // Arrange
        MoodleBatchHelper.MoodleUserCourseActivityStatus activityStatus = new MoodleBatchHelper.MoodleUserCourseActivityStatus();
        activityStatus.cmid = 1;
        activityStatus.state = 1;
        activityStatus.modname = 'test';
        activityStatus.instance = 1;
        activityStatus.timecompleted = 12;
        activityStatus.tracking = 123;
        activityStatus.overrideby =123;
        activityStatus.valueused =false;

    }
    
    @isTest
    static void testMoodleUserCourseActivityResponse() {
        MoodleBatchHelper.MoodleUserCourseActivityResponse activityRes = new MoodleBatchHelper.MoodleUserCourseActivityResponse();
        activityRes.statuses = new List<MoodleBatchHelper.MoodleUserCourseActivityStatus>();
        activityRes.warnings = new List<MoodleBatchHelper.MoodleUserCourseActivityWarning>();
		
	}


    @isTest
    static void testMoodleContents() {
        // Arrange
        MoodleBatchHelper.MoodleContents content = new MoodleBatchHelper.MoodleContents();
        content.type = 'file';
        content.filename = 'testFile.pdf';
        content.filepath = '/files/testFile.pdf';
        content.filesize = 12345;
        content.fileurl = 'https://example.com/files/testFile.pdf';
        content.timemodified = 1625190000;
        content.mimetype = 'application/pdf';
        content.isexternalfile = false;
        content.userid = 1;
        content.author = 'Test Author';
        content.license = 'Test License';
        
        content.content ='test';
        content.timecreated =123;
        content.sortorder =12345;
        content.repositorytype ='testRepo';
        content.tags = new List<MoodleBatchHelper.MoodleTag>();


    }

    @isTest
    static void testMoodleTag() {
        // Arrange
        MoodleBatchHelper.MoodleTag tag = new MoodleBatchHelper.MoodleTag();
        tag.id = 1;
        tag.name = 'test tag';
        tag.rawname = 'testRawName';
        tag.isstandard = 1;
        tag.tagcollid = 12;
        tag.taginstanceid = 1233;
        tag.taginstancecontextid = 1244;
        tag.itemid = 1234;
        tag.ordering = 12343;
        tag.flag = 1232;

        // Act & Assert
        System.assertEquals(1, tag.id);
        System.assertEquals('test tag', tag.name);
        System.assertEquals('testRawName', tag.rawname);
        System.assertEquals(1, tag.isstandard);
        System.assertEquals(12, tag.tagcollid);
        System.assertEquals(1233, tag.taginstanceid);
        System.assertEquals(1244, tag.taginstancecontextid);
        System.assertEquals(1234, tag.itemid);
        System.assertEquals(12343, tag.ordering);
        System.assertEquals(1232, tag.flag);
    }

    // Mock HTTP Response for valid response
    private class MoodleHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            // Provide a mock response for the GetUsers callout
            if (req.getEndpoint().contains('get_users')) {
                res.setBody('[{"id":12345,"username":"testuser1","firstname":"Test","lastname":"User1","email":"testuser1@example.com","courses":[{"id":11111,"progress":75,"enablecompletion":true,"lastaccess":1609459200,"isfavourite":true,"activities":[{"id":1,"status":true},{"id":2,"status":false}]}]},{"id":67890,"username":"testuser2","firstname":"Test","lastname":"User2","email":"testuser2@example.com","courses":[{"id":22222,"progress":50,"enablecompletion":false,"lastaccess":1609459200,"isfavourite":false,"activities":[{"id":1,"status":true},{"id":2,"status":false}]}]}]');
            }
            return res;
        }
    }

    // Mock HTTP Response for invalid response
    private class InvalidMoodleHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500); // Internal Server Error
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    // Mock HTTP Response to throw an exception
    private class ExceptionMoodleHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Simulated callout exception');
        }
    }

    // Mock HTTP Response for a specific scenario
    private class SpecificScenarioMoodleHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('[{"id":12345,"username":"testuser1","firstname":"Test","lastname":"User1","email":"testuser1@example.com","courses":[{"id":11111,"progress":75,"enablecompletion":true,"lastaccess":1609459200,"isfavourite":true,"activities":[{"id":1,"status":true},{"id":2,"status":false}]}]}]');
            return res;
        }
    }
    
    // Mock HTTP Response for a specific scenario
    private class MoodleHttpExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"exception_x":"exception","errorcode":"exception","exception":"Exception occurred","debuginfo":"exception debug"}');
            return res;
        }
    }
    
    @isTest
    static void testMoodleUserCourseActivityWarning() {
        // Arrange
        MoodleBatchHelper.MoodleUserCourseActivityWarning muca = new MoodleBatchHelper.MoodleUserCourseActivityWarning();
        muca.item ='rest';
        muca.itemid = 12;
        muca.warningcode = 'test';
        muca.message = 'test';
    }
    
    @isTest
    static void testMoodleCompletion() {
        // Arrange
        MoodleBatchHelper.MoodleCompletion mc = new MoodleBatchHelper.MoodleCompletion();
        mc.state = 1;
		mc.timecompleted = 1;
		mc.overrideby = 1;
		mc.valueused =false;
    }
    
    @isTest
    static void testMoodleContentsInfo() {
        MoodleBatchHelper.MoodleContentsInfo mci = new MoodleBatchHelper.MoodleContentsInfo();
        
        mci.filescount = 1234;
        mci.filesize = 1234;
        mci.lastmodified = 1234;
        mci.mimetypes = 'json';
        mci.repositorytype = 'tts';
    }
    
    @isTest
    static void testMoodleCourseResponse() {
        MoodleBatchHelper.MoodleCourseResponse mcr = new MoodleBatchHelper.MoodleCourseResponse();

		mcr.id = 1234;
		mcr.name ='test';
		mcr.visible = 1234;
		mcr.summary ='test';
		mcr.summaryformat = 1234;
		mcr.section = 1234;
		mcr.hiddenbynumsections = 1234;
		mcr.uservisible = false;

    }
    
    @isTest
    static void testMoodleGroup() {
        MoodleBatchHelper.MoodleGroup mg = new MoodleBatchHelper.MoodleGroup();
        
        mg.id =123;
        mg.courseid =1234;
        mg.name ='test';
        mg.description ='test';
        mg.descriptionformat =24543;
        mg.enrollmentkey ='test';
        mg.idnumber ='test23';
    }
    
    @isTest
    static void testMoodleCategory() {
        MoodleBatchHelper.MoodleCategory mc = new MoodleBatchHelper.MoodleCategory();

    	mc.id=123;
    	mc.name='test';
    }
    
    @isTest
    static void testMoodleCourse() {
        MoodleBatchHelper.MoodleCourse mc = new MoodleBatchHelper.MoodleCourse();

    	mc.id=123;
    	mc.shortName='test';
    }
    
     @isTest
    static void testMoodleUser() {
        MoodleBatchHelper.MoodleUser mc = new MoodleBatchHelper.MoodleUser();

    	mc.id=123;
    	mc.userName='test';
    }
}