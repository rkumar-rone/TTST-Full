/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 11-03-2024
 * @last modified by  :
**/
@isTest
public class SIB_OrderSummarySelectorTest {
	@isTest
    static void getOrderSummaryByIdsTest(){
        Test.startTest();
        List<SObject> response = SIB_OrderSummarySelector.getOrderSummaryByIds(new List<Id>());
        Test.stopTest();
        system.assertEquals(null,response,'getOrderSummaryByIdsTest assertion failed');
    }
    @isTest
    static void getOrderSummaryByOrderNumbersTest(){
        Test.startTest();
        List<SObject> response = SIB_OrderSummarySelector.getOrderSummaryByOrderNumbers(new List<String>());
        List<SObject> response2 = SIB_OrderSummarySelector.getOrderSummaryByOrderReferenceNumbers(new List<String>());
        Test.stopTest();
        system.assertEquals(null,response,'getOrderSummaryByOrderNumbersTest assertion failed');
    }
}