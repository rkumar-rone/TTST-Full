/*******************************************************************************************************************
** Module Name   : EventScheduleUpdateClass
** Description   : 
** Throws        : NA
** Calls         : NA
** Test Class    : 
** 
** Organization  : Rainmaker
**
** Revision History:-
** Version             Date            Author                             Description of Action
** 1.0                 00/00/00       PIYUSH KALRA           			Test class for EventScheduleUpdateClass
******************************************************************************************************************/
@isTest
private class EventScheduleUpdateClassTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        EventScheduleUpdateClass EventScheduleUpdateClassObj = new EventScheduleUpdateClass();
        set<id> setOfCampaignId = new set<id>();
        map<id,campaign> idvscampaign = new map<id,campaign>();
        Map<Id,Event_Schedule__c> toUpdate = new Map<Id,Event_Schedule__c>();
        
       
        campaign camp = new campaign();
        camp.name='xyz';
        camp.Status='Closed';
        camp.Number_of_TA_s_Requested__c='1';
        camp.Self_study_Format__c='Physical';
        camp.SS_Order_Delivery_E_book_Live__c = Date.today();
        
        //camp.Event_Schedule__r.Self_study_Order_s_Delivered__c=system.today();
        insert camp;
        toUpdate.put(camp.Event_Schedule__c , camp.Event_Schedule__r);
        //update toUpdate.values();
        
        
        //camp.Event_Schedule__r.Self_study_Order_s_Delivered__c=date.valueof(1/1/2012);
       /*
        Event_Schedule__c event = new Event_Schedule__c();
        
        event.Name='abc';
        event.CurrencyIsoCode='EUR - Euro';
        event.Schedule__c='International Event';
        event.Self_study_Order_s_Delivered__c=system.today();
        insert event;
        */
        
        system.debug('+'+camp);
        setOfCampaignId.add(camp.id);
        try{
             EventScheduleUpdateClass.updateField(setOfCampaignId);
        }
       
        catch(exception exce)
        {
            system.debug('+'+EventScheduleUpdateClassObj);
        }
     
        
        
    }
    
   
    
}