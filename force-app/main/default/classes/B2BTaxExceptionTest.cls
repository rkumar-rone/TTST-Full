@IsTest
public class B2BTaxExceptionTest {
	@IsTest
    static void testException() {
        //Given
        Boolean exFlag = false;
 
        //When
        Test.startTest();
        try {
            throw new B2BTaxException();
        } catch (Exception e) {
            exFlag = true;
        }
 
        Test.stopTest();
 
        //Then
        System.assert(exFlag);
    }
}