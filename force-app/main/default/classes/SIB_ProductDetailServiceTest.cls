/**
 * @description       : Test class for SIB_ProductDetailService
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  :
**/
@isTest
public class SIB_ProductDetailServiceTest {
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

        Campaign ttsEvent = new Campaign();
        ttsEvent.Account__c  = acc.Id;
        ttsEvent.Name = 'Testtts Event';
        insert ttsEvent;

        Event_Relationship__c testEventRel = new Event_Relationship__c();
        testEventRel.Parent__c = ttsEvent.Id;
        insert testEventRel;

        product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
        testProduct.TTS_Event__c = ttsEvent.Id;
        update testProduct;
    }
    
    @isTest
    static void getPDPConfigurationTest(){
        Map<String,Object> mapParams = new Map<String,Object>();
        String pdpJson = '{"customPDP":"true"}';
        mapParams.put(SIB_SetupConstants.CONFIG_JSON,pdpJson);
        Test.startTest();
        mapParams = SIB_ProductDetailService.getPDPConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getPDPConfigurationTest assertion failed');
	}
    
	@isTest
    static void getPDPConfigurationTestNullCase(){
        Map<String,Object> mapParams = new Map<String,Object>();
        Test.startTest();
        mapParams = SIB_ProductDetailService.getPDPConfiguration(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getPDPConfigurationTestNullCase assertion failed');
	}
    
    @isTest
    static void getProductDetailsTest(){
        Product2 testProd = [SELECT Id FROM Product2 LIMIT 1];
    	Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.RECORD_ID,testProd.Id);
        mapParams.put(SIB_Constants.WEBSTOREID,'000000000000000AAA');
       // mapParams.put(SIB_Constants.RECORD_ID,'000000000000000AAA');
        Test.startTest();
        mapParams = SIB_ProductDetailService.getProductDetails(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getProductDetailsTest assertion failed');
    }
    
    @isTest
    static void getProductDetailsTestNullCase(){
    	Map<String,Object> mapParams = new Map<String,Object>();
        Test.startTest();
        mapParams = SIB_ProductDetailService.getProductDetails(mapParams);
        Test.stopTest();
        system.assertEquals(false,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'getProductDetailsTestNullCase assertion failed');
    }
    
    @isTest
    static void getRelatedProductsCase1(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.PRODUCT_ID,prod.Id);
        dataMap.put(SIB_Constants.WEBSTOREID,'000000000000000AAA');
        dataMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,'000000000000000AAA');
        Test.startTest();
        dataMap = SIB_ProductDetailService.getRelatedProducts(dataMap);
        Test.stopTest();
        system.assertEquals(false,dataMap.get(SIB_SetupConstants.IS_SUCCESS),'getRelatedProductsCase1 assertion failed');
    }
    
    @isTest
    static void getRelatedProductsCase2(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        List<String> prodIds = new List<String>{prod.Id};
        dataMap.put(SIB_Constants.PRODUCT_ID_LIST,prodIds);
        dataMap.put(SIB_Constants.WEBSTOREID,'000000000000000AAA');
        dataMap.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,'000000000000000AAA');
        Test.startTest();
        dataMap = SIB_ProductDetailService.getRelatedProducts(dataMap);
        Test.stopTest();
        system.assertEquals(false,dataMap.get(SIB_SetupConstants.IS_SUCCESS),'getRelatedProductsCase2 assertion failed');
    }

    @isTest
    static void getEventRelationshipChildNamesTest(){
        Product2 testProd = [SELECT Id FROM Product2 WHERE Name =: '74CBTLV1G125DBVRQ1'];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.CURRENCY_CODE,'USD');
        mapParams.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,acc.Id);
        mapParams.put(SIB_Constants.PRODUCT_ID,testProd.Id);
        mapParams.put(SIB_Constants.RECORD_ID,testProd.Id);

        Test.startTest();
        Map<String,Object> mapGetEventRelationshipChildName = SIB_ProductDetailService.getEventRelationshipChildNames(mapParams);
        Map<String,Object> mapGetProductCurrency = SIB_ProductDetailService.getProductCurrency(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_Constants.IS_SUCCESS),'updateBuyerAndAccountCurrencyTest assertion failed');
    }
    
    @isTest
    static void updateBuyerAndAccountCurrencyTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put(SIB_Constants.CURRENCY_CODE,'USD');
        mapParams.put(SIB_Constants.PARAM_EFFECTIVEACCOUNTID,acc.Id);
        Test.startTest();
        mapParams = SIB_ProductDetailService.updateBuyerAndAccountCurrency(mapParams);
        Test.stopTest();
        system.assertEquals(true,mapParams.get(SIB_SetupConstants.IS_SUCCESS),'updateBuyerAndAccountCurrencyTest assertion failed');
    }
}