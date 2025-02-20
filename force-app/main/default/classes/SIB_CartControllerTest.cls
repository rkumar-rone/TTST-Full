/**
 * @description       : Test class for SIB_CartController
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-01-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CartControllerTest {

    @isTest
    public static void testSIBCartControllerSuccess() {
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('cartId', '12345');

        Test.startTest();
        Map<String, Object> result = SIB_CartController.getCartConfiguration(mapParams);
        Map<String, Object> resulGetCartDetails = SIB_CartController.getCartDetails(mapParams);
        Map<String, Object> resultUpdateCartItem = SIB_CartController.updateCartItem(mapParams);
        Map<String, Object> resultActivateCart = SIB_CartController.activateCart(mapParams);
        Map<String, Object> resultAddCartItem = SIB_CartController.addCartItem(mapParams);
        Map<String, Object> resultCalculateCart = SIB_CartController.calculateCart(mapParams);
        Map<String, Object> resultCompareCurrency = SIB_CartController.compareCurrency(mapParams);
        Map<String, Object> resultPreserveGuestCart = SIB_CartController.preserveGuestCart(mapParams);
        Map<String, Object> resultClearCart = SIB_CartController.clearCart(mapParams);
        Map<String, Object> resultDeleteCartItem = SIB_CartController.deleteCartItem(mapParams);
        Map<String, Object> checkCollevaProductExistOnCart = SIB_CartController.checkCollevaProductExistOnCart(mapParams);
        
        Test.stopTest();
        System.assertNotEquals(null, result, 'Passed');
    }

    @isTest
    public static void testSIBCartControllerException() {
        Test.startTest();
        Map<String, Object> result = SIB_CartController.getCartConfiguration(null);
        Map<String, Object> resulGetCartDetails = SIB_CartController.getCartDetails(null);
        Map<String, Object> resultUpdateCartItem = SIB_CartController.updateCartItem(null);
        Map<String, Object> resultActivateCart = SIB_CartController.activateCart(null);
        Map<String, Object> resultAddCartItem = SIB_CartController.addCartItem(null);
        Map<String, Object> resultCalculateCart = SIB_CartController.calculateCart(null);
        Map<String, Object> resultCompareCurrency = SIB_CartController.compareCurrency(null);
        Map<String, Object> resultPreserveGuestCart = SIB_CartController.preserveGuestCart(null);
        Map<String, Object> resultClearCart = SIB_CartController.clearCart(null);
        Map<String, Object> resultDeleteCartItem = SIB_CartController.deleteCartItem(null);
        Test.stopTest();

        System.assertEquals(false, result.get(SIB_Constants.IS_SUCCESS), 'Passed');
    }
}