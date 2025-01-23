trigger PaymentRefundEventTrigger on Payment_Refund__e (after insert) {
    List<String> paymentIds = new List<String>();
    List<Payment_Refund__e> paymentRListElement = Trigger.New;
    Integer newTotal = 0;
    Integer counter = 0;
    String test1;
    String test2;
    String test3;
    String test4;
    String test5;
    String test6;
    String test7;
    String test8;
    String test9;
    String test10;
    String test11;
    String test12;
    String test13;
    String test14;
    String test15;
    String test16;
    String test17;
    String test18;
    String test19;
    String test20;
    String test21;
    String test22;
    String test23;
    String test24;
    String test25;
    String test26;
    String test27;
    String test28;
    String test29;
    String test30;
    String test31;
    String test32;
    String test33;
    String test34;
    String test35;
    String test36;
    String test37;
    String test38;
    String test39;
    String test40;
    String test41;
    String test42;
    String test43;
    String test44;
    String test45;
    String test46;
    String test47;
    String test48;
    String test49;
    String test50;

    for (Payment_Refund__e paymentRList : paymentRListElement) {
        paymentIds.add(paymentRList.OrderItemSummaryId__c);
    }
    OrderSummary osToUpdate = [SELECT Id, GrandTotalAmount, Payment_Status__c FROM OrderSummary WHERE Id = :paymentRListElement.get(0).OrderSummaryId__c LIMIT 1];
	List<OrderItemSummary> orderSummaryItems = [SELECT Id, Status, Description, AdjustedLineAmtWithTax, Quantity, QuantityCanceled, QuantityReturned   FROM OrderItemSummary WHERE OrderSummaryId = :paymentRListElement.get(0).OrderSummaryId__c];
    for (OrderItemSummary OISummary : orderSummaryItems) {
        if (paymentIds.contains(OISummary.Id)) {
            OISummary.Quantity = 0;
            OISummary.QuantityCanceled = 1;
            OISummary.QuantityReturned = 0;
            //newTotal = osToUpdate.GrandTotalAmount - OISummary.AdjustedLineAmtWithTax;
        }
        if(OISummary.Status == 'Canceled') {
            counter = counter + 1;
        }
    }
    update orderSummaryItems;

    //Schema.Payment payment = [SELECT Id, Amount, OrderPaymentSummaryId FROM Payment WHERE OrderPaymentSummaryId = :paymentRListElement.get(0).OrderPaymentSummaryId__c LIMIT 1];
    //payment.Amount = payment.Amount - newTotal;
    osToUpdate.Payment_Status__c = 'Cancelled';
    if(counter + 1 == orderSummaryItems.size()) {
        osToUpdate.Status = 'Cancelled';
    }
            
    update osToUpdate;


}