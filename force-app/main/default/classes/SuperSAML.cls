public without sharing class SuperSAML {
    public static String genrateSAMLAssertion(String username, String assertionId) {
    	Contact c = [Select Id, Email from Contact where User_Id__c = :username.toLowerCase()];
    	Identity_Provider_Configuration__mdt ipc = [Select Id, Audience__c, Certificate__c, Certificate_Developer_Name__c, Destination__c, Entity_Id__c, Service_URL__c from Identity_Provider_Configuration__mdt where Active__c = true limit 1];
    	String certificate = ipc.Certificate__c;
    	String destination = ipc.Destination__c;
		String audience = ipc.Audience__c;
    	String entityId = ipc.Entity_Id__c;
    	String userId = c.Id; //'005G0000008bxkj';
    	String email = c.email;
    	//String userName = username;
    	String cert_id = ipc.Certificate_Developer_Name__c;
    	String isPortalUser = 'false';
    	Blob responsekey = Crypto.generateAesKey(128);
		String responseidString = '_' + EncodingUtil.ConvertTohex(responsekey);
		Blob assertionkey = Crypto.generateAesKey(128);
		String assertionidString = '_' + EncodingUtil.ConvertTohex(assertionkey);
		DateTime issuingTime = DateTime.now();
		DateTime expiringTime = issuingTime.addMinutes(5);
		DateTime validTime = issuingTime.addSeconds(-30);
    	
    	
    	
    	String assertionToDigest = '<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="' + assertionIdString + '" IssueInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Version="2.0">' +
    	'<saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">' + entityId + '</saml:Issuer>' +
    	'<saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">' + userName + '</saml:NameID>' + 
    	'<saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml:SubjectConfirmationData NotOnOrAfter="' + expiringTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Recipient="' + destination + '"></saml:SubjectConfirmationData></saml:SubjectConfirmation>' + 
    	'</saml:Subject>' + 
    	'<saml:Conditions NotBefore="' + validTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" NotOnOrAfter="' + expiringTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '">' +
    	'<saml:AudienceRestriction><saml:Audience>' + audience + '</saml:Audience></saml:AudienceRestriction>' +
    	'</saml:Conditions>' + 
    	'<saml:AuthnStatement AuthnInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '">' + 
    	'<saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef></saml:AuthnContext>' +
    	'</saml:AuthnStatement>' +
    	'<saml:AttributeStatement>' + 
    	'<saml:Attribute Name="userid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + userId + '</saml:AttributeValue></saml:Attribute>' + 
    	'<saml:Attribute Name="username" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + userName + '</saml:AttributeValue></saml:Attribute>' + 
    	'<saml:Attribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + email + '</saml:AttributeValue></saml:Attribute>' + 
    	'<saml:Attribute Name="is_portal_user" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + isPortalUser + '</saml:AttributeValue></saml:Attribute>' + 
    	'</saml:AttributeStatement>' + 
    	'</saml:Assertion>';
    	
    	String assertionDigest = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(assertionToDigest)));
    	
    	String assertionToSignature = '<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\n' +
		'<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod>\n' +
		'<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>\n' +
		'<ds:Reference URI="#' + assertionIdString + '">\n' +
		'<ds:Transforms>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"><ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="ds saml xs xsi"></ec:InclusiveNamespaces></ds:Transform>\n' +
		'</ds:Transforms>\n' +
		'<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>\n' +
		'<ds:DigestValue>' + assertionDigest + '</ds:DigestValue>\n' +
		'</ds:Reference>\n' +
		'</ds:SignedInfo>';
    	String assertionSignature = EncodingUtil.base64Encode(Crypto.SignWithCertificate('RSA-SHA1', Blob.valueOf(assertionToSignature), cert_id));
    	
    	String responseToDigest = '<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Destination="' + destination + '" ID="' + responseIdString + '" InResponseTo="' + assertionId + '" IssueInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Version="2.0">' +
    	'<saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">' + entityId + '</saml:Issuer>' + 
    	'<samlp:Status><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"></samlp:StatusCode></samlp:Status>' + 
    	'<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="' + assertionIdString + '" IssueInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Version="2.0">' + 
    	'<saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">' + entityId + '</saml:Issuer>' + 
    	'<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\n' +
		'<ds:SignedInfo>\n' +
		'<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod>\n' +
		'<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>\n' +
		'<ds:Reference URI="#' + assertionIdString + '">\n' +
		'<ds:Transforms>\n' + 
		'<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"><ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="ds saml xs xsi"></ec:InclusiveNamespaces></ds:Transform>\n' +
		'</ds:Transforms>\n' +
		'<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>\n' +
		'<ds:DigestValue>' + assertionDigest + '</ds:DigestValue>\n' +
		'</ds:Reference>\n' +
		'</ds:SignedInfo>\n' +
		'<ds:SignatureValue>\n' +
		assertionSignature + '\n' +
		'</ds:SignatureValue>\n' +
		'<ds:KeyInfo><ds:X509Data><ds:X509Certificate>' + certificate + '</ds:X509Certificate></ds:X509Data></ds:KeyInfo>' + 
		'</ds:Signature>' + 
		'<saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">' + userName + '</saml:NameID>' +
		'<saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml:SubjectConfirmationData NotOnOrAfter="' + expiringTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Recipient="' + destination + '"></saml:SubjectConfirmationData></saml:SubjectConfirmation>' +
		'</saml:Subject>' +
		'<saml:Conditions NotBefore="' + validTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" NotOnOrAfter="' + expiringTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '">' + 
		'<saml:AudienceRestriction><saml:Audience>' + audience + '</saml:AudienceRestriction>' + 
		'</saml:Conditions>' + 
		'<saml:AuthnStatement AuthnInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '"><saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef></saml:AuthnContext></saml:AuthnStatement>' + 
		'<saml:AttributeStatement>' + 
		'<saml:Attribute Name="userid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + userId + '</saml:AttributeValue></saml:Attribute>' + 
		'<saml:Attribute Name="username" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + userName + '</saml:AttributeValue></saml:Attribute>' + 
		'<saml:Attribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + email + '</saml:AttributeValue></saml:Attribute>' + 
		'<saml:Attribute Name="is_portal_user" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + isPortalUser + '</saml:AttributeValue></saml:Attribute>' +
		'</saml:AttributeStatement>' + 
		'</saml:Assertion>' + 
		'</samlp:Response>';
    	String responseDigest = EncodingUtil.base64Encode(Crypto.generateDigest('SHA1', Blob.valueOf(responseToDigest)));
    	
    	

    	String responseToSignature = '<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\n' +
		'<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod>\n' +
		'<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>\n' +
		'<ds:Reference URI="#' + responseIdString + '">\n' +
		'<ds:Transforms>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"><ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="ds saml samlp xs xsi"></ec:InclusiveNamespaces></ds:Transform>\n' +
		'</ds:Transforms>\n' +
		'<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>\n' +
		'<ds:DigestValue>' + responseDigest + '</ds:DigestValue>\n' +
		'</ds:Reference>\n' +
		'</ds:SignedInfo>';
    	String responseSignature = EncodingUtil.base64Encode(Crypto.SignWithCertificate('RSA-SHA1', Blob.valueOf(responseToSignature), cert_id));
    	
    	
    	String responseXML = '<?xml version="1.0" encoding="UTF-8"?>' +
    	'<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" Destination="' + destination + '" ID="' + responseIdString + + '" InResponseTo="' + assertionId + '" IssueInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Version="2.0">' + 
    	'<saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">' + entityId + '</saml:Issuer>' +
    	'<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\n' +
		'<ds:SignedInfo>\n' +
		'<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>\n' +
		'<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>\n' +
		'<ds:Reference URI="#' + responseIdString + '">\n' +
		'<ds:Transforms>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"><ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="ds saml samlp xs xsi"/></ds:Transform>\n' +
		'</ds:Transforms>\n' +
		'<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>\n' + 
		'<ds:DigestValue>' + responseDigest + '</ds:DigestValue>\n' +
		'</ds:Reference>\n' + 
		'</ds:SignedInfo>\n' +
		'<ds:SignatureValue>\n' +
		responseSignature + '\n' +
		'</ds:SignatureValue>\n' +
		'<ds:KeyInfo><ds:X509Data><ds:X509Certificate>' + certificate + '</ds:X509Certificate></ds:X509Data></ds:KeyInfo>' +
		'</ds:Signature>' +
		'<samlp:Status><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/></samlp:Status>' +
		'<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="' + assertionIdString + '" IssueInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Version="2.0">' +
		'<saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">' + entityId + '</saml:Issuer>' +
		'<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\n' +
		'<ds:SignedInfo>\n' +
		'<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>\n' +
		'<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>\n' +
		'<ds:Reference URI="#' + assertionIdString + '">\n' +
		'<ds:Transforms>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>\n' +
		'<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"><ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="ds saml xs xsi"/></ds:Transform>\n' +
		'</ds:Transforms>\n' +
		'<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>\n' +
		'<ds:DigestValue>' + assertionDigest + '</ds:DigestValue>\n' +
		'</ds:Reference>\n' +
		'</ds:SignedInfo>\n' +
		'<ds:SignatureValue>\n' +
		assertionSignature + '\n' +
		'</ds:SignatureValue>\n' + 
		'<ds:KeyInfo><ds:X509Data><ds:X509Certificate>' + certificate + '</ds:X509Certificate></ds:X509Data></ds:KeyInfo>' +
		'</ds:Signature>' + 
		'<saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">' + userName + '</saml:NameID>' +
		'<saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml:SubjectConfirmationData NotOnOrAfter="' + expiringTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" Recipient="' + destination + '"/></saml:SubjectConfirmation>' +
		'</saml:Subject>' +
		'<saml:Conditions NotBefore="' + validTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '" NotOnOrAfter="' + expiringTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '">' +
		'<saml:AudienceRestriction><saml:Audience>' + audience + '</saml:Audience></saml:AudienceRestriction>' +
		'</saml:Conditions>' + 
		'<saml:AuthnStatement AuthnInstant="' + issuingTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '"><saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef></saml:AuthnContext></saml:AuthnStatement>' +
		'<saml:AttributeStatement>' + 
		'<saml:Attribute Name="userid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + userId + '</saml:AttributeValue></saml:Attribute>' +
		'<saml:Attribute Name="username" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + userName + '</saml:AttributeValue></saml:Attribute>' +
		'<saml:Attribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + email + '</saml:AttributeValue></saml:Attribute>' + 
		'<saml:Attribute Name="is_portal_user" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:anyType">' + isPortalUser + '</saml:AttributeValue></saml:Attribute>' +
		'</saml:AttributeStatement>' +
		'</saml:Assertion>' +
		'</samlp:Response>';
		
		return EncodingUtil.base64Encode(Blob.valueOf(responseXML));
    }
    
    public static SAMLStatus checkAuthRequest(String request) {
    	Identity_Provider_Configuration__mdt ipc = [Select Id, Audience__c, Public_Key__c, Issuer__c, Certificate__c, Certificate_Developer_Name__c, Destination__c, Entity_Id__c, Service_URL__c from Identity_Provider_Configuration__mdt where Active__c = true limit 1];
    	String public_key = ipc.Public_Key__c;
    	String issuer = ipc.Issuer__c;
    	String decodedRequest = EncodingUtil.base64Decode(request).toString();
    	Pattern startsigpattern = Pattern.compile(':Signature xmlns:([A-Za-z0-9]+?)=".+?">');
    	Matcher startsigMatcher = startsigpattern.matcher(decodedRequest);
    	System.Debug(request);
    	if(startsigMatcher.find()) {
    		String namespace = startsigMatcher.group(1);
			Pattern sigpattern = Pattern.compile('(?m)(?s)<' + namespace + ':Signature xmlns:' + namespace + '=".+?">.+?</' + namespace + ':Signature>');
			Matcher sigmatcher = sigpattern.matcher(decodedRequest);
    		if(sigmatcher.find()) {
    			String signature = sigMatcher.group(0);
    			String requestWithoutSignature = decodedRequest.replace(signature, '');
    			Pattern referencepattern = Pattern.compile('<' + namespace + ':Reference URI="#(.+?)">');
    			Matcher referencematcher = referencepattern.matcher(signature);
    			if(referencematcher.find()) {
    				String referenceId = referencematcher.group(1);
    				Pattern digestpattern = Pattern.compile('<' + namespace + ':DigestValue>(.+?)</' + namespace + ':DigestValue>');
    				Matcher digestmatcher = digestpattern.matcher(signature);
    				if(digestmatcher.find()) {
    					String digest = digestmatcher.group(1);
    					Pattern digestMethodPattern = Pattern.compile('<' + namespace + ':DigestMethod Algorithm=".+?#(.+?)"');
    					Matcher digestMethodMatcher = digestMethodPattern.matcher(signature);
    					if(digestMethodMatcher.find()) {
    						String digestMethod = digestMethodMatcher.group(1);
    						Pattern startIdpattern = Pattern.compile('<([A-Za-z0-9]+?:[A-Za-z0-9]+?) .+?ID="' + referenceId + '".+?>');
	    					Matcher startIdMatch = startIdPattern.matcher(requestWithoutSignature);
    						if(startIdMatch.find()) {
	    						String elementType = startIdMatch.group(1);
    							Pattern requestToDigestPattern = Pattern.compile('(?s)(?m)<' + elementType + '.+?</' + elementType + '>');
    							Matcher requestToDigestMatcher = requestToDigestPattern.matcher(requestWithoutSignature);
	    						if(requestToDigestMatcher.find()) {
    								String requestToDigest = requestToDigestMatcher.group(0);
    								Pattern selfClosedTagsPattern = Pattern.compile('<([A-Za-z0-9]+?:[A-Za-z0-9]+?) [^>]+?/>');
    								Matcher selfClosedTagsMatcher = selfClosedTagsPattern.matcher(requestToDigest);
    								String requestToDigestTemp = requestToDigest; 
    								while(selfClosedTagsMatcher.find()) {
    									String tag = selfClosedTagsMatcher.group(0);
    									String tagName = selfClosedTagsMatcher.group(1);
    									String replacementTag = tag.replace('/>', '>') + '</' + tagName + '>';
    									requestToDigestTemp = requestToDigestTemp.replace(tag, replacementTag);
    								}
    								Map<String, String> childMap = new Map<String, String>();
    								requestToDigest = requestToDigestTemp;
    								Pattern alltagspattern = Pattern.compile('<([A-Za-z0-9]+?:[A-Za-z0-9]+) *?.*?>');
    								Matcher alltagsMatcher = alltagspattern.matcher(requestToDigest);
    								while(alltagsmatcher.find()) {
    									String tagName = alltagsMatcher.group(1);
    									String foundTag = alltagsMatcher.group(0);
    									String tagnamespace = '';
    									if(tagName.contains(':')) {
    										tagnamespace = tagName.split(':')[0];
    									}
    									Pattern attribsPattern = Pattern.compile('([A-Za-z0-9:]+?)=".*?"');
    									Matcher attribsMatcher = attribsPattern.matcher(foundTag);
    									Map<String, Map<String, String>> alphabetMap = new Map<String, Map<String, String>>();
    									while(attribsMatcher.find()) {
    										String findAttrib = attribsMatcher.group(1);
    										String namespaceattrib = '';
    										if(findAttrib.contains(':')) {
    											String[] parts = findAttrib.split(':'); 
    											namespaceattrib = parts[0];
    											findAttrib = parts[1];
    										}
    										if(!alphabetMap.containsKey(namespaceattrib)) {
    											alphabetMap.put(namespaceattrib, new Map<String, String>());
    										}
    										alphabetMap.get(namespaceattrib).put(findAttrib, attribsMatcher.group(0));
    									}
    									String[] attriblist = new String[0];
    									attriblist.add(tagName);
    									String[] namespaceList = new String[0];
    									nameSpacelist.addAll(alphabetMap.keySet());
    									nameSpaceList.sort();
    									for(String s : childMap.keySet()) {
    										if(s == tagnamespace) {
    											attriblist.add(childMap.get(s));
    											childMap.remove(s);
    										}
    									}
    									for(String s : nameSpaceList) {
    										if(s == 'xmlns') {
    											String[] attribSortList = new String[0];
    											attribSortList.addAll(alphabetMap.get(s).keySet());
	    										attribSortList.sort();
    											for(String s2 : attribSortList) {
    												if(s2 == tagnamespace) {
	    												attriblist.add(alphabetMap.get(s).get(s2));
    												}
    												else {
    													childMap.put(s2, alphabetMap.get(s).get(s2));
    												}
    											}
    										}
    									}
    									for(String s : nameSpaceList) {
    										if(s != 'xmlns') {
    											String[] attribSortList = new String[0];
    											attribSortList.addAll(alphabetMap.get(s).keySet());
	    										attribSortList.sort();
    											for(String s2 : attribSortList) {
	    											attriblist.add(alphabetMap.get(s).get(s2));
    											}
    										}
    									}
    									String newTag = '<' + String.join(attriblist, ' ') + '>';
    									requestToDigestTemp = requestToDigestTemp.replace(foundTag, newTag);
    								} 
    								requestToDigest = requestToDigestTemp;
    								if(EncodingUtil.base64Encode(Crypto.generateDigest(digestmethod == 'sha256' ? 'SHA-256' : (digestmethod == 'sha512' ? 'SHA-512' : 'SHA1'), Blob.valueOf(requestToDigest))) == digest) {
    									Pattern issuerPattern = Pattern.compile(':Issuer.*?>(.+?)</');
    									Matcher issuerMatcher = issuerPattern.matcher(requestToDigest);
    									if(issuerMatcher.find()) {
    										if(issuerMatcher.group(1) == issuer) {
    											
    											Pattern instantPattern = Pattern.compile('IssueInstant="(.+?)"');
    											Matcher instantMatcher = instantPattern.matcher(requestToDigest);
    											if(instantMatcher.find()) {
	   												String dateString = instantMatcher.group(1);
    												dateString = dateString.replace('T', ' ');
    												DateTime issueTime = DateTime.valueOfGMT(dateString);
    												if(!dateString.endsWith('Z')) {
    													if(dateString.contains('+')) {
    														String offset = dateString.split('+')[1];
    														Integer offsethours = (0 - Integer.valueOf(offset.split(':')[0]));
    														Integer offsetminutes = (0 - Integer.valueOf(offset.split(':')[1]));
    														issueTime = issueTime.addHours(offsetHours);
    														issueTime = issueTime.addMinutes(offsetMinutes);
    													}
    													else {
    														String offset = dateString.split('-')[1];
    														Integer offsethours = Integer.valueOf(offset.split(':')[0]);
    														Integer offsetminutes = Integer.valueOf(offset.split(':')[1]);
    														issueTime = issueTime.addHours(offsetHours);
    														issueTime = issueTime.addMinutes(offsetMinutes);
    													}
    												}
    												if(true) { //issueTime >= DateTime.now().addSeconds(-30) && issueTime < DateTime.now().addMinutes(5)) {
    													Pattern signedInfoPattern = Pattern.compile('(?m)(?s)<' + nameSpace + ':SignedInfo.*?>.*?</' + nameSpace + ':SignedInfo>');
    													Matcher signedInfoMatcher = signedInfoPattern.matcher(signature);
    													if(signedInfoMatcher.find()) {
    														String signedInfo = signedInfoMatcher.group(0);
    														Pattern signatureValuePattern = Pattern.compile('<' + nameSpace + ':SignatureValue.*?>(.*?)</' + nameSpace + ':SignatureValue>');
    														Matcher signatureValueMatcher = signatureValuePattern.matcher(signature);
    														if(signatureValueMatcher.find()) {
    															String signatureValue = signatureValueMatcher.group(1);
    															Pattern signatureSigningMethodPattern = Pattern.compile('<' + namespace + ':SignatureMethod.*?Algorithm="(.*?)".*?>');
    															Matcher signatureSigningMethodMatcher = signatureSigningMethodPattern.matcher(signature);
    															if(signatureSigningMethodMatcher.find()) {
    																if(signedInfo.startsWith('<' + namespace + ':SignedInfo>')) {
    																	signedInfo = signedInfo.replace('<' + namespace + ':SignedInfo>', '<' + namespace + ':SignedInfo xmlns:' + namespace + '="http://www.w3.org/2000/09/xmldsig#">');
    																}
    																selfClosedTagsMatcher = selfClosedTagsPattern.matcher(signedInfo);
    																String signedInfoTemp = signedInfo; 
    																while(selfClosedTagsMatcher.find()) {
    																	String tag = selfClosedTagsMatcher.group(0);
    																	String tagName = selfClosedTagsMatcher.group(1);
    																	String replacementTag = tag.replace('/>', '>') + '</' + tagName + '>';
    																	signedInfoTemp = signedInfoTemp.replace(tag, replacementTag);
    																}
    																signedInfo = signedInfoTemp;
    																String signingAlgorithm = signatureSigningMethodMatcher.group(1);
    																if(Crypto.verify(signingAlgorithm.endsWith('sha256') ? 'RSA-SHA256' : 'RSA-SHA1', Blob.valueOf(signedInfo), EncodingUtil.base64Decode(signatureValue), EncodingUtil.base64Decode(public_key))) {
    																	return new SAMLStatus(true, null, referenceid);
    																}
    																else {
    																	return new SAMLStatus(false, 'Signed Info is Not Valid.');	
    																}
    															}
    															else {
    																return new SAMLStatus(false, 'Can\'t determine Signature Algorithm.');	
    															}
    															
    														}
    														else {
    															return new SAMLStatus(false, 'No SignatureValue found.');
    														}
    													}
    													else {
    														return new SAMLStatus(false, 'No SignedInfo found.');	
    													}
    												}
    												else {
    													return new SAMLStatus(false, 'Assertion IssueInstant is Outside Acceptable Range.');	
    												}
    													
    											}
    											else {
    												return new SAMLStatus(false, 'IssueInstant Not Found.');	
    											}
    										}
    										else {
    											return new SAMLStatus(false, 'Issuer Does Not Match.');	
    										}
    									}
    									else {
    										return new SAMLStatus(false, 'No Issuer Found.');	
    									}
    								}
    								else {
    									return new SAMLStatus(false, 'Digests Don\'t Match.');
    								}

    							}
    							else {
	    							return new SAMLStatus(false, 'Couldn\'t Match the Section to Digest.');	
	    						}	
    							
    						}
    						else {
	    						return new SAMLStatus(false, 'No Element Found Matching the Digested ID.');
    						}
    					}
    					else {
    						return new SAMLStatus(false, 'No Digest Algorithm Found.');
    					}
    				}
    				else {
    					return new SAMLStatus(false, 'No Digest Found.');	
    				}
    			}
    			else {
    				return new SAMLStatus(false, 'Error Reading the Reference ID.');	
    			}
    		} 
    		else {
    			return new SAMLStatus(false, 'Error Reading the Signature Element.');	
    		}
    	}
    	else {
    		return new SAMLStatus(false, 'No Signature Found.');
    	} 
    	
    	
    	//String messageWithoutSig = decodedRequest.
    	//String signature = decodedRequest.
    }
    
    public class SAMLStatus {
    	
    	public SAMLStatus(Boolean requestValid, String errorMessage) {
    		this.requestValid = requestValid;
    		this.errorMessage = errorMessage;
    	}
    	public SAMLStatus(Boolean requestValid, String errorMessage, String assertionId) {
    		this.requestValid = requestValid;
    		this.errorMessage = errorMessage;
    		this.assertionId = assertionId;
    	}
    	
    	public Boolean requestValid {get;set;}
    	public String errorMessage {get;set;}
    	public String assertionId {get;set;}
    }    
}