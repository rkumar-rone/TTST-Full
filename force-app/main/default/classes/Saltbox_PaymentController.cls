global without sharing class Saltbox_PaymentController {
    
    @RemoteAction
    global static String generateCaptureContext() {
        Cybersource_Settings__mdt cs = [SELECT Host__c, Key__c, Secret__c, Merchant_Id__c, Target_Origins__c FROM Cybersource_Settings__mdt WHERE DeveloperName = 'B2B_Sandbox'];
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + cs.Host__c + '/microform/v2/sessions');
        request.setMethod('POST');
        request.setBody('{"targetOrigins": ["' + cs.Target_Origins__c + '"],"allowedCardNetworks": ["VISA","MASTERCARD","AMEX","DISCOVER"],"clientVersion": "v2.0"}');
        Blob blobValue = Crypto.generateDigest('SHA-256', Blob.valueOf(request.getbody()));
        String signdigest = EncodingUtil.base64Encode(blobValue);
        String digest = 'SHA-256=' + signdigest;

        String currentDate = datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss z');
        Map<String, String> signedHeaders = new Map<String, String>();
        signedHeaders.put('host', cs.Host__c);
        signedHeaders.put('v-c-date', currentDate);
        signedHeaders.put('(request-target)', 'post /microform/v2/sessions');
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
        Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(signatureString), EncodingUtil.base64Decode(cs.Secret__c));
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
        Http http = new Http();
        HTTPResponse res = http.send(request);
        return res.getBody();
    }
    

    public class PaymentWrapper {
        @AuraEnabled
        public string cardHolderFirstName{get;set;}
        @AuraEnabled
        public string cardHolderLastName{get;set;}
        @AuraEnabled
        public string token{get;set;}
        @AuraEnabled
        public Integer expiryYear{get;set;}
        @AuraEnabled
        public Integer expiryMonth{get;set;}
        @AuraEnabled
        public string cardType{get;set;}
        @AuraEnabled
        public AddressWrapper address{get;set;}
    }

    public class AddressWrapper {
        @AuraEnabled
        public string street{get;set;}
        @AuraEnabled
        public string city{get;set;}
        @AuraEnabled
        public string state{get;set;}
        @AuraEnabled
        public string postalCode{get;set;}
        @AuraEnabled
        public string country{get;set;}
    }

    @AuraEnabled
    public static string tokenizeCard(Id orderId, Id cartId, PaymentWrapper pw){
        WebCart wc = [SELECT GrandTotalAmount, convertCurrency(GrandTotalAmount) convertedCurrency, CurrencyIsoCode, IsWaitlisted__c, IsGroupOrder__c, BillingCity, BillingCountry, BillingPostalCode, BillingStreet, BillingState FROM WebCart WHERE Id = :cartId];
        String response = '';
        System.debug('Webcart: ' + wc);
        System.debug('PaymentWrapper: ' + pw.token);
        System.debug('OrderId: ' + orderId);
        if (wc.IsGroupOrder__c) {
            response = buildPaymentRequest(orderId, pw, wc);
        } else if (wc.IsWaitlisted__c){
            response = buildAuthorizationRequest(orderId, pw, wc);
        } else {
            response = buildPaymentRequest(orderId, pw, wc);
        }
        return response;
    }

    private static String buildAuthorizationRequest(Id orderId, PaymentWrapper pw, WebCart wc){
        PaymentGateway pg = [SELECT Id FROM PaymentGateway WHERE PaymentGatewayName = 'Credit Card'];

        ConnectApi.AuthorizationRequest ar = new ConnectApi.AuthorizationRequest();
        ar.paymentGatewayId = pg.Id;
        ar.amount = wc.GrandTotalAmount;
        ar.comments = String.valueOf((Decimal) wc.get('convertedCurrency') + ',' + String.valueOf(wc.Id)  + ',' + String.valueOf(orderId));
        ar.currencyIsoCode = wc.CurrencyIsoCode;

        ConnectApi.PaymentGroupRequest pgr = new ConnectApi.PaymentGroupRequest();
        pgr.sourceObjectId = orderId;
        pgr.currencyIsoCode = wc.CurrencyIsoCode;
        pgr.createPaymentGroup = true;
        ar.paymentGroup = pgr;

        ConnectApi.AuthApiPaymentMethodRequest authApiPMRequest = new ConnectApi.AuthApiPaymentMethodRequest();
        authApiPMRequest.address = new ConnectApi.AddressRequest();
        // authApiPMrequest.address.street = pw.address.street;
        // authApiPMrequest.address.city = pw.address.city;
        // authApiPMrequest.address.state = pw.address.state;
        // authApiPMrequest.address.postalCode = pw.address.postalCode;
        // authApiPMrequest.address.country = pw.address.country;
        authApiPMrequest.address.street = wc.BillingStreet;
        authApiPMrequest.address.city = wc.BillingCity;
        authApiPMrequest.address.state = wc.BillingState;
        authApiPMrequest.address.postalCode = wc.BillingPostalCode;
        authApiPMrequest.address.country = wc.BillingCountry;
        authApiPMrequest.saveForFuture = true;

        ConnectApi.CardPaymentMethodRequest cpmRequest = new ConnectApi.CardPaymentMethodRequest();
        if (pw.cardType == 'MasterCard') {
            pw.cardType = 'Master Card';
        }
        Blob decodePayload = EncodingUtil.base64Decode(pw.token.split('\\.')[1]);
        String jsonPayload = decodePayload.toString();
        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        String maskedValue = (String) ((Map<String,Object>)((Map<String, Object>) ((Map<String, Object>) ((Map<String, Object>) payloadMap.get('content')).get('paymentInformation')).get('card')).get('number')).get('maskedValue');
        cpmRequest.cardNumber = maskedValue.replace('X', '0');
        cpmRequest.expiryYear = pw.expiryYear;
        cpmRequest.expiryMonth = pw.expiryMonth;
        cpmRequest.cardHolderFirstName = pw.cardHolderFirstName;
        cpmRequest.cardHolderLastName = pw.cardHolderLastName;
        cpmRequest.cardHolderName = pw.cardHolderFirstName + ' ' + pw.cardHolderLastName;
        cpmRequest.cardType = pw.cardType;
        cpmRequest.cardCategory = ConnectApi.CardCategory.CreditCard;
        authApiPMRequest.cardPaymentMethod = cpmRequest;
        ar.paymentMethod = authApiPMRequest;

        ar.additionalData = new Map<String, String>();
        splitToken(ar, pw.token);
        try {
            if(Test.isRunningTest()){
                return 'Success';
            }
            ConnectApi.AuthorizationResponse response = ConnectApi.Payments.authorize(ar);
            return 'Success';
        } catch(ConnectApi.ConnectApiException e) {
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(e.getMessage());
            Map<String, Object> output = (Map<String, Object>) errorMap.get('output');
            Map<String, Object> gatewayResponse = (Map<String, Object>) output.get('gatewayResponse');
            String errorMsg = (String) gatewayResponse.get('gatewayResultCodeDescription');
            return errorMsg;
        }
    }

    private static String buildPaymentRequest(Id orderId, PaymentWrapper pw, WebCart wc){
        PaymentGateway pg = [SELECT Id FROM PaymentGateway WHERE PaymentGatewayName = 'Credit Card'];
        String originalCardType='';
        ConnectApi.SaleRequest ar = new ConnectApi.SaleRequest();
        ar.paymentGatewayId = pg.Id;
        ar.amount = wc.GrandTotalAmount;
        ar.comments = String.valueOf((Decimal) wc.get('convertedCurrency') + ',' + String.valueOf(wc.Id) + ',' + String.valueOf(orderId));
        ar.currencyIsoCode = wc.CurrencyIsoCode;

        ConnectApi.PaymentGroupRequest pgr = new ConnectApi.PaymentGroupRequest();
        pgr.sourceObjectId = orderId;
        pgr.currencyIsoCode = wc.CurrencyIsoCode;
        pgr.createPaymentGroup = true;
        ar.paymentGroup = pgr;

        ConnectApi.SaleApiPaymentMethodRequest authApiPMRequest = new ConnectApi.SaleApiPaymentMethodRequest();
        authApiPMRequest.address = new ConnectApi.AddressRequest();
        // authApiPMrequest.address.street = pw.address.street;
        // authApiPMrequest.address.city = pw.address.city;
        // authApiPMrequest.address.state = pw.address.state;
        // authApiPMrequest.address.postalCode = pw.address.postalCode;
        // authApiPMrequest.address.country = pw.address.country;
        authApiPMrequest.address.street = wc.BillingStreet;
        authApiPMrequest.address.city = wc.BillingCity;
        authApiPMrequest.address.state = wc.BillingState;
        authApiPMrequest.address.postalCode = wc.BillingPostalCode;
        authApiPMrequest.address.country = wc.BillingCountry;
        authApiPMrequest.saveForFuture = true;

        ConnectApi.CardPaymentMethodRequest cpmRequest = new ConnectApi.CardPaymentMethodRequest();
        if (pw.cardType == 'MasterCard') {
            pw.cardType = 'Master Card';
        }
        if(pw.cardType == 'Discover'){
            pw.cardType = 'Visa';
            originalCardType = 'Discover';
        }
        Blob decodePayload = EncodingUtil.base64Decode(pw.token.split('\\.')[1]);
        String jsonPayload = decodePayload.toString();
        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        String maskedValue = (String) ((Map<String,Object>)((Map<String, Object>) ((Map<String, Object>) ((Map<String, Object>) payloadMap.get('content')).get('paymentInformation')).get('card')).get('number')).get('maskedValue');
        cpmRequest.cardNumber = maskedValue.replace('X', '0');
        cpmRequest.expiryYear = pw.expiryYear;
        cpmRequest.expiryMonth = pw.expiryMonth;
        cpmRequest.cardHolderFirstName = pw.cardHolderFirstName;
        cpmRequest.cardHolderLastName = pw.cardHolderLastName;
        cpmRequest.cardHolderName = pw.cardHolderFirstName + ' ' + pw.cardHolderLastName;
        cpmRequest.cardType = 'Visa';   //pw.cardType;
        cpmRequest.cardCategory = ConnectApi.CardCategory.CreditCard;
        authApiPMRequest.cardPaymentMethod = cpmRequest;
        ar.paymentMethod = authApiPMRequest;

        ar.additionalData = new Map<String, String>();
        splitTokenSale(ar, pw.token);
        try {
            if(Test.isRunningTest()){
                return 'Success';
            }
            ConnectApi.SaleResponse response = ConnectApi.Payments.sale(ar);
            Order orderObj = new Order();
            orderObj.Id = orderId;
            orderObj.Original_Card_Type__c = originalCardType;
            update orderObj;
            return 'Success';
        } catch(ConnectApi.ConnectApiException e) {
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(e.getMessage());
            Map<String, Object> output = (Map<String, Object>) errorMap.get('output');
            Map<String, Object> gatewayResponse = (Map<String, Object>) output.get('gatewayResponse');
            String errorMsg;
            if(gatewayResponse != null) errorMsg = (String) gatewayResponse.get('gatewayResultCodeDescription');
            else errorMsg = e.getMessage();
            return errorMsg;
        }
    }

    //Split the Transient Token into smaller chunks due to 1000 character limit on additionalData values
    private static void splitToken (ConnectApi.AuthorizationRequest request, String token) {
        Decimal VALUE_LIMIT = 1000.00;
        Integer numOfChunks = Integer.valueOf(Math.ceil(token.length()/VALUE_LIMIT));
        
        for(Integer i = 0 ; i < numOfChunks ; i++) {
            Integer lowerLimit = Integer.valueOf(i * VALUE_LIMIT);
            Integer upperLimit = Integer.valueOf((i + 1) * VALUE_LIMIT);
            if(upperLimit > token.length()) {
                upperLimit = token.length();
            }
            String tokenChunk = token.substring(lowerLimit, upperLimit);
            request.additionalData.put(String.valueOf(i), tokenChunk);
        }
    }

    private static void splitTokenSale(ConnectApi.SaleRequest request, String token){
        Decimal VALUE_LIMIT = 1000.00;
        Integer numOfChunks = Integer.valueOf(Math.ceil(token.length()/VALUE_LIMIT));
        
        for(Integer i = 0 ; i < numOfChunks ; i++) {
            Integer lowerLimit = Integer.valueOf(i * VALUE_LIMIT);
            Integer upperLimit = Integer.valueOf((i + 1) * VALUE_LIMIT);
            if(upperLimit > token.length()) {
                upperLimit = token.length();
            }
            String tokenChunk = token.substring(lowerLimit, upperLimit);
            request.additionalData.put(String.valueOf(i), tokenChunk);
        }
    }
}