/**
 * @description       : 
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_B2BPricingServiceTest {

    @isTest
    static void testGetProductPricing() {

        Map<String,Product2> createProducts = SIB_TestDataFactory.createProducts(true);
        Pricebook2  testPricebook= SIB_TestDataFactory.createCommercePricebook2('testPricebook',true);
        Id productId = createProducts.get('74CBTLV1G125DBVRQ1').Id;
        SIB_ProductRequest productRequest = new SIB_ProductRequest(productId, true, true);

        Test.startTest();
        
        ConnectApi.ProductPrice mockProductPrice = new ConnectApi.ProductPrice();
        mockProductPrice.currencyIsoCode = 'USD';
        mockProductPrice.pricebookEntryId = testPricebook.Id;
        mockProductPrice.unitPrice = '100.0';
        mockProductPrice.listPrice = '120.0';

        ConnectApi.PriceAdjustmentTier priceTier = new ConnectApi.PriceAdjustmentTier();
        priceTier.adjustmentType = ConnectApi.PriceAdjustmentTierType.PercentageBasedAdjustment;
        priceTier.adjustmentValue = '10.0';
        priceTier.lowerBound = '1';
        priceTier.upperBound = '100';
        priceTier.tierUnitPrice = '90.0';
        mockProductPrice.priceAdjustment = new ConnectApi.PriceAdjustmentSchedule();
        mockProductPrice.priceAdjustment.priceAdjustmentTiers = new List<ConnectApi.PriceAdjustmentTier> { priceTier };
        
        SIB_B2BPricingService pricingService = new SIB_B2BPricingService();

        SIB_ProductPricing result = pricingService.getProductPricing(productRequest);
        SIB_ProductPricing transfromDataResult = pricingService.transformData(mockProductPrice);

        mockProductPrice.unitPrice = '120.0';
        mockProductPrice.listPrice = '100.0';

        SIB_ProductPricing transfromDataPriceResult = pricingService.transformData(mockProductPrice);

        Test.stopTest();
        System.assertEquals('USD', transfromDataResult.currencyCode, 'Pass');
    }
    
}