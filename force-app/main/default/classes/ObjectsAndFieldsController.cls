/**
 * @description       : Class used to retrieve object and fields data.
 * @author            : Emmanuel Pech
 * @last modified on  : 12-05-2023
 * @last modified by  : Emmanuel Pech
**/
public with sharing class ObjectsAndFieldsController {

    /**
     * @description       : Method to retrieve objects
     * @param             : None
     * @return            : Map<String, String> 
    **/
    @AuraEnabled(cacheable = true)
    public static Map<String, String> fetchAllObjectList(){
        Map<String, String> sobjectMap = new Map<String, String>();
        for (Schema.SObjectType objectTypeElement : Schema.getGlobalDescribe().Values()) {
            String name = objectTypeElement.getDescribe().getLocalName();
            String label = objectTypeElement.getDescribe().getLabel();
            sobjectMap.put(name, label);

        }
        return sobjectMap;
    }

    /**
     * @description       : Method to retrieve fields of specified object 
     * @param             : String strObjectName Object Name to retrieve its fields
     * @return            : Map<String, String>
    **/
    @AuraEnabled(cacheable = true)
    public static Map<String, String> fetchAllFieldList(String strObjectName){
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        Map<String, String> fieldMap = new Map<String, String>();
        for (Schema.SObjectField fieldElement : detail.get(strObjectName).getDescribe().fields.getMap().values()) {
            fieldMap.put(fieldElement.getDescribe().getLabel(), fieldElement.getDescribe().getName());

        }
        return fieldMap;
    }
}