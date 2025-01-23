/**
 * @author Anand Reddy
 * @email pareddy@rafter.one
 * @create date 2024-10-14 13:21:15
 * @modify date 2024-10-14 13:21:15
 * @desc [description]
 */

public without sharing class SIB_EventRelationshipSelector {
    private static final String CLASSNAME = 'SIB_EventRelationshipSelector';
    private static final String OBJ_NAME = 'Event_Relationship__c';

    public static Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Parent__c',
            'Child__r.Name'
        };
    }

    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getDefaultFields());
        return String.join(queryFieldsList, ',');
    }

    public static List<Sobject> getEventRelationshipsByEventIds(List<String> eventIds) {
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE Parent__c IN :eventIds ';
        String orderQuery = query + whereClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }
}