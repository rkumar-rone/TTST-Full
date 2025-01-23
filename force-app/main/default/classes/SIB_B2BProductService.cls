/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_B2BProductService implements ISIB_ProductService {

    public SIB_ProductDetail getProductDetail(SIB_ProductRequest productRequest){
        
        SIB_ProductDetail productDetail  = new SIB_ProductDetail();
        
        List<String> fields = new List<String>();
        List<String> mediaGroups = new List<String>();
        ConnectApi.ProductDetail connectProductDetail = null;
        if(!Test.isRunningTest()){
            connectProductDetail = SIB_B2BConnectAPI.getProduct(productRequest.webStoreId, productRequest.productId, productRequest.accountId, fields, false, mediaGroups, false, false, false);
        }else{
            connectProductDetail=SIB_TestDataFactory.createMockProductSearchData(productRequest.productId);
        }
        if(connectProductDetail != null) {
            productDetail = transformData(connectProductDetail);
            if(productDetail != null) {
                if(productRequest.showPricing != null && productRequest.showPricing && productDetail.productClass != 'VariationParent') {
                    SIB_ProductPricing pricingDetails = getPricingDetails(productRequest, connectProductDetail.fields);
    
                    if(pricingDetails.negotiatedPrice == null || productDetail.productCurrency == 'GBP') {
                        PricebookEntry gbpPrice = (PricebookEntry)JSON.deserialize(
                            B2BGetInfo.getGbpProductPrice(productDetail.productId),
                            PricebookEntry.class
                        );

                        if(gbpPrice != null) {
                            pricingDetails.negotiatedPrice = gbpPrice.UnitPrice;
                            pricingDetails.currencyCode = gbpPrice.CurrencyIsoCode;
                        }
                    }
                    productDetail.price = pricingDetails;
                }
    
                if(productRequest.showInventory != null && productRequest.showInventory){
                    ISIB_InventoryService inventoryService = SIB_DependencyService.getInstance().getInventoryService() ;
                    productDetail.inventory = null;
                }
    
                List<Session__c> eventSessions = SIB_GetInfo.getSessions(productRequest.productId);
                if(eventSessions != null && !eventSessions.isEmpty()){
                    productDetail.eventSessions = eventSessions;
                    //for calculating per early bird session price
                    if(productDetail.price != null && productDetail.price.earlyBirdRegistrationCost != null) {
                        productDetail.price.earlyBirdSessionPrice = productDetail.price.earlyBirdRegistrationCost / eventSessions.size();
                    }   
                }
    
                productDetail.sessionFlag = B2BGetInfo.getOnlyOneSession(productDetail.productId);
                productDetail.productCount = getCourseCount(productDetail);
                productDetail.totalDays = getTotalDays(productDetail);
            }
        }
        return productDetail;
    }

    public SIB_ProductDetail transformData(Object data){
        SIB_ProductDetail productDetail  = new SIB_ProductDetail();
        ConnectApi.ProductDetail connectProductDetail = (ConnectApi.ProductDetail)data;
        Map<String, String> fieldsMap = connectProductDetail.fields;
        ConnectApi.ProductMedia defaultMedia = connectProductDetail.defaultImage;
        SIB_ProductDetail.SIB_ProductMedia defaultImage = new SIB_ProductDetail.SIB_ProductMedia(defaultMedia.id, defaultMedia.title, String.valueOf(defaultMedia.mediaType) , defaultMedia.alternateText,defaultMedia.url);
        List<SIB_ProductDetail.SIB_ProductMedia> imgList = new List<SIB_ProductDetail.SIB_ProductMedia>();
        List<SIB_ProductDetail.SIB_ProductMedia> attachments = new List<SIB_ProductDetail.SIB_ProductMedia>();
        List<SIB_ProductDetail.SIB_ProductMedia> videos = new List<SIB_ProductDetail.SIB_ProductMedia>();
        for(ConnectApi.ProductMediaGroup mediaGroup : connectProductDetail.mediaGroups) {
            for(ConnectApi.ProductMedia media : mediaGroup.mediaItems) {
                SIB_ProductDetail.SIB_ProductMedia prodMedia = new SIB_ProductDetail.SIB_ProductMedia(media.id, media.title, String.valueOf(media.mediaType) , media.alternateText,media.url);
                if(prodMedia.type == SIB_Constants.IMAGE){
                    imgList.add(prodMedia);
                }else if(prodMedia.type == SIB_Constants.DOCUMENT){
                    attachments.add(prodMedia);
                }else if(prodMedia.type == SIB_Constants.VIDEO){
                    videos.add(prodMedia);
                }
            }
        }
        if(connectProductDetail.purchaseQuantityRule != null){
            Integer increment = String.isNotBlank(connectProductDetail.purchaseQuantityRule.increment) ? Integer.valueOf(connectProductDetail.purchaseQuantityRule.increment) : null ;
            Integer maximum = String.isNotBlank(connectProductDetail.purchaseQuantityRule.maximum) ? Integer.valueOf(connectProductDetail.purchaseQuantityRule.maximum) : null ;
            Integer minimum = String.isNotBlank(connectProductDetail.purchaseQuantityRule.minimum) ? Integer.valueOf(connectProductDetail.purchaseQuantityRule.minimum) : null ;
            productDetail.quantityRule = new SIB_ProductDetail.QuantityRule(increment, maximum,minimum) ;
        }

        //Variation Attributes

        //variationAttributeSet
        SIB_ProductDetail.SIB_ProductAttributeSet attributeSet;
        if(connectProductDetail.variationAttributeSet != null){
            ConnectApi.ProductAttributeSet attrSet = (ConnectApi.ProductAttributeSet)connectProductDetail.variationAttributeSet;
            attributeSet = new SIB_ProductDetail.SIB_ProductAttributeSet(attrSet.developerName, attrSet.attributes, attrSet.id);
        }

        //variationInfo
        List<SIB_ProductDetail.SIB_ProductAttributesToProductEntry> productMappings = new List<SIB_ProductDetail.SIB_ProductAttributesToProductEntry>();
        Map<String,SIB_ProductDetail.SIB_ProductAttributeInfo> attributeInfo = new Map<String,SIB_ProductDetail.SIB_ProductAttributeInfo>();
        if(connectProductDetail.variationInfo != null){
            //List
            if(!connectProductDetail.variationInfo.attributesToProductMappings.isEmpty()){
                for(ConnectApi.ProductAttributesToProductEntry attrToProduct : connectProductDetail.variationInfo.attributesToProductMappings){
                    List<SIB_ProductDetail.SIB_AttributesSummary> attributes = new List<SIB_ProductDetail.SIB_AttributesSummary>();
                    for(ConnectApi.ProductAttributeSelectionInfo attrSummary : attrToProduct.selectedAttributes){
                        attributes.add(new SIB_ProductDetail.SIB_AttributesSummary(attrSummary.apiName, attrSummary.label, attrSummary.sequence, attrSummary.value));
                    }
                    SIB_ProductDetail.SIB_ProductAttributesToProductEntry productMapping = 
                    new SIB_ProductDetail.SIB_ProductAttributesToProductEntry(attrToProduct.canonicalKey, attrToProduct.productId, attributes, attrToProduct.urlName);
                    productMappings.add(productMapping);
                }
            }
            //Map
            if(connectProductDetail.variationInfo.variationAttributeInfo !=null){
                for(String key : connectProductDetail.variationInfo.variationAttributeInfo.keySet()){
                    ConnectApi.ProductAttributeInfo pai = (ConnectApi.ProductAttributeInfo)connectProductDetail.variationInfo.variationAttributeInfo.get(key);
                    SIB_ProductDetail.SIB_ProductAttributeInfo attrInfo = new SIB_ProductDetail.SIB_ProductAttributeInfo(pai.allowableValues, pai.apiName, pai.availableValues, pai.fieldEnumOrId, pai.label, pai.objectName, pai.sequence);
                    attributeInfo.put(key, attrInfo);
                }
            }
        }
        SIB_ProductDetail.SIB_ProductVariationInfo variationInfo = new SIB_ProductDetail.SIB_ProductVariationInfo(productMappings,attributeInfo);
        //---------------------

        List<SIB_ProductDetail.SIB_CategoryPath> categoryPathList = new List<SIB_ProductDetail.SIB_CategoryPath>();
        for(ConnectApi.ProductCategoryData productCategoryData  : connectProductDetail.primaryProductCategoryPath.path){
            SIB_ProductDetail.SIB_CategoryPath catPath = new SIB_ProductDetail.SIB_CategoryPath(productCategoryData.id,productCategoryData.name,productCategoryData.description,productCategoryData.urlName);
            categoryPathList.add(catPath);
        }

        //productFieldList contains all lowercase strings
        List<String> productFieldList = SIB_Util.getAllObjectFields(SIB_Constants.PRODUCT_API_NAME).split(', ');

        productDetail.productVariationAttributeSet = attributeSet;
        productDetail.variationInfo = variationInfo;
        productDetail.categoryPath = categoryPathList;
        productDetail.productId = connectProductDetail.id;
        productDetail.name = productFieldList.contains('name') && fieldsMap.containsKey('Name') && fieldsMap.get('Name') != null ? fieldsMap.get('Name') : null;
        productDetail.productSku = productFieldList.contains('stockkeepingunit') && fieldsMap.containsKey('StockKeepingUnit') && fieldsMap.get('StockKeepingUnit') != null ? fieldsMap.get('StockKeepingUnit') : null;
        productDetail.productCode = productFieldList.contains('productcode') && fieldsMap.containsKey('ProductCode') && fieldsMap.get('ProductCode') != null ? fieldsMap.get('ProductCode') : null;
        productDetail.productClass = productFieldList.contains('productclass') && fieldsMap.containsKey('ProductClass') && fieldsMap.get('ProductClass') != null ? fieldsMap.get('ProductClass') : null;
        productDetail.productType = productFieldList.contains('type') && fieldsMap.containsKey('Type') && fieldsMap.get('Type') != null ? fieldsMap.get('Type') : null;
        productDetail.productGroup = productFieldList.contains('product_group__c') && fieldsMap.containsKey('Product_Group__c') && fieldsMap.get('Product_Group__c') != null ? fieldsMap.get('Product_Group__c') : null;
        productDetail.isCourse = productFieldList.contains('sib_is_course__c') && fieldsMap.containsKey('SIB_Is_Course__c') && fieldsMap.get('SIB_Is_Course__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Is_Course__c')) : false;
        productDetail.isMostPopular = productFieldList.contains('sib_most_popular__c') && fieldsMap.containsKey('SIB_Most_Popular__c') && fieldsMap.get('SIB_Most_Popular__c') != null ? Boolean.valueOf(fieldsMap.get('SIB_Most_Popular__c')) : false;
        productDetail.isNewCourse = productFieldList.contains('new_course__c') && fieldsMap.containsKey('New_Course__c') && fieldsMap.get('New_Course__c') != null ? Boolean.valueOf(fieldsMap.get('New_Course__c')) : false;
        productDetail.description = productFieldList.contains('short_description__c') && fieldsMap.containsKey('Short_Description__c') && fieldsMap.get('Short_Description__c') != null ? fieldsMap.get('Short_Description__c') : '';
        productDetail.productCurrency = productFieldList.contains('currencyisocode') && fieldsMap.containsKey('CurrencyIsoCode') && fieldsMap.get('CurrencyIsoCode') != null ? fieldsMap.get('CurrencyIsoCode') : null;
        productDetail.defaultImage = defaultImage;
        productDetail.images = imgList;
        productDetail.attachments = attachments;
        productDetail.videos = videos;
        productDetail.fieldsMap = fieldsMap ;
        productDetail.isSuccess = true ;
        productDetail.message = '';
        return productDetail;
    }

    public SIB_ProductPricing getPricingDetails(SIB_ProductRequest productRequest,  Map<String, String> fieldsMap) {

        DateTime earlyBirdDeadline;
        Decimal fullRegistrationCost;
        Decimal earlyBirdRegistrationCost;

        ISIB_PricingService pricingService = SIB_DependencyService.getInstance().getPricingService() ;
        SIB_ProductPricing pricingDetails = pricingService.getProductPricing(productRequest);
        List<String> productFieldList = SIB_Util.getAllObjectFields(SIB_Constants.PRODUCT_API_NAME).split(', ');

        if(productFieldList != null && !productFieldList.isEmpty()) {

            if(fieldsMap.containsKey('Product_Group__c') && 
                ((fieldsMap.get('Product_Group__c') == SIB_Constants.PRODUCT_GROUP_PRIVATE_COURSE) || (fieldsMap.get('Product_Group__c') == SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE)) ) {

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
                        pricingDetails.priceLabel = SIB_Constants.REGISTRATION_COST;
                        pricingDetails.fullRegistrationCost = fullRegistrationCost;
                        pricingDetails.unitPrice = fullRegistrationCost;
                        pricingDetails.listPrice = fullRegistrationCost;
                    }else {
                        pricingDetails.priceLabel = SIB_Constants.EARLY_BIRD_PRICE;
                        pricingDetails.earlyBirdRegistrationCost = earlyBirdRegistrationCost;
                        pricingDetails.unitPrice = earlyBirdRegistrationCost;
                        pricingDetails.listPrice = earlyBirdRegistrationCost;
                    }
            }
        }
        return pricingDetails;
    }

    public Integer getTotalDays(SIB_ProductDetail productDetail) {
        if(productDetail != null && productDetail.productId != null) {
            List<Product2> products = (List<Product2>)SIB_ProductSelector.getProductByIds(new List<Id>{productDetail.productId});
            if(products != null && !products.isEmpty()) {
                Campaign campaign = SIB_CampaignSelector.getCampaignById(products.get(0).TTS_Event__c);
                if(campaign != null) {
                    return Integer.valueOf(campaign.Total_Days__c);
                }
            }
           
        }
        return null;
    }

    public Integer getCourseCount(SIB_ProductDetail productDetail) {
        if(productDetail != null && productDetail.productId != null) {
            return SIB_BundleItemSelector.getCountByParentId(productDetail.productId);
        }
        return null;
    }
}