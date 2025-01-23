function iscmsImageURL(basePath,url){
    if(url.startsWith('/cms')){
        return basePath+'/sfsites/c'+url;
    }else{
        return url;
    }
}

function isInSitePreview(){
    let url = document.URL;
    return (url.indexOf('sitepreview') > 0 
        || url.indexOf('livepreview') > 0
        || url.indexOf('live-preview') > 0 
        || url.indexOf('live.') > 0
        || url.indexOf('.builder.') > 0);
};

function enableConsoleLogging(){
    document.cookie = "b2bLogging=true";
}

function consoleLogging(message){
    if(document.cookie.includes("b2bLogging=true;"))
    {
        console.log(message);
    }
}