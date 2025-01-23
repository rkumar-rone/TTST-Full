/**
 * @description       : Test class for SIB_Log
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@IsTest
public class SIB_LogTest {
    @isTest
    static void testLog() {
        LoggingLevel loggingLevel  = LoggingLevel.ERROR;
        Test.startTest();
        SIB_Log testLog = new SIB_Log('processType', 'recordId', 'sourceId', 'triggerEvent', 'stackTrace', 'message'); 
        SIB_Log testLog2 = new SIB_Log(loggingLevel,  'className' ,  'methodName' ,  'entryPoint' ,  'message');
        system.assertNotEquals(null,testLog,'Passed');        
        Test.stopTest();
    }
}