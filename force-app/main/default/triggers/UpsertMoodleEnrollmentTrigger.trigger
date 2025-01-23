trigger UpsertMoodleEnrollmentTrigger on CampaignMember (after delete, after insert, after update, before update) {
	Id[] checkEnrollmentIds = new Id[0];
	Id[] sendEnrollmentIds = new Id[0];
	Decimal[] deleteCampLMSId = new Decimal[0];
	Decimal[] deleteContLMSId = new Decimal[0];
	String[] campName = new String[0];
	String[] contName = new String[0];
	Id[] updateContacts = new Id[0];
    Set<Id> campaignIds = new Set<Id>();
	
	if(Trigger.isBefore) {
		String[] groupMemberStrings = new String[0];
		Id[] eventIds = new Id[0];
		for(CampaignMember c : Trigger.new) {
			if((c.Status != 'Registered' && Trigger.oldMap.get(c.Id).Status == 'Registered') || Test.isRunningTest()) {
				groupMemberStrings.add(' (Child_Event_Group__r.Child__c = \'' + c.CampaignId + '\' and Contact__c = \'' + c.ContactId + '\' ) ');
				if(c.Event_Generated_From__c != null) {
					eventIds.add(c.Event_Generated_From__c);
				}
			}
		}
		Map<Id, Map<Id, DateTime>> rcStartDate = new Map<Id, Map<Id, DateTime>>();
		Map<Id, Map<Id, DateTime>>  rcEndDate = new Map<Id, Map<Id, DateTime>>();
		Map<Id, Map<Id, Id>>  er = new Map<Id, Map<Id, Id>>();
		Map<Id, Map<Id, Id>>  erEarly = new Map<Id, Map<Id, Id>>();
		if(groupMemberStrings.size() > 0) {
			for(Group_Member__c gm : Database.query('Select Id,Contact__c, Child_Event_Group__c, Child_Event_Group__r.Child__c, Child_Event_Group__r.Date_RC_Access_Starts__c, Child_Event_Group__r.Date_RC_Access_Ends_DateTime__c from Group_Member__c where ' + String.join(groupMemberStrings, ' or '))) {
				if(!rcStartDate.containsKey(gm.Child_Event_Group__r.Child__c)) {
					rcStartDate.put(gm.Child_Event_Group__r.Child__c, new Map<Id, DateTime>());
					rcEndDate.put(gm.Child_Event_Group__r.Child__c, new Map<Id, Date>());
					er.put(gm.Child_Event_Group__r.Child__c, new Map<Id, Id>());
					erEarly.put(gm.Child_Event_Group__r.Child__c, new Map<Id, Id>());
				}
				DateTime startD = gm.Child_Event_Group__r.Date_RC_Access_Starts__c;
				DateTime endD  = gm.Child_Event_Group__r.Date_RC_Access_Ends_DateTime__c;
				Id erMap = gm.Child_Event_Group__c;
				Id erEarlyMap = gm.Child_Event_Group__c;

				if(!rcStartDate.get(gm.Child_Event_Group__r.Child__c).containsKey(gm.Contact__c) ||  rcStartDate.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c) == null || (startD != null && rcStartDate.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c) < startD)) {
					startD = rcStartDate.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c);
					erEarlyMap = er.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c);
				}
				if(!rcEndDate.get(gm.Child_Event_Group__r.Child__c).containsKey(gm.Contact__c) ||  rcEndDate.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c) == null || (endD != null && rcEndDate.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c) > endD)) {
					endD = rcEndDate.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c);
					erMap = er.get(gm.Child_Event_Group__r.Child__c).get(gm.Contact__c);
				}
				rcStartDate.get(gm.Child_Event_Group__r.Child__c).put(gm.Contact__c, startD);
				rcEndDate.get(gm.Child_Event_Group__r.Child__c).put(gm.Contact__c, endd);
				er.get(gm.Child_Event_Group__r.Child__c).put(gm.Contact__c, erMap);
				erEarly.get(gm.Child_Event_Group__r.Child__c).put(gm.Contact__c, erEarlyMap);
			}
		}
		if(eventIds.size() > 0) {
			Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([Select Id, Date_RC_Access_Starts__c, Date_RC_Access_Ends__c from Campaign where Id in :eventIds]);
			for(CampaignMember c : Trigger.new) {
				if(c.Event_Generated_From__c != null) {
					if(!rcStartDate.containsKey(c.Event_Generated_From__c)) {
						rcStartDate.put(c.Event_Generated_From__c, new Map<Id, DateTime>());
						rcEndDate.put(c.Event_Generated_From__c, new Map<Id, DateTime>());
					}
					DateTime startD = campaignMap.get(c.CampaignId).Date_RC_Access_Starts__c;
					DateTime endD  = campaignMap.get(c.CampaignId).Date_RC_Access_Ends__c;
					Id erMap = null;
					Id erEarlyMap = null;

					if(!rcStartDate.get(c.CampaignId).containsKey(c.ContactId) ||  rcStartDate.get(c.CampaignId).get(c.ContactId) == null || (startD != null && rcStartDate.get(c.CampaignId).get(c.ContactId) < startD)) {
						startD = rcStartDate.get(c.CampaignId).get(c.ContactId);
						erEarlyMap = er.get(c.CampaignId).get(c.ContactId);
					}
					if(!rcEndDate.get(c.CampaignId).containsKey(c.ContactId) ||  rcEndDate.get(c.CampaignId).get(c.ContactId) == null || (endD != null && rcEndDate.get(c.CampaignId).get(c.ContactId) > endD)) {
						endD = rcEndDate.get(c.CampaignId).get(c.ContactId);
						erMap = er.get(c.CampaignId).get(c.ContactId);
					}
					rcStartDate.get(c.CampaignId).put(c.ContactId, startD);
					rcEndDate.get(c.CampaignId).put(c.ContactId, endD);
					er.get(c.CampaignId).put(c.ContactId, erMap);
					erEarly.get(c.CampaignId).put(c.ContactId, erEarlyMap);
				}
			}
		}
		for(CampaignMember c : Trigger.new) {
			if(c.Status != 'Registered' && Trigger.oldMap.get(c.Id).Status == 'Registered' && rcStartDate.containsKey(c.CampaignId) && rcStartDate.get(c.CampaignId).containsKey(c.ContactId)) {
				c.Status = 'Registered';
				c.Event_Generated_From__c = er.get(c.CampaignId).get(c.ContactId);
				c.Earliest_Event_Relationship__c = erEarly.get(c.CampaignId).get(c.ContactId);
			}
		}
	}
	else {

    	if(Trigger.isInsert) {
	    	for(CampaignMember c : Trigger.new) {
    			if(c.Attendee_Status__c == 'Registered') {
	    			checkEnrollmentIds.add(c.Id);
    				updateContacts.add(c.ContactId);
                    campaignIds.add(c.CampaignId);
    			}
    		}
            for(CampaignMember c : [SELECT Id FROM CampaignMember where 
                                    CampaignId IN :campaignIds AND
                                    Campaign.LMS_Id__c != null AND 
                                    Contact.LMS_Id__c != null AND 
                                    Campaign.Sync_To_LMS__c = true AND 
                                    Campaign.Account__c != null AND 
                                    Attendee_Status__c = 'Registered' AND 
                                    Id in :checkEnrollmentIds]) {
                                        sendEnrollmentIds.add(c.Id);
                                    }
    	}	
    	else if(Trigger.isUpdate) {
	    	Id[] delEnrollIds = new Id[0];
    		for(CampaignMember c : Trigger.new) {
	    		if(c.Attendee_Status__c == 'Registered' && c.Attendee_Status__c != Trigger.oldMap.get(c.Id).Attendee_Status__c) {
    				checkEnrollmentIds.add(c.Id);
    				updateContacts.add(c.ContactId);	
    			}
    			else if(c.Attendee_Status__c != 'Registered' && Trigger.oldMap.get(c.Id).Attendee_Status__c == 'Registered') {
	    			checkEnrollmentIds.add(c.Id);
    				updateContacts.add(c.ContactId);	
    			}
    			else if(c.Attendee_Status__c == 'Registered' && (c.Date_RC_Access_Starts_Formula__c != Trigger.oldMAp.get(c.Id).Date_RC_Access_Starts_Formula__c || c.Date_RC_Access_Ends_Formula__c != Trigger.oldMap.get(c.Id).Date_RC_Access_Ends_Formula__c || c.Update_RC_Date__c != Trigger.oldMap.get(c.Id).Update_RC_Date__c)) {
	    			checkEnrollmentIds.add(c.Id);
    				updateContacts.add(c.ContactId);	
    			}
				else if(c.Additional_Enrollment_Trigger__c) {
					checkEnrollmentIds.add(c.Id);
    				updateContacts.add(c.ContactId);
				}
    		}
    		if(checkEnrollmentIds.size() > 0) {
	    		for(CampaignMember c : [Select Id from CampaignMember where Campaign.LMS_Id__c != null and Contact.LMS_Id__c != null and Campaign.Sync_To_LMS__c = true and Campaign.Account__c != null and Id in :checkEnrollmentIds]) {
	    			sendEnrollmentIds.add(c.Id);
    			}
    		}
    	}
    	else if(Trigger.isDelete){
	    	Id[] campIds = new Id[0];
    		Id[] contIds = new Id[0];
    		for(CampaignMember c: Trigger.old) {
	    		campIds.add(c.CampaignId);
    			contIds.add(c.ContactId);
    			updateContacts.add(c.ContactId);
    		}
    		Map<Id, Campaign> campMap = new Map<Id, Campaign>([Select Id, LMS_Id__c, Name from Campaign where LMS_Id__c != null and Id in :campIds]);
    		Map<Id, Contact> contMap = new Map<Id, Contact>([Select Id, LMS_Id__c, FirstName, LastName from Contact where LMS_Id__c != null and Id in :contIds]);
    		for(CampaignMember c: Trigger.old) {
	    		if(campMap.containsKey(c.CampaignId) && contMap.containsKey(c.ContactId)) {
    				deleteCampLMSId.add(campMap.get(c.CampaignId).LMS_Id__c);
    				deleteContLMSId.add(contMap.get(c.ContactId).LMS_Id__c);
    				campName.add(campMap.get(c.CampaignId).Name);
    				contName.add((contMap.get(c.ContactId).FirstName == null ? '' : (contMap.get(c.ContactId).FirstName + ' ')) + contMap.get(c.ContactId).LastName);
    			}
    		}
    	}
    	if(updateContacts.size() > 0) {
	    	Map<Id, Boolean> contactMap = new Map<Id, Boolean>();
			for(Id i : updateContacts) {
				contactMap.put(i, false);
			}
			System.Debug(updateContacts);
			for(CampaignMember cm : [Select Id, ContactId from CampaignMember where Campaign.Account__c != null and Campaign.Sync_to_LMS__c = true and Attendee_Status__c = 'Registered' and ContactId in :contactMap.keySet() and Campaign.LMS_Id__c != null]) {
				contactMap.put(cm.ContactId, true);
			}
			Contact[] toUpdateContact = new Contact[0];
			for(Contact c : [Select Id, Has_Registered_Synced_Events__c from Contact where Id in :contactMap.keySet()]) {
				if(c.Has_Registered_Synced_Events__c != contactMap.get(c.Id)) {
					c.Has_Registered_Synced_Events__c = contactMap.get(c.Id);
					toUpdateContact.add(c);
				}
			}
			if(toUpdateContact.size() > 0) 
				update toUpdateContact;
	    }
	    if(sendEnrollmentIds.size() > 0) {
			if(!system.isBatch()) {
    			Moodle.UpsertEnrollment(sendEnrollmentIds);
			}
    	}
    	if(deleteCampLMSId.size() > 0) {
			if(!system.isBatch()) {
	    		Moodle.DeleteEnrollment(deleteCampLMSId, deleteContLMSId, campName, contName);
			}
    	}	
	}
}