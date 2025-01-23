/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 11-12-2024
 * @last modified by  : Gaurav Setia
**/
public without sharing class SIB_ConfigController {
    
    @AuraEnabled
    public static String fetchConfigData(String configType) {

        String storefrontConfigurationString = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:configType].ConfigJSON__c;

        if(String.isBlank(storefrontConfigurationString)){
            storefrontConfigurationString = fetchJSONConfig(configType);
        }
        return storefrontConfigurationString;
    }

    public static String fetchJSONConfig(String configType){

        String jsonString = '';

        if(SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"showPasswordFields": true,'+
                            '"id": "SignUp",'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_HOME.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"id": "home",'+
                            '"Header":[{"Component":""}],'+
                            '"Product":[{"Component":""}]'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_PLP.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"id": "PLP",'+
                            '"defaultView": "grid",'+
                            '"availableLayouts":["list","grid"],'+
                            '"showLayoutButtons":true,'+
                            '"showProductImage": true,'+
                            '"showNegotiatedPrice":true,'+
                            '"showOriginalPrice":false,'+
                            '"showCallToActionButton":false,'+
                            '"addToCartButtonText":"Add to cart",'+
                            '"addToCartButtonProcessingText":"Adding...",' +
                            '"unavailablePriceText":"Price Unavailable",'+
                            '"viewOptionsButtonText":"View options",'+
                            '"cardContentMapping":[{"showLabel": false,"name": "Name", "label": "Product Name"},{"showLabel": false,"name": "StockKeepingUnit", "label": "Product SKU"},{"showLabel": false,"name": "Description", "label": "Product Description"}],'+
                            '"addToCartButtonStyle":"primary",'+
                            '"gridMaxColumnsDisplayed":3,'+
                            '"searchResultsPageSize":2,'+
                            '"selfStudyPageSize":2,'+
                            '"searchResultsFields":"Name"'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_PDP.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"id": "PDP",'+
                            '"customPDP": false,'+
                            '"productTypeList": ['+
                                '{'+
                                    '"productType": "Simple",'+
                                    '"shortDescriptionField": "Description",'+
                                    '"tierPricingConfig": {'+
                                        '"displayType": "horizontal"'+
                                    '},'+
                                    '"displayPromotionalPrice": true,'+
                                    '"displayRelatedProduct": true,'+
                                    '"relatedProductTypes": ['+
                                        '{'+
                                            '"displayName": "You Might Also Like",'+
                                            '"apiName": "Related"'+
                                        '},'+
                                        '{'+
                                            '"displayName": "Add Ons",'+
                                            '"apiName": "Add Ons"'+
                                        '}'+
                                    '],'+
                                    '"displayPageSections": true,'+
                                    '"pageSectionStyle": "accordion",'+
                                    '"pageSections": ['+
                                        '{'+
                                            '"title": "Details",'+
                                            '"apiName": "details",'+
                                            '"fieldAPIName": "Description",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Specification",'+
                                            '"apiName": "specification",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Resources",'+
                                            '"apiName": "resources",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '},'+
                                        '{'+
                                            '"title": "Quantity Discounts",'+
                                            '"apiName": "quantity-discount",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '}'+
                                    ']'+
                                '},'+
                                '{'+
                                    '"productType": "Simple",'+
                                    '"shortDescriptionField": "Description",'+
                                    '"tierPricingConfig": {'+
                                        '"displayType": "horizontal"'+
                                    '},'+
                                    '"displayPromotionalPrice": true,'+
                                    '"displayRelatedProduct": true,'+
                                    '"relatedProductTypes": ['+
                                        '{'+
                                            '"displayName": "Accessories",'+
                                            '"apiName": "Accessories"'+
                                        '}'+
                                    '],'+
                                    '"displayPageSections": true,'+
                                    '"pageSectionStyle": "accordion",'+
                                    '"pageSections": ['+
                                        '{'+
                                            '"title": "Details",'+
                                            '"apiName": "details",'+
                                            '"fieldAPIName": "Description",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Specification",'+
                                            '"apiName": "specification",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Resources",'+
                                            '"apiName": "resources",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '},'+
                                        '{'+
                                            '"title": "Quantity Discounts",'+
                                            '"apiName": "quantity-discount",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '}'+
                                    ']'+
                                '},'+
                                '{'+
                                    '"productType": "Variation Parent",'+
                                    '"shortDescriptionField": "Description",'+
                                    '"displayRelatedProduct": true,'+
                                    '"relatedProductTypes": ['+
                                        '{'+
                                            '"displayName": "Cross Sell",'+
                                            '"apiName": "Cross Sell"'+
                                        '},'+
                                        '{'+
                                            '"displayName": "UpSell",'+
                                            '"apiName": "UpSell"'+
                                        '}'+
                                    '],'+
                                    '"displayPageSections": true,'+
                                    '"pageSectionStyle": "accordion",'+
                                    '"pageSections": ['+
                                        '{'+
                                            '"title": "Details",'+
                                            '"apiName": "details",'+
                                            '"fieldAPIName": "Description",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Resources",'+
                                            '"apiName": "resources",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '}'+
                                    ']'+
                                '},'+
                                '{'+
                                    '"productType": "Subscription",'+
                                    '"shortDescriptionField": "Description",'+
                                    '"subscriptionModel": "B2B",'+
                                    '"displayPromotionalPrice": true,'+
                                    '"displayRelatedProduct": true,'+
                                    '"relatedProductTypes": ['+
                                        '{'+
                                            '"displayName": "You Might Also Like",'+
                                            '"apiName": "Related"'+
                                        '},'+
                                        '{'+
                                            '"displayName": "Accessories",'+
                                            '"apiName": "Accessories"'+
                                        '}'+
                                    '],'+
                                    '"displayPageSections": true,'+
                                    '"pageSectionStyle": "accordion",'+
                                    '"pageSections": ['+
                                        '{'+
                                            '"title": "Details",'+
                                            '"apiName": "details",'+
                                            '"fieldAPIName": "Description",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Specification",'+
                                            '"apiName": "specification",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": false'+
                                        '},'+
                                        '{'+
                                            '"title": "Resources",'+
                                            '"apiName": "resources",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '},'+
                                        '{'+
                                            '"title": "Quantity Discounts",'+
                                            '"apiName": "quantity-discount",'+
                                            '"fieldAPIName": "",'+
                                            '"showOnlyWhenApplicable": true'+
                                        '}'+
                                    ']'+
                                '}'+
                            ']'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_CART.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"id": "cart",'+
                            '"showUniqueCount": false,'+
                            '"allowPromoCode": true,'+
                            '"showRemoveItemOption": true,'+
                            '"showMoreItemsOption": false,'+
                            '"showLineItemTotal": true,'+
                            '"showOriginalPrice": true,'+
                            '"showSKU": true,'+
                            '"showProductImage": true,'+
                            '"showPricePerUnit": true,'+
                            '"showActualPrice": true,'+
                            '"hideQuantitySelector": true,'+
                            '"showSavedAmount": true,'+
                            '"productFields":[{"showLabel": false,"name": "productcode", "label": "Product Code"}],'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"id": "checkout",'+
                            '"displayLayout": "MultiStep",'+
                            '"availablePaymentMethods": ['+
                                '"po",'+
                                '"cc"'+
                            '],'+
                            '"creditCardGateway": "Stripe",'+
                            '"creditCardGatewayClassMap": {'+
                                '"Stripe": "SIB_StripePaymentAdapter",'+
                                '"Cybersource": "SIB_CybersourcePaymentAdapter"'+
                            '},'+
