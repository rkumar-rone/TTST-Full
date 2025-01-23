/**
 * @description       : Class that retrieve Contact Point Address
 * @author            : Rodrigo Hernandez
 * @last modified on  : 08-18-2023
 * @last modified by  : Rodrigo Hernandez
**/
public with sharing class Saltbox_B2BBillToController {
    /**
    * @description Gets contact point address related of current Account
    * @return List of forecast records that need to be created
    */
    @AuraEnabled
    public static List<ContactPointAddress> getContactPointAddresses() {
        String accountId = Saltbox_B2BUtils.getUserAccountID();
            return [Select Id, Address, City, Street, State, Country, CountryCode, StateCode, PostalCode from ContactPointAddress where ParentId=:accountId AND AddressType='Billing'];
    }

    private static Map<String, Set<Integer>> cache;
    public static final String ALPHA_UPPERCASE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    public static final String ALPHA_LOWERCASE_CHARS = 'abcdefghijklmnopqrstuvwxyz';
    public static final String NUMERIC_CHARS = '0123456789';
    public static final String BASE_64_CHARS = ALPHA_UPPERCASE_CHARS + ALPHA_LOWERCASE_CHARS + NUMERIC_CHARS + '+/';

    @AuraEnabled
    public static Map<String, Object> getCountriesAndStates(){
        return new Map<String, Object>{
            'countries' => toCustomPicklistEntry(listPicklistValues(Account.BillingCountryCode)),
            'statesByCountries' => listPicklistValuesByControllingValue(Account.BillingCountryCode, Account.BillingStateCode)
        };
    }

    public static List<CustomPicklistEntry> toCustomPicklistEntry(List<Schema.PicklistEntry> ples) {
        return (List<CustomPicklistEntry>) JSON.deserialize(JSON.serialize(ples),List<CustomPicklistEntry>.class);
    }

    public static Map<String, List<CustomPicklistEntry>> listPicklistValuesByControllingValue(SObjectField controlling,SObjectField dependent) {    
        Map<String, List<CustomPicklistEntry>> results = new Map<String, List<CustomPicklistEntry>>();
        if (controlling == null || dependent == null) {
            return results;
        }
        List<String> controllingValues = new List<String>();

        for (PicklistEntry pe : listPicklistValues(controlling)) {
            if (pe.isActive()) {
                results.put(pe.getValue(), new List<CustomPicklistEntry>());
                controllingValues.add(pe.getValue());
            }
        }
        cache = new Map<String, Set<Integer>>();
        for (CustomPicklistEntry customPicklistEntry : toCustomPicklistEntry(listPicklistValues(dependent))) {
                if (customPicklistEntry.active) {
                    for (Integer index : validForToIndices(customPicklistEntry.validFor)) {
                    results.get(controllingValues.get(index)).add(customPicklistEntry);
                    }
                }
            }              
        return results;
    }

    public static List<Schema.PicklistEntry> listPicklistValues(Schema.SObjectField field) {
        return field.getDescribe().getPicklistValues();
    }

    public class CustomPicklistEntry {
        
        @AuraEnabled
        public Boolean active { get; set; }

        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String value { get; set; }

        @AuraEnabled
        public String validFor { get; set; }
    }

    private static Set<Integer> validForToIndices(String validFor) {
        Set<Integer> indices = cache.get(validFor);
        if (indices == null) {
            indices = new Set<Integer>();
            String validForBits = base64ToBits(validFor);
            for (Integer i = validForBits.indexOf('1');i >= 0;i = validForBits.indexOf('1', i + 1)) {
                indices.add(i);
            }
           cache.put(validFor, indices);
        }
       return indices;
    }

    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            bits = String.valueOf(remainder) + bits;
            val = Integer.valueOf(Math.floor(val / 2));
        }

        return bits;
    }

    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) {
            return '';
        }
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE_64_CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
}