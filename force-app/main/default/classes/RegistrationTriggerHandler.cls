public with sharing class RegistrationTriggerHandler implements ITrigger{
    
    // Constructor
    public RegistrationTriggerHandler (){
        
    }
    

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore()
    {
       
    }
    
    
    public void bulkAfter()
    {
  
    }
    
    
    public void beforeInsert()
    {
        //IsAlreadyRegistered();
        SetDefaults();
    }
    
    public void beforeUpdate()
    {
        //IsAlreadyRegistered();
    }
    

    private void SetDefaults() {
        Id[] sessionIds = new Id[0];
        for(Registration__c r : (List<Registration__c>)Trigger.new) {
            if(r.Session__c != null) {
                sessionIds.add(r.Session__c);
            }
        }
        if(sessionIds.size() > 0) {
            Map<Id, Session__c> sessionMap = new Map<Id, Session__c>([Select Id, Event__r.Cancellation_Policy__c, Session_Content__c, Event__r.Additional_Information__c from Session__c where Id = :sessionIds]);
            for(Registration__c r : (List<Registration__c>)Trigger.new) {
                if(r.Session__c != null && sessionMap.containsKey(r.Session__c)) {
                    Session__c s = sessionMap.get(r.Session__c);
                    r.Additional_Information__c = s.Event__r.Additional_Information__c;
                    r.Session_Content__c = s.Session_Content__c;
                    r.Cancellation_Policy__c = s.Event__r.Cancellation_Policy__c;
                }
            }
        }
    }
    /** Check whether the contact is already registered for any other session of an event **/
    private void IsAlreadyRegistered(){
    	//Map contains the Session as the key and contains a listing of ContactIds
        Map<String,Set<String>> SessionContMap = new Map<String,Set<String>>();
        for(Registration__c R : (List<Registration__c>)Trigger.New){
            if(!SessionContMap.containsKey(R.Session__c)){
                SessionContMap.put(R.Session__c,new Set<String>());
            }
            SessionContMap.get(R.Session__c).add(R.Contact__c);
        }
        system.debug('SessionContMap: '+SessionContMap);
        Set<String> EventIds = new Set<String>();
        Map<Id, Session__c> sessionMap = new Map<Id,Session__c>();
        if(SessionContMap.size() > 0){
            for(Session__c S : [select Id, Name, Event__c, Session_End__c from Session__c where Id in : SessionContMap.keySet()]){
                EventIds.add(S.Event__c);
                sessionMap.put(S.Id,S);
            }
        }
        //Map contains the Event Id as the key and contains a listing of SessionIds
        Map<Id,Id> session2EventMap = new Map<Id,Id>();
        
        Map<String,Set<String>> EventSessionMap = new Map<String,Set<String>>();
        Set<String> AllSessionSet = new Set<String>();
        if(EventIds.size() > 0){
            for(Session__c S : [select Id, Name, Event__c from Session__c where Event__c in : EventIds]){
                if(!EventSessionMap.containsKey(S.Event__c)){
                    EventSessionMap.put(S.Event__c, new Set<String>());
                }
                EventSessionMap.get(S.Event__c).add(S.Id);
                AllSessionSet.add(S.Id);
                
                if (S.Event__c != null) session2EventMap.put(S.Id,S.Event__c);
            }
        }
        //Map contains the Session as the key and a listing of ContactIds
        Map<String,Set<String>> ExistingSCMap = new Map<String,Set<String>>();
        if(AllSessionSet.size() > 0){
            for(Registration__c R : [select Id, Name, Contact__c, Session__c from Registration__c where Session__c in : AllSessionSet ORDER BY Session__r.Session_End__c DESC]){
                if(!ExistingSCMap.containsKey(R.Session__c)){
                    ExistingSCMap.put(R.Session__c,new Set<String>());
                }
                ExistingSCMap.get(R.Session__c).add(R.Contact__c);
            }
        }
        
        Map<String,String> CurrentExSCMap = new Map<String,String>();
        for(String EId : EventSessionMap.keySet()){ //For Each Event Id
            for(String SId : EventSessionMap.get(EId)){ //get all of the sessions belonging to that event
                if(SessionContMap.containsKey(SId)){ //If Contacts are present in the Session
                    for(String ContId : SessionContMap.get(SId)){ //For each Contact
                        Boolean IsContExist = false;
                        for(String SsId : EventSessionMap.get(EId)){
                            if(ExistingSCMap.containsKey(SsId)){
                                if(ExistingSCMap.get(SsId).size() > 0 && ExistingSCMap.get(SsId).contains(ContId)){
                                    IsContExist = true;
                                    break;
                                }
                            }
                        }                        
                        if(IsContExist){ //If Contact exists in another session add the session and contact to the currentExisting
                            for(String SsId : EventSessionMap.get(EId)){
                                CurrentExSCMap.put(SsId,ContId);
                            }
                        }
                    }
                }
            }
        }
                
        Map<String,boolean> RegEmailMap = new Map<String,boolean>();
        if(Trigger.IsUpdate){
            for(Registration__c R : (List<Registration__c>)Trigger.Old){
                RegEmailMap.put(R.Session__c,R.Academic_Event_Registration_Email__c);
            }
        }
        
        //Create a Listing of Registration and sort on Session.Session_End__c (Latest DateTime should be first in the list)
        List<sortableRegistration> sRegistrations = new List<sortableRegistration>();
        for (Registration__c R: (List<Registration__c>)Trigger.new)
        {
        	sRegistrations.add(new sortableRegistration(R,sessionMap.get(R.Session__c)));
        }
        //Sort the Registrations
        system.debug('Presorted: '+sRegistrations);
        sRegistrations.sort();
        system.debug('Sorted: '+sRegistrations);
        
        //System.assert(false,CurrentExSCMap+' ---- '+R.Session__c);
        //for(Registration__c R : (List<Registration__c>)Trigger.New){
        for (sortableRegistration sr: sRegistrations)
        {
        	Registration__c R = sr.registration;
        	//system.debug('Registration - Session - Session_End__c: '+R.Id+' '+sessionMap.get(R.Session__c).Session_End__c);
            if(Trigger.IsInsert){
                if(CurrentExSCMap.containsKey(R.Session__c)){
                    R.Academic_Event_Registration_Email__c = false;
                }
                else{
                    R.Academic_Event_Registration_Email__c = true;
                    //Prevent multiple registrations handled in bulk from sending email
                    //Mark all Sessions in for this Event as being used already
                    if (session2EventMap.containsKey(R.Session__c))
                    {
                    	string eventId = session2EventMap.get(R.Session__c);
                    	if (EventSessionMap.get(eventId) != null)
                    	{
	                    	for (String SId : EventSessionMap.get(eventId))
	                    	{
	                    		if (!CurrentExSCMap.containsKey(SId)) CurrentExSCMap.put(SId,R.Contact__c);
	                    	}
                    	}
                    }
                }
            }
            else if(RegEmailMap.containsKey(R.Session__c)){
                R.Academic_Event_Registration_Email__c = RegEmailMap.get(R.Session__c);
            }
        }
    }
    
    
    /**
     * beforeDelete
     *
     * This method is called for records to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete()
    {   
    }
    
   
    public void afterInsert()
    {   
    	
    }
    
    public void afterUpdate()
    {
    	
    }
   
    public void afterDelete()
    {
    }
    
    public void afterUnDelete()
    {
    }
      
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        
    }
    
    public class sortableRegistration implements Comparable
    {
    	public Registration__c registration {get;set;}
    	public Session__c session {get;set;}
    	public sortableRegistration(Registration__c reg, Session__c sess)
    	{
    		this.registration = reg;
    		this.session = sess;
    	}
    	
    	public Integer compareTo(object compareTo)
    	{
    		sortableRegistration compareToRegistration = (sortableRegistration) compareTo;
            if(compareToRegistration.session != null && session != null) {
    		    if (session.Session_End__c == compareToRegistration.session.Session_End__c) return 0;
    		    if (session.Session_End__c < compareToRegistration.session.Session_End__c) return 1;
            }
    		return -1;
    	}
    }
}