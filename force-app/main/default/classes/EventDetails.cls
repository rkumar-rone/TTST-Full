public with sharing class EventDetails {
	public EventClass[] events {get;set;}
	public String userId {get;set;}
	public String userName {get;set;}
	public Boolean loggedIn {get;set;}
	public String selectedSession {get;set;}
	public Boolean waitlist {get;set;} 
	public Boolean allRequired {get;set;}
	
	public PageReference load() {
		waitlist = false;
		loggedIn = false;
		if(ApexPages.currentPage().getParameters().containsKey('userId')) {
			userId = ApexPages.currentPage().getParameters().get('userId');
			if(ApexPages.currentPage().getParameters().containsKey('userName')) {
				userName = ApexPages.currentPage().getParameters().get('userName');
				try { 
					Contact c = [Select Id from Contact where Id = :UserId and User_Id__c = :userName];
					loggedIn = true;
				}
				catch (Exception ex) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot access this page without being logged in.'));
				}
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot access this page without being logged in.'));
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot access this page without being logged in.'));
		}
		return null;
	}
	
	public EventDetails() {
		events = new EventClass[0];
		String eventId = '';
		if(ApexPages.currentPage().getParameters().containsKey('eventId'))
			eventId = ApexPages.currentPage().getParameters().get('eventId');
		if(ApexPages.currentPage().getParameters().containsKey('userId')) {
			userId = ApexPages.currentPage().getParameters().get('userId');
			if(ApexPages.currentPage().getParameters().containsKey('userName')) {
				userName = ApexPages.currentPage().getParameters().get('userName');
				try { 
					Contact c = [Select Id from Contact where Id = :UserId and User_Id__c = :userName];
					loggedIn = true;
				}
				catch (Exception ex) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot access this page without being logged in.'));
				}
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot access this page without being logged in.'));
			}
		}
		allRequired = true;
		for(Campaign[] cs : [Select Only_Show_Sessions__c, Instructor__c, Instructor__r.Name, Seats_Available__c, Registered__c, What_s_Included_in_the_Cost__c, What_to_Bring__c, RecordType.Name, Additional_Information__c, View_Map__c, Training_Location_Name__c, Training_Location_Street__c,Training_Location_City__c, Training_Location_State__c, Training_Location_Zip_Code__c, Cancellation_Policy__c, Event_Time_Zone__c, Description, Pre_requisites__c, Early_Bird_Registration_Cost__c, Early_Bird_Deadline__c, CurrencyIsoCode, Full_Registration_Cost__c, Partial_Course_Cost__c, Total_Sessions__c, Event_Description__c, Account__r.Name, Id, Name, Online_Event_Name__c, RT_Description__c, Sister_Event__c, Sister_Event__r.StartDate, Sister_Event__r.EndDate, StartDate, EndDate, Class_Code__c, Class_Details_Summary__c, (Select  Event__r.Instructor__c, Event__r.Instructor__r.Name, Seats_Available__c, Number_Registered__c, Required__c, End_Hours__c, End_Minutes__c, End_AM_PM__c, Start_AM_PM__c, Start_Minutes__c, Start_Hours__c, Waiting_List_Members__c, Id, Instructor__c, Instructor__r.Name, Name, Session_Date__c, Session_Start__c from Event_Sessions__r order by Session_Date__c, Session_Start__c ) from Campaign where Registration_From__c <= :dateTime.now() and Registration_To__c >= :dateTime.Now() order by StartDate]) {
 
			 
			for(Campaign c : cs) {
				if((eventId == '' && c.RecordType.Name == 'Public Event')|| (eventId != '' && c.Id == eventId)) { 
					EventClass e = new EventClass();
					e.c = c;
					e.userId = userId;
					e.userName = userName;
					for(Session__c[] sesses : c.Event_Sessions__r) {
						for(Session__c s : sesses) {
							if(!s.Required__c)
								allRequired = false;
							SessionClass sc = new SessionClass();
							sc.s = s;
							e.sessions.add(sc);
						}
					}
					events.add(e);
				}
			}
		}
	}
	
	public PageReference register() {
		Boolean waitlistParent = false;
		Integer selected = 0;
		if(waitlist == false) {
			for(EventClass e : events) {
				if(e.selected) {
					selected++;
					/*if((e.c.Registered__c == null ? 0 : e.c.Registered__c) >= (e.c.Seats_Available__c == null ? 0 : e.c.Seats_Available__c)) {
						waitlist = true;
						waitlistParent = true;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The event you are trying to register for is waitlisted - please hit Register again if you wish to be registered to the waitlist.'));
					}*/
				}
				for(SessionClass s : e.sessions) {
					if(s.selected) {
						selected++;
						if(s.s.Number_Registered__c >= s.s.Seats_Available__c && !waitlistParent) {
							waitlist = true;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The session you are trying to register for (' + s.s.Name + ') is waitlisted - please hit submit again if you wish to be registered to the waitlist.'));
						}
					}
				}
			}
			if(selected == 0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one session/event.'));
				return null;
			}
			if(waitlist == true)
				return null;
		}
		try {
			CampaignMember c = [Select Id, Attempted_Registration_Date__c from CampaignMember where ContactId = :userId and (Attendee_Status__c = 'Registered' or Attendee_Status__c = 'Waiting List') and CampaignId = :events[0].c.Id];
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Our records indicate that you registered for this course on ' + c.Attempted_Registration_Date__c.Month().format() + '/' + c.Attempted_Registration_Date__c.Day().format() + '/' + c.Attempted_Registration_Date__c.year().format().replaceAll(',', '') + '. Please check your email for registration confirmation records.'));
			return null;
		}
		catch(Exception ex) {
			
		}
		PageReference p = Page.Payment;
		if(userId != null)
			p.getParameters().put('userId', userId);
		if(userName != null)
			p.getParameters().put('userName', userName);
		Set<String> eventsSet = new Set<String>();
		Set<String> sessionsSet = new Set<String>();
		for(EventClass e : events) {
			if(e.selected) {
				eventsSet.add(e.c.Id);
				for(SessionClass s : e.sessions) {
					sessionsSet.add(s.s.Id);
				}
			}
			else {
				for(SessionClass s : e.sessions) {
					if(s.selected)
						sessionsSet.add(s.s.Id);
				}
			}
		}
		String eventparm = '';
		String sessionparm = '';
		for(String s : eventsSet) {
			eventparm += (s + ',');
		}
		if(eventparm.endsWith(','))
			eventparm = eventparm.substring(0, eventparm.length() - 1);
		for(String s : sessionsSet) {
			sessionparm += (s + ',');
		}
		if(sessionparm.endsWith(','))
			sessionparm = sessionparm.substring(0, sessionparm.length() - 1);
		p.getParameters().put('events', eventparm);
		p.getParameters().put('sessions', sessionparm);
		p.setRedirect(true);
		return p;
	}
	
	public class EventClass {
		public Campaign c {get;set;}
		public Boolean selected {get;set;}
		public SessionClass[] sessions {get;set;}
		public String userId {get;set;}
		public String userName {get;set;}
		public String selectedSession {get;set;}
		public EventClass() {
			sessions = new SessionClass[0];
			selected = false;
		}
		
		public PageReference selectItem() {
			if(this.selected) {
				for(SessionClass s : this.sessions) {
					s.selected = true;
				}
			}
			return null;
		}
		
		public List<String> getBring() {
			List<String> returnList = new List<String>();
			if(c.What_to_Bring__c != null && c.What_to_Bring__c != '') {
				returnList = c.what_To_Bring__c.split(';');	
			}
			return returnList;
		}
		
		public List<String> getCost() {
			List<String> returnList = new List<String>();
			if(c.What_s_Included_in_the_Cost__c != null && c.What_s_Included_in_the_Cost__c != '') {
				returnList = c.What_s_Included_in_the_Cost__c.split(';');	
			}
			return returnList;
		}
		
		public PageReference anyRelated() {
			if(c.Only_Show_Sessions__c) {
				for(SessionClass s : this.sessions) {
					if(s.s.Id == selectedSession) {
						s.selected = true;
					}
					else {
						s.selected = false;
					}
				}
			}
			else {
				Boolean status = false;
				Boolean required = false;
				System.Debug(selectedSession);
				for(SessionClass s : this.sessions) {
					if(s.s.Id == selectedSession) {
						if(s.s.Required__c) {
							required = true;
							status = s.selected;
						}
					}
				}
				for(SessionClass s : this.sessions) {
					if(required && s.s.Required__c)
						s.selected = status;
				}
			}
			return null;
		}
		
		public PageReference sister() {
			PageReference p = Page.EventDetails;
			p.getParameters().put('eventId', c.Sister_Event__c);
			if(userId != null)
				p.getParameters().put('userId', userId);
			if(userName != null)
				p.getParameters().put('userName', userName);
			p.setRedirect(true);
			return p;
		}
		public PageReference redirect() {
			PageReference p = Page.EventDetails;
			if(userId != null)
				p.getParameters().put('userId', userId);
			if(userName != null)
				p.getParameters().put('userName', userName);
			p.getParameters().put('eventId', c.Id);
			p.setRedirect(true);
			return p;
		}
	}
	
	public class SessionClass {
		public Session__c s {get;set;}
		public Boolean selected {get;set;}
		public SessionClass() {
			selected = false;
		}
	}
	
	public EventClass getEvent() {
		return events[0];
	}
	
	public PageReference cancel() {
		PageReference p = Page.SelectEvent;
        if(userId != null)
			p.getParameters().put('userId', userId);
		if(userName != null)
			p.getParameters().put('userName', userName);
		p.setRedirect(true);
        return p;
	}
}