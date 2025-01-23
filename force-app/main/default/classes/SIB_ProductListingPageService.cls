/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-15-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductListingPageService {

    private static final String CONFIG_TYPE = 'PLP';
    
    public static Map<String,Object> getPLPConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put('configurationType', CONFIG_TYPE);
        SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams != null && mapParams.containsKey('configJSON') && mapParams.get('configJSON') != null ) {
            SIB_PLPConfiguration plpConfig = SIB_PLPConfiguration.parse((String)mapParams.get('configJSON'));
            System.debug('plpConfig => '+ plpConfig);
            mapParams.put('plpConfig', plpConfig);
            mapParams.put('customPLP', true);
            isSuccess = true;
        }else{
            message = 'PLP Config JSON not found.';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public static Map<String,Object> getProducts(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        System.debug('mapParams:'+mapParams);
        if(mapParams != null &&
            mapParams.containsKey('webstoreId') && mapParams.get('webstoreId') != null && mapParams.containsKey('page') && 
            mapParams.get('page') != null && mapParams.containsKey('pageSize') && mapParams.get('pageSize') != null &&
            (mapParams.containsKey('recordId') || mapParams.containsKey('term'))) {
        
            Id effectiveAccountId = mapParams.containsKey('effectiveAccountId') ? (Id)mapParams.get('effectiveAccountId') : null;
            Id webstoreId = (Id)mapParams.get('webstoreId');
            String categoryId = (String)mapParams.get('recordId');
            String searchTerm = (String)mapParams.get('term');
            Integer page = Integer.valueOf(mapParams.get('page'));
            Integer pageSize = Integer.valueOf(mapParams.get('pageSize'));
            String sortRuleId = (String)mapParams.get('sortRuleId');
            List<SIB_ProductSearchRequest.RefinementInput> refinements = new List<SIB_ProductSearchRequest.RefinementInput>();
            if(mapParams.containsKey('refinements') && mapParams.get('refinements') != null) {
                String jsonMap = JSON.serialize(mapParams);
                Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(jsonMap);
                for (Object instance : (List<Object>)deserialized.get('refinements')) {
                    Map<String, Object> refinementMap = (Map<String, Object>)instance;
                    SIB_ProductSearchRequest.RefinementInput refinement = new SIB_ProductSearchRequest.RefinementInput();
                    refinement.nameOrId = (String)refinementMap.get('nameOrId');
                    refinement.attributeType = (String)refinementMap.get('attributeType');
                    List<String> values = new List<String>();
                    List<Object> valuesList = (List<Object>)refinementMap.get('values');
                    for(Object val : valuesList) {
                        values.add((String)val);
                    }
                    refinement.values = values;
                    refinements.add(refinement);
                }
            }
            
            ISIB_ProductSearchService productSearchService = SIB_DependencyService.getInstance().getProductSearchService();
            SIB_ProductSearchRequest request = new SIB_ProductSearchRequest();
            request.categoryId = categoryId;
            request.includePrices = true;
            request.page = page;
            request.pageSize = pageSize;
            request.refinements = refinements;
            request.searchTerm = searchTerm;
            request.sortRuleId = sortRuleId;
            request.webStoreId = webstoreId;
            request.accountId = effectiveAccountId;
            
            mapParams.put('searchResults', productSearchService.searchProducts(request));

            isSuccess = true;
        }else{
            message = 'MapParams missing attributes.';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    /**
     * @description get category for a given category name
     * @author garora@rafter.one
     * @created 27 Sep 24
    */
    public static Map<String,Object> getCategoryId(Map<String,Object> dataMap){
        if(dataMap!=null && dataMap.containsKey(SIB_Constants.CATEGORY_NAME) && dataMap.get(SIB_Constants.CATEGORY_NAME)!=null){
            String categoryName = (String) dataMap.get(SIB_Constants.CATEGORY_NAME);
            String storeName = SIB_Util.fetchConfigByValue(SIB_Constants.STOREFRONT_MODULE);
            WebStore store = [SELECT Id FROM WebStore WHERE Name = :storeName LIMIT 1];
            WebStoreCatalog storeCatalog = [SELECT Id,ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId=:store.Id LIMIT 1];
            ProductCategory category = [SELECT Id,Name FROM ProductCategory WHERE CatalogId=:storeCatalog.ProductCatalogId AND Name=:categoryName LIMIT 1];
            dataMap.put(SIB_Constants.CATEGORY_ID, category.Id);
        }
        return dataMap;
    }
}