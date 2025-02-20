/**
 * Created by junaidmohammed on 2/13/25.
 */

public without sharing class SIB_CollevaRetrySchedule implements Schedulable{

    public void execute(SchedulableContext context)
    {
        Database.executeBatch( new SIB_CollevaRetryBatch() , 1);
    }

}