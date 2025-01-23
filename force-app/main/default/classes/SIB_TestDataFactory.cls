/**
 * @author Amit Prashar
 * @email aprashar@rafter.one
 * @create date 2024-09-17 
 * @modify date 2024-09-17
 * @desc [description]
 */

 @isTest
 public with sharing class SIB_TestDataFactory {
 
     public static String getMockId(Schema.SObjectType sot)
     {
         Integer randomNumber = Integer.valueof((Math.random() * 100));
         String result = String.valueOf(randomNumber);
         return sot.getDescribe().getKeyPrefix() +'0'.repeat(12-result.length()) + result;
     }
 
     public static WebStore createWebStore(Boolean dml){
         WebStore wbStore = new WebStore();
         wbStore.Name = SIB_SetupConstants.STOREFRONT;
         wbStore.PricingStrategy = 'LowestPrice';
         if(dml){
             insert wbStore;
         }else{
             wbStore.Id = getMockId(WebStore.SObjectType) ;
         }
         return wbStore;
     }
 
     public static ProductCatalog createProductCatalog(Boolean dml){
         ProductCatalog prodCatalog = new ProductCatalog();
         prodCatalog.Name = SIB_SetupConstants.STOREFRONT+' Catalog';
         if(dml){
             insert prodCatalog;
         }else{
             prodCatalog.Id = getMockId(ProductCatalog.SObjectType) ;
         }
         return prodCatalog;
     }
 
     public static WebStoreCatalog createWebStoreCatalog(String webStoreId, String productCatalogId,Boolean dml){
         WebStoreCatalog webCatalog = new WebStoreCatalog();
         webCatalog.SalesStoreId = webStoreId;
         webCatalog.ProductCatalogId = productCatalogId;
         if(dml){
             insert webCatalog;
         }else{
             webCatalog.Id = getMockId(WebStoreCatalog.SObjectType) ;
         }
         return webCatalog;
     }
 
     public static ProductCategory createProductCategory(String name,String prodCatalogId,String parentId,Boolean dml){
         ProductCategory category = new ProductCategory();
         category.Name = name;
         category.CatalogId = prodCatalogId;
         category.ParentCategoryId = parentId;
         if(dml){
             insert category;
         }else{
             category.Id = getMockId(ProductCategory.SObjectType) ;
         }
         return category;
     }
 
     public static BuyerGroup createBuyerGroup(Boolean dml){
         BuyerGroup bg = new BuyerGroup();
         bg.Name = SIB_Util.getRegistrationBuyerGroupName();
         if(dml){
             insert bg;
         }else{
             bg.Id = getMockId(BuyerGroup.SObjectType) ;
         }
         return bg;
     }
 
     public static WebStoreBuyerGroup createWebStoreBuyerGroup(String webStoreId, String buyerGroupId,Boolean dml){
         WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
         webStrBuyerGrp.WebStoreId = webStoreId;
         webStrBuyerGrp.BuyerGroupId = buyerGroupId;
         if(dml){
             insert webStrBuyerGrp;
         }else{
             webStrBuyerGrp.Id = getMockId(WebStoreBuyerGroup.SObjectType) ;
         }
         return webStrBuyerGrp;
     }
 
     public static CommerceEntitlementPolicy createCommerceEntitlementPolicy(String name,Boolean dml){
         CommerceEntitlementPolicy commerceEntPolicy = new CommerceEntitlementPolicy();
         commerceEntPolicy.Name = name;
         commerceEntPolicy.Description = name;
         commerceEntPolicy.CanViewProduct = true;
         commerceEntPolicy.CanViewPrice = true;
         commerceEntPolicy.IsActive = true;
         if(dml){
             insert commerceEntPolicy;
         }else{
             commerceEntPolicy.Id = getMockId(CommerceEntitlementPolicy.SObjectType) ;
         }
         return commerceEntPolicy;
     }
 
     public static CommerceEntitlementBuyerGroup createCommerceEntitlementBuyerGroup(String buyerGroupId,String commerceEntPolicyId,Boolean dml){
         CommerceEntitlementBuyerGroup commerceEntBuyerGrp = new CommerceEntitlementBuyerGroup();
         commerceEntBuyerGrp.PolicyId = commerceEntPolicyId;
         commerceEntBuyerGrp.BuyerGroupId = buyerGroupId;
         if(dml){
             insert commerceEntBuyerGrp;
         }else{
             commerceEntBuyerGrp.Id = getMockId(CommerceEntitlementBuyerGroup.SObjectType) ;
         }
         return commerceEntBuyerGrp;
     }
 
     public static Pricebook2 createCommercePricebook2(String name,Boolean dml){
         Pricebook2 commercePriceBook = new Pricebook2();
         commercePriceBook.Name = name ;
         commercePriceBook.IsActive = true;
         if(dml){
             insert commercePriceBook;
         }else{
             commercePriceBook.Id = getMockId(Pricebook2.SObjectType) ;
         }
         return commercePriceBook;
     }
 
     public static BuyerGroupPricebook createBuyerGroupPricebook(String buyerGrpId,String commercePriceBookId, Boolean dml){
         BuyerGroupPricebook buyerGrpPricebook = new BuyerGroupPricebook();
         buyerGrpPricebook.BuyerGroupId = buyerGrpId;
         buyerGrpPricebook.Pricebook2Id = commercePriceBookId;
         buyerGrpPricebook.IsActive = true;
         if(dml){
             insert buyerGrpPricebook;
         }else{
             buyerGrpPricebook.Id = getMockId(BuyerGroupPricebook.SObjectType) ;
         }
         return buyerGrpPricebook;
     }
 
     public static PriceAdjustmentSchedule createPriceAdjustmentSchedule(Boolean dml){
         PriceAdjustmentSchedule PriceAdjSchedule = new PriceAdjustmentSchedule();
         PriceAdjSchedule.Name = 'RE Original Adjustment Schedule' ;
         PriceAdjSchedule.IsActive = true ;
         PriceAdjSchedule.ScheduleType = 'Volume' ;
         PriceAdjSchedule.AdjustmentMethod = 'Range' ;
         if(dml){
             insert PriceAdjSchedule;
         }else{
             PriceAdjSchedule.Id = getMockId(PriceAdjustmentSchedule.SObjectType) ;
         }
         return PriceAdjSchedule;
     }
 
     public static Map<String,Product2> createProducts(Boolean dml){
         List<Product2> products = new List<Product2>();
         Product2 productOne = new Product2(
             CurrencyIsoCode ='USD',
             Description ='SN74CBTLV1G125-Q1 Automotive Catalog Low-Voltage Single FET Bus Switch',
             DisplayUrl ='https://embed.widencdn.net/img/rocelec/n5clnnaato/640px/sot95p280x145-5l25_max_n.step.png?keep=c&crop=yes&u=5oefqw',
             IsActive =true,
             Name ='74CBTLV1G125DBVRQ1',
             ProductCode ='74CBTLV1G125DBVRQ1',
             StockKeepingUnit = '74CBTLV1G125DBVRQ12'
         );
         if(!dml){
             productOne.Id = getMockId(Product2.SObjectType) ;
         }
         products.add(productOne);
         Product2 productTwo = new Product2(
             CurrencyIsoCode ='USD',
             Description ='LM2901 - Comparator, 4 Func, 15000uV Offset-Max, 1300ns Response Time, PDIP14',
             DisplayUrl ='https://embed.widencdn.net/img/rocelec/naefzb9atr/640px/dip794w25p254l1969h508q14_txn_p.step.png?keep=c&crop=yes&u=5oefqw',
             IsActive =true,
             Name ='LM2901N',
             ProductCode ='LM2901N',
             StockKeepingUnit ='LM2901N2'
         );
         if(!dml){
             productTwo.Id = getMockId(Product2.SObjectType) ;
         }
 
         products.add(productTwo);
         if(dml){
             insert products;
         }
         Map<String,Product2> productMap = new Map<String,Product2>();
         for(Product2 prod: products){
             productMap.put(prod.productcode,prod);
         }
         return productMap;
     }
     
     public static List<ProductCategoryProduct> createProductcategory(String categoryId,List<Product2> products,Boolean dml){
         List<ProductCategoryProduct> insertList = new List<ProductCategoryProduct>();
         for(Product2 prod:products){
             ProductCategoryProduct pcp = new ProductCategoryProduct(
                 ProductId = prod.Id ,
                 ProductCategoryId = categoryId ,
                 IsPrimaryCategory= true
             );
             if(!dml){
                 pcp.Id = getMockId(ProductCategoryProduct.SObjectType) ;
             }
             insertList.add(pcp);
         }
         if(dml){
             insert insertList;
         }
         return insertList;
     }
 
     public static List<CommerceEntitlementProduct> createProductsToEntitlement(String entitledId,List<Product2> products,Boolean dml){
         List<CommerceEntitlementProduct> insertList = new List<CommerceEntitlementProduct>();
         for(Product2 prod:products){
             CommerceEntitlementProduct cep = new CommerceEntitlementProduct(
                 ProductId = prod.Id ,
                 PolicyId = entitledId
             );
             if(!dml){
                 cep.Id = getMockId(CommerceEntitlementProduct.SObjectType) ;
             }
             insertList.add(cep);
         }
         if(dml){
             insert insertList;
         }
         return insertList;
     }
 
 
     public static List<PricebookEntry> createPricebookEntry(String priceBookId,List<Product2> products,Boolean dml){
         List<PricebookEntry> insertList = new List<PricebookEntry>();
         List<PricebookEntry> insertStandardList = new List<PricebookEntry>();
         for(Product2 prod:products){
             PricebookEntry stdPe = new PricebookEntry(
                 Pricebook2Id = Test.getStandardPricebookId(),
                 Product2Id = prod.Id,
                 UnitPrice = 100,
                 IsActive = true
             );
             if(!dml){
                 stdPe.Id = getMockId(PricebookEntry.SObjectType) ;
             }
             insertStandardList.add(stdPe);
             PricebookEntry pe = new PricebookEntry(
                 Pricebook2Id = priceBookId,
                 Product2Id = prod.Id,
                 UnitPrice = 100,
                 IsActive = true,
                 CurrencyISOCode = 'USD'
             );
             if(!dml){
                 pe.Id = getMockId(PricebookEntry.SObjectType) ;
             }
             insertList.add(pe);
         }
         if(dml){
             insert insertStandardList;
             insert insertList;
         }
         return insertList;
     }
 
 
     public static User createAdminUser(Boolean dml){
 
         User adminUser = new User();
         adminUser.Alias = 'test123';
         adminUser.Email='testadmin@yopmail.com';
         adminUser.Emailencodingkey='UTF-8';
         adminUser.Lastname='Testing';
         adminUser.Languagelocalekey='en_US';
         adminUser.Localesidkey='en_US';
         adminUser.Profileid = UserInfo.getProfileId();
         //adminUser.Country='United States';
         adminUser.Country='US';//Changed VRa Oct 2 24
         adminUser.IsActive =true;
         adminUser.Timezonesidkey='America/Los_Angeles';
         adminUser.Username='testadmin222@yopmail.com';
         adminUser.UserRoleId = UserInfo.getUserRoleId();
         if(dml){
             insert adminUser;
         }else{
             adminUser.Id = getMockId(User.SObjectType) ;
         }
         return adminUser;
     }
 
 
     public static Account createBuyerAccount( BuyerGroup buyGrp,Boolean dml){
         Account acc = new Account();
         acc.Name = 'Doe INC';
         acc.Website = 'https://www.rafterone.com';
         acc.Phone = '9876543210';
         acc.BillingCountryCode = 'US';
         acc.BillingStateCode = 'GA';
         if(dml){
             insert acc;
         }else{
             acc.Id = getMockId(Account.SObjectType) ;
         }
         BuyerAccount bAccount = new BuyerAccount();
         bAccount.BuyerId = acc.Id;
         bAccount.Name = acc.name;
         bAccount.IsActive = true;
         if(dml){
             insert bAccount;
         }else{
             bAccount.Id = getMockId(BuyerAccount.SObjectType) ;
         }
         BuyerGroupMember buyGrpMem = new BuyerGroupMember();
         buyGrpMem.BuyerId = acc.Id;
         buyGrpMem.BuyerGroupId = buyGrp.Id;
         if(dml){
             insert buyGrpMem;
         }else{
             buyGrpMem.Id = getMockId(BuyerGroupMember.SObjectType) ;
         }
         return acc;
     }
 
     public static ContactPointAddress createShippingCPA( Account acc,Boolean dml){
 
         ContactPointAddress cpa = new ContactPointAddress();
         cpa.Name='Test CPA';
         cpa.AddressType='Shipping';
         cpa.Street='TestStreet';
         cpa.City='TestCity';
         cpa.StateCode ='GA';
         cpa.CountryCode ='US';
         cpa.PostalCode='30071';
         cpa.IsDefault=true;
         cpa.ParentId=acc.Id;
         cpa.CompanyName = acc.name  ;
         cpa.PhoneNumber = '9876543210' ;
         if(dml){
             insert cpa;
         }else{
             cpa.Id = getMockId(ContactPointAddress.SObjectType) ;
         }
         return cpa;
     }
 
     public static User createUser(  Contact customerContact,Boolean dml){
         
         User storeUser = new User();
         String orgId = UserInfo.getOrganizationId();
         String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
         Integer randomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
         String uniqueName = orgId + dateString + RandomId;
         storeUser.firstname = customerContact.firstname;
         storeUser.lastName = customerContact.lastName;
         storeUser.email = uniqueName + '@test' + orgId + '.org';
         storeUser.Username = uniqueName + '@test' + orgId + '.org';
         storeUser.EmailEncodingKey = 'ISO-8859-1';
         storeUser.Alias = uniqueName.substring(18, 23);
         storeUser.TimeZoneSidKey = 'America/Los_Angeles';
         storeUser.LocaleSidKey = 'en_US';
         storeUser.LanguageLocaleKey = 'en_US';
         storeUser.CommunityNickname = string.valueOf(math.random()).substring(0,6);
         storeUser.IsActive = true;
         storeUser.ProfileId = SIB_UserRegistrationHelper.getProfileId();
         storeUser.ContactId = customerContact.Id;
 
         if(dml){
             insert storeUser;
         }else{
             storeUser.Id = getMockId(User.SObjectType) ;
         }
         return storeUser;
     }
 
     public static List<PermissionSetAssignment> assignPermissionSet(User storeUser,Boolean dml){
         List<PermissionSetAssignment> prSetAssignments = new List<PermissionSetAssignment>();
         List<PermissionSet> buyerPermissionSetList = SIB_UserRegistrationHelper.getBuyerPermissionSet();
 
         for(PermissionSet ps : buyerPermissionSetList){
             PermissionSetAssignment psa =new PermissionSetAssignment (PermissionSetId = ps.Id, AssigneeId = storeUser.Id);
             if(!dml){
                 psa.Id = getMockId(PermissionSetAssignment.SObjectType) ;
             }
             prSetAssignments.add(psa);
         }
         if(dml){
             insert prSetAssignments;
         }
         return prSetAssignments;
     }
 
     public static WebCart createCart(Contact customerContact,User storeUser,WebStore webStore,Boolean dml){
         WebCart cart = new  WebCart();
         cart.CurrencyISOCode = 'USD';
         cart.Name = 'Cart';
         cart.Status = 'Active';
         cart.WebStoreId = webStore.Id;
         cart.AccountId = customerContact.AccountId;
         cart.OwnerId = storeUser.Id;
         cart.BillingCity = 'Los Angeles';
         cart.BillingCountryCode = 'US';
         cart.BillingStateCode = 'CA';
         cart.BillingPostalCode = '75040';
         cart.BillingStreet = '123 Adven Street';
         if(dml){
             insert cart;
         }else{
             cart.Id = getMockId(WebCart.SObjectType) ;
         }
         return cart;
 
     }
 
 
     public static OrderDeliveryMethod createOrderDeliveryMethod(Boolean dml){
         Product2 shipProduct =new Product2();
         shipProduct.Name = 'Default Shipping Product' ;
         shipProduct.ProductCode = 'Default Shipping Product' ;
         shipProduct.StockKeepingUnit = 'Default Shipping Product' ;
         shipProduct.isActive = true ;
         if(dml){
             insert shipProduct;
         }else{
             shipProduct.Id = getMockId(Product2.SObjectType) ;
         }
         OrderDeliveryMethod odm = new OrderDeliveryMethod();
         odm.Name = 'default Shipping';
         odm.ProductId = shipProduct.Id;
         odm.IsActive = true;
         if(dml){
             insert odm;
         }else{
             odm.Id = getMockId(OrderDeliveryMethod.SObjectType) ;
         }
         return odm;
     }
 
     public static CartDeliveryGroup createCartDeliveryGroup( WebCart cart,Boolean dml){
         CartDeliveryGroup cdg = new CartDeliveryGroup();
         cdg.Name = 'Default Delivery';
         cdg.cartId = cart.Id;
         cdg.DeliverToName = 'Test';
         cdg.DeliverToStreet = 'Test';
         cdg.DeliverToCity = 'Test';
         cdg.DeliverToPostalCode = '30071';
         cdg.DeliverToCountryCode = 'US';
         cdg.DeliverToStateCode = 'GA';
         cdg.ShipToPhoneNumber= '98765432120' ;
         cdg.CompanyName = 'Test Company' ;
         if(dml){
             insert cdg;
         }else{
             cdg.Id = getMockId(CartDeliveryGroup.SObjectType) ;
         }
         return cdg;
     }
 
     public static CartDeliveryGroupMethod createCartDeliveryGroupMethod( CartDeliveryGroup cdg,OrderDeliveryMethod odm,Boolean dml){
         CartDeliveryGroupMethod cdgm = new CartDeliveryGroupMethod();
         cdgm.WebCartId = cdg.cartId ;
         cdgm.Name = 'CDG Method' ;
         cdgm.WebCartId = cdg.cartId ;
         cdgm.CartDeliveryGroupId = cdg.id ;
         cdgm.ShippingFee = 10 ;
         cdgm.ExternalProvider = 'ExternalProvider';
         cdgm.DeliveryMethodId = cdg.SelectedDeliveryMethodId;
         cdgm.ProductId = odm.ProductId ;
         if(dml){
             insert cdgm;
         }else{
             cdgm.Id = getMockId(WebCart.SObjectType) ;
         }
         return cdgm;
     }
 
 
     public static List<CartItem> createCartItems(WebCart cart,List<Product2> products, CartDeliveryGroup cdg,Boolean dml){
         
         List<CartItem> cItems = new List<CartItem>();
         if(cart != null && products != null)
         {
             for(Product2 product : products)
             {
                 CartItem cItem = new CartItem();
                 cItem.cartId=cart.Id;
                 cItem.Product2Id=product.Id;
                 cItem.Product2=product;
                 cItem.Sku=product.StockKeepingUnit;
                 cItem.Type='Product';
                 cItem.SalesPrice =  0.7074;
                 cItem.ListPrice = 0;
                 cItem.TotalLineAmount=707.4;
                 cItem.TotalPrice = 601.29;
                 cItem.Quantity=1000;
                 cItem.CartDeliveryGroupId=cdg.id;
                 cItem.Name= product.Name;
                 cItems.add(cItem);
             }
             if(dml){
                 insert cItems;
             }
         }
         return cItems;
     }
 
     public static Contact createContact( Account acc,Boolean dml){
         Contact customerContact = new Contact();
         customerContact.AccountId = acc.Id;
         customerContact.FirstName = 'Smith';
         customerContact.LastName = 'Doe';
         customerContact.Email = 'sdoe@yopmail.com';
         customerContact.Phone = '9876543210';
         customerContact.MailingCountryCode = 'US';
         customerContact.MailingStateCode = 'GA';
         if(dml){
             insert customerContact;
         }else{
             customerContact.Id = getMockId(Contact.SObjectType) ;
         }
         return customerContact;
     }

     public static SIB_StorefrontConfiguration__c createStorefrontConfiguration(String configType,String jsonData){
        SIB_StorefrontConfiguration__c testConfig = new SIB_StorefrontConfiguration__c();
        testConfig.ConfigurationType__c = configType;
        testConfig.Active__c = true;
        testConfig.ConfigJSON__c  = jsonData;
        insert testConfig;

        return testConfig;
     }

     

     public static ConnectApi.CartSummary createMockConnectAPICartSummary(String cartId){
        ConnectApi.CartSummary cartSummaryMock = new ConnectApi.CartSummary();
        cartSummaryMock.cartId = cartId;
        cartSummaryMock.grandTotalAmount = '100.00';
        cartSummaryMock.totalProductAmount = '80.00';
        cartSummaryMock.totalTaxAmount = '5.00';
        cartSummaryMock.totalChargeAmount = '10.00';
        cartSummaryMock.totalPromotionalAdjustmentAmount = '5.00';
        cartSummaryMock.status = ConnectApi.CartStatus.Active;
        cartSummaryMock.uniqueProductCount = 3;
        cartSummaryMock.currencyIsoCode = 'USD';
        cartSummaryMock.totalProductAmountAfterAdjustments = '75.00';

        return cartSummaryMock;
     }

     public static ConnectApi.CartItemCollection createMockCartItemCollection(String cartId){ 
         List<ConnectApi.CartItemResult> mockCartItems = new List<ConnectApi.CartItemResult>();
         Id defauImageId = SIB_TestDataFactory.getMockId(ProductMedia.SObjectType) ;  
         Id cartItemId = SIB_TestDataFactory.getMockId(CartItem.SObjectType) ;  

         ConnectApi.CartItem mockCartItem = new ConnectApi.CartItem();
         mockCartItem.cartItemId = cartItemId;
         mockCartItem.productId = cartItemId;
         mockCartItem.productDetails = new ConnectApi.CartItemProduct();
         mockCartItem.productDetails.sku = 'SKU123';
         mockCartItem.productDetails.name = 'Product Name';
         mockCartItem.productDetails.fields = new Map<String, String>{
             'Product_Group__c' => 'Group1',
             'SIB_Is_Course__c' => 'true',
             'SIB_Most_Popular__c' => 'true'
         };
         mockCartItem.quantity = '1';
         mockCartItem.totalListPrice = '50.00';
         mockCartItem.salesPrice ='45.00';
         mockCartItem.totalPrice = '45.00';
         mockCartItem.totalAdjustmentAmount = '5.00';
         mockCartItem.type = ConnectApi.CartItemType.Product;
         mockCartItem.productDetails.thumbnailImage = new ConnectApi.ProductMedia();
         mockCartItem.productDetails.thumbnailImage.id = defauImageId;
         mockCartItem.productDetails.thumbnailImage.title = 'Thumbnail';
         mockCartItem.productDetails.thumbnailImage.mediaType = ConnectApi.ProductMediaType.Image;
         mockCartItem.productDetails.thumbnailImage.alternateText = 'Alt Text';
         mockCartItem.productDetails.thumbnailImage.url = 'http://example.com/image.png';
 
         ConnectApi.CartItemResult mockCartItemResult = new ConnectApi.CartItemResult();
         mockCartItemResult.cartItem = mockCartItem;
         mockCartItems.add(mockCartItemResult);
 
         ConnectApi.CartItemCollection mockCartItemsCollection = new ConnectApi.CartItemCollection();
         mockCartItemsCollection.cartItems = mockCartItems;
         mockCartItemsCollection.cartSummary = createMockConnectAPICartSummary(cartId);

         return mockCartItemsCollection;
     }

     public static ConnectApi.CartCouponCollection createMockCartCouponCollection(String cartId) {
        ConnectApi.CartCouponCollection mockCouponCollection = new ConnectApi.CartCouponCollection();
        mockCouponCollection.cartId = cartId;
        return mockCouponCollection;
    }

    public static ConnectApi.PreserveCart createMockPreserveCart(String cartId) {
        ConnectApi.PreserveCart mockPreserveCart = new ConnectApi.PreserveCart();
        mockPreserveCart.cartId = cartId;
        mockPreserveCart.currencyIsoCode ='USD';
        mockPreserveCart.numberOfProducts = 2;
        mockPreserveCart.numberOfProductsWithSuccess = 2;

        return mockPreserveCart;
    }

    public static ConnectApi.ProductDetail createMockProductSearchData(String productId){

        ProductCatalog testProductCatalog = SIB_TestDataFactory.createProductCatalog(false);
        ProductCategory testProductCategory = SIB_TestDataFactory.createProductCategory('AllCategories',testProductCatalog.Id,null,false);
        ProductCategory testChildCategory = SIB_TestDataFactory.createProductCategory('Test Child Category',testProductCatalog.Id,testProductCategory.Id,false);

        BuyerGroup testBuyerGroup = SIB_TestDataFactory.createBuyerGroup(true);    
        Account testAccount = SIB_TestDataFactory.createBuyerAccount(testBuyerGroup,true);
        Id defauImageId = SIB_TestDataFactory.getMockId(ProductMedia.SObjectType) ;  
        Id videoId = SIB_TestDataFactory.getMockId(ProductMedia.SObjectType) ;  
        Id mediaId = SIB_TestDataFactory.getMockId(ProductMedia.SObjectType) ;  

        //Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
        Pricebook2 testPricebook = SIB_TestDataFactory.createCommercePricebook2('TTS B2B Store Price Book',true);
        Campaign ttsEvent = new Campaign();
        ttsEvent.Account__c  = testAccount.Id;
        ttsEvent.Name = 'Testtts Event';
        insert ttsEvent;

        Session__c session1 = new Session__c(
            Name = 'Session 1',
            Event__c = ttsEvent.Id,
            Session_Date__c = Date.today(),
            Start_AM_PM__c = 'AM',
            Start_Hours__c = '9',
            Start_Minutes__c = '30',
            End_AM_PM__c = 'AM',
            End_Hours__c = '11',
            End_Minutes__c = '0'
        );
        Session__c session2 = new Session__c(
            Name = 'Session 2',
            Event__c = ttsEvent.Id,
            Session_Date__c = Date.today(),
            Start_AM_PM__c = 'PM',
            Start_Hours__c = '2',
            Start_Minutes__c = '0',
            End_AM_PM__c = 'PM',
            End_Hours__c = '4',
            End_Minutes__c = '0'
        );
        insert new List<Session__c>{ session1, session2 };
        
        Event_Relationship__c testEventRel = new Event_Relationship__c();
        testEventRel.Parent__c = ttsEvent.Id;
        insert testEventRel;
        product2 testProduct =  [SELECT Id,TTS_Event__c,Early_Bird_Deadline_formula__c,StockKeepingUnit,ProductCode,Product_Group__c FROM Product2 WHERE Id =: productId];
        testProduct.TTS_Event__c = ttsEvent.Id;
        update testProduct;

        List<PricebookEntry> createPriceBookEntry = SIB_TestDataFactory.createPricebookEntry((String)testPricebook.Id,new List<product2>{testProduct},true);
        ConnectApi.PurchaseQuantityRule mockQuantityRule = new ConnectApi.PurchaseQuantityRule();
        mockQuantityRule.increment = '5';
        mockQuantityRule.maximum = '50';
        mockQuantityRule.minimum = '1';
        // Prepare test data
        ConnectApi.ProductDetail testProductDetail = new ConnectApi.ProductDetail();
        testProductDetail.id = productId;
        testProductDetail.purchaseQuantityRule = mockQuantityRule;
        
        // Mock fieldsMap
        testProductDetail.fields = new Map<String, String>{
            'Name' => 'Test Product',
            'StockKeepingUnit' => testProduct.StockKeepingUnit,
            'ProductCode' => testProduct.ProductCode,
            'ProductClass' => 'Electronics',
            'Type' => 'Gadget',
            'Product_Group__c' => testProduct.Product_Group__c,
            'SIB_Is_Course__c' => 'true',
            'SIB_Most_Popular__c' => 'false',
            'Short_Description__c' => 'Test Description',
            'TTS_Event__c' => ttsEvent.Id,
            'CurrencyIsoCode' => 'USD',
            'Early_Bird_Deadline_formula__c' => '2024-10-21T12:00:00Z',
            'Full_Registration_Cost_formula__c'=> '150.00',
            'Early_Bird_Registration_Cost_formula__c' => '120.00'
        };

        

        // Mock default image
        ConnectApi.ProductMedia defaultImage = new ConnectApi.ProductMedia();
        defaultImage.id = defauImageId;
        defaultImage.title = 'Default Image';
        defaultImage.mediaType = ConnectApi.ProductMediaType.Image;
        defaultImage.alternateText = 'Alternate Text';
        defaultImage.url = 'https://example.com/defaultImage.jpg';
        testProductDetail.defaultImage = defaultImage;

        ConnectApi.ProductMedia imageMedia = new ConnectApi.ProductMedia();
        imageMedia.id = defauImageId;
        imageMedia.title = 'Default Image';
        imageMedia.mediaType = ConnectApi.ProductMediaType.Image;
        imageMedia.alternateText = 'Alternate Text';
        imageMedia.url = 'https://example.com/defaultImage.jpg';


        ConnectApi.ProductMedia docMedia = new ConnectApi.ProductMedia();
        docMedia.id = mediaId;
        docMedia.title = 'Document Title';
        docMedia.mediaType = ConnectApi.ProductMediaType.Document;
        docMedia.alternateText = 'Document Alt';
        docMedia.url = 'https://example.com/doc.pdf';

        ConnectApi.ProductMedia videoMedia = new ConnectApi.ProductMedia();
        videoMedia.id = videoId;
        videoMedia.title = 'Video Title';
        videoMedia.mediaType = ConnectApi.ProductMediaType.Video;
        videoMedia.alternateText = 'Video Alt';
        videoMedia.url = 'https://example.com/video.mp4';

        ConnectApi.ProductMediaGroup mediaGroup = new ConnectApi.ProductMediaGroup();
        mediaGroup.mediaItems = new List<ConnectApi.ProductMedia>{ imageMedia, docMedia, videoMedia };
        testProductDetail.mediaGroups = new List<ConnectApi.ProductMediaGroup>{ mediaGroup };

        ConnectApi.ProductAttributesToProductEntry attrToProductEntry = new ConnectApi.ProductAttributesToProductEntry();
        attrToProductEntry.canonicalKey = 'key1';
        attrToProductEntry.productId = testProduct.Id;

        ConnectApi.ProductAttributeSelectionInfo attributeSelectionInfo = new ConnectApi.ProductAttributeSelectionInfo();
        attributeSelectionInfo.apiName = 'Color';
        attributeSelectionInfo.label = 'Red';
        attributeSelectionInfo.sequence = 1;
        attributeSelectionInfo.value = 'Red';

        attrToProductEntry.selectedAttributes = new List<ConnectApi.ProductAttributeSelectionInfo>{ attributeSelectionInfo };


        // Add the attribute to the attributes list of the ProductAttributeSet
        ConnectApi.ProductAttributeSet mockAttrSet = new ConnectApi.ProductAttributeSet();
        mockAttrSet.developerName = 'Test_Attribute_Set';
        mockAttrSet.id = 'TestId';
        mockAttrSet.attributes = new Map<String,string>();
        
        testProductDetail.variationAttributeSet = mockAttrSet;

        testProductDetail.variationInfo = new ConnectApi.ProductVariationInfo();
        testProductDetail.variationInfo.attributesToProductMappings = new List<ConnectApi.ProductAttributesToProductEntry>{ attrToProductEntry };

        // Create and populate ConnectApi.ProductAttributeInfo
        ConnectApi.ProductAttributeInfo productAttributeInfo = new ConnectApi.ProductAttributeInfo();
        productAttributeInfo.allowableValues = new List<String>{ 'Red', 'Blue' };
        productAttributeInfo.apiName = 'Color';
        productAttributeInfo.availableValues = new List<String>{ 'Red' };
        productAttributeInfo.fieldEnumOrId = 'Color';
        productAttributeInfo.label = 'Color';
        productAttributeInfo.objectName = 'Product';
        productAttributeInfo.sequence = 1;

        // Assign the created ProductAttributeInfo to the map
        testProductDetail.variationInfo.variationAttributeInfo = new Map<String, ConnectApi.ProductAttributeInfo>{
            'Color' => productAttributeInfo
        };

        // Mock product category path
        ConnectApi.ProductCategoryData categoryData = new ConnectApi.ProductCategoryData();
        categoryData.id = testProductCategory.Id;
        categoryData.name = 'Category 1';
        categoryData.description = 'Test Category';
        categoryData.urlName = 'category-1';
        ConnectApi.ProductCategoryPath categoryPath = new ConnectApi.ProductCategoryPath();
        categoryPath.path = new List<ConnectApi.ProductCategoryData>{ categoryData };
        testProductDetail.primaryProductCategoryPath = categoryPath;

        return testProductDetail;
    }

    public static ConnectApi.ProductOverviewCollection createMockProductOverviewCollection(List<Id> productIds){
        Date currentDate = Date.today();
        ConnectApi.ProductOverviewCollection testProductOverviewCollection = new ConnectApi.ProductOverviewCollection();
        ConnectApi.ProductOverview testProductDetail = new ConnectApi.ProductOverview();
        testProductDetail.id = productIds[0];
        // Mock default image
        Id defauImageId = SIB_TestDataFactory.getMockId(ProductMedia.SObjectType) ;  
        ConnectApi.ProductMedia defaultImage = new ConnectApi.ProductMedia();
        defaultImage.id = defauImageId;
        defaultImage.title = 'Default Image';
        defaultImage.mediaType = ConnectApi.ProductMediaType.Image;
        defaultImage.alternateText = 'Alternate Text';
        defaultImage.url = 'https://example.com/defaultImage.jpg';
        testProductDetail.defaultImage = defaultImage;
        testProductDetail.fields = new Map<String, String>{
            'Name' => 'Test Product ' +  productIds[0],
            'StockKeepingUnit' => 'SKU' +  productIds[0],
            'ProductCode' => 'PCode' + productIds[0],
            'ProductClass' => 'ClassA',
            'Type' => 'Physical',
            'Description' => 'Test description',
            'SIB_Whats_Included__c' => 'Test long description',
            'SIB_Is_Course__c' => 'true',
            'SIB_Most_Popular__c' => 'false',
            'Product_Group__c' => 'Private Course',
            'Early_Bird_Deadline_formula__c' => '2024-10-21T12:00:00Z',
            'Full_Registration_Cost_formula__c'=> '150.00',
            'Early_Bird_Registration_Cost_formula__c' => '120.00'
        };
        testProductDetail.success = true;
        DateTime earlyBirdDeadline =  DateTime.newInstance(currentDate.addDays(10), Time.newInstance(12, 0, 0, 0));

        String formattedDeadline = earlyBirdDeadline.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        ConnectApi.ProductOverview testProductDetail2 = new ConnectApi.ProductOverview();
        testProductDetail2.id = productIds[1];
        testProductDetail2.defaultImage = defaultImage;
        testProductDetail2.fields = new Map<String, String>{
            'Name' => 'Test Product ' + productIds[1],
            'StockKeepingUnit' => 'SKU' + productIds[1],
            'ProductCode' => 'PCode' + productIds[1],
            'ProductClass' => 'ClassA',
            'Type' => 'Physical',
            'Description' => 'Test description',
            'SIB_Whats_Included__c' => 'Test long description',
            'SIB_Is_Course__c' => 'true',
            'SIB_Most_Popular__c' => 'false',
            'Product_Group__c' => 'Private Course',
            'Early_Bird_Deadline_formula__c' => formattedDeadline,
            'Full_Registration_Cost_formula__c'=> '150.00',
            'Early_Bird_Registration_Cost_formula__c' => '500.00'
        };
        testProductDetail2.success = true;

        testProductOverviewCollection.products = new List<ConnectApi.ProductOverview>{ testProductDetail,testProductDetail2 };
        testProductOverviewCollection.total = 2;
        return testProductOverviewCollection;        
    }

    public static  ConnectApi.PricingResult testPricingResultMockData(List<Id> productIds) {
        ConnectApi.PricingResult pricingResult = new ConnectApi.PricingResult();
        
        pricingResult.currencyIsoCode = 'USD';
        pricingResult.success = true;
        
        Id pbeId = getMockId(PricebookEntry.SObjectType);
        ConnectApi.PricingResultLineItem pricingResultItem = new ConnectApi.PricingResultLineItem();
        pricingResultItem.productId = productIds[0];
        pricingResultItem.listPrice = '150.00';
        pricingResultItem.unitPrice = '200.00';
        pricingResultItem.pricebookEntryId = pbeId;

        ConnectApi.PricingResultLineItem pricingResultItem2 = new ConnectApi.PricingResultLineItem();
        pricingResultItem2.productId = productIds[1];
        pricingResultItem2.listPrice = '150.00';
        pricingResultItem2.unitPrice = '200.00';
        pricingResultItem2.pricebookEntryId =pbeId;
        
        pricingResult.pricingLineItemResults = new List<ConnectApi.PricingResultLineItem>{pricingResultItem,pricingResultItem2};
        return pricingResult;
    }
 }