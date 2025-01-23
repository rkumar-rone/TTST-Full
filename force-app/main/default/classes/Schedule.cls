public with sharing class Schedule {
	public String userId {get;set;}
	public String userName {get;set;}
	public Boolean loggedIn {get;set;}
	public EventClass[] events {get;set;}
	
	
	public Schedule() {
		if(ApexPages.currentPage().getParameters().containsKey('userId'))
			userId = ApexPages.currentPage().getParameters().get('userId');
		if(ApexPages.currentPage().getParameters().containsKey('userName'))
			userName = ApexPages.currentPage().getParameters().get('userName');
		events = new EventClass[0];
		Map<Id, EventClass> eventMap = new Map<Id, EventClass>();
		for(CampaignMember[] cms : [Select Campaign.Instructor__c, Campaign.Instructor__r.Name, Campaign.Cancellation_Deadline_Date__c, Attendee_Status__c, Status, Campaign.Cancellation_Deadline__c, CampaignId, Id, Campaign.What_s_Included_in_the_Cost__c, Campaign.What_to_Bring__c, Campaign.RecordType.Name, Campaign.Additional_Information__c, Campaign.View_Map__c, Campaign.Training_Location_Street__c, Campaign.Training_Location_City__c, Campaign.Training_Location_Zip_Code__c, Campaign.Cancellation_Policy__c, Campaign.Description, Campaign.RT_Description__c, Campaign.Event_Time_Zone__c, Campaign.Pre_requisites__c, Campaign.Early_Bird_Registration_Cost__c, Campaign.Partial_Course_Cost__c, Campaign.Event_Description__c, Campaign.Account__r.Name, Campaign.Id, Campaign.Online_Event_Name__c, Campaign.Name, Campaign.Sister_Event__r.StartDate, Campaign.Sister_Event__r.EndDate, Campaign.StartDate, Campaign.EndDate, Campaign.Class_Code__c, Campaign.Class_Details_Summary__c from CampaignMember where ContactId = :userId and Campaign.StartDate >= :Date.Today()]) {
			//, 
			for(CampaignMember cm : cms) {
				EventClass e = new EventClass();
				e.c = cm;
				e.userId = userId;
				e.userName = userName;
				eventMap.put(cm.CampaignId, e);
			}
		}	
		for(Registration__c[] regs : [Select Name, Id, Session__r.Event__c, Session__r.Required__c, Session__r.End_Hours__c, Session__r.End_Minutes__c, Session__r.End_AM_PM__c, Session__r.Start_AM_PM__c, Session__r.Start_Minutes__c, Session__r.Start_Hours__c, Session__r.Waiting_List_Members__c, Session__r.Id, Session__r.Instructor__c, Session__r.Instructor__r.Name, Session__r.Name, Session__r.Event__r.Instructor__c, Session__r.Event__r.Instructor__r.Name, Session__r.Session_Date__c from Registration__c where Contact__c = :userId and Session__r.Session_Date__c >= :Date.Today() order by Session__r.Session_Date__c]) {
			//, 
			for(Registration__c reg : regs) {
				if(eventMap.containsKey(reg.Session__r.Event__c)) {
					SessionClass s = new SessionClass();
					s.s = reg;
					eventMap.get(reg.Session__r.Event__c).sessions.add(s);
				}
			}	
		}
		events.addAll(eventMap.Values());	
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
	
	public class EventClass {
		public CampaignMember c {get;set;}
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
			if(c.Campaign.What_s_Included_in_the_Cost__c != null && c.Campaign.What_s_Included_in_the_Cost__c != '') {
				returnList = c.Campaign.What_s_Included_in_the_Cost__c.split(';');	
			}
			return returnList;
		}
		
		public PageReference anyRelated() {
			Boolean status = false;
			Boolean required = false;
			System.Debug(selectedSession);
			for(SessionClass s : this.sessions) {
				if(s.s.Id == selectedSession) {
					if(s.s.Session__r.Required__c) {
						required = true;
						status = s.selected;
					}
				}
			}
			for(SessionClass s : this.sessions) {
				if(required && s.s.Session__r.Required__c)
					s.selected = status;
			}
			return null;
		}
		
		public PageReference sister() {
			PageReference p = Page.EventDetails;
			p.getParameters().put('eventId', c.Campaign.Sister_Event__c);
			if(userId != null)
				p.getParameters().put('userId', userId);
			if(userName != null)
				p.getParameters().put('userName', userName);
			p.setRedirect(true);
			return p;
		}
		
		public PageReference cancel() {
			
			Transaction__c t;
			try {
				t = [Select Id, Amount__c, Token__c, Request_Id__c from Transaction__c where Campaign__c = :c.CampaignId and Contact__c = :userId and Status__c = 'Auth' limit 1];
			}
			catch (Exception ex) {
				
			}
			if(t != null && c.Campaign.Cancellation_Deadline__c >= DateTime.now()) {
				API_Settings__c api = [Select Id, Username__c, Merchant_Id__c, Token__c from API_Settings__c limit 1];
				String userName = api.Username__c;
				String merchantIdString = api.Merchant_Id__c;
				String tokenString = api.Token__c;
				Dom.Document d = new Dom.Document();
				Dom.XMLNode parent = d.createRootElement('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
				parent.setAttribute('xmlns:ns1', 'urn:schemas-cybersource-com:transaction-data-1.59');
				Dom.XMLNode envHeader = parent.addChildElement('Header', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
				envHeader.setAttribute('xmlns:wsse', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');
				Dom.XMLNode security = envHeader.addChildElement('Security', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
				security.setAttribute('SOAP-ENV:mustUnderstand', '1');
				Dom.XMLNode userNameToken = security.addChildElement('UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
				Dom.XMLNode userNameDom = userNameToken.addChildElement('Username', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
				userNameDom.addTextNode(userName);
				Dom.XMLNode password = userNameToken.addChildElement('Password', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
				password.setAttribute('Type', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wssusername-token-profile-1.0#PasswordText');
				password.addTextNode(tokenString);
				Dom.XMLNode envBody = parent.addChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
				Dom.XMLNode reqMessage = envBody.addChildElement('requestMessage', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				Dom.XMLNode merchantid = reqMessage.addChildElement('merchantID', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				merchantId.addTextNode(merchantIdString);
				Dom.XMLNode merchantRef = reqMessage.addChildElement('merchantReferenceCode', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				merchantRef.addTextNode(c.Id);
				Dom.XMLNode clib = reqMessage.addChildElement('clientLibrary', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				clib.addTextNode('Salesforce');
				Dom.XMLNode clibv = reqMessage.addChildElement('clientLibraryVersion', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				clibv.addTextNode('22.0');
				Dom.XMLNode clibe = reqMessage.addChildElement('clientEnvironment', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				clib.addTextNode('Salesforce Server');
				Dom.XMLNode item = reqMessage.addChildElement('item', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				item.setAttribute('id', '0');
				Dom.XMLNode unitPrice = item.addChildElement('unitPrice', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				unitPrice.addTextNode(t.Amount__c.format());
				Dom.XMLNode quantity = item.addChildElement('quantity', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				quantity.addTextNode('1');
				Dom.XMLNode totals = reqMessage.addChildElement('purchaseTotals', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				Dom.XMLNode currencydom = totals.addChildElement('currency', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				currencydom.addTextNode('USD');
				Dom.XMLNode capserv = reqMessage.addChildElement('ccAuthReversalService', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				capserv.setAttribute('run', 'true');
				Dom.XMLNode authId = capserv.addChildElement('authRequestID', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
				authId.addTextNode(t.Request_ID__c);
				Http h = new Http();
        		HttpRequest req = new HttpRequest();
        		req.setEndpoint('https://ics2wstest.ic3.com/commerce/1.x/transactionProcessor');
        		System.debug(d.toXMLString());
        		req.setBody(d.toXmlString());
        		req.setMethod('POST');
        		req.setHeader('content-type', 'text/xml');
        		Dom.Document resD = new Dom.Document();
        		HttpResponse resp = h.send(req);
        		resD.load(resp.getBody());
        		System.Debug(resp.getBody());
        		Dom.XMLNode root = resd.getRootElement();
        		Dom.XMLNode respbody = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        		Dom.XMLNode respreply = respbody.getChildElement('replyMessage', 'urn:schemas-cybersource-com:transaction-data-1.59');
        		String requestId = '';
        		String decision = '';
        		String reasonCode = '';
        		String token = '';
        		String currencyType = '';
        		Decimal amount;
        		DateTime requestDateTime;
        		String authorizationCode = '';
        		String processorResponse = '';
        		requestId = DomHelpers.getFieldString(respreply, 'requestID', 'urn:schemas-cybersource-com:transaction-data-1.59');
				decision = DomHelpers.getFieldString(respreply, 'decision', 'urn:schemas-cybersource-com:transaction-data-1.59');
				reasonCode = DomHelpers.getFieldString(respreply, 'reasonCode', 'urn:schemas-cybersource-com:transaction-data-1.59');
				token = DomHelpers.getFieldString(respreply, 'requestToken', 'urn:schemas-cybersource-com:transaction-data-1.59');
				try {
					Dom.XMLNode purchaseTotals = respreply.getChildElement('purchaseTotals', 'urn:schemas-cybersource-com:transaction-data-1.59');
					currencyType = DomHelpers.getFieldString(purchaseTotals, 'currency', 'urn:schemas-cybersource-com:transaction-data-1.59');
				}
				catch (Exception ex) {
		
				}
       			Dom.XMLNode reversalReply;
       			try {
      				reversalReply = respreply.getChildElement('ccAuthReversalReply', 'urn:schemas-cybersource-com:transaction-data-1.59');
       			}
       			catch (Exception ex) {
       	
		        }
       			amount = DomHelpers.getFieldDecimal(reversalReply, 'amount', 'urn:schemas-cybersource-com:transaction-data-1.59');
		        requestDateTime = DomHelpers.getFieldDateTime(reversalReply, 'requestDateTime', 'urn:schemas-cybersource-com:transaction-data-1.59');
       			authorizationCode = DomHelpers.getFieldString(reversalReply, 'authorizationCode', 'urn:schemas-cybersource-com:transaction-data-1.59');
       			processorResponse = DomHelpers.getFieldString(reversalReply, 'processorResponse', 'urn:schemas-cybersource-com:transaction-data-1.59');
			    Transaction__c tr = new Transaction__c(Processor_Response__c = processorResponse, Authorization_Code__c = authorizationCode, Original_Transaction__c = t.Id, Amount__c = amount, Requested_Date_Time__c = requestDateTime, Campaign__c = c.CampaignId, Contact__c = userId, Currency_Code__c = currencyType, Decision__c = decision, Reason_Code__c = reasonCode, Request_ID__c = requestId, Token__c = token, Type__c = 'Void Auth');
			    if(reasonCode == '100') {
        		tr.status__c = 'Auth Reversal';
        		t.Status__c = 'Auth Reversal';
				}
				else {
					tr.status__c = 'Failed Auth Reversal';
					t.Status__c = 'Failed Auth Reversal';
				}
				update t;
				insert tr;
			}
			c.Attendee_Status__c = 'Cancelled';
			c.Attempted_Cancellation_Date__c = Date.today();
			update c;
			Registration__c[] regs = new Registration__c[0];
			for(SessionClass s : this.sessions) {
				s.s.Status__c = 'Cancelled';
				regs.add(s.s);
			}
			update regs;
			PageReference p = Page.Schedule;
			if(userId != null)
				p.getParameters().put('userId', userId);
			if(userName != null)
				p.getParameters().put('userName', userName);
			p.getParameters().put('eventId', c.Id);
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
		public Registration__c s {get;set;}
		public Boolean selected {get;set;}
		public SessionClass() {
			selected = false;
		}
	}
	
	public static testMethod void testSchedule() {
		Schedule s = new Schedule();
		s.load();
		if(s.events.size() > 0) {
			s.events[0].selectItem();
			s.events[0].getBring();
			s.events[0].getCost();
			s.events[0].anyRelated();
			s.events[0].sister();
			s.events[0].cancel();
			s.events[0].redirect();
		}
	}
}