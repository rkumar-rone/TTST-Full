/**
    * @description : Converted Trigger from Contact object run off of the Person Account object. Handles parsing updates and creating and updating Moodle users via queueable class
    * @created Date : 1st October 2023
    * @Author : Nathan Anderson
    * @LastModified
*/
trigger UpsertMoodleUser_PersonAccountTrigger on Account (after insert, after update, after delete) {
	Id[] toUpsert = new Id[0];
	Boolean[] create = new Boolean[0];
	String[] deleteIds = new String[0];
	Decimal[] deleteLMSIds = new Decimal[0];
	String[] deleteNames = new String[0];
    String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

	
	if(Trigger.isInsert || Trigger.isUpdate) {
    	for(Account a : Trigger.new) {
            if(a.RecordTypeId == recordTypeId) {
                Contact c = [SELECT Id, LMS_Id__c, Email, User_Id__c, Has_Registered_Synced_Events__c, FirstName, LastName, Suspend_LMS_Account__c FROM Contact WHERE Id = :a.PersonContactId];

                if(c.User_Id__c != null && c.User_Id__c != '' && c.Email != null && c.Email != '' && c.Has_Registered_Synced_Events__c) {
                    if(Trigger.isInsert || c.Email != Trigger.oldMap.get(a.Id).PersonEmail || c.User_Id__c != Trigger.oldMap.get(a.Id).User_Id__pc || c.FirstName != Trigger.oldMap.get(a.Id).FirstName || (c.Suspend_LMS_Account__c != Trigger.oldMap.get(a.Id).Suspend_LMS_Account__pc) || c.LastName != Trigger.oldMap.get(a.Id).LastName || c.Has_Registered_Synced_Events__c != Trigger.oldMap.get(a.Id).Has_Registered_Synced_Events__pc) {
                        if(c.LMS_Id__c == null) {
                            create.add(true);
                        }
                        else {
                            create.add(false);
                        }
                        toUpsert.add(c.Id);
                    }	
                }
            }
        }
        if(toUpsert.size() > 0) {
            UpsertUserQueueableWrapper uqw = new UpsertUserQueueableWrapper(toUpsert, create);
            System.EnqueueJob(uqw);
        }
    }  
}