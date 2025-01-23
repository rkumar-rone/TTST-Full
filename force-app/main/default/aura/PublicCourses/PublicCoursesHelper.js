({
        loadDefaults: function (component, event) {
        var vars = {};
        var parts = decodeURIComponent(window.location.href.replace('+', ' ')).replace(/[?&]+([^=&]+)=([^&]*)/gi,
            function (m, key, value) {
                value = decodeURIComponent(value.replace(/\+/g, ' '));
                vars[key] = decodeURIComponent(value);
                if (key === "ttseventdes") {
                    component.set("v.selectedcourse", value);
                }
                else if (key === "city") {
                    component.set("v.selectedcity", value);
                }
                else if (key === "month") {
                    component.set("v.selectedmonth", value);
                }
                else if (key === "year") {
                    component.set("v.selectedyear", value);
                }
            });
    },
    loadIsSandbox: function (component, event) {
        var action = component.get("c.getIsSandbox");
        var helper = this;
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isSandbox", response.getReturnValue());
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
    loadChoices: function (component, event) {
        var action = component.get("c.getPicklists");
        var helper = this;
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.coursetypes", response.getReturnValue().courses);
                component.set("v.months", response.getReturnValue().months);
                component.set("v.cities", response.getReturnValue().cities);
                component.set("v.deliveryFormats", response.getReturnValue().deliveryFormats);
                component.set("v.years", response.getReturnValue().years);
                /*window.setTimeout(
                    $A.getCallback( function() {
                    component.set("v.selectedyear", (new Date()).getFullYear());    	
                    helper.loadCourses(component, event);
                      }));*/
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
    loadCourses: function (component, event) {
        var action = component.get("c.getAllCourses");
        var selectedCourse = component.get("v.selectedcourse");
        var selectedMonth = component.get("v.selectedmonth");
        var selectedCity = component.get("v.selectedcity");
        var selectedDeliveryFormat = component.get("v.selectedDeliveryFormat");
        var selectedYear = component.get("v.selectedyear");
        var monthTranslation = { January: 1, February: 2, March: 3, April: 4, May: 5, June: 6, July: 7, August: 8, September: 9, October: 10, November: 11, December: 12 };
        if (selectedMonth === 'All Months')
            selectedMonth = null;
        else {
            selectedMonth = monthTranslation[selectedMonth];
        }
        action.setParams({ course: selectedCourse, month: selectedMonth, city: selectedCity, deliveryFormat: selectedDeliveryFormat, year: selectedYear });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.courses", response.getReturnValue());
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
})