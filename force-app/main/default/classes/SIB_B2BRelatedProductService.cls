/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_B2BRelatedProductService implements ISIB_RelatedProductService {

    public static  Map<Id, SIB_ProductDetail> productInfoMap  = null;

    public Map<String, List<SIB_RelatedProduct>> getRelatedProducts(SIB_ProductRequest productRequest) { 

        Map<String, List<SIB_RelatedProduct>> relatedProductWrapperMap = new Map<String, List<SIB_RelatedProduct>>();
        List<Id> relatedProductIds = new List<Id>();
    
        List<B2B_Recommendation__c> relatedProducts = SIB_RelatedProductsSelector.getRelatedProductsSelectorByIds(productRequest.productIds);
        for (B2B_Recommendation__c record : relatedProducts) {
            relatedProductIds.add(record.Recommended_Product__c);
        }
    
        if (relatedProductIds != null && !relatedProductIds.isEmpty()) {
            productRequest.relatedProductIds = relatedProductIds;
    
            productInfoMap = getProductDetail(productRequest);
            if (productRequest.showPricing != null && productRequest.showPricing) {
                Map<Id, SIB_ProductPricing> productPricingMap = getProductPricing(productRequest);
                for (Id proId : productInfoMap.keySet()) {
                    SIB_ProductDetail productDetail = productInfoMap.get(proId);
                    productDetail.price = productPricingMap.get(proId);
                    productInfoMap.put(proId, productDetail);
                }
            }
    
            // Use a Set to avoid duplicates
            Set<Id> addedProductIds = new Set<Id>();
    
            for (B2B_Recommendation__c record : relatedProducts) {
                String attachedProductKey = record.Attached_Product__c;
    
                // Initialize the list if it doesn't exist
                if (!relatedProductWrapperMap.containsKey(attachedProductKey)) {
                    relatedProductWrapperMap.put(attachedProductKey, new List<SIB_RelatedProduct>());
                }
    
                // Create a new wrapper
                SIB_RelatedProduct wrapper = new SIB_RelatedProduct();
                wrapper.name = record.name; 
                wrapper.active = Boolean.valueOf(record.Active__c); 
                wrapper.order = record.Order__c; 
                wrapper.type = record.Type__c; 
                wrapper.productId = attachedProductKey;
                wrapper.recommendedProducts = new List<SIB_ProductDetail>();
    
                // Get the recommended product detail
                SIB_ProductDetail recommendedProductDetail = productInfoMap.get(record.Recommended_Product__c);
                if (recommendedProductDetail != null) {
                    wrapper.recommendedProducts.add(recommendedProductDetail);
                }
    
                // Add the wrapper to the list in the map
                relatedProductWrapperMap.get(attachedProductKey).add(wrapper);
            }
        }
        return relatedProductWrapperMap;
    }
    
    public Map<Id, SIB_ProductDetail> getProductDetail(SIB_ProductRequest productRequest) { 
        Map<Id, SIB_ProductDetail> productDetailMap = new Map<Id, SIB_ProductDetail>();
        List<String> fields = new List<String>();
        ConnectApi.ProductOverviewCollection productOverviewCollection = null;
        if(!Test.isRunningTest()){
            productOverviewCollection = SIB_B2BConnectAPI.getProducts(productRequest.webStoreId, productRequest.accountId, productRequest.relatedProductIds, null, fields, false, false);
        }else{
            productOverviewCollection = SIB_TestDataFactory.createMockProductOverviewCollection(productRequest.productIds);
        }
        if(productOverviewCollection != null && productOverviewCollection.products != null && !productOverviewCollection.products.isEmpty()) {
            for(ConnectApi.ProductOverview product : productOverviewCollection.products) {

                Map<String, String> fieldsMap = product.fields;
                ConnectApi.ProductMedia defaultMedia = product.defaultImage;
                SIB_ProductDetail.SIB_ProductMedia defaultImage = new SIB_ProductDetail.SIB_ProductMedia(defaultMedia.id, defaultMedia.title, String.valueOf(defaultMedia.mediaType), defaultMedia.alternateText, defaultMedia.url);

                List<String> productFieldList = SIB_Util.getAllObjectFields(SIB_Constants.PRODUCT_API_NAME).split(', ');

                SIB_ProductDetail productDetail  = new SIB_ProductDetail();
                productDetail.productId = product.id;
                productDetail.name = fieldsMap.get('Name');
                productDetail.productSku = fieldsMap.get('StockKeepingUnit');
                productDetail.productCode = fieldsMap.get('ProductCode');
                productDetail.productClass = fieldsMap.get('ProductClass');
                productDetail.productType = fieldsMap.get('Type');
                productDetail.defaultImage = defaultImage;
                productDetail.description = fieldsMap.get('Description');
                productDetail.longDescription = fieldsMap.get('SIB_Whats_Included__c');
                productDetail.isCourse = productFieldList.contains('sib_is_course__c') && fieldsMap.containsKey('SIB_Is_Course__c') && fieldsMap.get('SIB_Is_Course__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Is_Course__c')) : false;
                productDetail.isMostPopular = productFieldList.contains('sib_most_popular__c') && fieldsMap.containsKey('SIB_Most_Popular__c') && fieldsMap.get('SIB_Most_Popular__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Most_Popular__c')) : false;
                productDetail.isNewCourse = productFieldList.contains('new_course__c') && fieldsMap.containsKey('New_Course__c') && fieldsMap.get('New_Course__c') != null ? Boolean.valueOf(fieldsMap.get('New_Course__c')) : false;
                productDetail.productGroup = productFieldList.contains('product_group__c') && fieldsMap.containsKey('Product_Group__c') && fieldsMap.get('Product_Group__c') != null ? fieldsMap.get('Product_Group__c') : null;
                productDetail.isCourse = productFieldList.contains('sib_is_course__c') && fieldsMap.containsKey('SIB_Is_Course__c') && fieldsMap.get('SIB_Is_Course__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Is_Course__c')) : false;
                productDetail.fieldsMap = fieldsMap;
                productDetail.isSuccess = product.success ;
                productDetail.message = '';
                productDetailMap.put(product.id, productDetail);
            }
        }
        return productDetailMap;
    }

    public Map<Id, SIB_ProductPricing> getProductPricing(SIB_ProductRequest productRequest) { 
        DateTime earlyBirdDeadline;
        Decimal fullRegistrationCost;
        Decimal earlyBirdRegistrationCost;

        Map<Id, SIB_ProductPricing> productPricingMap = new Map<Id, SIB_ProductPricing>();

        List<ConnectApi.PricingLineItemInput> pricingLineItemInput = new List<ConnectApi.PricingLineItemInput>();
        for(Id proId : productRequest.relatedProductIds) {
            ConnectApi.PricingLineItemInput input = new ConnectApi.PricingLineItemInput();
            input.productId = proId;
            pricingLineItemInput.add(input);
        }
        ConnectApi.PricingInput pricingInput = new ConnectApi.PricingInput();
        pricingInput.pricingLineItems = pricingLineItemInput;
        
        ConnectApi.PricingResult pricingResult = null;
        if(!Test.isRunningTest()){
            pricingResult = SIB_B2BConnectAPI.getProductPrices(productRequest.webStoreId, productRequest.accountId, pricingInput);
        }else{
            pricingResult = SIB_TestDataFactory.testPricingResultMockData(productRequest.productIds);
        }

        if(pricingResult != null && pricingResult.success && pricingResult.pricingLineItemResults != null && !pricingResult.pricingLineItemResults.isEmpty()) {
            for(ConnectApi.PricingResultLineItem lineItemPrice : pricingResult.pricingLineItemResults) {

                SIB_ProductPricing productPrice  = new SIB_ProductPricing();
                productPrice.currencyCode = pricingResult.currencyIsoCode;
                productPrice.pricebookEntryId = lineItemPrice.pricebookEntryId;
                productPrice.productId = lineItemPrice.productId;
                
               
                SIB_ProductDetail prodDetail = productInfoMap.get(lineItemPrice.productId);
                Map<String, String> fieldsMap = prodDetail.fieldsMap;
                List<String> productFieldList = SIB_Util.getAllObjectFields(SIB_Constants.PRODUCT_API_NAME).split(', ');
                if(fieldsMap.containsKey('Product_Group__c') && ((fieldsMap.get('Product_Group__c') == 'Private Course') || (fieldsMap.get('Product_Group__c') == 'Public Course')) ) {
                    productPrice.listPrice = lineItemPrice.listPrice != null ? Decimal.valueOf( lineItemPrice.listPrice) : Decimal.valueOf(lineItemPrice.unitPrice);
                    if(productFieldList != null && !productFieldList.isEmpty()) {
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
                            productPrice.priceLabel = SIB_Constants.REGISTRATION_COST;
                            productPrice.fullRegistrationCost = fullRegistrationCost;
                            productPrice.unitPrice = fullRegistrationCost;
                            productPrice.listPrice = fullRegistrationCost;
                        }else {
                            productPrice.priceLabel = SIB_Constants.EARLY_BIRD_PRICE;
                            productPrice.earlyBirdRegistrationCost = earlyBirdRegistrationCost;
                            productPrice.unitPrice = earlyBirdRegistrationCost;
                            productPrice.listPrice = earlyBirdRegistrationCost;
                        }
                    }
                }
                else{
                    productPrice.unitPrice = Decimal.valueOf(lineItemPrice.unitPrice);
                    productPrice.listPrice = lineItemPrice.listPrice != null ? Decimal.valueOf( lineItemPrice.listPrice) : Decimal.valueOf(lineItemPrice.unitPrice);
                }
                productPrice.negotiatedPrice =  Decimal.valueOf(lineItemPrice.unitPrice);
                if(productPrice.listPrice > productPrice.negotiatedPrice){
                    productPrice.negotiatedPriceDiscount = (productPrice.listPrice - productPrice.negotiatedPrice).setScale(2);
                    productPrice.negotiatedPriceDiscountPercent = (((productPrice.negotiatedPriceDiscount*100)/productPrice.listPrice)).setScale(2)+'%';
                }else{
                    productPrice.negotiatedPriceDiscount = 0 ;
                    productPrice.negotiatedPriceDiscountPercent = '';
                }
                
                productPrice.isSuccess = lineItemPrice.success;
                productPricingMap.put(lineItemPrice.productId, productPrice);
            }
        }
        return productPricingMap;
    }

}