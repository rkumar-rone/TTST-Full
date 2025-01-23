trigger UpdateFirstDate on Session__c (after delete, after insert, after update) {
	String[] campaignList = new String[0];
	if(Trigger.isInsert || Trigger.isUpdate) {
		for(Session__c s : Trigger.new) {
			campaignList.add(s.Event__c);
		}
	}
	else {
		for(Session__c s : Trigger.old) {
			campaignList.add(s.Event__c);
		}
	}
	Boolean needsUpdate;
	for(Campaign[] camps : [Select Id, Course_Start_Date_Time__c, (Select Id, Session_Start__c from Event_Sessions__r order by Session_Start__c nulls last) from Campaign where Id in :campaignList]) {
		needsUpdate = false;
		for(Campaign camp : camps) {
			if(camp.Event_Sessions__r != null && camp.Event_Sessions__r.size() > 0) {
				if (camp.Course_Start_Date_Time__c != camp.Event_Sessions__r[0].Session_Start__c) {
					camp.Course_Start_Date_Time__c = camp.Event_Sessions__r[0].Session_Start__c;
					needsUpdate = true;
				}
			}
		}
		if (needsUpdate) {
			update camps;
		}
	}
}