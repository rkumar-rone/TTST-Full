/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_LoggerTest {
    @isTest
    static void testLog() {
        SIB_Application_Logic_Setting__c brs = new SIB_Application_Logic_Setting__c();
        brs.LogExceptions__c = true;
        brs.SetupOwnerId = System.UserInfo.getUserId();
        brs.EnableDebugLogs__c = true;
        insert brs;

        Test.startTest();
        LoggingLevel loggingLevel  = LoggingLevel.ERROR;
        Map<String, Object> mapRequestParam = new Map<String, Object>();
        mapRequestParam.put(SIB_LoggingConstant.MESSAGING_LOG, 'Test');
        SIB_Logger.log( 'processType', 'recordId', 'sourceId', 'triggerEvent', 'stackTrace', 'message');
        SIB_Logger.log(loggingLevel,  'className' ,  'methodName' ,  'entryPoint' ,  'message');
        SIB_Logger.handleApplicationLogging(mapRequestParam);
        List<SIB_Log> testresult = SIB_Logger.getLoggedMessages();

        System.assertNotEquals(null,testresult,'Passed');
        Test.stopTest();
    }

    @isTest
    static void testLogNull() {

        Test.startTest();
        LoggingLevel loggingLevel  = LoggingLevel.ERROR;
        Map<String, Object> mapRequestParam = new Map<String, Object>();
        mapRequestParam.put(SIB_LoggingConstant.MESSAGING_LOG, 'Test');
        SIB_Logger.log( 'processType', 'recordId', 'sourceId', 'triggerEvent', 'stackTrace', 'message');
        SIB_Logger.log(loggingLevel,  'className' ,  'methodName' ,  'entryPoint' ,  'message');
        SIB_Logger.handleApplicationLogging(mapRequestParam);
        List<SIB_Log> testresult = SIB_Logger.getLoggedMessages();

        System.assertEquals(null,testresult,'Passed');
        Test.stopTest();
    }

    @isTest
    static void testLogProfile() {
        SIB_Application_Logic_Setting__c brs = new SIB_Application_Logic_Setting__c();
        brs.LogExceptions__c = true;
        brs.SetupOwnerId = System.UserInfo.getProfileId();
        brs.EnableDebugLogs__c = true;
        insert brs;
        Test.startTest();
        LoggingLevel loggingLevel  = LoggingLevel.ERROR;
        Map<String, Object> mapRequestParam = new Map<String, Object>();
        mapRequestParam.put(SIB_LoggingConstant.MESSAGING_LOG, 'Test');
        SIB_Logger.log( 'processType', 'recordId', 'sourceId', 'triggerEvent', 'stackTrace', 'message');
        SIB_Logger.log(loggingLevel,  'className' ,  'methodName' ,  'entryPoint' ,  'message');
        SIB_Logger.handleApplicationLogging(mapRequestParam);
        List<SIB_Log> testresult = SIB_Logger.getLoggedMessages();

        System.assertNotEquals(null,testresult,'Passed');
        Test.stopTest();
    }
}