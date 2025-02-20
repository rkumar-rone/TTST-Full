/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Gaurav Setia
**/
@IsTest
public class SIB_B2BCartServiceTest {

    @IsTest
    public static void testGetCartSummary() {

        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        
        System.runAs(adminUser) {
          
            Test.startTest();
            SIB_CartConfiguration testData = new SIB_CartConfiguration();

            testData.id = 'cart123';
            testData.type = 'Cart';
            testData.cssTheme = 'dark-theme';
            testData.allowPromoCode = true;
            testData.showUniqueCount = false;
            testData.pageSize = 10;
            testData.showRemoveItemOption = true;
            testData.showMoreItemsOption = true;
            testData.showLineItemTotal = true;
            testData.showOriginalPrice = false;
            testData.showSKU = true;
            testData.showProductImage = true;
            testData.showPricePerUnit = true;
            testData.showActualPrice = true;
            testData.hideQuantitySelector = false;
            testData.showSavedAmount = false;
    
            testData.productFields = new List<SIB_CartConfiguration.ProductFields>();
            
            SIB_CartConfiguration.ProductFields productField1 = new SIB_CartConfiguration.ProductFields();
            productField1.showLabel = true;
            productField1.name = 'ProductName';
            productField1.label = 'Product Name';
    
            SIB_CartConfiguration.ProductFields productField2 = new SIB_CartConfiguration.ProductFields();
            productField2.showLabel = true;
            productField2.name = 'ProductPrice';
            productField2.label = 'Product Price';
    
            testData.productFields.add(productField1);
            testData.productFields.add(productField2);
            String jsonTestData = JSON.serialize(testData);

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
            insert ttsEvent;
            
            Event_Relationship__c testEventRel = new Event_Relationship__c();
            testEventRel.Parent__c = ttsEvent.Id;
            insert testEventRel;
            product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
            testProduct.TTS_Event__c = ttsEvent.Id;
            update testProduct;
            WebStore testWebStore = SIB_TestDataFactory.createWebStore(true);
            
           
            Contact testContact = SIB_TestDataFactory.createContact(testAccount,true);
            Session__c testSession = new Session__c();
            testSession.Event__c = ttsEvent.Id;
            insert testSession;
            Session__c testSession2 = new Session__c();
            testSession2.Event__c = ttsEvent.Id;
            insert testSession2;
            WebCart testWebCart = SIB_TestDataFactory.createCart(testContact,adminUser,testWebStore,true);
            testWebCart.Selected_Sessions__c =  '{' + testSession.Id + ',' + testSession2.Id + '}';
            update testWebCart;
            CartDeliveryGroup testCDG = SIB_TestDataFactory.createCartDeliveryGroup(testWebCart,true);
            List<CartItem> testCartItems =  SIB_TestDataFactory.createCartItems(testWebCart,new List<Product2>{testProduct}, testCDG,true);

            List<SIB_CartRequest.SIB_CartItemRequest> cartItemRequests = new List<SIB_CartRequest.SIB_CartItemRequest>();
            for (CartItem cartItem : testCartItems) {
                SIB_CartRequest.SIB_CartItemRequest cartItemRequest = new SIB_CartRequest.SIB_CartItemRequest();
                cartItemRequest.itemId = cartItem.Id;
                cartItemRequest.productId = cartItem.Product2Id;
                cartItemRequest.quantity = (Integer)cartItem.Quantity;
                cartItemRequest.unitPrice = cartItem.SalesPrice;
                cartItemRequests.add(cartItemRequest);
            }

            SIB_CartRequest cartRequest = new SIB_CartRequest();
            cartRequest.webstoreId = testWebStore.Id;
            cartRequest.accountId = testAccount.Id;
            cartRequest.cartId = testWebCart.Id;
            cartRequest.cartItems = cartItemRequests;
            cartRequest.couponCode = 'Test Coupon';
            // Test.stopTest();

            // Test.startTest();
            SIB_B2BCartService cartService = new SIB_B2BCartService();
            SIB_CartResponse createCart = cartService.createCart(cartRequest);
            SIB_CartResponse cartResponse = cartService.getCartSummary(cartRequest);
            SIB_CartResponse getCartItems = cartService.getCartItems(cartRequest);
            SIB_CartResponse addToCart = cartService.addToCart(cartRequest);
            SIB_CartResponse updateCartItem = cartService.updateCartItem(cartRequest);
            SIB_CartResponse repriceCart = cartService.repriceCart(cartRequest);
            SIB_CartResponse removeCartItem = cartService.removeCartItem(cartRequest);
            SIB_CartResponse getCartCoupons = cartService.getCartCoupons(cartRequest);
            SIB_CartResponse applyCoupon = cartService.applyCoupon(cartRequest);
            SIB_CartResponse clearCart = cartService.clearCart(cartRequest);
            Test.stopTest();
        
            System.assertNotEquals(null, cartResponse, 'Cart Response should not be null');
        }
       
    }
}