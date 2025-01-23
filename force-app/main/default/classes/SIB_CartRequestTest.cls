/**
 * @description       : Test class for SIB_CartRequest
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CartRequestTest {

    @isTest
    public static void testSIBCartRequest() {
        SIB_CartRequest cartRequest = new SIB_CartRequest();
        
        cartRequest.cartId = 'testCartId123';
        cartRequest.couponCode = 'SAVE10';
        cartRequest.currencyIsoCode = 'USD';
        
        SIB_CartRequest.SIB_CartItemRequest cartItem = new SIB_CartRequest.SIB_CartItemRequest();
        cartItem.itemId = 'itemId123';
        cartItem.productId = 'prodId123';
        cartItem.quantity = 2;
        cartItem.unitPrice = 49.99;

        cartRequest.cartItems = new List<SIB_CartRequest.SIB_CartItemRequest>{ cartItem };
        System.assertEquals('testCartId123', cartRequest.cartId, 'Passed');
    }
}