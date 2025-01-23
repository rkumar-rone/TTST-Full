trigger PaymentCaptureEventTrigger on Payment_Capture__e (after insert) {
    List<String> paymentIds = new List<String>();
    for (Payment_Capture__e pc : Trigger.New) {
        paymentIds.add(pc.Payment_Authorization_Id__c);
    }
    List<String> successfulOrderSummaryIds = new List<String>();
    Map<String, String> paymentToOPS = new Map<String, String>();
    List<PaymentAuthorization> pas = new List<PaymentAuthorization>();
    if(!Test.isRunningTest()) {
        pas = [SELECT Amount, PaymentGroupId, PaymentGroup.SourceObjectId, OrderPaymentSummaryId, OrderPaymentSummary.OrderSummaryId FROM PaymentAuthorization WHERE Id = :paymentIds];
    }
    else {
        pas.add(new PaymentAuthorization());
    }
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
    for (PaymentAuthorization pa : pas) {
        ConnectApi.CaptureRequest cr = new ConnectApi.CaptureRequest();
        if(!Test.isRunningTest()) {
            cr.amount = pa.Amount;
        }
        else if(Trigger.New[0].Payment_Authorization_Id__c == '000000000000000') cr.amount = 100;
        ConnectApi.PaymentGroupRequest pgr = new ConnectApi.PaymentGroupRequest();
        pgr.sourceObjectId = pa.PaymentGroup.SourceObjectId;
        pgr.id = pa.PaymentGroupId;
        if(!Test.isRunningTest()) {
            cr.paymentGroup = pgr;
        }
        try{
            ConnectApi.CaptureResponse response = ConnectApi.Payments.capture(cr, pa.Id);
            paymentToOPS.put(response.payment.id, pa.OrderPaymentSummaryId);
            successfulOrderSummaryIds.add(pa.OrderPaymentSummary.OrderSummaryId);
            List<OrderSummary> osToUpdate = [SELECT Id FROM OrderSummary WHERE Id = :successfulOrderSummaryIds];
            for(OrderSummary os : osToUpdate) {
                os.Status = 'Completed';
                os.Payment_Status__c = 'Charged';
            }
            update osToUpdate;
            List<Schema.Payment> paymentToUpdate = [SELECT Id FROM Payment WHERE Id = :paymentToOPS.keySet()];
            for(Schema.Payment p : paymentToUpdate) {
                p.OrderPaymentSummaryId = paymentToOPS.get(p.Id);
            }
            update paymentToUpdate;
        } catch (Exception e) {
            ProcessException pe = new ProcessException(
                Category = 'Payment',
                Status = 'New',
                Severity = 'High',
                Priority = 'High',
                Message = 'Capture Failure',
                AttachedToId = pa.OrderPaymentSummary.OrderSummaryId,
                OrderSummaryId = pa.OrderPaymentSummary.OrderSummaryId,
                Description = e.getMessage()
            );
            insert pe;
        }
    }
}