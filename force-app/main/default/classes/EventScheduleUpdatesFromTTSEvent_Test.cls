/****************************************************************************************************
*Description:           This is the test class for the EventScheduleUpdatesFromTTSEvent trigger                     
*
*Required Class(es):    N/A
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     06/26/2015   Justin Padilla     Initial Implementation
*****************************************************************************************************/
@isTest
private class EventScheduleUpdatesFromTTSEvent_Test
{
    static testMethod void EventScheduleUpdatesFromTTSEvent_Trigger_Test()
	{
		//Create an Account
		Account a = new Account(Name = 'TEST');
		insert(a);
		
		//Create some Contacts
		List<Contact> contacts = new List<Contact>();
		for (Integer i=0;i<5;i++)
		{
			Contact c = new Contact();
			c.FirstName = 'Test'+string.valueOf(i);
			c.LastName = 'Test'+string.valueOf(i);
			c.AccountId = a.Id;
			c.Instructor__c = true;
			c.TA__c = true;
			contacts.add(c);
		}
		insert(contacts);
		//Schedule__c sc = new Schedule__c();
		//insert(sc);
		//Create an Event Schedule
		Event_Schedule__c schedule = new Event_Schedule__c();
		//schedule.Schedule__c = sc.Id;
		insert(schedule);
		//Create an Event
		Campaign c = new Campaign();
		c.Name = 'Test';
		c.Event_Schedule__c = schedule.Id;
		c.Account__c = a.Id;
		c.Instructor__c = contacts[0].Id;
		
		c.Number_of_TA_s_Requested__c = '4';
		c.TA_1__c = contacts[0].Id;
		c.TA_2__c = contacts[1].Id;
		c.TA_3__c = contacts[2].Id;
		c.TA_4__c = contacts[3].Id;
		
		c.Invoice_Number__c = 999;
		
		c.Self_study_Format__c = 'no self-study';
		
		insert(c);
		
		//Update Campaign with all nulls
		c.Instructor__c = null;
		c.TA_1__c = null;
		c.Invoice_Number__c = null;
		c.Self_study_Format__c = null;
		update(c);
		
		//Update with valid Info
		c.Instructor__c = contacts[0].Id;		
		c.Number_of_TA_s_Requested__c = '4';
		c.TA_1__c = contacts[0].Id;
		c.TA_2__c = contacts[1].Id;
		c.TA_3__c = contacts[2].Id;
		c.TA_4__c = contacts[3].Id;		
		c.Invoice_Number__c = 999;		
		c.Self_study_Format__c = 'no self-study';
		update(c);
    }
}