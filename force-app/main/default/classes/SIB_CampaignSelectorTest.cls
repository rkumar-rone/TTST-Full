/**
 * @description       : Test class for SIB_CampaignSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CampaignSelectorTest {

    @isTest
    static void testGetCampaignById() {

        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        
        System.runAs(adminUser) {
            Campaign testCampaign = new Campaign(
                Name = 'Test Campaign', 
                IsActive = true, 
                StartDate = Date.today()
            );
            insert testCampaign;
    
            Campaign resultCampaign = SIB_CampaignSelector.getCampaignById(testCampaign.Id);
            System.assertNotEquals(null, resultCampaign, 'Passed');
        }       
    }

    @isTest
    static void testGetCampaignByIdNoCampaignFound() {
        Id nonExistentCampaignId = SIB_TestDataFactory.getMockId(Campaign.SObjectType) ; 
        Campaign resultCampaign = SIB_CampaignSelector.getCampaignById(nonExistentCampaignId);
        System.assertEquals(null, resultCampaign, 'Passed');
    }
}