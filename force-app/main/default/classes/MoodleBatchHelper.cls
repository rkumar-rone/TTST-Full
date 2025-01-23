public class MoodleBatchHelper {
    public static void GetUsers(Contact[] contacts) {
        Moodle_Configuration__mdt config = [Select Id, Course_Contents_Function__c, Get_Users_Function__c, Get_Users_Courses_Activities_Function__c,  Get_Users_Courses_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        String userFunction = config.Get_Users_Function__c;
        String userCourseFunction = config.Get_Users_Courses_Function__c;
        String userCourseActivityFunction = config.Get_Users_Courses_Activities_Function__c;
        String contentsFunction = config.Course_Contents_Function__c;
        String reqBody = 'field=id';
        Integer i = 0;
        Map<Integer, Contact> lmsIdContactMap = new Map<Integer, Contact>();
        // Key: Contact LMS Id
        // Value: key:Campaign LMS Id ; Value: Campaign Member
        Map<Integer, Map<Integer, CampaignMember>> cmpMemLMScontLMSmap = new Map<Integer, Map<Integer, CampaignMember>>();
        List<Moodle_API_Error__c> exceptionLogs = new List<Moodle_API_Error__c>();
        
        // Preparing Contact Map Key: LMS Id ; Value: Contact
        for(Contact c : contacts) {
            if(c.LMS_Id__c != null) {
                reqBody += ('&values[' + i.format().replaceAll(',', '') + ']=' + c.LMS_Id__c.format().replaceAll(',', ''));
                i++;
                lmsIdContactMap.put(c.LMS_Id__c.intValue(), c);
            }
        }
        
        //Preparing Campaign Member Map Key: LMS Id ;  Value Map of LMS Id and Campaign Member
        Set<Integer> campLMSIds = new Set<Integer>();
        for(CampaignMember cm : [Select Id, Contact.LMS_Id__c, Campaign.LMS_Id__c from CampaignMember WHERE 
                                Contact.LMS_Id__c in :lmsIdContactMap.keySet() AND 
                                Campaign.LMS_Id__c != null AND
                                (Campaign.Date_RC_Access_Ends__c >=TODAY OR Campaign.Date_RC_Access_Ends__c = null OR Campaign.Date_RC_Access_Ends__c=LAST_N_DAYS:2)]) {
            if(!cmpMemLMScontLMSmap.containsKey(cm.Contact.LMS_Id__c.intValue())) {
                cmpMemLMScontLMSmap.put(cm.Contact.LMS_Id__c.intValue(), new Map<Integer,CampaignMember>());
            }
            campLMSIds.add(cm.Campaign.LMS_Id__c.intValue());
            cmpMemLMScontLMSmap.get(cm.Contact.LMS_Id__c.intValue()).put(cm.Campaign.LMS_Id__c.intValue(), cm);
        }
        
        // Begin - HTTP Call to Get LMS Details of the Contact
        // Prepare Update Contact Map based on Callout Response
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + userFunction + '&moodlewsrestformat=json');
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setBody(reqBody);
        Map<Integer, Contact> toUpdate = new Map<Integer, Contact>();
        Map<Id, CampaignMember> toUpdateCM = new Map<Id, CampaignMember>();
        try {
            HttpResponse hresp = h.send(httpreq);
            System.Debug(userFunction+'-'+hresp.getBody());
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    MoodleUserResponse[] responseUsers = (MoodleUserResponse[])JSON.deserialize(hresp.getBody(), MoodleUserResponse[].class);
                    //Iterate Over Moodle User Response to Update LMS Access Date Information on Contacts
                    for(MoodleUserResponse r : responseUsers) {
                        if(lmsIdContactMap.containsKey(r.id)) {
                            Contact updateContact = lmsIdContactMap.get(r.Id);
                            updateContact.LMS_Last_Access__c = (r.lastaccess == null || r.lastaccess == 0) ? null : DateTime.newInstance(r.lastAccess * 1000);
                            updateContact.LMS_First_Access__c = (r.firstaccess == null || r.firstaccess == 0) ? null :  DateTime.newInstance(r.firstAccess * 1000);
                            toUpdate.put(r.id, updateContact);
                        }
                    }
                    responseUsers.clear();
                }else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    
                    for(Contact cnt : contacts) {
                        exceptionLogs.add(new Moodle_API_Error__c(Function__c = userFunction,
                        Contact__c = cnt.Id,
                        Exception__c = me.exception_x,
                        Error_Code__c = me.errorcode,
                        Message__c = userFunction+'-'+me.message ,
                        Debug_Info__c = me.debuginfo));
                        
                    }
                }
            }else{
                for(Contact cnt : contacts) {
                    exceptionLogs.add(new Moodle_API_Error__c(Function__c = userFunction,
                    Contact__c = cnt.Id,
                    Exception__c = hresp.getBody(),
                    Error_Code__c = String.valueOf(hresp.getStatusCode()),
                    Message__c = userFunction+'-'+hresp.getStatusCode() ,
                    Debug_Info__c = 'Response Body:'+hresp.getBody()));
                    
                }
            }
            hresp = null;
            lmsIdContactMap.clear();
        }
        catch(Exception ex) {
            for(Contact cnt : contacts) {
                exceptionLogs.add(new Moodle_API_Error__c(Function__c = userFunction,
                Contact__c = cnt.Id,
                Exception__c = String.valueOf(ex.getCause()),
                Error_Code__c = ex.getTypeName(),
                Message__c = ex.getmessage() ,
                Debug_Info__c = ex.getStackTraceString()));
                
            }
            
        }
        // End - HTTP Call to Get LMS Details of the Contact
        
        // Begin - HTTP Call to Get LMS Course Details of the Contact
        //added to get the campaign details
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + contentsFunction + '&moodlewsrestformat=json');
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Map<Integer, Integer> lmsIdvisibleModuleCountMap = new Map<Integer, Integer>();
        
        //Iterate over Campaign LMS Id
        for(Integer campLMSid : campLMSIds) {
            try {
                reqBody = 'courseid=' + campLMSid.format().replaceAll(',', '');
                httpreq.setBody(reqBody);
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    System.Debug(contentsFunction+'-'+hresp.getBody());
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        MoodleCourseResponse[] courseResponses = (MoodleCourseResponse[])JSON.deserialize(hresp.getBody(), MoodleCourseResponse[].class);
                        Integer visibleModuleCount = 0;
                        for(MoodleCourseResponse mcr : courseResponses) {
                            if(mcr.modules != null) {
                                for(MoodleModules mod : mcr.modules) {
                                    if(mod.visible > 0 && mod.uservisible && mod.completion > 0) {
                                        visibleModuleCount++;
                                    }
                                }
                            }
                        }
                        lmsIdvisibleModuleCountMap.put(campLMSid, visibleModuleCount);
                        courseResponses.clear();
                    }else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        
                        for(Contact cnt : contacts) {
                            exceptionLogs.add(new Moodle_API_Error__c(Function__c = contentsFunction,
                            Contact__c = cnt.Id,
                            Exception__c = me.exception_x,
                            Error_Code__c = me.errorcode,
                            Message__c = contentsFunction+'-'+me.message ,
                            Debug_Info__c = me.debuginfo));
                            
                        }
                    }
                }else{
                    for(Contact cnt : contacts) {
                        exceptionLogs.add(new Moodle_API_Error__c(Function__c = contentsFunction,
                        Contact__c = cnt.Id,
                        Exception__c = hresp.getBody(),
                        Error_Code__c = String.valueOf(hresp.getStatusCode()),
                        Message__c = contentsFunction+'-'+hresp.getStatusCode() ,
                        Debug_Info__c = 'Response Body:'+hresp.getBody()));
                        
                    }
                }
                
                hresp = null;
            }
            catch(Exception ex) {
                for(Contact cnt : contacts) {
                    exceptionLogs.add(new Moodle_API_Error__c(Function__c = contentsFunction,
                    Contact__c = cnt.Id,
                    Exception__c = String.valueOf(ex.getCause()),
                    Error_Code__c = ex.getTypeName(),
                    Message__c = ex.getmessage() ,
                    Debug_Info__c = ex.getStackTraceString()));
                    
                }
            }
        }
        campLMSIds.clear();
        // End - HTTP Call to Get LMS Course Details of the Contact
        
        // Begin - HTTP Call to Get User Course Details of the Contact
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + userCourseFunction + '&moodlewsrestformat=json');
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        List<Integer> cntLMSIdsCmpEnbld = new List<Integer>();
        List<Integer> courseLMSIdsCmpEnbld = new List<Integer>();
        for(Contact c : contacts) {
            if(c.LMS_Id__c != null) {
                reqBody = ('userid=' + c.LMS_Id__c.format().replaceAll(',', ''));
                reqBody += '&returnusercount=0';
                httpreq.setBody(reqBody);
                try {
                    HttpResponse hresp = h.send(httpreq);
                    if(hresp.getStatusCode() == 200) {
                        System.Debug(userCourseFunction+'-'+hresp.getBody());
                        if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                            MoodleUserCourseResponse[] classes = (MoodleUserCourseResponse[])JSON.deserialize(hresp.getBody(), MoodleUserCourseResponse[].class);
                            
                            for(MoodleUserCourseResponse r : classes) {
                                if(cmpMemLMScontLMSmap.containsKey(c.LMS_Id__c.intValue()) && cmpMemLMScontLMSmap.get(c.LMS_Id__c.intValue()).containsKey(r.Id)) {
                                    System.Debug('MoodleUserCourseResponse-->'+r);
                                    CampaignMember updateCM = cmpMemLMScontLMSmap.get(c.LMS_Id__c.intValue()).get(r.Id);
                                    updateCM.Progress_Percentage__c = r.progress;
                                    updateCM.Completion_Enabled__c = r.enablecompletion;
                                    if(updateCM.Completion_Enabled__c) {
                                        cntLMSIdsCmpEnbld.add(c.LMS_Id__c.intValue());
                                        courseLMSIdsCmpEnbld.add(r.Id);
                                    }
                                    Long lastAccessLong = r.lastaccess == null ? null : r.lastAccess;
                                    updateCM.Last_Access_Date__c = (r.lastaccess == null ? null : DateTime.newInstance(lastaccessLong * 1000));
                                    updateCM.Favorite__c = r.isfavourite;
                                    toUpdateCM.put(updateCM.Id, updateCM);
                                }
                            }
                            classes.clear();
                        }else {
                            MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                            
                            for(Contact cnt : contacts) {
                                exceptionLogs.add(new Moodle_API_Error__c(Function__c = userCourseFunction,
                                Contact__c = cnt.Id,
                                Exception__c = me.exception_x,
                                Error_Code__c = me.errorcode,
                                Message__c = userCourseFunction+'-'+me.message ,
                                Debug_Info__c = me.debuginfo));
                                
                            }
                        }
                    }else{
                        for(Contact cnt : contacts) {
                            exceptionLogs.add(new Moodle_API_Error__c(Function__c = userCourseFunction,
                            Contact__c = cnt.Id,
                            Exception__c = hresp.getBody(),
                            Error_Code__c = String.valueOf(hresp.getStatusCode()),
                            Message__c = contentsFunction+'-'+hresp.getStatusCode() ,
                            Debug_Info__c = 'Response Body:'+hresp.getBody()));
                            
                        }
                    }
                    hresp = null;
                }
                catch(Exception ex) {
                    for(Contact cnt : contacts) {
                        exceptionLogs.add(new Moodle_API_Error__c(Function__c = userCourseFunction,
                        Contact__c = cnt.Id,
                        Exception__c = String.valueOf(ex.getCause()),
                        Error_Code__c = ex.getTypeName(),
                        Message__c = ex.getmessage() ,
                        Debug_Info__c = ex.getStackTraceString()));
                        
                    }
                    
                }
            }
        }
        // End - HTTP Call to Get User Course Details of the Contact
        
        
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + userCourseActivityFunction + '&moodlewsrestformat=json');
        for(Integer j = 0; j < cntLMSIdsCmpEnbld.size(); j++) {
            reqBody = ('courseid=' + courseLMSIdsCmpEnbld[j].format().replaceAll(',', ''));
            reqBody += ('&userid=' + cntLMSIdsCmpEnbld[j].format().replaceAll(',', ''));
            httpreq.setBody(reqBody);
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    System.Debug(userCourseActivityFunction+'-'+hresp.getBody());
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        MoodleUserCourseActivityResponse activityresponse = (MoodleUserCourseActivityResponse)JSON.deserialize(hresp.getBody(), MoodleUserCourseActivityResponse.class);
                        if(activityresponse.statuses != null) {
                            Integer totalModules = 0;
                            Integer completedModules = 0;
                            for(MoodleUserCourseActivityStatus astatus : activityresponse.statuses) {
                                if(astatus.state > 0) {
                                    completedModules++;
                                }
                                totalModules++;
                            }
                            
                            CampaignMember updateCM = cmpMemLMScontLMSmap.get(cntLMSIdsCmpEnbld[j]).get(courseLMSIdsCmpEnbld[j]);
                            updateCM.Number_of_Activities__c = lmsIdvisibleModuleCountMap.containsKey(courseLMSIdsCmpEnbld[j]) ? lmsIdvisibleModuleCountMap.get(courseLMSIdsCmpEnbld[j]) : totalModules;
                            updateCM.Number_of_Completed_Activities__c = completedModules;
                            
                            if(lmsIdvisibleModuleCountMap.containsKey(courseLMSIdsCmpEnbld[j])) {
                                updateCM.Progress_Percentage__c = (updateCM.Number_of_Activities__c == 0 || updateCM.Number_of_Activities__c == null || completedModules == null)  ? 0 : ((updateCM.Number_of_Completed_Activities__c / updateCM.Number_of_Activities__c) * 100);
                            }
                            toUpdateCM.put(updateCM.Id, updateCM);
                        }
                        activityresponse =  null;
                        // cmpMemLMScontLMSmap.clear();
                    }else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        exceptionLogs.add(new Moodle_API_Error__c(Function__c = userCourseActivityFunction,
                        Contact__c = lmsIdContactMap.get(cntLMSIdsCmpEnbld[j]).Id,
                        Exception__c = me.exception_x,
                        Error_Code__c = me.errorcode,
                        Message__c = userCourseActivityFunction+'-'+me.message ,
                        Debug_Info__c = me.debuginfo));
                        
                        
                    }
                }else{
                    exceptionLogs.add(new Moodle_API_Error__c(Function__c = userCourseActivityFunction,
                    Contact__c = lmsIdContactMap.get(cntLMSIdsCmpEnbld[j]).Id,
                    Exception__c = hresp.getBody(),
                    Error_Code__c = String.valueOf(hresp.getStatusCode()),
                    Message__c = contentsFunction+'-'+hresp.getStatusCode() ,
                    Debug_Info__c = 'Response Body:'+hresp.getBody()));
                    
                    
                }
                hresp = null;
            }
            catch(Exception ex) {
                exceptionLogs.add(new Moodle_API_Error__c(Function__c = userCourseActivityFunction,
                Contact__c = lmsIdContactMap.get(cntLMSIdsCmpEnbld[j]).Id,
                Exception__c = String.valueOf(ex.getCause()),
                Error_Code__c = ex.getTypeName(),
                Message__c = ex.getmessage() ,
                Debug_Info__c = ex.getStackTraceString()));
            }
        }
        update toUpdate.values();
        update toUpdateCM.values();
        
        insert exceptionLogs;
    }
    
    @testVisible
    private class MoodleUserReturn {
        public MoodleUser[] users {get;set;}
    }
    
    @testVisible
    private class MoodleExcept {
        public String exception_x {get;set;}
        public String errorcode {get;set;}
        public String message {get;set;}
        public String debuginfo {get;set;}
    }
    
    public class MoodleCategory {
        public Integer id {get;set;}
        public String name {get;set;}
    }
    
    public class MoodleCourse {
        public Integer id {get;set;}
        public String shortname {get;set;}
    }
    
    public class MoodleGroup {
        public Integer id {get;set;}
        public Integer courseid {get;set;}
        public String name {get;set;}
        public String description {get;set;}
        public Integer descriptionformat {get;set;}
        public String enrollmentkey {get;set;}
        public String idnumber {get;set;}
    }
    
    public class MoodleUser {
        public Integer id {get;set;}
        public String username {get;set;}
    }
    public class MoodleUserCourseActivityResponse {
        public MoodleUserCourseActivityStatus[] statuses {get;set;}
        public MoodleUserCourseActivityWarning[] warnings {get;set;}
        
    }
    
    public class MoodleCourseResponse {
        public Integer id {get;set;}
        public String name {get;set;}
        public Integer visible {get;set;}
        public String summary {get;set;}
        public Integer summaryformat {get;set;}
        public Integer section {get;set;}
        public Integer hiddenbynumsections {get;set;}
        public Boolean uservisible {get;set;}
        
        public MoodleModules[] modules {get;set;}
    }
    
    public class MoodleModules {
        public Integer id {get;set;}
        public String url {get;set;}
        public String name {get;set;}
        public Integer instance {get;set;}
        public String description {get;set;}
        public Integer visible {get;set;}
        public Boolean uservisible {get;set;}
        public Integer visibleoncoursepage {get;set;}
        public String modicon {get;set;}
        public String modname {get;set;}
        public String modplural {get;set;}
        public String availability {get;set;}
        public Integer indent {get;set;}
        public String onclick {get;set;}
        public String afterlink {get;set;}
        public String customdata {get;set;}
        public Boolean noviewlink {get;set;}
        public Integer completion {get;set;}
        public MoodleCompletion completiondata {get;set;}
        public MoodleContents[] contents {get;set;}
        public MoodleContentsInfo contensinfo {get;set;}
        
    }
    
    public class MoodleContentsInfo {
        public Integer filescount {get;set;}
        public Integer filesize {get;set;}
        public Integer lastmodified {get;set;}
        public String mimetypes {get;set;}
        public String repositorytype {get;set;}
    }
    
    public class MoodleCompletion {
        public Integer state {get;set;}
        public Integer timecompleted {get;set;}
        public Integer overrideby {get;set;}
        public Boolean valueused {get;set;}
    }
    
    public class MoodleContents {
        public String type {get;set;}
        public String filename {get;set;}
        public String filepath {get;set;}
        public Integer filesize {get;set;}
        public String fileurl {get;set;}
        public String content {get;set;}
        public Integer timecreated {get;set;}
        public Integer timemodified {get;set;}
        public Integer sortorder {get;set;}
        public String mimetype {get;set;}
        public Boolean isexternalfile {get;set;}
        public String repositorytype {get;set;}
        public Integer userid {get;set;}
        public String author {get;set;}
        public String license {get;set;}
        public MoodleTag[] tags {get;set;}
    }
    
    public class MoodleTag {
        public Integer id {get;set;}
        public String name {get;set;}
        public String rawname {get;set;}
        public Integer isstandard {get;set;}
        public Integer tagcollid {get;set;}
        public Integer taginstanceid {get;set;}
        public Integer taginstancecontextid {get;set;}
        public Integer itemid {get;set;}
        public Integer ordering {get;set;}
        public Integer flag {get;set;}
    }
    
    
    
    public class MoodleUserCourseActivityStatus {
        public Integer cmid {get;set;}
        public String modname {get;set;}
        public Integer instance {get;set;}
        public Integer state {get;set;}
        public Integer timecompleted {get;set;}
        public Integer tracking {get;set;}
        public Integer overrideby {get;set;}
        public Boolean valueused {get;set;}
    }
    
    public class MoodleUserCourseActivityWarning {
        public String item {get;set;}
        public Integer itemid {get;set;}
        public String warningcode {get;set;}
        public String message {get;set;}
    }
    
    public class MoodleUserCourseResponse {
        public Integer id {get;set;}
        public String shortname {get;set;}
        public String fullname {get;set;}
        public String displayname {get;set;}
        public Integer enrolledusercount{get;set;}
        public String idnumber {get;set;}
        public Integer visible {get;set;}
        public String summary {get;set;}
        public Integer summaryformat {get;set;}
        public String format {get;set;}
        public Boolean showgrades {get;set;}
        public String lang {get;set;}
        public Boolean enablecompletion {get;set;}
        public Boolean completionhascriteria {get;set;}
        public Boolean completionusertracked {get;set;}
        public Integer category {get;set;}
        public Decimal progress {get;set;}
        public Boolean completed {get;set;}
        public Integer startdate {get;set;}
        public Integer enddate {get;set;}
        public Integer marker {get;set;}
        public Integer lastaccess {get;set;}
        public Boolean isfavourite {get;set;}
        public Boolean hidden {get;set;}
        public MoodleFile[] overviewfiles {get;set;}
    }
    
    public class MoodleFile {
        public String filename {get;set;}
        public String filepath {get;set;}
        public Integer filesize {get;set;}
        public String fileurl {get;set;}
        public Integer timemodified {get;set;}
        public String mimetype {get;set;}
        public Integer isexternalfile {get;set;}
        public String repositorytype {get;set;}
    }
    
    public class MoodleUserResponse {
        public Integer id {get;set;}
        public String username {get;set;}
        public String firstname {get;set;}
        public String lastname {get;set;}
        public String fullname {get;set;}
        public String email {get;set;}
        public String department {get;set;}
        public Long firstaccess {get;set;}
        public Long lastaccess {get;set;}
        public String auth {get;set;}
        public Boolean suspended {get;set;}
        public Boolean confirmed {get;set;}
        public String lang {get;set;}
        public String theme {get;set;}
        public String timezone {get;set;}
        public Integer mailformat {get;set;}
        public String description {get;set;}
        public Integer descriptionformat {get;set;}
        public String profileimageurlsmall {get;set;}
        public String profileimageurl {get;set;}
    }
}