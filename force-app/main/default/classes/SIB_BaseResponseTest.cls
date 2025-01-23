/**
 * @description       : Test class for SIB_BaseResponse
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_BaseResponseTest {
    
    @isTest
    public static void testSIBBaseResponseTest() {

        SIB_BaseResponse baseResponse = new SIB_BaseResponse();
        
        baseResponse.isSuccess = true;
        baseResponse.message = 'Test';
        System.assertEquals(true,  baseResponse.isSuccess, 'Passed');
    }
}