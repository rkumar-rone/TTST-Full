/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-01-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CybersourcePaymentAdapterTest {
    
    private static final String TEST_CART_NAME = 'CybersourceTestCart';
    
    @TestSetup
    static void setupTestData() {
        
        final String accountName = 'TestAccount';
        final String webStoreName = 'Test WebStore';
        final String cartName = TEST_CART_NAME;
        final Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Schema.Account testAccount = new Schema.Account(LastName=accountName, RecordTypeId=personAccountRecordTypeId);
        insert testAccount;
        
        Schema.WebStore testWebStore = new Schema.WebStore(Name=webStoreName);
        insert testWebStore;
        
        Schema.WebCart testCart = new WebCart(Name=cartName, WebStoreId=testWebStore?.Id, AccountId=testAccount?.Id);
        insert testCart;
        
        getPaymentAuthorization();
    }
    
    @isTest
    static void responseMapTest() {
        
        Test.startTest();
        Map<String, Object> responseMap = SIB_CybersourcePaymentAdapter.responseMap;
        SIB_CybersourcePaymentAdapter.setApiSettings();
        SIB_CybersourcePaymentAdapter.setApiSettings();
       
        Test.stopTest();
        
    }
    
    @isTest
    static void authorizationRequestTest() {
        Test.startTest();
        SIB_CybersourcePaymentAdapter.setApiSettings();
        
        SIB_HttpCalloutMock newMock = new SIB_HttpCalloutMock(null, '{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "AUTHORIZED","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}', 201);
        Test.setMock(HttpCalloutMock.class, newMock);
        
        CyberSourcePaymentAdapter adapter = new CyberSourcePaymentAdapter();
        commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(100);
        authRequest.currencyIsoCode = 'USD';
        authRequest.comments = '100,zzz';
        authRequest.additionalData = new Map <String, String>{
            'token' => 'testToken'
                };
                    commercepayments.AuthApiPaymentMethodRequest paymentMethod = new commercepayments.AuthApiPaymentMethodRequest(getCardPaymentMethodRequest());
        paymentMethod.address = getAddressRequest();
        authRequest.paymentMethod = paymentMethod;
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
        
        commercepayments.paymentGatewayContext paymentContext = new commercepayments.paymentGatewayContext(authRequest,  Commercepayments.RequestType.Authorize);
        
        new SIB_CybersourcePaymentAdapter().processRequest(paymentContext);
        
        Test.stopTest();
    }
    
    @isTest
    static void capturePaymentForAuthorizationTest() {
        
        SIB_HttpCalloutMock newMock = new SIB_HttpCalloutMock(null, '{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "AUTHORIZED","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}', 201);
        Test.setMock(HttpCalloutMock.class, newMock);
       
        Test.startTest();

        String authId = getCurrentPaymentAuthRecordId('');

        commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(100, authId); 
        
        commercepayments.paymentGatewayContext paymentContext = new commercepayments.paymentGatewayContext(captureRequest,  Commercepayments.RequestType.Capture);
        
        new SIB_CybersourcePaymentAdapter().processRequest(paymentContext);
        Test.stopTest();
    }
    
    @isTest
    static void executePostAuthTest() {
        SIB_HttpCalloutMock newMock = new SIB_HttpCalloutMock(null, '{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "AUTHORIZED","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}', 201);
        Test.setMock(HttpCalloutMock.class, newMock);
        
        Test.startTest();
         
        Commercepayments.AlternativePaymentMethodRequest altPaymentMethodReq = new Commercepayments.AlternativePaymentMethodRequest('GatewayToken');
        Commercepayments.PostAuthApiPaymentMethodRequest apiPaymentMethod = new Commercepayments.PostAuthApiPaymentMethodRequest(altPaymentMethodReq);

        commercepayments.PostAuthorizationRequest postAuthRequest = new commercepayments.PostAuthorizationRequest(100);
        postAuthRequest.paymentMethod = apiPaymentMethod;          
        
        commercepayments.paymentGatewayContext paymentContext = new commercepayments.paymentGatewayContext(postAuthRequest,  Commercepayments.RequestType.PostAuth);
        
        new SIB_CybersourcePaymentAdapter().processRequest(paymentContext);
        
        Test.stopTest();
    }
   
    @isTest
    static void reversePaymentAuthorizationTest() {

        SIB_HttpCalloutMock newMock = new SIB_HttpCalloutMock(null, '{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "AUTHORIZED","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}', 201);
        Test.setMock(HttpCalloutMock.class, newMock);
        
        String authId = getCurrentPaymentAuthRecordId('');

        Test.startTest();
        CommercePayments.AuthorizationReversalRequest authReversalRequest = new CommercePayments.AuthorizationReversalRequest(100, authId);
        
        commercepayments.paymentGatewayContext paymentContext = new commercepayments.paymentGatewayContext(authReversalRequest,  Commercepayments.RequestType.AuthorizationReversal);
        
        new SIB_CybersourcePaymentAdapter().processRequest(paymentContext);
        Test.stopTest();
    }
    
    @isTest
    static void parseCaptureResponseTest() {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        
        responseMap.put(SIB_Constants.PARAM_STATUS, 'PENDING');
        
        Map<String, Object> orderInfo = new Map<String, Object>();
        responseMap.put(SIB_Constants.PARAM_ORDERINFORMATON, orderInfo);
        
        Map<String, Object> amountDetails = new Map<String, Object>();
        responseMap.put(SIB_Constants.PARAM_AMOUNTDETAILS, amountDetails);
        responseMap.put(SIB_Constants.PARAM_TOTALAMOUNT, '100');
        SIB_CybersourcePaymentAdapter.parseCaptureResponse(responseMap, new CommercePayments.CaptureResponse());
    }
    
    private static commercepayments.CardPaymentMethodRequest getCardPaymentMethodRequest() {
        
        commercepayments.CardPaymentMethodRequest cardRequest = new commercepayments.CardPaymentMethodRequest(CommercePayments.CardCategory.CreditCard);
        cardRequest.cardHolderFirstName = 'FirstName';
        cardRequest.cardHolderLastName  = 'LastName';
        
        return cardRequest;
    }
    
    private static PaymentAuthorization getPaymentAuthorization() {
        PaymentGroup paymentGrpRecord = new PaymentGroup();
        insert paymentGrpRecord;
        
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        paymentAuth.GatewayRefNumber = 'testgatewayreferencenumber';
        paymentAuth.PaymentGroup = paymentGrpRecord;
        paymentAuth.PaymentGroupId = paymentGrpRecord?.Id;
        PaymentAuth.AccountId = getCurrentAccount()?.Id;
        
        AlternativePaymentMethod newPM = new AlternativePaymentMethod(Status='Active', ProcessingMode = 'External');
        insert newPM;
        paymentAuth.PaymentMethodId = newPM.Id;
        insert paymentAuth;

        return paymentAuth;
    }
    
    private static String getCurrentPaymentAuthRecordId(String authorizationId) {
        
        String authId = '';
        List<PaymentAuthorization> paymentAuthList = [SELECT Id FROM PaymentAuthorization WHERE CreatedDate = TODAY LIMIT 1];
        if(null != paymentAuthList && !paymentAuthList.isEmpty()) {
            
			authId = paymentAuthList[0]?.Id;	            
        }
        
        return authId;
    }
    
    @isTest
    static void wrapperTest() {
        
        SIB_CybersourcePaymentAdapter.RequestWrapper wrapper = new SIB_CybersourcePaymentAdapter.RequestWrapper();
        wrapper.processingInformation = new SIB_CybersourcePaymentAdapter.ProcessingInformation();
        wrapper.orderInformation = new SIB_CybersourcePaymentAdapter.OrderInformation();
        wrapper.tokenInformation = new SIB_CybersourcePaymentAdapter.TokenInformation();
        wrapper.merchantDefinedInformation = new List<SIB_CybersourcePaymentAdapter.MerchantDefinedInformation>();
        wrapper.reversalInformation = new SIB_CybersourcePaymentAdapter.ReversalInformation();
        
        SIB_CybersourcePaymentAdapter.MerchantDefinedInformation merchant = new SIB_CybersourcePaymentAdapter.MerchantDefinedInformation();
        merchant.key = 'test';
        merchant.value = 'test';
        
        
        SIB_CybersourcePaymentAdapter.BillTo billTo = new SIB_CybersourcePaymentAdapter.BillTo();
        billTo.district = '';
        billTo.buildingNumber = '';
        billTo.phoneNumber = '';
        
        SIB_CybersourcePaymentAdapter.ReversalInformation reversal = new SIB_CybersourcePaymentAdapter.ReversalInformation();
        reversal.amountDetails = new SIB_CybersourcePaymentAdapter.AuthReversalAmount();
        reversal.billTo = new SIB_CybersourcePaymentAdapter.BillTo();
        
        SIB_CybersourcePaymentAdapter.ProcessingInformation process = new SIB_CybersourcePaymentAdapter.ProcessingInformation();
    }
    
    private static commercepayments.AddressRequest getAddressRequest() {
        
        commercepayments.AddressRequest newAddress = new commercepayments.AddressRequest('street1\nstreet2\nstreet3\nstreet4', 'city', 'state', 'country', 'postalcode');
        return newAddress;
    }
    
    private static Account getCurrentAccount() {
        Account fetchedAccount;
        
        List<Account> fetchedAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' and CreatedDate = TODAY LIMIT 1];
        if(null != fetchedAccounts && !fetchedAccounts.isEmpty()) {
            fetchedAccount = fetchedAccounts[0];
        }
        
        return fetchedAccount;
    }
}