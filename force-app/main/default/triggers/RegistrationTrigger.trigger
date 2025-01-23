trigger RegistrationTrigger on Registration__c (before insert,before update) {
    TriggerFactory.createHandler(RegistrationTriggerHandler.class);
}