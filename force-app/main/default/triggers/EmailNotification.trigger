trigger EmailNotification on Task (before insert, after insert, after update) {
    if(Trigger.IsAfter && Trigger.Isinsert){
        /** Setting the email body in comments field for task T-00371 **/
        Map<String,String> ContTaskIds = new Map<String,String>();
        for(Task T : Trigger.New){
            if(T.Description != null && (T.Description == 'Registration Email -- Academic Participants' ||
               T.Description == 'Registration Email -- Corporate Participants' || T.Description == 'Public Event' ||
               T.Description == 'Academic Participants' || T.Description == 'Automate Logistic Email for Public Course 5 Day Core Comprehesive' 
               || T.Description == 'Financial Modeling' || T.Description == 'Email to POST FM') && 
               T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
               
                ContTaskIds.put(T.WhoId,T.Id);
            }
        }
        
        Map<String,String> TaskContMap = new Map<String,String>();
        for(Contact c : [select Id, Name, Email from Contact where Id in: ContTaskIds.keySet()]){
            TaskContMap.put(ContTaskIds.get(C.Id),C.Email);
        }
        
        /*EmailTemplate ET = new EmailTemplate();
        for(EmailTemplate E : [Select id,name,body,subject from emailtemplate where name = 'Registration Email -- Academic Participants' limit 1]){
            ET = E;
        }
        
        EmailTemplate ET1 = new EmailTemplate();
        for(EmailTemplate E : [Select id,name,body,subject from emailtemplate where name = 'S-01805: Email notification to Academic participants based on Event Description' limit 1]){
            ET1= E;
        }
        
        EmailTemplate ET2 = new EmailTemplate();
        for(EmailTemplate E : [Select id,name,body,subject from emailtemplate where name = 'S-01806: Email notification to Public Event participants' limit 1]){
            ET2 = E;
        }
        
        EmailTemplate ET3 = new EmailTemplate();
        for(EmailTemplate E : [Select id,name,body,subject from emailtemplate where name = 'S-01321: Automate Logistic Email for Public Course 5 Day Core Comprehesive' limit 1]){
            ET3 = E;
        }
        
        EmailTemplate ET4 = new EmailTemplate();
        for(EmailTemplate E : [Select id,name,body,subject from emailtemplate where name = 'S-02396: As an instructor, I need MBA Pre FM to Academic Participants MBA PRE FM' limit 1]){
            ET4 = E;
        }
        
        EmailTemplate ET5 = new EmailTemplate();
        for(EmailTemplate E : [Select id,name,body,subject from emailtemplate where name = 'S-01823: Email to POST FM' limit 1]){
            ET5 = E;
        }*/
        
        List<Task> TList = new List<Task>();
        for(Task T : Trigger.New){
            if(T.Description != null && T.Description == 'Registration Email -- Academic Participants' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET = [Select id,name,body,subject from emailtemplate where name = 'Registration Email -- Academic Participants' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET.body != null)
                T1.Description += ET.body;
                
                TList.add(T1);
            }
            else if(T.Description != null && T.Description == 'Registration Email -- Corporate Participants' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET1 = [Select id,name,body,subject from emailtemplate where name = 'S-01805: Email notification to Academic participants based on Event Description' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET1.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET1.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET1.body != null)
                T1.Description += ET1.body;
                
                TList.add(T1);
            }
            else if(T.Description != null && T.Description == 'Public Event' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET2 = [Select id,name,body,subject from emailtemplate where name = 'S-01806: Email notification to Public Event participants' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET2.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET2.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET2.body != null)
                T1.Description += ET2.body;
                
                TList.add(T1);
            }
            else if(T.Description != null && T.Description == 'Academic Participants' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET1 = [Select id,name,body,subject from emailtemplate where name = 'S-01805: Email notification to Academic participants based on Event Description' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET1.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET1.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET1.body != null)
                T1.Description += ET1.body;
                
                TList.add(T1);
            }
            else if(T.Description != null && T.Description == 'Automate Logistic Email for Public Course 5 Day Core Comprehesive' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET3 = [Select id,name,body,subject from emailtemplate where name = 'S-01321: Automate Logistic Email for Public Course 5 Day Core Comprehesive' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET3.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET3.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET3.body != null)
                T1.Description += ET3.body;
                
                TList.add(T1);
            }
            else if(T.Description != null && T.Description == 'Financial Modeling' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET4 = [Select id,name,body,subject from emailtemplate where name = 'S-02396: As an instructor, I need MBA Pre FM to Academic Participants MBA PRE FM' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET4.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET4.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET4.body != null)
                T1.Description += ET4.body;
                
                TList.add(T1);
            }
            else if(T.Description != null && T.Description == 'Email to POST FM' && T.WhoId != null && (String.valueOf(T.WhoId)).startsWith('003')){
                EmailTemplate ET5 = [Select id,name,body,subject from emailtemplate where name = 'S-01823: Email to POST FM' limit 1];
                Task T1 = new Task(Id=T.Id);
                T1.subject = ET5.Subject;
                T1.Description = 'Additional To: '+TaskContMap.get(T.Id)+'\n';
                T1.Description += 'CC:'+'\n';
                T1.Description += 'BCC:'+'\n';
                T1.Description += 'Attachment:'+'\n\n';
                T1.Description += 'Subject: '+ET5.Subject+'\n';
                T1.Description += 'Body:'+'\n';
                
                if(ET5.body != null)
                T1.Description += ET5.body;
                
                TList.add(T1);
            }
            
        }

        if (!Test.IsRunningTest()) {
            update TList;
        }
        
        /** **/
    }
    
    if(trigger.isUpdate){    
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>(); 
        set<Id> idSetForCampaign = new set<Id>();  
        list<string> emaillist = new list<string>();
        //  list<user> listuser = new list<user>([select id from user where name ='Rainmaker Admin']);
        //  system.debug('userlist'+listuser);
        map<String ,TaskEmailSetting__c> maps = TaskEmailSetting__c.getall();
        
        for(TaskEmailSetting__c s : maps.values()){
            emaillist.add(s.email__c);
        }
        system.debug('gggg'+emaillist);
        
        string idPrefix ='';
        for(task t : trigger.new){
            if(t.WhatId != null && t.id != null){
                idPrefix = String.valueOf(t.WhatId);
            }
            if(idPrefix.startsWith('701')){
                idSetForCampaign.add(t.WhatId);
            }
        }
        
        // list<EmailTemplate> et=[Select id,name from EmailTemplate where name = 'RC Task Complete' limit 1];
            system.debug('idididid'+idSetForCampaign);
            list<Campaign> listToCampignToQuery = new list<Campaign>([Select id,Generate_RC_Tasks__c,name,(select id,Status,Subject,WhatId from Tasks ) from Campaign where ID IN : idSetForCampaign]);
            
                
                if(!listToCampignToQuery.isEmpty()){
                for(Campaign c : listToCampignToQuery){
                    if(c.Generate_RC_Tasks__c == true){
                        for(Task tt : c.Tasks){
                            if(tt.id != null && tt.Status == 'Completed' && tt.Subject.startsWith('RC:') && trigger.oldMap.containskey(tt.Id) && trigger.oldMap.get(tt.Id).Status != 'Completed'){
                                
                            
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                
                                
                                    email.setToAddresses(emaillist);
                                    //  email.setTargetObjectId(u);
                                    //  email.saveAsActivity = false;
                                    email.setSubject('The '+ tt.Subject + ' on '+ c.name +' Event is Complete');
                                    email.setHtmlBody('This message is to alert you that the Task '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ tt.id +' has been Completed.'+'<br/><br/>Subject Name: '+tt.Subject +'<br/><br/> Event Name: '+c.name +' '+    URL.getSalesforceBaseUrl().toExternalForm()+'/'+ c.id );
                                    emailMessageList.add(email);
                                    system.debug('*****in if loop---');
                                
                                }
                            
                        }
                    
                    }
                }
                if(!emailMessageList.IsEmpty()){
                        Messaging.sendEmail(emailMessageList);
                }
        }
    }   
}