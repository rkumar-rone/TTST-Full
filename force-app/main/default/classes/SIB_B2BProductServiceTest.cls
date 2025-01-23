/**
 * @description       : Test class for SIB_B2BProductService
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@IsTest
public class SIB_B2BProductServiceTest{
    @IsTest
    static void testGetProductDetail() {
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        
        System.runAs(adminUser) {
            
            Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
            product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
            testProduct.Product_Group__c = SIB_Constants.PRODUCT_GROUP_PRIVATE_COURSE;
            update testProduct;

            SIB_ProductRequest productRequest = new SIB_ProductRequest(testProduct.Id, true, true);

            
            Test.startTest();
            SIB_B2BProductService testSIBB2BProductService = new SIB_B2BProductService();
            SIB_ProductDetail productDetail = testSIBB2BProductService.getProductDetail(productRequest);
            Test.stopTest();
            
            System.assertNotEquals(null, productDetail,'Passed');
        }
    }
}