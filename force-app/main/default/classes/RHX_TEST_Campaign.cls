@isTest(SeeAllData=true)
public class RHX_TEST_Campaign {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Campaign LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Campaign()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}