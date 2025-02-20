/**
 * Created by junaidmohammed on 2/14/25.
 */

public with sharing class SIB_CollevaUsageSchedule implements Schedulable{

    public void execute(SchedulableContext context)
    {
        Database.executeBatch( new SIB_CollevaUsageBatch() , 1);
    }

}