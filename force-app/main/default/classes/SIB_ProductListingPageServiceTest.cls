/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_ProductListingPageServiceTest {
	@TestSetup
    static void setup(){
        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.Active__c = true;
        testConfig.ConfigurationType__c = 'PLP';
        insert testConfig;
        String storeName = SIB_Util.fetchConfigByValue(SIB_Constants.STOREFRONT_MODULE);
        Webstore webstore = new Webstore(Name = storeName);
        insert webstore;
        
        Account acc = new Account(Name='test');
        insert acc;
        
        ProductCatalog productCatalog = new ProductCatalog(Name='Test');
        insert productCatalog;
        
        WebStoreCatalog storeCatalog = new WebStoreCatalog(SalesStoreId=webstore.Id,ProductCatalogId=productCatalog.Id);
        insert storeCatalog;
        
        ProductCategory productCategory = new ProductCategory(Name='Test',CatalogId=productCatalog.Id);
        insert productCategory;
    }
    @isTest
    static void getPLPConfigurationTest(){
        SIB_PLPConfiguration plp = new SIB_PLPConfiguration();
        plp.type = 'test';
        Map<String,Object> response = new Map<String,Object>();
        response.put(SIB_SetupConstants.CONFIG_JSON,JSON.serialize(plp));
        Test.startTest();
        response = SIB_ProductListingPageService.getPLPConfiguration(response);
        Test.stopTest();
        system.assertEquals(false,response.get(SIB_SetupConstants.IS_SUCCESS),'getPLPConfigurationTest assertion failed');
    }
    @isTest
    static void getPLPConfigurationElseTest(){
        Map<String,Object> response = new Map<String,Object>();
        Test.startTest();
        response = SIB_ProductListingPageService.getPLPConfiguration(response);
        Test.stopTest();
        system.assertEquals(false,response.get(SIB_SetupConstants.IS_SUCCESS),'getPLPConfigurationElseTest assertion failed');
    }
    
    @IsTest
    static void getProductsTest(){
        Webstore webstore = [SELECT Id FROM Webstore LIMIT 1];
        ProductCategory productCategory = [SELECT Id FROM ProductCategory LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,Object> response = new Map<String,Object>();
        response.put(SIB_Constants.WEBSTOREID,webstore.Id);
        response.put(SIB_Constants.PAGE,1);
        response.put(SIB_Constants.PAGESIZE,1);
        response.put(SIB_Constants.RECORD_ID,productCategory.Id);
        response.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,acc.Id);
        response.put(SIB_Constants.TERM,'test');
        Map<String, Object> refinementMap = new Map<String, Object>();
        refinementMap.put(SIB_Constants.NAME_OR_ID,'test');
        refinementMap.put(SIB_Constants.ATTRIBUTE_TYPE,'test');
        refinementMap.put(SIB_Constants.VALUES,new List<String>{'test1','test2'});
        response.put(SIB_Constants.REFINEMENTS,new List<Map<String,Object>>{refinementMap});
        Test.startTest();
        response = SIB_ProductListingPageService.getProducts(response);
        Test.stopTest();
        system.assertEquals(true,response.get(SIB_SetupConstants.IS_SUCCESS),'getProductsTest assertion failed');
    }
    
    @isTest
    static void getCategoryIdTest(){
        Map<String,Object> response = new Map<String,Object>();
        response.put(SIB_Constants.CATEGORY_NAME,'Test');
        Test.startTest();
        response = SIB_ProductListingPageService.getCategoryId(response);
        Test.stopTest();
        ProductCategory productCategory = [SELECT Id FROM ProductCategory LIMIT 1];
        system.assertEquals(productCategory.Id,response.get(SIB_Constants.CATEGORY_ID),'getCategoryIdTest assertion failed');
    }
}