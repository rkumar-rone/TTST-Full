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
    
}