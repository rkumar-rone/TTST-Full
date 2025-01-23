/**
 * @description       :
 * @author            : Gaurang Arora
 * @group             :
 * @last modified on  : 11-03-2024
 * @last modified by  :
**/
@isTest
public class SIB_ConfigControllerTest {
	@TestSetup
    static void setup(){
        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.Active__c = true;
        testConfig.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_CART;
        insert testConfig;   
        SIB_StorefrontConfiguration__c testConfig2 = new SIB_StorefrontConfiguration__c();
        testConfig2.Active__c = true;
        testConfig2.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP;
        insert testConfig2; 
        SIB_StorefrontConfiguration__c testConfig3 = new SIB_StorefrontConfiguration__c();
        testConfig3.Active__c = true;
        testConfig3.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_HOME;
        insert testConfig3; 
        SIB_StorefrontConfiguration__c testConfig4 = new SIB_StorefrontConfiguration__c();
        testConfig4.Active__c = true;
        testConfig4.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_PLP;
        insert testConfig4;
        SIB_StorefrontConfiguration__c testConfig5 = new SIB_StorefrontConfiguration__c();
        testConfig5.Active__c = true;
        testConfig5.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_PDP;
        insert testConfig5;
        SIB_StorefrontConfiguration__c testConfig6 = new SIB_StorefrontConfiguration__c();
        testConfig6.Active__c = true;
        testConfig6.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT;
        insert testConfig6;
        SIB_StorefrontConfiguration__c testConfig7 = new SIB_StorefrontConfiguration__c();
        testConfig7.Active__c = true;
        testConfig7.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS;
        insert testConfig7;
        SIB_StorefrontConfiguration__c testConfig8 = new SIB_StorefrontConfiguration__c();
        testConfig8.Active__c = true;
        testConfig8.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT;
        insert testConfig8;
        SIB_StorefrontConfiguration__c testConfig9 = new SIB_StorefrontConfiguration__c();
        testConfig9.Active__c = true;
        testConfig9.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER;
        insert testConfig9;
        SIB_StorefrontConfiguration__c testConfig10 = new SIB_StorefrontConfiguration__c();
        testConfig10.Active__c = true;
        testConfig10.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU;
        insert testConfig10;    
    }
    
    @isTest
    static void updateConfigDataSIGNUPTest(){
        SIB_ConfigController.SignUpConfigWrapper wrapper = new SIB_ConfigController.SignUpConfigWrapper();
        wrapper.id = 'test';
        wrapper.showPasswordFields = true;
        Map<String,String> response = new Map<String,String>();
        Test.startTest();
        response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataSIGNUPTest assertion failed');
    }
    
    @isTest
    static void updateConfigDataSIGNUPExceptionTest(){
        List<SIB_StorefrontConfiguration__c> sib = [SELECT Id FROM SIB_StorefrontConfiguration__c WHERE ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP];
        delete sib;
        SIB_ConfigController.SignUpConfigWrapper wrapper = new SIB_ConfigController.SignUpConfigWrapper();
        wrapper.id = 'test';
        wrapper.showPasswordFields = true;
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_ERROR,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataSIGNUPTest assertion failed');
    }
    
