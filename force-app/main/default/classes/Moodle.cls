public without sharing class Moodle {
    
    @future(callout=true)
    public static void CreateGroups(Id[] parentEventIds, Id[] childIds) {
        Moodle_Configuration__mdt config = [Select Id, Add_Group_Members_Function__c, Create_Groups_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        String createGroups = config.Create_Groups_Function__c;
        String body = '';
        Integer i = 0;
        Event_Relationship__c[] rels = [Select Id, Parent__c, Child__c, Parent__r.Class_Code__c, Child__r.LMS_Id__c, Parent__r.Online_Event_Name__c, Parent__r.LMS_Course_Name__c from Event_Relationship__c where Parent__c in :parentEventIds and LMS_Group_Id__c = null and Child__r.LMS_Id__c != null];
        Map<Integer, Map<String, Event_Relationship__c>> elMap = new Map<Integer, Map<String, Event_Relationship__c>>();
        for(Event_Relationship__c el : rels) {
            String name = (el.Parent__r.LMS_Course_Name__c == null || el.Parent__r.LMS_Course_Name__c == '') ? el.Parent__r.Online_Event_Name__c : el.Parent__r.LMS_Course_Name__c;
            if(el.Child__r.LMS_Id__c != null && name != null && name != '') {
                body += ('&groups[' + i.format().replaceAll(',', '') + '][courseid]=' + el.Child__r.LMS_Id__c.format().replaceAll(',', ''));
                body += ('&groups[' + i.format().replaceAll(',', '') + '][name]=' + EncodingUtil.urlEncode(name, 'UTF-8'));
                body += ('&groups[' + i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(el.Parent__c, 'UTF-8'));
                body += ('&groups[' + i.format().replaceAll(',', '') + '][description]=' + EncodingUtil.urlEncode(el.Parent__r.Class_Code__c, 'UTF-8'));
                if(!elMap.containsKey(el.Child__r.LMS_Id__c.intValue())) {
                    elMap.put(el.Child__r.LMS_Id__c.intValue(), new Map<String, Event_Relationship__c>());
                }
                elMap.get(el.Child__r.LMS_Id__c.intValue()).put(el.Parent__r.LMS_Course_Name__c, el);
                i++;
            }
        }
        
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + createGroups + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        body = body.removeStart('&');
        httpreq.setBody(body);
        System.Debug(body);
        Event_Relationship__c[] toUpdate = new Event_Relationship__c[0];
        try {
            HttpResponse hresp = h.send(httpreq);
            System.Debug(hresp.getBody());
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    MoodleGroup[] mgs = (MoodleGroup[])JSON.deserialize(hresp.getBody(), MoodleGroup[].class);
                    Id[] erIds = new Id[0];
                    for(MoodleGroup mg : mgs) { 
                        Integer courseid = mg.courseid;
                        String name = mg.name;
                        Event_Relationship__c er = elMap.get(courseid).get(name);
                        er.LMS_Group_Id__c = mg.id;
                        toUpdate.add(er);
                        erIds.add(er.Id);
                    }
                    Map<Id, Set<Id>> foundParent = new Map<Id, Set<Id>>();
                    Map<Id, Set<Id>> foundChild = new Map<Id, Set<Id>>();
                    Map<Id, Set<Id>> alreadyAdded = new Map<Id, Set<Id>>();
                    Map<Id, Decimal> lmsIds = new Map<Id, Decimal>();
                    Id[] contactIds = new Id[0];
                    for(CampaignMember cm : [Select Id, CampaignId, ContactId, Contact.LMS_Id__c from CampaignMember where CampaignId in :parentEventIds and Attendee_Status__c = 'Registered']) {
                        lmsIds.put(Cm.ContactId, cm.Contact.LMS_Id__c);
                        if(!foundParent.containsKey(cm.CampaignId)) {
                            foundParent.put(cm.CampaignId, new Set<Id>());
                        }
                        foundParent.get(cm.CampaignId).add(cm.ContactId);
                    }
                    for(CampaignMember cm : [Select Id, CampaignId, ContactId from CampaignMember where CampaignId in :childIds and Attendee_Status__c = 'Registered' and Enrolled_in_Moodle__c = true]) {
                        if(!foundChild.containsKey(cm.CampaignId)) {
                            foundChild.put(cm.CampaignId, new Set<Id>());
                        }
                        foundChild.get(cm.CampaignId).add(cm.ContactId);
                        contactIds.add(cm.ContactId);
                    }
                    for(Group_Member__c gm : [Select Id, Contact__c, Child_Event_Group__c from Group_Member__c where Child_Event_Group__c in :erIds]) {
                        if(!alreadyAdded.containsKey(gm.Child_Event_Group__c)) {
                            alreadyAdded.put(gm.Child_Event_Group__c, new Set<Id>());
                        }
                        alreadyAdded.get(gm.Child_Event_Group__c).add(gm.Contact__c);
                    }
                    Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, LMS_Id__c from Contact where Id in :contactIds]);
                    String addMembers = config.Add_Group_Members_Function__c;
                    body = '';
                    h = new Http();
                    httpreq = new HttpRequest();
                    httpreq.setTimeout(120000);
                    httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + addMembers + '&moodlewsrestformat=json'); 
                    httpreq.setMethod('POST');
                    httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    Group_Member__c[] toUpsert = new Group_Member__c[0];
                    Integer j = 0;
                    for(Event_Relationship__c er : toUpdate) {
                        if(foundParent.containsKey(er.Parent__c) && foundChild.containsKey(er.Child__c)) {
                            for(Id contactId : foundParent.get(er.Parent__c)) {
                                if(foundChild.get(er.Child__c).contains(contactId) && (!alreadyAdded.containsKey(er.Id) || !alreadyAdded.get(er.Id).contains(contactId)) && contactMap.containsKey(contactId) && contactMap.get(contactId).LMS_Id__c != null) {
                                    body += ('&members%5B' + j.format().replaceAll(',', '') + '%5D%5Bgroupid%5D=' + er.LMS_Group_Id__c.format().replaceAll(',', ''));
                                    body += ('&members%5B' + j.format().replaceAll(',', '') + '%5D%5Buserid%5D=' + contactMap.get(contactId).LMS_Id__c.format().replaceAll(',', ''));
                                    toUpsert.add(new Group_Member__c(Child_Event_Group__c = er.Id, Contact__c = contactId, Group_Member_Key__c = contactMap.get(contactId).LMS_Id__c.format().replaceAll(',', '') + '-' + er.LMS_Group_Id__c.format().replaceAll(',', '')));
                                    j++;
                                }
                            }
                        }
                    }
                    body = body.removeStart('&');
                    if(body != '') {
                        httpreq.setBody(body);
                        System.Debug(body);
                        hresp = h.send(httpreq);
                        if(hresp.getStatusCode() == 200) {
                            if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                                upsert toUpsert Group_Member_Key__c;
                            }
                            else {
                                MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                                for(Event_Relationship__c er : toUpdate) {
                                    errors.add(new Moodle_API_Error__c(Function__c = addMembers, Event_Relationship__c = er.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message + ' CreateGroups', Debug_Info__c = me.debuginfo));
                                }
                            }
                        }
                        else {
                            MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                            for(Event_Relationship__c er : toUpdate) {
                                errors.add(new Moodle_API_Error__c(Function__c = addMembers, Event_Relationship__c = er.Id, Exception__c = hresp.getStatus()));
                            }
                        }
                    }
                    update toUpdate;
                }
                else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    for(Integer j : elMap.keySet()) {
                        for(Event_Relationship__c er : elMap.get(j).values()) {
                            errors.add(new Moodle_API_Error__c(Function__c = createGroups, Event_Relationship__c = er.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                        }
                    }
                }
            }
            else {
                for(Integer j : elMap.keySet()) {
                    for(Event_Relationship__c er : elMap.get(j).values()) {
                        errors.add(new Moodle_API_Error__c(Function__c = createGroups, Event_Relationship__c = er.Id, Exception__c = hresp.getStatus()));
                    }
                }
            }	
        }
        catch(Exception ex) {
            for(Integer j : elMap.keySet()) {
                for(Event_Relationship__c er : elMap.get(j).values()) {
                    errors.add(new Moodle_API_Error__c(Function__c = createGroups, Event_Relationship__c = er.Id, Exception__c = ex.getmessage()));
                }
            }
        }
        if(errors.size() > 0)
            insert errors;
    }
    
    @future(callout=true)
    public static void updateGroups(Id[] parentEventIds) {
        Moodle_Configuration__mdt config = [Select Id, Update_Groups_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        String updateGroups = config.Update_Groups_Function__c;
        String body = '';
        Integer i = 0;
        Event_Relationship__c[] rels = [Select Id, Parent__c, Parent__r.Class_Code__c, LMS_Group_Id__c, Child__r.LMS_Id__c, Parent__r.Online_Event_Name__c, Parent__r.LMS_Course_Name__c from Event_Relationship__c where Parent__c in :parentEventIds and Child__r.LMS_Id__c != null and LMS_Group_Id__c != null];
        Map<Integer, Event_Relationship__c> elMap = new Map<Integer, Event_Relationship__c>();
        for(Event_Relationship__c el : rels) {
            String name = (el.Parent__r.LMS_Course_Name__c == null || el.Parent__r.LMS_Course_Name__c == '') ? el.Parent__r.Online_Event_Name__c : el.Parent__r.LMS_Course_Name__c;
            if(el.Child__r.LMS_Id__c != null && name != null && name != '') {
                body += ('&groups[' + i.format().replaceAll(',', '') + '][id]=' + el.LMS_Group_Id__c.format().replaceAll(',', ''));
                body += ('&groups[' + i.format().replaceAll(',', '') + '][name]=' + EncodingUtil.urlEncode(name, 'UTF-8'));
                body += ('&groups[' + i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(el.Parent__c, 'UTF-8'));
                body += ('&groups[' + i.format().replaceAll(',', '') + '][description]=' + EncodingUtil.urlEncode(el.Parent__r.Class_Code__c, 'UTF-8'));
                elMap.put(el.LMS_Group_Id__c.intValue(), el);
                i++;
            }
        }
        
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + updateGroups + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        body = body.removeStart('&');
        httpreq.setBody(body);
        System.Debug(body);
        Event_Relationship__c[] toUpdate = new Event_Relationship__c[0];
        try {
            HttpResponse hresp = h.send(httpreq);
            System.Debug(hresp.getBody());
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    MoodleGroup[] mgs = (MoodleGroup[])JSON.deserialize(hresp.getBody(), MoodleGroup[].class);
                    /*for(MoodleGroup mg : mgs) { 
Integer courseid = mg.courseid;
String name = mg.name;
Event_Relationship__c er = elMap.get(courseid).get(name);
er.LMS_Group_Id__c = mg.id;
toUpdate.add(er);
}
update toUpdate*/
                }
                else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    for(Event_Relationship__c er : elMap.values()) {
                        errors.add(new Moodle_API_Error__c(Function__c = updateGroups, Event_Relationship__c = er.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                    }
                }
            }
            else {
                for(Event_Relationship__c er : elMap.values()) {
                    errors.add(new Moodle_API_Error__c(Function__c = updateGroups, Event_Relationship__c = er.Id, Exception__c = hresp.getStatus()));
                }
            }	
        }
        catch(Exception ex) {
            for(Event_Relationship__c er : elMap.values()) {
                errors.add(new Moodle_API_Error__c(Function__c = updateGroups, Event_Relationship__c = er.Id, Exception__c = ex.getmessage()));
            }
        }
        if(errors.size() > 0)
            insert errors;
    }
    
    @future(callout=true)
    public static void deleteGroups(Integer[] groupIds) {
        Moodle_Configuration__mdt config = [Select Id, Delete_Groups_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        String deleteGroups = config.Delete_Groups_Function__c;
        String body = '';
        Integer i = 0;
        for(Integer j : groupIds) {
            body += ('&groupids[' + i.format().replaceAll(',', '') + ']=' + j.format().replaceAll(',', ''));
            i++;
        }
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + deleteGroups + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        body = body.removeStart('&');
        httpreq.setBody(body);
        System.Debug(body);
        Event_Relationship__c[] toUpdate = new Event_Relationship__c[0];
        try {
            HttpResponse hresp = h.send(httpreq);
            System.Debug(hresp.getBody());
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    for(Event_Relationship__c[] rels : [Select Id, Parent__c, Parent__r.Class_Code__c, LMS_Group_Id__c, Child__r.LMS_Id__c, Parent__r.LMS_Course_Name__c from Event_Relationship__c where LMS_Group_Id__c in :groupIds]) {
                        for(Event_Relationship__c rel : rels) {
                            rel.LMS_Group_Id__c = null;
                        }
                        update rels;
                    }
                    //MoodleGroup[] mgs = (MoodleGroup[])JSON.deserialize(hresp.getBody(), MoodleGroup[].class);
                    /*for(MoodleGroup mg : mgs) { 
Integer courseid = mg.courseid;
String name = mg.name;
Event_Relationship__c er = elMap.get(courseid).get(name);
er.LMS_Group_Id__c = mg.id;
toUpdate.add(er);
}
update toUpdate*/
                }
                else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    for(Integer j : groupIds) {
                        errors.add(new Moodle_API_Error__c(Function__c = deleteGroups, LMS_Group_Id__c = j, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                    }
                }
            }
            else {
                for(Integer j : groupIds) {
                    errors.add(new Moodle_API_Error__c(Function__c = deleteGroups, LMS_Group_Id__c = j, Exception__c = hresp.getStatus()));
                }
            }	
        }
        catch(Exception ex) {
            for(Integer j : groupIds) {
                errors.add(new Moodle_API_Error__c(Function__c = deleteGroups, LMS_Group_Id__C = j, Exception__c = ex.getmessage()));
            }
        }
        if(errors.size() > 0)
            insert errors;
    }
    
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
        for(CampaignMember cm : [Select Id, Contact.LMS_Id__c, Campaign.LMS_Id__c from CampaignMember where Contact.LMS_Id__c in :lmsIdContactMap.keySet() and Campaign.LMS_Id__c != null]) {
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
        System.Debug(''+reqBody);
        Map<Integer, Contact> toUpdate = new Map<Integer, Contact>();
        Map<Id, CampaignMember> toUpdateCM = new Map<Id, CampaignMember>();
        try {
            HttpResponse hresp = h.send(httpreq);
            System.Debug(hresp.getBody());
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
                System.Debug('Request Body Campaign Details'+reqBody);
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    System.Debug(hresp.getBody());
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        MoodleCourseResponse[] courseResponses = (MoodleCourseResponse[])JSON.deserialize(hresp.getBody(), MoodleCourseResponse[].class);
                        Integer visibleModuleCount = 0;
                        for(MoodleCourseResponse mcr : courseResponses) {
                            if(mcr.modules != null) {
                                for(MoodleModules mod : mcr.modules) {
                                    //if(mod.visible > 0 && mod.uservisible && mod.completion > 0) {
                                    //Commented mod.completion > 0 - This should be irrespective of Completion
                                    if(mod.visible > 0 && mod.uservisible) {
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
                System.Debug('User Course Request-->'+reqBody);
                try {
                    HttpResponse hresp = h.send(httpreq);
                    if(hresp.getStatusCode() == 200) {
                        System.Debug(hresp.getBody());
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
            System.Debug('User Course Activity-->'+reqBody);
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    System.Debug('User Course Activity Response-->'+hresp.getBody());
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
    
    
    @future(callout=true)
    public static void addGroupMembers(Id[] contacts, Id[] eventRelationships) {
        Moodle_Configuration__mdt config = [Select Id, Add_Group_Members_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        String addMembers = config.Add_Group_Members_Function__c;
        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, LMS_Id__c from Contact where Id in :contacts and LMS_Id__c != null]);
        Map<Id, Event_Relationship__c> eventMap = new Map<Id, Event_Relationship__c>([Select Id, LMS_Group_Id__c from Event_Relationship__c where Id in :eventRelationships and LMS_Group_Id__c != null]);
        String body = '';
        Integer i = 0;
        Integer j = 0;
        for(Id contactId : contacts) {
            if(contactMap.containsKey(contactId) && eventMap.containsKey(eventRelationships[j])) {
                body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Bgroupid%5D=' + eventMap.get(eventRelationships[j]).LMS_Group_Id__c.format().replaceAll(',', ''));
                body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Buserid%5D=' + contactMap.get(contactId).LMS_Id__c.format().replaceAll(',', ''));
                i++;
            }
            j++;
        }
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + addMembers + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        body = body.removeStart('&');
        httpreq.setBody(body);
        System.Debug(body);
        Event_Relationship__c[] toUpdate = new Event_Relationship__c[0];
        if(body != '') {
            try {
                HttpResponse hresp = h.send(httpreq);
                System.Debug(hresp.getBody());
                if(hresp.getStatusCode() == 200) {
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        Group_Member__c[] toUpsert = new Group_Member__c[0];
                        j = 0;
                        for(Id contactId : contacts) {
                            if(contactMap.containsKey(contactId) && eventMap.containsKey(eventRelationships[j])) {
                                toUpsert.add(new Group_Member__c(Child_Event_Group__c = eventRelationships[j], Contact__c = contactId, Group_Member_Key__c = contactMap.get(contactId).LMS_Id__c.format().replaceAll(',', '') + '-' + eventMap.get(eventRelationships[j]).LMS_Group_Id__c.format().replaceAll(',', '')));
                            }
                            j++;
                        }
                        upsert toUpsert Group_Member_Key__c;
                        //MoodleGroup[] mgs = (MoodleGroup[])JSON.deserialize(hresp.getBody(), MoodleGroup[].class);
                        /*for(MoodleGroup mg : mgs) { 
Integer courseid = mg.courseid;
String name = mg.name;
Event_Relationship__c er = elMap.get(courseid).get(name);
er.LMS_Group_Id__c = mg.id;
toUpdate.add(er);
}
update toUpdate*/
                    }
                    else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        j = 0;
                        for(Id contactId : contacts) {
                            errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationships[j], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message  + ' AddGroupMembers', Debug_Info__c = me.debuginfo));
                            j++;
                        }
                    }
                }
                else {
                    j = 0;
                    for(Id contactId : contacts) {
                        errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationships[j], Exception__c = hresp.getStatus()));
                        j++;
                    }
                }	
            }
            catch(Exception ex) {
                j = 0;
                for(Id contactId : contacts) {
                    errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationships[j], Exception__c = ex.getmessage()));
                    j++;
                }
            }
        }
        if(errors.size() > 0)
            insert errors;
    }
    
    
    @future(callout=true)
    public static void removeGroupMembers(Id[] groupMemberIds) {
        Moodle_Configuration__mdt config = [Select Id, Remove_Group_Members_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        String delMembers = config.Remove_Group_Members_Function__c;
        Group_Member__c[] groupMembers = [Select Id, Contact__c, Child_Event_Group__c, Contact__r.LMS_Id__c, Child_Event_Group__r.LMS_Group_Id__c from Group_Member__c where Id in :groupMemberIds and Child_Event_Group__r.LMS_Group_Id__c != null and Contact__r.LMS_Id__c != null];
        String body = '';
        Integer i = 0;
        for(Group_Member__c gm : groupMembers) {
            body += ('&members[' + i.format().replaceAll(',', '') + '][groupid]=' + gm.Child_Event_Group__r.LMS_Group_Id__c.format().replaceAll(',', ''));
            body += ('&members[' + i.format().replaceAll(',', '') + '][userid]=' + gm.Contact__r.LMS_Id__c.format().replaceAll(',', ''));
            i++;
        }
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + delMembers + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        body = body.removeStart('&');
        httpreq.setBody(body);
        System.Debug(body);
        try {
            HttpResponse hresp = h.send(httpreq);
            System.Debug(hresp.getBody());
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    delete groupMembers;
                    //MoodleGroup[] mgs = (MoodleGroup[])JSON.deserialize(hresp.getBody(), MoodleGroup[].class);
                    /*for(MoodleGroup mg : mgs) { 
Integer courseid = mg.courseid;
String name = mg.name;
Event_Relationship__c er = elMap.get(courseid).get(name);
er.LMS_Group_Id__c = mg.id;
toUpdate.add(er);
}
update toUpdate*/
                }
                else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    for(Group_Member__c gm : groupMembers) {
                        errors.add(new Moodle_API_Error__c(Function__c = delMembers, Group_Member__c = gm.Id, Contact__c = gm.Contact__c, Event_Relationship__c = gm.Child_Event_Group__c, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                    }
                }
            }
            else {
                for(Group_Member__c gm : groupMembers) {
                    errors.add(new Moodle_API_Error__c(Function__c = delMembers, Group_Member__c = gm.Id, Contact__c = gm.Contact__c, Event_Relationship__c = gm.Child_Event_Group__c,  Exception__c = hresp.getStatus()));
                }
            }	
        }
        catch(Exception ex) {
            for(Group_Member__c gm : groupMembers) {
                errors.add(new Moodle_API_Error__c(Function__c = delMembers, Group_Member__c = gm.Id, Contact__c = gm.Contact__c, Event_Relationship__c = gm.Child_Event_Group__c,  Exception__c = ex.getmessage()));
            }
        }
        if(errors.size() > 0)
            insert errors;
    }
    
    
    @future(callout=true)
    public static void UpsertEnrollment(Id[] enrollmentIds) {
        Moodle_Configuration__mdt config = [Select Id, Add_Group_Members_Function__c, Enroll_Users_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        String enrollFunction = config.Enroll_Users_Function__c;
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        CampaignMember[] insertEnrollment = [Select Id, Date_RC_Access_Starts_Formula__c, CampaignId, Event_Relationship_Generated_From__c, Event_Relationship_Generated_From__r.LMS_Group_Id__c, ContactId, Attendee_Status__c, Date_RC_Access_Ends_Formula__c, Campaign.LMS_Id__c, Contact.LMS_Id__c from CampaignMember where Id in :enrollmentIds and Campaign.LMS_Id__c != null and Campaign.Sync_To_LMS__c = true and Contact.LMS_Id__c != null];
        if(insertEnrollment.size() > 0) {
            String body = '';
            for(Integer i = 0; i < insertEnrollment.size(); i++) {
                body += '&enrolments[' +  i.format().replaceAll(',', '') + '][roleid]=5';
                body += '&enrolments[' +  i.format().replaceAll(',', '') + '][userid]=' + EncodingUtil.urlEncode(insertEnrollment[i].Contact.LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;
                if(insertEnrollment[i].Date_RC_Access_Starts_Formula__c != null) {
                    body += '&enrolments[' +  i.format().replaceAll(',', '') + '][timestart]=' + (insertEnrollment[i].Date_RC_Access_Starts_Formula__c.getTime() / 1000).format().replaceAll(',', '');
                }
                if(insertEnrollment[i].Date_RC_Access_Ends_Formula__c  != null) {
                    body += '&enrolments[' +  i.format().replaceAll(',', '') + '][timeend]=' + (insertEnrollment[i].Date_RC_Access_Ends_Formula__c.getTime() / 1000).format().replaceAll(',', '');
                }
                body += '&enrolments[' +  i.format().replaceAll(',', '') + '][courseid]=' + EncodingUtil.urlEncode(insertEnrollment[i].Campaign.LMS_Id__c.format().replaceall(',', ''), 'UTF-8') ;
                if(insertEnrollment[i].Attendee_Status__c != 'Registered') {
                    body += '&enrolments[' + i.format().replaceAll(',', '') + '][suspend]=1';
                }
            }
            body = body.removeStart('&');
            Http h = new Http();
            HttpRequest httpreq = new HttpRequest();
            httpreq.setTimeout(120000);
            httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + enrollFunction + '&moodlewsrestformat=json'); 
            httpreq.setMethod('POST');
            httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpreq.setBody(body);
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        Id[] contactGroupIds = new Id[0];
                        Id[] eventrelationshipIds = new Id[0];
                        Id[] erIds = new Id[0];
                        Id[] campaignIds = new Id[0];
                        Map<Id, Set<Id>> contactChildren = new Map<Id, Set<Id>>();
                        for(CampaignMember c : insertEnrollment) {
                            c.Additional_Enrollment_Trigger__c = false;
                            campaignIds.add(c.CampaignId);
                            if(!contactChildren.containsKey(c.ContactId)) {
                                contactChildren.put(c.ContactId, new Set<Id>());
                            }
                            contactChildren.get(c.ContactId).add(c.CampaignId);
                        }
                        Map<Id, Event_Relationship__c[]> campParents = new Map<Id, Event_Relationship__c[]>();
                        Map<Id, Set<Id>> registeredParents = new Map<Id, Set<Id>>();
                        Id[] parentIds = new Id[0];
                        for(Event_Relationship__c er : [Select Id, Parent__c, Child__c from Event_Relationship__c where Child__c in :campaignIds]) {
                            if(!campParents.containsKey(er.Child__c)) {
                                campParents.put(er.Child__c, new Event_Relationship__c[0]);
                            }
                            campParents.get(er.Child__c).add(er);
                            parentIds.add(er.Parent__c);
                        }
                        for(CampaignMember cm : [Select CampaignId, ContactId from CampaignMember where CampaignId in :parentIds and COntactId in :contactChildren.keySet() and Attendee_Status__c = 'Registered']) 
                        {
                            if(!registeredParents.containsKey(cm.ContactId)) {
                                registeredParents.put(cm.ContactId, new Set<Id>());
                            }
                            registeredParents.get(cm.ContactId).add(cm.CampaignId);
                        }
                        
                        for(CampaignMember cm : insertEnrollment) {
                            if(campParents.containsKey(cm.CampaignId) && registeredParents.containsKey(cm.ContactId)) {
                                for(Event_Relationship__c er : campParents.get(cm.CampaignId)) {
                                    if(registeredParents.get(cm.ContactId).contains(er.Parent__c)) {
                                        contactGroupIds.add(cm.ContactId);
                                        eventrelationshipIds.add(er.Id);
                                    }
                                }
                            }
                        }
                        
                        if(contactGroupIds.size() > 0) {
                            String addMembers = config.Add_Group_Members_Function__c;
                            Map<Id, Contact> contactGroupMap = new Map<Id, Contact>([Select Id, LMS_Id__c from Contact where Id in :contactGroupIds and LMS_Id__c != null]);
                            Map<Id, Event_Relationship__c> eventGroupMap = new Map<Id, Event_Relationship__c>([Select Id, LMS_Group_Id__c from Event_Relationship__c where Id in :eventRelationshipIds and LMS_Group_Id__c != null]);
                            body = '';
                            Integer i = 0;
                            Integer j = 0;
                            for(Id contactId : contactGroupIds) {
                                if(contactGroupMap.containsKey(contactId) && eventGroupMap.containsKey(eventRelationshipIds[j])) {
                                    body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Bgroupid%5D=' + eventGroupMap.get(eventRelationshipIds[j]).LMS_Group_Id__c.format().replaceAll(',', ''));
                                    body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Buserid%5D=' + contactGroupMap.get(contactId).LMS_Id__c.format().replaceAll(',', ''));
                                    i++;
                                }
                                j++;
                            }
                            h = new Http();
                            httpreq = new HttpRequest();
                            httpreq.setTimeout(120000);
                            httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + addMembers + '&moodlewsrestformat=json'); 
                            httpreq.setMethod('POST');
                            httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            body = body.removeStart('&');
                            httpreq.setBody(body);
                            System.Debug(body);
                            if(body != '') {
                                try {
                                    hresp = h.send(httpreq);
                                    System.Debug(hresp.getBody());
                                    if(hresp.getStatusCode() == 200) {
                                        if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                                            Group_Member__c[] toUpsert = new Group_Member__c[0];
                                            j = 0;
                                            for(Id contactId : contactGroupIds) {
                                                if(contactGroupMap.containsKey(contactId) && eventGroupMap.containsKey(eventRelationshipIds[j])) {
                                                    toUpsert.add(new Group_Member__c(Child_Event_Group__c = eventRelationshipIds[j], Contact__c = contactId, Group_Member_Key__c = contactGroupMap.get(contactId).LMS_Id__c.format().replaceAll(',', '') + '-' + eventGroupMap.get(eventRelationshipIds[j]).LMS_Group_Id__c.format().replaceAll(',', '')));
                                                }
                                                j++;
                                            }
                                            upsert toUpsert Group_Member_Key__c;
                                        }
                                        else {
                                            MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                                            j = 0;
                                            for(Id contactId : contactGroupIds) {
                                                errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message + ' UpsertEnrollment', Debug_Info__c = me.debuginfo));
                                                j++;
                                            }
                                        }
                                    }
                                    else {
                                        j = 0;
                                        for(Id contactId : contactGroupIds) {
                                            errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = hresp.getStatus()));
                                            j++;
                                        }
                                    }	
                                }
                                catch(Exception ex) {
                                    j = 0;
                                    for(Id contactId : contactGroupIds) {
                                        errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = ex.getmessage()));
                                        j++;
                                    }
                                }
                            }
                        }
                        update insertEnrollment;
                    }
                    else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        for(CampaignMember c : insertEnrollment) {
                            errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                        }
                    }
                }
                else {
                    for(CampaignMember c : insertEnrollment) {
                        errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = hresp.getStatus()));
                    }	
                }
            }	
            catch(Exception ex) {
                for(CampaignMember c : insertEnrollment) {
                    errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = ex.getMessage()));
                }
            }    		   				
        }
        if(errors.size() > 0)
            insert errors;
    }
    
    @future(callout=true)
    public static void DeleteEnrollment(Decimal[] campaignLMSIds, Decimal[] contactLMSIds, String[] campaignNames, String[] contactNames) {
        Moodle_Configuration__mdt config = [Select Id, Unenroll_Users_Function__c, REST_Endpoint__c, Server_URL__c, Token__c from Moodle_Configuration__mdt where Active__c = true];
        String enrollFunction = config.Unenroll_Users_Function__c;
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        if(campaignLMSIds.size() > 0) {
            String body = '';
            for(Integer i = 0; i < campaignLMSIds.size(); i++) {
                body += '&enrolments[' +  i.format().replaceAll(',', '') + '][userid]=' + EncodingUtil.urlEncode(contactLMSIds[i].format().replaceAll(',', ''), 'UTF-8') ;
                body += '&enrolments[' +  i.format().replaceAll(',', '') + '][courseid]=' + EncodingUtil.urlEncode(campaignLMSIds[i].format().replaceall(',', ''), 'UTF-8') ;
            }
            body = body.removeStart('&');
            Http h = new Http();
            HttpRequest httpreq = new HttpRequest();
            httpreq.setTimeout(120000);
            httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + enrollFunction + '&moodlewsrestformat=json'); 
            httpreq.setMethod('POST');
            httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpreq.setBody(body);
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        //for(CampaignMember c : insertEnrollment) {
                        //c.Enrolled_in_Moodle__c = true;
                        //}
                        //update insertEnrollment;
                    }
                    else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        for(Integer i = 0; i < campaignLMSIds.size(); i++) {
                            errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, User_Name__c = contactNames[i], Course_Name__c	= campaignNames[i], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                        }
                    }
                }
                else {
                    for(Integer i = 0; i < campaignLMSIds.size(); i++) {
                        errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, User_Name__c = contactNames[i], Course_Name__c	= campaignNames[i],  Exception__c = hresp.getStatus()));
                    }
                }
            }	
            catch(Exception ex) {
                for(Integer i = 0; i < campaignLMSIds.size(); i++) {
                    errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, User_Name__c = contactNames[i], Course_Name__c	= campaignNames[i],  Exception__c = ex.getMessage()));
                }
            }    		   				
        }
        if(errors.size() > 0)
            insert errors;
        
    }
    
    @future(callout=true)
    public static void DeleteUsers(Decimal[] lmsIds, String[] contactIds, String[] contactNames) {
        System.Debug(lmsIds);
        Moodle_Configuration__mdt config = [Select Id, REST_Endpoint__c, Server_URL__c, Token__c, Delete_Users_Function__c, Update_Categories_Function__c from Moodle_Configuration__mdt where Active__c = true];
        String body = '';   	
        String function = config.Delete_Users_Function__c;
        for(Integer i = 0; i < lmsIds.size(); i++) {
            body += '&userids[' +  i.format().replaceAll(',', '') + ']=' + EncodingUtil.urlEncode(lmsIds[i].format().replaceAll(',', ''), 'UTF-8') ;
        }
        body = body.removeStart('&');
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + function + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setBody(body);
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        try {
            HttpResponse hresp = h.send(httpreq);
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    for(Contact[] conts : [Select Id from Contact where Id in :contactIds]) {
                        for(Contact c : conts) {
                            c.LMS_Id__c = null;
                        }
                        update conts;
                    }
                }
                else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    for(Integer i = 0; i < lmsIds.size(); i++) {
                        errors.add(new Moodle_API_Error__c(Contact__c = contactIds[i] == '' ? null : contactIds[i], Function__c = function, User_Name__c = contactNames[i], LMS_Id__c = lmsIds[i], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                    }
                }
            }
            else {
                for(Integer i = 0; i < lmsIds.size(); i++) {
                    errors.add(new Moodle_API_Error__c(Contact__c = contactIds[i] == '' ? null : contactIds[i], Function__c = function, User_Name__c = contactNames[i], LMS_Id__c = lmsIds[i], Exception__c = hresp.getStatus()));
                }
            }
        }
        catch(Exception ex) {
            for(Integer i = 0; i < lmsIds.size(); i++) {
                errors.add(new Moodle_API_Error__c(Contact__c = contactIds[i] == '' ? null : contactIds[i], Function__c = function, User_Name__c = contactNames[i], LMS_Id__c = lmsIds[i], Exception__c = ex.getMessage()));
            }   			
        }
        if(errors.size() > 0) {
            insert errors;
        }
        else {
            for(CampaignMember[] cms : [Select Id from CampaignMember where ContactId in :contactIds]) {
                for(CampaignMember cm : cms) {
                    cm.Enrolled_in_Moodle__c = false;
                }
                update cms;
            }
        }
    }
    
    @future(callout=true)
    public static void UpsertUsers(Id[] contactIds, Boolean[] create) {
        Id[] updateUsers = new Id[0];
        Id[] insertUsers = new Id[0];
        for(Integer i = 0; i < contactIds.size(); i++) {
            if(create[i]) {
                insertUsers.add(contactIds[i]);
            }
            else {
                updateUsers.adD(contactIds[i]);
            }
        }
        Contact[] createContacts = [Select Id, FirstName, LastName, Company__c, Country_of_Residence__c, Email, LMS_Id__c, Password_New__c, User_Id__c from Contact where Id in :insertUsers];
        Contact[] updateContacts = [Select Id, FirstName, LastName, Suspend_LMS_Account__c, Company__c, Country_of_Residence__c, Email, User_Id__c, LMS_Id__c from Contact where Id in :updateUsers];
        Moodle_Configuration__mdt config = [Select Id, Enroll_Users_Function__c, Add_Group_Members_Function__c, REST_Endpoint__c, Server_URL__c, Token__c, Create_Users_Function__c, Update_Users_Function__c from Moodle_Configuration__mdt where Active__c = true];
        String createFunction = config.Create_Users_Function__c;
        String updateFunction = config.Update_Users_Function__c;
        String enrollFunction = config.Enroll_Users_Function__c;
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        if(createContacts.size() > 0) {
            String body = '';   	
            for(Integer i = 0; i < createContacts.size(); i++) {
                body += '&users[' +  i.format().replaceAll(',', '') + '][username]=' + EncodingUtil.urlEncode(createContacts[i].User_Id__c, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][password]=' + EncodingUtil.urlEncode((createContacts[i].Password_New__c == null || createContacts[i].Password_New__c == '') ? '#RJ$RJ$#OJ$#O$JFO$#J' : createContacts[i].Password_New__c, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][lastname]=' + EncodingUtil.urlEncode(createContacts[i].LastName, 'UTF-8') ;
                //body += '&users[' +  i.format().replaceAll(',', '') + '][customfields][0][type]=institution';
                //body += '&users[' +  i.format().replaceAll(',', '') + '][customfields][0][value]=' + EncodingUtil.urlEncode(createContacts[i].Company__c == null ? '' : createContacts[i].Company__c, 'UTF-8');
                
                body += '&users[' +  i.format().replaceAll(',', '') + '][country]=' + EncodingUtil.urlEncode(createContacts[i].Country_of_Residence__c == null ? '' : createContacts[i].Country_of_Residence__c, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][auth]=saml2';
                if(createContacts[i].FirstName != null)
                    body += '&users[' +  i.format().replaceAll(',', '') + '][firstname]=' + EncodingUtil.urlEncode(CreateContacts[i].FirstName, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(createContacts[i].Id, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][email]=' + EncodingUtil.urlEncode(CreateContacts[i].Email, 'UTF-8') ;
            }
            body = body.removeStart('&');
            Http h = new Http();
            HttpRequest httpreq = new HttpRequest();
            httpreq.setTimeout(120000);
            httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + createfunction + '&moodlewsrestformat=json'); 
            httpreq.setMethod('POST');
            httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpreq.setBody(body);
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        MoodleUser[] mus = (MoodleUser[])JSON.deserialize(hresp.getBody(), MoodleUser[].class);
                        for(Integer i = 0; i < mus.size(); i++ ) {
                            createContacts[i].LMS_Id__c = mus[i].id;
                        }
                    }
                    else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        for(Contact c : createContacts) {
                            errors.add(new Moodle_API_Error__c(Function__c = createFunction, Contact__c = c.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                        }
                    }
                }
                else {
                    for(Contact c : createContacts) {
                        errors.add(new Moodle_API_Error__c(Function__c = createFunction, Contact__c = c.Id, Exception__c = hresp.getStatus()));
                    }	
                }
            }	
            catch(Exception ex) {
                for(Contact c : createContacts) {
                    errors.add(new Moodle_API_Error__c(Function__c = createFunction, Contact__c = c.Id, Exception__c = ex.getMessage()));
                }
            }    			
        }
        if(updateContacts.size() > 0) {
            String body = '';   	
            for(Integer i = 0; i < updateContacts.size(); i++) {
                body += '&users[' +  i.format().replaceAll(',', '') + '][id]=' + EncodingUtil.urlEncode(updateContacts[i].LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][username]=' + EncodingUtil.urlEncode(updateContacts[i].User_Id__c, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][lastname]=' + EncodingUtil.urlEncode(updateContacts[i].LastName, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][auth]=saml2';
                //body += '&users[' +  i.format().replaceAll(',', '') + '][customfields][0][type]=institution';
                //body += '&users[' +  i.format().replaceAll(',', '') + '][customfields][0][value]=' + EncodingUtil.urlEncode(updateContacts[i].Company__c == null ? '' : updateContacts[i].Company__c, 'UTF-8');
                body += '&users[' +  i.format().replaceAll(',', '') + '][country]=' + EncodingUtil.urlEncode(updateContacts[i].Country_of_Residence__c == null ? '' : updateContacts[i].Country_of_Residence__c, 'UTF-8') ;
                if(updateContacts[i].FirstName != null)
                    body += '&users[' +  i.format().replaceAll(',', '') + '][firstname]=' + EncodingUtil.urlEncode(updateContacts[i].FirstName, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(updateContacts[i].Id, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][email]=' + EncodingUtil.urlEncode(updateContacts[i].Email, 'UTF-8') ;
                body += '&users[' +  i.format().replaceAll(',', '') + '][suspended]=' +  (updateContacts[i].Suspend_LMS_Account__c ? '1' : '0');
            }
            body = body.removeStart('&');
            Http h = new Http();
            HttpRequest httpreq = new HttpRequest();
            httpreq.setTimeout(120000);
            httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + updatefunction + '&moodlewsrestformat=json'); 
            httpreq.setMethod('POST');
            httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpreq.setBody(body);
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    }
                    else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        for(Contact c : updateContacts) {
                            errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Contact__c = c.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                        }
                    }
                }
                else {
                    for(Contact c : updateContacts) {
                        errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Contact__c = c.Id, Exception__c = hresp.getStatus()));
                    }	
                }
            }	
            catch(Exception ex) {
                for(Contact c : updateContacts) {
                    errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Contact__c = c.Id, Exception__c = ex.getMessage()));
                }
            }    			
        }
        if(createContacts.size() > 0) {
            Map<Id, Integer> contactLMSId = new Map<Id, Integer>();
            for(Contact c : createContacts) {
                if(c.LMS_Id__c != null) {
                    contactLMSId.put(c.Id, c.LMS_Id__c.intValue());
                }
            }
            CampaignMember[] toInsertC = [Select Id, Date_RC_Access_Starts_Formula__c, Event_Relationship_Generated_From__r.LMS_Group_Id__c, Event_Relationship_Generated_From__c, ContactId, Date_RC_Access_Ends_Formula__c, CampaignId, Campaign.LMS_Id__c from CampaignMember where Campaign.Sync_To_LMS__c = true and Campaign.LMS_Id__c != null and Enrolled_in_Moodle__c = false and ContactId in :contactLMSId.keySet() and Attendee_Status__c = 'Registered'];
            if(toInsertC.size() > 0) {
                String body = '';
                for(Integer i = 0; i < toInsertC.size(); i++) {
                    body += '&enrolments[' +  i.format().replaceAll(',', '') + '][roleid]=5';
                    body += '&enrolments[' +  i.format().replaceAll(',', '') + '][userid]=' + EncodingUtil.urlEncode(contactLMSId.get(toInsertC[i].ContactId).format().replaceAll(',', ''), 'UTF-8') ;
                    body += '&enrolments[' +  i.format().replaceAll(',', '') + '][courseid]=' + EncodingUtil.urlEncode(toInsertC[i].Campaign.LMS_Id__c.format().replaceall(',', ''), 'UTF-8') ;
                    if(toInsertC[i].Date_RC_Access_Starts_Formula__c  != null) {
                        body += '&enrolments[' +  i.format().replaceAll(',', '') + '][timestart]=' + (toInsertC[i].Date_RC_Access_Starts_Formula__c.getTime() / 1000).format().replaceAll(',', '');
                    }
                    if(toInsertC[i].Date_RC_Access_Ends_Formula__c  != null) {
                        body += '&enrolments[' +  i.format().replaceAll(',', '') + '][timeend]=' + (toInsertC[i].Date_RC_Access_Ends_Formula__c.getTime() / 1000).format().replaceAll(',', '');
                    }
                }
                body = body.removeStart('&');
                System.Debug(body);
                Http h = new Http();
                HttpRequest httpreq = new HttpRequest();
                httpreq.setTimeout(120000);
                httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + enrollFunction + '&moodlewsrestformat=json'); 
                httpreq.setMethod('POST');
                httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                httpreq.setBody(body);
                try {
                    HttpResponse hresp = h.send(httpreq);
                    if(hresp.getStatusCode() == 200) {
                        if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                            Id[] contactGroupIds = new Id[0];
                            Id[] eventrelationshipIds = new Id[0];
                            
                            for(CampaignMember c : toInsertC) {
                                c.Enrolled_in_Moodle__c = true;
                                if(c.Event_Relationship_Generated_From__c != null && c.Event_Relationship_Generated_From__r.LMS_Group_Id__c != null) {
                                    contactGroupIds.add(c.ContactId);
                                    eventrelationshipIds.add(c.Event_Relationship_Generated_From__c);
                                }
                            }
                            if(contactGroupIds.size() > 0) {
                                String addMembers = config.Add_Group_Members_Function__c;
                                //Map<Id, Contact> contactGroupMap = new Map<Id, Contact>([Select Id, LMS_Id__c from Contact where Id in :contactGroupIds and LMS_Id__c != null]);
                                Map<Id, Event_Relationship__c> eventGroupMap = new Map<Id, Event_Relationship__c>([Select Id, LMS_Group_Id__c from Event_Relationship__c where Id in :eventRelationshipIds and LMS_Group_Id__c != null]);
                                body = '';
                                Integer i = 0;
                                Integer j = 0;
                                for(Id contactId : contactGroupIds) {
                                    if(contactLMSId.containsKey(contactId) && eventGroupMap.containsKey(eventRelationshipIds[j])) {
                                        body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Bgroupid%5D=' + eventGroupMap.get(eventRelationshipIds[j]).LMS_Group_Id__c.format().replaceAll(',', ''));
                                        body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Buserid%5D=' + contactLMSId.get(contactId).format().replaceAll(',', ''));
                                        i++;
                                    }
                                    j++;
                                }
                                h = new Http();
                                httpreq = new HttpRequest();
                                httpreq.setTimeout(120000);
                                httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + addMembers + '&moodlewsrestformat=json'); 
                                httpreq.setMethod('POST');
                                httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                                body = body.removeStart('&');
                                httpreq.setBody(body);
                                System.Debug(body);
                                if(body != '') {
                                    try {
                                        hresp = h.send(httpreq);
                                        System.Debug(hresp.getBody());
                                        if(hresp.getStatusCode() == 200) {
                                            if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                                                Group_Member__c[] toUpsert = new Group_Member__c[0];
                                                j = 0;
                                                for(Id contactId : contactGroupIds) {
                                                    if(contactLMSId.containsKey(contactId) && eventGroupMap.containsKey(eventRelationshipIds[j])) {
                                                        toUpsert.add(new Group_Member__c(Child_Event_Group__c = eventRelationshipIds[j], Contact__c = contactId, Group_Member_Key__c = contactLMSId.get(contactId).format().replaceAll(',', '') + '-' + eventGroupMap.get(eventRelationshipIds[j]).LMS_Group_Id__c.format().replaceAll(',', '')));
                                                    }
                                                    j++;
                                                }
                                                upsert toUpsert Group_Member_Key__c;
                                            }
                                            else {
                                                MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                                                j = 0;
                                                for(Id contactId : contactGroupIds) {
                                                    errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message + ' UpsertUsers', Debug_Info__c = me.debuginfo));
                                                    j++;
                                                }
                                            }
                                        }
                                        else {
                                            j = 0;
                                            for(Id contactId : contactGroupIds) {
                                                errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = hresp.getStatus()));
                                                j++;
                                            }
                                        }	
                                    }
                                    catch(Exception ex) {
                                        j = 0;
                                        for(Id contactId : contactGroupIds) {
                                            errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = ex.getmessage()));
                                            j++;
                                        }
                                    }
                                }
                            }
                            update toInsertC;
                        }
                        else {
                            MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                            for(CampaignMember c : toInsertC) {
                                errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                            }
                        }
                    }
                    else {
                        for(CampaignMember c : toInsertC) {
                            errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = hresp.getStatus()));
                        }	
                    }
                }	
                catch(Exception ex) {
                    for(CampaignMember c : toInsertC) {
                        errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = ex.getMessage()));
                    }
                }    		   				
            }
            update createContacts;
        }
        if(errors.size() > 0) {
            insert errors;
        }
    }
    
    @future(callout=true)
    public static void UpsertCategories(Id[] accountIds, Boolean create) {
        Account[] accounts = [Select Id, Name, Description, LMS_Id__c from Account where Id in :accountIds];
        Moodle_Configuration__mdt config = [Select Id, REST_Endpoint__c, Server_URL__c, Token__c, Create_Categories_Function__c, Update_Categories_Function__c from Moodle_Configuration__mdt where Active__c = true];
        String body = '';   	
        String function = create ? config.Create_Categories_Function__c : config.Update_Categories_Function__c;
        for(Integer i = 0; i < accounts.size(); i++) {
            body += '&categories[' +  i.format().replaceAll(',', '') + '][name]=' + EncodingUtil.urlEncode(accounts[i].Name, 'UTF-8') ;
            body += '&categories[' +  i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(accounts[i].Id, 'UTF-8') ;
            if(accounts[i].Description != null)
                body += '&categories[' +  i.format().replaceAll(',', '') + '][description]=' + EncodingUtil.urlEncode(accounts[i].Description, 'UTF-8') ;
            body += '&categories[' +  i.format().replaceAll(',', '') + '][descriptionformat]=2';
            if(!create) {
                body += '&categories[' +  i.format().replaceAll(',', '') + '][id]=' + EncodingUtil.urlEncode(accounts[i].LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;	
            }
        }
        body = body.removeStart('&');
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + function + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setBody(body);
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        try {
            HttpResponse hresp = h.send(httpreq);
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    MoodleCategory[] mcs = (MoodleCategory[])JSON.deserialize(hresp.getBody(), MoodleCategory[].class);
                    if(create) {
                        for(Integer i = 0; i < mcs.size(); i++ ) {
                            accounts[i].LMS_Id__c = mcs[i].id;
                        }
                        update accounts;
                    }
                }
                else {
                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                    for(Account a : accounts) {
                        errors.add(new Moodle_API_Error__c(Function__c = function, Account__c = a.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                    }
                }
            }
            else {
                for(Account a : accounts) {
                    errors.add(new Moodle_API_Error__c(Function__c = function, Account__c = a.Id, Exception__c = hresp.getStatus()));
                }
            }
        }
        catch(Exception ex) {
            for(Account a : accounts) {
                errors.add(new Moodle_API_Error__c(Function__c = function, Account__c = a.Id, Exception__c = ex.getMessage()));
            }
        }
        if(errors.size() > 0) {
            insert errors;
        }
        
    }
    
    @future(callout=true)
    public static void UpsertCoursesAndInsertCampaigns(Id[] campaignIds, Id[] accountIds, Boolean[] create) {
        Map<Id, Decimal> lmsIdMap = new Map<Id, Decimal>();
        Account[] accounts = [Select Id, Name, Description, LMS_Id__c from Account where Id in :accountIds];
        Moodle_Configuration__mdt config = [Select Id, REST_Endpoint__c, Server_URL__c, Token__c, Enroll_Users_Function__c, Create_Courses_Function__c, Update_Courses_Function__c, Create_Categories_Function__c, Add_Group_Members_Function__c from Moodle_Configuration__mdt where Active__c = true];
        String body = '';   	
        String function = config.Create_Categories_Function__c ;
        for(Integer i = 0; i < accounts.size(); i++) {
            body += '&categories[' +  i.format().replaceAll(',', '') + '][name]=' + EncodingUtil.urlEncode(accounts[i].Name, 'UTF-8') ;
            body += '&categories[' +  i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(accounts[i].Id, 'UTF-8') ;
            if(accounts[i].Description != null)
                body += '&categories[' +  i.format().replaceAll(',', '') + '][description]=' + EncodingUtil.urlEncode(accounts[i].Description, 'UTF-8') ;
            body += '&categories[' +  i.format().replaceAll(',', '') + '][descriptionformat]=2';
        }
        body = body.removeStart('&');
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + function + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setBody(body);
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        if(accounts.size() > 0) {
            try {
                HttpResponse hresp = h.send(httpreq);
                if(hresp.getStatusCode() == 200) {
                    if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                        MoodleCategory[] mcs = (MoodleCategory[])JSON.deserialize(hresp.getBody(), MoodleCategory[].class);
                        for(Integer i = 0; i < mcs.size(); i++ ) {
                            accounts[i].LMS_Id__c = mcs[i].id;
                            lmsIdMap.put(accounts[i].Id, mcs[i].id);
                        }
                    }
                    else {
                        MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                        for(Account a : accounts) {
                            errors.add(new Moodle_API_Error__c(Function__c = function, Account__c = a.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                        }
                    }
                }
                else {
                    for(Account a : accounts) {
                        errors.add(new Moodle_API_Error__c(Function__c = function, Account__c = a.Id, Exception__c = hresp.getStatus()));
                    }
                }
            }
            catch(Exception ex) {
                for(Account a : accounts) {
                    errors.add(new Moodle_API_Error__c(Function__c = function, Account__c = a.Id, Exception__c = ex.getMessage()));
                }
            }
        }
        if(errors.size() > 0) {
            insert errors;
        }
        else {
            Id[] createIds = new Id[0];
            Id[] updateIds = new Id[0];
            for(Integer i = 0; i < campaignIds.size(); i++) {
                if(create[i]) {
                    createIds.add(campaignIds[i]);
                }
                else {
                    updateIds.add(campaignIds[i]);
                }
            }
            Campaign[] createCampaigns = [Select Id, Visible_on_LMS__c, LMS_Course_Name__c, Class_Code__c, Date_RC_Access_Ends__c, Registration_From__c, RT_Description__c, LMS_Id__c, Account__c, Account__r.LMS_Id__c from Campaign where Id in :createIds];
            Campaign[] updateCampaigns = [Select Id, Visible_on_LMS__c, LMS_Course_Name__c, Class_Code__c, Date_RC_Access_Ends__c, Registration_From__c, RT_Description__c, LMS_Id__c, Account__c, Account__r.LMS_Id__c from Campaign where Id in :updateIds];
            String createFunction = config.Create_Courses_Function__c;
            String updateFunction = config.Update_Courses_Function__c;
            if(createIds.size() > 0) {
                body = '';   	
                for(Integer i = 0; i < createCampaigns.size(); i++) {
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][fullname]=' + EncodingUtil.urlEncode((createCampaigns[i].LMS_Course_Name__c == null ? '' : createCampaigns[i].LMS_Course_Name__c), 'UTF-8') ;
                    body += '&courses[' + i.format().replaceAll(',', '') + '][visible]=' +  (createCampaigns[i].Visible_on_LMS__c ? '1' : '0');
                    if(createCampaigns[i].Class_Code__c != null)
                        body += '&courses[' +  i.format().replaceAll(',', '') + '][shortname]=' + EncodingUtil.urlEncode(createCampaigns[i].LMS_Course_Name__c == null ?  '' : createCampaigns[i].LMS_Course_Name__c, 'UTF-8') ;
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(createCampaigns[i].Id, 'UTF-8') ;
                    if(createCampaigns[i].Registration_From__c != null)
                        body += '&courses[' +  i.format().replaceAll(',', '') + '][startdate]=' + (createCampaigns[i].Registration_From__c.getTime() / 1000).format().replaceAll(',', '');
                    if(createCampaigns[i].Date_RC_Access_Ends__c != null)
                        body += '&courses[' +  i.format().replaceAll(',', '') + '][enddate]=' + (createCampaigns[i].Date_RC_Access_Ends__c.getTime() / 1000).format().replaceAll(',', '') ;
                    //if(createCampaigns[i].RT_Description__c != null)
                    //body += '&courses[' +  i.format().replaceAll(',', '') + '][summary]=' + EncodingUtil.urlEncode(createCampaigns[i].RT_Description__c, 'UTF-8') ;
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][categoryid]=' + EncodingUtil.urlEncode(createCampaigns[i].Account__r.LMS_Id__c == null ? lmsIdMap.get(createCampaigns[i].Account__c).format().replaceAll(',', '') : createCampaigns[i].Account__r.LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;
                }
                body = body.removeStart('&');
                h = new Http();
                httpreq = new HttpRequest();
                httpreq.setTimeout(120000);
                httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + createFunction + '&moodlewsrestformat=json'); 
                httpreq.setMethod('POST');
                httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                httpreq.setBody(body);
                try {
                    HttpResponse hresp = h.send(httpreq);
                    if(hresp.getStatusCode() == 200) {
                        System.Debug(hresp.getBody());
                        if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                            MoodleCourse[] mcs = (MoodleCourse[])JSON.deserialize(hresp.getBody(), MoodleCourse[].class);
                            for(Integer i = 0; i < mcs.size(); i++ ) {
                                createCampaigns[i].LMS_Id__c = mcs[i].id;
                            }
                        }
                        else {
                            MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                            for(Campaign c : updateCampaigns) {
                                errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Campaign__c = c.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                            }
                        }
                    }
                    else {
                        for(Campaign c : createCampaigns) {
                            errors.add(new Moodle_API_Error__c(Function__c = createFunction, Campaign__c = c.Id, Exception__c = hresp.getStatus()));
                        }	
                    }
                }	
                catch(Exception ex) {
                    for(Campaign c : createCampaigns) {
                        errors.add(new Moodle_API_Error__c(Function__c = createFunction, Campaign__c = c.Id, Exception__c = ex.getMessage()));
                    }
                }    			
            }
            if(updateIds.size() > 0) {
                body = '';   	
                for(Integer i = 0; i < updateCampaigns.size(); i++) {
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][fullname]=' + EncodingUtil.urlEncode((updateCampaigns[i].LMS_Course_Name__c == null ? '' : updateCampaigns[i].LMS_Course_Name__c), 'UTF-8') ;
                    body += '&courses[' + i.format().replaceAll(',', '') + '][visible]=' +  (updateCampaigns[i].Visible_on_LMS__c ? '1' : '0');
                    if(updateCampaigns[i].Class_Code__c != null)
                        body += '&courses[' +  i.format().replaceAll(',', '') + '][shortname]=' + EncodingUtil.urlEncode(updateCampaigns[i].LMS_Course_Name__c == null ? '' : updateCampaigns[i].LMS_Course_Name__c, 'UTF-8') ;
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][idnumber]=' + EncodingUtil.urlEncode(updateCampaigns[i].Id, 'UTF-8') ;
                    if(updateCampaigns[i].Registration_From__c  != null)
                        body += '&courses[' +  i.format().replaceAll(',', '') + '][startdate]=' + (updateCampaigns[i].Registration_From__c.getTime() / 1000).format().replaceAll(',', '') ;
                    if(updateCampaigns[i].Date_RC_Access_Ends__c != null)
                        body += '&courses[' +  i.format().replaceAll(',', '') + '][enddate]=' + (updateCampaigns[i].Date_RC_Access_Ends__c.getTime() / 1000).format().replaceAll(',', '') ;
                    //if(updateCampaigns[i].RT_Description__c != null)
                    //	body += '&courses[' +  i.format().replaceAll(',', '') + '][summary]=' + EncodingUtil.urlEncode(updateCampaigns[i].RT_Description__c, 'UTF-8') ;
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][id]=' + EncodingUtil.urlEncode(updateCampaigns[i].LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;
                    body += '&courses[' +  i.format().replaceAll(',', '') + '][categoryid]=' + EncodingUtil.urlEncode(updateCampaigns[i].Account__r.LMS_Id__c == null ? lmsIdMap.get(createCampaigns[i].Account__c).format().replaceAll(',', '') : updateCampaigns[i].Account__r.LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;	
                }
                body = body.removeStart('&');
                System.Debug(body);
                h = new Http();
                httpreq = new HttpRequest();
                httpreq.setTimeout(120000);
                httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + updateFunction + '&moodlewsrestformat=json'); 
                httpreq.setMethod('POST');
                httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                httpreq.setBody(body);
                try {
                    HttpResponse hresp = h.send(httpreq);
                    if(hresp.getStatusCode() == 200) {
                        System.Debug(hresp.getBody());
                        if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                            
                        }
                        else {
                            MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                            for(Campaign c : updateCampaigns) {
                                errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Campaign__c = c.Id, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                            }
                        }
                    }
                    else {
                        for(Campaign c : updateCampaigns) {
                            errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Campaign__c = c.Id, Exception__c = hresp.getStatus()));
                        }	
                    }
                }	
                catch(Exception ex) {
                    for(Campaign c : updateCampaigns) {
                        errors.add(new Moodle_API_Error__c(Function__c = updateFunction, Campaign__c = c.Id, Exception__c = ex.getMessage()));
                    }
                }    			
            }
            if(createCampaigns.size() > 0) {
                String enrollFunction = config.Enroll_Users_Function__c;
                Map<Id, Integer> campaignLMSId = new Map<Id, Integer>();
                for(Campaign c : createCampaigns) {
                    if(c.LMS_Id__c != null)
                        campaignLMSId.put(c.Id, c.LMS_Id__c.intValue());
                }
                CampaignMember[] toInsertC = [Select Id, Contact.LMS_Id__c, Date_RC_Access_Starts_Formula__c, ContactId, CampaignId, Campaign.LMS_Id__c, Date_RC_Access_Ends_Formula__c,  Event_Relationship_Generated_From__c, Event_Relationship_Generated_From__r.LMS_Group_Id__c from CampaignMember where Contact.LMS_Id__c != null and Enrolled_in_Moodle__c = false and CampaignId in :campaignLMSId.keySet() and Attendee_Status__c = 'Registered'];
                if(toInsertC.size() > 0) {
                    body = '';
                    for(Integer i = 0; i < toInsertC.size(); i++) {
                        body += '&enrolments[' +  i.format().replaceAll(',', '') + '][roleid]=5';
                        body += '&enrolments[' +  i.format().replaceAll(',', '') + '][userid]=' + EncodingUtil.urlEncode(toInsertC[i].Contact.LMS_Id__c.format().replaceAll(',', ''), 'UTF-8') ;
                        body += '&enrolments[' +  i.format().replaceAll(',', '') + '][courseid]=' + EncodingUtil.urlEncode(campaignLMSId.get(toInsertC[i].CampaignId).format().replaceAll(',', ''), 'UTF-8') ;
                        if(toInsertC[i].Date_RC_Access_Starts_Formula__c  != null) {
                            body += '&enrolments[' +  i.format().replaceAll(',', '') + '][timestart]=' + (toinsertC[i].Date_RC_Access_Starts_Formula__c.getTime() / 1000).format().replaceAll(',', '');
                        }
                        if(toInsertC[i].Date_RC_Access_Ends_Formula__c  != null) {
                            body += '&enrolments[' +  i.format().replaceAll(',', '') + '][timeend]=' + (toInsertC[i].Date_RC_Access_Ends_Formula__c.getTime() / 1000).format().replaceAll(',', '');
                        }
                    }
                    body = body.removeStart('&');
                    h = new Http();
                    httpreq = new HttpRequest();
                    httpreq.setTimeout(120000);
                    httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + enrollFunction + '&moodlewsrestformat=json'); 
                    httpreq.setMethod('POST');
                    httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    httpreq.setBody(body);
                    try {
                        HttpResponse hresp = h.send(httpreq);
                        if(hresp.getStatusCode() == 200) {
                            if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                                Id[] contactGroupIds = new Id[0];
                                Id[] eventrelationshipIds = new Id[0];
                                
                                for(CampaignMember c : toInsertC) {
                                    c.Enrolled_in_Moodle__c = true;
                                    if(c.Event_Relationship_Generated_From__c != null && c.Event_Relationship_Generated_From__r.LMS_Group_Id__c != null) {
                                        contactGroupIds.add(c.ContactId);
                                        eventrelationshipIds.add(c.Event_Relationship_Generated_From__c);
                                    }
                                }
                                if(contactGroupIds.size() > 0) {
                                    String addMembers = config.Add_Group_Members_Function__c;
                                    Map<Id, Contact> contactGroupMap = new Map<Id, Contact>([Select Id, LMS_Id__c from Contact where Id in :contactGroupIds and LMS_Id__c != null]);
                                    Map<Id, Event_Relationship__c> eventGroupMap = new Map<Id, Event_Relationship__c>([Select Id, LMS_Group_Id__c from Event_Relationship__c where Id in :eventRelationshipIds and LMS_Group_Id__c != null]);
                                    body = '';
                                    Integer i = 0;
                                    Integer j = 0;
                                    for(Id contactId : contactGroupIds) {
                                        if(contactGroupMap.containsKey(contactId) && eventGroupMap.containsKey(eventRelationshipIds[j])) {
                                            body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Bgroupid%5D=' + eventGroupMap.get(eventRelationshipIds[j]).LMS_Group_Id__c.format().replaceAll(',', ''));
                                            body += ('&members%5B' + i.format().replaceAll(',', '') + '%5D%5Buserid%5D=' + contactGroupMap.get(contactId).LMS_Id__c.format().replaceAll(',', ''));
                                            i++;
                                        }
                                        j++;
                                    }
                                    h = new Http();
                                    httpreq = new HttpRequest();
                                    httpreq.setTimeout(120000);
                                    httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + addMembers + '&moodlewsrestformat=json'); 
                                    httpreq.setMethod('POST');
                                    httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                                    body = body.removeStart('&');
                                    httpreq.setBody(body);
                                    System.Debug(body);
                                    if(body != '') {
                                        try {
                                            hresp = h.send(httpreq);
                                            System.Debug(hresp.getBody());
                                            if(hresp.getStatusCode() == 200) {
                                                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                                                    Group_Member__c[] toUpsert = new Group_Member__c[0];
                                                    j = 0;
                                                    for(Id contactId : contactGroupIds) {
                                                        if(contactGroupMap.containsKey(contactId) && eventGroupMap.containsKey(eventRelationshipIds[j])) {
                                                            toUpsert.add(new Group_Member__c(Child_Event_Group__c = eventRelationshipIds[j], Contact__c = contactId, Group_Member_Key__c = contactGroupMap.get(contactId).LMS_Id__c.format().replaceAll(',', '') + '-' + eventGroupMap.get(eventRelationshipIds[j]).LMS_Group_Id__c.format().replaceAll(',', '')));
                                                        }
                                                        j++;
                                                    }
                                                    upsert toUpsert Group_Member_Key__c;
                                                }
                                                else {
                                                    MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                                                    j = 0;
                                                    for(Id contactId : contactGroupIds) {
                                                        errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message + ' UpsertUsers2', Debug_Info__c = me.debuginfo));
                                                        j++;
                                                    }
                                                }
                                            }
                                            else {
                                                j = 0;
                                                for(Id contactId : contactGroupIds) {
                                                    errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = hresp.getStatus()));
                                                    j++;
                                                }
                                            }	
                                        }
                                        catch(Exception ex) {
                                            j = 0;
                                            for(Id contactId : contactGroupIds) {
                                                errors.add(new Moodle_API_Error__c(Function__c = addMembers, Contact__c = contactId, Event_Relationship__c = eventRelationshipIds[j], Exception__c = ex.getmessage()));
                                                j++;
                                            }
                                        }
                                    }
                                }
                                update toInsertC;
                            }
                            else {
                                MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
                                for(CampaignMember c : toInsertC) {
                                    errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
                                }
                            }
                        }
                        else {
                            for(CampaignMember c : toInsertC) {
                                errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = hresp.getStatus()));
                            }	
                        }
                    }	
                    catch(Exception ex) {
                        for(CampaignMember c : toInsertC) {
                            errors.add(new Moodle_API_Error__c(Function__c = enrollFunction, Contact__c = c.ContactId, Campaign__c = c.CampaignId, Exception__c = ex.getMessage()));
                        }
                    }    		   				
                }
                update createCampaigns;
            }
            if(accounts.size() > 0) {
                update accounts;
            }
            if(errors.size() > 0) {
                insert errors;
            }
        }
    }
    
    @future(callout=true)
    public static void DeleteCourses(Decimal[] lmsIds, String[] courseNames, String[] courseIds) {
        /*Moodle_Configuration__mdt config = [Select Id, REST_Endpoint__c, Server_URL__c, Token__c, Delete_Courses_Function__c, Update_Categories_Function__c from Moodle_Configuration__mdt where Active__c = true];
String body = '';   	
String function = config.Delete_Courses_Function__c;
for(Integer i = 0; i < lmsIds.size(); i++) {
body += '&courseids[' +  i.format().replaceAll(',', '') + ']=' + EncodingUtil.urlEncode(lmsIds[i].format().replaceAll(',', ''), 'UTF-8') ;
}
body = body.removeStart('&');
Http h = new Http();
HttpRequest httpreq = new HttpRequest();
httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + function + '&moodlewsrestformat=json'); 
httpreq.setMethod('POST');
httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
httpreq.setBody(body);
Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
try {
HttpResponse hresp = h.send(httpreq);
if(hresp.getStatusCode() == 200) {
if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
for(Campaign[] camps : [Select Id from Campaign where Id in :courseIds]) {
for(Campaign c : camps) {
c.LMS_Id__c = null;
}
update camps;
}
}
else {
MoodleExcept me = (MoodleExcept)JSON.deserialize(hresp.getBody().replace('"exception"', '"exception_x"'), MoodleExcept.class);
for(Integer i = 0; i < lmsIds.size(); i++) {
errors.add(new Moodle_API_Error__c(Campaign__c = courseIds[i] == '' ? null : courseIds[i], Function__c = function, Course_Name__c = courseNames[i], LMS_Id__c = lmsIds[i], Exception__c = me.exception_x, Error_Code__c = me.errorcode, Message__c = me.message, Debug_Info__c = me.debuginfo));
}
}
}
else {
for(Integer i = 0; i < lmsIds.size(); i++) {
errors.add(new Moodle_API_Error__c(Campaign__c = courseIds[i] == '' ? null : courseIds[i], Function__c = function, Course_Name__c = courseNames[i], LMS_Id__c = lmsIds[i], Exception__c = hresp.getStatus()));
}
}
}
catch(Exception ex) {
for(Integer i = 0; i < lmsIds.size(); i++) {
errors.add(new Moodle_API_Error__c(Campaign__c = courseIds[i] == '' ? null : courseIds[i], Function__c = function, Course_Name__c = courseNames[i], LMS_Id__c = lmsIds[i], Exception__c = ex.getMessage()));
}   			
}
if(errors.size() > 0) {
insert errors;
}
else {
for(CampaignMember[] cms : [Select Id from CampaignMember where CampaignId in :courseIds]) {
for(CampaignMember cm : cms) {
cm.Enrolled_in_Moodle__c = false;
}
update cms;
}*/
        //}
    }
    
    public static Boolean CheckUser(String username) {
        Moodle_Configuration__mdt config = [Select Id, REST_Endpoint__c, Server_URL__c, Token__c, Delete_Courses_Function__c, Update_Categories_Function__c, Get_Users_Function__c from Moodle_Configuration__mdt where Active__c = true];
        String body = 'field=username&values[0]=' + username.toLowerCase();   	
        String function = config.Get_Users_Function__c;
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        httpreq.setTimeout(120000);
        httpreq.setEndpoint(config.Server_URL__c + config.REST_Endpoint__c + '?wstoken=' + config.Token__c + '&wsfunction=' + function + '&moodlewsrestformat=json'); 
        httpreq.setMethod('POST');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setBody(body);
        Moodle_API_Error__c[] errors = new Moodle_API_Error__c[0];
        try {
            HttpResponse hresp = h.send(httpreq);
            if(hresp.getStatusCode() == 200) {
                if(hresp.getBody() != null && !hresp.getBody().contains('"exception":')) {
                    System.Debug(hresp.getBody());
                    MoodleUserResponse[] responseUsers = (MoodleUserResponse[])JSON.deserialize(hresp.getBody(), MoodleUserResponse[].class);
                    if(responseUsers != null && responseUsers.size() > 0) {
                        return true;
                    }
                }
                else {
                }
            }
        }
        catch(Exception ex) {
        }
        return false;
    }
    //public static void UpsertCourses(Id[] campaignIds, Boolean create) {z
    
    
    private class MoodleUserReturn {
        public MoodleUser[] users {get;set;}
    }
    
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