/**
 * @description       : Test class for SIB_ProductDetailController
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendra
**/
@isTest
public class SIB_ProductDetailControllerTest {
@TestSetup
    static void setup(){
        Product2 prod = new Product2(Name='Test');
        insert prod;
       
        Account acc = new Account(Name='test');
        insert acc;
        BuyerAccount buyerAcc = new BuyerAccount();
        buyerAcc.BuyerId = acc.Id;
        buyerAcc.IsActive = true;
        buyerAcc.Name = acc.Name;
        insert buyerAcc;

        Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
    }
    
    @isTest
    static void getProductDetailConfigurationTest(){
        Map<String,Object> mapParams = new Map<String,Object>();
        String pdpJson = '{"customPDP":"true"}';
        mapParams.put(SIB_SetupConstants.CONFIG_JSON,pdpJson);
        Test.startTest();
        mapParams = SIB_ProductDetailController.getProductDetailConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_Constants.IS_SUCCESS),'getProductDetailConfigurationTest assertion failed');
	}
    
	@isTest
    static void getPDPConfigurationTestExceptionCase(){
        Map<String,Object> mapParams = new Map<String,Object>();
        String pdpJson = 'exception';
        mapParams.put(SIB_SetupConstants.CONFIG_JSON,pdpJson);
        Test.startTest();
        mapParams = SIB_ProductDetailController.getProductDetailConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_Constants.IS_SUCCESS),'getPDPConfigurationTestExceptionCase assertion failed');
	}
    
    @isTest
    static void getProductDetailsTest(){
        Product2 testProd = [SELECT Id FROM Product2 LIMIT 1];
    	Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.RECORD_ID,testProd.Id);
        mapParams.put(SIB_Constants.WEBSTOREID,'000000000000000AAA');
        Test.startTest();
        mapParams = SIB_ProductDetailService.getProductDetails(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_Constants.IS_SUCCESS),'getProductDetailsTest assertion failed');

    }
    
    @isTest
    static void getProductDetailsTestExceptionCase(){
    	Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.RECORD_ID,'exception');
        mapParams.put(SIB_Constants.WEBSTOREID,'exception');
        mapParams.put(SIB_Constants.RECORD_ID,'exception');
        Test.startTest();
        mapParams = SIB_ProductDetailController.getProductDetails(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_Constants.IS_SUCCESS),'getProductDetailsTestExceptionCase assertion failed');
    }
    
    @isTest
    static void getRelatedProductsTest(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.PRODUCT_ID,prod.Id);
        dataMap.put(SIB_Constants.WEBSTOREID,'000000000000000AAA');
        dataMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,'000000000000000AAA');
        Test.startTest();
        dataMap = SIB_ProductDetailController.getRelatedProducts(dataMap);
        Test.stopTest();
        system.assertEquals(false,dataMap.get(SIB_Constants.IS_SUCCESS),'getRelatedProductsTest assertion failed');
    }
    
    @isTest
    static void getRelatedProductsTestExceptionCase(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        List<String> prodIds = new List<String>{prod.Id};
        dataMap.put(SIB_Constants.PRODUCT_ID_LIST,prodIds);
        dataMap.put(SIB_Constants.WEBSTOREID,'exception');
        dataMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,'exception');
        Test.startTest();
        dataMap = SIB_ProductDetailController.getRelatedProducts(dataMap);
        Test.stopTest();
        system.assertEquals(false,dataMap.get(SIB_Constants.IS_SUCCESS),'getRelatedProductsTestExceptionCase assertion failed');
    }
    
    @isTest
    static void updateBuyerAndAccountCurrencyTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.CURRENCY_CODE,'USD');
        mapParams.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,acc.Id);
        Test.startTest();
        mapParams = SIB_ProductDetailController.updateBuyerAndAccountCurrency(mapParams);

        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_Constants.IS_SUCCESS),'updateBuyerAndAccountCurrencyTest assertion failed');
    }

    @isTest
    static void getEventRelationshipChildNamesTest(){
        Product2 testProd = [SELECT Id FROM Product2 LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.CURRENCY_CODE,'USD');
        mapParams.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,acc.Id);
        mapParams.put(SIB_Constants.PRODUCT_ID,testProd.Id);
        mapParams.put(SIB_Constants.RECORD_ID,testProd.Id);

        Test.startTest();
        Map<String,Object> mapGetEventRelationshipChildName = SIB_ProductDetailController.getEventRelationshipChildNames(mapParams);
        Map<String,Object> mapGetProductCurrency = SIB_ProductDetailController.getProductCurrency(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_Constants.IS_SUCCESS),'updateBuyerAndAccountCurrencyTest assertion failed');
    }
    
    @isTest
    static void updateBuyerAndAccountCurrencyTestExceptioCase(){
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.CURRENCY_CODE,'exception');
        mapParams.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,'exception');
        mapParams.put(SIB_Constants.PRODUCT_ID,'exception');
        mapParams.put(SIB_Constants.RECORD_ID,'exception');
        Test.startTest();
        mapParams = SIB_ProductDetailController.updateBuyerAndAccountCurrency(mapParams);
        Map<String,Object> mapGetEventRelationshipChildName = SIB_ProductDetailController.getEventRelationshipChildNames(mapParams);
        Map<String,Object> mapGetProductCurrency = SIB_ProductDetailController.getProductCurrency(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_Constants.IS_SUCCESS),'updateBuyerAndAccountCurrencyTestExceptioCase assertion failed');
    }


}