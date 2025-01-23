public abstract class SIB_TaxProvider {
  public SIB_TaxProvider() {
    //Logger.debug('SIB_TaxProvider constructor called', 'SIB_TaxProviderInit');
  }
    public virtual Map<String, String> prepareNamedCredentials(
      SIB_TaxProviderRequest taxRequest
    ) {
      //Logger.debug('Preparing named credentials', 'PrepareNamedCredentialsStart');
      Map<String, String> callOutRequest = new Map<String, String>();
      String endPoint =
        SIB_SetupConstants.CALLOUT +
        taxRequest.taxMetaData.namedCredentials +
        taxRequest.taxMetaData.endPoint;
      callOutRequest.put(SIB_SetupConstants.END_POINT, endPoint);
      //Logger.debug('Named credentials prepared: ' + callOutRequest, 'PrepareNamedCredentialsEnd');
      // callOutRequest.put(SIB_SetupConstants.USERNAME , SIB_SetupConstants.CREDENNTIALS_USERNAME);
      // callOutRequest.put(SIB_SetupConstants.PASSWORD , SIB_SetupConstants.CREDENNTIALS_PASSWORD);
      return callOutRequest;
    }
    public virtual Map<String, String> setServiceDetails(
      SIB_TaxProviderRequest taxRequest
    ) {
      //Logger.debug('Setting service details', 'SetServiceDetailsStart');
      
      Map<String, String> serviceDetails = new Map<String, String>();
      serviceDetails.put(SIB_SetupConstants.HTTP_METHOD,taxRequest.taxMetaData.httpMethod);
      serviceDetails.put(SIB_SetupConstants.SERVICE_TIMEOUT,taxRequest.taxMetaData.serviceTimeout);
      serviceDetails.put(SIB_SetupConstants.SERVICE_MODE,taxRequest.taxMetaData.serviceMode);
      serviceDetails.put(SIB_SetupConstants.MOCKED_RESPONSE,taxRequest.taxMetaData.mockedResponse);
      
      //Logger.debug('Service details set: ' + serviceDetails, 'SetServiceDetailsEnd');
      
      return serviceDetails;
    }
  
    public virtual Map<String, String> setRequestHeaders(SIB_TaxProviderRequest taxRequest) {
      //Logger.debug('Setting request headers', 'SetRequestHeadersStart');
      Map<String, String> htttpRequestDetails = new Map<String, String>();
      //Logger.debug('Request headers set: ' + htttpRequestDetails, 'SetRequestHeadersEnd');
      return htttpRequestDetails;
    }
  
    public virtual SIB_TaxProviderResponse calculateTax(SIB_TaxProviderRequest taxRequest) {
      //Logger.debug('Calculating tax for request: ' + taxRequest, 'CalculateTaxStart');
      SIB_TaxProviderResponse taxes;
      Map<String, String> responseMap;
      Boolean calloutSuccess = true;
      try {
        Map<String, String> callOutRequest = new Map<String, String>();
        callOutRequest.putAll(prepareNamedCredentials(taxRequest));
        callOutRequest.putAll(setServiceDetails(taxRequest));
        prepareCreateTransaction(taxRequest, callOutRequest);
        //Logger.debug('Making external callout', 'MakeExternalCallout');
        responseMap = SIB_ServiceFactory.getService(
            taxRequest.taxMetaData.serviceImplClass
          )
          .makeExternalCallout(callOutRequest, setRequestHeaders(taxRequest));
        if (
          !'201'.equals(responseMap.get(SIB_SetupConstants.RESPONSE_REASON_CODE)) ||
          responseMap.isEmpty()
        ) {
          calloutSuccess = false;
          //Logger.warn('Callout failed or response is empty', 'CalloutFailure');
        }
        String response = responseMap.get(SIB_SetupConstants.SERVICE_RESPONSE_BODY);
        if (calloutSuccess) {
          taxes = getTaxFromResponse(response, taxRequest);
          //Logger.debug('Tax calculation successful', 'CalculateTaxSuccess');
        }
      } catch (Exception expObj) {
        System.debug('Exception caught:'+expObj.getMessage());
        //Logger.error('Exception in calculateTax: ' + expObj.getMessage() + ' at Line Number: ' + expObj.getLineNumber(), 'CalculateTaxException');
        // WK_Exception.log(expObj, applicationName, moduleName, className,
        // methodName, supportData);
      }finally{
        //Logger.saveLog();
      }
      return taxes;
    }
  
    public abstract SIB_TaxProviderResponse getTaxFromResponse(
      String response,
      SIB_TaxProviderRequest taxRequest
    );
    public abstract void prepareCreateTransaction(
      SIB_TaxProviderRequest taxRequest,
      Map<String, String> callOutRequest
    );
  
    public void commitTransaction(SIB_TaxProviderRequest taxRequest) {
      //Logger.debug('Committing transaction for request: ' + taxRequest, 'CommitTransactionStart');
  
      SIB_TaxProviderResponse taxes;
      Map<String, String> responseMap;
      Boolean calloutSuccess = true;
      try {
        Map<String, String> callOutRequest = new Map<String, String>();
        callOutRequest.putAll(prepareNamedCredentials(taxRequest));
        callOutRequest.putAll(setServiceDetails(taxRequest));
        prepareCommitTransaction(taxRequest, callOutRequest);
        //Logger.debug('Making external callout for commit', 'MakeExternalCalloutCommit');
        responseMap = SIB_ServiceFactory.getService(
            taxRequest.taxMetaData.serviceImplClass
          )
          .makeExternalCallout(callOutRequest, setRequestHeaders(taxRequest));
        if (
          !'201'.equals(responseMap.get(SIB_SetupConstants.RESPONSE_REASON_CODE)) ||
          responseMap.isEmpty()
        ) {
          calloutSuccess = false;
          //Logger.warn('Commit callout failed or response is empty', 'CommitCalloutFailure');
        }
        String response = responseMap.get(SIB_SetupConstants.SERVICE_RESPONSE_BODY);
        if (calloutSuccess) {
          taxes = getTaxFromResponse(response, taxRequest);
          //Logger.debug('Transaction committed successfully', 'CommitTransactionSuccess');
        }
      } catch (Exception expObj) {
        System.debug('Exception caught:'+expObj.getMessage());
        //Logger.error('Exception in commitTransaction: ' + expObj.getMessage() + ' at Line Number: ' + expObj.getLineNumber(), 'CommitTransactionException');
      }finally{
        //Logger.saveLog();
      }
    }
    public abstract void prepareCommitTransaction(
      SIB_TaxProviderRequest taxRequest,
      Map<String, String> callOutRequest
    );
  }