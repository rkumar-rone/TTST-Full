/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_OrderSelectorTest {
	@isTest
    static void getOrderByIdsTest(){
        Test.startTest();
        List<Order> orders = (List<Order>) SIB_OrderSelector.getOrderByIds(new List<Id>());
        Test.stopTest();
        system.assertEquals(null,orders,'getOrderByIdsTest assertion failed');
    }
    @isTest
    static void getOrderByOrderNumbersTest(){
        Test.startTest();
        List<Order> orders = (List<Order>) SIB_OrderSelector.getOrderByOrderNumbers(new List<String>());
        Test.stopTest();
        system.assertEquals(null,orders,'getOrderByOrderNumbersTest assertion failed');
    }
}