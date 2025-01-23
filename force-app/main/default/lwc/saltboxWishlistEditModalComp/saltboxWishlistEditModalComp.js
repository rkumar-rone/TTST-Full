import { api, LightningElement } from 'lwc';
import updateWishlist from '@salesforce/apex/Saltbox_B2BWishlistController.updateWishlist';
import deleteWishlist from '@salesforce/apex/Saltbox_B2BWishlistController.deleteWishlist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SaltboxWishlistEditModalComp extends LightningElement {
    @api wishlistName;
    @api wishlistId;
    @api communityId;
    @api effectiveAccountId;

    bucketUpdateValue;

    connectedCallback(){
        this.bucketUpdateValue = this.wishlistName;
    }

    handleBucketNameChange(event){
        this.bucketUpdateValue = event.target.value;
    }

     /** Update Wishlist Name */
     updateWishlistName(){
        updateWishlist({
            wishlistId : this.wishlistId, 
            updateWishlistName : this.bucketUpdateValue,
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            this.showNotification('Updated Successfully','Wishlist Name Updated Successfully','success');
            const custEvent = new CustomEvent(
                'updatename',{
                    detail: this.bucketUpdateValue
                });
             this.dispatchEvent(custEvent);
            this.closeModal();
        })
        .catch(error => {
            this.error = error;
        });
    }

    /** Delete Wishlist  */

    handleDeleteWishlist(){
        deleteWishlist({
            wishlistId : this.wishlistId,
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            this.showNotification('Deleted Successfully','Wishlist Deleted Successfully','success');
            const custEvent = new CustomEvent(
                'deletewishlist',{
                    detail: this.wishlistId
                });
             this.dispatchEvent(custEvent);
            this.closeModal();
        })
        .catch(error => {
            this.error = error;
        });
    }

    /** Show Toast Message */
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeModal(){
        const custEvent = new CustomEvent(
            'closemodal');
         this.dispatchEvent(custEvent);
    }
    
}