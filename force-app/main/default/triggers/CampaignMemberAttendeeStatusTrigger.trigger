trigger CampaignMemberAttendeeStatusTrigger on CampaignMember (after insert, after update) {
	Campaign_Member_History__c[] toInsert = new Campaign_Member_History__c[0]; 
	String[] campaignClauses = new String[0];
	Map<Id, Map<Id, String>> statusMap = new Map<Id, Map<Id, String>>();
	Id[] toDeleteGroupMembers = new Id[0];
	Id[] parentEvents = new Id[0];
    for(CampaignMember cm : Trigger.new) {
    	if(Trigger.isInsert || cm.Attendee_Status__c != Trigger.oldMap.get(cm.Id).Attendee_Status__c) {
    		toInsert.add(new Campaign_Member_History__c(Campaign_Member_Id__c = cm.Id, Field__c = 'Attendee_Status__c', New_Value__c = cm.Attendee_Status__c, Old_Value__c = ((Trigger.isInsert) ? null : Trigger.oldMap.get(cm.Id).Attendee_Status__c)));
			if(Trigger.isUpdate && (cm.Attendee_Status__c == 'Registered' || Trigger.oldMap.get(cm.Id).Attendee_Status__c == 'Registered')) {
				parentEvents.adD(cm.CampaignId);
				campaignClauses.add('( Child_Event_Group__r.Parent__c = \'' + cm.CampaignId + '\' and Contact__c = \'' + cm.ContactId + '\' )');
				if(!statusMap.containsKey(cm.ContactId)) {
					statusMap.put(cm.ContactId, new Map<Id, String>());
				}
				statusMap.get(cm.ContactId).put(cm.CampaignId, cm.Attendee_Status__c);
			}
    	}
	}
	if(campaignClauses.size() > 0) {
		String[] childClauses = new String[0];
		String[] statusUpdateClauses = new String[0];
		Map<Id, Map<Id, String>> parentStatus = new Map<Id, Map<Id, String>>();
		Map<Id, Map<Id, Id>> earliestEvent = new Map<Id, Map<Id, Id>>();
		Map<Id, Map<Id, Id>> latestEvent = new Map<Id, Map<Id, Id>>();
		Map<Id, Map<Id, DateTime>> earliestEventDate = new Map<Id, Map<Id, DateTime>>();
		Map<Id, Map<Id, DateTime>> latestEventDate = new Map<Id, Map<Id, DateTime>>();

		Id[] impactedChildren = new Id[0];
		for(Event_Relationship__c er : [Select Id, Child__c, Parent__c from Event_Relationship__c where Parent__c in :parentEvents]) {
			for(Id i : statusMap.keySet()) {
				if(statusMap.get(i).containsKey(er.Parent__c)) {
					statusUpdateClauses.add('( CampaignId = \'' + er.Child__c + '\' and ContactId = \'' + i + '\' )');
					if(!parentStatus.containsKey(i)) {
						parentStatus.put(i, new Map<Id, String>());
					}
					parentStatus.get(i).put(er.Child__c, statusMap.get(i).get(er.Parent__c));
				}
			}
			impactedChildren.add(er.Child__c);
		}
		Map<Id, Event_Relationship__c[]> childParentMap = new Map<Id, Event_Relationship__c[]>();
		Id[] allParents = new Id[0];
		for(Event_Relationship__c er : [Select Id, Date_RC_Access_Ends_DateTime_Formula__c, Date_RC_Access_Starts_DateTime_Formula__c, Child__c, Parent__c from Event_Relationship__c where Child__c in :impactedChildren]) {
			if(!childParentMap.containsKey(er.Child__c)) {
				childParentMap.put(er.Child__c, new Event_Relationship__c[0]);
			}
			childParentMap.get(er.Child__c).add(er);
			allParents.add(er.Parent__c);
		}
		Map<Id, Map<Id, CampaignMember>> campaignMemberMap = new Map<Id, Map<Id, CampaignMember>>();
		for(CampaignMember cm : [Select Id, CampaignId, ContactId, Attendee_Status__c from CampaignMember where ContactId in :statusMap.keySet() and CampaignId in :allParents]) {
			if(!campaignMemberMap.containsKey(cm.ContactId)) {
				campaignMemberMap.put(cm.ContactId, new Map<Id, CampaignMember>());
			}
			campaignMemberMap.get(cm.ContactId).put(cm.CampaignId, cm);
		}
		for(Group_Member__c gm : Database.query('Select Id, Contact__c, Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c, Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c, Child_Event_Group__r.Parent__c, Child_Event_Group__r.Child__c from Group_Member__c where ' + String.join(campaignClauses, ' or '))) {
			if(statusMap.containsKey(gm.Contact__c) && statusMap.get(gm.Contact__c).containsKey(gm.Child_Event_Group__r.Parent__c) && statusMap.get(gm.Contact__c).get(gm.Child_Event_Group__r.Parent__c) !='Registered') {
				toDeleteGroupMembers.add(gm.Id);
			}
		}
		/*
			childClauses.add('( Child_Event_Group__r.Child__c = \'' + gm.Child_Event_Group__r.Child__c + '\' and Contact__c = \'' + gm.Contact__c + '\' )');
			statusUpdateClauses.add('( CampaignId = \'' + gm.Child_Event_Group__r.Child__c + '\' and ContactId = \'' + gm.Contact__c + '\' )');
			if(!parentStatus.containsKey(gm.Contact__c)) {
				parentStatus.put(gm.Contact__c, new Map<Id, String>());
			}
			parentStatus.get(gm.Contact__c).put(gm.Child_Event_Group__r.Child__c, statusMap.get(gm.Contact__c).get(gm.Child_Event_Group__r.Parent__c));
			if(statusMap.get(gm.Contact__c).get(gm.Child_Event_Group__r.Parent__c) == 'Registered') {
				if(!earliestEvent.containsKey(gm.Contact__c)) {
					earliestEvent.put(gm.Contact__c, new Map<Id, Id>());
					latestEvent.put(gm.Contact__c, new Map<Id, Id>());
					earliestEventDate.put(gm.Contact__c, new Map<Id, DateTime>());
					latestEventDate.put(gm.Contact__c, new Map<Id, DateTime>());
				}
				if(gm.Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c != null && (!latestEventDate.get(gm.Contact__c).containsKey(gm.Child_Event_Group__r.Child__c)  || latestEventDate.get(gm.Contact__c).get(gm.Child_Event_Group__r.Child__c) < gm.Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c)) {
					latestEventDate.get(gm.Contact__c).put(gm.Child_Event_Group__r.Child__c, gm.Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c);
					latestEvent.get(gm.Contact__c).put(gm.Child_Event_Group__r.Child__c, gm.Child_Event_Group__r.Parent__c);
				}
				if(gm.Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c != null && (!earliestEventDate.get(gm.Contact__c).containsKey(gm.Child_Event_Group__r.Child__c)  || earliestEventDate.get(gm.Contact__c).get(gm.Child_Event_Group__r.Child__c) > gm.Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c)) {
					earliestEventDate.get(gm.Contact__c).put(gm.Child_Event_Group__r.Child__c, gm.Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c);
					earliestEvent.get(gm.Contact__c).put(gm.Child_Event_Group__r.Child__c, gm.Child_Event_Group__r.Parent__c);
				}
			}
			
		}
		if(childClauses.size() > 0) {
			String[] cmParentClauses = new String[0];
			Map<Id, Map<Id, Set<Id>>> parentList = new Map<Id, Map<Id, Set<Id>>>();
			Map<Id, Map<Id, Map<Id, Group_Member__c>>> gmList = new Map<Id, Map<Id, Map<Id, Group_Member__c>>>();
			for(Group_Member__c gm : Database.query('Select Id, Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c, Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c, Contact__c, Child_Event_Group__r.Parent__c, Child_Event_Group__r.Child__c from Group_Member__c where ' + String.join(childClauses, ' or '))) {
				if(parentStatus.containsKey(gm.Contact__c) && parentStatus.get(gm.Contact__c).containsKey(gm.Child_Event_Group__r.Child__c)) { 
					cmParentClauses.add('( CampaignId = \'' + gm.Child_Event_Group__r.parent__c + '\' and ContactId = \'' + gm.Contact__c + '\' ) ');
					if(!parentList.containsKey(gm.Contact__c)) {
						parentList.put(gm.Contact__c, new Map<Id, Set<Id>>());
						gmList.put(gm.Contact__c, new Map<Id, Map<Id, Group_Member__c>>());
					}
					if(!parentList.get(gm.Contact__c).containsKey(gm.Child_Event_Group__r.Parent__c)) {
						parentList.get(gm.Contact__c).put(gm.Child_Event_Group__r.Parent__c, new Set<Id>());
						gmList.get(gm.Contact__c).put(gm.Child_Event_Group__r.Parent__c, new Map<Id, Group_Member__c>());
					}
					parentList.get(gm.Contact__c).get(gm.Child_Event_Group__r.Parent__c).add(gm.Child_Event_Group__r.Child__c);
					gmList.get(gm.Contact__c).get(gm.Child_Event_Group__r.Parent__c).put(gm.Child_Event_Group__r.Child__c, gm);
				}
			}

			if(cmParentClauses.size() > 0) {
				for(CampaignMember cm : Database.query('Select Id, ContactId, CampaignId, Attendee_Status__c from CampaignMember where ' + String.join(cmParentClauses, ' or '))) {
					if(cm.Attendee_Status__c == 'Registered' && parentStatus.containsKey(cm.ContactId) && parentList.containsKey(cm.ContactId) && parentList.get(cm.ContactId).containsKey(cm.CampaignId)) {
						for(Id i : parentList.get(cm.ContactId).get(cm.CampaignId)) {
							if(parentStatus.get(cm.ContactId).containsKey(i)) {
								parentStatus.get(cm.ContactId).put(i, 'Registered');
							}
							if(!earliestEvent.containsKey(cm.ContactId)) {
								earliestEvent.put(cm.ContactId, new Map<Id, Id>());
								latestEvent.put(cm.ContactId, new Map<Id, Id>());
								earliestEventDate.put(cm.ContactId, new Map<Id, DateTime>());
								latestEventDate.put(cm.ContactId, new Map<Id, DateTime>());
							}
							if(gmList.containsKey(cm.ContactId) && gmList.get(cm.ContactId).containsKey(cm.CampaignId) && gmList.get(cm.ContactId).get(cm.CampaignId).containsKey(i) && gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c != null && (!earliestEventDate.get(cm.ContactId).containsKey(i) || earliestEventDate.get(cm.ContactId).get(i) > gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c)) {
								earliestEventDate.get(cm.ContactId).put(i, gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__r.Date_RC_Access_Starts_DateTime_Formula__c);
								earliestEvent.get(cm.ContactId).put(i, gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__c);
							}
							if(gmList.containsKey(cm.ContactId) && gmList.get(cm.ContactId).containsKey(cm.CampaignId) && gmList.get(cm.ContactId).get(cm.CampaignId).containsKey(i) && gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c != null && (!latestEventDate.get(cm.ContactId).containsKey(i) || latestEventDate.get(cm.ContactId).get(i) < gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c)) {
								latestEventDate.get(cm.ContactId).put(i, gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__r.Date_RC_Access_Ends_DateTime_Formula__c);
								latestEvent.get(cm.ContactId).put(i, gmList.get(cm.ContactId).get(cm.CampaignId).get(i).Child_Event_Group__c);
							}
						}
					}
				}
			}
		}*/
		String[] toDeleteClauses = new String[0];
		if(statusUpdateClauses.size() > 0) {
			//System.Debug(parentStatus);
			for(CampaignMember[] cms : Database.query('Select Id, Attendee_Status__c, ContactId, CampaignId from CampaignMember where' + String.join(statusUpdateClauses, ' or '))) {
				for(CampaignMember cm : cms) {
					DateTime earliestTime = null;
					Id earliest = null;
					Id latest = null;
					DateTime latestTIme = null;
					String status = 'Cancelled';
					if(childParentMap.containsKey(cm.CampaignId)) {
						for(Event_Relationship__c er : childParentMap.get(cm.CampaignId)) {
							if(campaignMemberMap.containsKey(cm.ContactId) && campaignMemberMap.get(cm.ContactId).containsKey(er.Parent__c)) {
								CampaignMember parentCampaign = campaignMemberMap.get(cm.ContactId).get(er.Parent__c);
								if(parentCampaign.Attendee_Status__c == 'Registered' || status != 'Registered') {
									status = parentCampaign.Attendee_Status__c;
								}
								if(parentCampaign.Attendee_Status__c == 'Registered') {
									if(earliest == null || earliestTime > er.Date_RC_Access_Starts_DateTime_Formula__c) {
										earliestTime = er.Date_RC_Access_Starts_DateTime_Formula__c; 
										earliest = er.Id;
									}
									if(latest == null || latestTime < er.Date_RC_Access_Ends_DateTime_Formula__c) {
										latestTime = er.Date_RC_Access_Ends_DateTime_Formula__c;
										latest = er.Id;
									}
								}
							}
						}
						cm.Attendee_Status__c = status;
						if(status == 'Registered') {
							cm.Additional_Enrollment_Trigger__c = true;
						}
						cm.Earliest_Event_Relationship__c = earliest;
						cm.Event_Relationship_Generated_From__c = latest;
					}
					/*
					if(parentStatus.containsKey(cm.ContactId) && parentStatus.get(cm.ContactId).containsKey(cm.CampaignId)) {
						cm.Attendee_Status__c = parentStatus.get(cm.ContactId).get(cm.CampaignId);
						if(cm.Attendee_Status__c == 'Registered' && earliestEvent.containsKey(cm.ContactId) && earliestEvent.get(cm.ContactId).containsKey(cm.CampaignId)) { 
							cm.Earliest_Event_Relationship__c = earliestEvent.get(cm.ContactId).get(cm.CampaignId);
						}
						else {
							cm.Earliest_Event_Relationship__c = null;
						}
						if(cm.Attendee_Status__c == 'Registered' && latestEvent.containsKey(cm.ContactId) && latestEvent.get(cm.ContactId).containsKey(cm.CampaignId)) { 
							cm.Event_Relationship_Generated_From__c = latestEvent.get(cm.ContactId).get(cm.CampaignId);
						}
						else {
							cm.Event_Relationship_Generated_From__c = null;
						}
					}*/
				}
				update cms;
			}
		}
	}
    if(toInsert.size() > 0)
    	insert toInsert;
	if(toDeleteGroupMembers.size() > 0) {
		Moodle.removeGroupMembers(toDeleteGroupMembers);
	}
}