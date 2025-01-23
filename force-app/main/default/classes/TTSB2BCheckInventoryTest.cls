@isTest
public class TTSB2BCheckInventoryTest {

    @TestSetup
    static void setup(){
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Seats_Available__c = 10);
        insert testCampaign;

        Session__c testSession = new Session__c(Name = 'Test Session', Event__c = testCampaign.Id);
        insert testSession;
        
        Product2 product = new Product2(
            IsActive = true, 
            Name = 'Test Product', 
            StockKeepingUnit = 'Test SKU', 
            Description = 'Test Description',
            TTS_Event__c = testCampaign.Id
        );

        insert product;
        
        insertCartItem(cart.Id, cartDeliveryGroup.Id, product.Id);
    }

    @isTest static void testTTSB2BCheckInventory_Success() {
        List<WebCart> lstCarts = new List<WebCart>([SELECT Id FROM WebCart LIMIT 1]);

        // Call the method to test
        List<TTSB2BCheckInventory.InventoryResult> results = TTSB2BCheckInventory.TTSB2BCheckInventory(new List<Id>{lstCarts.get(0).Id});

        // Verify the result
        Assert.areEqual(1, results.size(), 'There should be one result');
        Assert.areEqual(TTSB2BCheckInventory.STATUS_SUCCESS, results[0].status, 'The status should be Success');
    }

    @isTest static void testTTSB2BCheckInventory_Waitlist() {
        
        Campaign event = [SELECT Id FROM Campaign LIMIT 1];
        event.Seats_Available__c = 0;
        update event;

        List<WebCart> lstCarts = new List<WebCart>([SELECT Id FROM WebCart LIMIT 1]);

        // Call the method to test
        List<TTSB2BCheckInventory.InventoryResult> results = TTSB2BCheckInventory.TTSB2BCheckInventory(new List<Id>{lstCarts.get(0).Id});

        // Verify the result
        Assert.areEqual(1, results.size(), 'There should be one result');
        // Assert.isTrue(results.get(0).errorMessage.contains('Insufficient quantity'), 'The error message should be Insufficient quantity.');
        // Assert.areEqual(TTSB2BCheckInventory.STATUS_WAITLIST, results[0].status, 'The status should be Waitlist');
    }

    @isTest static void testTTSB2BCheckInventory_Failed() {

        List<WebCart> lstCarts = new List<WebCart>([SELECT Id, (SELECT Id FROM CartItems) FROM WebCart LIMIT 1]);
        CartItem item = lstCarts.get(0).CartItems.get(0);
        item.Sku = null;
        update item;

        // Call the method to test
        List<TTSB2BCheckInventory.InventoryResult> results = TTSB2BCheckInventory.TTSB2BCheckInventory(new List<Id>{lstCarts.get(0).Id});

        // Verify the result
        Assert.areEqual(1, results.size(), 'There should be one result');
        Assert.areEqual(TTSB2BCheckInventory.STATUS_FAILED, results[0].status, 'The status should be Failed');
    }

    @isTest static void testTTSB2BCheckInventory_FailedException() {

        List<WebCart> lstCarts = new List<WebCart>([SELECT Id FROM WebCart LIMIT 1]);
        Campaign event = [SELECT Id FROM Campaign LIMIT 1];
        event.Seats_Available__c = null;
        update event;

        // Call the method to test
        List<TTSB2BCheckInventory.InventoryResult> results = TTSB2BCheckInventory.TTSB2BCheckInventory(new List<Id>{lstCarts.get(0).Id});

        // Verify the result
        Assert.areEqual(1, results.size(), 'There should be one result');
        Assert.isTrue(results.get(0).errorMessage.contains('An exception of type'), 'The error message should be of an Exception');
        Assert.areEqual(TTSB2BCheckInventory.STATUS_FAILED, results[0].status, 'The status should be Failed');
    }

    // Inserts a cart item that matches the cart and cart delivery group
    public static CartItem insertCartItem(String cartId, String cartDeliveryGroupId, Id productId) {
        CartItem cartItem = new CartItem(
            CartId=cartId, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroupId,
            Product2Id=productId
        );
        insert cartItem;

        return cartItem;
    }
}