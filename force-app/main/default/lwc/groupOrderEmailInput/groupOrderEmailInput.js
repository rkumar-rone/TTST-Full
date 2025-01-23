import { LightningElement, api, track } from 'lwc';
import createGroupRecepients from '@salesforce/apex/B2BGetInfo.createGroupRecepients';
import getCartItems from '@salesforce/apex/B2BGetInfo.getCartItems';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import getRecipientsForCart from '@salesforce/apex/B2BGetInfo.getRecipientsForCart';
import deleteRecipientsFromCheckout from '@salesforce/apex/B2BGetInfo.deleteRecipientsFromCheckout';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/Saltbox_B2BCartController2.getCartSummary';
import getCartPromotions from '@salesforce/apex/Saltbox_B2BCartController2.getCartPromotions';
import getCartItemsGTM from '@salesforce/apex/Saltbox_B2BCartController2.getCartItems';

export default class GroupOrderEmailInput extends LightningElement {


    @api cartId;
    @api cartItemQunatity;
    @api nextButtonLabel;
    @api isGroupOrder;
    customerEmails;
    availableSeats = 0;
    isDisabled = false;
    @track isNotSameRecipient = false;
    isLoading = false;
    @track cartItems = [];
    @track recipients = [];
    itemQuantity;
    @track isQuantityOne = false;
    @track recipientMissmatch = false;
    @track moreThanOneCourse = false;
    @track prepopulate = false;

    @track checkingSkip = true;

    @api showWaitlistScreen;
    @api waitlistText;
    @api waitlistError;
    showWaitlistError = false;
    cartItemsGTM;

