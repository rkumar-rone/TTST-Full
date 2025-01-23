/**
    * @description : Implements an HTTP Rest callout to Strivacity's Admin API to pass back key profile updates
    * @description : Also sets the Contact Id in Strivacity for use in Moodle LMS SAML
    * @created Date : 17th October 2023
    * @Author : Nathan Anderson
    * @LastModified
*/

public with sharing class StrivacityAdminAPIClient {
    
    /*
       * @description : Invocable method called from Send_Profile_Update_to_Strivacity (platform event triggered flow)
       * @params : accepts the full platform event record from the flow  
       * @created Date : 10-23-2023
       * @Return : return void
   */
    @InvocableMethod(callout=true)
    public static void sendStrivacityUpdate(List<Strivacity_Profile_Update__e> profiles) {
        String accessToken = sendAuthRequest();
            if (accessToken != null) {
                String jsonRequestBody = generateContactJson(profiles[0]);
                String identifier = [SELECT Strivacity_Identifier__pc FROM Account WHERE PersonContactId = :profiles[0].ContactId__c].Strivacity_Identifier__pc;
                makePutRequest(accessToken, jsonRequestBody, identifier);
            }
    }

    /*
       * @description : Utility class to parse the platform event record and construct the JSON body depending on which values were included
       * @params : accepts the full platform event record
       * @created Date : 10-23-2023
       * @Return : return String - the JSON string for the body of the PUT request
   */
    public static String generateContactJSON(Strivacity_Profile_Update__e profile) {

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        // gen.writeFieldName('workInfo');
        // gen.writeStartObject();
        // gen.writeStringField('company', 'Saltbox');
        // gen.writeEndObject();
        //gen.writeStringField('country', 'USA');
        if(profile.ContactId__c != null) {
            gen.writeFieldName('sfdc');
            gen.writeStartObject();
            gen.writeStringField('contactId', profile.ContactId__c);
            gen.writeEndObject();
        }
        if(profile.FirstName__c != null) {
            gen.writeFieldName('name');
            gen.writeStartObject();
            gen.writeStringField('familyName', profile.LastName__c);
            gen.writeStringField('givenName', profile.FirstName__c);
            gen.writeEndObject();
        }
        
        // gen.writeStringField('id', '436559d6-fb34-4293-94a5-8155fe734a10');
        // gen.writeStringField('source', 'linkedin');
        if(profile.Username__c != null) {
            gen.writeStringField('userName', profile.Username__c);
        }
        
        if(profile.Phone__c != null) {
            gen.writeFieldName('phoneNumbers');
            gen.writeStartObject();
            gen.writeStringField('primaryPhoneNumber', profile.Phone__c);
            gen.writeEndObject();
        }
        
        gen.writeEndObject();

        return gen.getAsString();

    }

    /*
       * @description : This method makes the authentication request to Strivacity's Admin api
       * @params : 
       * @created Date : 10-23-2023
       * @Return : return String - the Access Token to be passed to the PUT callout for the Authorization header
   */
    public static String sendAuthRequest() {
        Strivacity_Integration_Settings__mdt strivacity = [SELECT Account_API_Endpoint__c, Auth_Audience_Target__c, Account_API_Suffix__c FROM Strivacity_Integration_Settings__mdt WHERE QualifiedApiName = 'Strivacity_Profile_Update'];
        String clientId = '{$Credential.Username}';
        String clientSecret = '{$Credential.Password}';
        String endpoint = 'callout:Strivacity_Admin_Api';
        String grantType = 'client_credentials';
        String audience = strivacity.Auth_Audience_Target__c;
        String scope = 'write:account';

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        // Set the endpoint URL
        request.setEndpoint(endpoint);

        // Set the HTTP method to POST
        request.setMethod('POST');

        // Set the request headers
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // Set the request body (data)
        String requestBody = 'grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8') +
                            '&audience=' + EncodingUtil.urlEncode(audience, 'UTF-8') +
                            '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8');
        request.setBody(requestBody);

        // Set the Basic Authentication header with the client ID and client secret
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret));
        request.setHeader('Authorization', authHeader);

        try {
            // Send the HTTP request
            response = http.send(request);
        } catch (Exception e) {
            System.debug('HTTP Request Failed: ' + e.getMessage());
            return null;
        }

        // Check the HTTP response status code
        if (response.getStatusCode() == 200) {
            // Successful request
            String responseBody = response.getBody();
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            String accessToken = (String)jsonResponse.get('access_token');
            if (accessToken != null) {
                // Access token obtained, you can use it to make the PUT request
                return accessToken;
            } else {
                // Request failed
                System.debug('HTTP Request Returned no Access Token: ' + response.getStatusCode());
                System.debug('Response Body: ' + response.getBody());
                return null;
            }
        } else {
            // Request failed
            System.debug('HTTP Request Failed with Status Code: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }
    }

    /*
       * @description : Makes the PUT request to the Strivacity Account Attribute API
       * @params : String (AccessToken from the Auth API), String (JSON Body for the request), String (Strivacity_Identifier from the person account record)
       * @created Date : 10-23-2023
       * @Return : return String - Response body
   */
    public static String makePutRequest(String accessToken, String jsonRequestBody, String identifier) {
        Strivacity_Integration_Settings__mdt strivacity = [SELECT Account_API_Endpoint__c, Auth_Audience_Target__c, Account_API_Suffix__c FROM Strivacity_Integration_Settings__mdt WHERE QualifiedApiName = 'Strivacity_Profile_Update'];
        String endpoint = strivacity.Account_API_Endpoint__c;
        String endpointSuffix = strivacity.Account_API_Suffix__c;
        
        String reqEndpoint = endpoint + identifier + endpointSuffix;

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        // Set the endpoint URL for the PUT request
        request.setEndpoint(reqEndpoint);

        // Set the HTTP method to PUT
        request.setMethod('PUT');

        // Set the request headers
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);

        // String reqBody = '{"workInfo": {"company": "Saltbox"},"country": "USA","sfdc": {"contactId": "0037h00000t56DCAAY"},';
        // reqBody += '"name": {"familyName": "User123","givenName": "Test"},"id": "436559d6-fb34-4293-94a5-8155fe734a10",';
        // reqBody += '"source": "linkedin","userName": "test_user123","phoneNumbers": { "primaryPhoneNumber": "+12177141112"}}';

        request.setBody(jsonRequestBody);

        try {
            // Send the PUT request
            response = http.send(request);
        } catch (Exception e) {
            System.debug('PUT Request Failed: ' + e.getMessage());
            return null;
        }

        // Check the HTTP response status code
        if (response.getStatusCode() == 200) {
            // Successful PUT request
            return response.getBody();
        } else {
            // PUT request failed
            System.debug('PUT Request Failed with Status Code: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }
    }
}