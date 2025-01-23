@isTest
public class SIB_OrderSummaryRequestTest {

    @isTest
    static void instanceTest() {
        SIB_OrderSummaryRequest instance = new SIB_OrderSummaryRequest() ;
        instance.orderSummaryId = SIB_TestDataFactory.getMockId(Schema.OrderSummary.sObjectType);
    }
}