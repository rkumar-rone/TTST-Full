public with sharing class BatchRefundCaptures implements  Database.Batchable<SObject>, Database.AllowsCallouts {
	
	public BatchRefundCaptures() {
	}
	
	
	public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, Campaign.Class_Code__c, CampaignId, ContactId, Contact.FirstName, Contact.LastName from CampaignMember where  Attendee_Status__c = 'Cancelled Pending Refund']);
	}

	public void execute(Database.BatchableContext BC, List<CampaignMember> scope){
		String[] criteria = new String[0];
        Map<Id, Boolean> failMap = new Map<Id, Boolean>();
        Map<Id, Map<Id, Id>> campaignMemberMap = new Map<Id, Map<Id, Id>>();
        for(CampaignMember cm : scope) {
            criteria.add(' (Contact__c = \'' + cm.ContactId + '\' and Campaign__c = \'' + cm.CampaignId + '\' ) ');
            failMap.put(cm.Id, false);
            if(!campaignMemberMap.containsKey(cm.ContactId)) {
                campaignMemberMap.put(cm.ContactId, new Map<Id, Id>());
            }
            campaignMemberMap.get(cm.ContactId).put(cm.CampaignId, cm.Id);
        }
        String query = 'Select Id, Campaign__c, Campaign__r.Class_Code__c, Request_Id__c, Contact__c, Amount__c from Transaction__c where Status__c = \'Captured\' and (' + String.join(criteria, ' or ') + ' )';
        
        Cybersource_Settings__mdt cs = [Select Id, Username__c, Merchant_Id__c, Token__c, Endpoint__c from Cybersource_Settings__mdt where Active__c = true limit 1];
        Transaction__c[] updateTrans = Database.query(query);
        Transaction__c[] toUpsert = new Transaction__c[0];
        for(Transaction__c t : updateTrans) {
			String apiuserName = cs.Username__c; //api.Username__c;
			String merchantIdString = cs.Merchant_Id__c; //api.Merchant_Id__c;
			String tokenString = cs.Token__c; //api.Token__c;
			Dom.Document d = new Dom.Document();
			Dom.XMLNode parent = d.createRootElement('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
			parent.setAttribute('xmlns:ns1', 'urn:schemas-cybersource-com:transaction-data-1.111');
			Dom.XMLNode envHeader = parent.addChildElement('Header', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
			envHeader.setAttribute('xmlns:wsse', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');
			Dom.XMLNode security = envHeader.addChildElement('Security', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
			security.setAttribute('SOAP-ENV:mustUnderstand', '1');
			Dom.XMLNode userNameToken = security.addChildElement('UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
			Dom.XMLNode userNameDom = userNameToken.addChildElement('Username', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
			userNameDom.addTextNode(apiuserName);
			Dom.XMLNode password = userNameToken.addChildElement('Password', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'wsse');
			password.setAttribute('Type', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wssusername-token-profile-1.0#PasswordText');
			password.addTextNode(tokenString);
			Dom.XMLNode envBody = parent.addChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/', 'SOAP-ENV');
		    Dom.XMLNode reqMessage = envBody.addChildElement('requestMessage', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
			Dom.XMLNode merchantid = reqMessage.addChildElement('merchantID', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
    		merchantId.addTextNode(merchantIdString);
			Dom.XMLNode merchantRef = reqMessage.addChildElement('merchantReferenceCode', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
			merchantRef.addTextNode(campaignMemberMap.get(t.Contact__c).get(t.Campaign__c));
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
			Dom.XMLNode capserv = reqMessage.addChildElement('ccCreditService', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
			capserv.setAttribute('run', 'true');
			Dom.XMLNode authId = capserv.addChildElement('captureRequestID', 'urn:schemas-cybersource-com:transaction-data-1.111', 'ns1');
			authId.addTextNode(t.Request_ID__c);
			Http h = new Http();
   			HttpRequest req = new HttpRequest();
   			req.setEndpoint(cs.Endpoint__c);
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
    		String authorizationCode = '';
   			String processorResponse = '';
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
			Dom.XMLNode reversalReply;
    		try {
    			reversalReply = respreply.getChildElement('ccCreditServiceReply', 'urn:schemas-cybersource-com:transaction-data-1.111');
			}
			catch (Exception ex) {
	       	
	       	}
			amount = DomHelpers.getFieldDecimal(reversalReply, 'amount', 'urn:schemas-cybersource-com:transaction-data-1.111');
       		requestDateTime = DomHelpers.getFieldDateTime(reversalReply, 'requestDateTime', 'urn:schemas-cybersource-com:transaction-data-1.111');
			authorizationCode = DomHelpers.getFieldString(reversalReply, 'authorizationCode', 'urn:schemas-cybersource-com:transaction-data-1.111');
			processorResponse = DomHelpers.getFieldString(reversalReply, 'processorResponse', 'urn:schemas-cybersource-com:transaction-data-1.111');
	   		Transaction__c tr = new Transaction__c(Processor_Response__c = processorResponse, Authorization_Code__c = authorizationCode, Original_Transaction__c = t.Id, Amount__c = amount, Requested_Date_Time__c = requestDateTime, Campaign__c = t.Campaign__c, Contact__c = t.Contact__c, Currency_Code__c = currencyType, Decision__c = decision, Reason_Code__c = reasonCode, Request_ID__c = requestId, Token__c = token, Type__c = 'Credit');
	   		if(reasonCode == '100') {
    			tr.status__c = 'Refunded';
       			t.Status__c = 'Refunded';
			}
			else {
                failMap.put(campaignMemberMap.get(t.Contact__c).get(t.Campaign__c), true);
				tr.status__c = 'Failed Refund';
				t.Status__c = 'Failed Refund';
			}
			toUpsert.add(t);
			toUpsert.add(tr);
		}
		upsert toUpsert;
        for(CampaignMember cm : scope) {
            if(failMap.get(cm.Id)) {
                cm.Attendee_Status__c = 'Refund Failed';
            }
            else {
                cm.Attendee_Status__c = 'Refunded';
            }
        }
        update scope;
	}
	
	public void finish(Database.BatchableContext BC){
		
	}
		 
	 
	 public void execute(SchedulableContext ctx){
	 	BatchCaptureAuthorizations bca = new BatchCaptureAuthorizations();
	 	Database.executeBatch(bca, 100);	
	 }
	 
	 
	 
	
    
}