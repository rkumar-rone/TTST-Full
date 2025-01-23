@isTest
private with sharing class Saltbox_B2BCourseRegisterControllerTest {
    @isTest
    static void testGetTTSEvent() {
        // Create test data
        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Class_Code__c = 'TEST123');
        insert testCampaign;

        String classCode = [SELECT Class_Code__c FROM Campaign WHERE Id = :testCampaign.Id].Class_Code__c;

        // Call the method
        Saltbox_B2BCourseRegisterVFController controller = new Saltbox_B2BCourseRegisterVFController();
        controller.ttsEventId = testCampaign.Id;
        System.debug('testCampaign.Id: ' + testCampaign.Id);
        System.debug('controller.ttsEventId: ' + controller.ttsEventId);
        Campaign result = controller.getTTSEvent();
        System.debug('result: ' + result);

        // Verify the results
        System.assertEquals(testCampaign.Id, result.Id);
        System.assertEquals(classCode, result.Class_Code__c);
    }

    @isTest
    static void testGetDomain() {
        String testUrlPathPrefix = '';
        List<Network> list1 = [
            SELECT UrlPathPrefix
            FROM Network
            WHERE EmailSenderName = 'TTS B2B Store'
        ];

        if (list1.size() > 0) {
            if (list1.get(0).UrlPathPrefix != null) {
                testUrlPathPrefix = list1.get(0).UrlPathPrefix + '/';
            }
        }

        List<Domain> domain = [
            SELECT Domain
            FROM Domain
            WHERE HttpsOption = 'CommunityAlt'
            LIMIT 1
        ];
      
        String myDomain = '';
        if (domain.size() > 0) {
            myDomain = domain.get(0).Domain;
        }

        String url = 'https://' + myDomain + '/' + testUrlPathPrefix + 's/';

        // Call the method
        Saltbox_B2BCourseRegisterVFController controller = new Saltbox_B2BCourseRegisterVFController();
        String result = controller.getDomain();

        // Verify the results
        System.assertEquals(url, result, 'The domain should be ' + url + ' but was ' + result);
    }

    @isTest
    static void testGetSiteURL() {
        // Create test data
        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Class_Code__c = 'TEST123');
        insert testCampaign;

        String testUrlPathPrefix = '';
        List<Network> list1 = [
            SELECT UrlPathPrefix
            FROM Network
            WHERE EmailSenderName = 'TTS B2B Store'
        ];

        if (list1.size() > 0) {
            if (list1.get(0).UrlPathPrefix != null) {
                testUrlPathPrefix = list1.get(0).UrlPathPrefix + '/';
            }
        }

        List<Domain> domain = [
            SELECT Domain
            FROM Domain
            WHERE HttpsOption = 'CommunityAlt'
            LIMIT 1
        ];
      
        String myDomain = '';
        if (domain.size() > 0) {
            myDomain = domain.get(0).Domain;
        }

        String classCode = [SELECT Class_Code__c FROM Campaign WHERE Id = :testCampaign.Id].Class_Code__c;

        String url = 'https://' + myDomain + '/' + testUrlPathPrefix + 's/course-registration?CourseCode=' + classCode + '&courseId=' + testCampaign.Id;

        // Call the method
        Saltbox_B2BCourseRegisterVFController controller = new Saltbox_B2BCourseRegisterVFController();
        controller.ttsEventId = testCampaign.Id;
        String result = controller.getSiteURL();

        // Verify the results
        System.assertEquals(url, result, 'The site URL should be ' + url + ' but was ' + result);
    }
}