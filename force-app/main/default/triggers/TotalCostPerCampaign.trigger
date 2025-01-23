trigger TotalCostPerCampaign on Registration__c (after insert,after update, after delete) {
    //String[] contactEventKeys = new String[0];
    Id[] contactIds = new Id[0];
    String[] eventIds = new String[0];
    Id[] registrationIds = new Id[0];
    Map<Id, Registration__c> regMap = new Map<Id, Registration__c>();
    if(Trigger.isInsert || Trigger.isUpdate) {
    	for(Registration__c r : Trigger.new) {
    		if(Trigger.isInsert || r.status__c != Trigger.oldMap.get(r.Id).Status__c) {
    			//contactEventKeys.add(r.Contact_Event_Code__c);
    			contactIds.add(r.Contact__c);
    			eventIds.adD(r.Event_Id__c);
    		}
	    }
    }
    else {
    	for(Registration__c r : Trigger.old) {
    		//contactEventKeys.add(r.Contact_Event_Code__c);
    		contactIds.add(r.Contact__c);
    		eventIds.add(r.Event_Id__c);
    	}
    }
    //if(contactEventKeys.size() > 0) {
    if(contactIds.size() > 0) {
    	//Map<String, Integer> registeredEvents = new Map<String, Integer>();
    	Map<Id, Map<Id, Integer>> registeredEvents = new Map<Id, Map<Id, Integer>>();
    	//for(Registration__c[] regs : [Select Id, Contact_Event_Code__c from Registration__c where Contact_Event_Code__c in :contactEventKeys and Status__c = 'Registered']) {
    	for(Registration__c[] regs : [Select Id, Event_Id__c, Contact__c, Contact_Event_Code__c from Registration__c where Contact__c in :contactIds and Event_Id__c in :eventIds and Status__c = 'Registered']) {	
	    	for(Registration__c reg : regs) {
	    		if(!registeredEvents.containsKey(reg.Event_Id__c)) {
	    			registeredEvents.put(reg.Event_Id__c, new Map<Id, Integer>());
	    		}
	    		if(!registeredEvents.get(reg.Event_Id__c).containsKey(reg.Contact__c)) {
	    			registeredEvents.get(reg.Event_Id__c).put(reg.Contact__c, 0);
	    		}
    			//if(!registeredEvents.containsKey(reg.Contact_Event_Code__c))
	    			//registeredEvents.put(reg.Contact_Event_Code__c, 0);
    			//registeredEvents.put(reg.Contact_Event_Code__c, registeredEvents.get(reg.Contact_Event_Code__c) + 1);
    			registeredEvents.get(reg.Event_Id__c).put(reg.Contact__c, registeredEvents.get(reg.Event_Id__c).get(reg.Contact__c) + 1);
    		}
    	}
    
    //	Contact_Event_Code__c in :contactEventKeys
    	for(CampaignMember[] cms : [Select Id, ContactId, CampaignId from CampaignMember where ContactId in :contactIds and CampaignId in :eventIds]) {
	    	for(CampaignMember cm : cms) {
    			if(registeredEvents.containsKey(cm.CampaignId) && registeredEvents.get(cm.CampaignId).containsKey(cm.ContactId))  //Contact_Event_Code__c))
	    			cm.Sessions_Registered__c = registeredEvents.get(cm.CampaignId).get(cm.ContactId);
    			else
    				cm.Sessions_Registered__c = 0;
    		}
    		update cms;
    	}
    }
    /*Set<string> c_evt_id = new Set<string>();
    List<CampaignMember> cmem = new List<CampaignMember>();
    List<Registration__c> regs = new List<Registration__c>();
    Map<string,decimal> tcost = new Map<string,decimal>();
    Map<string,Integer> n_evt_reg = new Map<string,Integer>();
    if(Trigger.isUpdate||Trigger.isInsert)
        for(Registration__c reg:Trigger.new)
            c_evt_id.add(reg.Contact_Event_Code__c);
    else
        for(Registration__c reg:Trigger.old)
            c_evt_id.add(reg.Contact_Event_Code__c);
        
    cmem = [SELECT ID,Contact_Event_Code__c,Sessions_Registered__c FROM CampaignMember where Contact_Event_Code__c in:c_evt_id];
    regs = [SELECT ID,Contact_Event_Code__c FROM Registration__c WHERE Contact_Event_Code__c in:c_evt_id];
    
    
    for(Registration__c reg:regs)
    {
        //if(tcost.containskey(reg.Contact_Event_Code__c))
            //tcost.put(reg.Contact_Event_Code__c,tcost.get(reg.Contact_Event_Code__c)+reg.Final_Cost__c);
        //else tcost.put(reg.Contact_Event_Code__c,reg.Final_Cost__c);
        
        //tcost.put(reg.Contact_Event_Code__c,1.0);
        
        if(n_evt_reg.containskey(reg.Contact_Event_Code__c))
            n_evt_reg.put(reg.Contact_Event_Code__c,n_evt_reg.get(reg.Contact_Event_Code__c)+1);
        else n_evt_reg.put(reg.Contact_Event_code__c,1);
        
        
    }
    for(CampaignMember cm:cmem)
    {
        //if(tcost.containskey(cm.Contact_Event_code__c))
            
                //cm.Event_cost__c=tcost.get(cm.Contact_Event_Code__c);
            
        //else cm.Event_cost__c=0;
        
        if(n_evt_reg.containskey(cm.Contact_Event_code__c))
            
            cm.Sessions_Registered__c=n_evt_reg.get(cm.Contact_Event_Code__c);
            
        else cm.Sessions_Registered__c=0;
        
        
    }
    update cmem;*/

}