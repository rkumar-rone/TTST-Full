/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CheckInventoryTest {
	@TestSetup
    static void setup(){
        Account account = new Account (Name = 'test');
        insert account;
        WebStore webStore = new WebStore(Name='test');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        Campaign event = new Campaign();
        event.Name='test';
        event.Seats_Available__c = 10;
        insert event;
        Product2 prod = new Product2(Name='test',TTS_Event__c=event.Id);
        insert prod;
        Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
        product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
        testProduct.TTS_Event__c = event.Id;
        update testProduct;
        CartItem cartItem = new CartItem(CartId=cart.Id, Quantity = 2,Product2Id=prod.Id, Type= SIB_Constants.PARAM_PRODUCT, Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
        
    }
    
    @isTest
    static void checkInventoryForCartIdTest1(){
        WebCart cart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Test.startTest();
        SIB_CheckInventory.SIB_InventoryResult ir = SIB_CheckInventory.checkInventoryForCartId(cart.Id);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.CHECK_INV_STATUS.STATUS_FAILED,ir.status,'checkInventoryForCartIdTest1 assertion failed');
    }

    @isTest
    static void checkInventoryForCartIdTest3(){
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        CartItem ci = [SELECT Id,sku FROM CartItem LIMIT 1];
        ci.sku = 'test';
        update ci;

        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = '74CBTLV1G125DBVRQ1' LIMIT 1];
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup LIMIT 1];

        CartItem cartItem2 = new CartItem(CartId=cart.Id, Quantity = 10,Product2Id=testProduct.Id,sku = 'Test2', Type= SIB_Constants.PARAM_PRODUCT, Name='TestProduct2', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem2;

        Test.startTest();
        SIB_CheckInventory.SIB_InventoryResult ir = SIB_CheckInventory.checkInventoryForCartId(cart.Id);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.CHECK_INV_STATUS.STATUS_FAILED,ir.status,'checkInventoryForCartIdTest2 assertion failed');
    }
    
    @isTest
    static void checkInventoryForCartIdTest2(){
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        CartItem ci = [SELECT Id,sku FROM CartItem LIMIT 1];
        ci.sku = 'test';
        update ci;
        Test.startTest();
        SIB_CheckInventory.SIB_InventoryResult ir = SIB_CheckInventory.checkInventoryForCartId(cart.Id);
        SIB_CheckInventory.SIB_InventoryResult irnull = SIB_CheckInventory.checkInventoryForCartId('tes123');        

        Test.stopTest();
        system.assertNotEquals(null,ir.status,'checkInventoryForCartIdTest2 assertion failed');
    }
    
    @isTest
    static void checkInventoryForCartIdWrapperCase(){
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        CartItem ci = [SELECT Id,sku FROM CartItem LIMIT 1];
        ci.sku = 'test';
        update ci;
        Test.startTest();
        SIB_CheckInventory.SIB_InventoryResult sir = new SIB_CheckInventory.SIB_InventoryResult('test','test',ci);
        SIB_CheckInventory.SIB_InventoryResult sir2 = new SIB_CheckInventory.SIB_InventoryResult();
        Test.stopTest();
    }
}