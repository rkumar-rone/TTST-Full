import { LightningElement,api } from 'lwc';
import getManagedContentByContentKeys from '@salesforce/apex/Saltbox_CMSConnector.getManagedContentByContentKeys';
export default class SaltboxProductAttributeItem extends LightningElement {

    @api productAttrDetail
    attrImage;
    error;

    
   /** Getting Logo By Calling CMS Connector */
   connectedCallback(){
   
    getManagedContentByContentKeys({ managedContentIds: this.productAttrDetail.productAttrImageId })
    .then(data => {
        if (data) {
            this.getImageData = typeof data === 'object' ? data : JSON.parse(data);
           
            if(this.getImageData.success) {
                this.attrImage = this.getImageData.image;
               
            }
        }
    })
    .catch(error => {
        this.error = error;
    });
}


}