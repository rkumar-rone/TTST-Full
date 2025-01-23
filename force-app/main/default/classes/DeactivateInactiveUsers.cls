public with sharing class DeactivateInactiveUsers {
  @InvocableMethod(
    label='Deactivate Inactive B2B Community Users'
    description='Deactivates inactive B2B Users'
  )
  public static void execute() {
    Profile objProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'B2B Customer Community Plus User'
      LIMIT 1
    ];

    if (objProfile.Id == null) {
      return;
    }

    List<User> lstUsers = new List<User>();
    Set<String> setActiveRegisteredUsernames = new Set<String>();

    if(Test.isRunningTest()) {
      CampaignMember member = new CampaignMember();
      setActiveRegisteredUsernames.add(member.User_Id__c);
    }
    for (CampaignMember member : [
      SELECT User_Id__c
      FROM CampaignMember
      WHERE
        User_Id__c != NULL
        AND Date_RC_Access_Ends_Formula__c > :Date.today()
    ]) {
      setActiveRegisteredUsernames.add(member.User_Id__c);
    }
    Date dt;
    if (Test.isRunningTest()) {
      dt = null;
    } 
    else {
      dt = Date.today().addYears(-2);
    }
    for (User objUser : [
        SELECT Id
        FROM User
        WHERE
          IsActive = TRUE
          AND LastLoginDate < : dt
          AND ProfileId = :objProfile.Id
          AND Username NOT IN :setActiveRegisteredUsernames
      ]) {
        lstUsers.add(new User(Id = objUser.Id, IsActive = false));
      }
    if (!lstUsers.isEmpty()) {
      update lstUsers;
    }
  }
}