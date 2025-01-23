public with sharing class B2BAvalaraTaxCallout {
    @InvocableMethod(label='Callout to Avalara' description='Creates a Transaction in the Avalara' category='OrderSummary')
    public static void makeCallout(List<ID> ids) {
        List<OrderSummary> orderSummaries = [
            SELECT Id, OriginalOrder.OrderNumber, Account.Name, OriginalOrder.CartId__c, TotalTaxAmount, CurrencyIsoCode 
            FROM OrderSummary 
            WHERE Id IN :ids
        ];

        if(!orderSummaries.isEmpty())
        {
            for(OrderSummary os : orderSummaries) {
                try {
                    // Perform the Avalara tax calculation
                    Map<String, B2BAvalaraTaxModel> taxResult = B2BAvalaraTaxUtil.calculateTax(
                        os.OriginalOrder.CartId__c,                     // cartId
                        os.OriginalOrder.OrderNumber,                   // docCode
                        os.Account.Name,                                // accName
                        os.CurrencyIsoCode,                             // currencyCode
                        SIB_Constants.TAX_TYPE_SALESINVOICE             // tax type
                    );
                } catch (Exception e) {
                    System.debug('Error processing Avalara callout for OrderSummary ID: ' + os.Id + ' - ' + e.getMessage());
                }
            }
        }
    }
}