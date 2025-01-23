public with sharing class TriggerFactory
{
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
     
    public static void createHandler(Type t){
        // Get a handler appropriate to the object being processed
        ITrigger handler = getHandler(t);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null)
        {
        throw new TriggerException('No Trigger Handler found named: ' + t.getName());
        }
        // Execute the handler to fulfil the trigger
        execute(handler);
    }

    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */ 
    private static void execute(ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            if (Trigger.isDelete) {
                handler.beforeDelete();
            }
      
            else if (Trigger.isInsert) {
                handler.beforeInsert();
            }
            else if (Trigger.isUpdate)
            {
                handler.beforeUpdate();
            }
            
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            if (Trigger.isDelete) {
                handler.afterDelete();
            }
            else if (Trigger.isInsert) {
                handler.afterInsert();
            }
            else if (Trigger.isUpdate) {
             for (SObject so : Trigger.old)
                {
                    handler.afterUpdate();
                }

               // handler.afterUpdate();
                
            }else if(Trigger.isUnDelete){
                handler.afterUnDelete();
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
     
    private static ITrigger getHandler(Type t)
    {
        // Instantiate the type
        Object o = t.newInstance();
 
        // if its not an instance of ITrigger return null
        if (!(o instanceOf ITrigger))
        {
            return null;
        }
 
        return (ITrigger)o;
    }    
}