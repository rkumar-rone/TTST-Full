public with sharing class SIB_CollevaAPIService {

    private static final String CLASSNAME = 'SIB_CollevaAPIService';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Process Colleva API';

    public SIB_CollevaAPIService() {}

    @InvocableMethod(Label='Invoke Colleva API' Description='Invoke Colleva API')
    public static List<SIB_CollevaAPIResponseVO> processCollevaApi(List<SIB_CollevaAPIRequestVO> requestParam)
    {
        String methodName = 'processCollevaApi';
        String supportData = '';
        SIB_CollevaAPIResponseVO apiResponse = null;
        List<SIB_CollevaAPIResponseVO> apiResponseList = new List<SIB_CollevaAPIResponseVO>();
        try {
            String strRequest = '';
            for(SIB_CollevaAPIRequestVO request : requestParam)
            {
                supportData += 'Request : '+JSON.serializePretty(request);
                if(request.actionName == 'invokeCreateUsers')
                {
                    request.actionName = null;
                    apiResponse = SIB_CollevaAPIHelper.invokeCreateUsers(request);
                }
                else if(request.actionName == 'fetchUserDetails')
                {
                    request.actionName = null;
                    Integer.valueOf(request.userId);
                    apiResponse = SIB_CollevaAPIHelper.fetchUserDetails(request);
                }
                else if(request.actionName == 'fetchUserAllowedUsage')
                {
                    request.actionName = null;
                    apiResponse = SIB_CollevaAPIHelper.fetchUserAllowedUsage(request);
                }
                else if(request.actionName == 'fetchUserProducts')
                {
                    request.actionName = null;
                    apiResponse = SIB_CollevaAPIHelper.fetchUserProducts(request);
                }
                apiResponseList.add(apiResponse);
            }

        } catch (Exception ex) {
            system.debug('invokeCreateUsers : '+ ex);
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);            
        }
        return apiResponseList;
    }
}