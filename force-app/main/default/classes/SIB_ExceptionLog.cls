/**
 * Created by junaidmohammed on 10/25/24.
 */

public with sharing class SIB_ExceptionLog {

    public class B2BException extends Exception{}
    private static String SOBJECT_NAME = 'SIBExceptionLog__c';
    private static Integer recursiveCount = 0;
    private static final Integer MAX_TRIES = 5;

    //  @param excp , applicationName , moduleName , className , methodName
    //  @return return nothing
    //  this method is used to create exception logs record
    public static void log(Exception excp , String applicationName , String moduleName , String className , String methodName) {
        try
        {
            storeExceptionLog(excp , applicationName , moduleName , className , methodName,null);
        }
        catch (Exception e)
        {
            cleanUp(SOBJECT_NAME);
        }
    }

    public static void Log(Exception excp , String applicationName , String moduleName , String className , String methodName,String supportData)
    {
        storeExceptionLog(excp,applicationName,moduleName,className,methodName,supportData);
    }

    public static void storeExceptionLog(Exception excp , String applicationName , String moduleName , String className , String methodName,String supportData)
    {
        System.debug('########storeExceptionLog#######');
        try {
//            if(
//                    (B2BApplicationRunLogicSettings__c.getValues(System.UserInfo.getUserId()) != null &&
//                            B2BApplicationRunLogicSettings__c.getInstance(System.UserInfo.getUserId()).LogExceptions__c) ||
//                            (B2BApplicationRunLogicSettings__c.getValues(System.UserInfo.getProfileId()) != null &&
//                                    B2BApplicationRunLogicSettings__c.getInstance(System.UserInfo.getProfileId()).LogExceptions__c))
//            {
            String queryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String dmlLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String dmlStat = '3. Number of DML statements used so far / Number allowed: ' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();
            String cpuUsage = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            List<String> lstSalesforceLimit = new List<String>();
            lstSalesforceLimit.add(queryLimit);
            lstSalesforceLimit.add(dmlLimit);
            lstSalesforceLimit.add(dmlStat);
            lstSalesforceLimit.add(cpuUsage);
            //Create exception record
            SIBExceptionLog__c exc = new SIBExceptionLog__c();
            exc.SalesforceLimits__c = String.format('{0}\n{1}\n{2}\n{3}', lstSalesforceLimit);
            exc.ErrorMessage__c = excp.getMessage();
            exc.ExceptionType__c = excp.getTypeName();
            exc.LineNumber__c = excp.getLineNumber();
            exc.StackTrace__c = excp.getStackTraceString();
            exc.ApplicationName__c = applicationName;
            exc.ModuleName__c = moduleName;
            exc.ClassName__c = className;
            exc.MethodName__c = methodName;
            exc.ExceptionRunningUser__c = UserInfo.getUserId();
            //supportData +=  '\n\r\n\rUser Login History : ' + userLoginHistroy();
            String loggingMessages = '';
            if (SIB_Logger.logList != null && SIB_Logger.logList.size() > 0)
            {
                for (SIB_Log b2bLogObject : SIB_Logger.logList) {
                    loggingMessages += b2bLogObject.methodName + ' - ' + b2bLogObject.message + '\n';
                }
            }
            String strExceptionMessage = supportData + loggingMessages;
            Integer strLength = strExceptionMessage.length();
            Integer fieldLength = Schema.SObjectType.SIBExceptionLog__c.fields.ErrorSupportData__c.getLength();
            System.debug('########exc.ErrorMessage__c #######' + exc.ErrorMessage__c);
            System.debug('########exc.ExceptionType__c  #######' + exc.ExceptionType__c );
            System.debug('########exc.LineNumber__c  #######' + exc.LineNumber__c );
            System.debug('########strLength #######' + strLength);
            System.debug('########fieldLength #######' + fieldLength);
            if (strLength >= fieldLength)
            {
                Integer strFinalLength = strLength - (fieldLength - 100);
                System.debug('########strFinalLength #######' + strFinalLength);
                strExceptionMessage = strExceptionMessage.substring(strFinalLength);
            }
            System.debug('########strExceptionMessage finally  #######' + strExceptionMessage.length());
            exc.ErrorSupportData__c = String.escapeSingleQuotes(strExceptionMessage);
            System.debug('Custom:Exception' + JSON.serialize(exc));
            if( Schema.getGlobalDescribe().get(SOBJECT_NAME).getDescribe().isCreateable() &&
                    Limits.getLimitDmlStatements()>0)
            {
                Database.insert(exc);
            }

            System.debug('########after inserting exception e #######');
            System.debug('Custom:Exception ErrorMessage__c ' + exc.ErrorMessage__c);
            System.debug('Custom:Exception LineNumber__c ' + exc.LineNumber__c);
            System.debug('Custom:Exception ClassName__c ' + exc.ClassName__c);
            System.debug('Custom:Exception MethodName__c ' + exc.MethodName__c);
            System.debug('Custom:Exception ClassName__c ' + exc.ClassName__c);
            System.debug('Custom:Exception MethodName__c ' + exc.MethodName__c);
            SIB_Logger.log(LoggingLevel.ERROR, exc.ClassName__c, exc.MethodName__c, SIB_LoggingConstant.MESSAGING_ENTRY, 'Start');
            SIB_Logger.log(LoggingLevel.ERROR, exc.ClassName__c, exc.MethodName__c, SIB_LoggingConstant.MESSAGING_VALUE, exc.ExceptionType__c);
            SIB_Logger.log(LoggingLevel.ERROR, exc.ClassName__c, exc.MethodName__c, SIB_LoggingConstant.MESSAGING_VALUE, exc.ErrorMessage__c);
            SIB_Logger.log(LoggingLevel.ERROR, exc.ClassName__c, exc.MethodName__c, SIB_LoggingConstant.MESSAGING_VALUE, exc.LineNumber__c + '');
            SIB_Logger.log(LoggingLevel.ERROR, exc.ClassName__c, exc.MethodName__c, SIB_LoggingConstant.MESSAGING_VALUE, exc.StackTrace__c);
            SIB_Logger.log(LoggingLevel.ERROR, exc.ClassName__c, exc.MethodName__c, SIB_LoggingConstant.MESSAGING_EXIT, 'End');
            cleanUp(SOBJECT_NAME);

            //  }
        }catch (Exception exceptionObject) {
            System.debug('######## Error message #######' + exceptionObject);
            System.debug('######## Error message #######' + exceptionObject.getStackTraceString());
            System.debug('######## Error message #######' + exceptionObject.getMessage());
            cleanUp(SOBJECT_NAME);
        }
    }

    public static void cleanUp(String sObjectName)
    {
        // cleanUp any  records that are older than ExceptionLogCleanUpDays days
        Datetime daysLogsToBeDeleted = System.now() - Integer.valueOf(30);
        List<Id> successfullyDeletedIDList = new List<Id>();
        if(Test.isRunningTest())
        {
            daysLogsToBeDeleted = System.now() + 1;
        }
        System.debug('daysLogsToBeDeleted $$$$$$$$$$'+daysLogsToBeDeleted);

        String queryString = 'SELECT Id FROM ' + sObjectName + ' WHERE LastModifiedDate <= '+ daysLogsToBeDeleted.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +' limit 2000 FOR UPDATE';

        System.debug('queryString '+ queryString);

        List<SObject> recordsTobeDeletedList = Database.query(queryString);
        System.debug('mapOldLogsRecords  $$$$$$$$$$'+recordsTobeDeletedList);
        if (!recordsTobeDeletedList.isEmpty())
        {
            try
            {
                Database.DeleteResult[] deleteResultList = Database.delete(recordsTobeDeletedList, false);
                System.debug('deleteResultList '+deleteResultList);
                // Iterate through deleteResultList based on isSuccess capture the failed records
                for (Database.DeleteResult sr : deleteResultList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully Deleted ID: ' + sr.getId());
                        successfullyDeletedIDList.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Sobject fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                if(!successfullyDeletedIDList.isEmpty())
                {
                    Database.emptyRecycleBin(successfullyDeletedIDList);  //Hard delete records from Salesforce
                }
            }
            catch (Exception ex)
            {
                if (recursiveCount < MAX_TRIES )
                {
                    recursiveCount++;
                    cleanUp(SOBJECT_NAME); // This will keep on checking unless it will delete all the records. Kind of recursive mechanism
                }
            }
        }
    }

}