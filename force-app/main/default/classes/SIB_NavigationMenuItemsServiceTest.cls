/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_NavigationMenuItemsServiceTest {
   @isTest
   static void testUpdateSelectedAddAsDefault(){
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        System.runAs(adminUser){
            BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
            Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
            ContactPointAddress testCPA =  SIB_TestDataFactory.createShippingCPA(testAccount,true);
            Test.startTest();
            Map<Object,Object> addMap = new Map<Object,Object>();
            addMap.put('Id',testCPA.Id);
            Map<String,Object> mapParams = new Map<String,Object>();
            mapParams.put('addData',addMap);
            Map<String,Object> result = SIB_NavigationMenuItemsService.updateSelectedAddAsDefault(mapParams);
            System.assertEquals(true, result.get('isSuccess'),'Passed');            
            Test.stopTest();
        }
   }

    @IsTest
    static void testGetNavigationMenuItem(){
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        System.runAs(adminUser){
            SIB_MegaMenuConfiguration.Record record1 = new SIB_MegaMenuConfiguration.Record();
            record1.URL = 'https://example.com/record1';
            record1.Label = 'Record 1';

            SIB_MegaMenuConfiguration.Record record2 = new SIB_MegaMenuConfiguration.Record();
            record2.URL = 'https://example.com/record2';
            record2.Label = 'Record 2';

            SIB_MegaMenuConfiguration.SubCategory subCategory1 = new SIB_MegaMenuConfiguration.SubCategory();
            subCategory1.SubCategoryName = 'SubCategory 1';
            subCategory1.records = new List<SIB_MegaMenuConfiguration.Record>{ record1, record2 };

            SIB_MegaMenuConfiguration.SubCategory subCategory2 = new SIB_MegaMenuConfiguration.SubCategory();
            subCategory2.SubCategoryName = 'SubCategory 2';
            subCategory2.records = new List<SIB_MegaMenuConfiguration.Record>{ record1 };

            SIB_MegaMenuConfiguration.Category category1 = new SIB_MegaMenuConfiguration.Category();
            category1.type = 'CategoryType1';
            category1.value = 'CategoryValue1';
            category1.URL = 'https://example.com/category1';
            category1.subCategories = new List<SIB_MegaMenuConfiguration.SubCategory>{ subCategory1, subCategory2 };

            SIB_MegaMenuConfiguration.Category category2 = new SIB_MegaMenuConfiguration.Category();
            category2.type = 'CategoryType2';
            category2.value = 'CategoryValue2';
            category2.URL = 'https://example.com/category2';
            category2.subCategories = new List<SIB_MegaMenuConfiguration.SubCategory>(); // No subcategories

            SIB_MegaMenuConfiguration megaMenuConfig = new SIB_MegaMenuConfiguration();
            megaMenuConfig.Category = new List<SIB_MegaMenuConfiguration.Category>{ category1, category2 };

            // Serialize the object to JSON
            String jsonSerialized = JSON.serialize(megaMenuConfig);
            System.debug('Serialized JSON: ' + jsonSerialized);
            SIB_StorefrontConfiguration__c testConfig =  SIB_TestDataFactory.createStorefrontConfiguration(SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU,jsonSerialized);
            Map<String,Object> mapParams = new Map<String,Object>();
            Test.startTest();
            Map<String,Object> result = SIB_NavigationMenuItemsService.getMegMenuConfiguration(mapParams);
            System.assertEquals(true, result.get('isSuccess'),'Passed');            
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetNavigationMenuItemException(){
        Map<String,Object> mapParams = new Map<String,Object>();
        Test.startTest();
        Map<String,Object> result = SIB_NavigationMenuItemsService.getMegMenuConfiguration(mapParams);
        System.assertEquals(false, result.get('isSuccess'),'Passed');            
        Test.stopTest();
    }

    @isTest
    static void testUpdateSelectedAddAsDefaultException(){
      
        Test.startTest();
        Map<Object,Object> addMap = new Map<Object,Object>();
        
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('addData',addMap);
        Map<String,Object> result = SIB_NavigationMenuItemsService.updateSelectedAddAsDefault(mapParams);
        System.assertEquals(false, result.get('isSuccess'),'Passed');            
        Test.stopTest();          
        
    }
}