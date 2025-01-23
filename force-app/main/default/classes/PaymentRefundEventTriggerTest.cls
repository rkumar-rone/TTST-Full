@isTest
private class PaymentRefundEventTriggerTest {

    @isTest
    static void testPaymentRefundEventTrigger() {
        Test.startTest();
        Payment_Refund__e pc = new Payment_Refund__e();
        pc.OrderItemSummaryId__c = '000000000000000';
        pc.OrderSummaryId__c = '000000000000000';
        EventBus.publish(pc);
        Test.getEventBus().deliver();
        Test.stopTest();
    }
}