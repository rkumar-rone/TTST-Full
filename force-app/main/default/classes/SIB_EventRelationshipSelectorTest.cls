/**
 * @description       : Test class for SIB_EventRelationshipSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_EventRelationshipSelectorTest {
    @isTest
    static void testGetEventRelationshipsByEventIds(){
        Test.startTest();
        List<Sobject> result = SIB_EventRelationshipSelector.getEventRelationshipsByEventIds(new List<String>{});
        System.assertEquals(null, result,'Passed');        
        Test.stopTest();
    }
}