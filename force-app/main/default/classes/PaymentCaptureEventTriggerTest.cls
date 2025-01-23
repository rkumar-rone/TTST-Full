@isTest
private class PaymentCaptureEventTriggerTest {

    @isTest
    static void testEvent_Success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "INVALID_REQUEST","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}'));
        Test.startTest();
        Payment_Capture__e pc = new Payment_Capture__e();
        pc.Payment_Authorization_Id__c = '000000000000000';
        EventBus.publish(pc);
        Test.getEventBus().deliver();
        Test.stopTest();
    }

    @isTest
    static void testEvent_Failure() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "INVALID_REQUEST","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}'));
        Test.startTest();
        Payment_Capture__e pc = new Payment_Capture__e();
        pc.Payment_Authorization_Id__c = '000000000000001';
        EventBus.publish(pc);
        Test.getEventBus().deliver();
        Test.stopTest();
    }
}