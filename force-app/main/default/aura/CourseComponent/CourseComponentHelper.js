({
    getCourse : function(component, event) {
        var vars = {};
        var courseid = '';
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
           		vars[key] = value;	
               if(key === "id") {
                   courseid = value;
               }
       });
       component.set("v.courseid", courseid);
    },
	loadCourse : function(component, event) {
        component.set("v.errormessage", null);
        var courseid = component.get("v.courseid");
        if(courseid !== undefined && courseid !== null && courseid !== '') {
            var action = component.get("c.loadCourse");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key"),
                              courseid : courseid});
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() !== null) {
                        if(!response.getReturnValue().hasError) {
                        	component.set("v.course", response.getReturnValue());
                        	var bring = response.getReturnValue().c.What_to_Bring__c;
                        	var bringparts = ((bring === undefined || bring === null) ? new Array() : bring.split(';'));
                        	component.set("v.bring", bringparts);
                        	var included = response.getReturnValue().c.What_s_Included_in_the_Cost__c;
                        	var includedparts = ((included === undefined || included === null) ? new Array() : included.split(';'));
                        	component.set("v.included", includedparts);
                        }
                        else {
                            component.set("v.errormessage", response.getReturnValue().error);
                        }
                    }
                    else {
                        component.set("v.errormessage", "Error Loading the Course.");
                        
                    }
            	}
            	else if (state === "INCOMPLETE") {

            	}
            	else if (state === "ERROR") {
                	var errors = response.getError();
                	if (errors) {
                    	if (errors[0] && errors[0].message) {
                        component.set("v.errormessage", errors[0].message);
                    }
                	} else {
                    	component.set("v.errormessage", "Unknown error");
                	}
            	}
        	});
        	$A.enqueueAction(action);
        }
        else {
            component.set("v.errormessage", "Error Loading the Course.");
        }
	},
    register : function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
	       	"isredirect": true,
	        "url": "/register-course?id=" + component.get("v.courseid")
		});
		urlEvent.fire();
    },
    logIn : function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
	       	"isredirect": true,
	        "url": ("/?origURL=" + encodeURIComponent('/register-course?id=' + component.get("v.courseid")))
		});
		urlEvent.fire();
    }
})