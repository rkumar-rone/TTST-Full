@isTest
global class SIB_HttpCalloutMock implements HttpCalloutMock{

    global HttpRequest newRequest;
    global String responseBody;
    global Integer responseStatus;
    
    global SIB_HttpCalloutMock(HttpRequest newRequest, String responseBody, Integer responseStatus) {
        
        this.newRequest = newRequest;
        this.responseBody = responseBody;
        this.responseStatus = responseStatus;
    }
    
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse response = new HttpResponse();
        response.setBody(this.responseBody);
        response.setStatusCode(this.responseStatus);
        
        return response;
    }
}