    @isTest
    static void updateConfigDataHOMETest(){
        SIB_ConfigController.ComponentWrapper cw = new SIB_ConfigController.ComponentWrapper();
        cw.Component = 'test';
        SIB_ConfigController.HomeConfigWrapper wrapper = new SIB_ConfigController.HomeConfigWrapper();
        wrapper.id = 'test';
        wrapper.Header = new List<SIB_ConfigController.ComponentWrapper>{cw};
        wrapper.Product = new List<SIB_ConfigController.ComponentWrapper>{cw};
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_HOME);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataHOMETest assertion failed');
    }
    
    @isTest
    static void updateConfigDataPLPTest(){
        SIB_ConfigController.PLPConfigWrapper wrapper = new SIB_ConfigController.PLPConfigWrapper();
        wrapper.id = 'test';
        wrapper.defaultView = 'test';
        wrapper.availableLayouts = new List<String>{'test'};
        wrapper.showLayoutButtons = true;
        wrapper.showProductImage = true;
        wrapper.showNegotiatedPrice = true;
        wrapper.showOriginalPrice = true;
        wrapper.showCallToActionButton = true;
        wrapper.addToCartButtonText = 'test';
        wrapper.unavailablePriceText = 'test';
        wrapper.addToCartButtonProcessingText = 'test';
        wrapper.viewOptionsButtonText = 'test';
        SIB_ConfigController.CardContentMappingWrapper ccmw = new SIB_ConfigController.CardContentMappingWrapper();
        ccmw.name='test';
        ccmw.showLabel = true;
        ccmw.label = 'test';
        wrapper.cardContentMapping = new List<SIB_ConfigController.CardContentMappingWrapper>{ccmw};
        wrapper.addToCartButtonStyle = 'test';
        wrapper.gridMaxColumnsDisplayed = 1;
        wrapper.searchResultsPageSize = 1;
        wrapper.selfStudyPageSize = 1;
        wrapper.searchResultsFields = new List<String>{'test'};
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_PLP);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataPLPTest assertion failed');        
    }
    
    @isTest
    static void updateConfigDataPDPTest(){
        SIB_ConfigController.PDPConfigWrapper wrapper = new SIB_ConfigController.PDPConfigWrapper();
        wrapper.id = 'test';
        wrapper.customPDP = 'test';
        SIB_ConfigController.ProductTypeWrapper pdw = new SIB_ConfigController.ProductTypeWrapper();
        pdw.productType = 'test';
        pdw.shortDescriptionField = 'test';
        pdw.tierPricingConfig = new Map<String,String>();
        pdw.displayPromotionalPrice = true;
        pdw.displayRelatedProduct = true;
        SIB_ConfigController.RelatedProductTypeWrapper rptw = new SIB_ConfigController.RelatedProductTypeWrapper();
        rptw.apiName = 'test';
        rptw.displayName = 'test';
        pdw.relatedProductTypes = new List<SIB_ConfigController.RelatedProductTypeWrapper>{rptw};
        pdw.displayPageSections = true;
        pdw.pageSectionStyle = 'test';
        SIB_ConfigController.PageSectionWrapper psw = new SIB_ConfigController.PageSectionWrapper();
        psw.apiName = 'test';
        psw.title = 'test';
        psw.showOnlyWhenApplicable = true;
        psw.fieldAPIName = 'test';
        pdw.pageSections = new List<SIB_ConfigController.PageSectionWrapper>{psw};
        wrapper.productTypeList = new List<SIB_ConfigController.ProductTypeWrapper>{pdw};
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_PDP);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataPDPTest assertion failed');                
    }
    
    @isTest
    static void updateConfigDataCARTTest(){
        SIB_ConfigController.CartConfigWrapper wrapper = new SIB_ConfigController.CartConfigWrapper();
        wrapper.id = 'test';
        wrapper.showUniqueCount = true;
        wrapper.allowPromoCode = true;
        wrapper.showRemoveItemOption = true;
        wrapper.showMoreItemsOption = true;
        wrapper.showLineItemTotal = true;
        wrapper.showOriginalPrice = true;
        wrapper.showSKU = true;
        wrapper.showProductImage = true;
        wrapper.showPricePerUnit = true;
        wrapper.showActualPrice = true;
        wrapper.hideQuantitySelector = true;
        wrapper.showSavedAmount = true;
        wrapper.productFields = new List<SIB_ConfigController.CardContentMappingWrapper>();
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_CART);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataCARTTest assertion failed');                
    }
    
    @isTest
    static void updateConfigDataCHECKOUTTest(){
        SIB_ConfigController.CheckoutConfigWrapper wrapper = new SIB_ConfigController.CheckoutConfigWrapper();
        wrapper.id = 'test';
        wrapper.displayLayout = 'test';
        wrapper.availablePaymentMethods = new List<String>();
        wrapper.creditCardGateway = 'test';
        wrapper.creditCardGatewayClassMap = new Map<String,String>();
        wrapper.allowPromoCode = true;
        wrapper.isShippingProviderEnabled = true;
        wrapper.shippingProvider = new List<String>();
        wrapper.isTaxProviderEnabled = true;
        wrapper.taxProvider = 'test';
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataCHECKOUTTest assertion failed');                   
    }
    @isTest
    static void updateConfigDataCHECKOUTTest2(){
        SIB_ConfigController.CheckoutConfigWrapper wrapper = new SIB_ConfigController.CheckoutConfigWrapper();
        wrapper.id = 'test';
        wrapper.displayLayout = 'test';
        wrapper.availablePaymentMethods = new List<String>();
        wrapper.creditCardGateway = 'test';
        wrapper.creditCardGatewayClassMap = new Map<String,String>();
        wrapper.allowPromoCode = true;
        wrapper.isShippingProviderEnabled = true;
        wrapper.shippingProvider = new List<String>();
        wrapper.isTaxProviderEnabled = false;
        wrapper.taxProvider = 'test';
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataCHECKOUTTest2 assertion failed');                   
    }
    
    @isTest
    static void updateConfigDataORDER_DETAILSTest(){
        SIB_ConfigController.OrderDetailsConfigWrapper wrapper = new SIB_ConfigController.OrderDetailsConfigWrapper();
        wrapper.id = 'test';
        wrapper.pageType = 'test';
        wrapper.objectApiName = 'test';
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataORDER_DETAILSTest assertion failed');                   
    }
    
    @isTest
    static void updateConfigDataSTOREFRONTTest(){
        SIB_ConfigController.StorefrontConfigWrapper wrapper = new SIB_ConfigController.StorefrontConfigWrapper();
        wrapper.subscriptionService = 'test';
        wrapper.subscriptionAutomatedRenewals = true;
        wrapper.searchMgmtNCartService = 'test';
        wrapper.productService = 'test';
        wrapper.pricingService = 'test';
        wrapper.isSupportedProductTypeUsageProduct = true;
        wrapper.isSupportedProductTypeSubscriptionProduct = true;
        wrapper.isSupportedProductTypeBundle = true;
        wrapper.isSubscriptionServiceCustom = true;
        wrapper.isSubscriptionActionTypeRenew = true;
        wrapper.isSubscriptionActionTypeNew = true;
        wrapper.isSubscriptionActionTypeCancellationSupport = true;
        wrapper.isSubscriptionActionTypeAmend = true;
		wrapper.isSearchMgmtNCartServiceCustom = 'test';
       	wrapper.isProductServiceCustom = true;
        wrapper.isPricingServiceCustom = true;
        wrapper.isInventoryServiceCustom = true;
		wrapper.inventoryService = 'test';
        wrapper.automatedRenewalPeriod = 'test';
        wrapper.productSearchService = 'test';
        wrapper.isProductSearchServiceCustom = true;
        wrapper.cartService = 'test';
        wrapper.isCartServiceCustom = true;
        wrapper.relatedProductService = 'test';
        wrapper.isRelatedProductServiceCustom = true;
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataSTOREFRONTTest assertion failed');                   
    }
    
    @isTest
    static void updateConfigDataFOOTERTest(){
        SIB_FooterConfiguration wrapper = new SIB_FooterConfiguration();
        wrapper.id = 'test';
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataFOOTERTest assertion failed');                           
    }
    
    @isTest
    static void updateConfigDataMEGA_MENUTest(){
        SIB_MegaMenuConfiguration wrapper = new SIB_MegaMenuConfiguration();
        Test.startTest();
        Map<String,String> response = SIB_ConfigController.updateConfigData(JSON.serialize(wrapper), '1', SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU);
        Test.stopTest();
        system.assertEquals(SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS,response.get(SIB_SetupConstants.METHOD_STATUS),'updateConfigDataMEGA_MENUTest assertion failed');                           
    }
    
    @isTest
    static void getProductFieldsTest(){
        Test.startTest();
        Map<String,Object> response = SIB_ConfigController.getProductFields();
        Test.stopTest();
        system.assertEquals(true,response.size()>1,'getProductFieldsTest assertion failed');
    }
    
    @isTest
    static void TierPricingConfigWrapperTest(){
        Test.startTest();
        SIB_ConfigController.TierPricingConfigWrapper tpcw = new SIB_ConfigController.TierPricingConfigWrapper();
        tpcw.config = new Map<String,String>();
        Test.stopTest();
    }
    
    @isTest
    static void getSIBRelatedProductPicklistValuesTest(){
        Test.startTest();
        List<Map<String, String>> response = SIB_ConfigController.getSIBRelatedProductPicklistValues();
        Test.stopTest();
        system.assertEquals(true,response.size()>1,'getSIBRelatedProductPicklistValues assertion failed');
    }
    
    
    @isTest
    static void fetchConfigDataTest(){
        Test.startTest();
        String response = SIB_ConfigController.fetchConfigData('CART');
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchConfigDataTest assertion failed');
    }
    
    @isTest
    static void fetchJSONConfigTest1(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest1 assertion failed');
    }
    @isTest
    static void fetchJSONConfigTest2(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_HOME);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest2 assertion failed');
        
    }
    @isTest
    static void fetchJSONConfigTest3(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_PLP);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest3 assertion failed');

    }
    @isTest
    static void fetchJSONConfigTest4(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_PDP);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest4 assertion failed');
        
    }
    @isTest
    static void fetchJSONConfigTest5(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_CART);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest5 assertion failed');

    }
    @isTest
    static void fetchJSONConfigTest6(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest6 assertion failed');

    }
    @isTest
    static void fetchJSONConfigTest7(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest7 assertion failed');

    }
    @isTest
    static void fetchJSONConfigTest8(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest8 assertion failed');

    }
    @isTest
    static void fetchJSONConfigTest9(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest9 assertion failed');

    }
    @isTest
    static void fetchJSONConfigTest10(){
        Test.startTest();
        String response = SIB_ConfigController.fetchJSONConfig(SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU);
        Test.stopTest();
        system.assertEquals(true,response.length()>1,'fetchJSONConfigTest10 assertion failed');

    }
}