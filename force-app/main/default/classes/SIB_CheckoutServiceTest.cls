@isTest
public class SIB_CheckoutServiceTest {
    
    private static Map<String, Object> dataMap = new Map<String, Object>();
    private static SIB_TestDataFactory factory;
    


    @isTest
    static void getCheckoutConfigurationTest() {

        Map<String, Object> requestMap = new Map<String, Object>();

        Map<String, Object> configJson = new Map<String, Object>();
        configJson.put('id', 'id');
        configJson.put('displayLayout', 'displayLayout');

        requestMap.put('configJSON', JSON.serialize(configJson));

        Test.startTest();
        
        SIB_CheckoutService.getCheckoutConfiguration(requestMap);
        
        Test.stopTest();
    }
    
    @isTest
    static void getGroupOrderInformationTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        Test.startTest();
        requestMap.put(SIB_Constants.CARTID, SIB_TestDataFactory.getMockId(WebCart.sObjectType));
        requestMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID, SIB_TestDataFactory.getMockId(Account.sObjectType));
        requestMap.put(SIB_Constants.WEBSTOREID, SIB_TestDataFactory.getMockId(WebStore.sObjectType));
        
        SIB_CheckoutService.getGroupOrderInformation(requestMap);
        Test.stopTest();
    }
    
    @isTest
    static void updateCartAndCartItemsTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        List<String> cartItemsId = new List<String>();
        cartItemsId.add(SIB_TestDataFactory.getMockId(CartItem.sObjectType));
        cartItemsId.add(SIB_TestDataFactory.getMockId(CartItem.sObjectType));
        cartItemsId.add(SIB_TestDataFactory.getMockId(CartItem.sObjectType));
        
        requestMap.put(SIB_Constants.PARAM_CARTTOUPDATE, SIB_TestDataFactory.getMockId(WebCart.sObjectType));
        requestMap.put(SIB_Constants.PARAM_ISWAITLISTED, false);
		requestMap.put(SIB_Constants.PARAM_ISGROUPORDER, false);
        requestMap.put(SIB_Constants.PARAM_CARTITEMSTOUPDATE, JSON.serialize(cartItemsId));
        
        Test.startTest();
        SIB_CheckoutService.updateCartAndCartItems(requestMap);
        Test.stopTest();
    }

    @isTest
    static void checkEmailIsAlreadyOnCollevaTest() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        Test.startTest();
        Group_Recepient__c gr = new Group_Recepient__c();
        // gr.Cart__c = SIB_TestDataFactory.getMockId(WebCart.sObjectType);
        gr.Recepient_Email__c = 'test1@yopmail.com';
        gr.Colleva_Id__c = 1;
        INSERT GR;
        List<SIB_CollevaAPIActiveProductsVO> activeProdList = new List<SIB_CollevaAPIActiveProductsVO>();
            SIB_CollevaAPIActiveProductsVO activeProd = new SIB_CollevaAPIActiveProductsVO();
            activeProd.externalId = 'test';
            activeProd.productName = '';
            activeProd.purchaseType = '';
            activeProd.usageType = '';
            activeProd.validUntil = '2029-05-23';
            activeProdList.add(activeProd);

            SIB_CollevaAPIDataVO dataVo = new SIB_CollevaAPIDataVO();
            dataVo.createdAt = '';
            dataVo.id = 1;
            dataVo.email = '';
            dataVo.hasUsageLeft = true;
            dataVo.minutesLeft = 5;
            dataVo.minutesLimit = 10;
            dataVo.sessionsLeft = 1;
            dataVo.sessionsLimit = 20;
            dataVo.isUnlimited = false;
            dataVo.updatedAt = '';
            dataVo.validUntil = '';
            dataVo.activeProducts = activeProdList;
        requestMap.put(SIB_Constants.CARTID, SIB_TestDataFactory.getMockId(WebCart.sObjectType));
        // requestMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID, SIB_TestDataFactory.getMockId(Account.sObjectType));
        // requestMap.put(SIB_Constants.WEBSTOREID, SIB_TestDataFactory.getMockId(WebStore.sObjectType));
        requestMap.put(SIB_Constants.EMAIL,gr.Recepient_Email__c);
        
        
        SIB_CheckoutService.checkEmailIsAlreadyOnColleva(requestMap);
        Test.stopTest();
    }

    @isTest
    static void checkEmailIsAlreadyOnCollevaTest2() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        SIB_Colleva_Details__c colldetail = new SIB_Colleva_Details__c();
        colldetail.Email__c = 'test1@yopmail.com';
        colldetail.Colleva_Id__c = 1;
        insert colldetail;
        List<SIB_CollevaAPIActiveProductsVO> activeProdList = new List<SIB_CollevaAPIActiveProductsVO>();
            SIB_CollevaAPIActiveProductsVO activeProd = new SIB_CollevaAPIActiveProductsVO();
            activeProd.externalId = 'test';
            activeProd.productName = '';
            activeProd.purchaseType = '';
            activeProd.usageType = '';
            activeProd.validUntil = '2029-05-23';
            activeProdList.add(activeProd);

            SIB_CollevaAPIDataVO dataVo = new SIB_CollevaAPIDataVO();
            dataVo.createdAt = '';
            dataVo.id = 1;
            dataVo.email = '';
            dataVo.hasUsageLeft = true;
            dataVo.minutesLeft = 5;
            dataVo.minutesLimit = 10;
            dataVo.sessionsLeft = 1;
            dataVo.sessionsLimit = 20;
            dataVo.isUnlimited = false;
            dataVo.updatedAt = '';
            dataVo.validUntil = '';
            dataVo.activeProducts = activeProdList;
        Test.startTest();
        requestMap.put(SIB_Constants.CARTID, SIB_TestDataFactory.getMockId(WebCart.sObjectType));
        // requestMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID, SIB_TestDataFactory.getMockId(Account.sObjectType));
        // requestMap.put(SIB_Constants.WEBSTOREID, SIB_TestDataFactory.getMockId(WebStore.sObjectType));
        requestMap.put(SIB_Constants.EMAIL,'test1@yopmail.com');
        
        
        SIB_CheckoutService.checkEmailIsAlreadyOnColleva(requestMap);
        SIB_CheckoutService.getCartItems(SIB_TestDataFactory.getMockId(WebCart.sObjectType));
        Test.stopTest();
    }

    @isTest
    static void checkEmailIsAlreadyOnCollevaTest3() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        Test.startTest();
        // requestMap.put(SIB_Constants.CARTID, SIB_TestDataFactory.getMockId(WebCart.sObjectType));
        // requestMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID, SIB_TestDataFactory.getMockId(Account.sObjectType));
        // requestMap.put(SIB_Constants.WEBSTOREID, SIB_TestDataFactory.getMockId(WebStore.sObjectType));
        // requestMap.put(SIB_Constants.EMAIL,'test1@yopmail.com');
        
        
        SIB_CheckoutService.checkEmailIsAlreadyOnColleva(requestMap);
        SIB_CheckoutService.checkCollevaProductsDetail(requestMap);
        Test.stopTest();
    }
    
}