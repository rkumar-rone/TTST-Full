trigger UpsertMoodleCourseTrigger on Campaign (after delete, after insert, after update) {
	Decimal[] toDelete = new Decimal[0];
	String[] toDeleteNames = new String[0];
	String[] toDeleteCourses = new String[0];
	Id[] coursesToUpsert = new Id[0];
	Boolean[] create = new Boolean[0];
	Id[] accountsToInsert = new String[0];
	Id[] toCheckParticipants = new Id[0];
	
	
		if(Trigger.isInsert || Trigger.isUpdate) {
			for(Campaign c : Trigger.new) {
				if(c.Sync_to_LMS__c && c.LMS_Course_Name__c != null && c.LMS_Course_Name__c != '' && c.Account__c != null && c.Status != 'Cancelled' && Trigger.isUpdate && (Trigger.oldMap.get(c.Id).Account__c != c.Account__c || Trigger.oldMap.get(c.Id).Status != c.Status || Trigger.oldMap.get(c.Id).Sync_to_LMS__c != c.Sync_to_LMS__c || Trigger.oldMap.get(c.Id).LMS_Id__c != c.LMS_Id__c)) {
					toCheckParticipants.add(c.Id);
				}
			}
			if(toCheckParticipants.size() > 0) {
				Id[] contactIds = new Id[0];
				for(CampaignMember c : [Select Id, ContactId from CampaignMember where CampaignId in :toCheckParticipants]) {
					contactIds.add(c.ContactId);
				}
				Map<Id, Boolean> contactMap = new Map<Id, Boolean>();
				for(Id i : contactIds) {
					contactMap.put(i, false);
				}
				for(CampaignMember cm : [Select Id, ContactId from CampaignMember where Campaign.Account__c != null and Campaign.Sync_to_LMS__c = true and Attendee_Status__c = 'Registered' and Campaign.LMS_Id__c != null and ContactId in :contactMap.keySet()]) {
					contactMap.put(cm.ContactId, true);
				}
				Contact[] toUpdateContact = new Contact[0];
				for(Contact c : [Select Id, Has_Registered_Synced_Events__c from Contact where Id in :contactMap.keySet()]) {
					if(c.Has_Registered_Synced_Events__c != contactMap.get(c.Id)) {
						c.Has_Registered_Synced_Events__c = contactMap.get(c.Id);
						toUpdateContact.add(c);
					}
				}
				if(toUpdateContact.size() > 0) {
					update toUpdateContact;
				}
			}
			Campaign[] toUpsert = new Campaign[0];
			Id[] toUpdateGroups = new Id[0];
			Id[] accountIds = new Id[0];
			for(Campaign c : Trigger.new) {
				if(c.Sync_to_LMS__c && c.Account__c != null && c.Status != 'Cancelled') {
					if(Trigger.IsInsert || (c.LMS_Course_Name__c != Trigger.oldMap.get(c.Id).LMS_Course_Name__c) || (c.Registration_From__c  != Trigger.oldMap.get(c.Id).Registration_From__c ) || (c.Date_RC_Access_Ends__c != Trigger.oldMap.get(c.Id).Date_RC_Access_Ends__c) || (c.RT_Description__c != Trigger.oldMap.get(c.Id).RT_Description__c) || (c.Sync_To_LMS__c != Trigger.oldMap.get(c.Id).Sync_To_LMS__c) || (c.Account__c != Trigger.oldMap.get(c.Id).Account__c) || (c.Status != Trigger.oldMap.get(c.Id).Status) || (c.Visible_on_LMS__c != Trigger.oldMap.get(c.Id).Visible_on_LMS__c)) {
						accountIds.add(c.Account__c);
						toUpsert.add(c);
					}
				}
				else if((!c.Sync_to_LMS__c || c.Account__c == null || c.Status == 'Cancelled' || c.LMS_Course_Name__c == null || c.LMS_Course_Name__c == '') && c.LMS_Id__c != null) {
					if(Trigger.isInsert || c.LMS_Course_Name__c != Trigger.oldMap.get(c.Id).LMS_Course_Name__c || c.Sync_To_LMS__c != Trigger.oldMap.get(c.Id).Sync_To_LMS__c || c.Account__c != Trigger.oldMap.get(c.Id).Account__c || c.Status != Trigger.oldMap.get(c.Id).Status) {
						toDelete.add(c.LMS_Id__c);
						toDeleteNames.add(c.Name);
						toDeleteCourses.add(c.Id);
						if(Trigger.isUpdate && c.LMS_Course_Name__c != Trigger.oldMap.get(c.Id).LMS_Course_Name__c) {
							toupdateGroups.add(c.Id);
						}
					}
				}
			}
			if(accountIds.size() > 0) {
				Set<Id> categories = new Set<Id>();
				Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, LMS_Id__c from Account where Id in :accountIds]);
				for(Campaign c : toUpsert) {
					if(accountMap.get(c.Account__c).LMS_Id__c == null && !categories.contains(accountMap.get(c.Account__c).Id)) {
						categories.add(accountMap.get(c.Account__c).Id);
						accountsToInsert.add(accountMap.get(c.Account__c).Id);
					}
					coursesToUpsert.add(c.Id);
					if(c.LMS_Id__c == null) {
						create.add(true);
					}
					else {
						create.add(false);
					}
				}
				Moodle.UpsertCoursesAndInsertCampaigns(coursesToUpsert, accountsToInsert, create);
				if(toUpdateGroups.size() > 0) {
					Moodle.UpdateGroups(toUpdateGroups);
				}
			}
		}   
		else {
			for(Campaign c : Trigger.old) {
				if(c.LMS_Id__c != null) {
					toDelete.add(c.LMS_Id__c);
					toDeleteNames.add(c.Name);
					toDeleteCourses.add('');
				}
			}
		} 
		if(toDelete.size() > 0) {
			Moodle.DeleteCourses(toDelete, toDeleteNames, toDeleteCourses);
		}
}