/**
 * Created by junaidmohammed on 7/30/24.
 */

import {LightningElement} from 'lwc';
import isGuestUser from "@salesforce/user/isGuest";
import cjeDomainName from '@salesforce/label/c.Cje_Domain_Name';
import SIB_StrivacityIdCookieName from '@salesforce/label/c.SIB_StrivacityIdCookieName';

//apex
import getEncryptedFederationId from '@salesforce/apex/SIB_ConfigController.getEncryptedFederationId';

export default class B2BHeader extends LightningElement {

    connectedCallback() {
        this.addCJCookie();
        
        if(!isGuestUser) {
            this.setStrivacityId();
        }
    }

    addCJCookie()
    {
        let params = this.getUrlVars(window.location.href);
        //let domain = 'trainingthestreet.com';
        let domain = cjeDomainName;             //'trainingthestreet--fullcopy.sandbox.my.site.com';
        if(params.hasOwnProperty('cjevent'))
        {
            const evt = new CustomEvent("addCookies", {
                detail: {
                    cookieName: 'cje',
                    cookieValue: params['cjevent'],
                    expireInDays: '395',
                    domain: domain
                },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(evt);
        }
    }

    getUrlVars(urlParams) {
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

    setStrivacityId() {

        try {

            getEncryptedFederationId().then(result => {

                if(result && result?.isSuccess && result?.encrytedFederationId) {
    
                    let encryptedFederationId = result?.encrytedFederationId;
                    let domain = cjeDomainName; 
                    let cookiename = SIB_StrivacityIdCookieName;
                    domain = domain.startsWith('.') ? domain.slice(1) : domain;

                    const setCookieEvent = new CustomEvent("addCookies", {
                        detail:{
                            cookieName: cookiename,
                            cookieValue: encryptedFederationId,
                            expireInDays: '1',
                            domain: domain
                        },
                        bubbles: true,
                        composed: true
                    });
                
                    this.dispatchEvent(setCookieEvent);
                }
            }).catch(err =>{
                
            });
        }catch(error) {
            
        }
        
    }

    /*renderedCallback() {
        loadScript(this, app)
            .then(() => {
                window.populateCJEventCookie();
                /!*let name =  "cje=";
                let decodedCookie = decodeURIComponent(document.cookie);
                let ca = decodedCookie.split(';');
                for(let i = 0; i <ca.length; i++) {
                    let c = ca[i];

                    while (c.charAt(0) === ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(name) === 0) {
                        console.log(c.substring(name.length, c.length));
                    }
                }*!/
            })
            .catch((error) => {

            });
    }*/
}