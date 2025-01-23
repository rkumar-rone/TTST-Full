trigger RCAccessEndDate on Campaign (after update) {
	Id[] campaignIds = new Id[0];
	for(Campaign c : Trigger.new) {
		if(c.Date_RC_Access_Ends__c != Trigger.oldMap.get(c.Id).Date_RC_Access_Ends__c || c.Date_RC_Access_Starts__c != Trigger.oldMap.get(c.Id).Date_RC_Access_Starts__c) {
			campaignIds.add(c.Id);
		}
	}
	if(campaignIds.size() > 0) {
		for(CampaignMember[] cms : [Select Id, Update_RC_Date__c from CampaignMember where CampaignId in :campaignIds]) {
			for(CampaignMember cm : cms) {
				cm.Update_RC_Date__c = !cm.Update_RC_Date__c;
			}
			update cms;
		}
	}
    
}