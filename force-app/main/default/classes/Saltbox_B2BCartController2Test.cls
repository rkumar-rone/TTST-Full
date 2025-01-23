@isTest(SeeAllData=true)
public with sharing class Saltbox_B2BCartController2Test {
    static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        BuyerAccount buyerAccount = new BuyerAccount(Name='Test Buyer Account', BuyerId=testAccount.Id, CurrencyIsoCode='USD', IsActive = true);
        insert buyerAccount;
        BuyerGroup buyerGrp = new BuyerGroup();
        buyerGrp.Name = 'AcmeTest';
        insert buyerGrp;
        BuyerGroupMember bgm = new BuyerGroupMember();
        bgm.BuyerGroupId = buyerGrp.Id;
        bgm.BuyerId = testAccount.Id;
        insert bgm;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(System.Label.Saltbox_Network_ID);
        WebStoreBuyerGroup wbg = new WebStoreBuyerGroup();
        wbg.BuyerGroupId = buyerGrp.Id;
        wbg.WebStoreId = webstoreId;
        insert wbg;
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebCart cart = new WebCart(Name='Test Cart', Status='Active', Type='Cart', WebStoreId=webStoreId, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.IsActive = true;
        prod.Description = 'test description';
        prod.ProductCode = '11111';
        prod.StockKeepingUnit = '11111';
        insert prod;
        CartItem cartItem = new CartItem(CartId=cart.Id, Product2Id=prod.Id, Sku='SKU_Test1', SalesPrice=10.00, Quantity=3.0, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
        CartItem cartItem2 = new CartItem(CartId=cart.Id, Product2Id=prod.Id, Sku='DELETE_Test1', SalesPrice=10.00, Quantity=3.0, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem2;
    }

    @isTest(SeeAllData=true)
    public static void getCartItemsTest() {
        setup();
        String webStoreId = System.Label.Saltbox_Network_ID;
        Account effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        String accountId = effectiveAccountId.Id;
        WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId.Id LIMIT 1];
        String activeCartId = activeCart.Id;
        
        ConnectApi.CartItemCollection result = Saltbox_B2BCartController2.getCartItems(
            webStoreId,
            accountId,
            activeCartId,
            null,
            'CreatedDateAsc'
        );

        // System.assertEquals(3, result.cartItems.size());
    }

    @isTest(SeeAllData=true)
    public static void updateCartItem(){
        setup();
        String webStoreId = System.Label.Saltbox_Network_ID;
        String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].id;
        WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId LIMIT 1];
        String activeCartId = activeCart.Id;
        String cartItemId = [SELECT Id FROM CartItem WHERE  Sku='SKU_Test1' LIMIT 1].Id;
        ConnectApi.CartItemInput cartItem = new ConnectApi.CartItemInput();
        cartItem.quantity = '3';

        ConnectApi.CartItem result = Saltbox_B2BCartController2.updateCartItem(
            webStoreId,
            effectiveAccountId,
            activeCartId,
            cartItemId,
            cartItem
        );

        // Assert.isNotNull(result, 'Expected a non-null result from the call');
    }
    @isTest(SeeAllData=true)
    public static void deleteCartItem(){
        setup();
        String webStoreId = System.Label.Saltbox_Network_ID;
        String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].id;
        WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId LIMIT 1];
        String activeCartId = activeCart.Id;
        String cartItemId = [SELECT Id FROM CartItem WHERE  Sku='DELETE_Test1' LIMIT 1].Id;

        Saltbox_B2BCartController2.deleteCartItem(
            webstoreId,
            effectiveAccountId,
            activeCartId,
            cartItemId
        );

        // Assert.isNotNull(result, 'Expected a non-null result from the call');
    }
    @isTest(SeeAllData=true)
    public static void getCartSummary(){
        setup();
        String webStoreId = System.Label.Saltbox_Network_ID;
        String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].Id;
        WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId LIMIT 1];
        String activeCartId = activeCart.Id;

        Saltbox_B2BCartController2.getCartSummary(
            webstoreId,
            effectiveAccountId,
            activeCartId
        );

        // Assert.isNotNull(result, 'Expected a non-null result from the call');
    }
    @isTest(SeeAllData=true)
    public static void deleteCart(){
        setup();
        String webStoreId = System.Label.Saltbox_Network_ID;
        String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].Id;
        WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId LIMIT 1];
        String activeCartId = activeCart.Id;

        Saltbox_B2BCartController2.deleteCart(
        webstoreId,
        effectiveAccountId,
        activeCartId
        );
    }

    @isTest(SeeAllData=true)
    public static void getCartPromotionsTest(){

        List<CartItemPriceAdjustment> cartAdjustment = [SELECT CartId FROM CartItemPriceAdjustment ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];

        if (cartAdjustment.size() > 0) {
            System.Test.startTest();
            Saltbox_B2BCartController2.getCartPromotions(cartAdjustment[0].CartId);
            System.Test.stopTest();
        }else {
            setup();
            String webStoreId = System.Label.Saltbox_Network_ID;
            String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].Id;
            WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId LIMIT 1];
            String activeCartId = activeCart.Id;

            System.Test.startTest();
            Saltbox_B2BCartController2.getCartPromotions(activeCartId);
            System.Test.stopTest();
        }
    }

    @isTest(SeeAllData=true)
    public static void calculatePromotionsTest(){
        setup();
        String webStoreId = System.Label.Saltbox_Network_ID;
        String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].Id;
        WebCart activeCart = [SELECT Id FROM WebCart WHERE AccountId=:effectiveAccountId LIMIT 1];
        String activeCartId = activeCart.Id;

        System.Test.startTest();
        Saltbox_B2BCartController2.calculatePromotions(activeCartId);
        System.Test.stopTest();
    }

}