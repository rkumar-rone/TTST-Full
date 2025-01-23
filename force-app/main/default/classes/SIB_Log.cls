/**
 * Created by junaidmohammed on 10/25/24.
 */

public with sharing class SIB_Log {

    public String processType {set; get;}
    public String recordId {set; get;}
    public String sourceId {set; get;}
    public String message {set; get;}
    public String triggerEvent {set; get;}
    public String stackTrace {set; get;}
    public String className{set;get;}
    public String methodName{set;get;}
    public String entryPoint{set;get;}
    public LoggingLevel loggingLevel{set;get;}

    /**
     * B2BLog Wrapper object constructor
     * @param  processType  The sync process type that failed
     * @param  recordId     The Id of the record that failed
     * @param  sourceId     The source record Id if the object has one
     * @param  triggerEvent The event that kicked of the record sync attempt
     * @param  stackTrace   The error stack trace message, if it exists
     * @param  message      The error message text
     */
    public SIB_Log(String processType, String recordId, String sourceId, String triggerEvent, String stackTrace, String message){
        this.processType = processType;
        this.recordId = recordId;
        this.sourceId = sourceId;
        this.triggerEvent = triggerEvent;
        this.stackTrace = stackTrace;
        this.message = message;
    }

    /**
     * B2BLog Wrapper object constructor
     *
     * @param loggingLevel The sync process type that failed
     * @param className The Id of the record that failed
     * @param methodName The source record Id if the object has one
     * @param entryPoint The event that kicked of the record sync attempt
     * @param message The error message text
     */
    public SIB_Log(LoggingLevel loggingLevel , String className , String methodName , String entryPoint, String message){
        this.loggingLevel = loggingLevel;
        this.className = className;
        this.methodName = methodName;
        this.entryPoint = entryPoint;
        this.message = message;
    }

}