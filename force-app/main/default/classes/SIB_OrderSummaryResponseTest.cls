@isTest
public with sharing class SIB_OrderSummaryResponseTest {
    @isTest
    static void instanceTest() {
        OrderSummary os = new OrderSummary();
        SIB_OrderSummaryResponse instance = new SIB_OrderSummaryResponse() ;
        instance.orderSummary = os;
        SIB_OrderSummaryResponse instance2 = new SIB_OrderSummaryResponse(os) ;
    }
}