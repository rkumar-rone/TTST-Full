({
	showConfirm : function(component, event) {
        let vars = {};
        let sess = '';
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
          		vars[key] = value;	
               if(key === "sess") {
                   sess = value;
               }
       	});
        if(sess !== '') {
            var action = component.get("c.getSessionDetails");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key"),
                              sess : sess
                             });
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() !== null) {
                        component.set("v.firstName", response.getReturnValue().Contact__r.FirstName);
                        component.set("v.lastName", response.getReturnValue().Contact__r.LastName);
                        component.set("v.email", response.getReturnValue().Contact__r.Email);
                        component.set("v.cost", response.getReturnValue().Final_Cost__c);
                        component.set("v.status", response.getReturnValue().Status__c);
                        component.set("v.eventName", response.getReturnValue().Online_Event_Name__c);
                        component.set("v.classCode", response.getReturnValue().Class_Code__c);
                        var message = "";
                        message += response.getReturnValue().Contact__r.Email;
                        if(response.getReturnValue().Cardholder_Email__c !== undefined && response.getReturnValue().Cardholder_Email__c !== null && response.getReturnValue().Cardholder_Email__c !== '' && response.getReturnValue().Cardholder_Email__c !== response.getReturnValue().Contact__r.Email) {
                            message += ("<br />" + response.getReturnValue().Cardholder_Email__c);
                        }
                        component.set("v.emails", message);
                        /*
                        alert(gtag);
                        gtag('event', 'purchase');//, {'firstName' : response.getReturnValue().Contact__r.FirstName, 'lastName' : response.getReturnValue().Contact__r.LastName, 'email' : response.getReturnValue().Contact__r.Email, 'cost' : response.getReturnValue().Final_Cost__c, 'status' : response.getReturnValue().Status__c, 'event' : response.getReturnValue().Online_Event_Name__c});
                        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteractionGtag");
                            analyticsInteraction.setParams({
                                event : 'purchase',
                                event_category : 'ecommerce',
                                event_label : 'TTS Registration',
                                value: 
                            });
            analyticsInteraction.fire();*/
                        var cookieString = "; " + document.cookie;
                        var source = '';
                        var name = '';
                        var medium = '';
                        var parts = cookieString.split("; utm_source=");
                        if (parts.length === 2) {
                            source = parts.pop().split(";").shift();
                        }
                        var parts = cookieString.split("; utm_campaign=");
                        if (parts.length === 2) {
                            name = parts.pop().split(";").shift();
                        }
                        var parts = cookieString.split("; utm_medium=");
                        if (parts.length === 2) {
                            medium = parts.pop().split(";").shift();
                        }
                        if(source !== '' || name !== '' || medium !== '') {
                            const pushToDataLayerUTM = new CustomEvent('updateGTMdataLayer', {'detail' : { 'campaign' : {'medium' : medium, 'source' : source, 'name' : name}}});
                            document.dispatchEvent(pushToDataLayerUTM);
                        }
                        const pushToDataLayer = new CustomEvent('updateGTMdataLayer', {'detail' : { 'event' : 'purchase', details : {'firstName' : response.getReturnValue().Contact__r.FirstName, 'lastName' : response.getReturnValue().Contact__r.LastName, 'email' : response.getReturnValue().Contact__r.Email, 'cost' : response.getReturnValue().Final_Cost__c, 'status' : response.getReturnValue().Status__c, 'event' : response.getReturnValue().Online_Event_Name__c, 'class_code' : response.getReturnValue().Class_Code__c} }});
                        document.dispatchEvent(pushToDataLayer);
                        /*setTimeout(function() {
                            window.location.href = 'mycourses?sess=' + sess;
                            }, 5000);*/
                    }
            	}
        	});
        	$A.enqueueAction(action);
        }
	}
})