'"allowPromoCode": true,'+
                            '"isShippingProviderEnabled": true,'+
                            '"shippingProvider": ['+
                                '"po"'+
                            '],'+
                            '"isTaxProviderEnabled": true,'+
                            '"taxProvider": "Avalara",'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS.equalsIgnoreCase(configType)){
            jsonString = '{'+
                            '"id": "order",'+
                            '"pageType": "Order Detail Page",'+
                            '"objectApiName": "OrderSummary"'+
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT.equalsIgnoreCase(configType)){
            jsonString = '{' +
                '"id": "storefront",'+
                '"productService": "SIB_B2BProductService",' +
                '"isProductServiceCustom": false,' +
                '"searchMgmtNCartService": "SIB_B2BProductService",' +
                '"isSearchMgmtNCartServiceCustom": false,' +
                '"isSupportedProductTypeBundle": true,' +
                '"isSupportedProductTypeSubscriptionProduct": true,' +
                '"isSupportedProductTypeUsageProduct": true,' +
                '"pricingService": "SIB_B2BProductService",' +
                '"isPricingServiceCustom": false,' +
                '"subscriptionService": "SIB_B2BProductService",' +
                '"automatedRenewalPeriod": "",' +
                '"isSubscriptionServiceCustom": false,' +
                '"isSubscriptionActionTypeNew": true,' +
                '"isSubscriptionActionTypeAmend": true,' +
                '"isSubscriptionActionTypeRenew": true,' +
                '"subscriptionAutomatedRenewals": true' +
            '}';
        }else if (SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER.equalsIgnoreCase(configType)) {
            jsonString = '{' +
                            '"topSection": {' +
                                '"sortOrder": 1,' +
                                '"subsections": [' +
                                    '{' +
                                        '"SubsectionName": "Learn",' +
                                        '"sortOrder": 1,' +
                                        '"isSocialMediaSubSection": false,' +
                                        '"records": [' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/self-study-courses/",' +
                                                '"Label": "Self-Study",' +
                                                '"Active": true,' +
                                                '"sortOrder": 1' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/public-courses/",' +
                                                '"Label": "Public Courses",' +
                                                '"Active": true,' +
                                                '"sortOrder": 2' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/corporate-learning/",' +
                                                '"Label": "Corporate Solutions",' +
                                                '"Active": true,' +
                                                '"sortOrder": 3' +
                                            '}' +
                                        ']' +
                                    '},' +
                                    '{' +
                                        '"SubsectionName": "About Us",' +
                                        '"sortOrder": 2,' +
                                        '"isSocialMediaSubSection": false,' +
                                        '"records": [' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/history/",' +
                                                '"Label": "Our Company",' +
                                                '"Active": true,' +
                                                '"sortOrder": 1' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/team/",' +
                                                '"Label": "Our Team",' +
                                                '"Active": false,' +
                                                '"sortOrder": 2' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/instructor-development/",' +
                                                '"Label": "Instructor Development",' +
                                                '"Active": true,' +
                                                '"sortOrder": 3' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/why-choose-tts/",' +
                                                '"Label": "Why choose Us",' +
                                                '"Active": true,' +
                                                '"sortOrder": 4' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/flexible-learning-options/",' +
                                                '"Label": "Flexible Learning Options",' +
                                                '"Active": true,' +
                                                '"sortOrder": 5' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/training-learning-center/",' +
                                                '"Label": "Training & Learning Center",' +
                                                '"Active": true,' +
                                                '"sortOrder": 6' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/contact/",' +
                                                '"Label": "Contact Us",' +
                                                '"Active": true,' +
                                                '"sortOrder": 7' +
                                            '}' +
                                        ']' +
                                    '},' +
                                    '{' +
                                        '"SubsectionName": "Blog & Resources",' +
                                        '"sortOrder": 3,' +
                                        '"isSocialMediaSubSection": false,' +
                                        '"records": [' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/news-blog/",' +
                                                '"Label": "Blog",' +
                                                '"Active": true,' +
                                                '"sortOrder": 1' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://trainingthestreet.com/resource/",' +
                                                '"Label": "Free Resources",' +
                                                '"Active": false,' +
                                                '"sortOrder": 2' +
                                            '}' +
                                        ']' +
                                    '},' +
                                    '{' +
                                        '"SubsectionName": "Connect with us",' +
                                        '"sortOrder": 4,' +
                                        '"isSocialMediaSubSection": true,' +
                                        '"records": [' +
                                            '{' +
                                                '"URL": "https://www.facebook.com/pages/Training-The-Street/56806716383",' +
                                                '"Label": "facebook",' +
                                                '"Active": true,' +
                                                '"sortOrder": 1' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://twitter.com/TTS_Chat",' +
                                                '"Label": "twitter",' +
                                                '"Active": true,' +
                                                '"sortOrder": 2' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://www.linkedin.com/company/658350",' +
                                                '"Label": "linkedIn",' +
                                                '"Active": true,' +
                                                '"sortOrder": 3' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://www.youtube.com/@trainingthestreetdigital",' +
                                                '"Label": "Youtube",' +
                                                '"Active": true,' +
                                                '"sortOrder": 4' +
                                            '},' +
                                            '{' +
                                                '"URL": "https://www.instagram.com/trainingthestreet/",' +
                                                '"Label": "Instagram",' +
                                                '"Active": true,' +
                                                '"sortOrder": 5' +
                                            '}' +
                                        ']' +
                                    '}' +
                                '],' +
                                '"showSection": true,' +
                                '"openInNewWindow": false' +
                            '},' +
                            '"middleSection": {' +
                                '"sortOrder": 1,' +
                                '"showSection": true,' +
                                '"records": [' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/careers/",' +
                                        '"Label": "Careers",' +
                                        '"Active": true,' +
                                        '"sortOrder": 1' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/",' +
                                        '"Label": "FAQ",' +
                                        '"Active": false,' +
                                        '"sortOrder": 2' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/diversity-equity-inclusion/",' +
                                        '"Label": "Diversity, Equity & Inclusion",' +
                                        '"Active": true,' +
                                        '"sortOrder": 3' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/news-blog/",' +
                                        '"Label": "News & Blog",' +
                                        '"Active": true,' +
                                        '"sortOrder": 4' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/contact/",' +
                                        '"Label": "Contact Us",' +
                                        '"Active": true,' +
                                        '"sortOrder": 5' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/privacy/",' +
                                        '"Label": "Privacy Policy",' +
                                        '"Active": true,' +
                                        '"sortOrder": 6' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/california-privacy-notice/",' +
                                        '"Label": "California Privacy Notice",' +
                                        '"Active": true,' +
                                        '"sortOrder": 7' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/cookie-policy/",' +
                                        '"Label": "Cookie Policy",' +
                                        '"Active": true,' +
                                        '"sortOrder": 8' +
                                    '},' +
                                    '{' +
                                        '"URL": "https://trainingthestreet.com/terms-of-use/",' +
                                        '"Label": "Terms of Use",' +
                                        '"Active": true,' +
                                        '"sortOrder": 9' +
                                    '}' +
                                '],' +
                                '"openInNewWindow": false' +
                            '},' +
                            '"id": "FOOTER",' +
                            '"bottomSection": {' +
                                '"sortOrder": 1,' +
                                '"showSection": true,' +
                                '"records": [' +
                                    '{' +
                                        '"URL": "",' +
                                        '"Label": "Copyright © 2011-2024 Training The Street LLC. All rights reserved.",' +
                                        '"Active": true,' +
                                        '"sortOrder": 1' +
                                    '}' +
                                '],' +
                                '"openInNewWindow": false' +
                            '}' +
                        '}';
        }else if(SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU.equalsIgnoreCase(configType)){
            jsonString =  '{' + 
                            '"Category": [' +
                            '{' + 
                                '"value": "Self-Study",' +
                                '"URL": "self-study",' +
                                '"type": "SIB_SelfStudy",' +
                                '"subCategories": [' +
                                '{' + 
                                    '"SubCategoryName": "Fundamentals",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_Foundations"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_Advanced"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_FoundationsPlusAdvanced"' + '}' +
                                    ']' + 
                                '},' +
                                '{' + 
                                    '"SubCategoryName": "Interview Prep",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_InterviewFundamentals"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_IBInterviewPrep"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_PEInterviePrep"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_HedgeFundInterviewPrep"' + '}' +
                                    ']' + 
                                '},' +
                                '{' + 
                                    '"SubCategoryName": "Role Prep",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_InvestmentBanking"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_Private_Equity"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_EquityResearch"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_BondMarket"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_Assetmanagement"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_GlobalMarketandHedgeFund"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_Restructuring"' + '}' +
                                    ']' + 
                                '},' +
                                '{' + 
                                    '"SubCategoryName": "Industry SPecific",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_RealEstate"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_SoftwareTech"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_OilGas"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_BankingFIG"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_Insurance"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_PharmaBiotech"' + '}' +
                                    ']' + 
                                '},' +
                                '{' + 
                                    '"SubCategoryName": "Producrivity",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_Mastering_Excel"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_BecomeProficientInPowerPoint"' + '},' +
                                    '{' + '"URL": "#", "Label": "SIB_GettingStartedwithCopilot"' + '}' +
                                    ']' + 
                                '},' +
                                '{' + 
                                    '"SubCategoryName": "Others Resource",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_OneOnOneMentoring"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/resource/", "Label": "SIB_SelfStudyFreeResources"' + '}' +
                                    ']' + 
                                '}' +
                                ']' +
                            '},' +
                            '{' + 
                                '"value": "Public Courses",' +
                                '"URL": "category/PublicCourse",' +
                                '"type": "SIB_PublicCourses",' +
                                '"subCategories": [' +
                                '{' + 
                                    '"SubCategoryName": "Public Courses",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_EssentialComprehensive"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKUAA5", "Label": "SIB_AppliedExcel"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKPAA5", "Label": "SIB_FinancialStatementAnalysisAndAccounting"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKXAA5", "Label": "SIB_PrivateEquityTransition"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKZAA5", "Label": "SIB_FinancialModeling"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKRAA5", "Label": "SIB_EnhancedEssential"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKSAA5", "Label": "SIB_WallStreetBootcamp"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKJAA5", "Label": "SIB_PrinciplesOfCapitalMarkets"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKQAA5", "Label": "SIB_EveningEssentials"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKNAA5", "Label": "SIB_PythonTraining"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01tS6000003mUN3IAM", "Label": "SIB_CopilotFoundations"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKKAA5", "Label": "SIB_AdvancedTopics"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKLAA5", "Label": "SIB_SoftwareIndustryAnalysisFinancialModeling"' + '},' +
                                    '{' + '"URL": "https://portal.trainingthestreet.com/s/product/detail/01t4w00000NOSKVAA5", "Label": "SIB_RealEstateFundamentals"' + '}' +
                                    ']' + 
                                '},' +
                                '{' + 
                                    '"SubCategoryName": "Course Calendar",' +
                                    '"records": [' +
                                    '{' + '"URL": "#", "Label": "SIB_CourseCalendar"' + '}' +
                                    ']' + 
                                '}' +
                                ']' +
                            '},' +
                            '{' + 
                                '"value": "Corporate Training",' +
                                '"URL": "https://trainingthestreet.com/corporate-learning/",' +
                                '"type": "SIB_CorporateTraining",' +
                                '"subCategories": [' +
                                '{' + 
                                    '"SubCategoryName": "CORPORATE SOLUTIONS",' +
                                    '"records": [' +
                                    '{' + '"URL": "https://trainingthestreet.com/corporate-learning/", "Label": "SIB_CorporateOverview"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/corporate-excel-training/", "Label": "SIB_CorporateExcelTraining"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/continuing-development/", "Label": "SIB_ContinuingDevelopment"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/program-advisory-services/", "Label": "SIB_ProgramAdvisoryServices"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/onsite-private-equity-training/", "Label": "SIB_PrivateEquity"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/global-markets-training/", "Label": "SIB_GlobalMarkets"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/data_science_analytics_for_finance/", "Label": "SIB_DataScienceAndAnalytics"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/accounting-training/", "Label": "SIB_FinancialStatementAnalysis"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/copilot-for-finance/", "Label": "SIB_CopilotForFinance"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/modeling-solutions/", "Label": "SIB_ModelingSolutions"' + '},' +
                                    '{' + '"URL": "https://trainingthestreet.com/professional-skills-training/", "Label": "SIB_ProfessionalSkillsTraining"' + '}' +
                                    ']' + 
                                '}' +
                                ']' +
                            '},' +
                            '{' + 
                                '"value": "Academic",' +
                                '"URL": "https://trainingthestreet.com/academic/",' +
                                '"type": "SIB_Academic",' +
                                '"subCategories": []' +
                            '},' +
                            '{' + 
                                '"value": "Blog",' +
                                '"URL": "https://trainingthestreet.com/news-blog/",' +
                                '"type": "SIB_Blog",' +
                                '"subCategories": []' +
                            '},' +
                            '{' + 
                                '"value": "About Us",' +
                                '"URL": "https://trainingthestreet.com/team/",' +
                                '"type": "SIB_AboutUs",' +
                                '"subCategories": []' +
                            '},' +
                            '{' + 
                                '"value": "Free Resources",' +
                                '"URL": "https://trainingthestreet.com/resource/",' +
                                '"type": "SIB_FreeResources",' +
                                '"subCategories": []' +
                            '},' +
                            '{' + 
                                '"value": "My Courses",' +
                                '"URL": "my-courses",' +
                                '"type": "SIB_UserMenu_MyCourses",' +
                                '"subCategories": []' +
                            '}' +
                            ']' +
                            '}';

        }

        return jsonString;
    }

    @AuraEnabled
    public static Map<String,String> updateConfigData(String configStr,String keyOrder,String configId) {

        Map<String,String> responseMap = new Map<String,String>();

        String DMLOperation = '';

        try {
            
            SIB_StorefrontConfiguration__c configObj;

            if(SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP.equalsIgnoreCase(configId)){

                SignUpConfigWrapper config = (SignUpConfigWrapper) JSON.deserialize(configStr,SignUpConfigWrapper.class);

                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_SIGNUP;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_HOME.equalsIgnoreCase(configId)){

                HomeConfigWrapper config = (HomeConfigWrapper) JSON.deserialize(configStr,HomeConfigWrapper.class);
                
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_HOME];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_HOME;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_HOME;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_PLP.equalsIgnoreCase(configId)){

                PLPConfigWrapper config = (PLPConfigWrapper) JSON.deserialize(configStr,PLPConfigWrapper.class);
                
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_PLP];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_PLP;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_PLP;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_PDP.equalsIgnoreCase(configId)){

                PDPConfigWrapper config = (PDPConfigWrapper) JSON.deserialize(configStr,PDPConfigWrapper.class);
                
                // Populate tierPricingConfig maps in productTypeList
                for(ProductTypeWrapper productType : config.productTypeList) {
                    if (productType.tierPricingConfig != null) {
                        Map<String, String> newTierPricingConfig = new Map<String, String>();
                        newTierPricingConfig.putAll(productType.tierPricingConfig);
                        productType.tierPricingConfig = newTierPricingConfig;
                    }else{
                        productType.tierPricingConfig = null;
                    }
                }

                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_PDP];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_PDP;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_PDP;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_CART.equalsIgnoreCase(configId)){
                CartConfigWrapper config = (CartConfigWrapper) JSON.deserialize(configStr,CartConfigWrapper.class);
                
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_CART];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_CART;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_CART;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT.equalsIgnoreCase(configId)){
                CheckoutConfigWrapper config = (CheckoutConfigWrapper) JSON.deserialize(configStr,CheckoutConfigWrapper.class);
                
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_CHECKOUT;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
                
                Boolean isShippingProviderEnabled = config.isShippingProviderEnabled;
                
                if(isShippingProviderEnabled){
                    
                    // Add new shipping provider record name in the below set
                    Set<String> allShippingProviders = new Set<String>{'UPS','FedEx'};

                    Map<String,Boolean> newShippingprovidersMap = new Map<String,Boolean>();

                    Set<String> selectedShippingProvidersSet = new Set<String>(config.shippingProvider);

                    for(String provider:allShippingProviders){
                        newShippingprovidersMap.put(provider+'_Shipping',selectedShippingProvidersSet.contains(provider));
                    }
                        
                    activateNDeactivateShippingProviders(newShippingprovidersMap);
                }
                
                Boolean isTaxProviderEnabled = config.isTaxProviderEnabled;

                if(isTaxProviderEnabled){

                    Set<String> allTaxProviders = new Set<String>{'Avalara'};

                    Set<String> selectedTaxProvidersSet = new Set<String>{config.taxProvider};
                    
                    Map<String,Boolean> newTaxprovidersMap = new Map<String,Boolean>();

                    for(String provider:allTaxProviders){
                        newTaxprovidersMap.put(provider,selectedTaxProvidersSet.contains(provider));
                    }

                    activateNDeactivateTaxProviders(newTaxprovidersMap);
                }else{
                    Set<String> allTaxProviders = new Set<String>{'Avalara'};
                    
                    Map<String,Boolean> newTaxprovidersMap = new Map<String,Boolean>();

                    for(String provider:allTaxProviders){
                        newTaxprovidersMap.put(provider,false);
                    }

                    activateNDeactivateTaxProviders(newTaxprovidersMap);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS.equalsIgnoreCase(configId)){
                OrderDetailsConfigWrapper config = (OrderDetailsConfigWrapper) JSON.deserialize(configStr,OrderDetailsConfigWrapper.class);
                
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_ORDER_DETAILS;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT.equalsIgnoreCase(configId)){
                StorefrontConfigWrapper config = (StorefrontConfigWrapper) JSON.deserialize(configStr,StorefrontConfigWrapper.class);
                
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_STOREFRONT;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER.equalsIgnoreCase(configId)){
                SIB_FooterConfiguration config = (SIB_FooterConfiguration) JSON.deserialize(configStr,SIB_FooterConfiguration.class);
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER];
                
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_FOOTER;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }else if(SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU.equalsIgnoreCase(configId)){
                SIB_MegaMenuConfiguration config = (SIB_MegaMenuConfiguration) JSON.deserialize(configStr,SIB_MegaMenuConfiguration.class);
                configObj  = [Select id,ConfigJSON__c,ConfigurationType__c from SIB_StorefrontConfiguration__c where ConfigurationType__c=:SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU];
                if(configObj == null){

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_INSERT;

                    configObj = new SIB_StorefrontConfiguration__c();
                    configObj.id = SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU;
                    configObj.ConfigurationType__c = SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU;
                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                    configObj.Active__c = true;

                }else{

                    DMLOperation = SIB_SetupConstants.DML_OPERATION_UPDATE;

                    configObj.ConfigJSON__c = JSON.serializePretty(config);
                }
            }
            if(SIB_SetupConstants.DML_OPERATION_INSERT.equalsIgnoreCase(DMLOperation)){
                insert configObj;
            }else{
                update configObj;
            }
    
            responseMap.put(SIB_SetupConstants.METHOD_STATUS,SIB_SetupConstants.APEX_CALL_STATUS_SUCCESS);

        } catch (Exception e) {

            System.debug('Exception caught: '+e);
            
            responseMap.put(SIB_SetupConstants.METHOD_STATUS,SIB_SetupConstants.APEX_CALL_STATUS_ERROR);

            responseMap.put(SIB_SetupConstants.RESPONSE_MESSAGE,Label.SIB_Error_Update_Config+': '+e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getProductFields() {
        Map<String, String> fieldMap = new Map<String, String>();
        
        // Query fields of the Product2 object
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Product2.fields.getMap();
        for (String fieldName : fields.keySet()) {
            fieldMap.put(fieldName, fields.get(fieldName).getDescribe().getLabel());
        }
        
        return fieldMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSIBRelatedProductPicklistValues() {
        List<Map<String, String>> picklistValuesList = new List<Map<String, String>>();
        
        // Get the DescribeFieldResult for the Type__c field
        Schema.DescribeFieldResult fieldDescribe = B2B_Recommendation__c.Type__c.getDescribe();
        
        // Retrieve the picklist values
        if (fieldDescribe != null && fieldDescribe.isAccessible()) {
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                Map<String, String> picklistValueMap = new Map<String, String>();
                picklistValueMap.put('label', entry.getLabel());
                picklistValueMap.put('value', entry.getValue());
                picklistValueMap.put('fieldLabel', entry.getLabel());
                picklistValuesList.add(picklistValueMap);
            }
        }
        
        return picklistValuesList;
    }
    
    public static Map<String,String> activateNDeactivateShippingProviders(Map<String,Boolean> newShippingprovidersMap){

        Map<String,String> responseMap = new Map<String,String>();

        String developerName = 'SIB_Shipping_Provider__mdt';

        List<String> metadataList = new List<String>();

        for(String shiipingProviderKey: newShippingprovidersMap.keySet()){

            Boolean fieldValue = newShippingprovidersMap.get(shiipingProviderKey);

            String concatenatedString = developerName+'-'+shiipingProviderKey+'-'+'Is_Active__c'+'-'+fieldValue.toString();
            
            metadataList.add(concatenatedString);
                        
        }

        SIB_MetadataUtils.updateMultipleMetadataRecords(metadataList);

        return responseMap;
    }

    public static Map<String,String> activateNDeactivateTaxProviders(Map<String,Boolean> newTaxprovidersMap){

        Map<String,String> responseMap = new Map<String,String>();

        String developerName = 'SIB_Tax_Provider__mdt';

        List<String> metadataList = new List<String>();

        for(String taxProviderKey: newTaxprovidersMap.keySet()){

            Boolean fieldValue = newTaxprovidersMap.get(taxProviderKey);

            String concatenatedString = developerName+'-'+taxProviderKey+'-'+'Is_Active__c'+'-'+fieldValue.toString();
            
            metadataList.add(concatenatedString);
                        
        }

        SIB_MetadataUtils.updateMultipleMetadataRecords(metadataList);

        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEncryptedFederationId() {

        Map<String, Object> responseMap = new Map<String, Object>();

        try {

            responseMap = SIB_ConfigurationService.getEncryptedFederationId();
        }catch(Exception e) {

            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
        }

        return responseMap;
    }

    /** SIGNUP CONFIG */
    public class SignUpConfigWrapper{
        public String id{get;set;}
        public Boolean showPasswordFields{get;set;}
    }

    /** HOME CONFIG */
    public class HomeConfigWrapper {
        public String id { get; set; }
        public List<ComponentWrapper> Header { get; set; }
        public List<ComponentWrapper> Product { get; set; }
    }
    
    public class ComponentWrapper {
        public String Component { get; set; }
    }

    /** PLP CONFIG */
    public class PLPConfigWrapper {
        public String id { get; set; }
        public String defaultView { get; set; }
        public List<String> availableLayouts { get; set; }
        public Boolean showLayoutButtons { get; set; }
        public Boolean showProductImage { get; set; }
        public Boolean showNegotiatedPrice { get; set; }
        public Boolean showOriginalPrice { get; set; }
        public Boolean showCallToActionButton { get; set; }
        public String addToCartButtonText { get; set; }
        public String unavailablePriceText { get; set; }
        public String addToCartButtonProcessingText { get; set; }
        public String viewOptionsButtonText { get; set; }
        public List<CardContentMappingWrapper> cardContentMapping { get; set; }
        public String addToCartButtonStyle { get; set; }
        public Integer gridMaxColumnsDisplayed { get; set; }
        public Integer searchResultsPageSize{get;set;}
        public Integer selfStudyPageSize{get;set;}
        public List<String> searchResultsFields { get; set; }
    }
    
    public class CardContentMappingWrapper {
        public String name { get; set; }
        public Boolean showLabel { get; set; }
        public String label { get; set; }
    }
    
    /** PDP CONFIG */
    public class PDPConfigWrapper {
        public String id { get; set; }
        public String customPDP { get; set; }
        public List<ProductTypeWrapper> productTypeList { get; set; }
    }
    
    public class ProductTypeWrapper {
        public String productType { get; set; }
        public String shortDescriptionField { get; set; }
        //public TierPricingConfigWrapper tierPricingConfig { get; set; }
        public Map<String, String> tierPricingConfig {get;set;}
        public Boolean displayPromotionalPrice { get; set; }
        public Boolean displayRelatedProduct { get; set; }
        public List<RelatedProductTypeWrapper> relatedProductTypes { get; set; }
        public Boolean displayPageSections { get; set; }
        public String pageSectionStyle { get; set; }
        public List<PageSectionWrapper> pageSections { get; set; }
    }
    
    public class TierPricingConfigWrapper {
        public Map<String, String> config { get; set; }
    }
    
    public class RelatedProductTypeWrapper {
        public String displayName { get; set; }
        public String apiName { get; set; }
    }
    
    public class PageSectionWrapper {
        public String title { get; set; }
        public String apiName { get; set; }
        public String fieldAPIName { get; set; }
        public Boolean showOnlyWhenApplicable { get; set; }
    }
    
    /** CART CONFIG */
    public class CartConfigWrapper {
        public String id { get; set; }
        public Boolean showUniqueCount { get; set; }
        public Boolean allowPromoCode { get; set; }
        public Boolean showRemoveItemOption { get; set; }
        public Boolean showMoreItemsOption { get; set; }
        public Boolean showLineItemTotal { get; set; }
        public Boolean showOriginalPrice { get; set; }
        public Boolean showSKU { get; set; }
        public Boolean showProductImage { get; set; }
        public Boolean showPricePerUnit { get; set; }
        public Boolean showActualPrice { get; set; }
        public Boolean hideQuantitySelector { get; set; }
        public Boolean showSavedAmount { get; set; }
        public List<CardContentMappingWrapper> productFields { get; set; }
    }

    /** CHECKOUT CONFIG */
    public class CheckoutConfigWrapper {
        public String id { get; set; }
        public String displayLayout { get; set; }
        public List<String> availablePaymentMethods { get; set; }
        public String creditCardGateway { get; set; }
        public Map<String, String> creditCardGatewayClassMap { get; set; }
public Boolean allowPromoCode { get; set; }
        public Boolean isShippingProviderEnabled{get;set;}
        public List<String> shippingProvider { get; set; }
        public Boolean isTaxProviderEnabled{get;set;}
        public String taxProvider { get; set; }
    }
    
    /** ORDER DETAILS CONFIG */
    public class OrderDetailsConfigWrapper {
        public String id { get; set; }
        public String pageType { get; set; }
        public String objectApiName { get; set; }
    }
    
    /** STOREFRONT DETAILS CONFIG */
    public class StorefrontConfigWrapper {
        public String subscriptionService { get; set; }
        public Boolean subscriptionAutomatedRenewals { get; set; }
        public String searchMgmtNCartService { get; set; }
        public String productService { get; set; }
        public String pricingService { get; set; }
        public Boolean isSupportedProductTypeUsageProduct { get; set; }
        public Boolean isSupportedProductTypeSubscriptionProduct { get; set; }
        public Boolean isSupportedProductTypeBundle { get; set; }
        public Boolean isSubscriptionServiceCustom { get; set; }
        public Boolean isSubscriptionActionTypeRenew { get; set; }
        public Boolean isSubscriptionActionTypeNew { get; set; }
        public Boolean isSubscriptionActionTypeCancellationSupport { get; set; }
        public Boolean isSubscriptionActionTypeAmend { get; set; }
        public String isSearchMgmtNCartServiceCustom { get; set; }
        public Boolean isProductServiceCustom { get; set; }
        public Boolean isPricingServiceCustom { get; set; }
        public Boolean isInventoryServiceCustom { get; set; }
        public String inventoryService { get; set; }
        public String automatedRenewalPeriod { get; set; }
        public String productSearchService { get; set; }
        public Boolean isProductSearchServiceCustom { get; set; }
        public String cartService { get; set; }
        public Boolean isCartServiceCustom { get; set; }
        public String relatedProductService { get; set; }
        public Boolean isRelatedProductServiceCustom { get; set; }
    }  

}