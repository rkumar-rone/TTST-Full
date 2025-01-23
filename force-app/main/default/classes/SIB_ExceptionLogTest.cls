/**
 * Created by junaidmohammed on 10/25/24.
 */

@IsTest
private class SIB_ExceptionLogTest {

    @IsTest
    static void testStoreExceptionLog() {
        SIB_Application_Logic_Setting__c brs = new SIB_Application_Logic_Setting__c();
        brs.LogExceptions__c = true;
        brs.SetupOwnerId = System.UserInfo.getUserId();
        brs.EnableDebugLogs__c = true;
        insert brs;

        Test.startTest();
        Account acc = new Account();
        try{
            acc.BillingLongitude=1/0;
            if(acc!=null)
            {
                insert acc;
            }
        }
        catch(Exception e){
            SIB_ExceptionLog.Log(e,'CWS_Error_Log__c' , 'CWS_ExceptionHandler' , 'insertException' , '');
            SIB_ExceptionLog.Log(e, null , 'CWS_ExceptionHandler' , 'insertException' , '');
            SIB_ExceptionLog.Log(e,'CWS_Error_Log__c' , 'CWS_ExceptionHandler' , 'insertException' , '','null');
        }
        System.assertEquals (acc.Id, null,'passed');
        Test.stopTest();
    }

}