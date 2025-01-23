({
    hoverWait : function(component, event) {
        if(event.currentTarget.nextSibling.classList.contains("hidetip")) {
        	event.currentTarget.nextSibling.classList.remove("hidetip");
        }
    },
	clickWait : function(component, event) {
        if(event.currentTarget.nextSibling.classList.contains("hidetip")) {
        	event.currentTarget.nextSibling.classList.remove("hidetip");
        }
        else {
            event.currentTarget.nextSibling.classList.add("hidetip");
        }
    },
    hoverOutWait : function(component, event) {
        if(!event.currentTarget.nextSibling.classList.contains("hidetip")) {
        	event.currentTarget.nextSibling.classList.add("hidetip");
        }
    },
    changeColor : function(component, event) {
    	let coup = component.find("coupon");
        let butt = component.find("addcoupon");
        let val = coup.get("v.value");
        if(val !== undefined && val !== null && val !== '') {
           	$A.util.removeClass(coup, 'blank');
            $A.util.addClass(butt, 'slds-button_brand');
            $A.util.removeClass(butt, 'slds-button_neutral');
        }
        else {
            $A.util.addClass(coup, 'blank');
            $A.util.addClass(butt, 'slds-button_neutral');
            $A.util.removeClass(butt, 'slds-button_brand');
        }
    },
    toggleAccordion : function(component, event) {
        if(event.currentTarget.parentElement.classList.contains('collapsed')) {
        	event.currentTarget.parentElement.classList.remove('collapsed');
        }
        else {
        	event.currentTarget.parentElement.classList.add('collapsed');
        }
        event.preventDefault();
    },
    loadYears: function(component, event) {
        let year = (new Date()).getFullYear();
        let yeararr = new Array();
        for(let i = 0; i < 10; i++) {
            yeararr.push(year + i);
        }
        component.set("v.years", yeararr);
    },
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
                        component.set("v.course", response.getReturnValue());
                        if(response.getReturnValue().c.Do_Not_Display_Sessions__c) {
                            component.set("v.fullcourse", true);
                            this.changeTotal(component, event, false);
                        }
                        var bring = response.getReturnValue().c.What_to_Bring__c;
                        var bringparts = ((bring === undefined || bring === null) ? new Array() : bring.split(';'));
                        component.set("v.bring", bringparts);
                        var included = response.getReturnValue().c.What_s_Included_in_the_Cost__c;
                        var includedparts = ((included === undefined || included === null) ? new Array() : included.split(';'));
                        component.set("v.included", includedparts);
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
    changeTotal : function(component, event, toggle) {
        component.set("v.errormessage", null);
        component.set("v.couponerror", null);
        var sessions = new Array();
        var sessList = component.find("sess");
        if(Array.isArray(sessList)) {
            for(let i = 0; i < sessList.length; i++) {
                if(sessList[i].get("v.checked")) {
                    sessions.push(sessList[i].get("v.id"));
                }
            }
        }
        else if(sessList !== undefined) {
            if(sessList.get("v.checked"))
            	sessions.push(sessList.get("v.id"));
        }
        var courseid = component.get("v.courseid");
        var fullcourse = component.get("v.fullcourse");
        var coupon = component.get("v.coupon")
        if(courseid !== undefined && courseid !== null && courseid !== '') {
            var action = component.get("c.getTotal");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key"),
                              courseid : courseid,
                              full : fullcourse,
                              sessions : sessions,
                              coupon : coupon === undefined ? null : coupon
                             });
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() !== null) {
                        component.set("v.total", response.getReturnValue().total);
                        component.set("v.grandtotal", response.getReturnValue().grandTotal);
                        component.set("v.discount", response.getReturnValue().discount);
                        component.set("v.earlydiscount", response.getReturnValue().earlyDiscount);
                        component.set("v.alreadypaid", response.getReturnValue().alreadyPaid);
                        component.set("v.couponerror", response.getReturnValue().couponError);
                    }
                    else {
                        component.set("v.errormessage", "Error getting total.");
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
            component.set("v.errormessage", "Error Loading the total.");
        }
    },
    register : function(component, event) {
       component.set("v.showAffirm", false);
       var course = component.get("v.course");
       var sendAffirm = (course.c.Affirmation_Statement__c !== undefined && course.c.Affirmation_Statement__c !== null && course.c.Affirmation_Statement__c !== '') ? true : false;
	   event.getSource().set("v.disabled", true);
       var sessions = new Array();
       var sessList = component.find("sess");
       var waitlisted = false;
       var waitlistedCourses = new Array();
       if(Array.isArray(sessList)) {
           for(let i = 0; i < sessList.length; i++) {
                if(sessList[i].get("v.checked")) {
                    sessions.push(sessList[i].get("v.id"));
                    if(sessList[i].get("v.waitlisted")) {
                        waitlisted = true;
                        waitlistedCourses.push(sessList[i].get("v.label"))
                    }
                }
            }
        }
        else if(sessList !== undefined) {
            if(sessList.get("v.checked")) {
                sessions.push(sessList.get("v.id"));
                if(sessList.get("v.waitlisted")) {
                    waitlisted = true;
                    waitlistedCourses.push(sessList.get("v.label"))
                }
            }
        }
        var confirmwaitlist = component.get("v.confirmwaitlist");
        if(!waitlisted || confirmwaitlist) {
            var courseid = component.get("v.courseid");
            var fullcourse = component.get("v.fullcourse");
            if(sessions.length > 0 || fullcourse) {
            	var coupon = component.get("v.coupon")
                if(sendAffirm && !component.get("v.affirm")) {
                    component.set("v.showAffirm", true);
                    event.getSource().set("v.disabled", false);
                }
                else {
        	    if(courseid !== undefined && courseid !== null && courseid !== '') {
    	            var action = component.get("c.register");
	                action.setParams({ username : component.get("v.username"),
    	                              key : component.get("v.key"),
    	                            courseid : courseid,
	                                full : fullcourse,
	                                sessions : sessions,
	                                coupon : coupon === undefined ? null : coupon,
    	                              first : component.get("v.firstname"),
	                                last : component.get("v.lastname"),
	                                street : component.get("v.address"),
	                                city : component.get("v.city"),
	                                state : component.get("v.state"),
	                                zip : component.get("v.zip"),
	                                country : component.get("v.country"),
	                                phone : component.get("v.phone"),
    	                              cardno : component.get("v.cardno"),
	                                expm : component.get("v.month"),
	                                expy : component.get("v.year"),
    	                              cv : component.get("v.cvv"),
	                                cholderemail : component.get("v.cholderemail"),
                                    customquestion : component.get("v.customquestion"),
                                    affirm : sendAffirm ? component.get("v.affirm") : false,
                                    email : component.get("v.email")
	                                });
		            action.setCallback(this, function(response) {
    			        var state = response.getState();
                        event.getSource().set("v.disabled", false);
	        	        if (state === "SUCCESS") {
    	                    if(response.getReturnValue() !== null) {
	                            if(response.getReturnValue().success) {
    	                            /*var urlend = "";
	                                if(response.getReturnValue().sessions != null && response.getReturnValue().sessions != "") {
    	                                urlend += "?sessions=" + response.getReturnValue().sessions;
	                                }   
	                                if(response.getReturnValue().positions != null && response.getReturnValue().positions != "") {
    	                                urlend += "&positions=" + response.getReturnValue().positions;
	                                }*/
	                                var urlEvent = $A.get("e.force:navigateToURL");
                                    //"url": "/s/mycourses" + ((response.getReturnValue().sessionId === undefined || response.getReturnValue().sessionId === null || response.getReturnValue().sessionId === '') ? '' : ("?sess=" + response.getReturnValue().sessionId)) //+ urlend
    					 				urlEvent.setParams({
		                				    "isredirect": true,
                                            "url": "/s/register-confirm" + ((response.getReturnValue().sessionId === undefined || response.getReturnValue().sessionId === null || response.getReturnValue().sessionId === '') ? '' : ("?sess=" + response.getReturnValue().sessionId)) //+ urlend
    								});
					    		    urlEvent.fire();
	                            }
	                            else {
    	                        	component.set("v.errormessage", response.getReturnValue().error);    
	                            }
	                        }
    	                    else {
	                            component.set("v.errormessage", "Error getting total.");
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
    	            component.set("v.errormessage", "Error Loading the total.");
    	        } 
                }
            }
            else {
                component.set("v.errormessage", "You must make a course selection above.");
                event.getSource().set("v.disabled", false);
            }
        }
        else {
            this.showConfirm(component, event, waitlistedCourses);
        }
    },
    cancel : function(component, event) {
    	var courseid = component.get("v.courseid");
        var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
	    	"isredirect": true,
	    	"url": "/view-event?id=" + courseid
		});
		urlEvent.fire();
	},
    populateInfo : function(component, event) {
        component.set("v.cholderemail", "");
        var action = component.get("c.getPersonalInfo");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key")
                             });
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() !== null) {
                        component.set("v.firstname", response.getReturnValue().firstName);
                        component.set("v.lastname", response.getReturnValue().lastName);
                        component.set("v.address", response.getReturnValue().address);
                        component.set("v.city", response.getReturnValue().city);
                        component.set("v.state", response.getReturnValue().state);
                        component.set("v.zip", response.getReturnValue().postalCode);
                        component.set("v.country", response.getReturnValue().country);
                        component.set("v.phone", response.getReturnValue().mobile);
                        component.set("v.cholderemail", response.getReturnValue().cholderemail);
                        component.set("v.email", response.getReturnValue().email);
                    }
                    else {
                        component.set("v.errormessage", "Error getting personal info.");
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
    },
    clearInfo : function(component, event) {
        component.set("v.firstname", "");
        component.set("v.lastname", "");
        component.set("v.street", "");
        component.set("v.city", "");
        component.set("v.state", "");
        component.set("v.zip", "");
        component.set("v.country", "");
        component.set("v.phone", "");
        //component.set("v.email", "");
    },
    showConfirm : function(component, event, courses) {
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:RegisterWaitlist", {"courses" : courses}],
            ["c:RegisterWaitlistFooter", {}]
            				],
           function(components, status, errormessage) {
               if (status === "SUCCESS") {
                   modalBody = components[0];
                   modalFooter = components[1];
                   component.find('overlayLib').showCustomModal({
                       header: "Confirm Waiting List?",
                       body: modalBody, 
                       footer: modalFooter,
                       showCloseButton: false,
                       closeCallback: function() {
                        event.getSource().set("v.disabled", false);
                       }
                   })
               }                               
           });
    }
})