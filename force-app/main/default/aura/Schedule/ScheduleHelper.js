({
    loadCourses: function (component, event) {
        var action = component.get("c.loadSchedule");
        action.setParams({
            username: component.get("v.username"),
            key: component.get("v.key"),
            courseType: component.get("v.selectedtype"),
            courseStudyType: component.get("v.selectedstudytype")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let respval = response.getReturnValue();
                if (respval !== null) {
                    if (respval.success) {
                        component.set("v.courses", respval.scheds);
                        component.set("v.hasonline", respval.hasonline);
                        component.set("v.moodleURL", respval.moodleURL);
                    }
                    else {
                        component.set("v.errormessage", respval.error);
                    }
                }
                else {
                    component.set("v.errormessage", "Error Loading the Schedule.");

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
    handleShowModal: function (component, event) {
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:CancelCourse", {
                "username": component.get("v.username"),
                "key": component.get("v.key"),
                "campaignMemberId": event.currentTarget.getAttribute("data-value"),
                "courseName": event.currentTarget.getAttribute("data-coursename")  
            }],
            ["c:CancelCourseFooter", { "campaignMemberId": event.currentTarget.getAttribute("data-value") }]
        ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find('overlayLib').showCustomModal({
                        header: "Cancel Course?",
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: false,
                        closeCallback: function () {
                        }
                    })
                }
            });
    },
    handleShowEdit: function (component, event) {
        component.set("v.onlyonecourse", event.currentTarget.getAttribute("data-onlycourse")  );
    },
    addSessions: function (component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "isredirect": true,
            "url": "/s/register-course?id=" + event.currentTarget.getAttribute("data-value")
        });
        urlEvent.fire();
    },
    viewMoodle: function (component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "isredirect": true,
            "url": event.getSource().get("v.value")
        });
        urlEvent.fire();
    }
})