/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductDetailService {
    private static final String CONFIG_TYPE = 'PDP';

    public static Map<String,Object> getPDPConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE,CONFIG_TYPE );
        SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams != null && mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON) && mapParams.get(SIB_SetupConstants.CONFIG_JSON) != null ) {
            SIB_PDPConfiguration pdpConfig = SIB_PDPConfiguration.parse((String)mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            mapParams.put(SIB_Constants.PDP_CONFIG, pdpConfig);
            mapParams.put(SIB_Constants.CUSTOM_PDP, pdpConfig.customPDP);
            isSuccess = true;
        }else{
            message = SIB_Constants.PDP_CONFIG_JSON_NOT_FOUND;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> getProductDetails(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams.containsKey(SIB_Constants.RECORD_ID) && mapParams.get(SIB_Constants.RECORD_ID) != null
            && mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null ) {
            
            Id recordId = (Id)mapParams.get(SIB_Constants.RECORD_ID);
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);
            
            ISIB_ProductService productService = SIB_DependencyService.getInstance().getProductService();
            SIB_ProductRequest request = new SIB_ProductRequest(recordId, false, true);
            request.accountId = effectiveAccountId;
            request.webstoreId = webstoreId;
            mapParams.put(SIB_Constants.PRODUCT, productService.getProductDetail(request));
            
            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> getRelatedProducts(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        
        if(mapParams != null && 
            mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null && 
            (mapParams.containsKey(SIB_Constants.PRODUCT_ID) || mapParams.containsKey(SIB_Constants.PRODUCT_ID_LIST))) {
            
            List<Id> productIds = new List<Id>();
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);
    
            if(mapParams.containsKey(SIB_Constants.PRODUCT_ID)) {
                Id productId = (Id)mapParams.get(SIB_Constants.PRODUCT_ID);
                productIds.add(productId);
            } else if(mapParams.containsKey(SIB_Constants.PRODUCT_ID_LIST)) {
                List<Object> productIdList = (List<Object>)mapParams.get(SIB_Constants.PRODUCT_ID_LIST);
                for(Object pro : productIdList) {
                    productIds.add((Id) String.valueOf(pro));
                }
            }
    
            if(!productIds.isEmpty()) {
                ISIB_RelatedProductService relatedProductService = SIB_DependencyService.getInstance().getRelatedProductService();
                SIB_ProductRequest request = new SIB_ProductRequest(productIds, true, true);
                request.accountId = effectiveAccountId;
                request.webstoreId = webstoreId;
                Map<String, List<SIB_RelatedProduct>> relatedProductMapByType = relatedProductService.getRelatedProducts(request);
                
                if(!relatedProductMapByType.isEmpty()){
                    mapParams.put(SIB_Constants.RELATED_PRODUCT_MAP, relatedProductMapByType);
                    isSuccess = true;
                } else {
                    message = SIB_Constants.NO_RELATED_PRODUCT_FOUND;
                }
            }
            else{
                message = SIB_Constants.NO_PRODUCT_FOUND;
            }
        } else {
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        mapParams.put(SIB_Constants.Recommendations_count, SIB_Util.fetchConfigByValue(SIB_Constants.No_Of_Recommendations));
        return mapParams;
    }
    
    public static Map<String,Object> updateBuyerAndAccountCurrency(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null && mapParams.containsKey(SIB_Constants.CURRENCY_CODE) && mapParams.get(SIB_Constants.CURRENCY_CODE) != null) {
            String currencyCode = (String)mapParams.get(SIB_Constants.CURRENCY_CODE);
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            if(effectiveAccountId != null) {
    
                BuyerAccount buyerAccount = [
                    SELECT Id, CurrencyIsoCode, IsActive, Buyer.Name
                    FROM BuyerAccount
                    WHERE BuyerId = :effectiveAccountId
                ];
                buyerAccount.CurrencyIsoCode = currencyCode;
                update buyerAccount;
                
                Account acc = new Account();
                acc.Id = effectiveAccountId;
                acc.CurrencyIsoCode = currencyCode;
                update acc;

                isSuccess = true;
            }
        } else {
            message = SIB_Constants.PARAM_MISSIING_MSG;
        } 

        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String, Object> getEventRelationshipChildNames(Map<String, Object> mapParams) {
        // Check for productId in the mapParams
        if (mapParams != null && mapParams.containsKey(SIB_Constants.PRODUCT_ID) && mapParams.get(SIB_Constants.PRODUCT_ID) != null) {
            String productId = (String)mapParams.get(SIB_Constants.PRODUCT_ID);
            
            // Get the list of products by productId
            List<Product2> products = SIB_ProductSelector.getProductByIds(new List<Id>{ productId });
            
            // Collect related TTS_Event__c Ids
            List<Id> ttsEventIds = new List<Id>();
            for (Product2 prod : products) {
                if (prod.TTS_Event__c != null) {
                    ttsEventIds.add(prod.TTS_Event__c);
                }
            }
    
            // Query event relationships by TTS_Event__c Ids
            if (!ttsEventIds.isEmpty()) {
                List<Event_Relationship__c> eventRelationshipChildRecords = (List<Event_Relationship__c>) SIB_EventRelationshipSelector.getEventRelationshipsByEventIds(ttsEventIds);
                
                List<Id> childIds = new List<Id>();
                for (Event_Relationship__c eventChild : eventRelationshipChildRecords) {
                    if (eventChild.Child__r != null) {
                        childIds.add(eventChild.Child__c);
                    }
                }

                List<Product2> bundleChildProductDetails  = (List<Product2>) SIB_ProductSelector.getProductByEventIds(childIds);

                mapParams.put(SIB_Constants.BUNDLE_CHILD_PRODUCT_DETAILS, bundleChildProductDetails);
            }
        }
        return mapParams;
    }
    
    public static Map<String,Object> getProductCurrency(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null && mapParams.containsKey(SIB_Constants.RECORD_ID) && mapParams.get(SIB_Constants.RECORD_ID) != null ) {
            
            Id recordId = (Id)mapParams.get(SIB_Constants.RECORD_ID);
            
            List<Product2> products = (List<Product2>)SIB_ProductSelector.getProductByIds(new List<Id>{recordId});
            if(products != null && !products.isEmpty()) {
                mapParams.put(SIB_Constants.PARAM_CURRENCYISOCODE, products.get(0).CurrencyIsoCode);
            }
            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }
}