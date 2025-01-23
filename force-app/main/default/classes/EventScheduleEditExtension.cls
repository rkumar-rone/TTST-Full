/****************************************************************************************************
*Description:           This extension is used for Event Editing and controls which fields are
*                       pesented to the user based on the Event Record Type                   
*
*Required Class(es):    EventScheduleEditExtension_TEST
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     08/17/2015   Justin Padilla     Initial Implementation
*****************************************************************************************************/
public with sharing class EventScheduleEditExtension
{
    public Event_Schedule__c workingEventSchedule{get;set;}
    public Map<Id,RecordType> recordTypes {get;set;}
	public boolean IsAcademicClientEvent{
		get
		{
			boolean retval = false;
			if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName == 'Academic_Event_Client_Registration') retval = true;
			return retval; //defaulted to return false
		}set;}
	public boolean IsAcademicSalesforceEvent{
		get
		{
			boolean retval = false;
			if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName == 'Academic_Event_Salesforce_Registration') retval = true;
			return retval; //defaulted to return false
		}set;}
    public boolean IsCorporateEvent{
        get
        {
            boolean retval = false;
            if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName == 'Corporate_Event') retval = true;
            return retval; //defaulted to return false
        }set;}
    public boolean IsDefaultEvent{
        get
        {
            boolean retval = false;
            if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && (recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName != 'Corporate_Event' && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName != 'Academic_Event_Client_Registration')  && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName != 'Academic_Event_Salesforce_Registration') retval = true;
            return retval; //defaulted to return false
        }set;}
    
    public EventScheduleEditExtension(ApexPages.StandardController controller)
    {
        //Retreive the Event Schedule Information this will determine which layout is presented
        string eventScheduleId = Apexpages.currentPage().getParameters().get('id');
        if (eventScheduleId != null && eventScheduleId != '')
        {
            for (Event_Schedule__c es: [SELECT Id, RecordTypeId, Name FROM Event_Schedule__c WHERE Id =: eventScheduleId])
            {
                workingEventSchedule = es;
            }
        }
        system.debug('EventScheduleEditExtension - workingEventSchedule: '+workingEventSchedule);
        //Retrieve Record Types
        recordTypes = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Event_Schedule__c']);
        system.debug('EventScheduleEditExtension - recordTypes: '+recordTypes);
        system.debug('EventScheduleEditExtension - IsAcademicClientEvent: '+IsAcademicClientEvent);
        system.debug('EventScheduleEditExtension - IsAcademicSalesforceEvent: '+IsAcademicSalesforceEvent);
        system.debug('EventScheduleEditExtension - IsCorporateEvent: '+IsCorporateEvent);
        system.debug('EventScheduleEditExtension - IsDefaultEvent: '+IsDefaultEvent);
    }
}