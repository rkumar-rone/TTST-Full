/**
* @description : Test class for Saltbox Product Controller
* @created Date : 28th February 2022
* @Author : Sanyam Jain
* @LastModified
*/
@isTest(SeeAllData=true)
public class Saltbox_ProductControllerTest {
    
    //method to test get all featured products using mock class
    @isTest static void testGetAllFeaturedProduct() {
        
        createTestSetup();
        
        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        System.runAs(testUser) { 
           
            Test.startTest();
            String data =  Saltbox_ProductController.getAllFeatureProducts();
            Test.stopTest();
      
            System.assertNotEquals(null, data);
        }
    }

    //method to test get all featured products with order
    @isTest static void testGetFeaturedProductsWithOrder() {
        
        createTestSetup();
        
        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        System.runAs(testUser) { 
           
            Test.startTest();
            String data =  Saltbox_ProductController.getFeaturedProductsWithOrder();
            Test.stopTest();
      
            System.assertNotEquals(null, data);
        }
    }
    
    //method to test add product in cart method
    @isTest static void testAddProduct() {
        
        createTestSetup();
        
        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        System.runAs(testUser) {
            Test.startTest();
            ConnectApi.CartItem data =  Saltbox_ProductController.addCartItem(System.label.Test_Product_Id);
            Test.stopTest();
            System.assertNotEquals(null, data);
        }
    }
    
    //method to test get all recommended products using mock class
    @isTest static void testGetRecommendateProduct() {
        
        createTestSetup();
        String effectiveAccountId =[SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1].id;
        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        System.runAs(testUser) { 
           
            Test.startTest();
            String data =  Saltbox_ProductController.getRecommendateProduct(System.label.Test_Product_Id, System.Label.Saltbox_Network_ID, effectiveAccountId);
            Test.stopTest();
            System.assertNotEquals(null, data);
        }
    }

    //method to test get recommended products with order
    @isTest static void testGetRecommendedProductsWithOrder() {
        
        createTestSetup();
        
        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        System.runAs(testUser) { 
           
            Test.startTest();
            String data =  Saltbox_ProductController.getRecommendedProductsWithOrder(System.label.Test_Product_Id);
            Test.stopTest();
            System.assertNotEquals(null, data);
        }
    }
    
    //method to create steup data
    private static void createTestSetup() {
        String cartId;
        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :System.Label.Saltbox_Test_User_ID LIMIT 1]; 
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        BuyerAccount buyerAccount = new BuyerAccount(Name='Test Buyer Account', BuyerId=testAccount.Id, CurrencyIsoCode='USD', IsActive = true);
        insert buyerAccount;
        System.runAs(testUser) { 
            List<Product2> hiProduct = [SELECT Id FROM Product2 Where id =:  System.label.Test_Product_Id ];
            //adding product to cart
            if(!hiProduct.isEmpty()) {
                List<B2B_Recommendation__c> recommendationList = new List<B2B_Recommendation__c>();
                B2B_Recommendation__c recommended = new B2B_Recommendation__c();
                recommended.Recommended_Product__c = hiProduct[0].Id;
                recommended.Attached_Product__c = hiProduct[0].Id;
                recommended.Order__c = 1;
                recommended.Type__c = 'Recommendation';
                recommendationList.add(recommended);
                
                
                B2B_Recommendation__c recommendedOne = new B2B_Recommendation__c();
                recommendedOne.Recommended_Product__c = hiProduct[0].Id;
                recommendedOne.Attached_Product__c = hiProduct[0].Id;
                recommendedOne.Type__c = 'Featured';
                recommendedOne.Order__c = 2;
                recommendationList.add(recommendedOne);
                insert recommendationList;
            }
            
        }
        
        
    }
}