/**
 * @description       : Test class for SIB_CartResponse
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CartResponseTest {

    @isTest
    public static void testSIBCartResponse() {
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        
        cartResponse.cartId = 'testCartId123';
        cartResponse.status = 'Success';
        cartResponse.grandTotalAmount = 150.00;
        cartResponse.totalProductAmount = 120.00;
        cartResponse.shippingAmount = 20.00;
        cartResponse.taxAmount = 5.00;
        cartResponse.discountAmount = 10.00;
        cartResponse.uniqueProductCount = 3;
        cartResponse.currencyIsoCode = 'USD';
        cartResponse.isSuccess = true;
        cartResponse.isLocked = false;
        cartResponse.totalProductAmountAfterAdjustments = 110.00;
        cartResponse.isGroupOrder = false;

        SIB_CartResponse.SIB_CartItemResponse cartItem1 = new SIB_CartResponse.SIB_CartItemResponse();
        cartItem1.itemId = 'itemId123';
        cartItem1.productId = 'prodId123';
        cartItem1.quantity = 2;
        cartItem1.unitPrice = 49.99;
        cartItem1.listPrice = 54.99;
        cartItem1.totalPrice = 99.98;
        cartItem1.type = 'Physical';
        cartItem1.currencyIsoCode = 'USD';
        cartItem1.totalDiscount = 10.00;
        cartItem1.productDetail = new SIB_ProductDetail(); 
        
        cartResponse.cartItems = new List<SIB_CartResponse.SIB_CartItemResponse>{ cartItem1 };
        cartResponse.succeededCartItems = new List<ConnectApi.CartItemBasicResult>();
        cartResponse.failedCartItems = new List<ConnectApi.CartItemBasicResult>();
        System.assertEquals('testCartId123', cartResponse.cartId, 'Cart ID should be set correctly');
    }
}