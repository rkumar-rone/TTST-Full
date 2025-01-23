/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : Gaurav Setia
**/
public interface ISIB_RelatedProductService {

    Map<String, List<SIB_RelatedProduct>> getRelatedProducts(SIB_ProductRequest productRequest);

    Map<Id, SIB_ProductDetail> getProductDetail(SIB_ProductRequest productRequest);

    Map<Id, SIB_ProductPricing> getProductPricing(SIB_ProductRequest productRequest);
}