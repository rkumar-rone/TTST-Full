/**
 * @description       : Test class for SIB_CartService
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CartServiceTest {

    @isTest
    public static void testGetCartConfigurationSuccess() {       
        List<SIB_CartConfiguration.ProductFields> productFieldsList = new List<SIB_CartConfiguration.ProductFields>();
        Map<String,Object> mockParams = new Map<String, Object>();
        SIB_CartConfiguration cartConfiguration = new SIB_CartConfiguration();
        cartConfiguration.id = 'cart123';
        cartConfiguration.type = 'ShoppingCart';
        cartConfiguration.cssTheme = 'default-theme';
        String jsonTestData = JSON.serialize(cartConfiguration);

        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        
        System.runAs(adminUser) {
            Test.startTest();
            SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
            testConfig.ConfigurationType__c = 'CART';
            testConfig.Active__c = true;
            testConfig.ConfigJSON__c  = jsonTestData;
            insert testConfig;

            Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
            BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
            Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
            Campaign ttsEvent = new Campaign();
            ttsEvent.Account__c  = testAccount.Id;
            ttsEvent.Name = 'Testtts Event';
            //insert ttsEvent;
            
            // Event_Relationship__c testEventRel = new Event_Relationship__c();
            //testEventRel.Parent__c = ttsEvent.Id;
            //insert testEventRel;
            product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
            testProduct.Colleva_Base_Product__c = false;
            testProduct.Colleva_Product__c = true;
            //testProduct.TTS_Event__c = ttsEvent.Id;
            update testProduct;
            WebStore testWebStore = SIB_TestDataFactory.createWebStore(true);
            
           
            Contact testContact = SIB_TestDataFactory.createContact(testAccount,true);
            // Session__c testSession = new Session__c();
            // testSession.Event__c = ttsEvent.Id;
            // insert testSession;
            // Session__c testSession2 = new Session__c();
            // testSession2.Event__c = ttsEvent.Id;
            // insert testSession2;
            WebCart testWebCart = SIB_TestDataFactory.createCart(testContact,adminUser,testWebStore,true);
            // testWebCart.Selected_Sessions__c =  '{' + testSession.Id + ',' + testSession2.Id + '}';
            // update testWebCart;
            CartDeliveryGroup testCDG = SIB_TestDataFactory.createCartDeliveryGroup(testWebCart,true);
            List<CartItem> testCartItems =  SIB_TestDataFactory.createCartItems(testWebCart,new List<Product2>{testProduct}, testCDG,true);

            mockParams.put(SIB_SetupConstants.CONFIG_JSON,jsonTestData);
            mockParams.put(SIB_Constants.CARTID,testWebCart.Id);
            mockParams.put(SIB_Constants.CART_ID,testWebCart.Id);
            mockParams.put(SIB_Constants.WEBSTOREID,testWebStore.Id);
            mockParams.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,testAccount.Id);
            mockParams.put(SIB_Constants.PARAM_QUANTITY,'2');
            mockParams.put(SIB_Constants.PARAM_ITEM_ID,testCartItems[0].Id);
            mockParams.put(SIB_Constants.PRODUCT_ID,testProduct.Id);
            mockParams.put(SIB_Constants.PARAM_CURRENCYISOCODE,'USD');
            mockParams.put(SIB_Constants.IS_CHECKOUT_PAGE,true);
            mockParams.put(SIB_Constants.PARAM_ISORDERFORSOMEONEELSE,'true');
            mockParams.put(SIB_Constants.PRODUCT_ID,testProduct.Id);

            
                    
            Map<String,Object> result = SIB_CartService.getCartConfiguration(mockParams);
            Map<String,Object> resultGetCartDetails = SIB_CartService.getCartDetails(mockParams);
            Map<String,Object> compareCurrency = SIB_CartService.compareCurrency(mockParams);   
            Map<String,Object> resultGetCartSummary = SIB_CartService.getCartSummary(mockParams);
            Map<String,Object> resultGetCartItems= SIB_CartService.getCartItems(mockParams);
            Map<String,Object> resultUpdateCartItem= SIB_CartService.updateCartItem(mockParams);
            SIB_CartService.copyCustomCartFields(testWebCart,testWebCart,true);
            Map<String,Object> updateCheckOutCartStatus = SIB_CartService.updateCheckOutCartStatus(mockParams);
            Map<String,Object> resultActivateCart= SIB_CartService.activateCart(mockParams);            
            Map<String,Object> resultAddCartItem= SIB_CartService.addCartItem(mockParams);
            Map<String,Object> resultPreserveGuestCart= SIB_CartService.preserveGuestCart(mockParams); 
            Map<String,Object> resultDeleteCartItem= SIB_CartService.deleteCartItem(mockParams);
            Map<String,Object> resultClearCart= SIB_CartService.clearCart(mockParams);   
            Map<String,Object> checkCollevaProductExistOnCart= SIB_CartService.checkCollevaProductExistOnCart(mockParams);         
            
            System.assertNotEquals(null, result, 'Result should not be null');        
            Test.stopTest();
        }
    }
}