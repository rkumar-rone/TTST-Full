/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : Gaurav Setia
**/
public interface ISIB_ProductService {

    SIB_ProductDetail getProductDetail(SIB_ProductRequest productRequest);

    SIB_ProductDetail transformData(Object data);
}