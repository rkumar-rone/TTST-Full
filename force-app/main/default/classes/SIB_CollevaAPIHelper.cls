/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Rajesh Kumar
**/
public with sharing class SIB_CollevaAPIHelper 
{

    private static final String CLASSNAME = 'SIB_CollevaAPIHelper';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Api Module';
    private static final String APP_NAME = 'Colleva';

    /**
     * @param requestVO - 
     * Create User and Provision Product in Colleva System
     * @return SIB_CollevaAPIResponseVO - API Response
     */
    public static SIB_CollevaAPIResponseVO invokeCreateUsers(SIB_CollevaAPIRequestVO requestVO)
    {
        String methodName = 'invokeCreateUsers';
        String supportData = '';
        String endPointUrl = '/public/users';
        String methodType = 'POST';
        SIB_CollevaAPIResponseVO apiResponse = null;
        String strOrderSummaryId = requestVO.orderSummaryId;
        List<OrderSummary> listOfOrderSummaries = [SELECT Id,Status, Colleva_Provisioned__c, Colleva_Order__c
                                                    FROM OrderSummary WHERE Id=:strOrderSummaryId];
        supportData += 'Order Summary : '+JSON.serializePretty(listOfOrderSummaries);
        requestVO.orderSummaryId = null;
        String strRequest = JSON.serialize(requestVO, true);
        System.debug('>>>>>strRequest>>>>>>>'+strRequest);
        HttpResponse response = callHttpService(strRequest, endPointUrl, methodType);
        if (response != null) 
        {
            apiResponse = (SIB_CollevaAPIResponseVO) JSON.deserialize(response.getBody(), SIB_CollevaAPIResponseVO.class);
            System.debug('>>>>>apiResponse>>>>>>>'+JSON.serializePretty(apiResponse));
            // SIB_CaptureApplicationLog.futureCaptureApplicationLog(APP_NAME , strRequest , JSON.serialize(apiResponse) , '' , supportData);
            //TO-DO :  pass the order summary Id to attach logs.
        }
        return apiResponse;
    }

    /* 
        * Fetch user in Colleva
    */
    public static SIB_CollevaAPIResponseVO fetchUserDetails(SIB_CollevaAPIRequestVO requestVO)
    {
        String methodName = 'fetchUserDetails';
        String supportData = '';
        String endPointUrl = '/public/users/'+requestVO.userId;
        String methodType = 'PATCH';
        SIB_CollevaAPIResponseVO apiResponse = null;
        requestVO.userId = null;
        String strRequest = JSON.serialize(requestVO, true);
        HttpResponse response = callHttpService(strRequest, endPointUrl, methodType);
        if (response != null) 
        {
            apiResponse = (SIB_CollevaAPIResponseVO) JSON.deserialize(response.getBody(), SIB_CollevaAPIResponseVO.class);
            // SIB_CaptureApplicationLog.futureCaptureApplicationLog(APP_NAME , strRequest , JSON.serialize(apiResponse) , '' , supportData);
            //TO-DO :  pass the order summary Id to attach logs.
        }
        return apiResponse;
    }

    /* 
        * Get user in Colleva
    */
    public static SIB_CollevaAPIResponseVO fetchUserAllowedUsage(SIB_CollevaAPIRequestVO requestVO)
    {
        String methodName = 'fetchUserAllowedUsage';
        String supportData = '';
        String endPointUrl = '/public/users/'+requestVO.userId+'/allowed-usage';
        String methodType = 'GET';
        SIB_CollevaAPIResponseVO apiResponse = null;
        requestVO.userId = null;
        String strRequest = JSON.serialize(requestVO, true);
        HttpResponse response = callHttpService(strRequest, endPointUrl, methodType);
        if (response != null) 
        {
            apiResponse = (SIB_CollevaAPIResponseVO) JSON.deserialize(response.getBody(), SIB_CollevaAPIResponseVO.class);
            // SIB_CaptureApplicationLog.futureCaptureApplicationLog(APP_NAME , strRequest , JSON.serialize(apiResponse) , '' , supportData);
            //TO-DO :  pass the order summary Id to attach logs.
        }
        return apiResponse;
    }

    /* 
        * Get user in Colleva
    */
    public static SIB_CollevaAPIResponseVO fetchUserProducts(SIB_CollevaAPIRequestVO requestVO)
    {
        String methodName = 'fetchUserProducts';
        String supportData = '';
        String endPointUrl = '/public/users/'+requestVO.userId+'/products';
        String methodType = 'POST';
        SIB_CollevaAPIResponseVO apiResponse = null;
        requestVO.userId = null;
        String strRequest = JSON.serialize(requestVO, true);
        HttpResponse response = callHttpService(strRequest, endPointUrl, methodType);
        if (response != null) 
        {
            apiResponse = (SIB_CollevaAPIResponseVO) JSON.deserialize(response.getBody(), SIB_CollevaAPIResponseVO.class);
            // SIB_CaptureApplicationLog.futureCaptureApplicationLog(APP_NAME , strRequest , JSON.serialize(apiResponse) , '' , supportData);
            //TO-DO :  pass the order summary Id to attach logs.
        }
        return apiResponse;
    }


    /* 
        * Call API Service
    */
    public static HttpResponse callHttpService(String strRequest, String endPointUrl, String methodType)
    {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint('callout:Colleva_Api'+endPointUrl);
        request.setMethod(methodType);
        if(String.isNotBlank(strRequest))
        {
            request.setBody(strRequest);
            request.setHeader('Content-Type' , 'application/json');
        }
        HttpResponse response = http.send(request);
        system.debug('response : '+response.getBody());
        system.debug('response : '+response.getStatus());
        return response;
    }

    /*
    //Sample Request :
    String strRequest = '{"email":"john.doe.0124.1@yopmail.com","name":"John Doe","productId":"TTS_smartPrep","startDate":"2025-01-27"}';
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:Colleva_Api/public/users');
    request.setMethod('POST');
    request.setHeader('Content-Type' , 'application/json');
    request.setBody(strRequest);
    //request.setHeader('Colleva-Api-Key' , 'f7f9d831-c088-405c-b274-4d8e32fcc473___23');
    HttpResponse response = http.send(request);
    system.debug('response : '+response.getBody());
    system.debug('response : '+response.getStatus());

    */


}