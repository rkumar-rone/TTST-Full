public with sharing class MoodleDeactivateBatch  implements  Database.Batchable<SObject>, Database.AllowsCallouts {
	
	public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime sessionDate = dateTime.now();
        Moodle_Configuration__mdt config = [Select Id, Minutes_Until_Deactivation__c from Moodle_Configuration__mdt where Active__c = true];
        Integer minutes = (0 - (config.Minutes_Until_Deactivation__c == null ? 129600 : config.Minutes_Until_Deactivation__c.intValue()));
        sessionDate = sessionDate.addMinutes(minutes);
		return Database.getQueryLocator([Select Id from Contact where LMS_Id__c != null and Suspend_LMS_Account__c = false and (Session_Expiration__c = null or Session_Expiration__c <= :sessionDate)]);
	}

	public void execute(Database.BatchableContext BC, List<Contact> scope){
		for(Contact c : scope) {
            c.Suspend_LMS_Account__c = true;
        }
        update scope;
	}
	
	public void finish(Database.BatchableContext BC){
	}	 
	
       
}