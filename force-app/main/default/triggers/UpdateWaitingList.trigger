trigger UpdateWaitingList on Registration__c (after update, after delete) {
	String[] sessionIds = new String[0];
	Map<Id, Integer> sessTotal = new Map<Id, Integer>();
	if(Trigger.isUpdate) {
		for(Registration__c r : Trigger.new) {
			if(r.Status__c == 'Cancelled' && Trigger.oldMap.get(r.Id).Status__c != 'Cancelled') {
				sessionIds.add(r.Session__c);
				if(Trigger.oldMap.get(r.Id).Status__c == 'Registered') {
					if(sessTotal.containsKey(r.Session__c))
						sessTotal.put(r.Session__c, sessTotal.get(r.Session__c) + 1);
					else	
						sessTotal.put(r.Session__c, 1);
				}
			}
		}
	}
	if(sessionIds.size() > 0) {
		String[] eventsList = new String[0];
		String[] contactsList = new String[0];
		Map<Id, Set<Id>> contactEvents = new Map<Id, Set<Id>>();
		for(Session__c[] sesses : [Select Event__c, Event__r.Disable_Wait_List__c, Id, Seats_Available__c, Seats_Remaining__c, (Select Contact__c, Id, Waiting_List_Ranking__c, Waiting_List__c, Status__c from Session_Members__r order by Waiting_List_Ranking__c)  from Session__c where Id in :sessionIds]) {
			for(Session__c sess : sesses) {
				Integer size = 0;
				//for(Registration__c[] regs : sess.Session_Members__r) {
					//size += regs.size();
				//}
				System.Debug(sess.Seats_Remaining__c);
				//System.Debug(sess.Session_Members__r.size());
				System.Debug(sess.Event__r.Disable_Wait_List__c);
				Integer seats = sess.Seats_Remaining__c.intValue() + (sessTotal.containsKey(sess.Id) ? sessTotal.get(sess.Id) : 0);
				if(DateTime.now() <= sess.Event__r.Disable_Wait_List__c) { //seats > 0 && sess.Session_Members__r.size() > 0 &&
					Integer rank = 1;
					for(Registration__c[] regs : sess.Session_Members__r) {
						for(Registration__c r : sess.Session_Members__r) {
							if(seats > 0 && r.Status__c == 'Waiting List') {
								System.Debug(r.Contact__c);
								System.Debug(sess.Event__c);
								contactsList.add(r.Contact__c);
								eventsList.add(sess.Event__c);
								if(!contactEvents.containsKey(r.Contact__c))
									contactEvents.put(r.Contact__c, new Set<Id>());
								contactEvents.get(r.Contact__c).add(sess.Event__c);
								r.Waiting_List__c = false;
								r.Status__c = 'Registered';
								r.Waiting_List_Ranking__c = null;
								seats--;
							}
							else if(r.Status__c == 'Waiting List'){
								r.Waiting_List_Ranking__c = rank;
								rank++;
							}	
							else {
								r.Waiting_List__c = false;
								r.Waiting_List_Ranking__c = null;
							}
						}
					} 		
					for(Registration__c[] regs : sess.Session_Members__r) {
						update regs;
					}		
				}
			}
		}
		Map<Id, Map<Id, String>> waiting = new Map<Id, Map<Id, String>>();
		for(Id contId : contactEvents.keySet()) {
			if(!waiting.containsKey(contId))
				waiting.put(contId, new Map<Id, String>());
			for(Id event : contactEvents.get(contId)) {
				if(!waiting.get(contId).containsKey(event))
					waiting.get(contId).put(event, 'Registered');
			}
		}
		System.Debug(contactsList);
		System.Debug(contactsList.size());
		System.Debug(eventsList);
		for(Registration__c[] rs : [Select Id, Status__c, Contact__c, Session__r.Event__c from Registration__c where Contact__c in :contactsList and Session__r.Event__c in :eventsList]) {
			for(Registration__c r : rs) {
				if(contactEvents.get(r.Contact__c).contains(r.Session__R.Event__c))
					if(r.Status__c == 'Waiting List')
						waiting.get(r.Contact__c).put(r.Session__r.Event__c, 'Waiting List');
			}
		}
		CampaignMember[] toUp = new CampaignMember[0];
		for(CampaignMember[] cms : [Select Id, CampaignId, ContactId from CampaignMember where CampaignId in :eventsList and ContactId in :contactsList]) {
			for(CampaignMember cm : cms) {
				if(waiting.get(cm.ContactId).containsKey(cm.CampaignId))
					cm.Attendee_Status__c = waiting.get(cm.ContactId).get(cm.CampaignId);
				toUp.add(cm);	
			}
		}
		if(toUp.size() > 0)
			update toUp;
	
	}
}