public without sharing class SaltboxGroupOrderReservedSeatsInvocable {
    
    public class GroupOrderReservedSeats {
        @InvocableVariable (required=false) public List<String> sessionAllocationsIds;
        @InvocableVariable (required=true) public List<String> orderItemSummariesIds;
        @InvocableVariable (required=true) public Integer groupRecipientCount;
    }

    @InvocableMethod (label='SaltboxGroupOrderReservedSeatsInvocable - Update Reserved Seats' description = 'Updates the reserved seats for the Sessions and TTS Events referenced in the input collections')
    public static List<String> updateReservedSeats(List<GroupOrderReservedSeats> rawRequest) {
        List<String> result = new List<String>();
        Integer groupRecipientCount = rawRequest[0].groupRecipientCount;
        Boolean hasSessionAllocations;
        if (rawRequest[0].sessionAllocationsIds == null){
            hasSessionAllocations = false;
        } else {
            hasSessionAllocations = true;
        }

        if (hasSessionAllocations == true && rawRequest[0].sessionAllocationsIds == null) {
            result.add('Session Allocation Ids are required when hasSessionAllocations is true');
            return result;
        }

        if (hasSessionAllocations == true) {
            List<Session_Allocation__c> sessionAllocations = [SELECT Id, Session__c FROM Session_Allocation__c WHERE Id IN :rawRequest[0].sessionAllocationsIds];

            List<String> sessionIds = new List<String>();

            for (Session_Allocation__c sa : sessionAllocations) {
                sessionIds.add(sa.Session__c);
            }

            List<Session__c> sessions = [SELECT Id, Reserved_Seats__c FROM Session__c WHERE Id IN :sessionIds];

            for (Session_Allocation__c sa : sessionAllocations) {
                for (Session__c s : sessions) {
                    if (sa.Session__c == s.Id) {
                        if (s.Reserved_Seats__c == null) {
                            s.Reserved_Seats__c = groupRecipientCount;
                        } else {
                            s.Reserved_Seats__c += groupRecipientCount;
                        }
                    }
                }
            }

            try {
                update sessions;
            } catch (Exception e) {
                result.add('Error updating Session__c records: ' + e.getMessage());
                return result;
            }
        }
        
        List<OrderItemSummary> orderItemSummaries = [SELECT Id, Product2.TTS_Event__c FROM OrderItemSummary WHERE Id IN :rawRequest[0].orderItemSummariesIds];
    
        List<String> eventIds = new List<String>();

        for (OrderItemSummary ois : orderItemSummaries) {
            eventIds.add(ois.Product2.TTS_Event__c);
        }

        List<Campaign> events = [SELECT Id, Reserved_Seats__c FROM Campaign WHERE Id IN :eventIds];
        
        for (OrderItemSummary ois : orderItemSummaries) {
            for (Campaign e : events) {
                if (ois.Product2.TTS_Event__c == e.Id) {
                    if (e.Reserved_Seats__c == null) {
                        e.Reserved_Seats__c = groupRecipientCount;
                    } else {
                        e.Reserved_Seats__c += groupRecipientCount;
                    }
                }
            }
        }

        try {
            update events;
        } catch (Exception e) {
            result.add('Error updating TTS_Event__c records: ' + e.getMessage());
            return result;
        }

        result.add('Reserved seats updated successfully');
        return result;
    
    }

}