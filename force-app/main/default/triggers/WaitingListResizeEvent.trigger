trigger WaitingListResizeEvent on Campaign (after update) {
	String[] eventIds = new String[0];
	Map<Id, Integer> eventTotal = new Map<Id, Integer>();
	for(Campaign c : Trigger.new) {
		if(c.Seats_Available__c != Trigger.oldMap.get(c.Id).Seats_Available__c) {
			eventIds.add(c.Id);
			eventTotal.put(c.Id, ((c.Seats_Available__c == null ? 0 : c.Seats_Available__c) - (Trigger.oldMap.get(c.Id).Seats_Available__c == null ? 0 : Trigger.oldMap.get(c.Id).Seats_Available__c)).intValue());
		}
	}
	if(eventIds.size() > 0) {
		String[] eventsList = new String[0];
		String[] contactsList = new String[0];
		Map<Id, Set<Id>> contactEvents = new Map<Id, Set<Id>>();



		List<Registration__c> regList = new List<Registration__c>();
		for(Session__c[] sesses : [Select Event__c, Event__r.Disable_Wait_List__c, Id, Seats_Available__c, Seats_Remaining__c, (Select Contact__c, Id, Waiting_List_Ranking__c, Waiting_List__c, Status__c from Session_Members__r where Status__c = 'Waiting List' order by Waiting_List_Ranking__c)  from Session__c where Event__c in :eventIds]) {
			for(Session__c sess : sesses) {
				System.Debug(sess.Seats_Remaining__c);
				System.Debug(sess.Session_Members__r.size());
				System.Debug(sess.Event__r.Disable_Wait_List__c);
				Integer seats = (eventTotal.containsKey(sess.Event__c) ? eventTotal.get(sess.Event__c) : 0);
				if(seats > 0 && sess.Session_Members__r.size() > 0 && DateTime.now() <= sess.Event__r.Disable_Wait_List__c) {
					Integer rank = 1;
					for(Registration__c r : sess.Session_Members__r) {
						if(seats > 0) {
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
						else {
							r.Waiting_List_Ranking__c = rank;
							rank++;
						}	
					} 		
					regList.addAll(sess.Session_Members__r);		
				}
			}
		}
		update regList;
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