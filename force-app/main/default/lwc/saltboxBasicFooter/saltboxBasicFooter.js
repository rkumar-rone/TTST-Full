import { LightningElement, api } from 'lwc';
import getManagedContentByContentKeys from '@salesforce/apex/Saltbox_CMSConnector.getManagedContentByContentKeys';
import twitterIcon from '@salesforce/resourceUrl/twitterIcon';
import facebookIcon from '@salesforce/resourceUrl/facebookIcon';
import instagramIcon from '@salesforce/resourceUrl/instagramIcon';
import linkedInIcon from '@salesforce/resourceUrl/linkedInIcon';

export default class SaltboxBasicFooter extends LightningElement {
    @api logoImage;
    @api logoImageMobile;
    @api backgroundColor;
    @api textColor;
    @api logoImageId;
    @api Section1Item1;
    @api Section1Item2;
    @api Section2Item1;
    @api Section2Item2;
    @api Section2Item3;
    @api Section2Item4;

    @api Section1Item1Link;
    @api Section1Item2Link;
    @api Section2Item1Link;
    @api Section2Item2Link;
    @api Section2Item3Link;
    @api Section2Item4Link;

    @api twitterLink;
    @api facebookLink;
    @api instagramLink;
    @api linkedInLink;

    @api rights;
    getImageData;
    facebookIcon = facebookIcon;
    instagramIcon = instagramIcon;
    twitterIcon = twitterIcon;
    linkedInIcon = linkedInIcon;



    connectedCallback() {
        getManagedContentByContentKeys({ managedContentIds: this.logoImageId })
            .then(data => {
                if (data) {
                    this.getImageData = typeof data === 'object' ? data : JSON.parse(data);
                    console.log('from LWC');
                    console.log(this.getImageData);
                    if (this.getImageData.success) {
                        this.logoImage = this.getImageData.image;
                        console.log('InsideSuccess' + this.logoImage);
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    renderedCallback() {
        this.template
            .querySelector(".background")
            .style.setProperty("--backgroundColor", this.backgroundColor);

        this.template
            .querySelector(".background")
            .style.setProperty("--textColor", this.textColor);

    }
}