public without sharing class SIB_ConfigurationSelector {

    private static final String CLASSNAME = 'SIB_ConfigurationSelector';
    private static final String OBJ_NAME = 'SIB_StorefrontConfiguration__c';

    private static final String CONFIG_JSON_FIELD = 'ConfigJSON__c';

    public static String getConfigJSONField() {
        return CONFIG_JSON_FIELD;
    }
    
    public static Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'ConfigJSON__c'
        };
    }

    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getDefaultFields());
        return String.join(queryFieldsList, ',');
    }

    public static Sobject getConfigurationSelectorByType(String type)
    {
        Date currentDate = Date.today();
        String query =' SELECT ' +getQueryFieldString() + ' FROM '+OBJ_NAME+' ';
        String whereClause = ' WHERE Active__c = true AND ConfigurationType__c =: type AND (StartDate__c = null OR StartDate__c <=: currentDate ) AND (EndDate__c = null OR EndDate__c >=: currentDate) ';
        String orderByClause = ' ORDER BY EndDate__c ASC NULLS LAST limit 1 ';
        query = query + whereClause + orderByClause ;
        System.debug('getConfigurationSelectorByType query : '+query);
        List<SObject> configList = Database.query(query);
        return  configList.isEmpty()?null:configList.get(0);
    }

    public static SObject getConfigurationSelectorById(String configId)
    {
        Date currentDate = Date.today();
        String query =' SELECT ' +getQueryFieldString() + ' FROM '+OBJ_NAME+' ';
        String whereClause = ' WHERE Active__c = true AND  Id =: configId AND (StartDate__c = null OR StartDate__c <=: currentDate ) AND (EndDate__c = null OR EndDate__c >=: currentDate) ';
        String orderByClause = ' ORDER BY EndDate__c ASC NULLS LAST limit 1 ';
        query = query + whereClause + orderByClause ;
        System.debug('getConfigurationSelectorByType query : '+query);
        List<SObject> configList = Database.query(query);
        return  configList.isEmpty()?null:configList.get(0);
    }



}