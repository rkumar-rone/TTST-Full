import { LightningElement,api,track } from 'lwc';
import SIB_Icons from '@salesforce/resourceUrl/SIB_Icons';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import Logo_Image_Alt_Text from '@salesforce/label/c.SIB_Logo_Image_Alt_Text';
import SIB_LWRSiteURL from '@salesforce/label/c.SIB_LWRSiteURL';


export default class SibFooter extends LightningElement {
    static renderMode = 'light';

    @track images;
    
    @track Logo_Image_Alt_Text = Logo_Image_Alt_Text;

    siteUrl = SIB_LWRSiteURL;

    @api 
    footerConfig;

    connectedCallback() {
        
        this.images = {
            footerLogo:SIBTheme+'/images/logo-footer.png',
            facebook: SIB_Icons+'/SIB_Icons/facebook.svg',
            instagram: SIB_Icons+'/SIB_Icons/instagram.svg',
            twitter:SIB_Icons+'/SIB_Icons/twitter.svg',
            linkedin:SIB_Icons+'/SIB_Icons/linkedin.svg',
            youtube:SIB_Icons+'/SIB_Icons/youtube.svg'  
        };

    } 

    toggleAnswer(event) {
        event.preventDefault();
        event.stopPropagation();

        const dataId = event.currentTarget.dataset.id;
        const footerElement = this.querySelector(`[data-id="${dataId}"]`);
        if (footerElement) {
            footerElement.classList.toggle("is-open");
        }
    }
}