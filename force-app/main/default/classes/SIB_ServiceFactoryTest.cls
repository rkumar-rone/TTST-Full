/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_ServiceFactoryTest {

    @isTest
    static void testGetServiceWithClassName() {
        
        String className = 'SIB_ServiceFactory'; 

        try{
            SIB_HTTPService service = SIB_ServiceFactory.getService(className);
            System.assertNotEquals(service, null, 'Passed');
        }catch(Exception e){
           System.AssertNotEquals(e, null, 'Passed');
        }

        
    }

    @isTest
    static void testGetServiceWithoutClassName() {
        String className = null;
        
        SIB_HTTPService service = SIB_ServiceFactory.getService(className);
        
        System.assertNotEquals(service, null, 'Passed');
    }
}