trigger contentVersionTrigger on contentVersion  (after insert, after update) {

    if(Trigger.IsInsert && Trigger.IsAfter){
        TTSEventRichTextController.doAfterInsert(Trigger.New);
    }
}