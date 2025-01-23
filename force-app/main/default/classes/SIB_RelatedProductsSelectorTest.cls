/**
 * @description       : Test class for SIB_RelatedProductsSelector  
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/

@isTest
public class SIB_RelatedProductsSelectorTest{
    @isTest
    static void testGetRelatedProductsByProductId(){
        Id productId =  SIB_TestDataFactory.getMockId(Product2.SObjectType) ; 
        Test.startTest();

        List<Sobject> relatedProducts = SIB_RelatedProductsSelector.getRelatedProductsSelectorByIds(new List<Id>{productId});
        System.assertEquals(0, relatedProducts.size(),'Passed');
        Test.stopTest();
    }
}