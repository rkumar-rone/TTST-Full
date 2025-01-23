/*
 * This is a Wishlist Item Component
 *  @Author : Sanyam Jain
 */

import { LightningElement,api, track} from 'lwc';
import removeWishListItem from '@salesforce/apex/Saltbox_B2BWishlistController.removeWishListItem';
import addItemToCart from '@salesforce/apex/Saltbox_B2BWishlistController.addCartItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';

export default class SaltboxWishlistProductItem extends LightningElement {
/**Properties */
@api item;
@api wishListId;
@api properties;
@track title;
@track attribute;

@api communityId;
@api effectiveAccountId;

isLoading= false;

currentUserId = userId;

   /** Picking up value from item data according to dyamic field */
    connectedCallback(){
        this.title = this.item.productSummary.fields[this.properties.productNameField];
        this.attribute =  this.item.productSummary.fields[this.properties.productAttributeField];
    }

    /** Setting Up CSS Properties */
    renderedCallback(){
        this.initCSSVariables();
    }
    initCSSVariables() {
        var css = document.body.style;
        css.setProperty('--brand', this.properties.brandColor);
        css.setProperty('--buttonColor',this.properties.addToCartButtonColor);
        css.setProperty('--productAttrTextColor',this.properties.productAttributeTextColor);  
    }

    /** Remove Item From Wishlist */

    handleRemoveWishlistItem(){
        this.isLoading = true;
        removeWishListItem({
            wishListItemId : this.item.wishlistItemId, 
            wishlistId : this.wishListId,
            communityId: this.communityId, 
            effectiveAccountId: this.effectiveAccountId
        })
        .then(data => {
            this.dispatchEvent(
                new CustomEvent("removedwishlistitem")
            );
            this.isLoading = false;
            this.showNotification('Removed Successfully','Item removed successfully from wishlist','success');
        })
        .catch(error => {
            this.showNotification('Error',error.message,'error');
        });
    }

    //update 2023-30-2023
    async handleAddToCart(){
        try {
            // console.log(JSON.stringify(this.item,null,2));
            await addItemToCart({
                productId: this.item.productSummary.productId,
                currentUserId: this.currentUserId,
                communityId: this.communityId,
                effectiveAccountId: this.effectiveAccountId
            });

            this.showNotification(
                'Added To Cart',
                'Item successfully added to cart',
                'success'
            );
        } catch(e) {
            this.showNotification(
                'Error',
                'Item not added to cart',
                'error'
            );
            console.error(e.message);
        }
    }


    /** Method for showing toast message */
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }


}