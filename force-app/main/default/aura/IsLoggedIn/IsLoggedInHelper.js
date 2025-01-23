({
    getParams: function (component, event) {
        var vars = {};
        var parts = decodeURIComponent(window.location.href).replace(/[?&]+([^=&]+)=([^&]*)/gi,
            function (m, key, value) {
                vars[key] = value.replace(/\+/g, ' ');
                if (key === "u") {
                    document.cookie = 'user=' + value.replace(/\+/g, ' ') + ';secure';
                }
                if (key === "s") {
                    document.cookie = 'skey=' + value + ';secure';
                }
            });
    },
    checkIsLoggedIn: function (component, event) {
        this.getParams(component, event);
        var parts = document.cookie.split(';');
        var key = '';
        var user = '';
        for (let i = 0; i < parts.length; i++) {
            parts[i] = parts[i].trim();
            let smallerParts = parts[i].split('=');
            if (smallerParts[0] == 'user') {
                user = smallerParts[1];
            }
            else if (smallerParts[0] == 'skey') {
                key = smallerParts[1];
            }
        }
        if (user !== undefined && user !== null && user !== '' && key !== undefined && key !== null && key !== '') {
            var action = component.get("c.checkSession");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue() === 'Success') {
                        var loggedInEvent = $A.get("e.c:LoggedIn");
                        loggedInEvent.setParams({ "username": user, "key": key });
                        loggedInEvent.fire();
                    }
                    else {
                        this.returnToLogin(component, event);
                    }
                }
                else if (state === "INCOMPLETE") {
                    this.returnToLogin(component, event);
                }
                else if (state === "ERROR") {
                    this.returnToLogin(component, event);
                }
            });
            $A.enqueueAction(action);
        }
        else {
            var action = component.get("c.checkSession");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue() === 'Success') {
                        var loggedInEvent = $A.get("e.c:LoggedIn");
                        loggedInEvent.setParams({ "username": '', "key": '' });
                        loggedInEvent.fire();
                    }
                    else {
                        this.returnToLogin(component, event);
                    }
                }
                else if (state === "INCOMPLETE") {
                    this.returnToLogin(component, event);
                }
                else if (state === "ERROR") {
                    this.returnToLogin(component, event);
                }
            });
            $A.enqueueAction(action);
        }

    },
    returnToLogin: function (component, event) {
        console.error('## Return to login');
        var url = ('/' + window.location.href.split('/s/')[1]);
        var navService = component.find("navService");
        var destURL = "/?origURL=" + encodeURIComponent(url);
        if (url.startsWith('/view-event')) {
            destURL = url.replace('view-event', 'viewevent');
        }
        var pageReference = {
            "type": "standard__webPage",
            "attributes": {
                "url": destURL
            }
        };

        if (!url.startsWith('/public-courses')) {
            navService.navigate(pageReference, false);
        }
    }
})