@isTest
global with sharing class Saltbox_MockHttpEinstein implements System.HttpCalloutMock{
    global Saltbox_MockHttpEinstein() {

    }
    
    global System.HttpResponse respond(System.HttpRequest req) {
        // Assert request is correctly built
        
        String epRegex = '^https:\\/\\/\\S+\\/services\\/data\\/v55\\.0\\/commerce\\/webstores\\/\\S+\\/ai\\/recommendations\\?language=en-US&asGuest=true&recommender=\\S+$';
        String cookieRegex = '^\\S+$';
        String authorizationRegex = '^OAuth\\s\\S+$';
        
        Boolean epRegexMatch = Pattern.matches(epRegex, req.getEndpoint());
        Boolean cookieRegexMatch = Pattern.matches(cookieRegex, req.getHeader('Cookie'));
        Boolean authorizationRegexMatch = Pattern.matches(authorizationRegex, req.getHeader('Authorization'));

        Boolean correctEP = false;
        Boolean throwError = false;

        if (epRegexMatch && cookieRegexMatch && authorizationRegexMatch) {
            correctEP = true;
        }else {
            throwError = true;
        }

        System.assertEquals(
            true,
            correctEP,
            'Bad Endpoint'
        );

        // Create fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(req.getBody());
        if (throwError == true) {
            res.setStatusCode(500);
            res.setStatus('Failure');
        } else {
            res.setStatusCode(200);
            res.setStatus('Success');
        }
        return res;
    }

}