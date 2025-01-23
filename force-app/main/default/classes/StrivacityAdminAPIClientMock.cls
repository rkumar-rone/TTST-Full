global class StrivacityAdminAPIClientMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token": "mockAccessToken"}');
        res.setStatusCode(200);
        return res;
    }
}