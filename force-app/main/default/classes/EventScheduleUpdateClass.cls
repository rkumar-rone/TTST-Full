public with sharing class EventScheduleUpdateClass {
    
	
	public static void updateField (set<ID> setOfID){
		 Map<Id,Event_Schedule__c> toUpdate = new Map<Id,Event_Schedule__c>();
		 set<id> setofeventId = new set<id>();
		Map<ID ,Campaign> idVsCampaign = new Map<ID ,Campaign>([SELECT ID,Event_Schedule__c,Event_Schedule__r.Self_study_Order_s_Delivered__c,SS_Order_Delivery_E_book_Live__c FROM Campaign WHERE ID = :setOfID]);
		
		
		Date dt;
		for(Campaign cam : idVsCampaign.values()){
			//dt = cam.SS_Order_Delivery_E_book_Live__c.date();
			if (cam.Event_Schedule__c != null) cam.Event_Schedule__r.Self_study_Order_s_Delivered__c = cam.SS_Order_Delivery_E_book_Live__c;
			toUpdate.put(cam.Event_Schedule__c , cam.Event_Schedule__r);
		}
		
			
			if (!toUpdate.isEmpty())
			 update(toUpdate.values());
		
	}         

/*	public static void updateField (set<Id> setOfID){
		try{
		  Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Campaign.fields.getMap();
		  	string camField ='';
		  	for(string str : fldObjMap.keyset()){
		  		camField += str+',';
		  		
		  	}
		
		camField = camField.substring(0 , camField.length()-1);
		list<Campaign> camObj = Database.query('SELECT '+ camField+ 'FROM Campaign WHERE ID IN : setOfID');
		System.debug('camObj'+camObj);
		
		 Map<String, Schema.SObjectField> fldObjMapevent = schema.SObjectType.Event_Schedule__c.fields.getMap();
		 string eventField ='';
	  	for(string str : fldObjMapevent.keyset()){
	  		eventField += str+',';
	  		
	  	}
	  	set<id> setOfEventId = new set<Id>();
	  	eventField = eventField.substring(0 , camField.length()-1);
	  	for(Campaign c : camObj){
	  		setOfEventId.add(c.Event_Schedule__c);
	  		
	  	}
		list<Event_Schedule__c> EventObj = Database.query('SELECT '+ eventField+ 'FROM Campaign WHERE ID IN: \'' +setOfEventId+'\'');
		System.debug('eventField'+eventField);
		for(Event_Schedule__c e : EventObj){
	//		EventObj.Self_study_Order_s_Delivered__c = camObj.SS_Order_Delivery_E_book_Live__c.date();
		}
		
		
		update EventObj;
		}
		catch(Exception e){
		//return e.getMessage();
		}
		 
	}         */
}