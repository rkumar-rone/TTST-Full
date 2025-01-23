/**
 * @description       : This class contains Account specific selector method(s)
 * @author            : vramachandran@rafter.one
 * @group             : 
 * @last modified on  : 10-26-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_AccountSelector {
    private static final String CLASSNAME = 'SIB_AccountSelector';
    private static final String OBJ_NAME = 'Account';
    
    /**
     * @description returns account fields for provided account id 
     * @createdBy vramachandran@rafter.one
     * params accountId | String
     * returns String
     */
    public static Account getAccountInformation(String accountId) {

        Account fetchedAccount;
        String query = 'SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ' FROM ' + OBJ_NAME + ' ';
        String whereClause = ' WHERE Id = :accountId ';
        String orderQuery = query + whereClause;
        List<Account> fetchedAccounts = (List<Account>)Database.query(orderQuery);

        if(null != fetchedAccounts && !fetchedAccounts.isEmpty()) {

            fetchedAccount = fetchedAccounts[0];
        }
        return fetchedAccount;
    }
}