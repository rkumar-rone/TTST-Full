/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : vramachandran@rafter.one
**/
@isTest
public class SIB_DependencyServiceTest {

    @testSetup
    static void testDataSetup() {
        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.Active__c = true;
        testConfig.ConfigurationType__c = 'STOREFRONT';
        testConfig.ConfigJSON__c = '{"subscriptionService":"SIB_CustomSubscription","subscriptionAutomatedRenewals":false,"searchMgmtNCartService":null,"relatedProductService":"SIB_B2BRelatedProductService","productService":"SIB_B2BProductService","productSearchService":"SIB_B2BProductSearchService","pricingService":"SIB_B2BPricingService","isSupportedProductTypeUsageProduct":true,"isSupportedProductTypeSubscriptionProduct":true,"isSupportedProductTypeBundle":true,"isSubscriptionServiceCustom":true,"isSubscriptionActionTypeRenew":true,"isSubscriptionActionTypeNew":true,"isSubscriptionActionTypeCancellationSupport":true,"isSubscriptionActionTypeAmend":true,"isSearchMgmtNCartServiceCustom":null,"isRelatedProductServiceCustom":false,"isProductServiceCustom":false,"isProductSearchServiceCustom":false,"isPricingServiceCustom":false,"isInventoryServiceCustom":true,"isCartServiceCustom":false,"inventoryService":"InventoryService","cartService":"SIB_B2BCartService","automatedRenewalPeriod":""}';
        insert testConfig;
    }
    
    @isTest
    static void getInstanceTest() {
        Test.startTest();
        SIB_DependencyService service = SIB_DependencyService.getInstance();
        service.getProductService();
        service.getProductSearchService();
        service.getAllServices();
        service.getCartService();
        service.getInventoryService();
        service.getPricingService();
        service.getProductService();
        service.getRelatedProductService();
        service.getService('SIB_B2BProductService');
        
        Test.stopTest();
    }
}