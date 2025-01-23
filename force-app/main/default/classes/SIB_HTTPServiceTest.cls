/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_HTTPServiceTest {
	@isTest
    static void makeExternalCalloutTest(){
        SIB_HttpCalloutMock newMock = new SIB_HttpCalloutMock(null, '{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "AUTHORIZED","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}', 200);
        Test.setMock(HttpCalloutMock.class, newMock);
        Map<String,String> requestDetails = new Map<String,String>();
        requestDetails.put(SIB_SetupConstants.END_POINT,'test');
        requestDetails.put(SIB_SetupConstants.HTTP_METHOD,'test');
        requestDetails.put(SIB_SetupConstants.SERVICE_TIMEOUT,'1');
        requestDetails.put(SIB_SetupConstants.SERVICE_MODE, SIB_SetupConstants.SERVICE_MODE_LIVE);
        requestDetails.put(SIB_SetupConstants.SERVICE_REQUEST_BODY, '{"test":"test"}');
        SIB_HTTPService httpService = new SIB_HTTPService();
        Test.startTest();
        requestDetails = httpService.makeExternalCallout(requestDetails, new Map<String,String>{'test'=>'test'});
        httpService.setAuth();
        httpService.setAuthHeaders();
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.HTTP_RESPONSE_STATUS_SUCCESS,requestDetails.get(SIB_SetupConstants.HTTP_RESPONSE_STATUS),'makeExternalCalloutTest assertion failed');
    }
    
    @isTest
    static void makeExternalCalloutExceptionTest(){
        Map<String,String> requestDetails = new Map<String,String>();
        requestDetails.put(SIB_SetupConstants.END_POINT,'test');
        requestDetails.put(SIB_SetupConstants.HTTP_METHOD,'test');
        requestDetails.put(SIB_SetupConstants.SERVICE_TIMEOUT,'1.27');
        SIB_HTTPService httpService = new SIB_HTTPService();
        Test.startTest();
        requestDetails = httpService.makeExternalCallout(requestDetails, new Map<String,String>{'test'=>'test'});
        Test.stopTest();
    }
    
    @isTest
    static void makeExternalCalloutSecondaryTest() {
        SIB_HttpCalloutMock newMock = new SIB_HttpCalloutMock(null, '{"errorInformation": {"message" : "errorInformation"}, "id": "7014269189836305704951","submitTimeUtc": "2023-12-01T10:35:19Z","status": "AUTHORIZED","reason": "INVALID_DATA","message": "Declined - One or more fields in the request contains invalid data","details": [{"field": "tokenInformation.jti","reason": "INVALID_DATA"}]}', 201);
        Test.setMock(HttpCalloutMock.class, newMock);
        Map<String,String> requestDetails = new Map<String,String>();
        requestDetails.put(SIB_SetupConstants.END_POINT,'test');
        requestDetails.put(SIB_SetupConstants.HTTP_METHOD,'test');
        requestDetails.put(SIB_SetupConstants.SERVICE_TIMEOUT,'1');
        requestDetails.put(SIB_SetupConstants.SERVICE_MODE, SIB_SetupConstants.SERVICE_MODE_LIVE);
        requestDetails.put(SIB_SetupConstants.SERVICE_REQUEST_BODY, '{"test":"test"}');
        SIB_HTTPService httpService = new SIB_HTTPService();
        Test.startTest();
        httpService.makeExternalCallout(requestDetails, new Map<String,String>{'test'=>'test'});
        Test.stopTest();
    }
}