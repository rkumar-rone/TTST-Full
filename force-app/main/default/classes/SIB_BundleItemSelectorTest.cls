/**
 * @description       : Test class for SIB_BundleItemSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_BundleItemSelectorTest {
    
    @isTest
    static void testGetCountByParentId() {

        Id productId =  SIB_TestDataFactory.getMockId(Product2.SObjectType) ; 
        Test.startTest();
        Integer count = SIB_BundleItemSelector.getCountByParentId(productId);
        List<SObject> bundleItems = SIB_BundleItemSelector.getBundleItemsByProductIds(new List<Id>{productId});
        Test.stopTest();

        System.Assert.areEqual(0, count);
    }
}