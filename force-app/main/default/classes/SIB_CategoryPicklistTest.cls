@isTest
public class SIB_CategoryPicklistTest {
    @TestSetup
    static void setup(){
        String storeName = SIB_Util.fetchConfigByValue(SIB_Constants.STOREFRONT_MODULE);
        Webstore webstore = new Webstore(Name = storeName);
        insert webstore;
        
        ProductCatalog productCatalog = new ProductCatalog(Name='Test');
        insert productCatalog;
        
        WebStoreCatalog storeCatalog = new WebStoreCatalog(SalesStoreId=webstore.Id,ProductCatalogId=productCatalog.Id);
        insert storeCatalog;
        
        ProductCategory productCategory = new ProductCategory(Name='Test',CatalogId=productCatalog.Id);
        insert productCategory;
    }
	@isTest
    static void getValuesTest(){
        SIB_CategoryPicklist picklist = new SIB_CategoryPicklist();
        VisualEditor.DynamicPickListRows response = new VisualEditor.DynamicPickListRows();
        Test.startTest();
        response = picklist.getValues();
        Test.stopTest();
        system.assertEquals(1,response.size(),'getValuesTest assertion failed');
    }
    
    @isTest
    static void getDefaultValueTest(){
        SIB_CategoryPicklist picklist = new SIB_CategoryPicklist();
        VisualEditor.DataRow response;
        Test.startTest();
        response = picklist.getDefaultValue();
        Test.stopTest();
        system.assertEquals(null,response,'getValuesTest assertion failed');
    }
}