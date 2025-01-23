/**
 * @description       : Test class for SIB_SetupConstants
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_SetupConstantsTest {
    @isTest
    static void testSIBConstants() {
        SIB_SetupConstants test = new SIB_SetupConstants();
        System.assertEquals('cart_encryptedId', SIB_SetupConstants.CART_ENCRYPTED_ID, 'CART_ENCRYPTED_ID constant value mismatch');
    }
}