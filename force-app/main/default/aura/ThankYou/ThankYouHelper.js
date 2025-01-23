({
	getSessions : function(component, event) {
		var vars = {};
        var hassessions = false;
        var sessions = new Array();
        var positions = new Array();
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
           		vars[key] = value;	
               if(key === "sessions") {
                   hassessions = true;
                   sessions = value.split('%2C');
               }
               else if(key == "positions") {
                   positions = value.split('%2C');
               }
       });
        if(hassessions) {
            component.set("v.waitlisted", true);
            var wlsessions = new Array();
            for(let i = 0; i < sessions.length; i++) {
                if(sessions[i] != "") {
                    var temp = {};
                    temp.name = sessions[i];
                    temp.position = positions[i];
                    wlsessions.push(temp);
                }
            }
            component.set("v.wlsessions", wlsessions);
        }
	}
})