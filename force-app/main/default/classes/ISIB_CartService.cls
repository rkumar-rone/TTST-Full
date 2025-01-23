/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : Gaurav Setia
**/
public interface ISIB_CartService {
    
    SIB_CartResponse getCartSummary(SIB_CartRequest cartRequest);

    SIB_CartResponse getCartItems(SIB_CartRequest cartRequest);

    SIB_CartResponse addToCart(SIB_CartRequest cartRequest);

    SIB_CartResponse removeCartItem(SIB_CartRequest cartRequest);

    SIB_CartResponse clearCart(SIB_CartRequest cartRequest);

    SIB_CartResponse updateCartItem(SIB_CartRequest cartRequest);

    SIB_CartResponse repriceCart(SIB_CartRequest cartRequest);

    SIB_CartResponse applyCoupon(SIB_CartRequest cartRequest);

    SIB_CartResponse getCartCoupons(SIB_CartRequest cartRequest);

    SIB_CartResponse createCart(SIB_CartRequest cartRequest);
}