@isTest
private class CyberSourcePaymentAdapterTest {

    @isTest
    static void testAuthResponse_Invalid() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "INVALID_REQUEST","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}'));
        CyberSourcePaymentAdapter adapter = new CyberSourcePaymentAdapter();
        commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(100);
        authRequest.currencyIsoCode = 'USD';
        authRequest.comments = '100,zzz';
        authRequest.additionalData = new Map <String, String>{
            'token' => 'testToken'
        };
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
    }

    @isTest
    static void testCaptureResponse_Invalid() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "INVALID_REQUEST","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}'));
        CyberSourcePaymentAdapter adapter = new CyberSourcePaymentAdapter();
        commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(100, '000000000000000');
        captureRequest.additionalData = new Map <String, String>{
            'token' => 'testToken'
        };
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(captureRequest, commercepayments.RequestType.Capture);
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
    }

    @isTest
    static void testSaleResponse_Invalid() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "INVALID_REQUEST","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}'));
        CyberSourcePaymentAdapter adapter = new CyberSourcePaymentAdapter();
        commercepayments.SaleRequest saleRequest = new commercepayments.SaleRequest(100);
        saleRequest.currencyIsoCode = 'USD';
        saleRequest.comments = '100,zzz';
        saleRequest.additionalData = new Map <String, String>{
            'token' => 'testToken'
        };
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(saleRequest, commercepayments.RequestType.Sale);
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
    }

    @isTest
    static void testRefundResponse_Invalid() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "INVALID_REQUEST","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}'));
        CyberSourcePaymentAdapter adapter = new CyberSourcePaymentAdapter();
        commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(100, '000000000000000');
        refundRequest.additionalData = new Map <String, String>{
            'token' => 'testToken'
        };
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(refundRequest, commercepayments.RequestType.ReferencedRefund);
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
    }
}