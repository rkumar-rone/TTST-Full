/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-30-2024
 * @last modified by  : Gaurav Setia
**/
public without sharing class SIB_TaxCartCalculatorExtension extends CartExtension.TaxCartCalculator {

    // You MUST change this to be your service or you must launch your own Third Party Service
    // and add the host in Setup | Security | Remote site settings.

    private static final String CLASSNAME = 'SIB_TaxCartCalculatorExtension';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Tax Module';

    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request) {
        String methodName = 'calculate';
        String supportData = '';
        try
        {
            System.debug('>System.Limits.getDmlRows()>>>>>>>>'+System.Limits.getDmlRows());
            System.debug('>System.Limits.getDmlRows()>>>>>>>>'+System.Limits.getDmlStatements());
            System.debug('>System.Limits.getDmlRows()>>>>>>>>'+System.Limits.getSavepoints());
            CartExtension.Cart cartExtensionObject = request.getCart();
            existingCartValidationMessageCleanUp(cartExtensionObject);
            existingCartTaxesCleanUp(cartExtensionObject);
            String accountName;
            Boolean isCartBillingAddressExist;
            List<CartItem> lstCartItems = SIB_CartItemSelector.getCartItemsByCartIds(new List<Id>{cartExtensionObject.getId()});
            WebCart webCart = [SELECT Account.Name, BillingAddress FROM WebCart WHERE Id = :cartExtensionObject.getId() LIMIT 1];
            System.debug('webCart : '+JSON.serialize(webCart));
            if(lstCartItems != null && lstCartItems.size()>0)
            {
                for(CartItem cartItemObject : lstCartItems)
                {
                    if(cartItemObject.CartDeliveryGroup!=null && String.isNotBlank(cartItemObject.CartDeliveryGroup.DeliverToStreet) &&
                            String.isNotBlank(cartItemObject.CartDeliveryGroup.DeliverToCity) &&
                            String.isNotBlank(cartItemObject.CartDeliveryGroup.DeliverToCountry))
                    {
                        isCartBillingAddressExist = true;
                        break;
                    }
                }
                accountName = webCart.Account.Name;
                //isCartBillingAddressExist = webCart.BillingAddress != null ? true : false;
            }
            System.debug('>>>isCartBillingAddressExist>>>>>>>'+isCartBillingAddressExist);
            if(isCartBillingAddressExist == true)
            {
                // Get the tax rates and tax amounts from an external service
                Map<String, TaxDataFromExternalService> rateAndAmountFromExternalServicePerSku =
                        getTaxRatesAndAmountsFromExternalService(cartExtensionObject, accountName, cartExtensionObject.getCurrencyIsoCode());
                CartExtension.CartItemList cartItems = cartExtensionObject.getCartItems();
                for (Integer i = (cartItems.size() - 1); i >= 0; i--)
                {
                    CartExtension.CartItem cartItem = cartItems.get(i);
                    TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(cartItem.getSku());
                    if (rateAndAmountFromExternalService != null)
                    {
                        CartExtension.CartTaxList cartTaxCollection = cartItem.getCartTaxes();
                        CartExtension.CartTax cartTaxObject = new CartExtension.CartTax(
                                CartExtension.TaxTypeEnum.ESTIMATED ,
                                rateAndAmountFromExternalService.getAmount(),
                                rateAndAmountFromExternalService.getTaxName()
                        );
                        cartTaxObject.setTaxRate(String.valueOf(rateAndAmountFromExternalService.getRate()));
                        cartTaxCollection.add(cartTaxObject);
                    }
                }
            }
        } catch (Exception expObject) {
            System.debug('Exception caught:'+expObject.getMessage());
            //Logger.error('Exception caught: ' + e.getMessage(), 'ExceptionCaught');
            // For testing purposes, this example treats exceptions as user errors, which means they are
            // displayed to the buyer user. In production, you probably want exceptions to be admin-type
            // errors. In that case, throw the exception here and make sure that a notification system is
            // in place to let the admin know that the error occurred. See the README section about error
            // handling for details about how to create that notification.
            //throw new CalloutException('There was a problem with the request.');
            // Populating Custom Error Message
            setErrorInCart(request.getCart(), System.Label.SIB_TaxErrorMessageForCustomer);
            // SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            //Logger.saveLog();
        }
        return;
    }

    @TestVisible
    private virtual void setErrorInCart(CartExtension.Cart cart, String errorMessage) {
        CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
                CartExtension.CartValidationOutputTypeEnum.TAXES,
                CartExtension.CartValidationOutputLevelEnum.ERROR
        );
        cvo.setMessage(errorMessage);
        CartExtension.CartValidationOutputList cartValidationOutputList = cart.getCartValidationOutputs();
        cartValidationOutputList.add(cvo);
    }

    @TestVisible
    private virtual void existingCartTaxesCleanUp(CartExtension.Cart cart) {
        //Logger.debug('Starting cleanup of existing cart taxes and price adjustments for cart ID: ' + cart.getId(), 'TaxesCleanupStart');
        CartExtension.CartItemList cartItemCollection = cart.getCartItems();
        if(cartItemCollection != null) {
            for (Integer i = (cartItemCollection?.size() - 1); i >= 0; i--)
            {
                CartExtension.CartItem cartItem = cartItemCollection.get(i);
                if (cartItem != null && cartItem?.getCartTaxes() != null && cartItem?.getCartTaxes()?.size() > 0)
                {
                    for (Integer j = (cartItem?.getCartTaxes()?.size() - 1); j >= 0; j--)
                    {
                        cartItem.getCartTaxes().remove(cartItem.getCartTaxes().get(j));
                    }
                }
                if ( cartItem != null && cartItem?.getCartItemPriceAdjustments() != null && cartItem?.getCartItemPriceAdjustments()?.size() > 0)
                {
                    for(Integer k = (cartItem?.getCartItemPriceAdjustments()?.size() - 1);
                            k >= 0;
                            k--)
                    {
                        CartExtension.CartTaxList cipaTaxes = cartItem?.getCartItemPriceAdjustments()?.get(k)?.getCartTaxes();
                        if (cipaTaxes != null && cipaTaxes?.size() > 0)
                        {
                            for (Integer l = (cartItem?.getCartItemPriceAdjustments()?.size() - 1); l >= 0; l--)
                            {
                                cipaTaxes.remove(cipaTaxes.get(l));
                            }
                        }
                    }
                }
            }
        }

        //Logger.debug('Completed cleanup of existing cart taxes and price adjustments for cart ID: ' + cart.getId(), 'TaxesCleanupCompleted');
        // Logger.saveLog();
    }

    @TestVisible
    private virtual void existingCartValidationMessageCleanUp(CartExtension.Cart cart) {
        //Logger.debug('Starting cleanup of existing cart validation messages for cart ID: ' + cart.getId(), 'ValidationMessagesCleanupStart');
        CartExtension.CartValidationOutputList cartValidationOutputCollection = cart.getCartValidationOutputs();
        for (Integer i = (cartValidationOutputCollection.size() - 1); i >= 0; i--)
        {
            CartExtension.CartValidationOutput cvo = cartValidationOutputCollection.get(i);
            if(cvo.getType() == CartExtension.CartValidationOutputTypeEnum.TAXES)
            {
                cartValidationOutputCollection.remove(cvo);
            }
        }
        //Logger.debug('Completed cleanup of existing cart validation messages for cart ID: ' + cart.getId(), 'ValidationMessagesCleanupCompleted');
        // Logger.saveLog();
    }

    @TestVisible
    private static Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService(CartExtension.Cart cartExtensionObject, String accName, String currencyCode) {
        Decimal TaxAmount = 0.0;
        String docCode = cartExtensionObject.getId();
        Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
        Map<String,B2BAvalaraTaxModel > mapAvaTaxModel  = B2BAvalaraTaxUtil.calculateTaxes(cartExtensionObject, docCode, accName, currencyCode, SIB_Constants.TAX_TYPE_SALESORDER);
        for (String sku : mapAvaTaxModel.keySet())
        {
            System.debug('>>>>mapAvaTaxModel.get(sku).tax rate>>>>>>'+mapAvaTaxModel.get(sku).taxRate);
            System.debug('>>>>>mapAvaTaxModel.get(sku).taxAmount>>>>>'+mapAvaTaxModel.get(sku).taxAmount);
            taxDataFromExternalServiceBySKU.put(sku, new TaxDataFromExternalService(mapAvaTaxModel.get(sku).taxRate, mapAvaTaxModel.get(sku).taxAmount,
                    SIB_Constants.CART_TAX_NAME+sku));
        }
        return taxDataFromExternalServiceBySKU;
    }

    // Structure to store the tax data retrieved from external service
    // This simplifies our ability to access it when storing it in Salesforce's CartTax entity
    class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;
        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }
        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }
        public Decimal getRate() {
            return rate;
        }
        public Decimal getAmount() {
            return amount;
        }
        public String getTaxName() {
            return taxName;
        }
    }
}