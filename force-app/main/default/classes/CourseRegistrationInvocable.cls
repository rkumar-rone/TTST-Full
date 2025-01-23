/**
 * @description       : Invocable class to register a student for one or more courses.
 * @author            : Rodrigo Hernandez
 * @group             :
 * @last modified on  : 01-04-2024 
 * @last modified by  : Emmanuel Pech
**/
public without sharing class CourseRegistrationInvocable {
    
    /**
     * This inner class represents the input data for the createCourseRegistration method.
     * It contains a list of courses to register for, and a contact ID for the student to register.
     */
    public class CourseRegistrationInput {
        @InvocableVariable(label='Courses' description='The Items from the order to register the student for')
        public List<Campaign> courses;

        @InvocableVariable(label='Contact' description='The student to register for the courses')
        public Id contactId;

        @InvocableVariable(label='Order Summary Id' description='The Order Summary from where the course was bought')
        public Id orderSummaryId;

        @InvocableVariable(label='Event Relationships' description='The Relationships between events (CORPORATE EVENTS ONLY)')
        public List<Event_Relationship__c> eventRelationships;

        @InvocableVariable(label='Registration Type' description='Flags whether the registration from a group recipient')
        public String registrationType;

        @InvocableVariable(label='Waitlisted' description='Flags if the capacity is out and the student is waitlisted')
        public String waitlisted;

    }
    /**
     * This inner class represents the shared data between Session__c and Session_Allocation__c objects.
     */
    public class SessionInfo {
        public Id sessionId;
        public Id eventId;
        public Decimal waitingListMembers;
        public Boolean isAllocation; // To distinguish between direct sessions and allocations
    
        public SessionInfo(Id sessionId, Id eventId, Decimal waitingListMembers, Boolean isAllocation) {
            this.sessionId = sessionId;
            this.eventId = eventId;
            this.waitingListMembers = waitingListMembers;
            this.isAllocation = isAllocation;
        }
    }
    
    

    /**
     * This method returns a set of Campaign Ids that are waitlisted.
     * @param orderItemSummaries A list of OrderItemSummary objects with information about the campaign (TTS Event)
     * and whether it is waitlisted.
     */
    public static Set<Id> getWaitlistedCourses(List<OrderItemSummary> orderItemSummaries) {
        //Take in a list of OrderItemSummary and return a set of Campaign Ids that are waitlisted
        Set<Id> waitlistedCourseIds = new Set<Id>();
        for(OrderItemSummary orderItemSummary : orderItemSummaries){
            if(orderItemSummary.IsWaitlisted__c){
                waitlistedCourseIds.add(orderItemSummary.Product2.TTS_Event__c);
            }
        }
        return waitlistedCourseIds;
    }

    /**
     * This function determines if a campaign should be waitlisted
     */
    public static Boolean shouldBeWaitlisted(Id campaignId, String status, Set<Id> waitlistedCourseIds, Map<Id, Event_Relationship__c> campaignToEventRelationshipMap, String isWaitlistedFlag) {
        System.debug(isWaitlistedFlag);
        System.debug(waitlistedCourseIds.contains(campaignId));
        System.debug(campaignToEventRelationshipMap.get(campaignId)?.Parent__c != null);
        System.debug(waitlistedCourseIds.contains(campaignToEventRelationshipMap.get(campaignId)?.Parent__c));

        if(status == 'Registered') return false;
        if(isWaitlistedFlag == 'true') return true;
        return (waitlistedCourseIds.contains(campaignId) || ((campaignToEventRelationshipMap.get(campaignId)?.Parent__c != null && waitlistedCourseIds.contains(campaignToEventRelationshipMap.get(campaignId)?.Parent__c))));
    }

    /**
     * This method registers a student for one or more courses.
     * It takes a list of CourseRegistrationInput objects, each of which contains a list of courses
     * and a contact ID. The method creates a CampaignMember record for each course, and a Registration record
     * for each session associated with each course.
     * @param input A list of CourseRegistrationInput objects, each of which contains a list of courses
     * and a contact ID.
     */
    @InvocableMethod(label='Course Registration' description='Registers a student for a course')
    public static void createCourseRegistration(List<CourseRegistrationInput> input){
        // Types: OrderSummary, GroupRecipient, Private

        Set<Id> waitlistedCourseIds = new Set<Id>();

        String registrationType = input[0].registrationType;

        String orderType;

        switch on registrationType {
            when 'OrderSummary' {
                orderType = 'Individual';
            }
            when 'GroupRecipient' {
                orderType = 'Group';
            }
            when 'Private' {
                orderType = 'Private';
            }
            when else {
                
            }
        }

        if(input[0].registrationType == 'OrderSummary') {
            List<OrderItemSummary> orderItemSummaries = [SELECT Id, IsWaitlisted__c, Product2.TTS_Event__c FROM OrderItemSummary WHERE OrderSummaryId = :input[0].orderSummaryId];
            waitlistedCourseIds = getWaitlistedCourses(orderItemSummaries);
        }

        //set of course ids
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign course : input[0].courses) {
            campaignIds.add(course.Id);
        }

        //find existing CampaignMembers
        List<CampaignMember> existingCampaignMembers = [SELECT Id, CampaignId, ContactId, Attendee_Status__c, Status, Date_RC_Access_Starts_Formula__c, Date_RC_Access_Ends_Formula__c FROM CampaignMember WHERE ContactId = :input[0].contactId AND CampaignId IN :campaignIds];
        Map<Id, CampaignMember> campaignIdToCampaignMemberMap = new Map<Id, CampaignMember>();
        for (CampaignMember campaignMember : existingCampaignMembers) {
            campaignIdToCampaignMemberMap.put(campaignMember.CampaignId, campaignMember);
        }

        //map course id to event relationship
        Map<Id, Event_Relationship__c> campaignToEventRelationshipMap = new Map<Id, Event_Relationship__c>();
        if (input[0].eventRelationships != null) {
            for (Event_Relationship__c eventRelationship : input[0].eventRelationships) {
            	campaignToEventRelationshipMap.put(eventRelationship.Child__c, eventRelationship);
            }
        }

        // Create CampaignMember records for each course
        try {
            List<CampaignMember> campaignMembers = new List<CampaignMember>();
            List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();
            List<Campaign> campaigns = input[0].courses;
            //List<String> statusList = new List<String>{'Cancelled', 'Transferred', 'No Show'};
            for (Campaign campaign : campaigns) {
                CampaignMember campaignMember = new CampaignMember();
                if (campaignIdToCampaignMemberMap.containsKey(campaign.Id)) {
                    campaignMember = campaignIdToCampaignMemberMap.get(campaign.Id);
                }
                else {
                    campaignMember.ContactId = input[0].contactId;
                    campaignMember.CampaignId = campaign.Id;
                }
                Boolean isWaitlisted = shouldBeWaitlisted(campaign.Id, campaignMember.Status, waitlistedCourseIds, campaignToEventRelationshipMap, input[0].waitlisted);
                if (!isWaitlisted) {
                    System.debug('>>> Entered not waitlisted condition');
                    campaignMember.Attendee_Status__c = 'Registered';
                    campaignMember.Status = 'Registered';
                } else {
                    System.debug('>>> Entered waitlisted condition');
                    campaignMember.Attendee_Status__c = 'Waiting List';
                    campaignMember.Status = 'Waiting List';
                }
                campaignMember.Attempted_Registration_Date__c = Datetime.now();
                campaignMember.Description__c = campaign.Description;
                campaignMember.What_to_Bring__c = campaign.What_to_Bring__c;
                
                //If there is a related Order Summary, get the registration amounts to attribute to the CampaignMember
                if (input[0].orderSummaryId!= null) {
                    
                    campaignMember.Order_Summary__c = input[0].orderSummaryId;
                    //Get the OrderItemSummary for the course   
                    List<OrderItemSummary> osi = [SELECT Id, Product2Id, Product2.TTS_Event__c, Product2.TTS_Event__r.RecordType.DeveloperName, CurrencyIsoCode, (SELECT AdjustmentCause.Name FROM OrderItemAdjustmentLineItemSummaries), TotalLineAmount, TotalPrice, Quantity FROM OrderItemSummary WHERE OrderSummaryId = :input[0].orderSummaryId AND Product2.TTS_Event__c = :campaign.Id LIMIT 1];
                    //If the campaign is not a self study product, calculate the registration amount and discount
                    if(osi.size() > 0) {
                        campaignMember.CurrencyIsoCode = osi[0].CurrencyIsoCode;
                        if(osi[0].Product2.TTS_Event__r.RecordType.DeveloperName != 'SelfStudy_Product') {
                            //If the registration type is GroupRecipient, divide the total amount by the quantity
                            if(input[0].registrationType == 'GroupRecipient') {
                                campaignMember.Course_Cost__c = osi[0].TotalLineAmount / osi[0].Quantity;
                                campaignMember.Discount__c = (osi[0].TotalLineAmount - osi[0].TotalPrice) / osi[0].Quantity;
                            } else {
                                campaignMember.Course_Cost__c = osi[0].TotalLineAmount;
                                campaignMember.Discount__c = osi[0].TotalLineAmount - osi[0].TotalPrice;
                            }
                            //If there is a discount, get the coupon code
                            if(osi[0].OrderItemAdjustmentLineItemSummaries.size() > 0) {
                                campaignMember.Coupon_Code__c = osi[0].OrderItemAdjustmentLineItemSummaries[0].AdjustmentCause.Name;
                            }
                            //If there is more than one discount, concatenate the coupon codes and truncate to 50 characters to avoid exceeding the field limit
                            if(osi[0].OrderItemAdjustmentLineItemSummaries.size() > 1) {
                                String couponCodes = campaignMember.Coupon_Code__c + ', ' + osi[0].OrderItemAdjustmentLineItemSummaries[1].AdjustmentCause.Name;
                                campaignMember.Coupon_Code__c = couponCodes.left(50);
                            }
                        } 
                    }  
                    
                } else {
                    campaignMember.Course_Cost__c = 0;
                    campaignMember.CurrencyIsoCode = 'USD';
                } 
                if (!String.isBlank(orderType)) {
                    campaignMember.OrderType__c = orderType;
                }
                if (campaignToEventRelationshipMap.containsKey(campaign.Id)) {
                    if(campaignMember.Id == null || campaignMember.Date_RC_Access_Ends_Formula__c == null || campaignMember.Date_RC_Access_Ends_Formula__c <= campaignToEventRelationshipMap.get(campaign.Id).Date_RC_Access_Ends_DateTime_Formula__c) {
                        campaignMember.Event_Relationship_Generated_From__c = campaignToEventRelationshipMap.get(campaign.Id).Id;
                    }
                    if(campaignMember.Id == null || campaignMember.Date_RC_Access_Starts_Formula__c == null || campaignMember.Date_RC_Access_Starts_Formula__c >= campaignToEventRelationshipMap.get(campaign.Id).Date_RC_Access_Starts_DateTime_Formula__c) {
                        campaignMember.Earliest_Event_Relationship__c = campaignToEventRelationshipMap.get(campaign.Id).Id;
                    }

                    campaignMember.New_Portal__c = true;
                    if (campaign.View_Map__c == null || campaign.View_Map__c == '') {
                        campaignMember.View_Map__c = 'http://www.google.com/maps?hl=en&safe=off&q=' + campaign.Training_Location_Street__c + ',' + campaign.Training_Location_City__c + ',' + campaign.Training_Location_State__c + ',' + campaign.Training_Location_Zip_Code__c + '&aq=f&aqi=&aql=&oq=&pbx=1&bav=on.2,or.r_gc.r_pw.&fp=a445e974b90b3339';
                    } else {
                        campaignMember.View_Map__c = campaign.View_Map__c;
                    }
                }
                campaignMembers.add(campaignMember);
            }
            if (!campaignMembers.isEmpty()) {
                // filter out exact duplicates
                Map<String, CampaignMember> uniqueCampaignMembers = new Map<String, CampaignMember>();
                for(CampaignMember cm : campaignMembers){
                    String key = (String)cm.ContactId+cm.CampaignId;
                    uniqueCampaignMembers.put(key, cm);
                }
                campaignMembers = uniqueCampaignMembers.values();
                upsert campaignMembers;
            }
            



            //find sessions to register for
            List<SessionInfo> unifiedSessions = new List<SessionInfo>();
            Set<Id> allocatedCampaignIds = new Set<Id>();
            Set<Id> sessionIds = new Set<Id>();
            if(input[0].registrationType == 'OrderSummary' || input[0].registrationType == 'GroupRecipient') {
                for(Session_Allocation__c sa : [SELECT Session__c, Session__r.Event__c, Session__r.Waiting_List_Members__c FROM Session_Allocation__c WHERE Order_Summary__c = :input[0].orderSummaryId AND Session__r.Event__c IN :campaignIds]) {
                    unifiedSessions.add(new SessionInfo(sa.Session__c, sa.Session__r.Event__c, sa.Session__r.Waiting_List_Members__c, true));
                    sessionIds.add(sa.Session__c);
                    allocatedCampaignIds.add(sa.Session__r.Event__c);
                }
                Set<Id> nonAllocatedCampaignIds = new Set<Id>();
                for(Id campaignId : campaignIds){
                    if(!allocatedCampaignIds.contains(campaignId)){
                        nonAllocatedCampaignIds.add(campaignId);
                    }
                }
                if(!nonAllocatedCampaignIds.isEmpty()) {
                    for(Session__c s : [SELECT Id, Event__c, Waiting_List_Members__c FROM Session__c WHERE Event__c IN :nonAllocatedCampaignIds]) {
                        unifiedSessions.add(new SessionInfo(s.Id, s.Event__c, s.Waiting_List_Members__c, false));
                        sessionIds.add(s.Id);
                    }
                }

            }
            
            if(input[0].registrationType == 'Private') {
                for(Session__c s : [SELECT Id, Event__c, Waiting_List_Members__c FROM Session__c WHERE Event__c IN :campaignIds]) {
                    unifiedSessions.add(new SessionInfo(s.Id, s.Event__c, s.Waiting_List_Members__c, false));
                    sessionIds.add(s.Id);
                }
            }
            
            // Create registration__c records for each session associated with each course
            List<Registration__c> registrations = new List<Registration__c>();
            List<Registration__c> registrationsToUpdate = new List<Registration__c>();

            List<Registration__c> existingRegistrations = [SELECT Id, Session__c, Contact__c, Status__c, Waiting_List__c, Waiting_List_Ranking__c FROM Registration__c WHERE Contact__c = :input[0].contactId AND Session__c IN :sessionIds];
            Map<Id, Registration__c> sessionIdToRegistrationMap = new Map<Id, Registration__c>();
            for (Registration__c registration : existingRegistrations) {
                sessionIdToRegistrationMap.put(registration.Session__c, registration);
            }
            for (SessionInfo sessionInfo : unifiedSessions) {
                Registration__c registration = new Registration__c();
                if (sessionIdToRegistrationMap.containsKey(sessionInfo.sessionId)) {
                    registration = sessionIdToRegistrationMap.get(sessionInfo.sessionId);
                }
                else {
                    registration.Session__c = sessionInfo.sessionId;
                    registration.Contact__c = input[0].contactId;
                }
                Boolean isWaitlisted = shouldBeWaitlisted(sessionInfo.eventId, registration.Status__c, waitlistedCourseIds, campaignToEventRelationshipMap, input[0].waitlisted);
                if (!isWaitlisted) {
                    registration.Status__c = 'Registered';
                } else {
                    registration.Status__c = 'Waiting List';
                    registration.Waiting_List_Ranking__c = sessionInfo.waitingListMembers +1;
                    registration.Waiting_List__c = true;
                }
                if (input[0].orderSummaryId!= null) {
                    //registration.CurrencyIsoCode = input[0].orderSummaryId.CurrencyIsoCode;
                } else {
                    registration.CurrencyIsoCode = 'USD';
                }
                registrations.add(registration);
            }
            if (!registrations.isEmpty()) {
                // filter out exact duplicates
                Map<String, Registration__c> uniqueRegistrations = new Map<String, Registration__c>();
                for(Registration__c rs : registrations){
                    String key = (String)rs.Contact__c+rs.Session__c;
                    uniqueRegistrations.put(key, rs);
                }
                registrations = uniqueRegistrations.values();
                upsert registrations;
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
            ProcessException pe = new ProcessException();
            if (input[0].orderSummaryId != null) {
                pe.Category = 'Place Order';
                pe.Message = 'Error creating CampaignMember and Registration records';
                pe.Description =  ex.getMessage() + ' - ' + ex.getStackTraceString();
                pe.OrderSummaryId = input[0].orderSummaryId;
                pe.AttachedToId = input[0].orderSummaryId;

                insert pe;
            } else {
                //Email Stack Trace to Admin
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {System.Label.defaultEmailAddress};                                              //'nathan@saltboxmgmt.com' };
                mail.setPlainTextBody('Error: ' + ex.getMessage() + ' - ' + ex.getStackTraceString()) ;
                mail.setSubject('TTS - Corporate Registration Error');
                mail.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                //pe.AttachedToId = input[0].contactId;
            }
        }
        
    }
}