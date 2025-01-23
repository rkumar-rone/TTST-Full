public with sharing class SelectEvent {
	public String code {get;set;}
	public String userId {get;set;}
	public String userName {get;set;}
	public Boolean loggedIn {get;set;}
	
	public SelectEvent() {	
	}
	
	public PageReference load() {
		loggedIn = false;
		if(ApexPages.currentPage().getParameters().containsKey('userId')) {
			userId = ApexPages.currentPage().getParameters().get('userId');
			if(ApexPages.currentPage().getParameters().containsKey('userName')) {
				userName = ApexPages.currentPage().getParameters().get('userName');
				try { 
					Contact c = [Select Id from Contact where Id = :UserId and User_Id__c = :userName];
					loggedIn = true;
					if(ApexPages.currentPage().getParameters().containsKey('new'))
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your account has been created successfully.'));
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
	
	public PageReference search() {
		if(code == null || code.length() != 6) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that the code you entered is 6 characters and does not include spaces when searching for an event.'));
			return null;
		}
		Campaign c;
		try {
			System.Debug(code);
			c = [Select Id from Campaign where Class_Code__c = :code and Registration_From__c <= :dateTime.now() and Registration_To__c >= :dateTime.Now()];
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No events with this class code were found. Please enter a specific class code or click view Public Courses. Please make sure that the code you entered is 6 characters and does not include spaces when searching for an event.'));
			return null;
		}
		PageReference p = Page.EventDetails;
		p.getParameters().put('eventId', c.Id);
		if(userId != null)
			p.getParameters().put('userId', userId);
		if(userName != null)
			p.getParameters().put('userName', userName);
		return p;
	}
	
	public PageReference viewAll() {
		PageReference p = Page.EventList;
		if(userId != null)
			p.getParameters().put('userId', userId);
		if(userName != null)
			p.getParameters().put('userName', userName);
		return p;
	}
	
	public PageReference schedule() {
		PageReference p = Page.Schedule;
		if(userId != null)
			p.getParameters().put('userId', userId);
		if(userName != null)
			p.getParameters().put('userName', userName);
		return p;
	}
}