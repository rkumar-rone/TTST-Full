/**
 * @description       : Test class for SIB_B2BProductSearchServiceTest
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_B2BProductSearchServiceTest {
    private static SIB_ProductSearchRequest productSearchRequest;
    private static ConnectApi.ProductSearchResults mockProductSearchResults;
    private static ConnectApi.SortRulesCollection mockSortRules;
    

    @testSetup
    static void setup() {      

        WebStore testWebStore = SIB_TestDataFactory.createWebStore(false);
        ProductCatalog testProductCatalog = SIB_TestDataFactory.createProductCatalog(false);
        ProductCategory testProductCategory = SIB_TestDataFactory.createProductCategory('AllCategories',testProductCatalog.Id,testWebStore.Id,false);
        
        Date currentDate = Date.today();
    }

    @isTest
    static void testSearchProductsWithCategoryId() {
        WebStore testWebStore = SIB_TestDataFactory.createWebStore(false);

        BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(false);    
        Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,false);
        ProductCatalog testProductCatalog = SIB_TestDataFactory.createProductCatalog(false);
        ProductCategory testProductCategory = SIB_TestDataFactory.createProductCategory('AllCategories',testProductCatalog.Id,null,false);
        productSearchRequest = new SIB_ProductSearchRequest();
        productSearchRequest.categoryId = testProductCategory.Id;
        productSearchRequest.includePrices = true;
        productSearchRequest.page = 1;
        productSearchRequest.pageSize = 10;
        productSearchRequest.sortRuleId = 'sortRule1';
        productSearchRequest.webStoreId = testWebStore.Id;
        productSearchRequest.accountId = testAccount.Id;

        SIB_ProductSearchRequest.RefinementInput testRefinementInput = new SIB_ProductSearchRequest.RefinementInput();
        testRefinementInput.nameOrId = 'Test Refinement';
        testRefinementInput.attributeType =   'ProductAttribute';
        testRefinementInput.values = new List<String>{'Test'};
        productSearchRequest.refinements = new List<SIB_ProductSearchRequest.RefinementInput>{testRefinementInput};


        Test.startTest();

        SIB_B2BProductSearchService service = new SIB_B2BProductSearchService();
        SIB_ProductSearchResponse response = service.searchProducts(productSearchRequest);

        System.assertNotEquals(null, response, 'Response should not be null');
        Test.stopTest();
    }

    @isTest
    static void testTransformSortRulesData() {

        ConnectApi.SortRulesCollection mockSortRules = new ConnectApi.SortRulesCollection();
        mockSortRules.sortRules = new List<ConnectApi.SortRule>();

        ConnectApi.SortRule sortRule1 = new ConnectApi.SortRule();
        sortRule1.label = 'Price: Low to High';
        sortRule1.nameOrId = 'priceLowToHigh';
        sortRule1.sortOrder = 1;
        sortRule1.sortRuleId = 'sortRule1';

        ConnectApi.SortRule sortRule2 = new ConnectApi.SortRule();
        sortRule2.label = 'Price: High to Low';
        sortRule2.nameOrId = 'priceHighToLow';
        sortRule2.sortOrder = 2;
        sortRule2.sortRuleId = 'sortRule2';

        mockSortRules.sortRules.add(sortRule1);
        mockSortRules.sortRules.add(sortRule2);

        SIB_B2BProductSearchService service = new SIB_B2BProductSearchService();
        List<SIB_ProductSearchResponse.SortRule> result = service.transformSortRulesData(mockSortRules);

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testTransformData() {
       Date currentDate = Date.today();
        
       User adminUser = SIB_TestDataFactory.createAdminUser(true);
        
        System.runAs(adminUser) { 
            Test.startTest();
            ProductCatalog testProductCatalog = SIB_TestDataFactory.createProductCatalog(false);
            ProductCategory testProductCategory = SIB_TestDataFactory.createProductCategory('AllCategories',testProductCatalog.Id,null,false);
            ProductCategory testChildCategory = SIB_TestDataFactory.createProductCategory('Test Child Category',testProductCatalog.Id,testProductCategory.Id,false);
            BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
            Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
            Id defauImageId = SIB_TestDataFactory.getMockId(ProductMedia.SObjectType) ;  
            Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
            Pricebook2 testPricebook = SIB_TestDataFactory.createCommercePricebook2('testPricebook',true);
            Campaign ttsEvent = new Campaign();
            ttsEvent.Account__c  = testAccount.Id;
            ttsEvent.Name = 'Testtts Event';
            insert ttsEvent;
            
            Event_Relationship__c testEventRel = new Event_Relationship__c();
            testEventRel.Parent__c = ttsEvent.Id;
            insert testEventRel;
            product2 testProduct =  createProducts.get('74CBTLV1G125DBVRQ1');
            testProduct.TTS_Event__c = ttsEvent.Id;
            update testProduct;

            List<PricebookEntry> createPriceBookEntry = SIB_TestDataFactory.createPricebookEntry((String)testPricebook.Id,new List<product2>{testProduct},true);
            
            ConnectApi.ProductSearchResults mockProductSearchResults = new ConnectApi.ProductSearchResults();
            
            ConnectApi.SearchCategory mockSearchCategory = new ConnectApi.SearchCategory();
            mockSearchCategory.category = new ConnectApi.ProductCategoryData();
            mockSearchCategory.category.id = testProductCategory.Id;
            mockSearchCategory.category.name = 'Electronics';
            mockSearchCategory.category.description = 'Electronics products';
            mockSearchCategory.category.urlName = 'electronics-category';
            mockSearchCategory.productCount = 100;

            ConnectApi.SearchCategory mockChildCategory = new ConnectApi.SearchCategory();
            mockChildCategory.category = new ConnectApi.ProductCategoryData();
            mockChildCategory.category.id = testChildCategory.Id;
            mockChildCategory.category.name = 'Mobile Phones';
            mockChildCategory.category.description = 'Mobile phone products';
            mockChildCategory.category.urlName = 'mobile-phones-category';
            mockChildCategory.productCount = 50;
            mockSearchCategory.children = new List<ConnectApi.SearchCategory>{mockChildCategory};
            mockProductSearchResults.categories = mockSearchCategory;
            
            ConnectApi.ProductSummaryPage mockProductSummaryPage = new ConnectApi.ProductSummaryPage();
            mockProductSummaryPage.pageSize = 10;
            mockProductSummaryPage.total = 1;   
        
            ConnectApi.ProductSummary mockProductSummary = new ConnectApi.ProductSummary();
            mockProductSummary.id = testProduct.Id;
            mockProductSummary.defaultImage = new ConnectApi.ProductMedia();
            mockProductSummary.defaultImage.id = defauImageId;
            mockProductSummary.defaultImage.url = 'http://test.com/image.jpg';
            mockProductSummary.defaultImage.title = 'Product Image';
            mockProductSummary.defaultImage.mediaType = ConnectApi.ProductMediaType.Image;

            mockProductSummary.fields = new Map<String, ConnectApi.FieldValue>{
                'Name' => new ConnectApi.FieldValue(),
                'StockKeepingUnit' => new ConnectApi.FieldValue(),
                'ProductCode' => new ConnectApi.FieldValue(),
                'CurrencyIsoCode' => new ConnectApi.FieldValue(),
                'Product_Group__c' => new ConnectApi.FieldValue(),
                'Early_Bird_Deadline_formula__c' => new ConnectApi.FieldValue(),
                'Full_Registration_Cost_formula__c' => new ConnectApi.FieldValue(),
                'Early_Bird_Registration_Cost_formula__c' => new ConnectApi.FieldValue()

            };

            ConnectApi.PurchaseQuantityRule mockQuantityRule = new ConnectApi.PurchaseQuantityRule();
            mockQuantityRule.increment = '5';
            mockQuantityRule.maximum = '50';
            mockQuantityRule.minimum = '1';
            
            ConnectApi.ProductAttributeSummary mockAttributeSummary = new ConnectApi.ProductAttributeSummary();
            mockAttributeSummary.apiName = 'Color';
            mockAttributeSummary.label = 'Color';
            mockAttributeSummary.sequence = 1;
            mockAttributeSummary.value = 'Red';
            
            ConnectApi.ProductAttributeSetSummary mockVariationAttributeSet = new ConnectApi.ProductAttributeSetSummary();
            mockVariationAttributeSet.apiName = 'Product Variations';
            mockVariationAttributeSet.label = 'Product Variation Set';
            mockVariationAttributeSet.attributes = new List<ConnectApi.ProductAttributeSummary> { mockAttributeSummary };

            ConnectApi.PricingResultLineItem mockPricing = new ConnectApi.PricingResultLineItem();
            mockPricing.pricebookEntryId = createPriceBookEntry[0].Id;
            mockPricing.listPrice = '100';
            mockPricing.unitPrice = '90';
            
            mockProductSummary.purchaseQuantityRule = mockQuantityRule;
            mockProductSummary.variationAttributeSet = mockVariationAttributeSet;
            mockProductSummary.prices = mockPricing;


            
            mockProductSummary.fields.get('Name').value = 'Test Product';
            mockProductSummary.fields.get('StockKeepingUnit').value = 'SKU123';
            mockProductSummary.fields.get('ProductCode').value = 'P123';
            mockProductSummary.fields.get('CurrencyIsoCode').value = 'USD';
            mockProductSummary.fields.get('Product_Group__c').value = SIB_Constants.BUNDLE_NAME;
            mockProductSummary.fields.get('Early_Bird_Deadline_formula__c').value = '2024-10-21T12:00:00Z';
            mockProductSummary.fields.get('Full_Registration_Cost_formula__c').value = '150.00';
            mockProductSummary.fields.get('Early_Bird_Registration_Cost_formula__c').value = '120.00';



            mockProductSummaryPage.products = new List<ConnectApi.ProductSummary>{mockProductSummary};
            mockProductSearchResults.productsPage = mockProductSummaryPage;

            Id pricebookEntryId = SIB_TestDataFactory.getMockId(PricebookEntry.SObjectType);

            ConnectApi.PricingResultLineItem mockPricingResultLineItem = new ConnectApi.PricingResultLineItem();
            mockPricingResultLineItem.pricebookEntryId = pricebookEntryId;
            mockPricingResultLineItem.listPrice = '100';
            mockPricingResultLineItem.unitPrice = '90';
            mockProductSummary.prices = mockPricingResultLineItem;

            ConnectApi.DistinctValueSearchFacet mockFacet = new ConnectApi.DistinctValueSearchFacet();
            mockFacet.attributeType = ConnectApi.CommerceSearchAttributeType.Product2;
            mockFacet.displayName = 'Color';
            mockFacet.displayRank = 1;
            mockFacet.nameOrId = 'color';
            mockFacet.displayType = ConnectApi.CommerceSearchFacetDisplayType.SingleSelect;
            mockFacet.facetType = ConnectApi.CommerceSearchFacetType.DistinctValue;

            ConnectApi.DistinctFacetValue mockFacetValue = new ConnectApi.DistinctFacetValue();
            mockFacetValue.displayName = 'Red';
            mockFacetValue.nameOrId = 'color_red';
            mockFacetValue.productCount = 10;
            mockFacet.values = new List<ConnectApi.DistinctFacetValue>{mockFacetValue};

            mockProductSearchResults.facets = new List<ConnectApi.SearchFacet>{mockFacet};

            SIB_B2BProductSearchService service = new SIB_B2BProductSearchService();
            SIB_ProductSearchResponse response = service.transformData(mockProductSearchResults);
            DateTime earlyBirdDeadline =  DateTime.newInstance(currentDate.addDays(10), Time.newInstance(12, 0, 0, 0));

            String formattedDeadline = earlyBirdDeadline.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            mockProductSummary.fields.get('Early_Bird_Deadline_formula__c').value = formattedDeadline;
            mockPricing.listPrice = '50';
            mockPricing.unitPrice = '100';
            mockProductSummary.prices = mockPricing;
            SIB_ProductSearchResponse response2 = service.transformData(mockProductSearchResults);
        
            Test.stopTest();
            System.assertNotEquals(null, response, 'Response should not be null');  
        }
    }

}