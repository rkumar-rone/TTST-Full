public interface ISIB_PricingService {

    SIB_ProductPricing getProductPricing(SIB_ProductRequest productRequest);

    // Map<Id,SIB_ProductPricing> getProductsPricing(SIB_ProductRequest productRequest);

    SIB_ProductPricing transformData(Object data);
}