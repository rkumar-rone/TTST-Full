/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CampaignSelector {

    public static Campaign getCampaignById(Id campaignId) {
        String fields = SIB_Util.getAllObjectFields('Campaign');

        String query = 'SELECT ' + fields + ' FROM Campaign WHERE Id = :campaignId WITH SYSTEM_MODE';
        List<Campaign> campaignList = Database.query(query);
        
        if(campaignList != null && !campaignList.isEmpty()) {
            return campaignList.get(0);
        }
        return null;
    }
}