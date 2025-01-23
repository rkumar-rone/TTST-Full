({
	logout : function(component, event) {
		var parts = document.cookie.split(';');
        var key = '';
        var user = '';
        for(let i = 0; i < parts.length; i++) {
        	parts[i] = parts[i].trim();
            let smallerParts = parts[i].split('=');
            if(smallerParts[0] == 'user') {
                user = smallerParts[1];
            }
            else if(smallerParts[0] == 'skey')  {
                key = smallerParts[1];
            }
        }
        if(user !== undefined && user !== null && user !== '' && key !== undefined && key !== null && key !== '') {
            var action = component.get("c.logout");
        	action.setParams({ username : user,
                              key : key});
	        action.setCallback(this, function(response) {
		        this.returnToLogin(component,event);
        	});
        	$A.enqueueAction(action);
        }
        else {
            this.returnToLogin(component, event);
        }

	},
    returnToLogin : function(component,event) {
        var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
	    	"isredirect": true,
	        "url": "/"
		});
		urlEvent.fire();
    }
})