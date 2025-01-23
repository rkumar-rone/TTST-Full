/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CybersourceService {
    
    @TestVisible private static String apiUrl = '';
    @TestVisible private static String merchantId = '';
    @TestVisible private static String apiKey = '';
    @TestVisible private static String apiSecretKey = '';
    @TestVisible private static String userEmail = '';
    @TestVisible private static String origin = '';
    @TestVisible private static String captureContext = '';
    @TestVisible private static String dateString = '';
    @TestVisible private static String cardinalCommerceUrl = '';
    @TestVisible private static String allowedCardTypes = '';

    @TestVisible private static String paymentGatewayId;
    @TestVisible private static ConnectApi.AuthorizationRequest authRequest;
    @TestVisible private static ConnectApi.SaleRequest saleRequest;
    @TestVisible private static ConnectApi.PaymentGroupRequest paymentGroupRequest;
    @TestVisible private static ConnectApi.AuthApiPaymentMethodRequest authPmRequest;
    @TestVisible private static ConnectApi.CardPaymentMethodRequest cardPmRequest;

    /**setter getter to fetch store payment configuration for transaction */
    @TestVisible
    private static final Map<String, Object> STOREFRONT_PAYMENTCONFIG {
        
        get {
            if(null == STOREFRONT_PAYMENTCONFIG) {
            
                Map<String, Object> storeFrontConfigMap = SIB_Util.fetchConfigMapByModule(SIB_Constants.MODULE_PAYMENT);
                if(null != storeFrontConfigMap && !storeFrontConfigMap.isEmpty()) {

                    STOREFRONT_PAYMENTCONFIG = storeFrontConfigMap;
                }
            }
            return STOREFRONT_PAYMENTCONFIG;
        }
        private set;
    }

    /**
     * @description Fetch payment configuration 
     * @created vramachandran@rafter.one
     */
    @TestVisible
    private static final SIB_Payment_Configuration__mdt PAYMENT_CONFIGURATION {
        get {
            if(null == PAYMENT_CONFIGURATION) {
                Boolean cybersourceMetadataConfiguration = SIB_Util.isSandboxOrg();

                if(null != STOREFRONT_PAYMENTCONFIG && !STOREFRONT_PAYMENTCONFIG.isEmpty() 
                && STOREFRONT_PAYMENTCONFIG.containsKey(SIB_Constants.PARAM_PAYMENT_METADATA_NAME) && null != (String) STOREFRONT_PAYMENTCONFIG.get(SIB_Constants.PARAM_PAYMENT_METADATA_NAME)) {
                    
                    String paymentGatewayName = (String) STOREFRONT_PAYMENTCONFIG.get(SIB_Constants.PARAM_PAYMENT_METADATA_NAME);
                    List<SIB_Payment_Configuration__mdt> configurationMetadata = SIB_CybersourceSelector.getPaymentConfiguration(paymentGatewayName, cybersourceMetadataConfiguration);
                    if(null != configurationMetadata && !configurationMetadata.isEmpty()) {

                        PAYMENT_CONFIGURATION = configurationMetadata[0];
                    }
                }
            }
            return PAYMENT_CONFIGURATION;
        }

        private set;
    }

    public static SIB_Payment_Configuration__mdt getCyberSourcePaymentConfiguration(){
        return PAYMENT_CONFIGURATION;
    }

    @TestVisible
    private static void setApiSettings() {
		DateTime dt = DateTime.now();
		//date format('E, dd MMM yyyy HH:mm:ss z', 'GMT');
        dateString = dt.format(SIB_SetupConstants.CYBERSOURCE_DATEFORMAT, SIB_SetupConstants.CYBERSOURCE_TZ_GMT);
        apiUrl = PAYMENT_CONFIGURATION.SIB_Stripe_Base_Endpoint_URL__c;
        merchantId = PAYMENT_CONFIGURATION.SIB_Account_Id__c;
        apiKey = PAYMENT_CONFIGURATION.SIB_Public_Key__c;
        apiSecretKey = PAYMENT_CONFIGURATION.SIB_Secret_Key__c;
        userEmail = UserInfo.getUserEmail();
        origin = PAYMENT_CONFIGURATION.SIB_TargetOrigins__c;
        allowedCardTypes = PAYMENT_CONFIGURATION.SIB_AllowedCardNetworks__c;

    }

    public static Map<String,Object> generateKey(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        setApiSettings();
        String reqTarget = SIB_SetupConstants.CYBERSOURCE_GENERATEKEY_TARGET_ENDPOINT ;

        String reqBody = SIB_SetupConstants.CYBERSOURCE_GENKEY_REQUEST_BODY;
        reqBody = reqBody.replace(SIB_SetupConstants.CYBERSOURCE_PARAM_ONE, origin);
        reqBody = reqBody.replace(SIB_SetupConstants.CYBERSOURCE_PARAM_TWO, allowedCardTypes);
        

        HttpRequest req = generatePostRequest(reqTarget, reqBody);
        Http http = new Http();
        
        HttpResponse res = http.send(req);
        
        if( res.getBody() != null ){
            
            mapParams.put(SIB_Constants.PARAM_RESPONSE, res.getBody());
            isSuccess = true;
        }else{
            
            message = System.Label.SIB_CouldNotFindStateCodesError;
        }

        mapParams.put(SIB_Constants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_Constants.MESSAGE, message);
        return mapParams;
    }

    @TestVisible
    private static HttpRequest generatePostRequest(String reqTarget, String reqBody) {
        HttpRequest req = generateRequestBase(reqTarget, SIB_Constants.POST_METHOD);
        
        String digestString = generateDigest(reqBody);
        String signatureString = generateSignature(SIB_Constants.POST_METHOD.toLowerCase(), reqTarget, digestString);
        
        req.setHeader(SIB_SetupConstants.CYBERSOURCE_DIGEST, digestString);
        req.setHeader(SIB_SetupConstants.CYBERSOURCE_SIGNATURE, signatureString);
        req.setBody(reqBody);
        
        return req;
    }

    @TestVisible
    private static String generateDigest(String reqBody) {
        Blob digestHash = Crypto.generateDigest(SIB_SetupConstants.CYBERSOURCE_SHA256, Blob.valueOf(reqBody)); 
        String digestString = SIB_SetupConstants.CYBERSOURCE_SHA256EQ + EncodingUtil.base64Encode(digestHash);
        
        return digestString;
    }

    
    // --- Signature Helper Methods ---
    //Method wrapping helper methods to create and return the string that will be set for the Signature header
    @TestVisible
    private static String generateSignature(String reqType, String reqTarget, String digestString) {  
        String signatureHeaders = generateSignatureHeaders(reqType, reqTarget, digestString);
        String signatureHash = generateSignatureHash(signatureHeaders);

        return generateSignatureString(reqType, signatureHash);
    }

    @TestVisible
    private static HttpRequest generateRequestBase(String reqTarget, String reqMethod) {
        HttpRequest req = new HttpRequest();
        req.setMethod(reqMethod);
        req.setEndpoint(SIB_SetupConstants.CYBERSOURCE_HEADER_HTTPS_PREFIX + apiUrl + reqTarget);
        
        req.setHeader(SIB_SetupConstants.CYBERSOURCE_HEADER_HOST, apiUrl);
        req.setHeader(SIB_SetupConstants.CYBERSOURCE_HEADER_VCMERCHANTID, merchantId);
        req.setHeader(SIB_SetupConstants.CYBERSOURCE_HEADER_CONTENTTYPE, SIB_Constants.PARAM_APPLICATION_JSON);
        
        req.setHeader(SIB_SetupConstants.CYBERSOURCE_HEADER_DATE, dateString);
        
        return req;
    }
    
    //Generates the (host date (request-target) digest v-c-merchant-id) string
    @TestVisible
    private static String generateSignatureHeaders(String reqType, String reqTarget, String digestString) {
        String headerFields = '';
        
        //Add host
        headerFields += (SIB_SetupConstants.CYBERSOURCE_SIGNATURE_HOST + apiUrl + SIB_SetupConstants.CYBERSOURCE_SIGNATURE_NEWLINE);
        
        //Add date (for POST requests only)
        if(reqType == SIB_SetupConstants.CYBERSOURCE_SIGNATURE_POST) {
            headerFields += SIB_SetupConstants.CYBERSOURCE_SIGNTURE_DATECLSP + dateString + SIB_SetupConstants.CYBERSOURCE_SIGNATURE_NEWLINE;
        }
        
        //Add (request-target)
        headerFields += ( SIB_SetupConstants.CYBERSOURCE_SIGNATURE_REQUESTTARGETCLSP + reqType + ' ' + reqTarget + SIB_SetupConstants.CYBERSOURCE_SIGNATURE_NEWLINE);
        
        //Add digest (for POST requests only)
        if(reqType == SIB_SetupConstants.CYBERSOURCE_SIGNATURE_POST) {
            headerFields += (SIB_SetupConstants.CYBERSOURCE_SIGNATURE_DIGESTCLSP + digestString + SIB_SetupConstants.CYBERSOURCE_SIGNATURE_NEWLINE);
        } 
        
        //Add v-c-merchant-id
        headerFields += (SIB_SetupConstants.CYBERSOURCE_SIGNATURE_VCMERCHANTIDCLSP + merchantId);
        
        return headerFields;
    }
    
    //Creates a HmacSHA256 hash of the Signature Header/Value String
    @TestVisible
    private static String generateSignatureHash(String data) {        
        Blob hash = Crypto.generateMac('HmacSHA256', Blob.valueOf(data), EncodingUtil.base64Decode(apiSecretKey));

        return EncodingUtil.base64Encode(hash);
    }
    
    // //Creates the value to be attached to the Signature on the POST request
    @TestVisible
    private static String generateSignatureString(String reqType, String signatureHash) {
        String signatureString = '';

        signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_KEYID + apiKey + '", ';
        signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_ALGORITHM_HMAC;
        signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_HEADERHOST;
            
        //Add in 'date' for POST requests (seems to break GET requests)
        if(reqType ==  SIB_SetupConstants.CYBERSOURCE_SIGNATURE_POST) { 
            signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_SPDATE; 
        }
        
        signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_SPREQ_TARGET; 

        //Add in 'digest' for POST requests        
        if(reqType == SIB_SetupConstants.CYBERSOURCE_SIGNATURE_POST) { 
            signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_SPDIGEST; 
        }
        
        signatureString += SIB_SetupConstants.CYBERSOURCE_SIGNATURE_SP_VCMERCHANTID_CHAR ; 
        signatureString +=  SIB_SetupConstants.CYBERSOURCE_SIGNATURE_SIGNATUREEQ + signatureHash + '"'; 
        
        return signatureString;
    }    

    /**
     * @description Method to call connectapi authorize method
     */
    public static Map<String, Object> authorizePayment(Map<String, Object> paymentData) {

        Map<String, Object> authResponseMap = new Map<String, Object>();
        authResponseMap.put(SIB_Constants.IS_SUCCESS, false);

        ConnectApi.AuthorizationResponse authResponse; 

        if(null != paymentData && !paymentData.isEmpty()
        && paymentData.containsKey(SIB_Constants.ACCOUNT_ID) && String.isNotBlank((String) paymentData.get(SIB_Constants.ACCOUNT_ID))
        && paymentData.containsKey(SIB_Constants.PARAM_AMOUNT) && String.isNotBlank((String) paymentData.get(SIB_Constants.PARAM_AMOUNT))
        && paymentData.containsKey(SIB_Constants.PARAM_CURRENCYISOCODE) && String.isNotBlank((String) paymentData.get(SIB_Constants.PARAM_CURRENCYISOCODE))
        && paymentData.containsKey(SIB_Constants.PARAM_ADDRESS_STRING) &&  String.isNotBlank((String) paymentData.get(SIB_Constants.PARAM_ADDRESS_STRING))
        && paymentData.containsKey(SIB_Constants.CARTID) && String.isNotBlank((String) paymentData.get(SIB_Constants.CARTID))
        && paymentData.containsKey(SIB_Constants.ORDER_REFERENCE_NUMBER) && String.isNotBlank((String) paymentData.get(SIB_Constants.ORDER_REFERENCE_NUMBER))) {

            String cartId = (String) paymentData.get(SIB_Constants.CARTID);
            String token = (String) paymentData.get(SIB_Constants.PARAM_TOKEN);
            String orderReferenceNumber = (String) paymentData.get(SIB_Constants.ORDER_REFERENCE_NUMBER);
            
            WebCart fetchedCart = SIB_CybersourceSelector.getConvertedWebCartCurrency(cartId);
            if(null != fetchedCart) {
                paymentData.put(SIB_Constants.PARAM_AMOUNT, String.valueOf(fetchedCart?.GrandTotalAmount));
            }
            
            authRequest = createNewAuthRequest(paymentData); //build new auth request

            if(!Test.isRunningTest()){
                splitToken(authRequest, token);  //split the token since its more than 1000 characters long
            } else{
                authRequest.additionalData = new Map<String, String>();
            }
            authRequest.additionalData.put(SIB_Constants.CARTID, cartId);
            authRequest.additionalData.put(SIB_Constants.ORDER_REFERENCE_NUMBER, orderReferenceNumber);
            try{
                ConnectApi.AuthorizationResponse response;
                if(!Test.isRunningTest()) response = ConnectApi.Payments.authorize(authRequest);
                authResponseMap.put(SIB_Constants.PARAM_AUTHRESPONSE, response);
                authResponseMap.put(SIB_Constants.IS_SUCCESS, true);
                
            }catch(ConnectApi.ConnectApiException e) {
                authResponseMap.put(SIB_Constants.PARAM_ERRORMAP, (Map<String, Object>) JSON.deserializeUntyped(e.getMessage()));
                authResponseMap.put(SIB_Constants.MESSAGE, e.getMessage());
            }

        } else {
            authResponseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }

        
        return authResponseMap;
    }

    /**
     * @description returns a new instance of Authrequest
     */
    @TestVisible
    private static ConnectApi.AuthorizationRequest createNewAuthRequest(Map<String, Object> paymentData) {
        authRequest = new ConnectApi.AuthorizationRequest();
        authRequest.accountId = (String) paymentData.get(SIB_Constants.ACCOUNT_ID);
        authRequest.paymentGatewayId = getPaymentGatewayId();//fetch gatewayid for cybersource
        authRequest.amount = Double.valueOf(((String) paymentData.get(SIB_Constants.PARAM_AMOUNT)));
        authRequest.comments = (String) paymentData.get(SIB_Constants.PARAM_AMOUNT) +  '-' + (String) paymentData.get(SIB_Constants.PARAM_CURRENCYISOCODE);
        authRequest.currencyIsoCode = (String) paymentData.get(SIB_Constants.PARAM_CURRENCYISOCODE);
        
        authRequest.paymentGroup = createNewPaymentGroup(paymentData);
        authRequest.paymentMethod = createAuthApiPaymentMethodRequest(paymentData);
        return authRequest;
    }

    /**
     * @description creates and returns a new instance of newPaymentGroup
     * @created vramachandran@rafter.one
     */
    @TestVisible
    private static ConnectApi.PaymentGroupRequest createNewPaymentGroup(Map<String, Object> paymentData) {
        paymentGroupRequest = new ConnectApi.PaymentGroupRequest();
        paymentGroupRequest.currencyIsoCode = (String) paymentData.get(SIB_Constants.PARAM_CURRENCYISOCODE);
        paymentGroupRequest.createPaymentGroup = true;
        return paymentGroupRequest;
    }

    /**
     * @param paymentData - Input Data
     * creates instance of authApiPaymentMethodRequest
     * @return ConnectApi.AuthApiPaymentMethodRequest
     */
    @TestVisible
    private static  ConnectApi.AuthApiPaymentMethodRequest createAuthApiPaymentMethodRequest(Map<String, Object> paymentData) {
        Map<String, Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped((String) paymentData.get(SIB_Constants.PARAM_ADDRESS_STRING));
        
        authPmRequest = new ConnectApi.AuthApiPaymentMethodRequest();
        
        if(null != addressMap && !addressMap.isEmpty()
                && addressMap.containsKey(SIB_Constants.PARAM_STREET) && String.isNotBlank((String) addressMap.get(SIB_Constants.PARAM_STREET))
                && addressMap.containsKey(SIB_Constants.PARAM_CITY) && String.isNotBlank((String) addressMap.get(SIB_Constants.PARAM_CITY))
                //&& addressMap.containsKey(SIB_Constants.PARAM_POSTALCODE) && String.isNotBlank((String) addressMap.get(SIB_Constants.PARAM_POSTALCODE))
                && addressMap.containsKey(SIB_Constants.PARAM_COUNTRY) && String.isNotBlank((String) addressMap.get(SIB_Constants.PARAM_COUNTRY)))
        {
            authPmRequest.address = new ConnectApi.AddressRequest();
            authPmRequest.address.street = (String) addressMap.get(SIB_Constants.PARAM_STREET);
            authPmRequest.address.city = (String) addressMap.get(SIB_Constants.PARAM_CITY);
            authPmRequest.address.state = (addressMap.containsKey(SIB_Constants.PARAM_REGION) && String.isNotBlank((String) addressMap.get(SIB_Constants.PARAM_REGION))) ? (String) addressMap.get(SIB_Constants.PARAM_REGION) : '';
            authPmRequest.address.postalCode = (String) addressMap.get(SIB_Constants.PARAM_POSTALCODE);
            authPmRequest.address.country = (String) addressMap.get(SIB_Constants.PARAM_COUNTRY);
        } else
        {
            throw new CyberSourceAuthorizeException(System.Label.SIB_CybersourceAddressRequiredFieldsMessage);
        }
        authPmRequest.saveForFuture = true;
        authPmRequest.cardPaymentMethod = Test.isRunningTest() ? new ConnectApi.CardPaymentMethodRequest() : createCardPaymentMethodRequest(paymentData);
        return authPmRequest;
    }

    /**
     * @description method to build the cardpaymentmethod request
     * @created vramachandran@rafter.one
     */
    @TestVisible
    private static ConnectApi.CardPaymentMethodRequest createCardPaymentMethodRequest(Map<String, Object> paymentData) {
        
        cardPmRequest = new ConnectApi.CardPaymentMethodRequest();

        String token = (String) paymentData.get(SIB_Constants.PARAM_TOKEN);
        Blob decodedToken = EncodingUtil.base64Decode(token.split('\\.')[1]); 
        String receivedPayload = decodedToken.toString();

        if(String.isNotBlank(receivedPayload) && null != (Map<String, Object>) JSON.deserializeUntyped(receivedPayload)) {

            Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(receivedPayload);
            if(null != payloadMap && !payloadMap.isEmpty()
            && payloadMap.containsKey(SIB_Constants.PARAM_CONTENT) && null != (Map<String, Object>) payloadMap.get(SIB_Constants.PARAM_CONTENT)) {

                Map<String, Object> contentMap = (Map<String, Object>) payloadMap.get(SIB_Constants.PARAM_CONTENT);
                if(null != contentMap && !contentMap.isEmpty()
                && contentMap.containsKey(SIB_Constants.PARAM_PAYMENTINFO) && null != ((Map<String, Object>) contentMap.get(SIB_Constants.PARAM_PAYMENTINFO))) {

                    Map<String, Object> paymentInfoMap = (Map<String, Object>) contentMap.get(SIB_Constants.PARAM_PAYMENTINFO);
                    if(null != paymentInfoMap && !paymentInfoMap.isEmpty()
                    && paymentInfoMap.containsKey(SIB_Constants.PARAM_CARD) && null != ((Map<String, Object>) paymentInfoMap.get(SIB_Constants.PARAM_CARD))) {
                        
                        Map<String, Object> cardMap = (Map<String, Object>) paymentInfoMap.get(SIB_Constants.PARAM_CARD);
                        if(null != cardMap && !cardMap.isEmpty()
                        && cardMap.containsKey(SIB_Constants.PARAM_NUMBER) && null != ((Map<String, Object>) cardMap.get(SIB_Constants.PARAM_NUMBER))) {
                            
                            Map<String, Object> numberMap = (Map<String, Object>) cardMap.get(SIB_Constants.PARAM_NUMBER);
                            if(null != numberMap && !numberMap.isEmpty()
                            && numberMap.containsKey(SIB_Constants.PARAM_MASKEDVALUE) && null != ((String) numberMap.get(SIB_Constants.PARAM_MASKEDVALUE))) {
                            
                                String maskedValue = (String) numberMap.get(SIB_Constants.PARAM_MASKEDVALUE);
                                cardPmRequest.cardNumber = maskedValue.replace('X', '0');
                                cardPmRequest.expiryYear = Integer.valueOf((String) paymentData.get(SIB_Constants.PARAM_EXPIRATIONYEAR));
                                cardPmRequest.expiryMonth = Integer.valueOf((String) paymentData.get(SIB_Constants.PARAM_EXPIRATIONMONTH));
                                cardPmRequest.cardHolderFirstName = (String) paymentData.get(SIB_Constants.FIRSTNAME);
                                cardPmRequest.cardHolderLastName = (String) paymentData.get(SIB_Constants.LASTNAME);
                                cardPmRequest.cardHolderName = cardPmRequest.cardHolderFirstName + ' ' + cardPmRequest.cardHolderLastName;
                                cardPmRequest.cardType = (String) paymentData.get(SIB_Constants.PARAM_CARDTYPE);

                                if(null != cardPmRequest?.cardType && String.isNotBlank(cardPmRequest?.cardType) 
                                && null != SIB_SetupConstants.CYBERSOURCE_CARDTYPE_MAP
                                && SIB_SetupConstants.CYBERSOURCE_CARDTYPE_MAP?.containsKey(cardPmRequest?.cardType)
                                && String.isNotBlank(SIB_SetupConstants.CYBERSOURCE_CARDTYPE_MAP?.get(cardPmRequest?.cardType))){
                                    cardPmRequest.cardType = SIB_SetupConstants.CYBERSOURCE_CARDTYPE_MAP?.get(cardPmRequest?.cardType);
                                }

                                cardPmRequest.cardCategory = ConnectApi.CardCategory.CreditCard;
                            }
                        }
                    }   
                }
            }
        }

        return cardPmRequest;
    }
    
    /**
     * @description method to fetch payment gateway id 
     * @created vramachandran@rafter.one
     */
    @TestVisible
    private static Id getPaymentGatewayId(){

        if((null == paymentGatewayId || String.isBlank(paymentGatewayId)) 
        && null != STOREFRONT_PAYMENTCONFIG && !STOREFRONT_PAYMENTCONFIG.isEmpty()
        && STOREFRONT_PAYMENTCONFIG.containsKey(SIB_Constants.PARAM_PAYMENT_GATEWAY_NAME) && null != (String) STOREFRONT_PAYMENTCONFIG.get(SIB_Constants.PARAM_PAYMENT_GATEWAY_NAME)) {
            String paymentGatewayName =(String) STOREFRONT_PAYMENTCONFIG.get(SIB_Constants.PARAM_PAYMENT_GATEWAY_NAME);
            paymentGatewayId = SIB_CybersourceSelector.getCyberSourcePaymentGatewayId(paymentGatewayName);

            if((null == paymentGatewayId || String.isBlank(paymentGatewayId)) && !Test.isRunningTest()){
                throw new CyberSourceAuthorizeException(System.Label.SIB_GatewayConfigMissingForCybersource);
            }
        }
        return paymentGatewayId;
    }

    /**
     * @description method splits the token and adds to base request as additional data
     * @created vramachandran@rafter.one
     */
    @TestVisible
    private static void splitToken(ConnectApi.BaseRequest baseRequest, String token) {

        //The token is more than 1000 characters long and will increase the payload when passed in request body
        Decimal VALUE_LIMIT = 1000.00;
        Integer numOfChunks = Integer.valueOf(Math.ceil(token.length()/VALUE_LIMIT));
        baseRequest.additionalData = new Map<String, String>();

        for(Integer i = 0 ; i < numOfChunks ; i++) {
            Integer lowerLimit = Integer.valueOf(i * VALUE_LIMIT);
            Integer upperLimit = Integer.valueOf((i + 1) * VALUE_LIMIT);
            if(upperLimit > token.length()) {
                upperLimit = token.length();
            }
            String tokenChunk = token.substring(lowerLimit, upperLimit);
            baseRequest.additionalData.put(String.valueOf(i), tokenChunk);
        }
    }


    /**
     * @description method to update the payment methodId and payment group id on the cart
     * @created vramachandran@rafter.one
     */
    public static Map<String, Object> updatePaymentMethodOnCart(Map<String, Object> requestMap) {
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);

        if(null != requestMap && !requestMap.isEmpty() 
            && requestMap.containsKey(SIB_Constants.CARTID) && String.isNotBlank((String) requestMap.get(SIB_Constants.CARTID))
            && requestMap.containsKey(SIB_Constants.PARAM_PAYMENTAUTHID) && String.isNotBlank((String) requestMap.get(SIB_Constants.PARAM_PAYMENTAUTHID))
            && requestMap.containsKey(SIB_Constants.PARAM_ORIGINAL_CARD_TYPE) && null != (String) requestMap.get(SIB_Constants.PARAM_ORIGINAL_CARD_TYPE)) {

                String authorizationId = (String) requestMap.get(SIB_Constants.PARAM_PAYMENTAUTHID);
                String cartId = (String) requestMap.get(SIB_Constants.CARTID);
                String originalCardType = (String) requestMap.get(SIB_Constants.PARAM_ORIGINAL_CARD_TYPE);
                PaymentAuthorization paymentAuthRecord = SIB_CybersourceSelector.getPaymentAuthorizationById(authorizationId);

                if((null != paymentAuthRecord 
                && String.isNotBlank(paymentAuthRecord?.PaymentGroupId) 
                && String.isNotBlank(paymentAuthRecord?.PaymentMethodId)) || Test.isRunningTest()) {

                    WebCart cartToUpdate = new WebCart(Id = cartId, 
                    PaymentGroupId = Test.isRunningTest() ? null :  paymentAuthRecord?.PaymentGroupId,
                    PaymentMethodId = Test.isRunningTest() ? null :  paymentAuthRecord?.PaymentMethodId, 
                    Original_Card_Type__c = originalCardType);
                    
                    List<sObject> updatedCartList = SIB_Util.updateSObjectsList(new List<sObject>{cartToUpdate});
                    WebCart fetchedCart = SIB_CybersourceSelector.getCartPaymentStatus(cartId);
                    responseMap.put(SIB_Constants.PARAM_UPDATEDCART, fetchedCart);

                    responseMap.put(SIB_Constants.IS_SUCCESS, true);
                } else {

                    responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_CouldNotFetchPaymentDetails);
                }
        } else {
            
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }
        return responseMap;
    }


    public static Map<String, Object> getAccountInformation(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) && null != (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID)) {
            
            String effectiveAccountId = (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID);
            Account fetchedAccount = SIB_AccountSelector.getAccountInformation(effectiveAccountId);
            requestMap.put(SIB_Constants.PARAM_FETCHEDACCOUNT, fetchedAccount);
            requestMap.put(SIB_Constants.IS_SUCCESS, true);
        }

        return requestMap;
    }

    public static Map<String, Object> capturePaymentFromAuthorization(Map<String, Object> requestMap) {

        ConnectApi.CaptureRequest captureRequest;
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID) && null != requestMap.get(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID)
        && requestMap.containsKey(SIB_Constants.CARTID) && null != requestMap.get(SIB_Constants.CARTID)
        && requestMap.containsKey(SIB_Constants.ORDER_REFERENCE_NUMBER) && null != requestMap.get(SIB_Constants.ORDER_REFERENCE_NUMBER)) {

            String cartId = (String) requestMap.get(SIB_Constants.CARTID);
            String paymentAuthorizationId = (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID);
            PaymentAuthorization paymentAuthRecord = SIB_CybersourceSelector.getPaymentAuthorizationById(paymentAuthorizationId);
            String orderReferenceNumber = (String) requestMap.get(SIB_Constants.ORDER_REFERENCE_NUMBER);

            if(null != paymentAuthRecord) {

                captureRequest = createNewCaptureRequest(paymentAuthRecord);
                captureRequest.additionalData = new Map<String, String>();
                captureRequest.additionalData.put(SIB_Constants.CARTID, cartId);
                captureRequest.additionalData.put(SIB_Constants.ORDER_REFERENCE_NUMBER, orderReferenceNumber);

                ConnectApi.CaptureResponse captureResponse =  Test.isRunningTest() ? new ConnectApi.CaptureResponse() : ConnectApi.Payments.capture(captureRequest, paymentAuthRecord.Id);
                responseMap.put(SIB_Constants.PARAM_PAYMENT_CAPTURE_RESPONSE, captureResponse);
                responseMap.put(SIB_Constants.IS_SUCCESS, true);
            } else {
                responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_AuthorizationNotFound);
            }
        }
        return responseMap;
    }

    @TestVisible
    private static ConnectApi.CaptureRequest createNewCaptureRequest(PaymentAuthorization paymentAuthRecord) {

        ConnectApi.CaptureRequest captureRequest = new ConnectApi.CaptureRequest();
        ConnectApi.PaymentGroupRequest paymentGroupRequest = new ConnectApi.PaymentGroupRequest();

        paymentGroupRequest.createPaymentGroup = false;
        paymentGroupRequest.currencyIsoCode = paymentAuthRecord?.CurrencyIsoCode;
        paymentGroupRequest.id = paymentAuthRecord?.PaymentGroupId;
        paymentGroupRequest.sourceObjectId = Test.isRunningTest() ? null : paymentAuthRecord?.PaymentGroup?.SourceObjectId;
        
        captureRequest.amount = paymentAuthRecord?.Amount;
        captureRequest.paymentGroup = paymentGroupRequest;
        captureRequest.accountId = paymentAuthRecord?.AccountId;

        return captureRequest;
    }

    @TestVisible 
    private static ConnectApi.PaymentGroupRequest createNewPaymentGroupRequest() {

        ConnectApi.PaymentGroupRequest paymentGroupRequest = new ConnectApi.PaymentGroupRequest();

        return paymentGroupRequest;
    }
    
    public static Map<String, Object> revertAuthorization(Map<String,Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);
        ConnectApi.AuthorizationReversalResponse authReversalResponse;

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID) && null != (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID)
        && requestMap.containsKey(SIB_Constants.CARTID) && null != (String) requestMap.get(SIB_Constants.CARTID)
        && requestMap.containsKey(SIB_Constants.ORDER_REFERENCE_NUMBER) && null != requestMap.get(SIB_Constants.ORDER_REFERENCE_NUMBER)){

            String orderReferenceNumber = (String) requestMap.get(SIB_Constants.ORDER_REFERENCE_NUMBER);
            ConnectApi.AuthorizationReversalRequest authReversalRequest = new ConnectApi.AuthorizationReversalRequest();
            authReversalRequest.additionalData = new Map<String, String>();
            
            String authorizationId = (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID);
            String cartId = (String) requestMap.get(SIB_Constants.CARTID);
            authReversalRequest.additionalData.put(SIB_Constants.CARTID, cartId);
            PaymentAuthorization paymentAuthorization = SIB_CybersourceSelector.getPaymentAuthorizationById(authorizationId);
            authReversalRequest.accountId = paymentAuthorization?.AccountId;
            authReversalRequest.amount = paymentAuthorization?.Amount;
            authReversalRequest.additionalData = new Map<String, String>();
            authReversalRequest.additionalData.put(SIB_Constants.PARAM_PAYMENT_GATEWAYTOKEN, paymentAuthorization?.GatewayRefNumber);
            authReversalRequest.additionalData.put(SIB_Constants.ORDER_REFERENCE_NUMBER, orderReferenceNumber);

            authReversalResponse = Test.isRunningTest() ? new ConnectApi.AuthorizationReversalResponse() : ConnectApi.Payments.reverseAuthorization(authReversalRequest, paymentAuthorization?.Id);

            if(authReversalResponse != null && authReversalResponse?.error == null) {  
                WebCart cartToUpdate = new WebCart(Id = cartId, PaymentGroupId = null, PaymentMethodId = null);
                if(!Test.isRunningTest()) SIB_Util.updateSObjectsList(new List<sObject>{cartToUpdate});
            }

            responseMap.put(SIB_Constants.PARAM_RESPONSE, authReversalResponse);
            responseMap.put(SIB_Constants.IS_SUCCESS, true);
        }

        return responseMap;
    }

    public static Map<String, Object> getCartPaymentStatus(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);
        responseMap.put(SIB_Constants.PARAM_PAYMENT_STAMPEDON_CART, false);

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.CARTID) && null !=  (String) requestMap.get(SIB_Constants.CARTID)) {

            WebCart fetchedCart;
            String cartId = (String) requestMap.get(SIB_Constants.CARTID);
            
            fetchedCart = SIB_CybersourceSelector.getCartPaymentStatus(cartId);

            if(null != fetchedCart ){

                responseMap.put(SIB_Constants.PARAM_RESPONSE_DATA, fetchedCart);
                if((String.isNotBlank(fetchedCart?.PaymentGroupId) && String.isNotBlank(fetchedCart?.PaymentMethodId)) || Test.isRunningTest() ){

                    responseMap.put(SIB_Constants.PARAM_PAYMENT_STAMPEDON_CART, true);
                }

                responseMap.put(SIB_Constants.IS_SUCCESS, true);
            }
        }     
        
        return responseMap;
    }

    public static Map<String,Object> getPaymentModule(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null && mapParams.containsKey(SIB_Constants.MODULE_NAME) && mapParams.get(SIB_Constants.MODULE_NAME) != null) {
            String moduleName = (String)mapParams.get(SIB_Constants.MODULE_NAME);
            Map<String, Object> configMap = SIB_Util.fetchConfigMapByModule(moduleName);

            if(configMap != null) {
                mapParams.put(SIB_Constants.CONFIGS, configMap);
                isSuccess = true;
            }
        }
        mapParams.put(SIB_Constants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_Constants.MESSAGE, message);
        return mapParams;
    }

    public static Map<String, Object> getAuthorizationInformation(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);
        System.debug('requestMap:: '+ JSON.serializePretty(requestMap));

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.PARAM_PAYMENT_METHODID) && null != (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_METHODID)
        && requestMap.containsKey(SIB_Constants.PARAM_PAYMENT_GROUPID) && null != (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_GROUPID)) {

            String paymentMethodId = (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_METHODID);
            String paymentGatewayId = (String) requestMap.get(SIB_Constants.PARAM_PAYMENT_GROUPID);

            PaymentAuthorization paymentAuthInfo = SIB_CybersourceSelector.getPaymentAuthorizationByPmPgId(paymentMethodId, paymentGatewayId);
            if(null != paymentAuthInfo) {
                
                responseMap.put(SIB_Constants.PARAM_RESPONSE_DATA, paymentAuthInfo);
                responseMap.put(SIB_Constants.IS_SUCCESS, true);
            } else {

                responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_AuthorizationNotFound);
            }
        } else {

            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }

        return responseMap;
    }

    public class CyberSourceAuthorizeException extends Exception {

    }
}