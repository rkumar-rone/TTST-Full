/**
 * @description       : Test class for  SIB_Constants
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_ConstantsTest {
    @isTest
    static void testSIBConstants() {
        SIB_Constants test = new SIB_Constants();
        System.assertEquals('CDI', SIB_Constants.STOREFRONT_NAME, 'Passed');
    }
}