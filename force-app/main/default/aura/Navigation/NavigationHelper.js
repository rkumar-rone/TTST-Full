({
	setNav : function(component, event) {
        var page = window.location.href.split('/s/')[1];
        if(page.startsWith('profile')) {
        	$A.util.addClass(component.find('profile'), 'selected');
        }
        else if(page.startsWith('mycourses')) {
            $A.util.addClass(component.find('mycourses'), 'selected');
        }
        else if(page.startsWith('events')) {
            $A.util.addClass(component.find('events'), 'selected');
        }
        else if(page.startsWith('courses')) {
            $A.util.addClass(component.find('courses'), 'selected');
        }

	}
})