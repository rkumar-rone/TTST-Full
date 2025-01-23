/**
 * @description       : Test class for SIB_WebCartSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_WebCartSelectorTest {
    @isTest
    static void testGetCartByIds(){
        Test.startTest();
        List<SObject> result = SIB_WebCartSelector.getCartByIds(new List<Id>());
        System.assertEquals(null,result,'Passed');        
        Test.stopTest();
    }
}