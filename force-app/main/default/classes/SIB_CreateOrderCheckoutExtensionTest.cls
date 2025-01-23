/**
 * @description       : Test class for @SIB_CreateOrderCheckoutExtension
 * @author            : vramachandran@rafter.one
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : vramachandran@rafter.one
**/
@isTest
public class SIB_CreateOrderCheckoutExtensionTest {
    
    private static final String ACCOUNT_NAME = 'My Test Account';
    private static final String WEBSTORE_NAME = 'My Test WebStore';
    private static final String CART_NAME = 'My Test Cart';

    @TestSetup
    static void testDataSetup() {
        
        final String accountName = ACCOUNT_NAME;
        final String webStoreName = WEBSTORE_NAME;
        final String cartName = CART_NAME;
        final Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Schema.Account testAccount = new Schema.Account(LastName=accountName, RecordTypeId=personAccountRecordTypeId);
        insert testAccount;
        Schema.WebStore testWebStore = new Schema.WebStore(Name=webStoreName);
        insert testWebStore;
        Schema.Account account = [SELECT Id FROM Account WHERE id=:testAccount.Id LIMIT 1];
        Schema.WebStore webStore = [SELECT Id FROM WebStore WHERE id=:testWebStore.Id LIMIT 1];
        PaymentAuthorization paymentAuthRecord = getPaymentAuthorization(testAccount.Id);
        Schema.WebCart testCart = new WebCart(Name=cartName, WebStoreId=webStore.Id, AccountId=account.Id, 
                                              PaymentMethodId = paymentAuthRecord?.PaymentMethodId,
                                             PaymentGroupId = paymentAuthRecord?.PaymentGroupId);

        insert testCart;

        
        Product2 parentProduct = createSimpleProduct('parentProduct', 'parentProduct001');
        Product2 secondaryProduct = createSimpleProduct('secondaryProduct', 'secondaryProduct001');
        Product2 tertiaryProduct = createSimpleProduct('tertiaryProduct', 'tertiaryProduct001');
        Product2 quaternaryProduct = createSimpleProduct('quaternaryProduct', 'quaternaryProduct001');
        Product2 quinaryProduct = createSimpleProduct('quinaryProduct', 'quinaryProduct001');
        
        OrderDeliveryMethod orderDeliveryMethodRecord = createOrderDeliveryMethod(); 
        CartDeliveryGroup cartDeliveryGroupRecord = createCartDeliveryGroup(testCart?.Id, orderDeliveryMethodRecord?.Id);

        createCartItem(testCart, cartDeliveryGroupRecord, parentProduct);
        createCartItem(testCart, cartDeliveryGroupRecord, secondaryProduct);
        
        createNewBundleProducts(parentProduct, secondaryProduct);
        createNewBundleProducts(secondaryProduct, tertiaryProduct);
        createNewBundleProducts(secondaryProduct, quaternaryProduct);
        createNewBundleProducts(parentProduct, quinaryProduct);
        
        
    }
    
    @isTest
    static void prepareRecievedDataTest() {
        List<WebCart> fetchedCarts = [SELECT Id from WebCart WHERE Name =: CART_NAME LIMIT 1 ];
        
        if(null != fetchedCarts && !fetchedCarts.isEmpty()) {
            
            WebCart fetchedCart = fetchedCarts[0];
            CartExtension.Cart cartObject = CartExtension.CartTestUtil.getCart(fetchedCart?.Id);
            
            CartExtension.CreateOrderRequest newOrderRequest = new CartExtension.CreateOrderRequest(cartObject, 'ABCD-ABCD-ORDER_REFS');
            
            Test.startTest();
            new SIB_CreateOrderCheckoutExtension().createOrder(newOrderRequest);
            //new SIB_CreateOrderCheckoutExtension().prepareRecievedData(newOrderRequest);
            Test.stopTest();
        }
    }
    
    
    private static Product2 createSimpleProduct(String productName, String stockKeepingUnit) {
        
        Product2 simpleProduct = new Product2(
            IsActive = true,
            Name = productName, 
            Family = 'Standard Price',
            ProductCode = 'CAS_TEST',
            StockKeepingUnit = stockKeepingUnit
            
        );
        
        insert simpleProduct;
        return simpleProduct;
    }
    
    private static OrderDeliveryMethod createOrderDeliveryMethod() 
    {
        OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(Name = 'Freight');
        insert orderDeliveryMethod;
        return orderDeliveryMethod;
    }
    
    private static CartDeliveryGroup createCartDeliveryGroup(String cartId, String deliveryMethodId){
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(Name = 'Test Delivery',
                                                                    CartId = cartId,
                                                                    DeliverToName ='test Delivery',
                                                                    DesiredDeliveryDate = DateTime.now(),
                                                                    DeliveryMethodId = deliveryMethodId);
        insert cartDeliveryGroup;
        return cartDeliveryGroup;
        
    }
    
    public static CartItem createCartItem(WebCart cart, CartDeliveryGroup cartDeliveryGroup, Product2 p) 
    {
        List<CartItem> cartItems = new List<CartItem>();
        CartItem cartItem = new CartItem(
            CartId = cart.Id,
            Sku = p.ProductCode,
            SalesPrice = 10.00,
            Quantity = 3.0,
            Type = 'Product',
            Name = 'TestProduct',
            Listprice = 10.00,
            CartDeliveryGroupId = cartDeliveryGroup.Id,
            Product2Id = p.Id,
            TotalLineAmount = 30.00
        );
        insert cartItem;
        return cartItem;
        
    }
    
    
    private static PaymentAuthorization getPaymentAuthorization(String accountId) {
        PaymentGroup paymentGrpRecord = new PaymentGroup();
        insert paymentGrpRecord;
        
        PaymentAuthorization paymentAuth = new PaymentAuthorization();
        paymentAuth.Amount = 100.00;
        paymentAuth.ProcessingMode = 'External';
        paymentAuth.Status = 'Draft'; 
        paymentAuth.PaymentGroup = paymentGrpRecord;
        paymentAuth.PaymentGroupId = paymentGrpRecord?.Id;
        PaymentAuth.AccountId = accountId;
        
        AlternativePaymentMethod newPM = new AlternativePaymentMethod(Status='Active', ProcessingMode = 'External');
		insert newPM;
        paymentAuth.PaymentMethodId = newPM.Id;
        insert paymentAuth;
        
        
        return paymentAuth;
    }
    
    private static void createNewBundleProducts(Product2 parentProduct, Product2 childProduct) {
        
        Bundle_Item__c newBundleItem = new Bundle_Item__c(Bundle_Parent_Item__c = parentProduct?.Id, Bundle_Item__c = childProduct?.Id, Quantity__c =2 , CurrencyIsoCode = 'USD');
        insert newBundleItem;
    }
}