/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  : 
**/
@isTest
public class SIB_ProductPricingTest {
	@isTest
    static void test(){
        SIB_ProductPricing pricing = new SIB_ProductPricing();
        pricing.pricebookId = '000000000000000AAA';
        pricing.pricebookEntryId = '000000000000000AAA';
        pricing.productId = '000000000000000AAA';
        pricing.unitPrice = 5;
        pricing.listPrice = 5;
        pricing.negotiatedPrice = 5;
        pricing.negotiatedPriceDiscount = 5;
        pricing.negotiatedPriceDiscountPercent = '5';
        pricing.currencyCode = 'USD';
        SIB_ProductPricing.PriceAdjustmentTiers pat = new SIB_ProductPricing.PriceAdjustmentTiers();
        pat.adjustmentId = '000000000000000AAA';
        pat.adjustmentType = 'test';
        pat.adjustmentValue = 5;
        pat.lowerBound = 5;
        pat.upperBound = 5;
        pat.tierUnitPrice = 5;
        pricing.priceAdjustmentTiers = new List<SIB_ProductPricing.PriceAdjustmentTiers>{pat};
        pricing.displayPrice = 'test';
        pricing.earlyBirdSessionPrice = 5;
        pricing.earlyBirdRegistrationCost = 5;
        pricing.fullRegistrationCost = 5;
        pricing.priceLabel = 'test';
    }
}