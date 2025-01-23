public with sharing class B2BAvaTaxProvider {

    private static final String CLASSNAME = 'B2BAvaTaxProvider';

    public static String getTaxServiceRequestBody(String cartId, String docCode, B2B_AvalaraTaxSettings__mdt avalaraTaxSettings, String accName, String currencyCode, String taxTransacionType) {
  
        B2BAvaTaxRequest avalaraRequest = new B2BAvaTaxRequest();
        avalaraRequest.type = taxTransacionType;
        avalaraRequest.currencyCode = currencyCode;

        //Tranaction will be Committed only after Order Summary Status is Completed
        if (String.isNotBlank(taxTransacionType) && taxTransacionType == SIB_Constants.TAX_TYPE_SALESINVOICE) {
            avalaraRequest.commit_Z = true;
        }else {
            avalaraRequest.commit_Z = false;
        }

        if (String.isNotBlank(docCode)) {
            avalaraRequest.code = docCode;
        }
    
        if (String.isNotBlank(avalaraTaxSettings.CompanyCode__c)) {
            avalaraRequest.companyCode = avalaraTaxSettings.CompanyCode__c;
        }
    
        if (String.isNotBlank(accName)) {
            avalaraRequest.customerCode = accName;
        } else {
            avalaraRequest.customerCode = avalaraTaxSettings.CustomerCode__c;
        }
    
        avalaraRequest.date_Z = System.now() + '';

        avalaraRequest.lines = prepareRequestFromDB(cartId, avalaraTaxSettings);
      
        String avalaraRequestBody = JSON.serialize(avalaraRequest, true);
        avalaraRequestBody = avalaraRequestBody.replaceAll('_Z', '');
        return avalaraRequestBody;
    }


    public static String generateTaxServiceRequestBody(CartExtension.Cart cartExtensionObject , String docCode, B2B_AvalaraTaxSettings__mdt avalaraTaxSettings, String accName, String currencyCode, String taxTransacionType) {
        B2BAvaTaxRequest avalaraRequest = new B2BAvaTaxRequest();
        avalaraRequest.type = taxTransacionType;
        avalaraRequest.currencyCode = currencyCode;
        //Tranaction will be Committed only after Order Summary Status is Completed
        if (String.isNotBlank(taxTransacionType) && taxTransacionType == SIB_Constants.TAX_TYPE_SALESINVOICE)
        {
            avalaraRequest.commit_Z = true;
        }else
        {
            avalaraRequest.commit_Z = false;
        }
        if (String.isNotBlank(docCode))
        {
            avalaraRequest.code = docCode;
        }
        if (String.isNotBlank(avalaraTaxSettings.CompanyCode__c))
        {
            avalaraRequest.companyCode = avalaraTaxSettings.CompanyCode__c;
        }
        if (String.isNotBlank(accName))
        {
            avalaraRequest.customerCode = accName;
        }
        else
        {
            avalaraRequest.customerCode = avalaraTaxSettings.CustomerCode__c;
        }
        avalaraRequest.date_Z = System.now() + '';
        avalaraRequest.lines = prepareRequestFromCartExtension(cartExtensionObject, avalaraTaxSettings);
        String avalaraRequestBody = JSON.serialize(avalaraRequest, true);
        avalaraRequestBody = avalaraRequestBody.replaceAll('_Z', '');
        return avalaraRequestBody;
    }


    private static List<B2BAvaTaxRequest.Lines> prepareRequestFromCartExtension(CartExtension.Cart cartExtensionObject , B2B_AvalaraTaxSettings__mdt avalaraTaxSettings) {
        String methodName = 'prepareRequestFromCartExtension';
        List<B2BAvaTaxRequest.Lines> lines = new List<B2BAvaTaxRequest.Lines>();
        List<CartItem> cartItems = new List<CartItem>();
        cartItems = (List<CartItem>)SIB_CartItemSelector.getCartItemsByCartIds(new List<Id>{cartExtensionObject.getId()});
        Map<String, CartExtension.CartItem> mapCartItemExtensionById = new Map<String, CartExtension.CartItem>();
        CartExtension.CartItemList cartItemsTemp = cartExtensionObject.getCartItems();
        Iterator<CartExtension.CartItem> cartItemIterator = cartItemsTemp.iterator();
        SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Started');
        SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Request Param');
        while(cartItemIterator.hasNext())
        {
            CartExtension.CartItem cartItemExtensionObject = cartItemIterator.next();
            System.debug('CartExtension.CartItem : '+cartItemExtensionObject.getTotalPriceAfterAllAdjustments());
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Cart Item Product : ' + cartItemExtensionObject.getProduct2Id() + ' : ' +cartItemExtensionObject.getSku());
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Total Price After All Adjustment : ' + cartItemExtensionObject.getTotalPriceAfterAllAdjustments());
            mapCartItemExtensionById.put(cartItemExtensionObject.getId() , cartItemExtensionObject);
        }
        SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Total Product Price : ' + cartExtensionObject.getTotalProductAmount());
        SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Total Cart Discount : ' + cartExtensionObject.getTotalPromoAdjustmentAmount());
        SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Total Cart Price : ' + cartExtensionObject.getTotalAmountAfterAllAdjustments());
        CartExtension.CartItem cartItemExtObject;
        Decimal cartItemTotalAdjustment;
        for (CartItem cartItem : cartItems)
        {
            cartItemExtObject = null;
            cartItemTotalAdjustment = null;
            if(cartItem.Type == SIB_Constants.CARTITEM_TYPE)
            {
                cartItemTotalAdjustment = cartItem.TotalPriceAfterAllAdjustments;
                B2BAvaTaxRequest.Lines line = new B2BAvaTaxRequest.Lines();
                B2BAvaTaxRequest.Addresses addresses = new B2BAvaTaxRequest.Addresses();
                SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Cart Billing Address : '
                        + cartItem.CartDeliveryGroup.DeliverToStreet  + ', ' + cartItem.CartDeliveryGroup.DeliverToCity +
                        ', ' + cartItem.CartDeliveryGroup.DeliverToState + ', ' + cartItem.CartDeliveryGroup.DeliverToPostalCode +
                        ', ' + cartItem.CartDeliveryGroup.DeliverToCountry);
                if(mapCartItemExtensionById.containsKey(cartItem.Id) && mapCartItemExtensionById.get(cartItem.Id)!=null)
                {
                    cartItemExtObject = mapCartItemExtensionById.get(cartItem.Id);
                    cartItemTotalAdjustment = cartItemExtObject.getTotalPriceAfterAllAdjustments();
                }
                // Determine the tax code and location based on product attributes
                if(cartItem.Product2.Delivery_Format__c == SIB_Constants.DELIVERY_FORMAT_IN_PERSON &&
                        (cartItem.Product2.Product_Group__c == SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE ||
                                cartItem.Product2.Product_Group__c == SIB_Constants.PRODUCT_GROUP_PRIVATE_COURSE))
                {
                    line = prepareLine(
                            cartItem.Sku !=null ? cartItem.Sku : cartItem.Product2.StockKeepingUnit,
                            cartItem.Product2.Name,
                            cartItem.Quantity,
                            cartItemTotalAdjustment ,
                            cartItem.Product2.In_Person_Tax_Code__c
                    );
                    addresses.shipTo = prepareShipToAddress(
                            cartItem.Product2.Training_Location_Street_formula__c,
                            cartItem.Product2.Training_Location_City_formula__c,
                            cartItem.Product2.Training_Location_State_formula__c,
                            cartItem.Product2.Training_Location_Zip_Code_formula__c,
                            cartItem.Product2.Training_Location_Country_formula__c
                    );
                } else
                {
                    line = prepareLine(
                            cartItem.Sku !=null ? cartItem.Sku : cartItem.Product2.StockKeepingUnit,
                            cartItem.Product2.Name,
                            cartItem.Quantity,
                            cartItemTotalAdjustment ,
                            cartItem.Product2.Virtual_Tax_Code__c
                    );
                    addresses.shipTo = prepareShipToAddress(
                            cartItem.CartDeliveryGroup.DeliverToStreet,
                            cartItem.CartDeliveryGroup.DeliverToCity,
                            cartItem.CartDeliveryGroup.DeliverToState,
                            cartItem.CartDeliveryGroup.DeliverToPostalCode,
                            cartItem.CartDeliveryGroup.DeliverToCountry
                    );
                }
                addresses.shipFrom = prepareShipFromAddress(avalaraTaxSettings);
                line.addresses = addresses;
                lines.add(line);
            }
        }
        return lines;
    }

    private static List<B2BAvaTaxRequest.Lines> prepareRequestFromDB(String cartId, B2B_AvalaraTaxSettings__mdt avalaraTaxSettings) {
        List<B2BAvaTaxRequest.Lines> lines = new List<B2BAvaTaxRequest.Lines>();
        List<CartItem> cartItems = new List<CartItem>();

        cartItems = (List<CartItem>)SIB_CartItemSelector.getCartItemsByCartIds(new List<Id>{cartId});

        for (CartItem cartItem : cartItems) {
            if(cartItem.Type == SIB_Constants.CARTITEM_TYPE) {
                B2BAvaTaxRequest.Lines line = new B2BAvaTaxRequest.Lines();
                B2BAvaTaxRequest.Addresses addresses = new B2BAvaTaxRequest.Addresses();

                // Determine the tax code and location based on product attributes
                if(cartItem.Product2.Delivery_Format__c == SIB_Constants.DELIVERY_FORMAT_IN_PERSON && (cartItem.Product2.Product_Group__c == SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE || cartItem.Product2.Product_Group__c == SIB_Constants.PRODUCT_GROUP_PRIVATE_COURSE)) {
                    line = prepareLine(
                        cartItem.Sku !=null ? cartItem.Sku : cartItem.Product2.StockKeepingUnit,
                        cartItem.Product2.Name,
                        cartItem.Quantity,
                        cartItem.TotalPriceAfterAllAdjustments,
                        cartItem.Product2.In_Person_Tax_Code__c
                    );

                    addresses.shipTo = prepareShipToAddress(
                        cartItem.Product2.Training_Location_Street_formula__c,
                        cartItem.Product2.Training_Location_City_formula__c,
                        cartItem.Product2.Training_Location_State_formula__c,
                        cartItem.Product2.Training_Location_Zip_Code_formula__c,
                        cartItem.Product2.Training_Location_Country_formula__c
                    );
                } else {
                    line = prepareLine(
                        cartItem.Sku !=null ? cartItem.Sku : cartItem.Product2.StockKeepingUnit,
                        cartItem.Product2.Name,
                        cartItem.Quantity,
                        cartItem.TotalPriceAfterAllAdjustments,
                        cartItem.Product2.Virtual_Tax_Code__c
                    );

                    addresses.shipTo = prepareShipToAddress(
                        cartItem.CartDeliveryGroup.DeliverToStreet,
                        cartItem.CartDeliveryGroup.DeliverToCity,
                        cartItem.CartDeliveryGroup.DeliverToState,
                        cartItem.CartDeliveryGroup.DeliverToPostalCode,
                        cartItem.CartDeliveryGroup.DeliverToCountry
                    );
                }

                addresses.shipFrom = prepareShipFromAddress(avalaraTaxSettings);
                line.addresses = addresses;
                
                lines.add(line);
            }
        }
        return lines;
    }
  
    private static B2BAvaTaxRequest.Lines prepareLine(
      String sku,
      String name,
      Decimal quantity,
      Decimal taxableAmount,
      String taxCode
    ) {
        B2BAvaTaxRequest.Lines line = new B2BAvaTaxRequest.Lines();
        line.itemCode = sku;
        line.description = name;
        line.quantity = quantity;
        line.amount = taxableAmount;
        line.taxCode = taxCode;
        return line;
    }

    private static B2BAvaTaxRequest.ShipFrom prepareShipFromAddress(B2B_AvalaraTaxSettings__mdt avalaraTaxSettings) {
        B2BAvaTaxRequest.ShipFrom address = new B2BAvaTaxRequest.ShipFrom();
    
        address.line1 = avalaraTaxSettings.Address_Line1__c;
        address.city = avalaraTaxSettings.City__c;
        address.region = avalaraTaxSettings.State__c;
        address.postalCode = avalaraTaxSettings.Zip_Code__c;
        address.country = avalaraTaxSettings.Country_Code__c;
        return address;
    }
  
    private static B2BAvaTaxRequest.ShipFrom prepareShipToAddress(
      String street,
      String city,
      String state,
      String postalCode,
      String country
    ) {
        B2BAvaTaxRequest.ShipFrom address = new B2BAvaTaxRequest.ShipFrom();
        address.line1 = street;
        address.city = city;
        address.region = state;
        address.postalCode = postalCode;
        address.country = country;
        return address;
    }
}