@isTest
public class ReCAPTCHATest {
    @isTest static void testVerifyRecaptcha() {
        // Mock the HttpCallout
        Test.setMock(HttpCalloutMock.class, new ReCAPTCHAMock());

        // Call the method to test
        Boolean result = ReCAPTCHA.verifyRecaptcha('testResponse');

        // Verify the results
        System.assertEquals(true, result, 'Expected the ReCAPTCHA verification to succeed');
    }

    @isTest static void testVerifyRecaptchaError() {
        // Mock the HttpCallout
        Test.setMock(HttpCalloutMock.class, new ReCAPTCHAMockError());

        // Call the method to test
        Boolean result = ReCAPTCHA.verifyRecaptcha('testResponse');

        // Verify the results
        System.assertEquals(false, result, 'Expected the ReCAPTCHA verification to fail');
    }

    @isTest static void testVerifyRecaptchaErrorSuccess() {
        // Mock the HttpCallout
        Test.setMock(HttpCalloutMock.class, new ReCAPTCHAMockErrorSuccess());

        // Call the method to test
        Boolean result = ReCAPTCHA.verifyRecaptcha('testResponse');

        // Verify the results
        System.assertEquals(false, result, 'Expected the ReCAPTCHA verification to fail');
    }

    public class ReCAPTCHAMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class ReCAPTCHAMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": false}');
            res.setStatusCode(401);
            return res;
        }
    }

    public class ReCAPTCHAMockErrorSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": false}');
            res.setStatusCode(200);
            return res;
        }
    }
}