({
	loggedIn : function(component, event, helper) {
		document.getElementById('logonav').href = 'mycourses';
	},
	scriptsLoaded : function(component, event, helper) {
		jQuery('#menu-main-navigation,#menu-main-navigation-1').smartmenus({
			subMenusSubOffsetX: 1,
			subMenusSubOffsetY: -8
		});
		jQuery(window).scroll(function() {
			if (jQuery(".navbar").offset().top > 50) {
				jQuery(".navbar-fixed-top").addClass("top-nav-collapse");
			} else {
				jQuery(".navbar-fixed-top").removeClass("top-nav-collapse");
			}
		});
	}
})