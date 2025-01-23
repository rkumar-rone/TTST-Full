/**
 * Created by junaidmohammed on 10/25/24.
 */

@IsTest
private class SIB_CaptureApplicationLogTest {

    @IsTest
    static void logTestMethodOne()
    {
        SIBCaptureApplicationLog__c testCA = new SIBCaptureApplicationLog__c();
        testCA.Request__c = 'ErrorCode';
        testCA.Response__c = 'ErrorMessage';
        insert testCA;
        Test.startTest();
       
        SIB_Logger.log('processType', 'recordId', 'sourceId','triggerEvent','stackTrace','message');
        SIB_CaptureApplicationLog.futureCaptureApplicationLog('AEE', 'Request', 'Response', SIB_TestDataFactory.getMockId(WebCart.SObjectType),'test123');
        Test.stopTest();
    }

}