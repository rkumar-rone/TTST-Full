trigger AfterInsertLead on Lead (after insert) { 
    if (trigger.isAfter && trigger.isInsert) { 
        List<Lead> newlyInsertedLeads = [SELECT Id From Lead WHERE Id IN :trigger.new]; 
        Database.DMLOptions autoResponseOptions = new Database.DMLOptions(); 
        autoResponseOptions.EmailHeader.triggerAutoResponseEmail = true; 
        for (Lead newLead : newlyInsertedLeads ) { 
            Database.update(newLead, autoResponseOptions); 
        } 
    } 
}