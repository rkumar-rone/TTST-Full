/**
 * @description       : Test class for SIB_ProductSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_ProductSelectorTest {
    @isTest
    static void testGetProductByIds(){
        Test.startTest();
        List<Sobject> result = SIB_ProductSelector.getProductByEventIds(new List<Id>{});
        List<Sobject> resultGetProductByEventIds = SIB_ProductSelector.getProductByIds(new List<String>{});
        System.assertEquals(null, result,'Passed');        
        Test.stopTest();
    }
}