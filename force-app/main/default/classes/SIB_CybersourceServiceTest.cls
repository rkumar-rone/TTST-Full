/**
 * @description       : 
 * @author            : vramchandran@rafter.one
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : vramachandran@rafter.com
**/
@isTest
public class SIB_CybersourceServiceTest {
    
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
    }
    
    @isTest
    static void getCyberSourcePaymentConfigurationTest() {

        Test.startTest();
        SIB_CybersourceService.getCyberSourcePaymentConfiguration();
        SIB_CybersourceService.setApiSettings();
        Test.stopTest();

    }
    
    @isTest
    static void splitTokenTest() {
        
        Test.startTest();
        ConnectApi.AuthorizationRequest baseRequest = new ConnectApi.AuthorizationRequest();
        String randomToken = generateRandomString(1200);
        SIB_CybersourceService.splitToken(baseRequest, randomToken);
        Test.stopTest();
    }
    
    @isTest
    static void generatePostRequestTest() {
        
        Test.startTest();

        SIB_CybersourceService.apiSecretKey = 'ZW5jb2RlZHZhbGx1ZQ==';
        String requestTarget = generateRandomString(100);
        String requestBody = generateRandomString(100);
        
        SIB_CybersourceService.generatePostRequest(requestTarget, requestBody);       
        Test.stopTest();
    }
    
    
    private static String generateRandomString(Integer length) {
        String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Pool of characters
        String result = '';
        Integer charactersLength = characters.length();
        
        for (Integer i = 0; i < length; i++) {
            // Pick a random character from the character pool and append it to the result string
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), charactersLength);
            result += characters.substring(randomIndex, randomIndex + 1);
        }
        
        return result;
    }
    
    
    @isTest
    static void createNewPaymentGroupRequestTest() {
        Test.startTest();
        SIB_CybersourceService.createNewPaymentGroupRequest();
        Test.stopTest();
    }
    
    @isTest
    static void createNewCaptureRequestTest() {
        PaymentAuthorization paymentAuthRecord = new PaymentAuthorization();
        PaymentGroup paymentGroupRecord = new PaymentGroup( Id = SIB_TestDataFactory.getMockId(Schema.PaymentGroup.sObjectType));
        paymentAuthRecord.PaymentGroupId = paymentGroupRecord?.Id;
        paymentAuthRecord.PaymentGroup = paymentGroupRecord;
        paymentAuthRecord.AccountId = SIB_TestDataFactory.getMockId(Schema.Account.sObjectType);
        paymentAuthRecord.Amount = 10.00;
        paymentAuthRecord.currencyIsoCode = 'USD';
        
        Test.startTest();
        SIB_CybersourceService.createNewCaptureRequest(paymentAuthRecord);
        Test.stopTest();
        
    }
    
    @isTest
    static void capturePaymentFromAuthorizationTest() {
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        
        insert paymentAuth;
        
        Map<String, Object> requestMap = new Map<String, Object>{
            SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID => paymentAuth?.Id
        };
        Map<String, Object> failRequestMap = new Map<String, Object> {
            SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID => ''
         };
        
        Test.startTest();
        SIB_CybersourceService.capturePaymentFromAuthorization(requestMap);
        SIB_CybersourceService.capturePaymentFromAuthorization(failRequestMap);
        Test.stopTest();
    }
    
    @isTest
    static void getAccountInformationTest() {
        
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        
        insert paymentAuth;
       
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>{
            SIB_Constants.PARAM_EFFECTIVEACCOUNTID => SIB_TestDataFactory.getMockId(Schema.Account.sObjectType)
        };
            
            SIB_CybersourceService.getAccountInformation(requestMap);
        Test.stopTest();
    }
    
    @isTest
    static void updatePaymentMethodOnCartTest() {
        PaymentGroup paymentGrpRecord = new PaymentGroup();
        insert paymentGrpRecord;
        
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        paymentAuth.PaymentGroup = paymentGrpRecord;
        //paymentAuth.PaymentMethodId = SIB_TestDataFactory.getMockId(Schema.PaymentMethod.sObjectType);
        
        
        insert paymentAuth;
        
        WebCart fetchedCart = getCurrentCart();
        Map<String, Object> requestMap = new Map<String, Object>{
            SIB_Constants.CARTID => fetchedCart?.Id,
            SIB_Constants.PARAM_PAYMENTAUTHID => paymentAuth?.Id,
            SIB_Constants.PARAM_ORIGINAL_CARD_TYPE => 'Discover'
        };
            
        Test.startTest();
		SIB_CybersourceService.updatePaymentMethodOnCart(requestMap);
        Test.stopTest();
    }
    
    @isTest
    static void getPaymentGatewayIdTest() {
        Test.startTest();
        SIB_CybersourceService.paymentGatewayId = SIB_TestDataFactory.getMockId(Schema.PaymentGateway.sObjectType);
        SIB_CybersourceService.getPaymentGatewayId();
        Test.stopTest();
    }
    
    @isTest
    static void testAddressMap() {
        String addressMapString = '{"street":"test","city":"city","region":"region","postalCode":"postalCode","country":"country"}';
        Map<String, Object> requestData = new Map<String, Object>{
            SIB_Constants.PARAM_ADDRESS_STRING => addressMapString
        };
        
        Test.startTest();
        SIB_CybersourceService.createAuthApiPaymentMethodRequest(requestData);
        Test.stopTest();
    }
    
    
    @isTest
    static void createNewPaymentGroupTest() {
        Map<String, Object> paymentMap = new Map<String, Object>();
        paymentMap.put(SIB_Constants.PARAM_CURRENCYISOCODE, 'USD');
        
        Test.startTest();
        SIB_CybersourceService.createNewPaymentGroup(paymentMap);
        Test.stopTest();
    }
    
    @isTest
    static void createNewAuthRequestTest() {
        String addressMapString = '{"street":"test","city":"city","region":"region","postalCode":"postalCode","country":"country"}';
        
        PaymentAuthorization paymentAuth = getPaymentAuthorization();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(SIB_Constants.PARAM_ADDRESS_STRING, addressMapString);
        requestMap.put(SIB_Constants.ACCOUNT_ID, SIB_TestDataFactory.getMockId(Schema.Account.sObjectType));
        requestMap.put(SIB_Constants.PARAM_AMOUNT, String.valueOf(100.00));
        requestMap.put(SIB_Constants.PARAM_CURRENCYISOCODE, 'USD');
        requestMap.put(SIB_Constants.PARAM_PAYMENT_AUTHORIZATION_ID, paymentAuth?.Id);
        requestMap.put(SIB_Constants.CARTID, SIB_TestDataFactory.getMockId(Schema.WebCart.sObjectType));
        
        System.debug('RequestMap:: '+ JSON.serializePretty(requestMap));
        
        Test.startTest();
        SIB_CybersourceService.authorizePayment(requestMap);
        SIB_CybersourceService.revertAuthorization(requestMap);
        SIB_CybersourceService.createNewAuthRequest(requestMap);
      
        Test.stopTest();
    }
    
    @isTest
    static void generateKeyTest() {
        Map<String, Object> requestMap = new Map<String, Object>();
		
        SIB_HttpCalloutMock mock = new SIB_HttpCalloutMock(new HttpRequest(), '{"status":"success", "message":"This is a custom response"}', 200 );
        
        Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();        
        SIB_CybersourceService.generateKey(requestMap);
        Test.stopTest();
    }
    
    @isTest
    static void getCartPaymentStatusTest() {
	PaymentAuthorization paymentAuth = getPaymentAuthorization();
       WebCart fetchedCart = getCurrentCart();
       fetchedCart.PaymentGroupId = paymentAuth.PaymentGroupId;
       //fetchedCart.PaymentMethodId = SIB_TestDataFactory.getMockId(Schema.PaymentMethod.sObjectType);
        
       update fetchedCart;
        
       Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(SIB_Constants.CARTID, fetchedCart?.Id);
        
        requestMap.put(SIB_Constants.MODULE_NAME, 'DoNotInvoiceMinimumTotal');
        
        Test.startTest();
        SIB_CybersourceService.getCartPaymentStatus(requestMap);
        SIB_CybersourceService.getPaymentModule(requestMap);
        
        Test.stopTest();
    }
    
    private static PaymentAuthorization getPaymentAuthorization() {
        PaymentGroup paymentGrpRecord = new PaymentGroup();
        insert paymentGrpRecord;
        
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        paymentAuth.PaymentGroup = paymentGrpRecord;
        paymentAuth.PaymentGroupId = paymentGrpRecord?.Id;
        PaymentAuth.AccountId = getCurrentAccount()?.Id;
        
        AlternativePaymentMethod newPM = new AlternativePaymentMethod(Status='Active', ProcessingMode = 'External');
		insert newPM;
        paymentAuth.PaymentMethodId = newPM.Id;
        insert paymentAuth;
        
        
        return paymentAuth;
    }
    
    @isTest
    static void createCardCaptureRequestTest() {
        String testToken = '\\.eyJpc3MiOiJGbGV4LzAwIiwiZXhwIjoxNzA2OTEwMjQyLCJ0eXBlIjoiZ2RhLTAuOS4wIiwiaWF0IjoxNzA2OTA5MzQ3LCJqdGkiOiIxRDFJMk8yQ1NUTVczVUlYT0tFUUZJNE9RWDFMN0NNU0tERTNMSjhCNURWWjZXQkpHS0xRNjVCRDYyMjJENDI2IiwiY29udGVudCI6eyJvcmRlckluZm9ybWF0aW9uIjp7ImJpbGxUbyI6e30sImFtb3VudERldGFpbHMiOnt9LCJzaGlwVG8iOnt9fSwicGF5bWVudEluZm9ybWF0aW9uIjp7ImNhcmQiOnsiZXhwaXJhdGlvblllYXIiOnsidmFsdWUiOiIyMDI4In0sIm51bWJlciI6eyJtYXNrZWRWYWx1ZSI6IlhYWFhYWFhYWFhYWDExMTEiLCJiaW4iOiI0MTExMTEifSwic2VjdXJpdHlDb2RlIjp7fSwiZXhwaXJhdGlvbk1vbnRoIjp7InZhbHVlIjoiMDYifSwidHlwZSI6eyJ2YWx1ZSI6IjAwMSJ9fX19fQ==';
        
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(SIB_Constants.PARAM_TOKEN, testToken);
        requestMap.put(SIB_Constants.PARAM_EXPIRATIONYEAR, '2024');
        requestMap.put(SIB_Constants.PARAM_EXPIRATIONMONTH, '04');
        requestMap.put(SIB_Constants.FIRSTNAME, 'TestFirst');
        requestMap.put(SIB_Constants.LASTNAME, 'TestLast');
        
        Test.startTest();
        SIB_CybersourceService.createCardPaymentMethodRequest(requestMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void getAuthorizationInformationTest() {
        PaymentAuthorization paymentAuthRecord = getPaymentAuthorization();
        
        
        List<PaymentAuthorization> paymentAuths = [SELECT Id, PaymentMethodId, PaymentGroupId 
                                                   FROM PaymentAuthorization 
                                                   WHERE CreatedDate = TODAY 
                                                   LIMIT 1];
        
        if(null != paymentAuths && !paymentAuths.isEmpty()) {
            
            paymentAuthRecord = paymentAuths[0];
        } 
        
        WebCart currentCart = getCurrentCart();
        currentCart.paymentMethodId = paymentAuthRecord?.PaymentMethodId;
        currentCart.paymentGroupId = paymentAuthRecord?.paymentGroupId;
        
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(SIB_Constants.PARAM_PAYMENT_METHODID, paymentAuthRecord?.PaymentMethodId);
        requestMap.put(SIB_Constants.PARAM_PAYMENT_GROUPID, paymentAuthRecord?.paymentGroupId);

        Test.startTest();
        SIB_CybersourceService.getAuthorizationInformation(requestMap);
        
        Test.stopTest();
    }
    
    private static WebCart getCurrentCart() {
        
        WebCart fetchedCart;
        List<WebCart> fetchedCarts = [SELECT Id, paymentMethodId, paymentGroupId FROM WebCart WHERE Name = :TEST_CART_NAME and CreatedDate = TODAY LIMIT 1];
        
        if(null != fetchedCarts && !fetchedCarts.isEmpty()) {

            fetchedCart = fetchedCarts[0];
        }        
        
        return fetchedCart;
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