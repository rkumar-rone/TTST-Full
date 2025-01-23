(function() {

    function populateCJEventCookie()
    {
        let params = getUrlVars(window.location.href);
        //let domain = 'trainingthestreet.com';
        let domain = 'trainingthestreet--fullcopy.sandbox.my.site.com';
        if(params.hasOwnProperty('cjevent'))
        {
            const date = new Date();
            date.setTime(date.getTime() + (395 * 24 * 60 * 60 * 1000));
            let expires = "; expires=" + date.toGMTString();
            console.log('CJ Event Value : '+params['cjevent']);
            document.cookie = 'cje='+params['cjevent']+';domain=' + domain + ';path=/;secure;' + expires;
        }
    }

    function getUrlVars(urlParams) {
        var vars = [], hash;
        if(urlParams)
        {
            var hashes = urlParams.slice(urlParams.indexOf('?') + 1).split('&');
            for (var i = 0; i < hashes.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
        }
        return vars;
    }
    // this makes the sayHello function available in the window     namespace
    // so we can call window.sayHello from any LWC JS file
    window.populateCJEventCookie = populateCJEventCookie;
})();


