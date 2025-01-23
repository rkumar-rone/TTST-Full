({
	doInit: function(component, event, helper) {
		var self = window.location.toString();
		var querystring = self.split("?");
		if (querystring.length > 1) {
			var pairs = querystring[1].split("&");
			for (i in pairs) {
				var keyval = pairs[i].split("=");
				if (keyval.startsWith('utm')) {
					document.cookie = keyval[0] + "=" + decodeURIComponent(keyval[1]) + "; path=/";
				}
			}
		}
    }
})