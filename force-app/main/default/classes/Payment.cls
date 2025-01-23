public class Payment {
	public String userId {get;set;}
	public String userName {get;set;}
	public Boolean loggedIn {get;set;}
	public Set<String> sessionsSet {get;set;}
	public Set<String> eventsSet {get;set;}
	public Campaign eventInfo {get;set;}
	
	public String first {get;set;}
	public String last {get;set;}
	public String street {get;set;}
	public String city {get;set;}
	public String state {get;set;}
	public String zip {get;set;}
	public String country {get;set;}
	public String email {get;set;}
	public String cardno {get;set;}
	public String expm {get;set;}
	public String expy {get;set;}
	public String cv {get;set;}
	public String phone {get;set;}
	public Decimal total {get;set;}
	public String couponCode {get;set;}
	public Boolean waitlist {get;set;}
	public Boolean waitlist2 {get;set;}
	public Campaign event {get;set;}
	public Session__c[] sessions {get;set;}
	public Contact c {get;set;}
	public CurrencyType ct {get;set;}
	
	
	public PageReference load() {
		sessions = new Session__c[0];
		loggedIn = false;
		waitlist = false;
		waitlist2 = false;
		if(ApexPages.currentPage().getParameters().containsKey('userId')) {
			userId = ApexPages.currentPage().getParameters().get('userId');
			if(ApexPages.currentPage().getParameters().containsKey('userName')) {
				userName = ApexPages.currentPage().getParameters().get('userName');
				try { 
					c = [Select Id, Email, LastName, FirstName from Contact where Id = :UserId and User_Id__c = :userName];
					loggedIn = true;
					email = c.Email;
					last = c.LastName;
					first = c.firstName;
					sessionsSet = new Set<String>();
					eventsSet = new Set<String>(); 
					if(ApexPages.currentPage().getParameters().containsKey('sessions') && ApexPages.currentPage().getParameters().get('sessions') != '')
						sessionsSet.addAll(ApexPages.currentPage().getParameters().get('sessions').split(','));
					if(ApexPages.currentPage().getParameters().containsKey('events') && ApexPages.currentPage().getParameters().get('events') != '')
						eventsSet.addAll(ApexPages.currentPage().getParameters().get('events').split(','));
					sessions = new Session__c[0];
					c = [Select Id, FirstName, LastName, Email from Contact where Id = :UserId and User_Id__c = :userName];
					try {
						sessions = [Select  Waiting_List_Members__c, Event__r.Description, Event__R.Cancellation_fee__c, Event__r.No_show_fee__c, Event__r.What_to_Bring__c, Session_Content__c, Event__r.Cancellation_Policy__c, Id, Number_Registered__c, Seats_Available__c,  Event__c, Name, Session_Date__c, Start_Hours__c, Start_Minutes__c, Start_AM_PM__c, End_Hours__c, End_Minutes__c, End_AM_PM__c from Session__c where Id in :sessionsSet];
						eventInfo = [Select Class_Code__c, Wait_List_Members__c, CurrencyIsoCode, Training_Location_City__c, Training_Location_Zip_Code__c, Training_Location_Street__c, Training_Location_State__c, View_map__c, What_to_Bring__c, Cancellation_Policy__c, Id, Cancellation_fee__c, No_Show_Fee__c, Total_Class_Cost__c, Registered__c, Name,  Online_Event_Name__c, RT_Description__c, Seats_Available__c, Description, Event_Description__c, Event_Time_Zone__c, StartDate, EndDate, Early_Bird_Deadline__c, Early_Bird_Registration_Cost__c, Full_Registration_Cost__c, Partial_Course_Cost__c, Total_Sessions__c, Coupon_1_Expiration__c, Coupon_2_Expiration__c, Coupon_3_Expiration__c, Coupon_4_Expiration__c, Coupon_Code_1__c, Coupon_Code_2__c, Coupon_Code_3__c, Coupon_Code_4__c, Discount_Type_1__c, Discount_Type_2__c, Discount_Type_3__c, Discount_Type_4__c, Discount_Value_1__c, Discount_Value_2__c, Discount_Value_3__c, Discount_Value_4__c from Campaign where Id = :sessions[0].Event__c];
					}
					catch (Exception ex) {
						sessions = new Session__c[0];
					}
					if(eventsSet.size() == 0) {
						try {
							event = [Select Class_Code__c, Wait_List_Members__c, CurrencyIsoCode, Training_Location_City__c, Training_Location_Zip_Code__c, Training_Location_Street__c, Training_Location_State__c, View_map__c, What_to_Bring__c, Cancellation_Policy__c, Id, Cancellation_fee__c, No_Show_Fee__c, Total_Class_Cost__c, Registered__c, Name,  Online_Event_Name__c, RT_Description__c, Seats_Available__c, Description, Event_Description__c, Event_Time_Zone__c, StartDate, EndDate, Early_Bird_Deadline__c, Early_Bird_Registration_Cost__c, Full_Registration_Cost__c, Partial_Course_Cost__c, Total_Sessions__c, Coupon_1_Expiration__c, Coupon_2_Expiration__c, Coupon_3_Expiration__c, Coupon_4_Expiration__c, Coupon_Code_1__c, Coupon_Code_2__c, Coupon_Code_3__c, Coupon_Code_4__c, Discount_Type_1__c, Discount_Type_2__c, Discount_Type_3__c, Discount_Type_4__c, Discount_Value_1__c, Discount_Value_2__c, Discount_Value_3__c, Discount_Value_4__c from Campaign where Id = :sessions[0].Event__c];
							eventInfo = event;
							
						}
						catch (Exception ex) {
							
						}
					}
					else {
						try {
							event = [Select Class_Code__c, Online_Event_Name__c, Wait_List_Members__c, CurrencyIsoCode, Training_Location_City__c, Training_Location_Zip_Code__c, Training_Location_Street__c, Training_Location_State__c, View_Map__C, What_to_Bring__c, Cancellation_Policy__c, Id, Cancellation_fee__c, No_show_fee__c, Total_Class_Cost__c, Registered__c, Name, Seats_Available__c, Description, Event_Description__c, Event_Time_Zone__c, StartDate, EndDate, Early_Bird_Deadline__c, Early_Bird_Registration_Cost__c, Full_Registration_Cost__c, Partial_Course_Cost__c, Total_Sessions__c, Coupon_1_Expiration__c, Coupon_2_Expiration__c, Coupon_3_Expiration__c, Coupon_4_Expiration__c, Coupon_Code_1__c, Coupon_Code_2__c, Coupon_Code_3__c, Coupon_Code_4__c, Discount_Type_1__c, Discount_Type_2__c, Discount_Type_3__c, Discount_Type_4__c, Discount_Value_1__c, Discount_Value_2__c, Discount_Value_3__c, Discount_Value_4__c from Campaign where Id in :eventsSet];
						}
						catch (Exception ex) {
							
						}	
					}
					ct = [Select IsoCode, ConversionRate from CurrencyType Where IsoCode = :event.CurrencyIsoCode];
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
		for(Session__c s : sessions) {
			if(s.Number_Registered__c >= s.Seats_Available__c)
				waitlist = true;
		}
		if(event == null || (event.Registered__c == null ? 0 : event.Registered__c) >= (event.Seats_Available__c == null ? 0 : event.Seats_Available__c))
			waitlist = true;
		return null;
	}
	
	public PageReference submitPayment() {
		/*if(waitlist && !waitlist2) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'One or more of the registered events are waitlisted - please hit submit again if you wish to be registered to the waitlist.'));
				waitlist2 = true;
				return null;
		}*/
		String sessNames = '';
		String positions = '';
		if(getCost() > 0 || getNoShowCancel()) {
			if(first == null || first == '' || last == null || last == '' || street == null || street == '' || city == null || city == '' ||  zip == null || zip == '' || country == null || country == '' || phone == null || phone == '' || cardno == null || cardno == '' || expm == null || expm == '' || expy == null || expy == '' || cv == null || cv == '') {
				//state == null || state == '' ||
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'All fields are required. Please check and resubmit.'));
				return null;
			}
			if(state == null) 
				state = '';
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
			merchantRef.addTextNode(event.Id + '-' + c.Id);
			Dom.XMLNode clib = reqMessage.addChildElement('clientLibrary', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			clib.addTextNode('Salesforce');
			Dom.XMLNode clibv = reqMessage.addChildElement('clientLibraryVersion', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			clibv.addTextNode('22.0');
			Dom.XMLNode clibe = reqMessage.addChildElement('clientEnvironment', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			clib.addTextNode('Salesforce Server');
			Dom.XMLNode billTo = reqMessage.addChildElement('billTo', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			Dom.XMLNode firstName = billTo.addChildElement('firstName', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			firstName.addTextNode(first);
			Dom.XMLNode lastName = billTo.addChildElement('lastName', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			lastName.addTextNode(last);
			Dom.XMLNode street1 = billTo.addChildElement('street1', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			street1.addTextNode(street);
			Dom.XMLNode citydom = billTo.addChildElement('city', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			citydom.addTextNode(city);
			Dom.XMLNode statedom = billTo.addChildElement('state', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			statedom.addTextNode(state);
			Dom.XMLNode zipdom = billTo.addChildElement('postalCode', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			zipdom.addTextNode(zip);
			Dom.XMLNode countrydom = billTo.addChildElement('country', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			countrydom.addTextNode(country);
			Dom.XMLNode emaildom = billTo.addChildElement('email', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			emaildom.addTextNode(email);
			Dom.XMLNode ipAdd = billTo.addChildElement('ipAddress', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			ipAdd.addTextNode(ApexPages.CurrentPage().getHeaders().get('x-Salesforce-SIP'));
			Dom.XMLNode item = reqMessage.addChildElement('item', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			item.setAttribute('id', '0');
			//Decimal billedCost = getCost();
			Decimal billedCost = getMax();
			if(ct.IsoCode != 'USD')
				billedCost = ((1/ct.ConversionRate) * billedCost).setScale(2);
			Dom.XMLNode unitPrice = item.addChildElement('unitPrice', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			if(getCost() <= 0 && getMax() <= 0)
				unitPrice.addTextNode('0');
			else
				unitPrice.addTextNode(billedcost.format().replaceAll(',', ''));
			Dom.XMLNode quantity = item.addChildElement('quantity', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			quantity.addTextNode('1');
			Dom.XMLNode totals = reqMessage.addChildElement('purchaseTotals', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			Dom.XMLNode currencydom = totals.addChildElement('currency', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			currencydom.addTextNode('USD');
			Dom.XMLNode card = reqMessage.addChildElement('card', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			Dom.XMLNode accno = card.addChildElement('accountNumber', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			accno.addTextNode(cardno);
			Dom.XMLNode expmo = card.addChildElement('expirationMonth', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			expmo.addTextNode(expm);
			Dom.XMLNode expyear = card.addChildElement('expirationYear', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			expyear.addTextNode(expy);
			Dom.XMLNode cvdom = card.addChildElement('cvNumber', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			cvdom.addTextNode(cv);
			Dom.Xmlnode merchantDefinedData = reqMessage.addChildElement('merchantDefinedData', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			Dom.Xmlnode field1 = merchantDefinedData.addChildElement('field1', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			field1.addTextNode(event.Class_Code__c);
			Dom.XMLNode auth = reqMessage.addChildElement('ccAuthService', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
			auth.setAttribute('run', 'true');
			Http h = new Http();
        	HttpRequest req = new HttpRequest();
//        	req.setEndpoint('https://ICS2WSTEST.IC3.COM/commerce/1.x/transactionProcessor');
//testing
	       	req.setEndpoint('https://ics2ws.ic3.com/commerce/1.x/transactionProcessor');
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
        	String authorizationCode = '';
        	String avsCode = '';
        	String avsCodeRaw = '';
	        DateTime authorizedDateTime;
        	String processorResponse = '';
        	String authFactor = '';
	        String adviceCode = '';
        	String adviceCodeRaw = '';
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
        	Dom.XMLNode authreply;
        	try {
	        	authReply = respreply.getChildElement('ccAuthReply', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	}
        	catch (Exception ex) {
	        	
        	}
        	amount = DomHelpers.getFieldDecimal(authreply, 'amount', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	authorizationCode = DomHelpers.getFieldString(authreply, 'authorizationCode', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	avsCode = DomHelpers.getFieldString(authreply, 'avsCode', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	avsCodeRaw = DomHelpers.getFieldString(authreply, 'avsCodeRaw', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	authorizedDateTime = DomHelpers.getFieldDateTime(authreply, 'authorizedDateTime', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	processorResponse = DomHelpers.getFieldString(authreply, 'processorResponse', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	authFactor = DomHelpers.getFieldString(authreply, 'authFactorCode', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	adviceCode = DomHelpers.getFieldString(authreply, 'merchantAdviceCode', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	adviceCodeRaw = DomHelpers.getFieldString(authreply, 'merchantAdviceCodeRaw', 'urn:schemas-cybersource-com:transaction-data-1.59');
        	Transaction__c t = new Transaction__c(Amount__c = amount, Auth_Factor_Code__c = authFactor, Authorization_Code__c = authorizationCode, Authorized_Date_Time__c = authorizedDateTime, AVS_Code__c = avsCode, AVS_Code_Raw__c = avsCodeRaw, Campaign__c = event.Id, Contact__c = c.Id, Currency_Code__c = currencyType, Decision__c = decision, Merchant_Advice_Code__c = adviceCode, Merchant_Advice_Code_Raw__c = adviceCodeRaw, Processor_Response__c = processorResponse, Reason_Code__c = reasonCode, Request_ID__c = requestId, Token__c = token, Type__c = 'Auth');
        	if(reasonCode == '100') {
	        	t.Status__c = 'Auth';
        		insert t;
        		c.Cardholder_First_Name__c = first;
        		c.Cardholder_Last_Name__c = last;
        		c.Cardholder_Phone__c = phone;
        		c.OtherCity = city;
        		c.OtherState = state;
        		c.OtherPostalCode = zip;
        		c.OtherStreet = street;
        		update c;
        		Registration__c[] toinsert = new Registration__c[0];
        		Integer numReg = 0;
        		Boolean waiting = false;
        		for(Session__c s : sessions) {
	        		numreg++;
	        		Registration__c tempReg;
	        		try {
	        			tempReg = [Select Id from Registration__c where Contact__c = :c.Id and Session__c = :s.Id];
	        			tempreg.Cancellation_Policy__c = s.Event__r.Cancellation_Policy__c;
	        			tempreg.Coupon_Code__c = couponCode;
	        			tempreg.Session_Content__c = s.Session_Content__c;
	        			tempreg.Status__c = 'Registered';
	        			tempreg.What_to_Bring__c = s.Event__r.What_to_Bring__c;
	        		}
	        		catch (Exception ex) {
	        			tempReg = new Registration__c(Cancellation_Policy__c = s.Event__r.Cancellation_Policy__c,Contact__c = c.Id, Coupon_Code__c = couponCode, Session__c = s.Id, Session_Content__c = s.Session_Content__c, Status__c = 'Registered', What_to_Bring__c = s.Event__r.What_to_Bring__c);
	        		}
        			if(event.View_Map__c == null || event.View_Map__c == '')
        				tempReg.View_Map__c = 'http://www.google.com/maps?hl=en&safe=off&q=' + event.Training_Location_Street__c + ',' + event.Training_Location_City__c + ',' + event.Training_Location_State__c + ',' + event.Training_Location_Zip_Code__c + '&aq=f&aqi=&aql=&oq=&pbx=1&bav=on.2,or.r_gc.r_pw.&fp=a445e974b90b3339';
        			else
        				tempReg.View_Map__c = event.View_Map__c;
        			if(s.Seats_Available__c <= s.Number_Registered__c) {
	        			tempReg.Waiting_List_Ranking__c = s.Waiting_List_Members__c + 1;
        				tempReg.Waiting_List__c = true;
        				tempReg.Status__c = 'Waiting List';
        				waiting = true;
        				positions += tempReg.Waiting_List_Ranking__c.format() + ',';
        				sessNames += s.Name + ',';
        			}
        			toInsert.add(tempReg);
        		}
        		
        		CampaignMember cm;
        		try {
        			cm = [Select Id from CampaignMember where CampaignId = :event.Id and ContactId = :c.Id];
        			 cm.Attempted_Registration_Date__c = DateTime.now();
        			 cm.Attendee_Status__c = 'Registered';
        			 cm.Course_Cost__c = getTotal();
        			 cm.Discount__c = getDiscount(getTotal());
        			 cm.Sessions_Registered__c = numReg;
        			 cm.Description__c = event.Description;
        			 cm.Cancellation_Policy__c = event.Cancellation_Policy__c;
        			 cm.What_to_Bring__c = event.What_to_Bring__c;
        		}
        		catch (Exception ex) {
        			cm = new CampaignMember(CurrencyIsoCode = event.CurrencyISOCode, CampaignId = event.Id, ContactId = c.Id, Attempted_Registration_Date__c = DateTime.now(), Attendee_Status__c = 'Registered', Course_Cost__c = getTotal(), Discount__c = getDiscount(getTotal()), Sessions_Registered__c = numReg, Description__c = event.Description, Cancellation_Policy__c = event.Cancellation_Policy__c, What_to_Bring__c = event.What_to_Bring__c);
        		}
        		
        		if(event.Seats_Available__c <= event.Wait_List_Members__c || waiting) {
	        		cm.Date_Added_to_Wait_List__c = Date.today();
        			cm.Attendee_Status__c = 'Waiting List';
        		}
        		if(event.View_Map__c == null || event.View_Map__c == '')
        			cm.View_Map__c = 'http://www.google.com/maps?hl=en&safe=off&q=' + event.Training_Location_Street__c + ',' + event.Training_Location_City__c + ',' + event.Training_Location_State__c + ',' + event.Training_Location_Zip_Code__c + '&aq=f&aqi=&aql=&oq=&pbx=1&bav=on.2,or.r_gc.r_pw.&fp=a445e974b90b3339';
        		else
        			cm.View_Map__c = event.View_Map__c;
        		cm.CC_Last_4_Digits__c = (cardno == null || cardno == '' ? '' : cardno.substring(cardno.length() - 4)); 
        		upsert cm;
        		cm = [Select Final_Cost__c, CurrencyISOCode from CampaignMember where Id = :cm.Id];
        		for(Registration__c r : toInsert) {
        			r.Final_Cost__c = cm.Final_Cost__c;
        			r.CurrencyISOCode = cm.CurrencyISOCode;
        			r.CC_Last_4_Digits__c = (cardno == null || cardno == '' ? '' : cardno.substring(cardno.length() - 4));
        		}
        		upsert toInsert;
        		PageReference p = Page.ThankYou;
        		if(sessNames != '')
        			p.getParameters().put('sessName', sessNames);
				if(positions != '')
					p.getParameters().put('pos', positions);
        		if(userId != null)
					p.getParameters().put('userId', userId);
				if(userName != null)
					p.getParameters().put('userName', userName);
					
				p.setRedirect(true);
        		return p;
	        }
    	    else {
        		t.Status__c = 'Failed Auth';
        		insert t;
        		if(reasonCode == '101') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One or more required fields are missing.'));
        		}
        		else if(reasonCode == '102') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One or more fields contains invalid data.'));
        		}
        		else if(reasonCode == '202') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This card is expired. Please try another card.'));
    	    	}
        		else if(reasonCode == '203') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This transaction was declined. Please try another card.'));
        		}
        		else if(reasonCode == '204') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient funds. Please try another card.'));
        		}
        		else if(reasonCode == '208') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Inactive card or card not authorized for internet transactions. Please try another card.'));
        		}
        		else if(reasonCode == '209') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CV Code does not match.'));
        		}
        		else if(reasonCode == '210') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Card has reached credit limit. Please try another card.'));
        		}
        		else if(reasonCode == '211') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CV Code does not match.'));
        		}
        		else if(reasonCode == '231') {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid card number.'));
    	    	}
        		else {
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error processing your card. Please contact Training the Street for more information.'));
        		}
        		return null;
        	}
		}
		else {
			Registration__c[] toinsert = new Registration__c[0];
        	Integer numReg = 0;
        	for(Session__c s : sessions) {
	        	numreg++;
        		Registration__c tempReg = new Registration__c(Cancellation_Policy__c = s.Event__r.Cancellation_Policy__c,Contact__c = c.Id, Coupon_Code__c = couponCode, Session__c = s.Id, Session_Content__c = s.Session_Content__c, Status__c = 'Registered', What_to_Bring__c = s.Event__r.What_to_Bring__c );
        		if(s.Seats_Available__c <= s.Number_Registered__c) {
	        		tempReg.Waiting_List_Ranking__c = s.Waiting_List_Members__c + 1;
        			tempReg.Waiting_List__c = true;
        			tempReg.Status__c = 'Waiting List';
        			positions += tempReg.Waiting_List_Ranking__c.format() + ',';
        			sessNames += s.Name + ',';
        		}
        		toInsert.add(tempReg);
        	}
        	if(event != null) {
        		CampaignMember cm = new CampaignMember(CurrencyIsoCode = event.CurrencyISOCode, CampaignId = event.Id, ContactId = c.Id, Attempted_Registration_Date__c = DateTime.now(), Attendee_Status__c = 'Registered', Course_Cost__c = getTotal(), Discount__c = getDiscount(getTotal()), Sessions_Registered__c = numReg);
        		if(event.Seats_Available__c <= event.Wait_List_Members__c) {
	        		cm.Date_Added_to_Wait_List__c = Date.today();
        			cm.Attendee_Status__c = 'Waiting List';
        		}
        		insert cm;
        		insert toInsert;
        	}
        	PageReference p = Page.ThankYou;
        	if(sessNames != '')
        		p.getParameters().put('sessName', sessNames);
			if(positions != '')
				p.getParameters().put('pos', positions);
        	if(userId != null)
				p.getParameters().put('userId', userId);
			if(userName != null)
				p.getParameters().put('userName', userName);
			p.setRedirect(true);
        	return p;
		}
		return null;	
	}
	
	public Decimal getDiscount(Decimal total) {
		Decimal multiplier = (sessions.size() == 0 ? 1 : sessions.size());
		Decimal discount = 0;
		if(event != null && event.Coupon_Code_1__c != '' && event.Coupon_Code_1__c != null && couponCode == event.Coupon_Code_1__c && (event.Coupon_1_Expiration__c == null || Date.today() < event.Coupon_1_Expiration__c))
			if(event.Discount_Type_1__c == '%')
				discount = (total * (event.Discount_Value_1__c / 100));
			else
				discount = event.Discount_Value_1__c * multiplier;
		else if(event != null && event.Coupon_Code_2__c != '' && event.Coupon_Code_2__c != null &&couponCode == event.Coupon_Code_2__c && (event.Coupon_2_Expiration__c == null || Date.today() < event.Coupon_2_Expiration__c))
			if(event.Discount_Type_2__c == '%')
				discount = (total * (event.Discount_Value_2__c / 100));
			else
				discount = event.Discount_Value_2__c  * multiplier;
		else if(event != null && event.Coupon_Code_3__c != '' && event.Coupon_Code_3__c != null && couponCode == event.Coupon_Code_3__c && (event.Coupon_3_Expiration__c == null || Date.today() < event.Coupon_3_Expiration__c))
			if(event.Discount_Type_3__c == '%')
				discount = (total * (event.Discount_Value_3__c / 100));
			else
				discount = event.Discount_Value_3__c  * multiplier;
		else if(event != null && event.Coupon_Code_4__c != '' && event.Coupon_Code_4__c != null && couponCode == event.Coupon_Code_4__c && (event.Coupon_4_Expiration__c == null || Date.today() < event.Coupon_4_Expiration__c))
			if(event.Discount_Type_4__c == '%')
				discount = (total * (event.Discount_Value_4__c / 100));
			else
				discount = event.Discount_Value_4__c  * multiplier;
		return discount;
	}
	
	public Decimal getCost() {
		Decimal total = getTotal();
		if(total == null)
			total = 0;
		total -= (getDiscount(total) == null ? 0 : getDiscount(total));
		if(total < 0)
			total = 0;
		return total;
	}
	
	public Decimal getMax() {
		Decimal max = 0;
		if(getCost() > max)
			max = getCost();
		if(eventInfo.No_Show_Fee__c != null && eventInfo.No_Show_Fee__c > max)
			max = eventInfo.No_Show_Fee__c;
		if(eventInfo.Cancellation_Fee__c != null && eventInfo.Cancellation_Fee__c > max)
			max = eventInfo.Cancellation_Fee__c;
		return max;
	}
	
	public Decimal getTotal() {
		Decimal total = 0.00;
		System.Debug('Sessions - ' + sessions.size());
		if(event != null && sessions.size() == event.Total_Sessions__c && event.Early_Bird_Deadline__c >= Date.today()) {
			total = event.Early_Bird_Registration_Cost__c;
			System.Debug('early bird');
		} 
		else if(event != null && sessions.size() == event.Total_Sessions__c && (event.Early_Bird_Deadline__c < Date.today() || event.Early_Bird_Deadline__c == null)) {
			total = event.Full_Registration_Cost__c;
			System.Debug('total');
		} 	
		else if(event != null){
			total = ((event.Partial_Course_Cost__c / event.Total_Sessions__c) * sessions.size());
			System.Debug('calced');
		}
		return total;
	}
	
	public PageReference ApplyCoupon() {
		if(event != null && event.Coupon_Code_1__c != '' && event.Coupon_Code_1__c != null && couponCode == event.Coupon_Code_1__c) {
			if(event.Coupon_1_Expiration__c != null && Date.today() > event.Coupon_1_Expiration__c) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This coupon code has expired.'));
			}
		}
		else if(event != null && event.Coupon_Code_2__c != '' && event.Coupon_Code_2__c != null && couponCode == event.Coupon_Code_2__c) {
			if(event.Coupon_2_Expiration__c != null && Date.today() > event.Coupon_2_Expiration__c) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This coupon code has expired.'));
			}
		}
		else if(event != null && event.Coupon_Code_3__c != '' && event.Coupon_Code_2__c != null && couponCode == event.Coupon_Code_3__c) {
			if(event.Coupon_3_Expiration__c != null && Date.today() > event.Coupon_3_Expiration__c) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This coupon code has expired.'));
			}
		}
		else if(event != null && event.Coupon_Code_4__c != '' && event.Coupon_Code_4__c != null && couponCode == event.Coupon_Code_4__c) {
			if(event.Coupon_4_Expiration__c != null && Date.today() > event.Coupon_4_Expiration__c) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This coupon code has expired.'));
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This coupon code is not valid.'));
		}
		return null;
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
	
	public Boolean getNoShowCancel() {
		if(event != null && ((event.Cancellation_fee__c != null && event.Cancellation_fee__c > 0) || (event.no_Show_Fee__c != null && event.No_Show_Fee__c > 0)))
			return true;
		return false;
	}
	
	public static testMethod void testPayment() {
		Payment p = new Payment();
		p.load();
		p.applyCoupon();
		p.cancel();
		p.getCost();
		p.getDiscount(p.getCost());
		p.getNoShowCancel();
		p.submitPayment();
	}

}