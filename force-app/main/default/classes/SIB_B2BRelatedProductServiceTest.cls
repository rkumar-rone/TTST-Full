/**
 * @description       : Test class for SIB_B2BRelatedProductService
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@IsTest
public class SIB_B2BRelatedProductServiceTest{

    @IsTest
    static void testGetRelatedProducts() {
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        System.runAs(adminUser) {
            
            Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
            product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
            product2 testProduct2 =  createProducts.get('LM2901N');

            SIB_ProductRequest productRequest = new SIB_ProductRequest(new List<Id>{testProduct.Id,testProduct2.Id}, true, true);
            B2B_Recommendation__c testRem1 = new B2B_Recommendation__c(
            Recommended_Product__c = testProduct.Id,
            Attached_Product__c = testProduct.Id,
            Active__c = true,
            Order__c = 1,
            Type__c = 'Recommendation'
            );

            insert testRem1;

            B2B_Recommendation__c testRem2 = new B2B_Recommendation__c(
            Recommended_Product__c = testProduct.Id,
            Attached_Product__c = testProduct.Id,
            Active__c = true,
            Order__c = 2,
            Type__c = 'Recommendation'
            );
            insert testRem2;

            Test.startTest();
            SIB_B2BRelatedProductService result = new SIB_B2BRelatedProductService();
            Map<String, List<SIB_RelatedProduct>>  productDetail = result.getRelatedProducts(productRequest);
            Test.stopTest();
            
            System.assertNotEquals(null, productDetail,'Passed');
        }
    }
}