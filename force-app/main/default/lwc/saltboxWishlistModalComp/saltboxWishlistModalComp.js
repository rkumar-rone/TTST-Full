/*
 * This is a Wishlist Modal Component
 *  @Author : Sanyam Jain
 */

import { api, LightningElement, track, wire} from 'lwc';
import getWishLists from '@salesforce/apex/Saltbox_B2BWishlistController.getWishListsModal';
import createWishList from '@salesforce/apex/Saltbox_B2BWishlistController.createWishList';
import addWishListItem  from '@salesforce/apex/Saltbox_B2BWishlistController.addWishListItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import removeWishListItem from '@salesforce/apex/Saltbox_B2BWishlistController.removeWishListItem';
import getWishlistModalMetadata from '@salesforce/apex/Saltbox_B2BWishlistController.getWishlistModalMetadata';

export default class SaltboxWishlistModalComp extends LightningElement {

    /**Properties */
    @track wishListData;
    @track error;
    @track showNewBucketSection = false;
    @track newBucketName;
    @track isLoaded;
    @api productId;
    @track addEnable= false;
    isLoading;
    selectedWishlist = [];
    unselectedWishlist = [];
    hasRendered = true;
    wishlistMap;
    wishlistProperties = {};

    @api communityId;

    @api effectiveAccountId;
    

    connectedCallback(){
        console.log('this.communityId', this.communityId);
        this.isLoading  = true;
        this.handleGetWishlist();
        this.handlGetWishlistModalProperties();
    }
    renderedCallback(){
        if(this.wishListData && this.hasRendered){
            this.handlePrepopulate();
        }
    }

    /** Making wihslist select if item is already there */
    handlePrepopulate(){
            for(var i=0 ;i< this.wishListData.length;i++){
                if(this.wishListData[i].wishlistItems.length>0){
                    for(var j=0;j< this.wishListData[i].wishlistItems.length;j++){
                        if(this.wishListData[i].wishlistItems[j].Product2Id == this.productId){
                            if( this.template.querySelector(`[data-id="${this.wishListData[i].wishList.wishlistId}"]`)){
                                var element =  this.template.querySelector(`[data-id="${this.wishListData[i].wishList.wishlistId}"]`);
                                element.checked = true;
                                if(!this.selectedWishlist.includes(element.value)){
                                    this.selectedWishlist.push(element.value);
                                }
                            }
                            break;
                        }
                    }
                }
            }
            this.handleAddButton();
            this.hasRendered = false;
    }


    /** Getting Wishlist Modal Properties from Metadata */
    handlGetWishlistModalProperties(){
        getWishlistModalMetadata()
        .then(data => {
            if (data) {
                console.log(JSON.stringify(data));
                this.wishlistProperties = data;
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.wishlistProperties = undefined;
            console.log(` error: ${JSON.stringify(this.error,null, 2)}`);
        });
    }

    /** Handle Get Wishlist with wishlis items */
    handleGetWishlist(){
        getWishLists({
            communityId: this.communityId, 
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            if (data) {
                 this.wishListData = JSON.parse(data); 
                 this.wishlistMap = this.wishListData.reduce((acc, item) => acc.set(item.wishList.wishlistId, item.wishlistItems), new Map());
                 this.isLoading = false;
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.wishListData = [];
           
            console.log(` error: ${JSON.stringify(this.error)}`);
        });
    }


    /**Method to remove Item From wishlist */
    handleRemoveWishlistItem(wishlistItemId,wishlistId){
        removeWishListItem({wishListItemId : wishlistItemId , wishlistId : wishlistId})
        .then(data => {
           
        })
        .catch(error => {
            this.error = error;
            console.log('error:', JSON.stringify(error));
        });
        
    }

    
    /** Handle Checkbocx Click */
    handleCheckBoxClick(event){
        if(event.target.checked){
            const index = this.selectedWishlist.indexOf(event.target.value);
            if (!index > -1) {
                this.unselectedWishlist.splice(index, 1); 
                this.selectedWishlist.push(event.target.value);
            }
            //this.selectedWishlist.push(event.target.value);
        }
        else{
            const index = this.selectedWishlist.indexOf(event.target.value);
            if (index > -1) {
                this.selectedWishlist.splice(index, 1); 
                this.unselectedWishlist.push(event.target.value);
            }
        }
       this.handleAddButton();
          
    }


    
    /** Add Wishlist Button */
    handleAddButton(){
        if(this.selectedWishlist.length>0){
            this.addEnable = true;
        }
        else{
            this.addEnable = false;
        }
    }

    /** Remove Unselected wishlist */
    handleUnselectedWishlist(){
        for(var i= 0;i<this.unselectedWishlist.length;i++){
            var wishlistItems = this.wishlistMap.get(this.unselectedWishlist[i])
            for(var j=0;j< wishlistItems.length ;j++){
                if(wishlistItems[j].Product2Id == this.productId){
                    this.handleRemoveWishlistItem(wishlistItems[j].Id, wishlistItems[j].WishlistId);
                }
            }
        }
    }

    /** Add Product To Wishlist and remove unselected wishlist */
    handleAddWishlist(){
        this.isLoading = true;
        this.handleUnselectedWishlist();
        addWishListItem({
            productId : this.productId, 
            wishlistListId : this.selectedWishlist,
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            this.isLoading = false;
            this.handleCancel();
            this.showNotification('Update Successfull','Your product was successfully updated against the wishlist(s).','success');
        })
        .catch(error => {
            this.error = error;
            console.log('error:', error);
        });
    }

    /** Show Toast Notification */
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    

    /** Handle Show and hide create bucket */
    createBucket(){
        if(this.showNewBucketSection){
            this.showNewBucketSection = false
        }
        else{
            this.showNewBucketSection = true;
        }
       
    }

    /**Create New Bucket */
    saveBucket(){
        createWishList({
            bucketName : this.newBucketName, 
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            if(data){
                this.wishListData.push(JSON.parse(data));
            }
        })
        .catch(error => {
            this.error = error;
            this.showNotification('Error',error.body.message,'error');
            console.log('error:', JSON.stringify(error));
        });
        
        
        this.showNewBucketSection = false;

    }

    /** Handling Bucket Name */
    handleChange(event){
        this.newBucketName = event.target.value;
    }

    /** Close Modal */
    handleCancel(){
        this.dispatchEvent(
            new CustomEvent("cancelmodel")
        );
      //his.showModal = false;
    }


}