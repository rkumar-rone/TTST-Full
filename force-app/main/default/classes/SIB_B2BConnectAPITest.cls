/**
 * @description       : 
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_B2BConnectAPITest {

    private static String webStoreId = 'testWebStore';
    private static String effectiveAccountId = 'testAccountId';
    private static String productId = 'testProductId';
    private static List<String> fields = new List<String>{'Name', 'Price'};
    private static Boolean excludeFields = false;
    private static List<String> mediaGroups = new List<String>{'Images'};
    private static Boolean excludeMedia = false;
    private static Boolean excludeEntitlementDetails = true;
    private static Boolean excludePrimaryProductCategory = true;

    @isTest
    static void testGetSortRules() {
        Test.startTest();
        ConnectApi.SortRulesCollection result = SIB_B2BConnectAPI.getSortRules(webStoreId);
        Test.stopTest();

        System.assertEquals(null, result, 'Pass');
    }

    @isTest
    static void testSearchProducts() {
        ConnectApi.ProductSearchInput productSearchInput = new ConnectApi.ProductSearchInput();

        Test.startTest();
        ConnectApi.ProductSearchResults result = SIB_B2BConnectAPI.searchProducts(webStoreId, effectiveAccountId, productSearchInput);
        Test.stopTest();

        System.assertEquals(null, result, 'Pass');
    }

    @isTest
    static void testGetProduct() {
        Test.startTest();
        ConnectApi.ProductDetail result = SIB_B2BConnectAPI.getProduct(webStoreId, productId, effectiveAccountId, fields, excludeFields, mediaGroups, excludeMedia, excludeEntitlementDetails, excludePrimaryProductCategory);
        Test.stopTest();

        System.assertEquals(null, result, 'Pass');
    }

    @isTest
    static void testGetProducts() {
        List<String> productIds = new List<String>{'testProduct1', 'testProduct2'};
        List<String> skus = new List<String>{'sku1', 'sku2'};

        Test.startTest();
        ConnectApi.ProductOverviewCollection result = SIB_B2BConnectAPI.getProducts(webStoreId, effectiveAccountId, productIds, skus, fields, excludeMedia, false);
        Test.stopTest();

        System.assertEquals(null, result, 'Pass');
    }

    @isTest
    static void testGetProductPrice() {
        Test.startTest();
        ConnectApi.ProductPrice result = SIB_B2BConnectAPI.getProductPrice(webStoreId, productId, effectiveAccountId);
        Test.stopTest();

        System.assertEquals(null, result, 'Pass');
    }

    @isTest
    static void testGetProductPrices() {
        ConnectApi.PricingInput pricingInput = new ConnectApi.PricingInput();

        Test.startTest();
        ConnectApi.PricingResult result = SIB_B2BConnectAPI.getProductPrices(webStoreId, effectiveAccountId, pricingInput);
        Test.stopTest();

        System.assertEquals(null, result, 'Pass');
    }
}