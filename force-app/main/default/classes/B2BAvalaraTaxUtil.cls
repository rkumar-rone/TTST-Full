/**
 * @description       : 
 * @author            : Pochana Anand Kumar
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
public class B2BAvalaraTaxUtil {

    private static final String CLASSNAME = 'B2BAvalaraTaxUtil';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Tax Module';
    
    public static Map<String,B2BAvalaraTaxModel > calculateTax(String cartId, String docCode, String accName, String currencyCode, String taxTransactionType) {
        String methodName = '';
        String supportData = '';
        Map<String,B2BAvalaraTaxModel > mapAvaTaxModel = new Map<String,B2BAvalaraTaxModel>();
        Http http = new Http();
        try {
            B2B_AvalaraTaxSettings__mdt avalaraTaxSettings = B2B_AvalaraTaxSettings__mdt.getInstance(SIB_Constants.AVALARA_METADATA_AVATAX);
            HttpRequest req = getTaxServiceRequestHeader(avalaraTaxSettings.ServiceUrl__c);
            String body = B2BAvaTaxProvider.getTaxServiceRequestBody(cartId, docCode, avalaraTaxSettings, accName, currencyCode, taxTransactionType);
            req.setBody(body);
            System.debug('body : '+body);
            HttpResponse res = null;
            res = http.send(req);
            Integer statusCode = res.getStatusCode();
            if (statusCode == 201)
            {
                String avaResponse = res.getBody();
                System.debug('avaResponse : '+avaResponse);
                B2BAvaTaxResponseJSON avaTaxJSON = (B2BAvaTaxResponseJSON) System.JSON.deserialize(avaResponse, B2BAvaTaxResponseJSON.class);
                List<B2BAvaTaxResponseJSON.cls_lines> lstAvaTax = avaTaxJSON.lines;
                for(B2BAvaTaxResponseJSON.cls_lines objTax : lstAvaTax)
                {
                    B2BAvalaraTaxModel tax = new B2BAvalaraTaxModel();
                    tax.taxAmount =objTax.taxCalculated;
                    List<B2BAvaTaxResponseJSON.cls_details> lstAvaTaxDetails = objTax.details;
                    Decimal totalTaxRate = 0.0 ;
                    for(B2BAvaTaxResponseJSON.cls_details objTaxDetails : lstAvaTaxDetails)
                    {
                        totalTaxRate += objTaxDetails.rate;
                    }
                    tax.taxRate = totalTaxRate;
                    mapAvaTaxModel.put(objTax.itemCode,tax);
                }
            } else if (statusCode == 400)
            {
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_INVALID_CODE);
            } else
            {
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_SERVICE_ERROR);
            }
        } catch(System.CalloutException expObject)
        {
            // SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
            throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_CALLOUT);
        }
        return mapAvaTaxModel;
    }

    public static Map<String,B2BAvalaraTaxModel > calculateTaxes(CartExtension.Cart cartExtensionObject , String docCode, String accName, String currencyCode, String taxTransactionType) {
        String methodName = 'calculateTaxes';
        String supportData = '';
        String appName = 'Tax Calculation';
        String appRequest = '';
        String appResponse = '';
        String recordId = '';
        Map<String,B2BAvalaraTaxModel > mapAvaTaxModel = new Map<String,B2BAvalaraTaxModel>();
        Http http = new Http();
        try {
            B2B_AvalaraTaxSettings__mdt avalaraTaxSettings = B2B_AvalaraTaxSettings__mdt.getInstance(SIB_Constants.AVALARA_METADATA_AVATAX);
            HttpRequest req = getTaxServiceRequestHeader(avalaraTaxSettings.ServiceUrl__c);
            String body = B2BAvaTaxProvider.generateTaxServiceRequestBody(cartExtensionObject, docCode, avalaraTaxSettings, accName, currencyCode, taxTransactionType);
            req.setBody(body);
            appRequest = body;
            recordId = cartExtensionObject.getId();
            HttpResponse res = null;
            res = http.send(req);
            Integer statusCode = res.getStatusCode();
            String avaResponse = res.getBody();
            appResponse =  avaResponse;
            if (statusCode == 201)
            {
                B2BAvaTaxResponseJSON avaTaxJSON = (B2BAvaTaxResponseJSON) System.JSON.deserialize(avaResponse, B2BAvaTaxResponseJSON.class);
                List<B2BAvaTaxResponseJSON.cls_lines> lstAvaTax = avaTaxJSON.lines;
                for(B2BAvaTaxResponseJSON.cls_lines objTax : lstAvaTax)
                {
                    SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Line : Product Code  : ' + objTax.itemCode);
                    SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Line : Taxable Amount : ' + objTax.taxableAmount);
                    SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Line : Non-Taxable Amount : ' + objTax.nonTaxableAmount);
                    SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Line : Tax Calculated : ' + objTax.taxCalculated);
                    B2BAvalaraTaxModel tax = new B2BAvalaraTaxModel();
                    tax.taxAmount = objTax.taxCalculated;
                    List<B2BAvaTaxResponseJSON.cls_details> lstAvaTaxDetails = objTax.details;
                    Decimal totalTaxRate = 0.0 ;
                    for(B2BAvaTaxResponseJSON.cls_details objTaxDetails : lstAvaTaxDetails)
                    {
                        SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Line : Tax Rate : ' + objTaxDetails.rate);
                        totalTaxRate += objTaxDetails.rate;
                    }
                    SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Line : Total Tax Rate : ' + totalTaxRate);
                    tax.taxRate = totalTaxRate;
                    mapAvaTaxModel.put(objTax.itemCode,tax);
                }
                SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Cart : Total Tax Amount : ' + avaTaxJSON.totalAmount);
                SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Cart : Total Tax Exempt Amount : ' + avaTaxJSON.totalExempt);
                SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Cart : Total Calculated Tax Amount : ' + avaTaxJSON.totalTax);
                SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Cart : Adjustment Reason : ' + avaTaxJSON.adjustmentReason);
            } else if (statusCode == 400)
            {
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_INVALID_CODE);
            } else
            {
                throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_SERVICE_ERROR);
            }
        } catch(System.CalloutException expObject)
        {
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Exception Stacktrace : ' + expObject.getStackTraceString());
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Exception Message : ' + expObject.getMessage());
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Exception Cause  : ' + expObject.getCause());
            System.debug('>>>>>>getMessage>>>>.'+expObject.getMessage());
            System.debug('>>>>>>getStackTraceString>>>>.'+expObject.getStackTraceString());
            System.debug('>>>>>>getCause>>>>.'+expObject.getCause());
            // SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
            throw new B2BTaxException(B2BTaxException.EXCEPTION_TAX_CALLOUT);
        }finally
        {
            if (SIB_Logger.logList != null && SIB_Logger.logList.size() > 0)
            {
                for (SIB_Log b2bLogObject : SIB_Logger.logList)
                {
                    supportData += b2bLogObject.methodName + ' - ' + b2bLogObject.message + '\n';
                }
            }
            SIB_CaptureApplicationLog.futureCaptureApplicationLog(appName , appRequest , appResponse , recordId , supportData);
        }
        return mapAvaTaxModel;
    }
    
    public static HttpRequest getTaxServiceRequestHeader(String taxServiceUrl) {
        HttpRequest req = new HttpRequest();
        req.setMethod(SIB_Constants.POST_METHOD);
        req.setHeader('content-type', 'application/json');
        req.setEndpoint('callout:Avalara'+taxServiceUrl);
        return req;
    }
}