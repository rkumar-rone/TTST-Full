({
	login : function(component, event, helper) {
        component.set("v.login", true);
        var cmpTarget = component.find('logintab');
        $A.util.addClass(cmpTarget, 'active');
        cmpTarget = component.find('signuptab');
        $A.util.removeClass(cmpTarget, 'active');
	},
    signup : function(component, event, helper) {
        component.set("v.login", false);
        var cmpTarget = component.find('signuptab');
        $A.util.addClass(cmpTarget, 'active');
        cmpTarget = component.find('logintab');
        $A.util.removeClass(cmpTarget, 'active');
	}
})