    /**
     * Cart Summary
     * @type {Object}
     */ 
    cartSummary;

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }
    

    handleWaitlistContinue(){
        this.showWaitlistScreen = false;
        this.showWaitlistError = false;
    }

    connectedCallback(){

        if (this.waitlistError != '') {
            this.showWaitlistError = true;
        }
        //console.log('cartId', this.cartId);
        //console.log(this.isNotSameRecipient, this.isGroupOrder);
        this.isNotSameRecipient = this.isGroupOrder;
        //console.log(this.isNotSameRecipient, this.isGroupOrder);
        this.isLoading = true;
        let courseToCartItems = {};
        getCartItems( {cartId: this.cartId})
            .then(result => {
                let counter = 0;
                result.forEach( (item) => {
                    if(!courseToCartItems.hasOwnProperty(item.Product2Id)){
                        let selfStudy = item.Product2.Product_Group__c == 'Self-Study';
                        courseToCartItems[`${item.Product2Id}`] = { isSelfStudy: selfStudy, availableSeats: item.Product2.TTS_Event__r.Seats_Available__c, courseName: item.Product2.Name, startDate : item.Product2.Start_Date__c, city : item.Product2.Training_Location_City_formula__c, session : item.CartItem_Selected_Sessions__c, cartItems: [] };
                    }
                    
                    let courseToCartItem = courseToCartItems[`${item.Product2Id}`];
                    
                    if (item.Quantity && item.Quantity > 1) {
                        for (let index = 0; index < item.Quantity; index++) {
                            counter++;
                            let processedItem = {...item, itemNumber: counter, key: crypto.randomUUID()};
                            courseToCartItem.cartItems.push(processedItem);
                        }
                    } else if(item.Quantity == 1) {
                        counter++;
                        let processedItem = {...item, itemNumber: counter, key: crypto.randomUUID()};
                        courseToCartItem.cartItems.push(processedItem);
                    }
                    
                });
                this.cartItems = [...Object.values(courseToCartItems)];
                this.itemQuantity = counter;
                //console.log('this.itemQuantity', this.itemQuantity);
                if (this.itemQuantity == 1) {
                    this.isNotSameRecipient = false;
                    this.isQuantityOne = true;
                }
                //console.log('this.cartItems', JSON.parse(JSON.stringify(this.cartItems)));
                let recipientAux = {};
                let countAux = 0;
                let sessionArr;
                for (let course = 0; course < this.cartItems.length; course++) {
                    if(this?.cartItems[course]?.session != undefined){
                        sessionArr = Object.values(JSON.parse(this.cartItems[course]?.session));
                    }
                    this.recipients.push({courseName: this.cartItems[course].courseName, 
                                            courseId: '', 
                                            isSelfStudy: this.cartItems[course].isSelfStudy, 
                                            availableSeats: this.cartItems[course].availableSeats , 
                                            startDate: this.cartItems[course].startDate,
                                            city: this.cartItems[course]?.city,
                                            session : sessionArr,
                                            //session: this?.cartItems[course]?.session != undefined ?? Object.values(JSON.parse(this.cartItems[course]?.session)),
                                            recipients: []});
                    for (let recipnt = 0; recipnt < this.cartItems[course].cartItems.length; recipnt++) {
                        this.recipients[course].courseId = this.cartItems[course].cartItems[recipnt].Product2.TTS_Event__c;
                        recipientAux = {};
                        recipientAux.key = countAux;
                        recipientAux.Cart__c = this.cartId;
                        recipientAux.Cart_Item__c = this.cartItems[course].cartItems[recipnt].Id;
                        recipientAux.Status__c = 'Created';
                        recipientAux.TTS_Event__c = this.cartItems[course].cartItems[recipnt].Product2.TTS_Event__c;
                        recipientAux.courseName = this.cartItems[course].courseName;
                        recipientAux.First_Name__c = '';
                        recipientAux.Last_Name__c = '';
                        recipientAux.Recepient_Email__c = '';
                        recipientAux.toDisable = this.prepopulate;
                        this.recipients[course].recipients.push(recipientAux);
                        countAux++;
                    }
                }
                if (this.recipients.length > 1) {
                    this.moreThanOneCourse = true;
                }
                //console.log('this.recipients', JSON.parse(JSON.stringify(this.recipients)));
                //console.log('this.cartItems', JSON.parse(JSON.stringify(this.cartItems)));

                //Code related to GTM
                try {

                    getCartSummary({
                        communityId: communityId,
                        effectiveAccountId: this.resolvedEffectiveAccountId,
                        activeCartOrId: this.cartId
                    })
                    .then((result) => {
                        this.cartSummary = JSON.parse(JSON.stringify(result));
                        console.log('this.cartSummary', this.cartSummary);
                    })
                    .then(() => {
                        try {
                            getCartItemsGTM({
                                communityId: communityId,
                                effectiveAccountId: this.resolvedEffectiveAccountId,
                                activeCartOrId: this.cartId,
                                pageParam: null,
                                sortParam: 'CreatedDateDesc'
                            })
                            .then((result) => {
                                this.cartItemsGTM = result.cartItems;
                            })
                            .then(() => {
                                getCartPromotions({ cartId: this.cartId })
                                .then((result) => {
                                    //console.log('getCartPromotions', JSON.parse(result));
                    
                                    let cartPromotions = JSON.parse(result);
                    
                                    //console.log('this.cartSummary', JSON.parse(JSON.stringify(this.cartSummary)));
                    
                                    console.log('this.cartItemsGTM', JSON.parse(JSON.stringify(this.cartItemsGTM)));
                    
                                    let items = [];
                    
                                    let auxItem = {};
                    
                                    let itemHasPromotion;
                                    this.cartItemsGTM.forEach(item => {
                                        itemHasPromotion = false;
                                        cartPromotions.cartItemPromotions.forEach(promotion => {
                                            if (promotion.cartItemId == item.cartItem.cartItemId) {
                                                auxItem = { item_name:item.cartItem.productDetails.name, item_id:item.cartItem.productDetails.sku, coupon: promotion.promotion};
                                                itemHasPromotion = true;
                                            }
                                        });
                                        if (!itemHasPromotion) {
                                            auxItem = { item_name:item.cartItem.productDetails.name, item_id:item.cartItem.productDetails.sku, coupon: ''};
                                        }
                                        items.push(auxItem);
                                    });
                    
                                    let value = this.cartSummary.totalProductAmountAfterAdjustments;
                                    let currency = this.cartSummary.currencyIsoCode;
                                    let coupon = cartPromotions.cartOverallPromotion;
                                    let itemArray = JSON.parse(JSON.stringify(items));
                    
                                    /*console.log('value', this.cartSummary.totalProductAmountAfterAdjustments);
                                    console.log('currencyCode', this.cartSummary.currencyIsoCode);
                                    console.log('coupon', cartPromotions.cartOverallPromotion);
                                    console.log('items', JSON.parse(JSON.stringify(items)));*/
                    
                                    const pushToDataLayer = new CustomEvent('updateGTMdataLayer', { 
                                        'detail' : { 
                                        'event' : 'begin_checkout', 
                                        'ecommerce' : {
                                            'value': value,
                                            'currency': currency,
                                            'coupon': coupon,
                                            'items' : itemArray
                                        } 
                                        }
                                    });
                    
                                    console.log('pushToDataLayer', JSON.stringify(pushToDataLayer.detail));
                                    document.dispatchEvent(pushToDataLayer);
                    
                                });
                            });
                        } catch (e) {
                            console.log('Error in getCartPromotions', e);
                        }
                    });
                    
                } catch (error) {
                    console.error('Error in getCartSummary', error);
                }
                

            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: "Couldn't get all items from the cart.",
                    variant: "error"
                }));
            })
            .then(() => {
                getRecipientsForCart( {cartId: this.cartId} )
                .then(result => {
                    //console.log('result', result);
                    //console.log('this.itemQuantity', this.itemQuantity);
                    if(result == this.itemQuantity){
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                    }else{
                        this.checkingSkip = false;
                        if (result > 0) {
                            deleteRecipientsFromCheckout( {cartId: this.cartId} )
                            .then(() => {
                                this.recipientMissmatch = false;
                                this.isLoading = false;
                            })
                        } else {
                            this.isLoading = false;
                        }
                        
                    }
                    //console.log('this.recipients', JSON.parse(JSON.stringify(this.recipients)));
                })
            });
          
    }

    handleEmailAddressSubmit(){
        this.isLoading = true;
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!allValid) {
            this.isLoading = false;
            return;
        }

        let recipientsOut = [];
        let recipientAux = {};

        for (let course = 0; course < this.recipients.length; course++) {
            for (let recipnt = 0; recipnt < this.recipients[course].recipients.length; recipnt++) {
                recipientAux = {};
                recipientAux.Cart__c = this.cartId;
                recipientAux.Cart_Item__c = this.recipients[course].recipients[recipnt].Cart_Item__c;
                recipientAux.Status__c = 'Created';
                recipientAux.TTS_Event__c = this.recipients[course].recipients[recipnt].TTS_Event__c;
                recipientAux.First_Name__c = this.recipients[course].recipients[recipnt].First_Name__c;
                recipientAux.Last_Name__c = this.recipients[course].recipients[recipnt].Last_Name__c;
                recipientAux.Recepient_Email__c = this.recipients[course].recipients[recipnt].Recepient_Email__c;
                recipientsOut.push(recipientAux);
            }
        }

        createGroupRecepients( {groupRecipients: recipientsOut, useSameRecipient: !this.isNotSameRecipient, cartId: this.cartId} )
            .then(result => {
                this.isDisabled = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: "Success",
                    message: "Group recipients created.",
                    variant: "success"
                }));
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: "Couldn't create group recipients.",
                    variant: "error"
                }));
            });
        this.isLoading = false;
    }

    handleSameRecipientNext(){
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    handleSameRecipientChange(event){
        this.isNotSameRecipient = event.target.checked;
    }

    handleRecipientPrepopulate(event){
        //console.log('this.recipients.length', this.recipients.length);
        if (this.recipients.length < 2) return;
        this.prepopulate = event.target.checked;
        //console.log('this.prepopulate', this.prepopulate);
        let firstCourseRecipientsLength = this.recipients[0].recipients.length;
        //console.log('firstCourseRecipientsLength', firstCourseRecipientsLength);
        for (let course = 1; course < this.recipients.length; course++) {
            
            for (let recipnt = 0; recipnt < Math.min(firstCourseRecipientsLength,this.recipients[course].recipients.length); recipnt++) {
                //console.log('course', course);
                //console.log('recipnt', recipnt);
                this.recipients[course].recipients[recipnt].First_Name__c = this.recipients[0].recipients[recipnt].First_Name__c;
                this.recipients[course].recipients[recipnt].Last_Name__c = this.recipients[0].recipients[recipnt].Last_Name__c;
                this.recipients[course].recipients[recipnt].Recepient_Email__c = this.recipients[0].recipients[recipnt].Recepient_Email__c;
                this.recipients[course].recipients[recipnt].toDisable = this.prepopulate;
                //console.log('this.recipients[course].recipients[recipnt]', JSON.parse(JSON.stringify(this.recipients[course].recipients[recipnt])));
            }
        }
        
    }

    handleFirstNameChange(event){
        const firstName = event.target.value;
        if(firstName == '') return;
        const key = event.target.dataset.key;
        for (let course = 0; course < this.recipients.length; course++) {
            for (let recipnt = 0; recipnt < this.recipients[course].recipients.length; recipnt++) {
                if(this.recipients[course].recipients[recipnt].key == key){
                    this.recipients[course].recipients[recipnt].First_Name__c = firstName;
                    if (this.prepopulate && course == 0 && recipnt <= (this.recipients[0].recipients.length - 1)) {
                        for (let courseAux = 1; courseAux < this.recipients.length; courseAux++) {
                            this.recipients[courseAux].recipients[recipnt].First_Name__c = firstName;
                        }
                    }
                }
            }
        }
        //console.log('this.recipients', JSON.parse(JSON.stringify(this.recipients)));
    }

    handleLastNameChange(event){
        const lastName = event.target.value;
        if(lastName == '') return;
        const key = event.target.dataset.key;
        for (let course = 0; course < this.recipients.length; course++) {
            for (let recipnt = 0; recipnt < this.recipients[course].recipients.length; recipnt++) {
                if(this.recipients[course].recipients[recipnt].key == key){
                    this.recipients[course].recipients[recipnt].Last_Name__c = lastName;
                    if (this.prepopulate && course == 0 && recipnt <= (this.recipients[0].recipients.length - 1)) {
                        for (let courseAux = 1; courseAux < this.recipients.length; courseAux++) {
                            this.recipients[courseAux].recipients[recipnt].Last_Name__c = lastName;
                        }
                    }
                }
            }
        }
        //console.log('this.recipients', JSON.parse(JSON.stringify(this.recipients)));
    }

    handleEmailChange(event){
        const email = event.target.value;
        if(email == '') return;
        const key = event.target.dataset.key;
        for (let course = 0; course < this.recipients.length; course++) {
            for (let recipnt = 0; recipnt < this.recipients[course].recipients.length; recipnt++) {
                if(this.recipients[course].recipients[recipnt].key == key){
                    this.recipients[course].recipients[recipnt].Recepient_Email__c = email;
                    if (this.prepopulate && course == 0 && recipnt <= (this.recipients[0].recipients.length - 1)) {
                        for (let courseAux = 1; courseAux < this.recipients.length; courseAux++) {
                            this.recipients[courseAux].recipients[recipnt].Recepient_Email__c = email;
                        }
                    }
                }
            }
        }
        //console.log('this.recipients', JSON.parse(JSON.stringify(this.recipients)));
    }

}