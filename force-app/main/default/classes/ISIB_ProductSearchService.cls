public interface ISIB_ProductSearchService {
    
    SIB_ProductSearchResponse searchProducts(SIB_ProductSearchRequest productSearchRequest);

    SIB_ProductSearchResponse transformData(Object data);
}