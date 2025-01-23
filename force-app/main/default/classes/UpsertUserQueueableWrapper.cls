public with sharing class UpsertUserQueueableWrapper implements Queueable {
    public final Id[] contactIds;
    public final Boolean[] create;
    
    public UpsertUserQueueableWrapper(Id[] contactIds, Boolean[] create) {
        this.contactIds = contactIds;
        this.create = create;
    }

    public void execute(QueueableContext context) {
        Moodle.UpsertUsers(contactIds, create);
    }
}