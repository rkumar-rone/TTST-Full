@isTest
public class LeadTriggerTests {
    private static testmethod void afterInsertLeadTest(){
        Lead newLd = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert newLd;
    } 
}