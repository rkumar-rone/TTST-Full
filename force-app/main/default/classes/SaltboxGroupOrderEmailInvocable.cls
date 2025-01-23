public without sharing class SaltboxGroupOrderEmailInvocable {

    public class GroupOrderEmailRequest {
        @InvocableVariable (required=true) public String sender;
        @InvocableVariable (required=true) public String subject;
        @InvocableVariable (required=true) public String generatedRegistrationLink;
        @InvocableVariable (required=true) public String orderAccountName;
        @InvocableVariable (required=true) public String fromCompanyUniversity;
        @InvocableVariable (required=true) public String templateName;
        @InvocableVariable (required=true) public String personAccountId;
        @InvocableVariable (required=true) public String decisionMakerEmail;
        @InvocableVariable (required=true) public List<Group_Recepient__c> groupRecepients;
    }

    @InvocableMethod (label='SaltboxGroupOrderEmailInvocable - Send Group Order Email' description = 'Sends an email for a Group Order. \nSender must be a verified org-wide email address')
    public static List<String> sendGroupOrderEmail(List<GroupOrderEmailRequest> rawRequest) {
        
        List<String> response = new List<String>();
        if (rawRequest.isEmpty()) {
            response.add('Request is empty');
            System.debug('>>> response: '+response);
            return response;
        }

        GroupOrderEmailRequest request = rawRequest.get(0);

        List<String> groupRecipientsIds = new List<String>();

        for (Group_Recepient__c gr : request.groupRecepients) {
            groupRecipientsIds.add(gr.Id);
        }

        List<Group_Recepient__c> groupRecepientsList = [SELECT Id, Recepient_Email__c, First_Name__c, Last_Name__c, TTS_Event__r.Name FROM Group_Recepient__c WHERE Id IN :groupRecipientsIds];

        Messaging.SingleEmailMessage emailMessage;
        String[] toAddress;

        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = :request.sender];
        if (owea.isEmpty()) {
            response.add('Sender email address is not a verified org-wide email address');
            System.debug('>>> response: '+response);
            return response;
        }

        String templateHtmlFull = [SELECT HtmlValue FROM EmailTemplate WHERE Name= :request.templateName LIMIT 1].HtmlValue;
        if (String.isBlank(templateHtmlFull)) {
            response.add('Could not find the template for Group Orders named "'+request.templateName+'"');
            System.debug('>>> response: '+response);
            return response;
        }
        String templateHtml;

        List<String> mergeFieldsToCheck = new List<String>();

        mergeFieldsToCheck.add('{RegistrationLink}');
        mergeFieldsToCheck.add('{CourseName}');
        mergeFieldsToCheck.add('{OrderAccountName}');
        mergeFieldsToCheck.add('{FromCompanyUniversity}');
        mergeFieldsToCheck.add('{RecipientFirstname}');
        mergeFieldsToCheck.add('{RecipientLastname}');

        for (String mergeField : mergeFieldsToCheck) {
            if (!templateHtmlFull.contains(mergeField)) {
                response.add('The email template "'+request.templateName+'" does not cointains the text indicator "'+mergeField+'"');
                System.debug('>>> response: '+response);
                return response;
            }
        }

        String emailBody;
        String wholeEmailBody;
        String[] ccAdress;

        Messaging.SingleEmailMessage[] emailsToSend = new Messaging.SingleEmailMessage[]{};

        for (Group_Recepient__c gr : groupRecepientsList) {
            emailMessage = new Messaging.SingleEmailMessage();

            toAddress = new List<String>();
            toAddress.add(gr.Recepient_Email__c);
            emailMessage.setToAddresses(toAddress);

            emailMessage.setSubject(request.subject);
            
            if ( owea.size() > 0 ) {
                emailMessage.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            if (!String.isBlank(templateHtmlFull)) {
                templateHtml = templateHtmlFull;
            }
            
            emailBody = templateHtml;
            wholeEmailBody = emailBody;
            for (String mergeField : mergeFieldsToCheck) {
                emailBody = wholeEmailBody.substringBefore(mergeField);
                System.debug('>>> mergeField: '+mergeField);
                if (mergeField == '{RegistrationLink}') {
                    emailBody = emailBody + '<a href=\''+request.generatedRegistrationLink+gr.Id+'\'>'+request.generatedRegistrationLink+gr.Id+'</a>';
                }
                if (mergeField == '{CourseName}') {
                    emailBody = emailBody + gr.TTS_Event__r.Name;
                }
                if (mergeField == '{RecipientFirstname}') {
                    emailBody = emailBody + gr.First_Name__c;
                }
                if (mergeField == '{RecipientLastname}') {
                    emailBody = emailBody + gr.Last_Name__c;
                }
                if (mergeField == '{OrderAccountName}') {
                    emailBody = emailBody + request.orderAccountName;
                }
                if (mergeField == '{FromCompanyUniversity}') {
                    if (request.fromCompanyUniversity != 'Null') {
                        emailBody = emailBody + 'from ' + request.fromCompanyUniversity;
                    }
                }
                emailBody = emailBody + wholeEmailBody.substringAfter(mergeField);
                wholeEmailBody = emailBody;
            }
            emailMessage.setHtmlBody(emailBody);

            emailMessage.setWhatId(request.personAccountId);
            //String personAccountEmail = [SELECT PersonEmail FROM Account WHERE Id = :request.personAccountId LIMIT 1].PersonEmail;
            ccAdress = new List<String>();
            //ccAdress.add(personAccountEmail);

            ccAdress.add(request.decisionMakerEmail);

            emailMessage.setCcAddresses(ccAdress);

            emailsToSend.add(emailMessage);
        }

        try{
            List<Messaging.SendEmailResult> rawResult = Messaging.sendEmail(emailsToSend);
            Messaging.SendEmailResult result = rawResult.get(0);
            if (result.isSuccess()) {
                response.add('Success');
                System.debug('>>> response: '+response);
            return response;
            }else {
                response.add('An error happened while sending the email: '+result.getErrors());
                System.debug('>>> response: '+response);
            return response;
            }
        }catch(exception e){
            response.add('An error happened while sending the email: '+e.getMessage());
            System.debug('>>> response: '+response);
            return response;
        }

    }
}