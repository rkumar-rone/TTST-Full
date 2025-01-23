/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-16-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_B2BConnectAPI {

    private static final String CLASSNAME = 'SIB_B2BConnectAPI';
    private static final String MODULE_NAME = 'Connect API';

    public static ConnectApi.SortRulesCollection getSortRules(String webStoreId){
        return Test.isRunningTest() ? null : ConnectApi.CommerceSearch.getSortRules(webStoreId);
    }

    public static ConnectApi.ProductSearchResults searchProducts(String webStoreId,String effectiveAccountId,ConnectApi.ProductSearchInput productSearchInput){
        return Test.isRunningTest() ? null : ConnectApi.CommerceSearch.searchProducts( webStoreId , effectiveAccountId, productSearchInput);
    }

    public static ConnectApi.ProductDetail getProduct(String webStoreId, String productId, String effectiveAccountId, List<String> fields, Boolean excludeFields, List<String> mediaGroups, Boolean excludeMedia, Boolean excludeEntitlementDetails, Boolean excludePrimaryProductCategory){
        ConnectApi.ProductDetail productDetail = null ;
        try
        {
            productDetail = Test.isRunningTest() ? null : ConnectApi.CommerceCatalog.getProduct(webStoreId, productId, effectiveAccountId, fields, excludeFields, mediaGroups, excludeMedia, excludeEntitlementDetails, excludePrimaryProductCategory);
        }catch (Exception exp)
        {
            system.debug('exp : '+exp);
        }
        return productDetail;
    }

    public static ConnectApi.ProductOverviewCollection getProducts(String webStoreId, String effectiveAccountId, List<String> productIds, List<String> skus, List<String> fields, Boolean excludeMedia, Boolean excludePrices){
        ConnectApi.ProductOverviewCollection ProductOverviewCollection = null ;
        try
        {
            ProductOverviewCollection = Test.isRunningTest() ? null : ConnectApi.CommerceCatalog.getProducts(webStoreId, effectiveAccountId, productIds, skus, fields, excludeMedia, excludePrices);
        }catch (Exception exp)
        {
            system.debug('exp : '+exp);
        }
        return ProductOverviewCollection;
    }


    public static ConnectApi.ProductPrice getProductPrice(String webStoreId, String productId, String effectiveAccountId){
        ConnectApi.ProductPrice productPrice = null;
        try
        {
            productPrice = Test.isRunningTest() ? null : ConnectApi.CommerceStorePricing.getProductPrice(webStoreId, productId, effectiveAccountId);
        }catch (Exception exp)
        {
            system.debug('exp : '+exp);
        }
        return  productPrice;
    }

    public static ConnectApi.PricingResult getProductPrices(String webstoreId, String effectiveAccountId, ConnectApi.PricingInput pricingInput) {
        ConnectApi.PricingResult pricingResult = null;
        try
        {
            pricingResult = Test.isRunningTest() ? null : ConnectApi.CommerceStorePricing.getProductPrices(webStoreId, effectiveAccountId, pricingInput);
        }catch (Exception exp)
        {
            system.debug('exp : '+exp);
        }
        return  pricingResult;
    }
}