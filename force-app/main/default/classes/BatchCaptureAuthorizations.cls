public with sharing class BatchCaptureAuthorizations implements  Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
	public final Date d;
	
	public BatchCaptureAuthorizations(Date d) {
		this.d = d;
	}
	
	public BatchCaptureAuthorizations() {
		this.d = Date.today();
	}
	
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([Select Id, Campaign__r.Class_Code__c, Campaign__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Amount__c, Token__c, Request_ID__c from Transaction__c where  (Status__c = 'Auth' or Status__c = 'Failed Capture') and Type__c = 'Auth' and Campaign__r.Billing_Date__c <= :d and CreatedDate >= :DateTime.newInstance(2019, 5, 16, 0, 0, 0 	) and Amount__c != null]);
	}

	public void execute(Database.BatchableContext BC, List<Transaction__c> scope){
		Id[] campaignIds = new Id[0];
		Id[] contactIds = new Id[0];
		for(Transaction__c t : scope) {
			if(t.Campaign__c != null) {
				campaignIds.add(t.Campaign__c);
			}
			if(t.Contact__c != null) {
				contactIds.add(t.Contact__c);
			}
		}
		Map<Id, Map<Id, CampaignMember>> campaignMemberMap = new Map<Id, Map<Id, CampaignMember>>();
		for(CampaignMember c : [Select Id, Attendee_Status__c, ContactId, CampaignId from CampaignMember where ContactId in :contactIds and CampaignId in :campaignIds]) {
			if(!campaignMemberMap.containsKey(c.ContactId)) {
				campaignMemberMap.put(c.ContactId, new Map<Id, CampaignMember>());
			}
			campaignMemberMap.get(c.ContactId).put(c.CampaignId, c);
		}
		CampaignMember[] toUpdate = new CampaignMember[0];
		

		Transaction__c[] upsertTrans = new Transaction__c[0];
		Cybersource_Settings__mdt cs = [Select Id, Username__c, Merchant_Id__c, Token__c, Endpoint__c from Cybersource_Settings__mdt where Active__c = true  limit 1];
		String userName = cs.Username__c; //api.Username__c;
		String merchantIdString = cs.Merchant_Id__c; //api.Merchant_Id__c;
		String tokenString = cs.Token__c; //api.Token__c;
		for(Transaction__c t : scope) {
			if(campaignMemberMap.containsKey(t.Contact__c) && campaignMemberMap.get(t.Contact__c).containsKey(t.Campaign__c) && campaignMemberMap.get(t.Contact__c).get(t.Campaign__c).Attendee_Status__c == 'Registered') {
				//API_Settings__c api = [Select Id, Username__c, Merchant_Id__c, Token__c from API_Settings__c limit 1];
				/*String userName = api.Username__c;
				String merchantIdString = api.Merchant_Id__c;
				String tokenString = api.Token__c;*/
				Dom.Document d = new Dom.Document();
				Dom.XMLNode parent = d.createRootElement('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
				parent.setAttribute('xmlns:ns1', 'urn:schemas-cybersource-com:transaction-data-1.111');
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
				Dom.XMLNode reqMessage = envBody.addChildElement('requestMessage', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				Dom.XMLNode merchantid = reqMessage.addChildElement('merchantID', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				merchantId.addTextNode(merchantIdString);
				Dom.XMLNode merchantRef = reqMessage.addChildElement('merchantReferenceCode', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				merchantRef.addTextNode(t.Id);
				Dom.XMLNode clib = reqMessage.addChildElement('clientLibrary', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				clib.addTextNode('Salesforce');
				Dom.XMLNode clibv = reqMessage.addChildElement('clientLibraryVersion', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				clibv.addTextNode('22.0');
				Dom.XMLNode clibe = reqMessage.addChildElement('clientEnvironment', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				clib.addTextNode('Salesforce Server');			
				Dom.XMLNode item = reqMessage.addChildElement('item', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				item.setAttribute('id', '0');
				Dom.XMLNode unitPrice = item.addChildElement('unitPrice', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				unitPrice.addTextNode(t.Amount__c.format().replaceAll(',', ''));
				Dom.XMLNode quantity = item.addChildElement('quantity', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				quantity.addTextNode('1');
				Dom.XMLNode totals = reqMessage.addChildElement('purchaseTotals', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				Dom.XMLNode currencydom = totals.addChildElement('currency', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				currencydom.addTextNode('USD');
				Dom.Xmlnode merchantDefinedData = reqMessage.addChildElement('merchantDefinedData', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				Dom.Xmlnode field1 = merchantDefinedData.addChildElement('mddField', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				field1.setAttribute('id', '1');
				field1.addTextNode(t.Campaign__r.Class_Code__c);
				Dom.XMLNode capserv = reqMessage.addChildElement('ccCaptureService', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				capserv.setAttribute('run', 'true');
				Dom.XMLNode authId = capserv.addChildElement('authRequestID', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
				authId.addTextNode(t.Request_ID__c);
				Http h = new Http();
        		HttpRequest req = new HttpRequest();
				req.setEndpoint(cs.Endpoint__c); //'https://ICS2WSTEST.IC3.COM/commerce/1.x/transactionProcessor');
				//test
        		//req.setEndpoint('https://ics2ws.ic3.com/commerce/1.x/transactionProcessor');
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
        		Dom.XMLNode respreply = respbody.getChildElement('replyMessage', 'urn:schemas-cybersource-com:transaction-data-1.111');
        		String requestId = '';
        		String decision = '';
        		String reasonCode = '';
        		String token = '';
        		String currencyType = '';
        		Decimal amount;
        		DateTime requestDateTime;
        		String reconciliationID = '';
        		requestId = DomHelpers.getFieldString(respreply, 'requestID', 'urn:schemas-cybersource-com:transaction-data-1.111');
				decision = DomHelpers.getFieldString(respreply, 'decision', 'urn:schemas-cybersource-com:transaction-data-1.111');
				reasonCode = DomHelpers.getFieldString(respreply, 'reasonCode', 'urn:schemas-cybersource-com:transaction-data-1.111');
				token = DomHelpers.getFieldString(respreply, 'requestToken', 'urn:schemas-cybersource-com:transaction-data-1.111');
				try {
					Dom.XMLNode purchaseTotals = respreply.getChildElement('purchaseTotals', 'urn:schemas-cybersource-com:transaction-data-1.111');
					currencyType = DomHelpers.getFieldString(purchaseTotals, 'currency', 'urn:schemas-cybersource-com:transaction-data-1.111');
				}
				catch (Exception ex) {
				}
        		Dom.XMLNode captureReply;
        		try {
		        	captureReply = respreply.getChildElement('ccCaptureReply', 'urn:schemas-cybersource-com:transaction-data-1.111');
        		}
        		catch (Exception ex) {
        		}
	        	amount = DomHelpers.getFieldDecimal(capturereply, 'amount', 'urn:schemas-cybersource-com:transaction-data-1.111');
				requestDateTime = DomHelpers.getFieldDateTime(capturereply, 'requestDateTime', 'urn:schemas-cybersource-com:transaction-data-1.111');
        		reconciliationId = DomHelpers.getFieldString(captureReply, 'reconciliationID', 'urn:schemas-cybersource-com:transaction-data-1.111');
				Transaction__c tr = new Transaction__c(Reconciliation_ID__c = reconciliationId, Original_Transaction__c = t.Id, Amount__c = amount, Requested_Date_Time__c = requestDateTime, Campaign__c = t.Campaign__c, Contact__c = t.Contact__c, Currency_Code__c = currencyType, Decision__c = decision, Reason_Code__c = reasonCode, Request_ID__c = requestId, Token__c = token, Type__c = 'Capture');
        		if(reasonCode == '100') {
					tr.status__c = 'Captured';
					t.Status__c = 'Captured';
				}
				else {
					tr.status__c = 'Failed Capture';
					t.Status__c = 'Failed Capture';
				}
				if(t.Contact__c != null && campaignMemberMap.containsKey(t.Contact__c) && t.Campaign__c != null && campaignMemberMap.get(t.Contact__c).containsKey(t.Campaign__c)) {
					CampaignMember tempCM = campaignMemberMap.get(t.Contact__c).get(t.Campaign__c);
					tempCM.Transaction_Status__c = t.Status__c;
					toUpdate.add(tempCM);
				}
				upsertTrans.add(tr);
				upsertTrans.add(t);
			}
		}
		upsert upsertTrans;
		update toUpdate;
	}
	
	public void finish(Database.BatchableContext BC){
		BatchRefundCaptures brc = new BatchRefundCaptures();
		Database.executeBatch(brc, 100);
	}
		 
	 
	 public void execute(SchedulableContext ctx){
	 	BatchCaptureAuthorizations bca = new BatchCaptureAuthorizations();
	 	Database.executeBatch(bca, 100);	
	 }
	 
	 
	 
	
    
}