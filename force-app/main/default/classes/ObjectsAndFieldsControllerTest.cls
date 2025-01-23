@isTest
public with sharing class ObjectsAndFieldsControllerTest {
    @isTest public static void testInitWithSearch(){
        Test.startTest();
            Map<String, String> result = ObjectsAndFieldsController.fetchAllObjectList();
        Test.stopTest();
        System.assert(!result.isEmpty());
    }

    @isTest public static void testFetchAllFieldList(){
        Test.startTest();
            Map<String, String> result = ObjectsAndFieldsController.fetchAllFieldList('Contact');
        Test.stopTest();
        System.assert(!result.isEmpty());
    }
}