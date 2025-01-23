/**
 * Created by junaidmohammed on 10/25/24.
 */

public with sharing class SIB_CaptureApplicationLog {

    private static Integer recursiveCount = 0;
    private static final Integer MAX_TRIES = 5;

    @Future(Callout=true)
    public static void futureCaptureApplicationLog(String appName,String appRequest,String appResponse, String cartId , String supportData)
    {
        captureApplicationLogs( appName, appRequest, appResponse , cartId , supportData);
    }

    public static SIBCaptureApplicationLog__c captureApplicationLogs(String appName,String appRequest , String appResponse ,  String cartId , String supportData)
    {
        String loggingMessages = supportData;
        if (SIB_Logger.logList != null && SIB_Logger.logList.size() > 0)
        {
            for (SIB_Log b2bLogObject : SIB_Logger.logList)
            {
                loggingMessages += b2bLogObject.methodName + ' - ' + b2bLogObject.message + '\n';
            }
        }
        Integer strLength = loggingMessages.length();
        Integer fieldLength = Schema.SObjectType.SIBCaptureApplicationLog__c.fields.SupportData__c.getLength();
        if (strLength >= fieldLength)
        {
            Integer strFinalLength = strLength - (fieldLength - 100);
            System.debug('########strFinalLength #######' + strFinalLength);
            loggingMessages = loggingMessages.substring(strFinalLength);
        }
        SIBCaptureApplicationLog__c objCapture = new SIBCaptureApplicationLog__c();
        objCapture.Application__c = appName;
        objCapture.Request__c = appRequest;
        objCapture.Response__c = appResponse;
        objCapture.RunningUser__c = UserInfo.getUserId();
        objCapture.SupportData__c =  String.escapeSingleQuotes(loggingMessages);
        if(String.isNotBlank(cartId))
        {
            objCapture.RecordId__c = cartId;
            objCapture.Cart__c = cartId;
        }
        try{
            insert objCapture;
            cleanUp();
        }
        catch(Exception ex){
            cleanUp();
        }
        return objCapture;
    }

    public static void cleanUp()
    {
        // cleanUp any  records that are older than 30 days
        Datetime oneMonthOld = System.now() - Integer.valueOf(60);
        if(Test.isRunningTest())
        {
            oneMonthOld = System.now();
        }
        System.debug('60 Days $$$$$$$$$$'+oneMonthOld);
        Map<Id,SIBCaptureApplicationLog__c> mapOldRecords = new Map<Id,SIBCaptureApplicationLog__c>([SELECT Id FROM SIBCaptureApplicationLog__c
        WHERE LastModifiedDate <= :oneMonthOld LIMIT 5000]);
        System.debug('mapOldRecords  $$$$$$$$$$'+mapOldRecords);
        if (!mapOldRecords.isEmpty())
        {
            try
            {
                delete mapOldRecords.values();
            }
            catch (Exception ex){
                if (recursiveCount < MAX_TRIES )
                {
                    recursiveCount++;
                    cleanUp(); // This will keep on checking unless it will delete all the records. Kind of recursive mechanism
                }
            }
        }
    }

}