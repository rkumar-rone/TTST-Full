@isTest(SeeAllData=true)
public with sharing class WaitingListResizeEventTriggerTest {
    
    @isTest
    static void testWaitingListResizeEventTrigger() {

        List<Session__c> sessionsList = [SELECT Event__c,Id,Name,Waiting_List_Members__c FROM Session__c WHERE Waiting_List_Members__c > 0 ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];

        List<String> eventIds = new List<String>();
        for (Session__c session : sessionsList) {
            eventIds.add(session.Event__c);
        }
        
        List<Registration__c> registrationsList = [SELECT Id,Session__c FROM Registration__c WHERE Session__c IN :sessionsList ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];

        if (registrationsList.size() < 1) {
            System.assertEquals(1, 2, 'No registrations found');
        }

        List<Campaign> campaignsList = [SELECT Id,Name,Seats_Available__c FROM Campaign WHERE Wait_List_Members__c > 0 AND Id IN :eventIds ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
        
        if (campaignsList.size() < 1) {
            System.assertEquals(1, 2, 'Campaigns not found');
        }

        for (Campaign campaign : campaignsList) {
            campaign.Instructor__c = null;
            campaign.Disable_Wait_List__c = Datetime.now().addDays(5);
            campaign.Disable_Wait_List_Date__c = campaign.Disable_Wait_List__c.date();
            update campaign;
        }

        List<String> eventIds2 = new List<String>();
        for (Campaign campaign : campaignsList) {
            eventIds2.add(campaign.Id);
        }

        List<Campaign> campaignsList2 = [SELECT Id,Name,Seats_Available__c, Disable_Wait_List__c FROM Campaign WHERE Id IN :eventIds2];

        for (Campaign c : campaignsList2) {
            if (c.Disable_Wait_List__c < Datetime.now()) {
                System.assertEquals(1, 2, 'Was not able to update to be after today: c.Disable_Wait_List__c: '+c.Disable_Wait_List__c+' c.Id: '+c.Id);
            }
        }
        
        Test.startTest();
       
        for (Campaign campaign : campaignsList2) {
            campaign.Seats_Available__c = campaign.Seats_Available__c+100;
            update campaign;
        }
        

        Test.stopTest();

    }
}