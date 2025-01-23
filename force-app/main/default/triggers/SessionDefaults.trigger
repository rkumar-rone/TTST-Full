trigger SessionDefaults on Session__c (before insert) {
	String[] eventIds = new String[0];
	Map<Id, Id> campToInstruct = new Map<Id, Id>();
	for(Session__c s : Trigger.new) {
		eventIds.add(s.Event__c);
	}
	for(Campaign[] camps : [Select Id, Instructor__c from Campaign where Id in :eventIds]) {
		for(Campaign camp : camps) {
			campToInstruct.put(camp.Id, camp.Instructor__c);
		}
	}
	for(Session__c s : Trigger.new) {
		s.Instructor__c = campToInstruct.get(s.Event__c);
	}
}