@isTest
public class TTSEventScheduleTriggerHandlerTest {
    @isTest 
    static void testTriggerHandler() {
        // Instantiate the class
        TTSEventScheduleTriggerHandler handler = new TTSEventScheduleTriggerHandler();

        // Test the static variables
        System.assertEquals(false, TTSEventScheduleTriggerHandler.isUpdateTriggerExecuted);
        System.assertEquals(false, TTSEventScheduleTriggerHandler.isInsertTriggerExecuted);

        // Modify the static variables
        TTSEventScheduleTriggerHandler.isUpdateTriggerExecuted = true;
        TTSEventScheduleTriggerHandler.isInsertTriggerExecuted = true;

        // Verify the changes
        System.assertEquals(true, TTSEventScheduleTriggerHandler.isUpdateTriggerExecuted);
        System.assertEquals(true, TTSEventScheduleTriggerHandler.isInsertTriggerExecuted);
    }
}