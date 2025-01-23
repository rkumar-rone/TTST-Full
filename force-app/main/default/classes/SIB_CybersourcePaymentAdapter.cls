/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : Gaurav Setia
**/
global with sharing class SIB_CybersourcePaymentAdapter implements CommercePayments.PaymentGatewayAdapter {

    private static final String CLASSNAME = 'SIB_CybersourcePaymentAdapter';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Payment Module';
    
    // Salesforce Result Codes
    private static final CommercePayments.SalesforceResultCodeInfo RC_SUCCESS = toCodeInfo(CommercePayments.SalesforceResultCode.Success);
    private static final CommercePayments.SalesforceResultCodeInfo RC_DECLINE = toCodeInfo(CommercePayments.SalesforceResultCode.Decline);
    
    // Cybersource Response Codes
    private static final List<String> DECLINE_CODES = new List<String>{'AVS_FAILED','CONTACT_PROCESSOR','EXPIRED_CARD','PROCESSOR_DECLINED',
        'INSUFFICIENT_FUND','STOLEN_LOST_CARD','ISSUER_UNAVAILABLE','UNAUTHORIZED_CARD','CVN_NOT_MATCH','EXCEEDS_CREDIT_LIMIT','INVALID_CVN',
        'DECLINED_CHECK','BLACKLISTED_CUSTOMER','SUSPENDED_ACCOUNT','PAYMENT_REFUSED','CV_FAILED','INVALID_ACCOUNT','GENERAL_DECLINE',
        'INVALID_MERCHANT_CONFIGURATION','DECISION_PROFILE_REJECT','SCORE_EXCEEDS_THRESHOLD','PENDING_AUTHENTICATION','ACH_VERIFICATION_FAILED',
        'DECISION_PROFILE_REVIEW','CONSUMER_AUTHENTICATION_REQUIRED','CONSUMER_AUTHENTICATION_FAILED','MISSING_FIELD','INVALID_DATA',
        'DUPLICATE_REQUEST','INVALID_CARD','CARD_TYPE_NOT_ACCEPTED','INVALID_MERCHANT_CONFIGURATION','PROCESSOR_UNAVAILABLE','INVALID_AMOUNT',
        'INVALID_CARD_TYPE','INVALID_PAYMENT_ID','DEBIT_CARD_USEAGE_EXCEEDD_LIMIT'};

	private static String apiUrl = '';
    private static String merchantId = '';
    private static String apiKey = '';
    private static String apiSecretKey = '';
    private static String userEmail = '';
    private static String origin = '';
    private static String captureContext = '';
    private static String dateString = '';
    private static String allowedCardTypes = '';
    private static String apiHost = '';

    private static final String AUTHORIZATION_ENDPOINT = '/pts/v2/payments';
    private static final String SALE_ENDPOINT = '/pts/v2/payments';
    private static final String CAPTURE_PAYMENT_ENDPOINT = '/pts/v2/payments/{id}/captures';
    private static final String REVERSE_PAYMENT_ENDPOINT = '/pts/v2/payments/{id}/reversals';
    private static final String REQUEST_TYPE_AUTH = 'Auth';
    private static final String REQUEST_TYPE_POST_AUTH = 'PostAuth';
    private static final String REQUEST_TYPE_CAPTURE = 'Capture';
    private static final String REQUEST_TYPE_AUTHREVERSE = 'AuthReverse';
    
    private static SIB_Payment_Configuration__mdt paymentConfiguration; 
    private static CommercePayments.AuthApiPaymentMethodRequest  authApiPmRequest;

    global CommercePayments.GatewayResponse processRequest(CommercePayments.PaymentGatewayContext gatewayContext) {
        String methodName = 'processRequest';
        String supportData = '';
        CommercePayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        CommercePayments.GatewayResponse response;
        try {
            setApiSettings();
            if(requestType == CommercePayments.RequestType.Authorize) 
            {
                //authorize payment
                response = createPaymentAuthorization((CommercePayments.AuthorizationRequest) gatewayContext.getPaymentRequest());
            } else if (requestType == CommercePayments.RequestType.PostAuth) 
            {
                //Post Auth payment capture
                response = executePostAuth((CommercePayments.PostAuthorizationRequest) gatewayContext.getPaymentRequest());
            } else if(requestType == CommercePayments.RequestType.Capture) 
            {
                //capture payment from auth token
                response = capturePaymentForAuthorization((CommercePayments.CaptureRequest) gatewayContext.getPaymentRequest());
            } else if(requestType == CommercePayments.RequestType.AuthorizationReversal) 
            {
                //Reverse a payment authorization from given auth id
                response = reversePaymentAuthorization((CommercePayments.AuthorizationReversalRequest) gatewayContext.getPaymentRequest());
            }
            return response;
        } catch (CyberSourceValidationException expObject) 
        {
            SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
            return new CommercePayments.GatewayErrorResponse('400', expObject.getMessage());
        }
    }
    
    @TestVisible
    private static Map<String, Object> responseMap {
        get {
            if(null == responseMap) 
            {
                responseMap = new Map<String, Object>();
            }
            return responseMap;
        }
        private set;
    }

    @TestVisible
    private static void setApiSettings() {
        paymentConfiguration = SIB_CybersourceService.getCyberSourcePaymentConfiguration();
        apiUrl = SIB_SetupConstants.CYBERSOURCE_HEADER_HTTPS_PREFIX + paymentConfiguration.SIB_Stripe_Base_Endpoint_URL__c;
        merchantId = paymentConfiguration.SIB_Account_Id__c;
        apiKey = paymentConfiguration.SIB_Public_Key__c;
        apiSecretKey = paymentConfiguration.SIB_Secret_Key__c;
        userEmail = UserInfo.getUserEmail();
        origin = paymentConfiguration.SIB_TargetOrigins__c;
        allowedCardTypes = paymentConfiguration.SIB_AllowedCardNetworks__c;
        Datetime dt = Datetime.now();
        dateString = dt.format(SIB_SetupConstants.CYBERSOURCE_DATEFORMAT, SIB_SetupConstants.CYBERSOURCE_TZ_GMT);
        apiHost = paymentConfiguration.SIB_Host__c;
    }
    
    @TestVisible
    private static CommercePayments.SalesforceResultCodeInfo toCodeInfo(CommercePayments.SalesforceResultCode code) {
        return new CommercePayments.SalesforceResultCodeInfo(code);
    }

    @TestVisible
    private static CommercePayments.GatewayResponse createPaymentAuthorization(CommercePayments.AuthorizationRequest authRequest) {
        CommercePayments.AuthorizationResponse authResponse = new CommercePayments.AuthorizationResponse();
        authApiPmRequest = authRequest.paymentMethod;
        if(authRequest.amount != null)
        {
            authResponse.setAmount(authRequest.amount);
        } else 
        {
            throw new CyberSourceValidationException(System.Label.SIB_RequiredFieldMissing + ' ' + System.Label.SIB_Amount);
        }
        String token = getCompleteToken(authRequest);
        String endpointTarget = AUTHORIZATION_ENDPOINT;
        String authorizeEndpoint = apiUrl + endpointTarget;
        RequestWrapper wrapper = buildAuthRequestBody(authRequest, token);
        HttpResponse response = makePaymentCallout(authorizeEndpoint, endpointTarget, wrapper);
        String body = response.getBody();
		Map<String, Object> calloutResults = (Map<String, Object>) JSON.deserializeUntyped(body);
        parseAuthResponse(calloutResults, authResponse);
        return authResponse;
    }

    @TestVisible
    private static CommercePayments.PostAuthorizationResponse  executePostAuth(CommercePayments.PostAuthorizationRequest postAuthRequest) {
        CommercePayments.PostAuthApiPaymentMethodRequest apiPaymentMethod =(CommercePayments.PostAuthApiPaymentMethodRequest) postAuthRequest.paymentMethod;
        CommercePayments.AlternativePaymentMethodRequest altPaymentMethod= (CommercePayments.AlternativePaymentMethodRequest) apiPaymentMethod.alternativePaymentMethod;
        CommercePayments.PostAuthorizationResponse postAuthResponse = new CommercePayments.PostAuthorizationResponse();
        ConnectApi.PaymentGroupRequest paymentGroupRequest = new ConnectApi.PaymentGroupRequest();
        //Payment authorization id is passed as gateway token in altPaymentMethod
        String gatewayToken = (String) altPaymentMethod.gatewayToken;
        PaymentAuthorization paymentAuthRecord = getPaymentAuthorizationFromGatewayToken(gatewayToken);
        String gatewayRefNumber = paymentAuthRecord?.GatewayRefNumber;
        parsePostAuthCaptureResponse(paymentAuthRecord, postAuthResponse);
        return postAuthResponse;
    }

    @TestVisible
    private static CommercePayments.GatewayResponse capturePaymentForAuthorization(CommercePayments.CaptureRequest captureRequest) {
        CommercePayments.CaptureResponse captureResponse = new CommercePayments.CaptureResponse();
        if(captureRequest.amount != null )
        {
            captureResponse.setAmount(captureRequest.amount);
        }
        else
        {
            throw new  CyberSourceValidationException(System.Label.SIB_RequiredFieldMissing + ' ' + System.Label.SIB_Amount);
        }
        PaymentAuthorization paymentAuthRecord = getPaymentAuthorizationFromGatewayToken(captureRequest.paymentAuthorizationId);
        RequestWrapper wrapper = buildCaptureRequestBody(captureRequest, paymentAuthRecord);
        String gatewayRefNumber = paymentAuthRecord?.GatewayRefNumber;
        String endpointTarget = CAPTURE_PAYMENT_ENDPOINT.replace(SIB_SetupConstants.CYBERSOURCE_REPLACE_CHAR_ID, gatewayRefNumber);
        String endpoint = apiUrl + endpointTarget;
        HttpResponse response = makePaymentCallout(endpoint, endpointTarget, wrapper);
        String responseBody = response.getBody();
        Map<String, Object> calloutResults = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        calloutResults.put(SIB_Constants.PARAM_GATEWAY_TOKEN, gatewayRefNumber);        
        parseCaptureResponse(calloutResults, captureResponse);
        return captureResponse;
    }

    @TestVisible
    private static CommercePayments.GatewayResponse reversePaymentAuthorization(CommercePayments.AuthorizationReversalRequest authReversalRequest) {
        CommercePayments.AuthorizationReversalResponse authReversalResponse = new CommercePayments.AuthorizationReversalResponse();
        if(null != authReversalRequest || null != authReversalRequest?.amount)
        {
            authReversalResponse.setAmount(authReversalRequest.amount);
        } else
        {
            throw new CyberSourceValidationException(System.Label.SIB_RequiredFieldMissing + ' ' + System.Label.SIB_Amount);
        }
        PaymentAuthorization paymentAuthRecord = getPaymentAuthorizationFromGatewayToken(authReversalRequest.paymentAuthorizationId);
        RequestWrapper wrapper = buildReversalRequestBody(authReversalRequest, paymentAuthRecord);
        String gatewayRefNumber = paymentAuthRecord?.GatewayRefNumber;
        String endpointTarget = REVERSE_PAYMENT_ENDPOINT.replace(SIB_SetupConstants.CYBERSOURCE_REPLACE_CHAR_ID, gatewayRefNumber);
        String endpoint = apiUrl + endpointTarget;
        HttpResponse response = makePaymentCallout(endpoint, endpointTarget, wrapper);
        String responseBody = response.getBody();
        Map<String, Object> calloutResults = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        calloutResults.put(SIB_Constants.PARAM_GATEWAY_TOKEN, gatewayRefNumber);
        parseReversalResponse(calloutResults, authReversalResponse);
        return authReversalResponse;
    }

    @TestVisible 
    private static RequestWrapper buildReversalRequestBody(CommercePayments.AuthorizationReversalRequest authReversalRequest, PaymentAuthorization paymentAuthRecord) {
        RequestWrapper wrapper = buildNewRequestWrapper(REQUEST_TYPE_AUTHREVERSE);
        wrapper.clientReferenceInformation.code = createNewClientReferenceInformationCode(authReversalRequest);
        wrapper.orderInformation.amountDetails.currency_z =  'USD';
        wrapper.reversalInformation.amountDetails.totalAmount =  String.valueOf((Decimal)paymentAuthRecord.get(SIB_Constants.PARAM_CONVERTED_AMOUNT));//Change 29, Oct 24 to fetch amount from authorization 
        return wrapper;
    }

    @TestVisible
    private static void parseCaptureResponse(Map<String, Object> responseBody, CommercePayments.CaptureResponse captureResponse) {
        if((String) responseBody.get(SIB_Constants.PARAM_STATUS) != SIB_SetupConstants.CYBERSOURCE_STATUS_PENDING)
        {
            captureResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            captureResponse.setGatewayResultCodeDescription(JSON.serialize(responseBody));   
        }
        else
        {
            Map<String, Object> orderInformation = (Map<String,Object> )responseBody.get(SIB_Constants.PARAM_ORDERINFORMATON);
            Map<String, Object> amountDetails = ((Map<String, Object>) orderInformation.get(SIB_Constants.PARAM_AMOUNTDETAILS));
            captureResponse.setGatewayResultCode(SIB_Constants.PARAM_SUCCESS);
            captureResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        }
        captureResponse.setGatewayDate(System.now());
        captureResponse.setGatewayReferenceNumber(SIB_Constants.PARAM_SF_PREFIX+ randomGenerator(6));
    }

    @TestVisible
    private static void parseReversalResponse(Map<String, Object> responseBody, CommercePayments.AuthorizationReversalResponse authReversalResponse) {
        if((String) responseBody.get(SIB_Constants.PARAM_STATUS) != SIB_SetupConstants.CYBERSOURCE_STATUS_REVERSED)
        {
            authReversalResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            authReversalResponse.setGatewayResultCodeDescription(JSON.serialize(responseBody));   
        } else
        {
            authReversalResponse.setGatewayResultCode(SIB_Constants.PARAM_SUCCESS);
            authReversalResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            authReversalResponse.setGatewayReferenceDetails((String) responseBody.get('reconciliationId'));
        }
        authReversalResponse.setGatewayDate(System.now());
        authReversalResponse.setGatewayReferenceNumber(SIB_Constants.PARAM_SF_PREFIX+ randomGenerator(6));
    }

    @TestVisible
    private static void parsePostAuthCaptureResponse(PaymentAuthorization paymentAuthRecord, CommercePayments.PostAuthorizationResponse postAuthResponse){
        postAuthResponse.setGatewayAuthCode(paymentAuthRecord?.GatewayRefNumber);
        postAuthResponse.setGatewayResultCode(SIB_Constants.PARAM_SUCCESS);
        postAuthResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        postAuthResponse.setGatewayDate(System.now());
        postAuthResponse.setGatewayReferenceNumber(SIB_Constants.PARAM_SF_PREFIX + randomGenerator(6));
    }

    @TestVisible
    private static void parseAuthResponse(Map<String, Object> responseBody, CommercePayments.AuthorizationResponse authResponse) {
        CommercePayments.PaymentMethodTokenizationResponse pmTokenizationResponse = new CommercePayments.PaymentMethodTokenizationResponse();
        if((String)responseBody.get(SIB_Constants.PARAM_STATUS) == SIB_SetupConstants.CYBERSOURCE_STATUS_AUTHORIZED)
        {
            authResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            authResponse.setGatewayResultCodeDescription(SIB_SetupConstants.CYBERSOURCE_TRANSACTION_NORMAL);
        } else
        {
            authResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            Map<String, Object> errorInformation = (Map<String, Object>) responseBody.get(SIB_Constants.PARAM_ERRORINFORMATION);
            authResponse.setGatewayResultCodeDescription((String)errorInformation.get(SIB_Constants.PARAM_MESSAGE));
        }
        authResponse.setGatewayResultCode(SIB_SetupConstants.CYBERSOURCE_GATEWAYRESULTCODE_00);
        authResponse.setGatewayDate(System.now());
        authResponse.setGatewayReferenceNumber((String)responseBody.get(SIB_Constants.PARAM_ID));
    }

    @TestVisible
    private static RequestWrapper buildCaptureRequestBody(CommercePayments.PostAuthorizationRequest postAuthRequest, PaymentAuthorization paymentAuthRecord) {
        RequestWrapper wrapper = buildNewRequestWrapper(REQUEST_TYPE_POST_AUTH);
        wrapper.clientReferenceInformation.code = createNewClientReferenceInformationCode(postAuthRequest);
        wrapper.orderInformation.amountDetails.currency_z =  'USD';
        wrapper.orderInformation.amountDetails.totalAmount =  getConvertedCurrency(postAuthRequest); 
        return wrapper;
    }

    @TestVisible
    private static RequestWrapper buildCaptureRequestBody(CommercePayments.CaptureRequest captureRequest, PaymentAuthorization paymentAuthRecord) {
        RequestWrapper wrapper = buildNewRequestWrapper(REQUEST_TYPE_CAPTURE);
        wrapper.clientReferenceInformation.code = createNewClientReferenceInformationCode(captureRequest);
        wrapper.orderInformation.amountDetails.currency_z = 'USD';
        wrapper.orderInformation.amountDetails.totalAmount = String.valueOf((Decimal)paymentAuthRecord.get(SIB_Constants.PARAM_CONVERTED_AMOUNT));//Change 26, Oct 24 to fetch amount from authorization 
        return wrapper;
    }

    //build the json body for auth request
    @TestVisible
    private static RequestWrapper buildAuthRequestBody(CommercePayments.AuthorizationRequest authRequest, String transientToken) {
        RequestWrapper wrapper = buildNewRequestWrapper(REQUEST_TYPE_AUTH);
        wrapper.clientReferenceInformation.code = createNewClientReferenceInformationCode(authRequest);
        wrapper.tokenInformation.transientTokenJwt = transientToken;
        wrapper.orderInformation.amountDetails.currency_z = 'USD';
        wrapper.orderInformation.amountDetails.totalAmount = getConvertedCurrency(authRequest);
        wrapper.orderInformation.billTo = getBillToInformation(authRequest);
        return wrapper;
    }

    @TestVisible
    private static RequestWrapper buildNewRequestWrapper(String requestType) {
        RequestWrapper wrapper = new RequestWrapper();
        if(requestType == REQUEST_TYPE_AUTH || requestType == REQUEST_TYPE_POST_AUTH || requestType == REQUEST_TYPE_CAPTURE || requestType == REQUEST_TYPE_AUTHREVERSE)
        {
            wrapper.clientReferenceInformation =  new ClientReferenceInformation() ; 
        } 
        if(requestType == REQUEST_TYPE_AUTH || requestType == REQUEST_TYPE_POST_AUTH || requestType == REQUEST_TYPE_CAPTURE || requestType == REQUEST_TYPE_AUTHREVERSE)
        {
            wrapper.orderInformation = new OrderInformation();
            wrapper.orderInformation.amountDetails = new AmountDetails();
        }
        if(requestType == REQUEST_TYPE_AUTH )
        {
            wrapper.orderInformation.billTo = new BillTo();
            wrapper.tokenInformation = new TokenInformation();
        }
        if(requestType == REQUEST_TYPE_AUTHREVERSE)
        {
            wrapper.reversalInformation = new ReversalInformation();
            wrapper.reversalInformation.amountDetails = new AuthReversalAmount();
        }
        return wrapper;
    }

    @TestVisible
    private static String createNewClientReferenceInformationCode(CommercePayments.BaseRequest baseRequest) {
        if(null != baseRequest?.additionalData && !baseRequest?.additionalData?.isEmpty() 
           && baseRequest?.additionalData.containsKey(SIB_Constants.ORDER_REFERENCE_NUMBER) && null != baseRequest?.additionalData.get(SIB_Constants.ORDER_REFERENCE_NUMBER) )
        {
            String orderReferenceNumber = (String) baseRequest?.additionalData.get(SIB_Constants.ORDER_REFERENCE_NUMBER);
            return orderReferenceNumber;
        } else {
            Blob cryptoAesKey = Crypto.GenerateAESKey(128);
            String convertedHexValue = EncodingUtil.ConvertTohex(cryptoAesKey);
            String uniqueId = convertedHexValue.substring(0,8)+ '-' + convertedHexValue.substring(8,12) + '-' +
                                convertedHexValue.substring(12,16) + '-' +
                                convertedHexValue.substring(16,20) + '-' + convertedHexValue.substring(20);
            return uniqueId;
        }
    }

    @TestVisible
    private static BillTo getBillToInformation(CommercePayments.AuthorizationRequest authRequest) {
        BillTo billTo = new BillTo();
        billTo.firstName = authRequest.paymentMethod.cardPaymentMethod.cardHolderFirstName;
        billTo.lastName = authRequest.paymentMethod.cardPaymentMethod.cardHolderLastName;
        String[] addressLines = authRequest.paymentMethod.address.street.split(SIB_SetupConstants.CYBERSOURCE_SIGNATURE_NEWLINE);
        billTo.address1 = addressLines[0];
        if(addressLines.size() > 1)
        {
            billTo.address2 = addressLines[1];
        }
        if(addressLines.size() > 2)
        {
            billTo.address3 = addressLines[2];
        }
        if(addressLines.size() > 3)
        {
            billTo.address4 = addressLines[3];
        }
        billTo.locality = authRequest.paymentMethod.address.city;
        billTo.administrativeArea = authRequest.paymentMethod.address.state;
        billTo.postalCode = authRequest.paymentMethod.address.postalCode;
        billTo.country = authRequest.paymentMethod.address.country;
        billTo.email = UserInfo.getUserEmail();
        return billTo;
    }

    @TestVisible
    private static HttpResponse makePaymentCallout(String endpointUrl, String endpointTarget, RequestWrapper wrapper) {
        HttpRequest paymentRequest = new HttpRequest();
        paymentRequest.setEndpoint(endpointTarget);
        paymentRequest.setMethod(SIB_Constants.POST_METHOD);
        String requestBody = JSON.serialize(wrapper);
        requestBody = requestBody.replace(SIB_SetupConstants.CYBERSOURCE_TOKENINFO_NULL, SIB_Constants.PARAM_EMPTY_STRING);
        requestBody = requestBody.replace(SIB_SetupConstants.CYBERSOURCE_PROCESSINGINFO_NULL, SIB_Constants.PARAM_EMPTY_STRING);
        requestBody = requestBody.replace(SIB_SetupConstants.CYBERSOURCE_MERCHANTINFO_NULL, SIB_Constants.PARAM_EMPTY_STRING);
        requestBody = requestBody.replaceAll(SIB_SetupConstants.CYBERSOURCE_REVERSALINFO_NULL, SIB_Constants.PARAM_EMPTY_STRING);       
        requestBody = requestBody.replace(SIB_SetupConstants.CYBERSOURCE_BILLTO_NULL, SIB_Constants.PARAM_EMPTY_STRING);
        requestBody = requestBody.replaceAll(SIB_SetupConstants.CYBERSOURCE_CURRENCYZ, SIB_SetupConstants.CYBERSOURCE_CURRENCY);
        requestBody = requestBody.replaceAll(SIB_SetupConstants.CYBERSOURCE_AMOUNT_NULL, SIB_Constants.PARAM_EMPTY_STRING);
        requestBody = requestBody.replaceAll(SIB_SetupConstants.CYBERSOURCE_CURRENCY_NULL, SIB_Constants.PARAM_EMPTY_STRING);
        paymentRequest.setBody(requestBody);
        setHeaderParams(paymentRequest, endpointTarget);
        CommercePayments.PaymentsHttp http = new CommercePayments.PaymentsHttp();
        System.debug('paymentRequest'+paymentRequest);
        System.debug('requestBody'+requestBody);
        System.debug('endpointTarget'+endpointTarget);
        HttpResponse response = http.send(paymentRequest);
        return response;
    }

    @TestVisible
    private static void setHeaderParams(HttpRequest paymentRequest, String endpointTarget) {
        //required date format 'E, dd MMM yyyy HH:mm:ss z', 'GMT'
        String currentDateTimeStamp = Datetime.now().format(SIB_SetupConstants.CYBERSOURCE_DATEFORMAT, SIB_SetupConstants.CYBERSOURCE_TZ_GMT);
        String digest = getHeaderDigest(paymentRequest);
        getHeaderSignature(paymentRequest, digest, currentDateTimeStamp, endpointTarget);
    }

    @TestVisible
    private static String getHeaderDigest(HttpRequest paymentRequest) {
        Blob requestBody = paymentRequest.getBodyAsBlob();
        String digest = EncodingUtil.base64Encode(Crypto.generateDigest(SIB_SetupConstants.CYBERSOURCE_SHA256, requestBody));
        return SIB_SetupConstants.CYBERSOURCE_SHA256EQ + digest;
    }

    @TestVisible
    private static String getHeaderSignature(HttpRequest paymentRequest, String digest, String currentDateTimeStamp, string endpointTarget) {
        Map<String, String> signedHeaders = new Map<String, String>();
        signedHeaders.put(SIB_SetupConstants.CYBERSOURCE_ADAPTER_HOST, apiHost); //host
		signedHeaders.put(SIB_SetupConstants.CYBERSOURCE_ADAPTER_VCDATE, currentDateTimeStamp);//v-c-date
		signedHeaders.put(SIB_SetupConstants.CYBERSOURCE_ADAPTER_REQTARGET, SIB_SetupConstants.CYBERSOURCE_SIGNATURE_POST + SIB_SetupConstants.CYBERSOURCE_EMPTYSTRING + endpointTarget); //(request-target), 'post '
		signedHeaders.put(SIB_SetupConstants.CYBERSOURCE_HEADER_VCMERCHANTID, merchantId);//v-c-merchant-id
		signedHeaders.put(SIB_SetupConstants.CYBERSOURCE_ADAPTER_DIGEST, digest);//digest
        String signatureString = '';
		String headersString = '';
		for (String key : signedHeaders.keySet())
        {
			signatureString = signatureString + SIB_SetupConstants.CYBERSOURCE_SIGNATURE_NEWLINE + key + SIB_SetupConstants.CYBERSOURCE_ADAPTER_COLON + signedHeaders.get(key);
			headersString = headersString + SIB_SetupConstants.CYBERSOURCE_EMPTYSTRING + key;
		}
		signatureString = signatureString.substring(1,signatureString.length());
		headersString = headersString.substring(1,headersString.length());
		String algorithmName = SIB_SetupConstants.CYBERSOURCE_SIGNATURE_HMACSHA256;//Constant for 'HmacSHA256';
		Blob mac = Test.isRunningTest() ? Blob.valueOf(SIB_SetupConstants.CYBERSOURCE_SIGNATURE_KEYID) :
                                        Crypto.generateMac(algorithmName, Blob.valueOf(signatureString), EncodingUtil.base64Decode(apiSecretKey));
		String macUrl = EncodingUtil.base64Encode(mac);
		String signature =  SIB_SetupConstants.CYBERSOURCE_SIGNATURE_KEYID + apiKey + SIB_SetupConstants.CYBERSOURCE_ADAPTER_QTCMA // Set the headerkeyid="'     '", '
						+ SIB_SetupConstants.CYBERSOURCE_SIGNATURE_ALGORITHM_HMAC  //Set the header for 'algorithm="HmacSHA256", '
						+ SIB_SetupConstants.CYBERSOURCE_ADAPTER_HEADER + headersString + SIB_SetupConstants.CYBERSOURCE_ADAPTER_QTCMA //Set the header for 'headers="''", '
						+ SIB_SetupConstants.CYBERSOURCE_SIGNATURE_SIGNATUREEQ + macUrl + SIB_SetupConstants.CYBERSOURCE_ADAPTER_QT;
        paymentRequest.setHeader(SIB_SetupConstants.CYBERSOURCE_ADAPTER_HOST, apiHost);
        paymentRequest.setHeader(SIB_SetupConstants.CYBERSOURCE_ADAPTER_SIGNATURE, signature); //Set the header parameter 'signature'
        paymentRequest.setHeader(SIB_SetupConstants.CYBERSOURCE_ADAPTER_DIGEST, digest); //Set the header parameter 'digest'
        paymentRequest.setHeader(SIB_SetupConstants.CYBERSOURCE_HEADER_VCMERCHANTID, merchantId); //Set the header parameter 'v-c-merchant-id'
        paymentRequest.setHeader(SIB_SetupConstants.CYBERSOURCE_ADAPTER_VCDATE, currentDateTimeStamp); //Set the header parameter 'v-c-date'
        paymentRequest.setHeader(SIB_SetupConstants.CONTENTTYPE, SIB_SetupConstants.APPLICATION_JSON); //Set the header parameter 'Content-type' and value 'application/json'
        return signature;
    }

    //get the token sent in request as addtional data
    @TestVisible
    private static String getCompleteToken(CommercePayments.AuthorizationRequest authRequest) {
        Integer keyCount = authRequest.additionalData.keySet().size();
		String finalToken = '';
		for(Integer i = 0 ; i < keyCount ; i++) finalToken += authRequest.additionalData.get(String.valueOf(i));
        return finalToken;
    }
    
    @TestVisible
    private static String getConvertedCurrency(CommercePayments.BaseRequest baseRequest) {
        System.debug('baseRequest::' + baseRequest);
        String convertedAmount ;
        if(null != baseRequest?.additionalData && !baseRequest?.additionalData?.isEmpty() 
           && baseRequest?.additionalData.containsKey(SIB_Constants.CARTID) && null !=  (String)baseRequest?.additionalData.get(SIB_Constants.CARTID) )
        {
            String cartId = (String) baseRequest?.additionalData.get(SIB_Constants.CARTID);
            System.debug('cartId:: ' + cartId);
            WebCart fetchedCart = SIB_CybersourceSelector.getConvertedWebCartCurrency(cartId);
            System.debug('fetchedCart::' + JSON.serialize(fetchedCart));
            convertedAmount = String.valueOf((Double) fetchedCart.get(SIB_Constants.PARAM_CONVERTED_AMOUNT));
        }
        return convertedAmount;
    }

    @TestVisible
    private static PaymentAuthorization getPaymentAuthorizationFromGatewayToken(String authroizationId) {
        
        return SIB_CybersourceSelector.getConvertedPaymentAuthorizationById(authroizationId);
    }

    @TestVisible
    private static String randomGenerator(Integer stringLength) {
        final Integer MAX = Integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.round(Math.random() * MAX)).leftPad(stringLength,'0');
    }

    public class RequestWrapper {
        public ClientReferenceInformation clientReferenceInformation {get;set;}
        public ProcessingInformation processingInformation {get;set;} 
        public OrderInformation orderInformation {get;set;} 
        public TokenInformation tokenInformation {get;set;}
        public List<MerchantDefinedInformation> merchantDefinedInformation {get;set;}
        public ReversalInformation reversalInformation {get;set;}
    }

    public class ClientReferenceInformation {
        public String code {get;set;}
    }

    public class ProcessingInformation {
        public Boolean capture {get;set;}
        //public List<String> actionList {get;set;}
        //public List<String> actionTokenTypes {get;set;}
    }

    public class OrderInformation {
        public AmountDetails amountDetails {get;set;}
        public BillTo billTo {get;set;} 
    }

    public class TokenInformation {
        public String transientTokenJwt {get;set;}
    }

    public class ReversalInformation {
        public AuthReversalAmount amountDetails {get;set;}
        public BillTo billTo {get;set;} 
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
        public String currency_z {get;set;} // string replace to reserved id: currency
    }

    public class AuthReversalAmount { 
        public String totalAmount {get;set;}
    }

    public class CyberSourceValidationException extends Exception {
    }

}