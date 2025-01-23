/**
 * @description       : Test class for SIB_CartItemSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CartItemSelectorTest {
    @isTest
    public static void testGetDefaultFields() {
        Test.startTest();
        Set<String> result = SIB_CartItemSelector.getDefaultFields();
        String queryFieldString = SIB_CartItemSelector.getQueryFieldString();
        System.assert(result.contains('Id'), 'Passed');
        Test.stopTest();
    }

    @isTest
    static void testGetCartItemsByCartIds() {
        Test.startTest();
        Id cartId = SIB_TestDataFactory.getMockId(WebCart.SObjectType);
        List<Sobject> result = SIB_CartItemSelector.getCartItemsByCartIds(new List<Id>{cartId});
        System.assertEquals(null,result, 'Passed');
        Test.stopTest();
    }
}