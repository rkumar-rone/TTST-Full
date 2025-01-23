import { LightningElement } from 'lwc';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import SIB_StrivacityIdCookieName from '@salesforce/label/c.SIB_StrivacityIdCookieName';
import SIB_SiteDomainName from '@salesforce/label/c.Cje_Domain_Name';

export default class SibLogout extends LightningElement {

    fetchLogoutUrl() {
        getLogoutUrl()
        .then((result) => {  
            if(result) {
                document.cookie =  SIB_StrivacityIdCookieName + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT; domain=." + SIB_SiteDomainName + "; path=/";
                window.location.href = result         
            }
        })
        .catch((error) => {
            console.log('Error fetching logout URL:', error);
        });
    }

    connectedCallback() {
        if(!this.isInSitePreview()) {
            this.fetchLogoutUrl();
        }
    }

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }
}