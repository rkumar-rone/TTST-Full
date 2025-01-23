/**
 * @description       : Schedulable class to call SIB_CourseReviewBatch
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
public with sharing class SIB_CourseReviewSchedulable implements Schedulable {
    public void execute(SchedulableContext SC) {
        List<String> mdRecords = SIB_Util.fetchConfigByModule(SIB_Constants.COURSE_REVIEW_BATCH_SIZE);
        Integer batchSize;
        if(!mdRecords.isEmpty()){
            batchSize = Integer.valueOf(mdRecords[0]);
            SIB_CourseReviewBatch batch = new SIB_CourseReviewBatch();
            Database.executeBatch(batch, batchSize);
        }
    }
}