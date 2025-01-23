global class CyberSourcePaymentAdapter implements CommercePayments.PaymentGatewayAdapter {
	private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO = new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
	private static final commercepayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO = new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline);

	global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.GatewayResponse response;
        try 
        {
            if (requestType == commercepayments.RequestType.Authorize) {

                response = createAuthResponse((commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
            }
            else if ( requestType == commercepayments.RequestType.Capture)
            {
                response =  createCaptureResponse((commercepayments.CaptureRequest)gatewayContext.getPaymentRequest()) ;
            }
            else if ( requestType == commercepayments.RequestType.Sale)
            {
                response =  createSaleResponse((commercepayments.SaleRequest)gatewayContext.getPaymentRequest()) ;
            }
            else if (requestType == commercepayments.RequestType.ReferencedRefund) {
            		response = createRefundResponse((commercepayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest());
            }
            return response;
        }
        catch(SalesforceValidationException e)
        {
             commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400', e.getMessage());
             return error;
        }
    }

    public Map<String, Object> createCyberSourceCallout(CybersourceBody cybersourceBody, String endpoint, Boolean capture) {

        //working sessions call
		Cybersource_Settings__mdt cs = [SELECT Host__c, Key__c, Secret__c, Merchant_Id__c FROM Cybersource_Settings__mdt WHERE DeveloperName = 'B2B_Sandbox'];
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('POST');

        String jsonBody = JSON.serialize(cybersourceBody);
        jsonBody = jsonBody.replace('"currency_Z":', '"currency":');
        if(capture) {
            jsonBody = jsonBody.replace('"tokenInformation":null,', '');
            jsonBody = jsonBody.replace('"processingInformation":null,', '');
            jsonBody = jsonBody.replace('"merchantDefinedInformation":null,', '');
            jsonBody = jsonBody.replace('"billTo":null,', '');
        }
        request.setBody(jsonBody);
        // if (type == 'sale') {
        //     request.setBody('{"clientReferenceInformation": {"code": "TC50142_3"}, "processingInformation": {"capture": true}, "orderInformation": {"amountDetails": {"totalAmount": "102.23","currency": "USD"},"billTo": {"firstName": "Kevin","lastName": "Test","address1": "201 S. Division St.","locality": "Ann Arbor","administrativeArea": "MI","postalCode": "48104-2201","country": "US","district": "MI","buildingNumber": "123","email": "test@cybs.com","phoneNumber": "999999999"}},"tokenInformation": {"transientTokenJwt": "' + finalToken + '"}}');
        // } else {
        //     request.setBody('{"clientReferenceInformation": {"code": "TC50142_3"},"orderInformation": {"amountDetails": {"totalAmount": "102.23","currency": "USD"},"billTo": {"firstName": "Kevin","lastName": "Test","address1": "201 S. Division St.","locality": "Ann Arbor","administrativeArea": "MI","postalCode": "48104-2201","country": "US","district": "MI","buildingNumber": "123","email": "test@cybs.com","phoneNumber": "999999999"}},"tokenInformation": {"transientTokenJwt": "' + finalToken + '"}}');
        // }
		Blob blobValue = Crypto.generateDigest('SHA-256', Blob.valueOf(request.getbody()));
		String signdigest = EncodingUtil.base64Encode(blobValue);
		String digest = 'SHA-256=' + signdigest;
		
		String currentDate = datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss z');
		Map<String, String> signedHeaders = new Map<String, String>();
		signedHeaders.put('host', cs.Host__c);
		signedHeaders.put('v-c-date', currentDate);
		signedHeaders.put('(request-target)', 'post ' + endpoint);
		signedHeaders.put('v-c-merchant-id', cs.Merchant_Id__c);
		signedHeaders.put('digest', digest);
		
		String signatureString = '';
		String headersString = '';
		for (String key : signedHeaders.keySet()){
			signatureString = signatureString + '\n' + key + ': ' + signedHeaders.get(key);
			headersString = headersString + ' ' + key;
		}
		signatureString = signatureString.substring(1,signatureString.length());
		headersString = headersString.substring(1,headersString.length());
		String algorithmName = 'HmacSHA256';
		Blob mac = Crypto.generateMac(algorithmName, Blob.valueOf(signatureString), EncodingUtil.base64Decode(cs.Secret__c));
		String macUrl = EncodingUtil.base64Encode(mac);
		String signature = 'keyid="' + cs.Key__c + '", '
						+ 'algorithm="HmacSHA256", '
						+ 'headers="' + headersString + '", '
						+ 'signature="' + macUrl + '"';
		
		request.setHeader('host', cs.Host__c);
		request.setHeader('signature', signature);
		request.setHeader('digest', digest);
		request.setHeader('v-c-merchant-id', cs.Merchant_Id__c);
		request.setHeader('v-c-date', currentDate);
		request.setHeader('Content-type', 'application/json');
		commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
		HTTPResponse res = http.send(request);
		String body = res.getBody();
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);

        return results;
    }

    public class CybersourceBody {
        public ClientReferenceInformation clientReferenceInformation {get;set;} 
        public ProcessingInformation processingInformation {get;set;} 
        public OrderInformation orderInformation {get;set;} 
        public TokenInformation tokenInformation {get;set;}
        public List<MerchantDefinedInformation> merchantDefinedInformation {get;set;}
    }
    public class ClientReferenceInformation {
        public String code {get;set;} 
    }
    public class ProcessingInformation {
        public Boolean capture {get;set;} 
        public List<String> actionList {get;set;}
        public List<String> actionTokenTypes {get;set;}
    }
    public class OrderInformation {
        public AmountDetails amountDetails {get;set;} 
        public BillTo billTo {get;set;} 
    }
    public class TokenInformation {
        public String transientTokenJwt {get;set;} 
    }

    public class MerchantDefinedInformation {
        public String key {get;set;}
        public String value {get;set;}
    }

    public class BillTo {
        public String firstName {get;set;} 
        public String lastName {get;set;} 
        public String address1 {get;set;}
        public String address2 {get;set;}
        public String address3 {get;set;}
        public String address4 {get;set;}
        public String locality {get;set;} 
        public String administrativeArea {get;set;} 
        public String postalCode {get;set;} 
        public String country {get;set;} 
        public String district {get;set;} 
        public String buildingNumber {get;set;} 
        public String email {get;set;} 
        public String phoneNumber {get;set;} 
    }

    public class AmountDetails {
        public String totalAmount {get;set;} 
        public String currency_Z {get;set;} // string replace to reserved id: currency
    }

    public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
		
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = authRequest.paymentMethod;
        
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        if(authRequest.amount!=null) authResponse.setAmount(authRequest.amount);
        else throw new SalesforceValidationException('Required Field Missing : Amount');

        Integer keyCount = authRequest.additionalData.keySet().size();
		String finalToken = '';
		for(Integer i = 0 ; i < keyCount ; i++) finalToken += authRequest.additionalData.get(String.valueOf(i));

        CybersourceBody cybersourceBody = new CybersourceBody();
        ClientReferenceInformation clientReferenceInformation = new ClientReferenceInformation(); cybersourceBody.clientReferenceInformation = clientReferenceInformation;
        ProcessingInformation processingInformation = new ProcessingInformation(); cybersourceBody.processingInformation = processingInformation;
        processingInformation.actionList = new List<String>{'TOKEN_CREATE'};
        processingInformation.actionTokenTypes = new List<String>{'customer'};
        OrderInformation orderInformation = new OrderInformation(); AmountDetails amountDetails = new AmountDetails(); BillTo billto = new BillTo(); orderInformation.amountDetails = amountDetails; orderInformation.billTo = billto; cybersourceBody.orderInformation = orderInformation; 
        TokenInformation tokenInformation = new TokenInformation(); cybersourceBody.tokenInformation = tokenInformation;
        clientReferenceInformation.code = 'TC50142_3';
        processingInformation.capture = false;
        tokenInformation.transientTokenJwt = finalToken;
        CartItem ci;
        if(!Test.isRunningTest()) { ci = [SELECT Sku FROM CartItem WHERE CartId = :authRequest.comments.split(',')[1] LIMIT 1]; }
        MerchantDefinedInformation merchantDefinedInformation = new MerchantDefinedInformation();
        List<MerchantDefinedInformation> mdiList = new List<MerchantDefinedInformation>();
        merchantDefinedInformation.key = 'Class Code';
        if(!Test.isRunningTest()) { merchantDefinedInformation.value = ci.Sku; }
        else merchantDefinedInformation.value = 'test';
        mdiList.add(merchantDefinedInformation);
        cybersourceBody.merchantDefinedInformation = mdiList;

        //Cybersource only transacts in USD
        amountDetails.currency_Z = 'USD';
        amountDetails.totalAmount =  authRequest.comments.split(',')[0];
        // amountDetails.currency_Z = authRequest.currencyIsoCode;
        // amountDetails.totalAmount =  String.valueOf(authRequest.amount);
        if(!Test.isRunningTest()) {
            billto.firstName = authRequest.paymentMethod.cardPaymentMethod.cardHolderFirstName;billto.lastName = authRequest.paymentMethod.cardPaymentMethod.cardHolderLastName;
            String[] lines = authRequest.paymentMethod.address.street.split('\n');
            billto.address1 = lines[0];
            if(lines.size() > 1) billto.address2 = lines[1];
            if(lines.size() > 2) billto.address3 = lines[2];
            if(lines.size() > 3) billto.address4 = lines[3];
            billto.locality = authRequest.paymentMethod.address.city;billto.administrativeArea = authRequest.paymentMethod.address.state;billto.postalCode = authRequest.paymentMethod.address.postalCode;billto.country = authRequest.paymentMethod.address.country;
            User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Account a = [SELECT PersonContactId, PersonHomePhone, PersonEmail FROM Account WHERE PersonContactId = :u.ContactId];
            Order OrderSCode = [SELECT OrderNumber FROM Order WHERE Id = :authRequest.comments.split(',')[2] LIMIT 1];
            billto.email = a.PersonEmail;billto.phoneNumber = a.PersonHomePhone;clientReferenceInformation.code = OrderSCode.OrderNumber;
        }
        Map<String, Object> results = createCyberSourceCallout(cybersourceBody, '/pts/v2/payments', false);

        if((String)results.get('status') == 'AUTHORIZED') {
            authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
            authResponse.setGatewayResultCodeDescription('Transaction Normal');
            Map<String, Object> tokenInformationResponse = (Map<String, Object>) results.get('tokenInformation');
            Map<String, Object> customerInformation = (Map<String, Object>) tokenInformationResponse.get('customer');
            Map<String, Object> cardInformation = (Map<String, Object>) customerInformation.get('client');
            paymentMethodTokenizationResponse.setGatewayTokenEncrypted((String)customerInformation.get('id'));
            authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        }
		else {
            authResponse.setSalesforceResultCodeInfo(DECLINE_SALESFORCE_RESULT_CODE_INFO);
            Map<String, Object> errorInformation = (Map<String, Object>) results.get('errorInformation');
            authResponse.setGatewayResultCodeDescription((String)errorInformation.get('message'));
        }
        authResponse.setGatewayResultCode('00');
        authResponse.setGatewayDate(system.now());
        authResponse.setGatewayReferenceNumber((String)results.get('id'));
        return authResponse;
    }
    
    public commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
        commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
        if(captureRequest.amount!=null ) captureResponse.setAmount(captureRequest.amount);
        else throw new SalesforceValidationException('Required Field Missing : Amount');             
        PaymentAuthorization pa;
        String endpoint = '/pts/v2/payments/';
        if(!Test.isRunningTest()) {
            pa = [SELECT convertCurrency(amount) convertedCurrency, GatewayRefNumber, CurrencyIsoCode, OrderPaymentSummary.OrderSummaryId, OrderPaymentSummaryId FROM PaymentAuthorization WHERE Id = :captureRequest.paymentAuthorizationId LIMIT 1];
            endpoint = '/pts/v2/payments/' + pa.GatewayRefNumber + '/captures';
        }
        CybersourceBody cybersourceBody = new CybersourceBody();
        ClientReferenceInformation clientReferenceInformation = new ClientReferenceInformation(); cybersourceBody.clientReferenceInformation = clientReferenceInformation;
        OrderInformation orderInformation = new OrderInformation(); AmountDetails amountDetails = new AmountDetails(); orderInformation.amountDetails = amountDetails; cybersourceBody.orderInformation = orderInformation; 
        clientReferenceInformation.code = 'TC50142_3';
        if(!Test.isRunningTest()) {
             OrderSummary OrderSCode = [SELECT OrderNumber FROM OrderSummary WHERE Id = :pa.OrderPaymentSummary.OrderSummaryId LIMIT 1];
            clientReferenceInformation.code = OrderSCode.OrderNumber;
        }
        //Cybersource only transacts in USD
        amountDetails.currency_Z = 'USD';
        if(!Test.isRunningTest()) amountDetails.totalAmount =  String.valueOf((Decimal) pa.get('convertedCurrency'));
        else amountDetails.totalAmount = '100';
        // amountDetails.currency_Z = saleRequest.currencyIsoCode;
        // amountDetails.totalAmount =  String.valueOf(captureRequest.amount);
        Map<String, Object> results = createCyberSourceCallout(cybersourceBody, endpoint, true);
        if((String)results.get('status') != 'PENDING') {
            captureResponse.setSalesforceResultCodeInfo(DECLINE_SALESFORCE_RESULT_CODE_INFO);
            captureResponse.setGatewayResultCodeDescription(JSON.serialize(results));
        }
        else {
            captureResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        }
        captureResponse.setGatewayDate(system.now());
        captureResponse.setGatewayResultCode('00');
        captureResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
        return captureResponse;
    }
    
    public commercepayments.GatewayResponse createSaleResponse(commercepayments.SaleRequest saleRequest) {
        commercepayments.SaleResponse saleResponse = new commercepayments.SaleResponse();
        commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        
        Integer keyCount = saleRequest.additionalData.keySet().size();
		String finalToken = '';
		for(Integer i = 0 ; i < keyCount ; i++) finalToken += saleRequest.additionalData.get(String.valueOf(i));
        
        if(saleRequest.amount!=null )
        {
            saleResponse.setAmount(saleRequest.amount);
        }
        else
        {
            throw new SalesforceValidationException('Required Field Missing : Amount');             
        }

        CybersourceBody cybersourceBody = new CybersourceBody();
        ClientReferenceInformation clientReferenceInformation = new ClientReferenceInformation(); cybersourceBody.clientReferenceInformation = clientReferenceInformation;
        ProcessingInformation processingInformation = new ProcessingInformation(); cybersourceBody.processingInformation = processingInformation;
        processingInformation.actionList = new List<String>{'TOKEN_CREATE'};
        processingInformation.actionTokenTypes = new List<String>{'customer'};
        OrderInformation orderInformation = new OrderInformation(); AmountDetails amountDetails = new AmountDetails(); BillTo billto = new BillTo(); orderInformation.amountDetails = amountDetails; orderInformation.billTo = billto; cybersourceBody.orderInformation = orderInformation; 
        TokenInformation tokenInformation = new TokenInformation(); cybersourceBody.tokenInformation = tokenInformation;
        clientReferenceInformation.code = 'TC50142_3';
        processingInformation.capture = true;
        tokenInformation.transientTokenJwt = finalToken;
        CartItem ci;
        if(!Test.isRunningTest()) { ci = [SELECT Sku FROM CartItem WHERE CartId = :saleRequest.comments.split(',')[1] LIMIT 1]; }
        MerchantDefinedInformation merchantDefinedInformation = new MerchantDefinedInformation();
        List<MerchantDefinedInformation> mdiList = new List<MerchantDefinedInformation>();
        merchantDefinedInformation.key = 'Class Code';
        if(!Test.isRunningTest()) { merchantDefinedInformation.value = ci.Sku; }
        else merchantDefinedInformation.value = 'test';
        mdiList.add(merchantDefinedInformation);
        cybersourceBody.merchantDefinedInformation = mdiList;

        //Cybersource only transacts in USD
        amountDetails.currency_Z = 'USD';
        amountDetails.totalAmount =  saleRequest.comments.split(',')[0];
        // amountDetails.currency_Z = saleRequest.currencyIsoCode;
        // amountDetails.totalAmount =  String.valueOf(saleRequest.amount);
        if(!Test.isRunningTest()) {
            billto.firstName = saleRequest.paymentMethod.cardPaymentMethod.cardHolderFirstName;billto.lastName = saleRequest.paymentMethod.cardPaymentMethod.cardHolderLastName;
            String[] lines = saleRequest.paymentMethod.address.street.split('\n');
            billto.address1 = lines[0];
            if(lines.size() > 1) billto.address2 = lines[1];
            if(lines.size() > 2) billto.address3 = lines[2];
            if(lines.size() > 3) billto.address4 = lines[3];
            billto.locality = saleRequest.paymentMethod.address.city;billto.administrativeArea = saleRequest.paymentMethod.address.state;billto.postalCode = saleRequest.paymentMethod.address.postalCode;billto.country = saleRequest.paymentMethod.address.country;
            User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Account a = [SELECT PersonContactId, PersonHomePhone, PersonEmail FROM Account WHERE PersonContactId = :u.ContactId];
            Order OrderSCode = [SELECT OrderNumber FROM Order WHERE Id = :saleRequest.comments.split(',')[2] LIMIT 1];
            billto.email = a.PersonEmail;billto.phoneNumber = a.PersonHomePhone;clientReferenceInformation.code = OrderSCode.OrderNumber;
        }
        Map<String, Object> results = createCyberSourceCallout(cybersourceBody, '/pts/v2/payments', false);
        System.debug('Cybersourse response: '+results);
        if((String)results.get('status') == 'AUTHORIZED') {
            saleResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
            saleResponse.setGatewayResultCodeDescription('Transaction Normal');
            Map<String, Object> tokenInformationResponse = (Map<String, Object>) results.get('tokenInformation');
            System.debug('tokenInformationResponse: '+tokenInformationResponse);
            Map<String, Object> customerInformation = (Map<String, Object>) tokenInformationResponse.get('customer');
            System.debug('customerInformation: '+customerInformation);
            paymentMethodTokenizationResponse.setGatewayToken((String)customerInformation.get('id'));
            saleResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        }
		else {
            saleResponse.setSalesforceResultCodeInfo(DECLINE_SALESFORCE_RESULT_CODE_INFO);
            Map<String, Object> errorInformation = (Map<String, Object>) results.get('errorInformation');
            if(errorInformation != null) saleResponse.setGatewayResultCodeDescription((String)errorInformation.get('message'));
            saleResponse.setGatewayResultCodeDescription((String)results.get('status'));
        }
        saleResponse.setGatewayResultCode('00');
        saleResponse.setGatewayDate(system.now());
        saleResponse.setGatewayReferenceNumber((String)results.get('id'));
        return saleResponse;
    }
    
    public commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
        commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
        if (refundRequest.amount != null) {
            refundResponse.setAmount(refundRequest.amount);
        } else {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }
        Schema.Payment p;
        String endpoint = '/pts/v2/payments/';
        if(!Test.isRunningTest()) {
            p = [SELECT convertCurrency(amount) convertedCurrency, GatewayRefNumber, CurrencyIsoCode, OrderPaymentSummary.OrderSummaryId, OrderPaymentSummaryId FROM Payment WHERE Id = :refundRequest.PaymentId LIMIT 1];
            endpoint = '/pts/v2/payments/' + p.GatewayRefNumber + '/refunds';
        }
        CybersourceBody cybersourceBody = new CybersourceBody();
        ClientReferenceInformation clientReferenceInformation = new ClientReferenceInformation(); cybersourceBody.clientReferenceInformation = clientReferenceInformation;
        OrderInformation orderInformation = new OrderInformation(); AmountDetails amountDetails = new AmountDetails(); orderInformation.amountDetails = amountDetails; cybersourceBody.orderInformation = orderInformation; 
        if(!Test.isRunningTest()) {
            OrderSummary OrderSCode = [SELECT OrderNumber FROM OrderSummary WHERE Id = :p.OrderPaymentSummary.OrderSummaryId LIMIT 1];
            clientReferenceInformation.code = OrderSCode.OrderNumber;
        }
        //Cybersource only transacts in USD
        amountDetails.currency_Z = 'USD';
        if(!Test.isRunningTest()) amountDetails.totalAmount =  String.valueOf((Decimal) p.get('convertedCurrency'));
        else amountDetails.totalAmount = '100';
        Map<String, Object> results = createCyberSourceCallout(cybersourceBody, endpoint, true);
        if((String)results.get('status') != 'PENDING') {
            refundResponse.setSalesforceResultCodeInfo(DECLINE_SALESFORCE_RESULT_CODE_INFO);
            refundResponse.setGatewayResultCodeDescription(JSON.serialize(results));
        }
        else {
            refundResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        }
        refundResponse.setGatewayDate(system.now());
        refundResponse.setGatewayResultCode('00');
        refundResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
        return refundResponse;
    }  

    private String getRandomNumber(integer stringLength){
        final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }


	public class SalesforceValidationException extends Exception {}
}