/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-25-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_B2BProductSearchService implements ISIB_ProductSearchService  {

    public SIB_ProductSearchResponse searchProducts(SIB_ProductSearchRequest productSearchRequest){
        SIB_ProductSearchResponse productSearchResponse = new SIB_ProductSearchResponse();
        ConnectApi.ProductSearchInput productSearchInput = new ConnectApi.ProductSearchInput();
        if(String.isNotBlank(productSearchRequest.categoryId)){
            productSearchInput.categoryId = productSearchRequest.categoryId;
        }else{
            productSearchInput.searchTerm = productSearchRequest.searchTerm;
        }
        productSearchInput.includePrices = productSearchRequest.includePrices ;
        productSearchInput.includeQuantityRule = true ;
        productSearchInput.page = productSearchRequest.page;
        productSearchInput.pageSize = productSearchRequest.pageSize ;
        productSearchInput.sortRuleId = productSearchRequest.sortRuleId ;
        List<String> defaultFields = new List<String>{'Name', 'StockKeepingUnit', 'ProductCode', 'ProductClass', 'Type'};
        Set<String> productFields = productListFields();
        productFields.addAll(defaultFields);
        productSearchInput.fields = new List<String>(productFields);
        List<ConnectApi.RefinementInput> refinements = new List<ConnectApi.RefinementInput>();
        if(productSearchRequest.refinements != null && !productSearchRequest.refinements.isEmpty()){
            for(SIB_ProductSearchRequest.RefinementInput refInput : productSearchRequest.refinements){
                ConnectApi.DistinctValueRefinementInput refinementInput  = new ConnectApi.DistinctValueRefinementInput();
                if(refInput.attributeType == 'ProductAttribute') {
                    refinementInput.attributeType = ConnectApi.CommerceSearchAttributeType.ProductAttribute;
                }else {
                    refinementInput.attributeType = ConnectApi.CommerceSearchAttributeType.Custom;
                }
                refinementInput.nameOrId = refInput.nameOrId ;
                refinementInput.type = ConnectApi.CommerceSearchFacetType.DistinctValue;
                List<String> filterValues = new List<String>();
                for(String val : refInput.values) {
                    filterValues.add(val);
                }
                refinementInput.values = filterValues;
                refinements.add(refinementInput);
            }
        }else {
            //productSearchInput.page = productSearchRequest.page ;
        }
        productSearchInput.refinements = refinements ;
        System.debug('productSearchInput--' + productSearchInput);
        ConnectApi.ProductSearchResults connectProductSearch = SIB_B2BConnectAPI.searchProducts(productSearchRequest.webStoreId, productSearchRequest.accountId, productSearchInput);
        if(connectProductSearch != null) {
            System.debug('connectProductSearchAPI--' + connectProductSearch);
            productSearchResponse = transformData(connectProductSearch);

        }
        ConnectApi.SortRulesCollection connectSortRules = SIB_B2BConnectAPI.getSortRules(productSearchRequest.webStoreId);
        if(connectSortRules != null) {
            productSearchResponse.sortRules = transformSortRulesData(connectSortRules);
        }
        return productSearchResponse;
    }

    public List<SIB_ProductSearchResponse.SortRule> transformSortRulesData(Object data) {
        ConnectApi.SortRulesCollection connectSortRules = (ConnectApi.SortRulesCollection) data; 

        List<SIB_ProductSearchResponse.SortRule> sortRuleList = new List<SIB_ProductSearchResponse.SortRule>();
        for(ConnectApi.SortRule sortRule : connectSortRules.sortRules) {
            SIB_ProductSearchResponse.SortRule rule = new SIB_ProductSearchResponse.SortRule();
            rule.displayName = sortRule.label;
            rule.nameOrId = sortRule.nameOrId;
            rule.sortOrder = sortRule.sortOrder;
            rule.sortRuleId = sortRule.sortRuleId;
            sortRuleList.add(rule);
        }

        return sortRuleList;
    }
    
    public SIB_ProductSearchResponse transformData(Object data){
        ConnectApi.ProductSearchResults connectProductSearch = (ConnectApi.ProductSearchResults) data;
        System.debug('connectProductSearch--' + JSON.serializePretty(connectProductSearch));
        SIB_ProductSearchResponse productSearch  = new SIB_ProductSearchResponse();
        
        SIB_ProductSearchResponse.SearchCategory searchCategory = new SIB_ProductSearchResponse.SearchCategory();
        //check for no products
        ConnectApi.ProductSummaryPage productsPage = connectProductSearch.productsPage;
        productSearch.pageSize = productsPage.pageSize;
        productSearch.total = (Integer)productsPage.total;
        if(productSearch.total != 0) {   
            ConnectApi.SearchCategory searchCategoryConnect = connectProductSearch.categories;
            searchCategory.id = searchCategoryConnect.category.id;
            searchCategory.name = searchCategoryConnect.category.name;
            searchCategory.productCount = (Integer)searchCategoryConnect.productCount;
            searchCategory.description = searchCategoryConnect.category.description;
            searchCategory.urlSlug = searchCategoryConnect.category.urlName;
            List<ConnectApi.SearchCategory> connectedChildren = searchCategoryConnect.children;
            if(connectedChildren != null && connectedChildren.size() > 0) {
                List<SIB_ProductSearchResponse.SearchCategory> childCategories = new List<SIB_ProductSearchResponse.SearchCategory>();
                for(ConnectApi.SearchCategory child : connectedChildren) {
                    SIB_ProductSearchResponse.SearchCategory childCategory = new SIB_ProductSearchResponse.SearchCategory();
                    childCategory.id = child.category.id;
                    childCategory.name = child.category.name;
                    childCategory.productCount = (Integer)child.productCount;
                    childCategory.description = child.category.description;
                    childCategory.urlSlug = child.category.urlName;
                    childCategories.add(childCategory);
                }
                searchCategory.children = childCategories;
            }
            productSearch.searchCategory = searchCategory;

            List<SIB_ProductSearchResponse.SearchFilter> filters = new List<SIB_ProductSearchResponse.SearchFilter>();
            List<ConnectApi.SearchFacet> facets = connectProductSearch.facets;
            for(ConnectApi.SearchFacet facet : facets) {
                ConnectApi.DistinctValueSearchFacet distinctValueFacet = (ConnectApi.DistinctValueSearchFacet)facet;
                SIB_ProductSearchResponse.SearchFilter filter = new SIB_ProductSearchResponse.SearchFilter();
                filter.attributeType = String.valueOf(facet.attributeType);
                filter.displayName = facet.displayName;
                filter.displayRank = facet.displayRank;
                filter.nameOrId = facet.nameOrId;
                filter.displayType = String.valueOf(facet.displayType);
                filter.facetType = String.valueOf(facet.facetType);
                List<ConnectApi.DistinctFacetValue> connectedValues = distinctValueFacet.values;
                List<SIB_ProductSearchResponse.FilterValue> values = new List<SIB_ProductSearchResponse.FilterValue>();
                for(ConnectApi.DistinctFacetValue val : connectedValues) {
                    SIB_ProductSearchResponse.FilterValue filterValue = new SIB_ProductSearchResponse.FilterValue();
                    filterValue.displayName = val.displayName;
                    filterValue.nameOrId = val.nameOrId;
                    filterValue.productCount = (Integer)val.productCount;
                    filterValue.type = String.valueOf(val.type);
                    filterValue.checked = false;
                    values.add(filterValue);
                }
                filter.values = values;
                filters.add(filter);
            }
            productSearch.filters = filters;

            productSearch.locale = connectProductSearch.locale;

            List<SIB_ProductDetail> products = new List<SIB_ProductDetail>();

            //Store Product Ids
            List<Id> productIds = new List<Id>();

            //productFieldList contains all lowercase strings
            List<String> productFieldList = SIB_Util.getAllObjectFields(SIB_Constants.PRODUCT_API_NAME).split(', ');

            List<ConnectApi.ProductSummary> connectedProducts = productsPage.products;
            for(ConnectApi.ProductSummary prod : connectedProducts) {
                SIB_ProductDetail productDetail = new SIB_ProductDetail();
                
                ConnectApi.ProductMedia defaultMedia = prod.defaultImage;
                SIB_ProductDetail.SIB_ProductMedia defaultImage = new SIB_ProductDetail.SIB_ProductMedia(defaultMedia.id, defaultMedia.title, String.valueOf(defaultMedia.mediaType) , defaultMedia.alternateText,defaultMedia.url);

                Map<String, ConnectApi.FieldValue> fieldsMapTemp = prod.fields;
                Map<String, String> fieldsMap = new Map<String, String>();
                for(String key : fieldsMapTemp.keySet()) {
                    fieldsMap.put(key, (fieldsMapTemp.get(key)).value);
                }

                productDetail.productId = prod.id;
                productDetail.name = productFieldList.contains('name') && fieldsMap.containsKey('Name') && fieldsMap.get('Name') != null ? fieldsMap.get('Name') : null;
                productDetail.productSku = productFieldList.contains('stockkeepingunit') && fieldsMap.containsKey('StockKeepingUnit') && fieldsMap.get('StockKeepingUnit') != null ? fieldsMap.get('StockKeepingUnit') : null;
                productDetail.productCode = productFieldList.contains('productcode') && fieldsMap.containsKey('ProductCode') && fieldsMap.get('ProductCode') != null ? fieldsMap.get('ProductCode') : null;
                productDetail.productClass = productFieldList.contains('productclass') && fieldsMap.containsKey('ProductClass') && fieldsMap.get('ProductClass') != null ? fieldsMap.get('ProductClass') : null;
                productDetail.productType = productFieldList.contains('type') && fieldsMap.containsKey('Type') && fieldsMap.get('Type') != null ? fieldsMap.get('Type') : null;
                productDetail.productGroup = productFieldList.contains('product_group__c') && fieldsMap.containsKey('Product_Group__c') && fieldsMap.get('Product_Group__c') != null ? fieldsMap.get('Product_Group__c') : null;
                productDetail.isCourse = productFieldList.contains('sib_is_course__c') && fieldsMap.containsKey('SIB_Is_Course__c') && fieldsMap.get('SIB_Is_Course__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Is_Course__c')) : false;
                productDetail.isMostPopular = productFieldList.contains('sib_most_popular__c') && fieldsMap.containsKey('SIB_Most_Popular__c') && fieldsMap.get('SIB_Most_Popular__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Most_Popular__c')) : false;
                productDetail.isNewCourse = productFieldList.contains('new_course__c') && fieldsMap.containsKey('New_Course__c') && fieldsMap.get('New_Course__c') != null ? Boolean.valueOf(fieldsMap.get('New_Course__c')) : false;
                productDetail.productCurrency = productFieldList.contains('currencyisocode') && fieldsMap.containsKey('CurrencyIsoCode') && fieldsMap.get('CurrencyIsoCode') != null ? fieldsMap.get('CurrencyIsoCode') : null;
                productDetail.productSlugURL = productFieldList.contains('sib_slugurl__c') && fieldsMap.containsKey('SIB_SlugUrl__c') && fieldsMap.get('SIB_SlugUrl__c') != null ? fieldsMap.get('SIB_SlugUrl__c') : null;
                productDetail.defaultImage = defaultImage;
                productDetail.fieldsMap = fieldsMap ;
                productDetail.isSuccess = true ;

                if(productDetail.productGroup == SIB_Constants.BUNDLE_NAME || productDetail.productGroup == SIB_Constants.SELF_STUDY_NAME) {
                    productIds.add(productDetail.productId);
                }

                if(prod.purchaseQuantityRule != null){
                    Integer increment = String.isNotBlank(prod.purchaseQuantityRule.increment) ? Integer.valueOf(prod.purchaseQuantityRule.increment) : null ;
                    Integer maximum = String.isNotBlank(prod.purchaseQuantityRule.maximum) ? Integer.valueOf(prod.purchaseQuantityRule.maximum) : null ;
                    Integer minimum = String.isNotBlank(prod.purchaseQuantityRule.minimum) ? Integer.valueOf(prod.purchaseQuantityRule.minimum) : null ;
                    productDetail.quantityRule = new SIB_ProductDetail.QuantityRule(increment, maximum,minimum) ;
                }

                if(prod.variationAttributeSet != null){
                    List<ConnectApi.ProductAttributeSummary> prodAttrSummary = prod.variationAttributeSet.attributes;
                    List<SIB_ProductDetail.SIB_AttributesSummary> attributes = new List<SIB_ProductDetail.SIB_AttributesSummary>();

                    for(ConnectApi.ProductAttributeSummary attribute : prodAttrSummary){
                        SIB_ProductDetail.SIB_AttributesSummary attr = new SIB_ProductDetail.SIB_AttributesSummary(attribute.apiName, attribute.label, attribute.sequence, attribute.value);
                        attributes.add(attr);
                    }
                    productDetail.variationAttributeSet = new SIB_ProductDetail.SIB_VariationAttributeSetSummary(prod.variationAttributeSet.apiName, attributes, prod.variationAttributeSet.label);
                }

                ConnectApi.PricingResultLineItem connectedPrice = prod.prices;
                SIB_ProductPricing pricing = new SIB_ProductPricing();
                pricing.currencyCode = productDetail.productCurrency;
                pricing.pricebookEntryId = connectedPrice.pricebookEntryId;

                //Get List Price and Unit Price of a Product
                pricing = getProductPrice(productFieldList, fieldsMap, productDetail, pricing, connectedPrice);
                
                pricing.negotiatedPrice =  pricing.unitPrice;
                if(pricing.listPrice > pricing.negotiatedPrice){
                    pricing.negotiatedPriceDiscount = (pricing.listPrice - pricing.negotiatedPrice).setScale(2);
                    pricing.negotiatedPriceDiscountPercent = (((pricing.negotiatedPriceDiscount*100)/pricing.listPrice)).setScale(2)+'%';
                }else{
                    pricing.negotiatedPriceDiscount = 0 ;
                    pricing.negotiatedPriceDiscountPercent = '';
                }
                
                productDetail.price = pricing;

                products.add(productDetail);
            }
            //Get Product bullet point description for Self Study and Bundle Products
            if(productIds != null) {
                productSearch.products = getEventRelationshipChildNames(products, productIds);
            }else {
                productSearch.products = products;
            }
            
            productSearch.isSuccess = true;
        }else {
            productSearch.isSuccess = false;
        }
        return productSearch;
    }

    public static Set<String> productListFields() {
        Set<String> fieldNames = new Set<String>();
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('configurationType', 'PLP');
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams != null && mapParams.containsKey('configJSON') && mapParams.get('configJSON') != null) {
            SIB_PLPConfiguration plpConfig = SIB_PLPConfiguration.parse((String)mapParams.get('configJSON'));
            if(plpConfig.cardContentMapping != null) {
                for(SIB_PLPConfiguration.CardContentMapping prodField : plpConfig.cardContentMapping) {
                    fieldNames.add(prodField.name);
                }
            }
        }
        return fieldNames;
    }

    /**
     * @description method to get List Price and Unit Price of a Product
     * @author Anand
     * @created 17 Sep 24
     */
    public static SIB_ProductPricing getProductPrice(List<String> productFieldList, Map<String, String> fieldsMap, SIB_ProductDetail productDetail, SIB_ProductPricing pricing, ConnectApi.PricingResultLineItem connectedPrice) {
        DateTime earlyBirdDeadline;
        Decimal fullRegistrationCost = 0;
        Decimal earlyBirdRegistrationCost = 0;
        if (productFieldList.contains('early_bird_deadline_formula__c') && fieldsMap.containsKey('Early_Bird_Deadline_formula__c') && fieldsMap.get('Early_Bird_Deadline_formula__c') != null) {
            earlyBirdDeadline = DateTime.valueOf(fieldsMap.get('Early_Bird_Deadline_formula__c').replace('T', ' ').replace('Z', ''));
        }

        if (productFieldList.contains('full_registration_cost_formula__c') && fieldsMap.containsKey('Full_Registration_Cost_formula__c') && fieldsMap.get('Full_Registration_Cost_formula__c') != null) {
            fullRegistrationCost = Decimal.valueOf(fieldsMap.get('Full_Registration_Cost_formula__c'));
        }

        if (productFieldList.contains('early_bird_registration_cost_formula__c') && fieldsMap.containsKey('Early_Bird_Registration_Cost_formula__c') && fieldsMap.get('Early_Bird_Registration_Cost_formula__c') != null) {
            earlyBirdRegistrationCost = Decimal.valueOf(fieldsMap.get('Early_Bird_Registration_Cost_formula__c'));
        }
        
        if(earlyBirdDeadline == null || earlyBirdDeadline < Datetime.now()) {
            pricing.priceLabel = SIB_Constants.REGISTRATION_COST;
            pricing.fullRegistrationCost = fullRegistrationCost;
            pricing.unitPrice = fullRegistrationCost;
            pricing.listPrice = fullRegistrationCost;
        }else {
            pricing.priceLabel = SIB_Constants.EARLY_BIRD_PRICE;
            pricing.earlyBirdRegistrationCost = earlyBirdRegistrationCost;
            pricing.unitPrice = earlyBirdRegistrationCost;
            pricing.listPrice = earlyBirdRegistrationCost;
        }

        if(pricing.pricebookEntryId != null) {
            if(productDetail.productGroup == SIB_Constants.BUNDLE_NAME || productDetail.productGroup == SIB_Constants.SELF_STUDY_NAME) {
                pricing.unitPrice = Decimal.valueOf(connectedPrice.unitPrice);
                if(connectedPrice.listPrice != null) {
                    pricing.listPrice = Decimal.valueOf(connectedPrice.listPrice);
                }else {
                    pricing.listPrice = pricing.unitPrice;
                }
            }
            pricing.isSuccess = true;
        }else {
            pricing.isSuccess = false;
        }

        return pricing;
    }

    /**
     * @description method to get Event Relationship Child Names from TTS Events of a Product.
     * @author Anand
     * @created 09 Oct 24
     */
    public static List<SIB_ProductDetail> getEventRelationshipChildNames(List<SIB_ProductDetail> productDetails, List<Id> productIds) {
        Map<String, List<String>> eventIdToNamesMap = new Map<String, List<String>>();
        Map<String, String> productIdToEventIdMap = new Map<String, String>();
        List<Product2> products = new List<Product2>();

        // Query self-study or bundle Products
        if(productIds != null) {
            products = (List<Product2>)SIB_ProductSelector.getProductByIds(productIds);
        }

        if(products != null) {
            for(Product2 prod : products) {
                if(prod.TTS_Event__c != null) {
                    productIdToEventIdMap.put(prod.Id, prod.TTS_Event__c);
                }
            }
        }
        
        // Query all child relationships for the given event ids
        List<Sobject> eventRelationshipRecords = SIB_EventRelationshipSelector.getEventRelationshipsByEventIds(productIdToEventIdMap.values());
        List<Event_Relationship__c> eventRelationshipChildRecords = new List<Event_Relationship__c>();
        if(eventRelationshipRecords != null && eventRelationshipRecords.size() > 0) {
            eventRelationshipChildRecords = (List<Event_Relationship__c>)eventRelationshipRecords;
        }

        // Build the eventIdToNamesMap
        if(eventRelationshipChildRecords != null) {
            for(Event_Relationship__c eventChild : eventRelationshipChildRecords) {
                // Get the list of child names for this Parent__c from the map
                List<String> childNames = eventIdToNamesMap.get(eventChild.Parent__c);
    
                // If there is no list yet for this Parent__c, create a new list and add it to the map
                if (childNames == null) {
                    childNames = new List<String>();
                    eventIdToNamesMap.put(eventChild.Parent__c, childNames);
                }
    
                // Add the current child name to the list
                childNames.add(eventChild.Child__r.Name);
            }
        }

        // Update productDetails with the corresponding child names
        for(SIB_ProductDetail productDetail : productDetails) {
            if(productIdToEventIdMap != null && productIdToEventIdMap.keySet().contains(productDetail.productId)) {
                String eventId = productIdToEventIdMap.get(productDetail.productId);
                productDetail.bundleEventChildNames = eventIdToNamesMap.containsKey(eventId) && eventIdToNamesMap.get(eventId) != null ? eventIdToNamesMap.get(eventId) : null;
            }
        }

        return productDetails;
    }
}