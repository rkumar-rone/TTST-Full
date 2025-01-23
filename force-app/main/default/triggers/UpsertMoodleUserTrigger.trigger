trigger UpsertMoodleUserTrigger on Contact (after insert, after update, after delete) {
	Id[] toUpsert = new Id[0];
	Boolean[] create = new Boolean[0];
	String[] deleteIds = new String[0];
	Decimal[] deleteLMSIds = new Decimal[0];
	String[] deleteNames = new String[0];
	
	if(Trigger.isInsert || Trigger.isUpdate) {
    	for(Contact c : Trigger.new) {
	    	if(c.User_Id__c != null && c.User_Id__c != '' && c.Email != null && c.Email != '' && c.Has_Registered_Synced_Events__c) {
    			if(Trigger.isInsert || c.Email != Trigger.oldMap.get(c.Id).Email || c.User_Id__c != Trigger.oldMap.get(c.Id).User_Id__c || c.FirstName != Trigger.oldMap.get(c.Id).FirstName || (c.Suspend_LMS_Account__c != Trigger.oldMap.get(c.Id).Suspend_LMS_Account__c) || c.LastName != Trigger.oldMap.get(c.Id).LastName || c.Has_Registered_Synced_Events__c != Trigger.oldMap.get(c.Id).Has_Registered_Synced_Events__c) {
	    			if(c.LMS_Id__c == null) {
    					create.add(true);
    				}
	    			else {
    					create.add(false);
    				}
	    			toUpsert.add(c.Id);
    			}	
    		}
    		else if (Trigger.isUpdate && ((c.User_Id__c != Trigger.oldMap.get(c.Id).User_Id__c && (c.User_Id__C == null || c.User_Id__C == '')) || ((c.Email == null || c.Email == '')  && Trigger.oldMap.get(c.Id).Email != c.Email) || ((!c.Has_Registered_Synced_Events__c) && Trigger.oldMap.get(c.Id).Has_Registered_Synced_Events__c != c.Has_Registered_Synced_Events__c))) {
	    		if(c.LMS_Id__c != null) {
    				deleteIds.add(c.Id);
    				deleteLMSIds.add(c.LMS_Id__c);
    				deleteNames.add((c.FirstName == null ? '' : (c.FirstName + ' ')) + c.LastName);
    			}
    		}
	    }
	    if(toUpsert.size() > 0) {
			UpsertUserQueueableWrapper uqw = new UpsertUserQueueableWrapper(toUpsert, create);
			System.EnqueueJob(uqw);
	    }
	}
	else {
		for(Contact c : Trigger.old) {
			if(c.LMS_Id__c != null) {
   				deleteIds.add(c.Id);
   				deleteLMSIds.add(c.LMS_Id__c);
   				deleteNames.add((c.FirstName == null ? '' : (c.FirstName + ' ')) + c.LastName);
			}
		}
	}
	if(deleteIds.size() > 0) {
		//Moodle.DeleteUsers(deleteLMSIds, deleteIds, deleteNames);
	}
}