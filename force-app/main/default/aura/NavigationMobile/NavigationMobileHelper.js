({
	setNav : function(component, event) {
        let page = window.location.href.split('/s/')[1];
       
        if(page.startsWith('profile')) {
        	component.set("v.profile", true);
        }
        else if(page.startsWith('mycourses')) {
            component.set("v.mycourses", true);
        }
        else if(page.startsWith('events')) {
            component.set("v.events", true);
        }
        else if(page.startsWith('courses')) {
            component.set("v.courses", true);
        }

	}
})