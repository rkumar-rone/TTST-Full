public virtual class SIB_HTTPService {
    public SIB_HTTPService() {
    }
    public virtual HttpRequest createHttpRequest( Map<String, String> requestDetails) {
      
      HttpRequest req = new HttpRequest();
      
      req.setEndpoint(requestDetails.get(SIB_SetupConstants.END_POINT));
      
      req.setMethod(String.isNotBlank(requestDetails.get(SIB_SetupConstants.HTTP_METHOD))? requestDetails.get(SIB_SetupConstants.HTTP_METHOD): SIB_SetupConstants.HTTP_POST);
      
      Integer timeout = String.isNotBlank(requestDetails.get(SIB_SetupConstants.SERVICE_TIMEOUT))? Integer.valueOf(requestDetails.get(SIB_SetupConstants.SERVICE_TIMEOUT)): SIB_SetupConstants.HTTP_DEFAULT_TIMEOUT;
      
      req.setTimeout(timeout);
      
      return req;
    }
  
    public virtual void setRequestHeaders(HttpRequest req,Map<String, String> requestHeaders) {
      
      if (!requestHeaders.isEmpty()) {
        
        for (String key : requestHeaders.keySet()) {
          
          req.setHeader(key, requestHeaders.get(key));
        
        }
      }
      if (!requestHeaders.containsKey(SIB_SetupConstants.HTTP_HEADER_CONTENT_TYPE)) {
        
        req.setHeader(SIB_SetupConstants.HTTP_HEADER_CONTENT_TYPE,SIB_SetupConstants.HTTP_HEADER_CONTENT_TYPE_JSON);
      
      }
    }
  
    public virtual Map<String, String> makeExternalCallout(Map<String, String> calloutRequestDetails,Map<String, String> requestHeaders) {
      
      Map<String, String> responseMap = new Map<String, String>();
      
      try {
        
        HttpRequest req = createHttpRequest(calloutRequestDetails);
        
        setRequestHeaders(req, requestHeaders);
        
        Http http = new Http();
        
        HTTPResponse res = null;
        
        if (!Test.isRunningTest()) {

          if (calloutRequestDetails.get(SIB_SetupConstants.SERVICE_MODE).toUpperCase().equals(SIB_SetupConstants.SERVICE_MODE_LIVE)) {

              req.setbody(calloutRequestDetails.get(SIB_SetupConstants.SERVICE_REQUEST_BODY));

              res = http.send(req);

          } else {
            
            res = new HTTPResponse();
            
            res.setStatusCode(SIB_SetupConstants.HTTP_200);
            
            res.setBody(calloutRequestDetails.get(SIB_SetupConstants.MOCKED_RESPONSE));
          
          }
        } else {
          
          res = new HTTPResponse();
          
          res.setStatusCode(SIB_SetupConstants.HTTP_200);
        }
        if (res.getStatusCode() == SIB_SetupConstants.HTTP_200) {

          responseMap.put(SIB_SetupConstants.HTTP_RESPONSE_STATUS,SIB_SetupConstants.HTTP_RESPONSE_STATUS_SUCCESS);
          
          responseMap.put(SIB_SetupConstants.RESPONSE_REASON_CODE,String.valueOf(res.getstatusCode()));

          responseMap.put(SIB_SetupConstants.SERVICE_RESPONSE_BODY, res.getBody());
        } else {
          
          responseMap.put(SIB_SetupConstants.HTTP_RESPONSE_STATUS,SIB_SetupConstants.HTTP_RESPONSE_STATUS_ERROR);

          responseMap.put(SIB_SetupConstants.RESPONSE_REASON_CODE,String.valueOf(res.getstatusCode()));

          responseMap.put(SIB_SetupConstants.SERVICE_RESPONSE_BODY, res.getBody());
        }
      } catch (Exception expObj) {
        
        responseMap.put(SIB_SetupConstants.HTTP_RESPONSE_STATUS,SIB_SetupConstants.HTTP_RESPONSE_STATUS_ERROR);
        
        System.debug(
          'Exception due to error ====' +
            expObj.getMessage() +
            'at Line Number ====' +
            expObj.getLineNumber()
        );
        // WK_Exception.log(expObj, applicationName, moduleName, className,
        // methodName, supportData);
      }

      System.debug('makeExternalCallout : responseMap: '+JSON.serializePretty(responseMap));

      return responseMap;
    }
  
    public virtual void setAuth() {
    }
    public virtual void setAuthHeaders() {
    }
  }