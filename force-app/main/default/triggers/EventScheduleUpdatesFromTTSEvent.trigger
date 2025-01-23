/****************************************************************************************************
*Description:           This trigger populates information on the TTS Event Schedule                       
*
*Required Class(es):    EventScheduleUpdatesFromTTSEvent_Test
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     06/17/2015   Justin Padilla     Initial Implementation
*****************************************************************************************************/
trigger EventScheduleUpdatesFromTTSEvent on Campaign (before insert, before update)
{
    Set<string> excludedRecordTypebyName = new Set<string>();
    excludedRecordTypebyName.add('Public_Event');
    excludedRecordTypebyName.add('Academic_Event');
    Set<Id> validRecordTypeIds = new Set<Id>();
    list<Event_Schedule__c> eventSchedulelist = new list<Event_Schedule__c>();
    map<id,datetime> eventScheduleIdVsDeliverytoStudent = new map<id,datetime>();
    list<Event_Schedule__c> eventScheduleUpdatelist  = new list<Event_Schedule__c>();
    set<id> eventScheduleId = new set<id>();
    map<id,datetime> IdsvsvalueOfEventSchedule =new map<id,datetime>();
    List<Event_Schedule__c> UpdateEvents =new List<Event_Schedule__c>();
    map<string, Holiday> mapOfHolidays = new  map<string,Holiday>();
    
    //JGP 08/12/2015 S-01044
    //Retrieve Campaign record types
    Map<Id,RecordType> recordTypes = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign']);
    //JGP 08/20/2015 Add Event RecordTypes to Map by Name
    Map<string,RecordType> recordTypesByName = new Map<string,RecordType>();
    for (RecordType rt: recordTypes.values())
    {
        recordTypesByName.put(rt.DeveloperName,rt);
    }
    Map<string,RecordType> eventRecordTypes = new Map<string,RecordType>();
    for (RecordType rt: [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Event_Schedule__c'])
    {
        eventRecordTypes.put(rt.DeveloperName,rt);
    }    
    /*----------------------Changes By p.k---------------------------------------*/
  /*  for(campaign campaignObj : trigger.new)
    {
        eventScheduleIdVsDeliverytoStudent.put(campaignObj.Event_Schedule__c,campaignObj.SS_Order_Delivery_E_book_Live__c);
    }
    
    if(eventScheduleIdVsDeliverytoStudent != null){
        for(Event_Schedule__c eventScheduleObj : [select id,Self_study_Order_s_Delivered__c from Event_Schedule__c where id IN:eventScheduleIdVsDeliverytoStudent.keyset()]){
        eventScheduleObj.Self_study_Order_s_Delivered__c = Date.valueOf(eventScheduleIdVsDeliverytoStudent.get(eventScheduleObj.id));
        eventSchedulelist.add(eventScheduleObj);
        }
        
        try{
            update eventSchedulelist;
        }
        catch(Exception e){
            system.debug('ERROR-'+e);
        }   
    }
    */
     /*************************** Update No_Case_Study_Pre_reading__c on event schedule *********************************************/
     map<id , Campaign> mapOfIdVsCamField = new map <ID , Campaign>();
     list<Event_Schedule__c> listOfUpdateEvent = new list<Event_Schedule__c>();
     
     for(Campaign camObj : trigger.new){
        
            mapOfIdVsCamField.put(camObj.Event_Schedule__c , camObj );
        
     }
     system.debug('++++'+mapOfIdVsCamField);
     
     if(mapOfIdVsCamField != null){
        for(Event_Schedule__c eventObj :[select id,No_Case_Study_Pre_reading__c from Event_Schedule__c where Id IN : mapOfIdVsCamField.Keyset()]){
            if(mapOfIdVsCamField.get(eventObj.id).Case_Study_Pre_reading_Format__c != null && mapOfIdVsCamField.get(eventObj.id).Case_Study_Pre_reading_Format__c == 'No Pre-reading'){
            eventObj.No_Case_Study_Pre_reading__c = true;
            }else{
            eventObj.No_Case_Study_Pre_reading__c = false;
            }
            listOfUpdateEvent.add(eventObj);
        }
     }
        system.debug('++++'+listOfUpdateEvent);
      
      if(!listOfUpdateEvent.isEmpty())
        update listOfUpdateEvent;
     
     
    
    /***************************Field Update *********************************************/
    

    for(campaign campaignObj : trigger.new)
    {
        eventScheduleIdVsDeliverytoStudent.put(campaignObj.Event_Schedule__c,campaignObj.SS_Order_Delivery_E_book_Live__c);
    }
    
    if(eventScheduleIdVsDeliverytoStudent != null){
        for(Event_Schedule__c eventScheduleObj : [select id,SS_Order_Delivery_E_book_Live__c from Event_Schedule__c where id IN:eventScheduleIdVsDeliverytoStudent.keyset()]){
        eventScheduleObj.SS_Order_Delivery_E_book_Live__c = Date.valueOf(eventScheduleIdVsDeliverytoStudent.get(eventScheduleObj.id));
        eventSchedulelist.add(eventScheduleObj);
        }
        
        try{
            update eventSchedulelist; 
        }
        catch(Exception e){
            system.debug('ERROR-'+e);
        }   
    }

    
    /********************************update Case_Study_Pre_reading_Open__c ****************************************/
    map<id,DateTime> idVsCaseStudyPreReadingOpen = new map<id,DateTime>();
    set<id> idsOfEventScheduleInEvent = new set<id>();
    list<Event_Schedule__c> UpdatedObjectsOfEventSchedule = new list<Event_Schedule__c>();
    
    for(Campaign eventObj : trigger.new)
    {   if(eventObj.Case_Study_Pre_reading_Open__c != null)
            idVsCaseStudyPreReadingOpen.put(eventObj.Event_Schedule__c,eventObj.Case_Study_Pre_reading_Open__c);
        idsOfEventScheduleInEvent.add(eventObj.Event_Schedule__c);
    }
    system.debug('@@@'+idVsCaseStudyPreReadingOpen);
//  system.debug('@@@'+idVsCaseStudyPreReadingOpen.values());
    for(Event_Schedule__c evenScheduleObj :[select id,Case_Study_Pre_reading_Open__c from Event_Schedule__c where id in:idsOfEventScheduleInEvent])
    {
        evenScheduleObj.Case_Study_Pre_reading_Open__c = Date.valueOf(idVsCaseStudyPreReadingOpen.get(evenScheduleObj.id));
        UpdatedObjectsOfEventSchedule.add(evenScheduleObj);
    }
    if(!UpdatedObjectsOfEventSchedule.isEmpty())
        update UpdatedObjectsOfEventSchedule;
     /***************************Field Update *********************************************/
     for(campaign objOfCampaign : trigger.new){
        if(objOfCampaign.Event_Schedule__c !=null){
            IdsvsvalueOfEventSchedule.put(objOfCampaign.Event_Schedule__c,objOfCampaign.Book_Delivered_to_Student_E_book_Live__c);
        }
     }
     List<Event_Schedule__c> RelatedEvents = [select id,Book_Delivered_to_Student_E_book_Live__c from Event_Schedule__c where id in:IdsvsvalueOfEventSchedule.keyset()];
    
     for(Event_Schedule__c objCamp : RelatedEvents){
        for(id mapidvalue : IdsvsvalueOfEventSchedule.keyset()){
            if(objCamp.id == mapidvalue){
                objCamp.Book_Delivered_to_Student_E_book_Live__c = IdsvsvalueOfEventSchedule.get(mapidvalue);
                UpdateEvents.add(objCamp);
            }
        }
            
         
     }
     
        update UpdateEvents;
     
     /**************************update Using_Resource_Center_Schedule__c**********************************************/
    for(campaign campaignObj : trigger.new)
    {
        if(campaignObj.Using_Resource_Center__c == true && campaignObj.Using_Resource_Center__c != null )
        {
            eventScheduleId.add(campaignObj.Event_Schedule__c);
        }
    }
    
    System.debug('+++++'+eventScheduleId);
    
    list<Event_Schedule__c> eventSchedulelistSec = [select Using_Resource_Center_Schedule__c from Event_Schedule__c where ID IN:eventScheduleId ];
    
    for(Event_Schedule__c eventScheduleObj : eventSchedulelistSec)
    {
        eventScheduleObj.Using_Resource_Center_Schedule__c = true;
        eventScheduleUpdatelist.add(eventScheduleObj);
    
        System.debug('+++++'+eventScheduleUpdatelist);
    }
    
     System.debug('+++++'+eventScheduleUpdatelist);
    
    update eventScheduleUpdatelist;
    
    
    
    /*-------------------------------------------------------------*/
    for (RecordType rt: [SELECT Id, DeveloperName, SObjectType FROM RecordType where SObjectType = 'Campaign'])
    {
        if (!excludedRecordTypebyName.contains(rt.DeveloperName)) validRecordTypeIds.add(rt.Id);
    }   
    Set<Id> scheduleIds = new Set<Id>();    
    Set<String> fieldMonitor = new Set<String>();
    fieldMonitor.add('Instructor__c');
    for (Campaign c: trigger.new)
    {
        if (c.Event_Schedule__c != null && validRecordTypeIds.contains(c.RecordTypeId)) 
            scheduleIds.add(c.Event_Schedule__c);
    }
    //JGP 08/20/2015
    boolean recordTypeUpdated = false;
    /******************************************* Update Campaign Record Type according to the Registration System Picklist *******/
    for (Campaign c: trigger.new)
    {
        if (trigger.isUpdate && c.Registration_System__c != null && c.Registration_System__c != trigger.oldMap.get(c.Id).Registration_System__c) //Registration system has been updated
        {
            system.debug('Event Record Type has changed');
            if (recordTypes.get(c.recordTypeId).DeveloperName != 'Public_Event')
            {
                if (c.Registration_System__c.toLowerCase() == 'client' && recordTypes.get(c.recordTypeId).DeveloperName != 'Academic_Event_Client_Registration' && recordTypesByName.get('Academic_Event_Client_Registration') != null) c.recordTypeId = recordTypesByName.get('Academic_Event_Client_Registration').Id;
                if (c.Registration_System__c.toLowerCase() == 'salesforce' && recordTypes.get(c.recordTypeId).DeveloperName != 'Academic_Event_Salesforce_Registration' && recordTypesByName.get('Academic_Event_Salesforce_Registration') != null) c.recordTypeId = recordTypesByName.get('Academic_Event_Salesforce_Registration').Id;
                system.debug('Event Record Type has been updated');
                recordTypeUpdated = true;
            }
        }
        
        if (c.Registration_System__c != null && trigger.isinsert)  //Registration system has been updated
        {
            system.debug('Event Record Type has changed');
            if (recordTypes.get(c.recordTypeId).DeveloperName != 'Public_Event')
            {
                if (c.Registration_System__c.toLowerCase() == 'client' && recordTypes.get(c.recordTypeId).DeveloperName != 'Academic_Event_Client_Registration' && recordTypesByName.get('Academic_Event_Client_Registration') != null) c.recordTypeId = recordTypesByName.get('Academic_Event_Client_Registration').Id;
                if (c.Registration_System__c.toLowerCase() == 'salesforce' && recordTypes.get(c.recordTypeId).DeveloperName != 'Academic_Event_Salesforce_Registration' && recordTypesByName.get('Academic_Event_Salesforce_Registration') != null) c.recordTypeId = recordTypesByName.get('Academic_Event_Salesforce_Registration').Id;
                system.debug('Event Record Type has been updated');
                recordTypeUpdated = true;
            }
        }
    }
    if (!scheduleIds.isEmpty())
    {
        /**************** Instructor *******************************/       
        Map<Id, Event_Schedule__c> eventSchedules = new Map<Id, Event_Schedule__c>([SELECT Id, Resource_Assigned__c FROM Event_Schedule__c WHERE Id IN: scheduleIds]);
        Map<Id,Event_Schedule__c> toUpdate = new Map<Id,Event_Schedule__c>();
        
        /**********************field***********************/
        /*if (trigger.isUpdate)
            {
        set<id> setofeventId = new set<id>();
        Map<ID ,Campaign> idVsCampaign = new Map<ID ,Campaign>([SELECT ID,SS_Order_Delivery_E_book_Live__c,Event_Schedule__c,Event_Schedule__r.Self_study_Order_s_Delivered__c FROM Campaign WHERE ID IN :trigger.new]);
        
        Date dt;
        for(Campaign cam : idVsCampaign.values()){
            //  dt = cam.SS_Order_Delivery_E_book_Live__c.date();
                system.debug('dtValue'+dt);
                setofeventId.add(cam.Event_Schedule__c);
        }
            
        Map<ID ,Event_Schedule__c> idVsEvent = new Map<ID , Event_Schedule__c>([SELECT ID,Self_study_Order_s_Delivered__c from Event_Schedule__c WHERE ID IN : setofeventId]);
        for(Campaign cam : idVsCampaign.values()){
                dt = null != cam.SS_Order_Delivery_E_book_Live__c ? cam.SS_Order_Delivery_E_book_Live__c.date() :null;
                system.debug('2dtValue'+dt);
                if(cam.Event_Schedule__c != null){
                    idVsEvent.get(cam.Event_Schedule__c).Self_study_Order_s_Delivered__c = dt;
                }
        }
        update idVsEvent.values();
            }*/
    /***************************************************/   
        
        
        for (Campaign c: trigger.new)
        {
            if (trigger.isInsert)
            {
                for (string s: fieldMonitor)
                {
                    
                    
                    if (s == 'Instructor__c')
                    {
                        if (c.get(s) != null && c.Event_Schedule__c != null)
                        {
                            eventSchedules.get(c.Event_Schedule__c).put('Resource_Assigned__c', Date.today());
                            toUpdate.put(c.Event_Schedule__c, eventSchedules.get(c.Event_Schedule__c));
                        }
                    }
                }
            }
            if (trigger.isUpdate)
            {
                for (string s: fieldMonitor)
                {
                    if (c.get(s) != trigger.oldMap.get(c.Id).get(s)) //It's been updated
                    {
                        if (s == 'Instructor__c')
                        {
                            if (c.get(s) == null && c.Event_Schedule__c != null) eventSchedules.get(c.Event_Schedule__c).put('Resource_Assigned__c', null);
                            if (c.get(s) != null && c.Event_Schedule__c != null) eventSchedules.get(c.Event_Schedule__c).put('Resource_Assigned__c', Date.today());
                            toUpdate.put(c.Event_Schedule__c, eventSchedules.get(c.Event_Schedule__c));
                        }
                    }
                }
            }
        }
        /***************** TA Staffing *****************************************************/
        //Is # of TA's populated?
        for (Campaign c: trigger.new)
        {
            Set<String> monitored = new Set<string>();
            monitored.add('Number_of_TA_s_Requested__c');
            monitored.add('TA_1__c');
            monitored.add('TA_2__c');
            monitored.add('TA_3__c');
            monitored.add('TA_4__c');
            monitored.add('TA_5__c');
            monitored.add('TA_6__c');
            if (c.Number_of_TA_s_Requested__c != null && c.Event_Schedule__c != null)
            {
                Boolean evaluate = false;
                Integer TACount = 0;
                if (trigger.isInsert)
                {
                    for (string s: monitored)
                    {
                        if (c.get(s) != null)
                        {
                            TACount++;
                            evaluate = true;
                        }                       
                    }
                }
                if (trigger.isUpdate)
                {
                    for (string s: monitored)
                    {
                        if (c.get(s) != trigger.oldMap.get(c.Id).get(s)) evaluate = true;
                        if (c.get(s) != null && s != 'Number_of_TA_s_Requested__c') TACount++;
                    }
                }
                if (evaluate) // && TACount > 0
                {
                    //Get the Event needed
                    Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                    if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                    if (c.Number_of_TA_s_Requested__c != null && integer.valueOf(c.Number_of_TA_s_Requested__c) > TACount) temp.TA_Staffing_Complete__c = null;
                    if (c.Number_of_TA_s_Requested__c != null && integer.valueOf(c.Number_of_TA_s_Requested__c) <= TACount) temp.TA_Staffing_Complete__c = Date.today();
                    toUpdate.put(temp.Id,temp);
                }
            }
        }
        /***************** Invoice Number *****************************************************/
        for (Campaign c: trigger.new)
        {
            if (c.Event_Schedule__c != null)
            {
                Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                //Invoice_Sent_to_Accounting__c
                if(temp != null) {
                    if (trigger.isInsert && c.Invoice_Number__c != null)    temp.Event_Setup_in_Accounting__c = date.today();
                    if (trigger.isUpdate && c.Invoice_Number__c != trigger.oldMap.get(c.Id).Invoice_Number__c && c.Invoice_Number__c != null) temp.Event_Setup_in_Accounting__c = date.today();
                    if (trigger.isUpdate && c.Invoice_Number__c != trigger.oldMap.get(c.Id).Invoice_Number__c && c.Invoice_Number__c == null) temp.Event_Setup_in_Accounting__c = null;
                    toUpdate.put(temp.Id,temp);
                }
            }
        }
        /***************** Self Study Format ****************************************************/
        for (Campaign c: trigger.new)
        {
            if (c.Event_Schedule__c != null)
            {
                Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                if(temp != null) {
                if (trigger.isInsert && c.Self_study_Format__c != null && c.Self_study_Format__c.toLowerCase() == 'no self-study') temp.Is_Self_study__c = true;
                if (trigger.isUpdate && c.Self_study_Format__c != trigger.oldMap.get(c.Id).Self_study_Format__c && c.Self_study_Format__c != null && c.Self_study_Format__c.toLowerCase() == 'no self-study') temp.Is_Self_study__c = true;
                if (trigger.isUpdate && c.Self_study_Format__c != trigger.oldMap.get(c.Id).Self_study_Format__c && (c.Self_study_Format__c == null || c.Self_study_Format__c.toLowerCase() != 'no self-study')) temp.Is_Self_study__c = false;
                toUpdate.put(temp.Id,temp);
                }
            }
        }
        /********************** Instructor change to update the Event Schedule if a user exists with the same email address as the Contact *******************/
        Map<Id, string> contactId2EmailMap = new Map<Id, string>();
        Set<string> emailAddresses = new Set<String>();
        Map<string,User> email2UserMap = new Map<string,User>();
        Map<String,String> ESOwnerMap = new Map<String,String>();
        for (Campaign c: trigger.New)
        {
            if (trigger.isInsert && c.Instructor__c != null) contactId2EmailMap.put(c.Instructor__c, null);
            if (trigger.isUpdate && c.Instructor__c != trigger.oldMap.get(c.Id).Instructor__c) contactId2EmailMap.put(c.Instructor__c, null);
            
            if(c.Event_Schedule__c != null && c.Instructor__c == null){
                if(c.Event_Manager__c != null){
                    ESOwnerMap.put(c.Event_Schedule__c,c.Event_Manager__c);
                }
            }
        }
        if (!contactId2EmailMap.isEmpty())
        {
            for (Contact c: [SELECT Id, Email FROM Contact where Id IN: contactId2EmailMap.keySet()])
            {
                contactId2EmailMap.put(c.Id,c.Email);
                emailAddresses.add(c.Email);
            }
            if (!emailAddresses.isEmpty())
            {
                for (User u: [SELECT Id, Email FROM User where Email IN: emailAddresses])
                {
                    email2UserMap.put(u.Email,u);
                }
            }
        }
        system.debug('contactId2EmailMap: '+contactId2EmailMap);
        system.debug('email2UserMap: '+email2UserMap);
        for (Campaign c: trigger.new)
        {
            if (c.Event_Schedule__c != null)
                {
                    Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                    if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                    
                    if(temp != null) {
                    if (c.Instructor__c != null && contactId2EmailMap.get(c.Instructor__c) != null && email2UserMap.get(contactId2EmailMap.get(c.Instructor__c)) != null)
                    {
                        User newOwner = email2UserMap.get(contactId2EmailMap.get(c.Instructor__c));
                        temp.put('OwnerId',newOwner.Id);
                        temp.put('Allow_Owner_Change__c',true);
                        system.debug('Schedule New Owner: '+newOwner.Id);
                        toUpdate.put(temp.Id,temp);
                    }
                    
                    if(c.Instructor__c == null && ESOwnerMap.containsKey(c.Event_Schedule__c)){
                        temp.put('OwnerId',ESOwnerMap.get(c.Event_Schedule__c));
                        temp.put('Event_Relationship_Manager__c',ESOwnerMap.get(c.Event_Schedule__c));
                        temp.put('Allow_Owner_Change__c',true);
                        system.debug(' ******** Schedule New Owner ');
                        toUpdate.put(temp.Id,temp);
                    }
                    }
                }
        }
        //JGP 08/12/2015 S-01044
        /******************************************  Registration System **********************************************************/
        for (Campaign c: trigger.new)
        {
            //if (recordTypes.get(c.recordTypeId).DeveloperName == 'Academic_Event_Client_Registration')
            //{
                Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                if(temp != null) {
                if (c.Registration_System__c != null && c.Registration_System__c.toLowerCase() == 'client') temp.put('Client_Registration__c',true);
                if (c.Registration_System__c == null || c.Registration_System__c.toLowerCase() != 'client') temp.put('Client_Registration__c',false);
                system.debug('Client Registration Set');
                toUpdate.put(temp.Id,temp);
                }
            //}
        }
        /****************************************** Survey Setup **********************************************************/
        for (Campaign c: trigger.new)
        {
            if (recordTypes.get(c.recordTypeId).DeveloperName == 'Academic_Event_Client_Registration' || recordTypes.get(c.recordTypeId).DeveloperName == 'Academic_Event_Salesforce_Registration')
            {
                Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                if(temp != null) {
                if (trigger.isInsert && c.Survey_Link__c != null) temp.put('Survey_Set_Up__c', dateTime.now());
                if (trigger.isUpdate && c.Survey_Link__c != null && c.Survey_Link__c != trigger.oldMap.get(c.Id).Survey_Link__c) temp.put('Survey_Set_Up__c', dateTime.now());
                if (trigger.isUpdate && c.Survey_Link__c == null && c.Survey_Link__c != trigger.oldMap.get(c.Id).Survey_Link__c) temp.put('Survey_Set_Up__c', null);
                
                toUpdate.put(temp.Id,temp);
                system.debug('@@'+temp.Id);
                system.debug('@@@'+temp);
                }
            }
        }       
        //JGP 08/20/2015 Update the Event Schedule to Match the Event Record Type by Name
        /******************************************* Match Record Type ***************************************************/
        for (Campaign c: trigger.new)
        {
            if ((trigger.isUpdate && c.RecordTypeId != trigger.oldMap.get(c.Id).RecordTypeId && c.Event_Schedule__c != null) || recordTypeUpdated) //Record Type has changed attempt to match
            {
                system.debug('recordTypes.get(c.recordTypeId).DeveloperName: '+recordTypes.get(c.recordTypeId).DeveloperName);
                system.debug('eventRecordTypes.get: '+eventRecordTypes.get(recordTypes.get(c.recordTypeId).DeveloperName));
                if (eventRecordTypes.get(recordTypes.get(c.recordTypeId).DeveloperName) != null)
                {
                    Event_Schedule__c temp = toUpdate.get(c.Event_Schedule__c);
                    if (temp == null) temp = eventSchedules.get(c.Event_Schedule__c);
                    temp.recordTypeId = eventRecordTypes.get(recordTypes.get(c.recordTypeId).DeveloperName).Id;
                    system.debug('Event Schedule RecordType Updated: '+temp);
                    toUpdate.put(temp.Id,temp);
                }
            }
        }
    if (!toUpdate.isEmpty()) 
    {
        update(toUpdate.values());
        system.debug('@@@@'+toUpdate.values());
    }
    }
    /**********************************fieldUpdate*******************/
    //P.K 08/31/2015 Update the checkbox on Event if end date is between Labor Day and Memorial Day.
     /**********************************Checkbox update*******************/
    // creating map for holidays
        
    for(holiday h :[select name ,RecurrenceType,RecurrenceMonthOfYear,RecurrenceStartDate,RecurrenceDayOfWeekMask,RecurrenceInterval,RecurrenceInstance,IsRecurrence, ActivityDate from holiday])
    {
        if(h.IsRecurrence){
            
            //system.debug('!!!Date dt'+dt);
            mapOfHolidays.put(h.name , h);
        }else if(h.name != null && h.ActivityDate != null)
            { 
                if(h.name =='Memorial Day Reccuring' || h.name =='Labor Day Reccuring')
                {
                    mapOfHolidays.put(h.name , h);
                    system.debug('!!!mapOfHolidays'+mapOfHolidays);
                }
            } 
        
    }
    
    /*
    //updating checkbox value
    for(Campaign campObj : trigger.new)
    {
        if(campObj.EndDate != null && mapOfHolidays.get('Labor Day Reccuring') != null && mapOfHolidays.get('Memorial Day Reccuring')!=null && mapOfHolidays.get('Memorial Day Reccuring').RecurrenceStartDate.year() <= campObj.EndDate.year() && mapOfHolidays.get('Labor Day Reccuring').RecurrenceStartDate.year() <= campObj.EndDate.year())
        {
            boolean dt = RecurringDate.recurring( campObj.EndDate , mapOfHolidays); 
            
            
            system.debug('!!!!labor'+mapOfHolidays.get('Labor Day Reccuring'));
            system.debug('!!!!memorial'+mapOfHolidays.get('Memorial Day Reccuring'));
            system.debug('!!!!!end date'+campObj.EndDate);
            //if(campObj.EndDate >  mapOfHolidays.get('Labor Day Reccuring').activitydate && campObj.EndDate < mapOfHolidays.get('Memorial Day Reccuring').activitydate && mapOfHolidays.get('Memorial Day Reccuring').activitydate > mapOfHolidays.get('Labor Day Reccuring').activitydate)
            //{
            //  campObj.Is_Check__c = true;
            //  system.debug('!!!campObj.Is_Check__c'+campObj.Is_Check__c);
            //}
            
            if(dt == true)
            {
                campObj.Is_Check__c = true;
            }
            else
            {
                campObj.Is_Check__c = false;
            }
        }
        
        else
        {
            campObj.Is_Check__c = false;
        }
    }
    
    */
}