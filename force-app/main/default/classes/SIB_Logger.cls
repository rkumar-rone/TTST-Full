/**
 * Created by junaidmohammed on 10/25/24.
 */

public with sharing class SIB_Logger {

    public static List<SIB_Log> logList;

    /**
     * @param processType - Process Name
     * @param recordId - Record Id
     * @param sourceId - Source Id
     * @param triggerEvent - Triggering Event
     * @param stackTrace - Exception Stack Trace
     * @param message - Message
     */
    public static void log(String processType, String recordId, String sourceId, String triggerEvent, String stackTrace, String message){
        SIB_Log errorLog = new SIB_Log(processType, recordId, sourceId,triggerEvent,stackTrace,message);
        if(logList==null)
        {
            logList = new List<SIB_Log>();
        }
        logList.add(errorLog);
    }

    /**
     * @param loggingLevel - Logging Level
     * @param className - Class Name
     * @param methodName - Method Name
     * @param entryPoint - Entry Point
     * @param message - Message
     */
    public static void log(LoggingLevel loggingLevel, String className , String methodName , String entryPoint , String message){
        SIB_Log errorLog = new SIB_Log(loggingLevel, className , methodName , entryPoint , message);
        if(logList==null)
        {
            logList = new List<SIB_Log>();
        }
        logList.add(errorLog);
    }

    /**
     * @param mapRequestParam - Request Input Map object
     */
    public static void handleApplicationLogging(Map<String, Object> mapRequestParam) {
        if ( (mapRequestParam != null &&
                (SIB_Application_Logic_Setting__c.getValues(System.UserInfo.getUserId()) != null &&
                        SIB_Application_Logic_Setting__c.getInstance(System.UserInfo.getUserId()).EnableDebugLogs__c) ||
                (SIB_Application_Logic_Setting__c.getValues(System.UserInfo.getProfileId()) != null &&
                        SIB_Application_Logic_Setting__c.getInstance(System.UserInfo.getProfileId()).EnableDebugLogs__c)) ||
                UserInfo.getUserType() == SIB_LoggingConstant.USER_TYPE_GUEST)
        {
            mapRequestParam.put(SIB_LoggingConstant.MESSAGING_LOG, JSON.serialize(SIB_Logger.logList, true));
        }
    }

    /**
     * @return List<B2BLog>
     */
    public static List<SIB_Log> getLoggedMessages() {
        if ( (
                (SIB_Application_Logic_Setting__c.getValues(System.UserInfo.getUserId()) != null &&
                        SIB_Application_Logic_Setting__c.getInstance(System.UserInfo.getUserId()).EnableDebugLogs__c) ||
                        (SIB_Application_Logic_Setting__c.getValues(System.UserInfo.getProfileId()) != null &&
                                SIB_Application_Logic_Setting__c.getInstance(System.UserInfo.getProfileId()).EnableDebugLogs__c)) ||
                UserInfo.getUserType() == SIB_LoggingConstant.USER_TYPE_GUEST)
        {
            return SIB_Logger.logList;
        }
        return null;
    }

}