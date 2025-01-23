/*
 * This is a Wishlist Item Component for 
 *  @Author : Sanyam Jain
 */

import { LightningElement,api,track } from 'lwc';
import updateWishlist from '@salesforce/apex/Saltbox_B2BWishlistController.updateWishlist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mobileTemplate from './saltboxWishlistMobile.html';
import desktopTemplate from './saltboxWishlistDesktop.html';
export default class SaltboxWishlistItem extends LightningElement {
    @api item;
    @track editBucketName = false;
    @track isClosed  = true;
    @track bucketInputValue;
    @api wishlistProductItems;
    @api properties;
    @api currentWishlistId;
    @api communityId;
    @api effectiveAccountId;

    // Making Item active and inactive by removing class
    @api handleActiveItem(){
        const custEvent = new CustomEvent(
            'removeallactivebucket', {
                detail: this.item.id
            });
        this.dispatchEvent(custEvent);
        if(this.isClosed){
            this.isClosed = false;
        }
        else{
            this.isClosed = true;
        }
        /** Remoing Inactive class and adding active class */
        this.template.querySelector('[data-id="bucket-item"]').classList.remove('inactive-bucket-item');
        this.template.querySelector('[data-id="bucket-item"]').classList.add('active-bucket-item');
    }


    /** Render Template according to mobile Size */
    render() {
        if( window.screen.width < 460 ){
            return mobileTemplate;
        }
        else{
         return desktopTemplate;
        }
         
    }

    /** Edit Mode of Wishlist Item*/
    handleEditBucketName(){
        if(this.editBucketName){
            this.editBucketName = false;
        }
        else{
        this.editBucketName = true;
        this.bucketInputValue = this.item.name;
            setTimeout(()=>{
                this.template.querySelector('[data-id="bucket-input"]').focus();
            },1000);
        }
    }

    /** Update Wishlist Name */
    updateWishlistName(){
        updateWishlist({
            wishlistId : this.item.id , 
            updateWishlistName : this.bucketInputValue,
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            this.item = data;
            this.editBucketName = false;
            this.showNotification('Updated Successfully','Wishlist Name Updated Successfully','success');
        })
        .catch(error => {
            this.error = error;
        });
    }

    /** Handle On Change Bucket Name */
    handleBucketNameChange(event){
        this.bucketInputValue = event.target.value;
    }

    /** Refresh Wishlist Items on click */
    handleWishListItems(){
        const custEvent = new CustomEvent(
            'refreshwishlistitem', {
                detail: this.item.id
            });
         this.dispatchEvent(custEvent);


         this.handleActiveItem();

    }

    /** Remove Active Wishlist Item */
    @api handleRemoveActive(){
        this.template.querySelector('[data-id="bucket-item"]').classList.remove('active-bucket-item');
        this.template.querySelector('[data-id="bucket-item"]').classList.add('inactive-bucket-item');
    }

    /**Close Mobile Accordion */
    @api closeAccordion(){
        if(this.isClosed == false){
            this.isClosed = true;
        }
       
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
    
    
}