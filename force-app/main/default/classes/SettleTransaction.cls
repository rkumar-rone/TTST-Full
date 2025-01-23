public with sharing class SettleTransaction {
	public Campaign e {get;set;}
	public Transact[] trans {get;set;}  
	public Boolean submitted {get;set;}
	
	public SettleTransaction() {
		submitted = false;
		e = [Select Id, Name from Campaign where Id = :ApexPages.currentPage().getParameters().get('id')];
		trans = new Transact[0];
		String[] conts = new String[0];
		for(Transaction__c[] transes : [Select Id, Campaign__r.Class_Code__c, Campaign__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Amount__c, Token__c, Request_ID__c from Transaction__c where Campaign__c = :e.Id and (Status__c = 'Auth' or Status__c = 'Failed Capture') and Type__c = 'Auth']) {
			for(Transaction__c tran : transes) {
				conts.add(tran.Contact__c);
				trans.add(new Transact(tran, this));
			}
		}
		Map<Id, CampaignMember> campMembs = new Map<Id, CampaignMember>();
		for(CampaignMember[] cms : [Select Id, ContactId, Attendee_Status__c from CampaignMember where ContactId in :conts and CampaignId = :e.Id]) {
			for(CampaignMember cm : cms) {
				campMembs.put(cm.contactId, cm);
			}
		} 
		for(Transact t : trans) {
			t.cm = campMembs.get(t.t.Contact__c);
		}
	}
	public void resetTrans() {
		trans = new Transact[0];
		String[] conts = new String[0];
		for(Transaction__c[] transes : [Select Id, Campaign__r.Class_Code__c, Campaign__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Amount__c, Token__c, Request_ID__c from Transaction__c where Campaign__c = :e.Id and Status__c = 'Auth' and Type__c = 'Auth']) {
			for(Transaction__c tran : transes) {
				trans.add(new Transact(tran, this));
				conts.add(tran.Contact__c);
			}
		}
		Map<Id, CampaignMember> campMembs = new Map<Id, CampaignMember>();
		for(CampaignMember[] cms : [Select Id, ContactId, Attendee_Status__c from CampaignMember where ContactId in :conts and CampaignId = :e.Id]) {
			for(CampaignMember cm : cms) {
				campMembs.put(cm.contactId, cm);
			}
		} 
	}
	public PageReference cancel() {
		return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
	}
	
	public PageReference submit() {
		Integer i = 0;
		for(Transact t : trans) {
			if(t.selected)
				i++;	
		}
		if(i > 10) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can only process a maximum of 10 transactions at a time.'));
			return null;
		}
		else {
			Map<Id, Map<Id, CampaignMember>> campaignMemberMap = new Map<Id, Map<Id, CampaignMember>>();
			Id[] campaignIds = new Id[0];
			Id[] contactIds = new Id[0];
			for(Transact t : trans) {
				if(t.selected) {
					if(t.t.Contact__c != null && t.t.Campaign__c != null) {
						campaignIds.add(t.t.Campaign__c);
						contactIds.add(t.t.Contact__c);
					}
				}
			}
			for(CampaignMember cm : [Select Id, CampaignId, ContactId from CampaignMember where CampaignId in :campaignIds and ContactId in :contactIds]) {
				if(cm.ContactId != null && cm.CampaignId != null) {
						if(!campaignMemberMap.containsKey(cm.ContactId)) {
							campaignMemberMap.put(cm.ContactId, new Map<Id, CampaignMember>());
						}
						campaignMemberMap.get(cm.ContactId).put(cm.CampaignId, cm);
					}
			}

			CampaignMember[] toUpdate = new CampaignMember[0];
			Transaction__c[] upsertTrans = new Transaction__c[0];
			for(Transact t : trans) {
				if(t.selected) {
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
					merchantRef.addTextNode(t.t.Id);
					Dom.XMLNode clib = reqMessage.addChildElement('clientLibrary', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					clib.addTextNode('Salesforce');
					Dom.XMLNode clibv = reqMessage.addChildElement('clientLibraryVersion', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					clibv.addTextNode('22.0');
					Dom.XMLNode clibe = reqMessage.addChildElement('clientEnvironment', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					clib.addTextNode('Salesforce Server');			
					Dom.XMLNode item = reqMessage.addChildElement('item', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					item.setAttribute('id', '0');
					Dom.XMLNode unitPrice = item.addChildElement('unitPrice', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					unitPrice.addTextNode(t.t.Amount__c.format().replaceAll(',', ''));
					Dom.XMLNode quantity = item.addChildElement('quantity', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					quantity.addTextNode('1');
					Dom.XMLNode totals = reqMessage.addChildElement('purchaseTotals', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					Dom.XMLNode currencydom = totals.addChildElement('currency', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					currencydom.addTextNode('USD');
					Dom.Xmlnode merchantDefinedData = reqMessage.addChildElement('merchantDefinedData', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					Dom.Xmlnode field1 = merchantDefinedData.addChildElement('field1', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					field1.addTextNode(t.t.Campaign__r.Class_Code__c);
					Dom.XMLNode capserv = reqMessage.addChildElement('ccCaptureService', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					capserv.setAttribute('run', 'true');
					Dom.XMLNode authId = capserv.addChildElement('authRequestID', 'urn:schemas-cybersource-com:transaction-data-1.59', 'ns1');
					authId.addTextNode(t.t.Request_ID__c);
					Http h = new Http();
        			HttpRequest req = new HttpRequest();
//        			req.setEndpoint('https://ICS2WSTEST.IC3.COM/commerce/1.x/transactionProcessor');
//test
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
        			DateTime requestDateTime;
        			String reconciliationID = '';
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
        			Dom.XMLNode captureReply;
        			try {
        				captureReply = respreply.getChildElement('ccCaptureReply', 'urn:schemas-cybersource-com:transaction-data-1.59');
        			}
        			catch (Exception ex) {
        	
			        }
        			amount = DomHelpers.getFieldDecimal(capturereply, 'amount', 'urn:schemas-cybersource-com:transaction-data-1.59');
			        requestDateTime = DomHelpers.getFieldDateTime(capturereply, 'requestDateTime', 'urn:schemas-cybersource-com:transaction-data-1.59');
        			reconciliationId = DomHelpers.getFieldString(captureReply, 'reconciliationID', 'urn:schemas-cybersource-com:transaction-data-1.59');
			        Transaction__c tr = new Transaction__c(Reconciliation_ID__c = reconciliationId, Original_Transaction__c = t.t.Id, Amount__c = amount, Requested_Date_Time__c = requestDateTime, Campaign__c = t.t.Campaign__c, Contact__c = t.t.Contact__c, Currency_Code__c = currencyType, Decision__c = decision, Reason_Code__c = reasonCode, Request_ID__c = requestId, Token__c = token, Type__c = 'Capture');
			        if(reasonCode == '100') {
        				tr.status__c = 'Captured';
        				t.status = 'Accepted - ' + reasonCode;
        				t.t.Status__c = 'Captured';
					}
					else {
						t.status = 'Failed - ' + reasonCode;
						tr.status__c = 'Failed Capture';
						t.t.Status__c = 'Failed Capture';
					}
					if(t.t.Contact__c != null && t.t.Campaign__c != null && campaignMemberMap.containsKey(t.t.Contact__c) && campaignMemberMap.get(t.t.Contact__c).containsKey(t.t.Campaign__c)) {
						CampaignMember tempCm = campaignMemberMap.get(t.t.Contact__c).get(t.t.Campaign__c);
						tempCM.Transaction_Status__c = t.t.Status__c;
						toUpdate.add(tempCM);
					}
					t.newt = tr;
					upsertTrans.add(tr);
					upsertTrans.add(t.t);
				}
			}
			upsert upsertTrans;
			update toUpdate;
			submitted = true;
		}
		
		return null;
	}
	
	public class Transact {
		public Transaction__c t {get;set;}
		public Transaction__c newt {get;set;}
		public Boolean selected {get;set;}
		public String status {get;set;}
		public SettleTransaction st {get;set;}
		public CampaignMember cm {get;set;} 
		public Transact(Transaction__c t, SettleTransaction strans) {
			this.t = t;
			this.st = strans;
			status = '';
			selected = false;
		}
		
		public PageReference view() {
			return new PageReference('/' + newt.Id);
		}
		
		public PageReference del() {
			status = 'Deleted';
			t.status__c = 'Deleted';
			update t;
			st.resetTrans();
			return null;
		}
	}
}