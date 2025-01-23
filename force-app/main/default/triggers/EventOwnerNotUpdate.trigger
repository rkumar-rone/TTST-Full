trigger EventOwnerNotUpdate on Event_Schedule__c (before update)
{
	if (trigger.isUpdate)
	{
	   	if(!EventOwnweUpdateclass.bool)
	   	{ 
	    	list<Event_Schedule__c> updateListInsertionOrder = new list<Event_Schedule__c>();
	        for(Event_Schedule__c e : trigger.new )
	        {
		        if(trigger.newMap.get(e.id).ownerId != trigger.oldMap.get(e.id).ownerId && !e.Allow_Owner_Change__c)e.addError(' "You must update the Event "Instructor" in order to update the Schedule "Owner". Please update the "Instructor" field on the Event."');
		        if(trigger.newMap.get(e.id).ownerId != trigger.oldMap.get(e.id).ownerId && e.Allow_Owner_Change__c) e.Allow_Owner_Change__c = false;
	    	}
		}
	}
}