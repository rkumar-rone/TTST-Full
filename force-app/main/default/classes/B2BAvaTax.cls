// This must implement the sfdc_checkout.CartTaxCalculations interface
// in order to be processed by the checkout flow and used for your Taxes integration.
global class B2BAvaTax implements sfdc_checkout.CartTaxCalculations {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            // In the Spring '20 release, there should be one delivery group per cart.
            // In the future, when multiple delivery groups can be created,
            // this sample should be updated to loop through all delivery groups.
            
            // Get all SKUs, the cart item IDs, and the total line amounts from the cart items.
            Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
            String accName;
            String currencyCode;

            List<CartItem> cartItems = [SELECT Id, Sku, Cart.Account.Name, Cart.CurrencyIsoCode FROM CartItem WHERE CartId = :cartId AND Type = 'Product'];

            for (CartItem cartItem : cartItems) {
                // Populate the maps with cart item details
                cartItemIdsBySKU.put(cartItem.Sku, cartItem.Id);
                accName = cartItem.Cart.Account.Name;
                currencyCode = cartItem.Cart.CurrencyIsoCode;
            }
            
            // Get the tax rates and tax amounts from an external service
            // Other parameters will be passed here, like ship_from, bill_to, more details about the ship_to, etc.
            Map<String, TaxDataFromExternalService> rateAndAmountFromExternalServicePerSku = getTaxRatesAndAmountsFromExternalService(cartId, accName, currencyCode);
            
            
            // If there are taxes from a previously cancelled checkout, delete them.
            List<Id> cartItemIds = cartItemIdsBySKU.values();
            delete [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            
            CartTax[] cartTaxestoInsert = new CartTax[]{};
            
            for (String sku : cartItemIdsBySKU.keySet()) {
                TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(sku);
                
                // If the sku was found in the external system, add a new CartTax line for that sku
                // The following fields from CartTax can be filled in:
                // Amount (required): Calculated tax amount.
                // CartItemId (required): ID of the cart item.
                // Description (optional): Description of CartTax.
                // Name (required): Name of the tax.
                // TaxCalculationDate (required): Calculation date for this tax line.
                // TaxRate (optional): The percentage value of the tax. Null if the tax is a flat amount.
                // TaxType (required): The type of tax, e.g. Actual or Estimated.
                CartTax tax = new CartTax( 
                    Amount = rateAndAmountFromExternalService.getAmount(),
                    CartItemId = cartItemIdsBySKU.get(sku),
                    Name = rateAndAmountFromExternalService.getTaxName(),
                    TaxCalculationDate = Date.today(),
                    TaxRate = rateAndAmountFromExternalService.getRate(),
                    TaxType = 'Actual'
                );
                cartTaxestoInsert.add(tax);
            }
            insert(cartTaxestoInsert);
            
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }
    
    private Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService (String cartId, String accName, String currencyCode) {
           
            Decimal TaxAmount = 0.0;
            String docCode = cartId;
            
            Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
                    
            Map<String,B2BAvalaraTaxModel > mapAvaTaxModel  = B2BAvalaraTaxUtil.calculateTax(cartId, docCode, accName, currencyCode, 'SalesOrder');
            System.debug('tax ' +mapAvaTaxModel);
                
            for (String sku : mapAvaTaxModel.keySet()) {
                
                taxDataFromExternalServiceBySKU.put(sku, new TaxDataFromExternalService(
                    mapAvaTaxModel.get(sku).taxrate,
                    mapAvaTaxModel.get(sku).taxAmount,
                    'Avalara Tax - '+sku
                ));
            }
            return taxDataFromExternalServiceBySKU;
    }
    
    // Structure to store the tax data retrieved from external service
    // This simplifies our ability to access it when storing it in Salesforce's CartTax entity
    Class TaxDataFromExternalService {
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
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // For the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user (maximum 255 characters)
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Taxes'
            );
            insert(cartValidationError);
            return integrationStatus;
    }
}