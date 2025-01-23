trigger PopulateMinimumDateToEventSchedule on Campaign (after insert, after update){
    set<Id> idSet = new set<Id>();
    list<Event_Schedule__c> listOfEventSchedule = new list<Event_Schedule__c>();
    list<Event_Schedule__c> listOfEventScheduleToUpdate = new list<Event_Schedule__c>();
    map<Id , Event_Schedule__c> mapToUpdate = new map<Id, Event_Schedule__c>();
    DateTime dt;
    DateTime dt1;
    map<Id , Date> eventIdVsStartDate = new map<Id , Date>();
    map<Id , Date> eventIdVsEndDate = new map<Id , Date>();
    map<Id , Date> eventIdVsTrainingConfirmed = new map<Id , Date>();
    
    
    /********prevent the creation of multiple Schedules on an Event*****/ 
    /*    
     set<id> idSetForEvent = new set<id>();
     map<id,integer> countMap = new map<id, Integer>();
     
    for(Campaign camObj : trigger.new){
        idSetForEvent.add(camObj.Event_Schedule__c);
    }
    system.debug('@@idset '+idSetForEvent);
    for(Event_Schedule__c eveObj : [select id,(select id from TTS_Events__r) from Event_Schedule__c where Id IN :idSetForEvent]){
        for(Campaign c : eveObj.TTS_Events__r){
            countMap.put(c.id , eveObj.TTS_Events__r.size());
            
        }
    }
    
    system.debug('+++++'+countMap);
    */
    /*
    for(Campaign camObj : trigger.new){
        system.debug('@@map '+countMap.get(camObj.id));
        if(countMap.get(camObj.id) > 1){
            camObj.addError('Cant Create Multiple event schedules');
        }
    }
    */
     /***************************************************/ 
     
    //JGP 8/12/2015 Retrieve Record Types
    Map<Id,RecordType> recordTypes = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign']);
     
    for(Campaign cam: trigger.new){
        idSet.add(cam.Event_Schedule__c);
        if(trigger.isUpdate && cam.StartDate != trigger.oldMap.get(cam.id).startDate){
            eventIdVsStartDate.put(cam.Event_Schedule__c , cam.StartDate);
            
        }
        if(trigger.isUpdate && cam.Enddate != trigger.oldMap.get(cam.id).Enddate){
            eventIdVsEndDate.put(cam.Event_Schedule__c , cam.Enddate);
            
        }
        eventIdVsTrainingConfirmed.put(cam.Event_Schedule__c , cam.createddate.date());
        
    }
    listOfEventSchedule = [SELECT id,Earliest_Date_Time__c,(SELECT id,RecordTypeId,Acct_Assess_Start__c,Val_Assess_Start__c,Book_Delivered_to_Student_E_book_Live__c,Self_study_Format__c,Case_Study_Pre_reading_Open__c,StartDate From TTS_Events__r ) From Event_Schedule__c Where id IN: idSet];
    
    for(Event_Schedule__c eventSchObj: listOfEventSchedule){
        Date eventDate ;
        if(eventIdVsStartDate.containsKey(eventSchObj.id)){
            eventSchObj.Start_Date__c = eventIdVsStartDate.get(eventSchObj.id);
        }
        if(eventIdVsEndDate.containsKey(eventSchObj.id)){
            eventSchObj.End_Date__c = eventIdVsEndDate.get(eventSchObj.id);
        }
        if(eventIdVsTrainingConfirmed.containsKey(eventSchObj.id)){
            eventSchObj.Training_Confirmed__c = eventIdVsTrainingConfirmed.get(eventSchObj.id);
        }
       
        system.debug('**** Inside here--'+eventSchObj.TTS_Events__r);
        map<string,date> dateList = new map<string,date>();
        list<Date> dateList2 = new list<Date>();
        string name;
        date dateVar;
        for(Campaign cam : eventSchObj.TTS_Events__r){
        if(trigger.newmap.keyset().contains(cam.Id)){  
            system.debug('**** Inside here again');
            system.debug('**** event Date'+eventDate);
            //JGP S-01044 8/12/2015
            if (recordTypes.get(cam.RecordTypeId).DeveloperName != 'Academic_Event_Client_Registration' && recordTypes.get(cam.RecordTypeId).DeveloperName != 'Academic_Event_Salesforce_Registration')
            {
                if(eventDate!=null)
                    dateList.put('',eventDate);
                if(cam.Acct_Assess_Start__c != null)
                    dateList.put('Acct Assess Start',cam.Acct_Assess_Start__c.Date());
                if(cam.Val_Assess_Start__c != null)
                    dateList.put('Val Assess Start',cam.Val_Assess_Start__c.Date());
                if(cam.Case_Study_Pre_reading_Open__c != null)
                    dateList.put('Case Study Pre reading Open',cam.Case_Study_Pre_reading_Open__c.Date());
                if(cam.Book_Delivered_to_Student_E_book_Live__c != null && cam.Self_study_Format__c != 'Physical'){
                    dateList.put('Student to receive SS/E-Book goes live',cam.Book_Delivered_to_Student_E_book_Live__c  .date());            
                }
            }
            //JGP S-01044 8/12/2015
            if(cam.StartDate != null)   
                    dateList.put('Start Date',cam.Startdate);            
            dateList2.addall(dateList.values());
            dateList2.sort();
            
            system.debug('****** dateList'+dateList);
            if(!dateList.isEmpty())
                eventDate = dateList2.get(0);
                
                
                    for(string dateObj : dateList.keyset())
                    {
                        if(dateList.get(dateObj) == eventDate)
                        {
                            name = dateObj;
                        }
                    }
                
                
            system.debug('****** Abhineet'+eventDate);
            system.debug('!@#$'+name);
            /*if(eventDate==null || (eventDate!=null &&  (cam.Val_Assess_Start__c != null && eventDate > cam.Val_Assess_Start__c.Date()) || (cam.Acct_Assess_Start__c != null && eventDate > cam.Acct_Assess_Start__c.Date()) || (cam.Case_Study_Pre_reading_Open__c != null && eventDate > cam.Case_Study_Pre_reading_Open__c.Date()) || eventDate > cam.StartDate)){
                system.debug('****** Inside Main Iff');
                
                if(((cam.Acct_Assess_Start__c != null && cam.Acct_Assess_Start__c.Date() < cam.StartDate) && cam.Acct_Assess_Start__c < cam.Val_Assess_Start__c && cam.Acct_Assess_Start__c < cam.Case_Study_Pre_reading_Open__c) || cam.Acct_Assess_Start__c != null){
                    system.debug('****** Inside Second Iff');
                    eventDate = cam.Acct_Assess_Start__c.Date();
                }
                
                else if((cam.Val_Assess_Start__c < cam.Acct_Assess_Start__c && cam.Val_Assess_Start__c < cam.Case_Study_Pre_reading_Open__c  && (cam.Val_Assess_Start__c !=null && cam.Val_Assess_Start__c.Date() < cam.StartDate)) || cam.Val_Assess_Start__c != null){
                    system.debug('****** Inside third Iff');
                    eventDate = cam.Val_Assess_Start__c.Date();
                }
                
                else if((cam.Case_Study_Pre_reading_Open__c < cam.Acct_Assess_Start__c && cam.Case_Study_Pre_reading_Open__c < cam.Val_Assess_Start__c  && (cam.Case_Study_Pre_reading_Open__c !=null && cam.Case_Study_Pre_reading_Open__c.Date() < cam.StartDate)) || cam.Case_Study_Pre_reading_Open__c != null){
                    system.debug('****** Inside Fourth Iff'+cam.Case_Study_Pre_reading_Open__c.Date());
                    
                    eventDate = cam.Case_Study_Pre_reading_Open__c.Date();
                    system.debug('**** here'+ eventDate);
                }
                
                else if((cam.Acct_Assess_Start__c != null && cam.StartDate < cam.Acct_Assess_Start__c.Date()) || (cam.Val_Assess_Start__c != null && cam.StartDate < cam.Val_Assess_Start__c.date()) || (cam.Case_Study_Pre_reading_Open__c != null && cam.StartDate < cam.Case_Study_Pre_reading_Open__c.Date()) || (cam.startDate != null)){
                    system.debug('****** Inside fifth Iff');
                    eventDate = cam.StartDate;
                    system.debug('***** aaaaaa'+eventDate);
                }
            }*/
        }
        if(eventDate != null){
            if(eventSchObj.Earliest_Date_Time__c != null){
                dt1 = eventSchObj.Earliest_Date_Time__c;
            }   
            dt = dateTime.newInstance(eventDate.year(),eventDate.month(),eventDate.day());
         //   if(dt1 ==null || dt1 > dt)
                
                    eventSchObj.Earliest_Date_Time__c = dt;
                
                    
                
                if(name!= null){
                eventSchObj.Earliest_Date_Time_Detail__c = name;
                }
            //listOfEventScheduleToUpdate.add(eventSchObj);
            mapToUpdate.put(eventSchObj.id , eventSchObj);
        }else if(!eventIdVsEndDate.isEmpty() || !eventIdVsStartDate.isEmpty() || !eventIdVsTrainingConfirmed.isEmpty()){
            mapToUpdate.put(eventSchObj.id , eventSchObj);
            //listOfEventScheduleToUpdate.add(eventSchObj);
        }
        system.debug('***** eventSchObj.Earliest_Date_Time__c'+eventSchObj.Earliest_Date_Time__c);
        system.debug('***** eventDate'+eventDate);
    }
    }
    listOfEventScheduleToUpdate.addAll(mapToUpdate.values());
    if(listOfEventScheduleToUpdate.IsEmpty()) return;
        try{
            update listOfEventScheduleToUpdate;
            system.debug('Event Schedule to update listing: '+listOfEventScheduleToUpdate);
        }catch(DMLException e){
            system.debug('**** Error Message'+e.getMessage());
        }
}