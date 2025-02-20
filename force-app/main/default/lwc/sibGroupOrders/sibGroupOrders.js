import { LightningElement,api,wire } from 'lwc';
import { CartSummaryAdapter } from "commerce/cartApi";

//apex
import createGroupRecepients from '@salesforce/apex/SIB_GetInfo.createGroupRecepients';
import deleteRecipientsFromCheckout from '@salesforce/apex/B2BGetInfo.deleteRecipientsFromCheckout';
import getGroupOrderInfo from '@salesforce/apex/SIB_CheckoutController.getGroupOrderInformation';
import updateCartAndCartItems from '@salesforce/apex/SIB_CheckoutController.updateCartAndCartItems';
import checkEmailIsAlreadyOnColleva from '@salesforce/apex/SIB_CheckoutController.checkEmailIsAlreadyOnColleva';

//labels
import B2B_LBL_GROUPORDERS from '@salesforce/label/c.SIB_GroupOrders';
import B2B_LBL_PREPOPULATEONALLCOURSES from '@salesforce/label/c.SIB_PrepopulateOnAllCourses';
import B2B_LBL_FIRSTNAME from '@salesforce/label/c.SIB_Firstname';
import B2B_LBL_LASTNAME from '@salesforce/label/c.SIB_Lastname';
import B2B_LBL_EMAILADDRESS from '@salesforce/label/c.SIB_EmailAddress';
import B2B_LBL_NEXTCOURSE from '@salesforce/label/c.SIB_NextCourse';
import B2B_LBL_ISORDERFORSOMEONEELSE from '@salesforce/label/c.SIB_IsOrderForSomeoneElse';
import B2B_LBL_RECIPIENT from '@salesforce/label/c.SIB_Recipient';
import B2B_LBL_RECIPIENTS from '@salesforce/label/c.SIB_Recipients';
import SIB_RECIPIENTERRORMESSAGE from '@salesforce/label/c.SIB_RecipientErrorMessage';
import B2B_LBL_NEXT from '@salesforce/label/c.SIB_Next';
import B2B_LBL_COMPLETETHISFIELD from '@salesforce/label/c.SIB_CompleteThisField';
import B2B_LBL_SOMETHINGWENTWRONG from '@salesforce/label/c.SIB_GenericExceptionMessage';
import B2B_LBL_SHIPPING from '@salesforce/label/c.B2BShipping';
import B2B_LBL_EMAILFORMATERROR from '@salesforce/label/c.SIB_EmailFormatError';
import B2B_LBL_EDIT from '@salesforce/label/c.SIB_Edit';
import B2B_LBL_WAITLISTSCREENHEADER from '@salesforce/label/c.SIB_CheckoutWaitListScreenHeader';
import B2B_LBL_GROUPRECIPIENTCREATED from '@salesforce/label/c.SIB_GroupRecipientCreated';
import B2B_LBL_BILLING from '@salesforce/label/c.SIB_Billing';
import B2B_LBL_ORDERRECIPIENTS from '@salesforce/label/c.SIB_OrderRecipients';
import B2B_LBL_RECIPIENTEMAILSHOULDBEUNIQUE from '@salesforce/label/c.SIB_RecipientEmailShouldBeUnique';
import B2B_LBL_CITY from '@salesforce/label/c.SIB_BillingFieldCityPlaceholder';
import B2B_LBL_SESSIONS from '@salesforce/label/c.SIB_Sessions';


//messagechannel
import { subscribe, publish, MessageContext, unsubscribe } from 'lightning/messageService';
import CHECKOUT_STATE_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibMultiStepCheckoutMessages__c';
import {consoleLogging, getCookie, setCookie} from "c/sibUtils";

export default class SibGroupOrders extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    @api checkoutDetails;
    @api checkoutConfig;

    /**properties - Begin*/
    //text
    recordId;
    webStoreId;
    cartId;
    effectiveAccountId;
    styles = {
        inputerror : 'recipient-input-error',
        hidecomponent : 'sib-hide-component',
        recipientexpanded: 'recipient-data-section-expanded',
        recipienthidden: 'recipient-data-section-hidden',
        accordian: 'icon-hover'
    }
    waitlistErrorMessage = '';
    

    //boolean
    questStore;
    isPrePopulate = getCookie("isPrePopulate") === 'true';
    isGroupOrderCart = false;
    isStencilLoading = true;
    isDataLoaded = false;
    isDisplayPrePopulate = false;
    isDisplayRecipientSection = false;
    isOrderForSomeoneElse = getCookie("isOrderForSomeoneElse") === 'true';
    isGroupOrderReadOnly = false;
    iswaitlistError = false;
    isMarkCartAsWaitListed = false;
    isNextStepAvailable = true;
    

    //arrays
    itemsToDisplay=[];
    waitlistItems = [];
    waitlistedCartItems  = [];

    //objects
    cartSummary = {};
    cartItems = {};
    inputDataMap = {};
    validationMap = {};
    firstCartItemValues = {};
    waitListInfo = {};
    cartIdProductMap = {};
    finalInputMap = {}
    cartPromotion = {};
    cartSummaryGTM = {};
    loadedRecipientsMap = {};
    cartGroupRecipients;
    checkCollevaCourse = false;
    //messagechannel objects
    subscription = null;
    isEmailValidOnColleva = false;

    //Maps
    emailValidationMap = new Map();

    labels = {
        B2B_LBL_GROUPORDERS,
        B2B_LBL_PREPOPULATEONALLCOURSES,
        B2B_LBL_FIRSTNAME,
        B2B_LBL_LASTNAME,
        B2B_LBL_EMAILADDRESS,
        B2B_LBL_NEXTCOURSE,
        B2B_LBL_ISORDERFORSOMEONEELSE,
        B2B_LBL_RECIPIENT,
        B2B_LBL_RECIPIENTS,
        B2B_LBL_NEXT,
        B2B_LBL_COMPLETETHISFIELD,
        B2B_LBL_SOMETHINGWENTWRONG,
        B2B_LBL_SHIPPING,
        B2B_LBL_EMAILFORMATERROR,
        B2B_LBL_EDIT,
        B2B_LBL_WAITLISTSCREENHEADER,
        B2B_LBL_GROUPRECIPIENTCREATED,
        B2B_LBL_BILLING,
        B2B_LBL_ORDERRECIPIENTS,
        B2B_LBL_RECIPIENTEMAILSHOULDBEUNIQUE,
        B2B_LBL_CITY,
        B2B_LBL_SESSIONS,
        SIB_RECIPIENTERRORMESSAGE
    }

    /**properties - End*/

    /** Getter setters: begin */
    get isBuilder(){
        const loc = window.location.href;
        let isBuilder = false;
        if(loc.includes('comm') || loc.includes('preview')){
            isBuilder = true;
        }
        
        return isBuilder;
    }

    get isPrePopulateChecked() {
        return this.isPrePopulate;
    }

    get isGroupOrder() {
        return this.isGroupOrderCart;
    }

    get currentItemsToDisplay(){
        return this.itemsToDisplay;
    }

    get displayPrepopulate() {
        let displayPrePopulate = false;

        if(this.isGroupOrder && this.isOrderForSomeoneElse) {
            displayPrePopulate = this.isDisplayPrePopulate;
        } else if(!this.isGroupOrder && this.isDisplayPrePopulate) {
            displayPrePopulate = this.isDisplayPrePopulate;
        }

        return displayPrePopulate;
    }

    get displayRecipientSection() {
        return (!this.isGroupOrder || (this.isGroupOrder && this.isOrderForSomeoneElse));
    }

    get nextStepLabel() {
        let nextLabel = this.labels.B2B_LBL_BILLING;
        if(this.labels.B2B_LBL_BILLING && this.labels.B2B_LBL_BILLING.includes(':')){
            nextLabel = this.labels.B2B_LBL_BILLING.replaceAll(':','').toUpperCase();
        }
        return nextLabel;
    }

    get displayWaitlistScreen() {
        return this.iswaitlistError;
    }

    get waitlistScreenMessage() {
        return this.waitlistErrorMessage;
    }

    get isScreenLoaded() {
        let isLoaded = this.isStencilLoading
        return isLoaded;
    }

    get componentHeaderLabel() {

        let header = this.labels.B2B_LBL_GROUPORDERS;
        if(this.isGroupOrder) {
            header = this.labels.B2B_LBL_ORDERRECIPIENTS;
        }

        return header;
    }

    //wired methods : begin
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data && !this.isDataLoaded && !this.isBuilder) {
            this.cartId = data?.cartId;
            this.effectiveAccountId = data?.accountId;
            this.webStoreId = data?.webstoreId;
            this.fetchGroupOrderInfo();
        } else if (error) {
        }
    }

    async deleteRecipients()
    {
        await deleteRecipientsFromCheckout({cartId: this.cartId}).then(result =>
        {

        }).catch(error => {
            //  send toast message
            consoleLogging('deleteRecipients : Error : '+JSON.stringify(error));
            this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
        });
    }

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            CHECKOUT_STATE_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    //wired methods : end

    /**Lifecycle hooks: begin */
    connectedCallback() {
        let checkoutStage = getCookie("checkoutStage");
        if(checkoutStage && checkoutStage === 'groupOrders') {
            this.isGroupOrderReadOnly = false;
        } else {
            this.isGroupOrderReadOnly = true;
        }
    }

    renderedCallback() {
        this.populateRecipientValues();
    }

    errorCallback(error, stack) { 
        
    }
    /**Lifecycle hooks: end */

    async fetchGroupOrderInfo() {
        this.isDataLoaded = true;
        let requestMap =
        {
            cartId: this.cartId,
            webstoreId: this.webStoreId,
            effectiveAccountId: this.effectiveAccountId
        }
        await getGroupOrderInfo({requestMap: requestMap}).then(result =>
        {
            if(result && result?.isSuccess && result?.cartSummary && result?.cartItems)
            {
                this.cartItems = result?.cartItems;
                this.cartPromotion = JSON.parse(result.cartPromotions);
                this.cartSummaryGTM = result?.summaryGTM;
                this.isDisplayPrePopulate = this.cartItems && this.cartItems?.length > 1;
                this.cartSummary = result?.cartSummary;
                this.cartGroupRecipients = result?.groupRecipients;
                this.isGroupOrderCart = result?.cartSummary?.isGroupOrder;
                this.waitListInfo = result?.waitlist;
                this.collevaResponse = result?.collevaResponse;
                if(this.collevaResponse && this.collevaResponse?.collevaProdQty == 1){
                    this.checkCollevaCourse = true;
                }
                this.checkWaitListInfo(this.waitListInfo).then(result => {
                    this.processGroupOrderData();
                }).catch(error => {
                    consoleLogging('fetchGroupOrderInfo : Error : '+JSON.stringify(error));
                    this.processGroupOrderData();
                });
            } else
            {
                this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
            }
            this.isDataLoaded = true;
        }).catch(error => {
            //  send toast message
            consoleLogging('fetchGroupOrderInfo : Error : '+JSON.stringify(error));
            this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
        })
    }

    //check if the waitlist error message dialog needs to be displayed
    async checkWaitListInfo(){
        let returnVal;
        if(this.waitListInfo)
        {
            let waitlist = this.waitListInfo;
            if(waitlist)
            {
                if(waitlist?.status && waitlist?.status !== 'Success')
                {
                    this.iswaitlistError = true;
                    this.waitlistErrorMessage = waitlist?.errorMessage;
                    this.waitlistedCartItems = waitlist?.waitlistedProducts;
                    if(this.waitlistedCartItems && this.waitlistedCartItems?.length > 0)
                    {
                        this.cartItems.forEach( cartItem =>
                        {
                            for(let i = 0 ; i < this.waitlistedCartItems?.length; i++)
                            {
                                let waitlistedItem = this.waitlistedCartItems[i];
                                if(waitlistedItem?.Id === cartItem?.Id)
                                {
                                    cartItem = {...cartItem, IsWaitlisted__c: true};
                                    this.isMarkCartAsWaitListed = true;
                                    this.waitlistedCartItems[i] = {...waitlistedItem,IsWaitlisted__c: true };
                                }
                            }
                        })
                    }
                    returnVal = Promise.resolve(false);
                } else
                {
                    returnVal = Promise.resolve(true);
                }
            }
        } else
        {
            returnVal = Promise.resolve(true);
        }
        return await returnVal
    }

    processGroupOrderData() {
        let processedList = [];
        try {
            
            const cartId = this.cartSummary?.cartId;
            let counter = 0;
            const cartItemsLength = this.cartItems?.length;
            const cartItemsArr = this.cartItems;
            for(let item = 0; item < cartItemsLength ; item++) {
                let cartItem = this.cartItems[item];
                if(cartItem.Product2.Colleva_Base_Product__c)
                {                
                    let lineItem = {}; 
                    
                    const cartItemId = cartItem?.Id;
                    if(!this.finalInputMap[cartItemId]) this.finalInputMap[cartItemId] = {};

                    let isSessionAvailable = false
                    let sessionsList = [];
                    if(cartItem && cartItem?.CartItem_Selected_Sessions__c &&
                        cartItem?.CartItem_Selected_Sessions__c !== '' &&
                        cartItem?.Product2 && cartItem?.Product2?.Product_Group__c &&
                        cartItem?.Product2?.Product_Group__c === 'Public Course')
                    {
                        isSessionAvailable = true;
                        sessionsList = Object.values(JSON.parse(cartItem?.CartItem_Selected_Sessions__c));
                    }
                    //build a json for header info
                    lineItem =  {productname: cartItem?.Product2.Name,
                                cartItemId: cartItemId, 
                                cartId: cartId,
                                nextCourse: counter < cartItemsLength && counter +1 < cartItemsLength ? this.cartItems[counter + 1]?.Product2?.Name : '',
                                nextCourseId: counter < cartItemsLength && counter +1 < cartItemsLength? this.cartItems[counter + 1]?.Id: '', 
                                islast: counter === cartItemsLength - 1,
                                isFirst: item === 0,
                                displaySectionId: 'recipient-data-section-'+cartItemId,
                                displayClass:  counter === 0 ? 'recipient-data-section-expanded' : 'recipient-data-section-hidden',
                                displayRecipientsClass: 'recipient-data-section-hidden',
                                isSessionPresent: isSessionAvailable,
                                city: cartItem?.Product2 && cartItem?.Product2?.Training_Location_City_formula__c ?
                                                    cartItem?.Product2?.Training_Location_City_formula__c  : '',
                                sessions: sessionsList,
                                displayCitySessionData : !!((cartItem?.Product2 && cartItem?.Product2?.Training_Location_City_formula__c &&
                                    cartItem?.Product2?.Training_Location_City_formula__c !== '') || (sessionsList && sessionsList?.length > 0)),
                            }; 
                    
                    this.cartIdProductMap[cartItemId] = cartItem?.Product2;
                    let recipientsList = [];

                    //build an array for recipient list
                    
                    for(let i=0; i < cartItem?.Quantity ; i++) {
                        let data = {}; 
                        const dataIdPrefix = cartItemId + '-' + counter + '-' + i + '-'; 
                        data = {
                            firstname: '',
                            firstNameId: dataIdPrefix + 'firstname', 
                            firstNameErrorId: dataIdPrefix + 'firstnameError',
                            lastname: '',
                            lastNameId: dataIdPrefix + 'lastname', 
                            lastNameErrorId: dataIdPrefix + 'lastnameError',
                            email:'',
                            emailId: dataIdPrefix + 'email', 
                            emailErrorId: dataIdPrefix + 'emailError',
                            counter: i+1, 
                            id: crypto.randomUUID, 
                            rowId:(cartItemId + '-' +i)
                        };
                        recipientsList.push(data);
                    }
                    lineItem = { ...lineItem, recipients: recipientsList};
                    this.finalInputMap[cartItemId] = recipientsList;

                    processedList.push(lineItem);
                    this.itemsToDisplay = processedList;
                    
                    counter += 1;
                }
                else{
                    this.isGroupOrderCart = true;
                }
            }

            // If the user refreshes the page, load Group Recipients from the server and display them on the UI
            this.loadedRecipientsMap = {};
            if (this.cartGroupRecipients && this.cartGroupRecipients.length > 0) {
            
                for (let item = 0; item < this.cartGroupRecipients.length; item++) {
                    let recipientData = this.cartGroupRecipients[item];
            
                    // Extract the id and create a recipient object
                    let recipientCartItemId = recipientData.Cart_Item__c;
                    let recipient = {
                        id: recipientData.Id,
                        firstname: recipientData.First_Name__c,
                        lastname: recipientData.Last_Name__c,
                        email: recipientData.Recepient_Email__c
                    };
            
                    // Check if the ID key already exists in the loadedRecipientsMap
                    if (!this.loadedRecipientsMap[recipientCartItemId]) {
                        this.loadedRecipientsMap[recipientCartItemId] = []; // Initialize as an empty array if not present
                    }
            
                    // Push the recipient object to the list under the recipient's ID
                    this.loadedRecipientsMap[recipientCartItemId].push(recipient);
                }

                this.firstCartItemValues = this.cartGroupRecipients.length > 0 ? this.loadedRecipientsMap[this.cartGroupRecipients[0].Cart_Item__c] : {};

                // Iterate over finalInputMap entries to assign groupRecipientId without checking email
                Object.keys(this.finalInputMap).forEach((cartItemId) => {
                    const recipients = this.finalInputMap[cartItemId];
                    const groupRecipientIds = this.loadedRecipientsMap[cartItemId];

                    // Assign groupRecipientId sequentially
                    recipients.forEach((recipient, index) => {
                        if (index < groupRecipientIds?.length) {
                            recipient.groupRecipientId = groupRecipientIds[index]?.id;
                        }
                    });
                });

                // Iterate over itemsToDisplay entries to assign firstname, lastname, email from Server.
                this.itemsToDisplay.forEach((displayItem) => {
                    const recipients = displayItem.recipients; // Access the recipients array directly
                    const groupRecipientIds = this.loadedRecipientsMap[displayItem.cartItemId];

                    // Assign groupRecipientId sequentially
                    recipients.forEach((recipient, index) => {
                        if (index < groupRecipientIds?.length) {
                            recipient.firstname = groupRecipientIds[index]?.firstname;
                            recipient.lastname = groupRecipientIds[index]?.lastname;
                            recipient.email = groupRecipientIds[index]?.email;
                        }
                    });
                });
            }

            this.handleDataLayerMessage();
            this.isStencilLoading = false;
        } catch(error) {
            consoleLogging('processGroupOrderData : Error : '+JSON.stringify(error));
        }    
    }

    handleDataLayerMessage(){
        let cartItems = [];

        try{
            let dataLayerItem = {};

            this.cartSummaryGTM?.cartItems?.forEach( cartItem => {
                let promotionItem = '';
                this.cartPromotion?.cartItemPromotions.forEach(promotion =>
                {
                    if(promotion?.cartItemId === cartItem?.itemId)
                    {
                        promotionItem = promotion?.promotion;
                    }
                });
                dataLayerItem = {item_name:cartItem?.productDetail?.name, item_id:cartItem?.productDetail?.productSku, coupon: promotionItem};
                cartItems.push(dataLayerItem);
            })

            let value = this.cartSummaryGTM?.totalProductAmountAfterAdjustments;
            let currency = this.cartSummaryGTM?.currencyIsoCode;
            let coupon = this.cartPromotion?.cartOverallPromotion;
            let itemArray = JSON.parse(JSON.stringify(cartItems));
            
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
            this.dispatchEvent(pushToDataLayer);
        }catch(error) {
            consoleLogging('handleDataLayerMessage : Error : '+JSON.stringify(error));
        }
    }

    handleRecipientInfoChange(event) {
        const eventId = event.currentTarget.dataset.id;
        const errorId = eventId + 'Error';

        let eventData = event.target.value;
        if(!eventId.includes('email')){
            eventData = eventData.replace(/[^a-zA-Z\s]/g, '');
            event.target.value = eventData;
        }
        const eventInfo = eventId.split('-');
        const cartItemId = eventInfo[0];
        const cartItemCounter = eventInfo[1];
        const recipientCounter = eventInfo[2];
        const counter = 'recipient-'+eventInfo[2];
        const inputField = eventInfo[3];

        let field = this.querySelector('[data-id="'+eventId+'"]');
        let errorField = this.querySelector('[data-id="'+eventId+'Error"]');
        
        if(eventData != '' && eventData != null && eventData != undefined) {
            this._removeFromClassList(field, this.styles.inputerror);
            this._addToClassList(errorField, this.styles.hidecomponent);

            let counterMap = [];

            if(this.cartGroupRecipients && this.cartGroupRecipients.length > 0) {
                //if data has not been added add a new key value pair
                if(!this.loadedRecipientsMap.hasOwnProperty(cartItemId)){
                    this.loadedRecipientsMap[cartItemId] = {};
                }
                
                let cartItemMap = this.loadedRecipientsMap[cartItemId];
                if(!cartItemMap.hasOwnProperty(recipientCounter)){
                    cartItemMap[recipientCounter] = {firstname: '', lastname:'', email: ''};
                } 
                counterMap = cartItemMap[recipientCounter];
                
                if(!counterMap.hasOwnProperty(inputField)) {
                    counterMap[inputField] = {};
                }

                counterMap[inputField] = eventData;
                
                cartItemMap[recipientCounter] = counterMap;
                this.loadedRecipientsMap[cartItemId] = cartItemMap;
            } else {
                //if data has not been added add a new key value pair
                if(!this.inputDataMap.hasOwnProperty(cartItemId)){
                    this.inputDataMap[cartItemId] = {};
                }
                
                let cartItemMap = this.inputDataMap[cartItemId];
                if(!cartItemMap.hasOwnProperty(counter)){
                    cartItemMap[counter] = {firstname: '', lastname:'', email: ''};
                } 
                counterMap = cartItemMap[counter];
                
                if(!counterMap.hasOwnProperty(inputField)) {
                    counterMap[inputField] = {};
                }

                counterMap[inputField] = eventData;
                
                cartItemMap[counter] = counterMap;
                this.inputDataMap[cartItemId] = cartItemMap;
            }
            

            if(cartItemCounter == 0 && eventData != '' && eventData != null && eventData != undefined) {
                if(!this.firstCartItemValues.hasOwnProperty(recipientCounter)) this.firstCartItemValues[recipientCounter] = {firstname: '', lastname:'', email: ''};
                this.firstCartItemValues[recipientCounter] = counterMap;
            }

            if(this.isPrePopulate){
                this.populateAllFieldsWithFirstCartItemValues();
            }
        } else {
            this._addToClassList(field, this.styles.inputerror);
            this._removeFromClassList(errorField, this.styles.hidecomponent);
            
            if(cartItemCounter == 0  && eventData != '' && eventData != null && eventData != undefined) {
                if(!this.firstCartItemValues.hasOwnProperty(recipientCounter)) this.firstCartItemValues[recipientCounter] = {firstname: '', lastname:'', email: ''};
                let recipientRecord = this.firstCartItemValues[recipientCounter];
                recipientRecord[inputField] = eventData;
            }
        }
    }

    validateEmailAddress(event) {
        const email = event.target.value;
        const eventId = event.currentTarget.dataset.id;
        let field = this.querySelector('[data-id="'+eventId+'"]');
        field.classList.remove(this.styles.inputerror);

        if(this.validateEmail(email, eventId)){
            //call server method to check if email is entered before.
            if(this.checkEmailIsAlreadyExistOnColleva(email, eventId).then()) {
            if(this.validateEmailUniqueness(email, eventId)) { 
                    this.handleRecipientInfoChange(event);
                }
            }
            
        } else {
            return;
        }
        
    }

    async checkEmailIsAlreadyExistOnColleva(email, eventId) {
        // this.isDataLoaded = true;
        // this.isStencilLoading = true;
        // this.isNextStepAvailable = false;
        document.querySelector(".cta-btn").setAttribute("disabled","");
        document.querySelector(".cta-btn").style.cursor = 'no-drop';
        let isEmailValid = true;
        setTimeout(() => {
        let field = this.querySelector('[data-id="'+eventId+'"]');
        let errorField = this.querySelector('[data-id="'+eventId+'Error"]');
        let requestMap =
        {
            email: email,
            cartId: this.cartId
            
        }
         checkEmailIsAlreadyOnColleva({requestMap: requestMap}).then(result =>
        {
            field = this.querySelector('[data-id="'+eventId+'"]');
            errorField = this.querySelector('[data-id="'+eventId+'Error"]');
            if(result && result?.isSuccess  && result.msg != '')
            {
                // field.classList.remove(this.styles.inputerror);
                errorField.textContent = result.msg;
                field.classList.add(this.styles.inputerror);
                errorField.classList.remove(this.styles.hidecomponent);
                isEmailValid = false;
                this.isEmailValidOnColleva = isEmailValid;   
            } else 
            {
                field?.classList?.remove(this.styles.inputerror);
                this.isEmailValidOnColleva = true;
            }
            document.querySelector(".cta-btn").removeAttribute("disabled");
            document.querySelector(".cta-btn").style.cursor = 'pointer';
            // this.isStencilLoading = false;
            // this.isNextStepAvailable = true;
        }).catch(error => {
            //  send toast message
            consoleLogging('fetchGroupOrderInfo : Error : '+JSON.stringify(error));
            this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
        });
    },1000);
        return isEmailValid;
    }

    checkErrorVisibility(){
        let errorDiv = document.getElementsByClassName("sib-error-text");
        let isError = false;
        for(let i = 0; i < errorDiv.length ; i++) {
            if(errorDiv[i].checkVisibility()){
                return true;    
            }
        }
        return isError;
    }

    validateEmailUniqueness(email, eventId) {
        let isEmailUnique = true;
        let field = this.querySelector('[data-id="'+eventId+'"]');
        let errorField = this.querySelector('[data-id="'+eventId+'Error"]');
        
        this.emailValidationMap = this.emailValidationMap && this.emailValidationMap != undefined && this.emailValidationMap != null  ? this.emailValidationMap : new Map();
        let courseId = eventId.split('-')[0];

        if(email && email != undefined && email != '' && email != null) {
            if(this.emailValidationMap?.has(courseId)) {

                let courseEmailMap = this.emailValidationMap?.get(courseId);
                if(courseEmailMap && !courseEmailMap?.has(email)) {
                    
                    this._addToClassList(errorField, this.styles.hidecomponent );
                    this._removeFromClassList(field, this.styles.inputerror);
                    errorField.textContent = this.labels.B2B_LBL_COMPLETETHISFIELD;
    
                    courseEmailMap.set(email, email);
                    this.emailValidationMap.set(courseId, courseEmailMap);
                } else {
                    
                    isEmailUnique = false;
                    errorField.textContent = this.labels.B2B_LBL_RECIPIENTEMAILSHOULDBEUNIQUE;
                    this._addToClassList(field, this.styles.inputerror);
                    this._removeFromClassList(errorField, this.styles.hidecomponent);
                    isEmailUnique = false;
                    return isEmailUnique;
                }
            } else {
                
                let courseEmailMap = new Map();
                courseEmailMap.set(email, email);
                this.emailValidationMap.set(courseId, courseEmailMap);
            }
        }
        
        return isEmailUnique;
    }

    validateEmail(email, eventId) {

        let isValid = true;
        let field = this.querySelector('[data-id="'+eventId+'"]');
        let errorField = this.querySelector('[data-id="'+eventId+'Error"]');

        if(email && email != '' && email != null && email != undefined) {

            this._addToClassList(errorField, this.styles.hidecomponent );
            this._removeFromClassList(field, this.styles.inputerror);
            const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            errorField.textContent = this.labels.B2B_LBL_COMPLETETHISFIELD;
            if (!emailRegex.test(email)) {
                errorField.textContent = this.labels.B2B_LBL_EMAILFORMATERROR;
                this._addToClassList(field, this.styles.inputerror);
                this._removeFromClassList(errorField, this.styles.hidecomponent);
                isValid = false;
            } else {
               //ignore
            } 

        } else {
            
            if(email == '' || email == undefined || email == null) {
                errorField.textContent = this.labels.B2B_LBL_COMPLETETHISFIELD
            }
            this._addToClassList(field, this.styles.inputerror);
            this._removeFromClassList(errorField, this.styles.hidecomponent);
        }
        return isValid;
    }

    handlePrepopulateData(event) {

        this.isPrePopulate = !this.isPrePopulate;
        this.populateAllFieldsWithFirstCartItemValues();
    }

    populateAllFieldsWithFirstCartItemValues(){
        
        //check if any values have been populated
        if(this.firstCartItemValues && Object.keys(this.firstCartItemValues).length > 0 && this.itemsToDisplay && Object.keys(this.itemsToDisplay).length > 0) {
            

            for(let cartItem = 0; cartItem < this.itemsToDisplay.length ; cartItem++) {
                
                let counter = 0;
                this.itemsToDisplay[cartItem].recipients.forEach( recipient => {
                    if(this.firstCartItemValues.hasOwnProperty(counter) ){
                        let recordValues = this.firstCartItemValues[counter];
                        if(counter < Object.keys(recordValues).length ){

                            this.querySelector('[data-id="'+recipient.firstNameId+'"]').value = recordValues.firstname;
                            this.querySelector('[data-id="'+recipient.lastNameId+'"]').value = recordValues.lastname;
                            this.querySelector('[data-id="'+recipient.emailId+'"]').value = recordValues.email;

                            //Updating itemsToDisplay array to retain values when data re-renders
                            recipient.firstname = recordValues.firstname;
                            recipient.lastname = recordValues.lastname;
                            recipient.email = recordValues.email;
                            
                        }
                    }
                    
                    counter+=1;
                }) 
            }
        }
    }

    populateRecipientValues(){
        //check if any values have been populated
        if(this.loadedRecipientsMap && Object.keys(this.loadedRecipientsMap).length > 0 && this.itemsToDisplay && Object.keys(this.itemsToDisplay).length > 0) {
            for (let cartItem = 0; cartItem < this.itemsToDisplay.length; cartItem++) {
                const item = this.itemsToDisplay[cartItem];
                const itemId = item.cartItemId; // Assuming `id` is the unique identifier for the cart item
        
                // Check if this item exists in recipientsList
                if (this.loadedRecipientsMap[itemId]) {
                    let recipients = this.loadedRecipientsMap[itemId];
        
                    recipients.forEach((recipientData, index) => {
                        // Ensure there’s a matching recipient in itemsToDisplay for this index
                        if (item.recipients[index]) {
                            const recipient = item.recipients[index];

                            // Populate the input fields with data from recipientData, checking each field
                            const firstNameElement = this.querySelector('[data-id="' + recipient.firstNameId + '"]');
                            const lastNameElement = this.querySelector('[data-id="' + recipient.lastNameId + '"]');
                            const emailElement = this.querySelector('[data-id="' + recipient.emailId + '"]');

                            if (firstNameElement) {
                                firstNameElement.value = recipientData.firstname;
                            }
        
                            if (lastNameElement) {
                                lastNameElement.value = recipientData.lastname;
                            }
        
                            if (emailElement) {
                                emailElement.value = recipientData.email;
                            }
                        }
                    });
                }
            }
        }
    }

    proceedToNextCourse(event) {

        if(this._validateCourseContents(event)){
            const prevCourse = event.currentTarget.dataset.currentcourseid;
            const nextCourse = event.currentTarget.dataset.nextcourseid;
            
            if(prevCourse && nextCourse) {
                let currentCourseField = this.querySelector('[data-id="'+prevCourse+'"]');
                let nextCourseField = this.querySelector('[data-id="'+nextCourse+'"]');
                this._removeFromClassList(currentCourseField, this.styles.recipientexpanded);
                this._addToClassList(currentCourseField, this.styles.recipienthidden);
                this._removeFromClassList(nextCourseField, this.styles.recipienthidden);
                this._addToClassList(nextCourseField, this.styles.recipientexpanded);

            }
        } else {
            //validation failed
            return;
        }
    }

    continueToGrouporder(event) {
        this.iswaitlistError = false;
        this.waitlistErrorMessage = '';
    }

    handleEdit(event) {
        this.isGroupOrderReadOnly = false;
        this.publishCheckoutState('groupOrders');
    }

    _validateCourseContents(event){
        let validationResult = true; //set the return value as true, this flag is switched if errror found
        let overallValidation = true;
        let counter = 0; // set initial counter value
        
        this.emailValidationMap = new Map();

        let courseId = event.currentTarget.dataset.currentcourseid;

        this.cartItems.forEach( cartItem => {
            
            const cartItemId = cartItem.Id; //get cartId for building the data-id selector
            if(cartItemId == courseId) {
                validationResult = this._validateContentHelper(cartItemId, cartItem, counter, validationResult);
            }
            
            counter+=1;
            if(!validationResult) overallValidation= false; 
        });
        
        return overallValidation;
    }

    _validateContentHelper(cartItemId, cartItem, counter, validationResult) {
        let overallResult = true
        const fieldToValidate = ['firstname', 'lastname', 'email']; // fields to be validated are added to array for dynamic validation
        
        for(let i = 0; i < cartItem.Quantity ; i++) {
            fieldToValidate.forEach( fieldName => { // loop through the validation field array 
                let selectorPrefix = cartItemId + '-' + counter + '-' + i + '-' ;
                let fieldSelector = selectorPrefix + fieldName;
                let fieldErrorSelector = selectorPrefix + fieldName + 'Error';
                let valueField = this._fetchFieldForDataId(fieldSelector);
                let errorSection = this._fetchFieldForDataId(fieldErrorSelector);
                
                if(valueField && (valueField.value == '' || valueField.value == null || valueField.value == undefined)){ // check if field is empty

                    this._addToClassList(valueField, this.styles.inputerror);
                    this._removeFromClassList(errorSection, this.styles.hidecomponent);
                    if(fieldName == 'email' && (valueField.value != '' && valueField.value != null || valueField.value != undefined) ){ // this is specific for email

                        validationResult = this.validateEmail(valueField.value, fieldSelector); 
                        if(validationResult) {
                            
                            validationResult = this.validateEmailUniqueness(valueField.value, fieldSelector);
                        }
                    } else if(fieldName == 'email') {

                        errorSection.textContent = this.labels.B2B_LBL_COMPLETETHISFIELD;
                    }
                    validationResult = false;
                } else {
                    
                    if(fieldName == 'email' && (valueField.value != '' && valueField.value != null || valueField.value != undefined) ){ // this is specific for email
                        
                        validationResult = this.validateEmail(valueField.value, fieldSelector);
                        if(validationResult) {

                            validationResult = this.validateEmailUniqueness(valueField.value, fieldSelector);
                        }
                        if(validationResult)  {
                            
                            this.finalInputMap[cartItemId][i][fieldName.toLowerCase()] = valueField.value;
                        }
                    } else {

                        this.finalInputMap[cartItemId][i][fieldName.toLowerCase()] = valueField.value;
                    }
                }

                if(!validationResult) overallResult = false;
            })
        }
        
        return overallResult;
    }


    _validateOverallFormFields(event) {

        let validationResult = true;
        let overallValidationResult = true;
        let counter = 0;
        this.emailValidationMap = new Map();
        if(!this.isEmailValidOnColleva || this.checkErrorVisibility()){
            overallValidationResult = false;
            return overallValidationResult;
        }
        this.cartItems.forEach( cartItem => {
            
            const cartItemId = cartItem?.Id;

            validationResult = this._validateContentHelper(cartItemId, cartItem, counter, validationResult);
            counter +=1;

            if(!validationResult) overallValidationResult = false;
            
        });

        return overallValidationResult;
    }

    async proceedToNextCheckoutStep(event) {
        
        try{
            let result = false;
            if(this.checkCollevaCourse && !this.collevaResponse.isIndividualOrderAllowed 
                && !this.isOrderForSomeoneElse ){
                this.showToastMessage('you already have same SmartPrep Product Active. ', 'error');
                return;
            }
            if(this.isGroupOrder && !this.isOrderForSomeoneElse && !this.isMarkCartAsWaitListed){
                
                this.publishProceedToNextStep();
            } else if (this.isGroupOrder && !this.isOrderForSomeoneElse && this.isMarkCartAsWaitListed) {

                this.proceedToCheckUpdateCartAndCartItems();
            } else {
                
                if(this._validateOverallFormFields(event)) {
                    this.createNewrecipients();
                    setCookie("isOrderForSomeoneElse", this.isOrderForSomeoneElse, 1);
                    setCookie("isPrePopulate", this.isPrePopulate, 1);
                } else {
                    this.showToastMessage(this.labels.SIB_RECIPIENTERRORMESSAGE, 'error');
                    return;
                }
            }
        } catch(error) {
            this.isStencilLoading = false;
        }
        
        
    }

    createNewrecipients(){
        this.isStencilLoading = true;
        let success = true;
        let returnValue = true;
        
        let cartId = this.cartSummary?.cartId;

        let newRecipientsList = [];
        if(this.finalInputMap && Object.keys(this.finalInputMap).length > 0) {
            for(const [key, value] of Object.entries(this.finalInputMap)) {
                
                let cartItemId = key;
                let productData = this.cartIdProductMap[cartItemId];
                let recipientInfo = value;
                

                value.forEach( entry => {
                    let newRecipient = {};
                    newRecipient.Id = entry?.groupRecipientId;
                    newRecipient.Cart__c = cartId;
                    newRecipient.Cart_Item__c = cartItemId;
                    newRecipient.Status__c = 'Created';
                    newRecipient.TTS_Event__c = productData?.TTS_Event__c;
                    newRecipient.First_Name__c = entry?.firstname;
                    newRecipient.Last_Name__c = entry?.lastname;
                    newRecipient.Recepient_Email__c = entry?.email;
                    newRecipientsList.push(newRecipient); 
                })
            }
            
            if(newRecipientsList && newRecipientsList.length > 0 ) {
                this.isGroupOrderReadOnly = true;
                createGroupRecepients({groupRecipients: newRecipientsList, useSameRecipient: false, cartId: this.cartSummary?.cartId}).then(result => {
                    if(result) {
                        this.updateIdToGroupRecipients(result);
                    }
                    this.proceedToCheckUpdateCartAndCartItems();
                }).catch( error => {
                    this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
                })
            }
        } else {
            
        }

        return returnValue;
    }

    updateIdToGroupRecipients(groupRecipients) {
        // Create a map with recipient emails and CartItemId as keys for quick lookup
        const groupRecipientMap = new Map();
        groupRecipients.forEach((groupRecipient) => {
            const key = `${groupRecipient.Cart_Item__c}_${groupRecipient.Recepient_Email__c}`;
            groupRecipientMap.set(key, groupRecipient.Id);
        });

        // Iterate over finalInputMap entries
        Object.keys(this.finalInputMap).forEach((cartItemId) => {
            this.finalInputMap[cartItemId].forEach((recipient) => {
                const key = `${cartItemId}_${recipient.email}`;
                if (groupRecipientMap.has(key)) {
                    recipient.groupRecipientId = groupRecipientMap.get(key);
                }
            });
        });
    }

    proceedToCheckUpdateCartAndCartItems(){
        this.isStencilLoading = true
        let cartItems = []
        this.waitlistedCartItems.forEach( cartItem => {
            cartItems.push(cartItem?.Id);
        })

        let requestMap = {
            cartToUpdate: this.cartSummary?.cartId,
            cartItemsToUpdate: JSON.stringify(cartItems),
            isWaitListed: this.isMarkCartAsWaitListed,
            isGroupOrder: this.isGroupOrder
        }

        updateCartAndCartItems(
            {requestMap: requestMap}
        ).then(result =>{
            if(result && result.isSuccess) {
                this.showToastMessage(this.labels.B2B_LBL_GROUPRECIPIENTCREATED, 'success');
                this.publishProceedToNextStep();
            } else {
                this.isStencilLoading = false;
                this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
            }
        }).catch( error => {
            this.isStencilLoading = false;
            this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
        })
    }

    publishProceedToNextStep(){
        this.isStencilLoading = true;
        this.isGroupOrderReadOnly = true;
        this.publishCheckoutState('billing');
    }

    publishCheckoutState(nextState) {
        const payload = { 
            nextState: nextState,
        };
        this.isStencilLoading = false;
        publish(this.messageContext, CHECKOUT_STATE_MESSAGE_CHANNEL, payload);
    }

    openCurrentCourse(event) {
        let currentId = event.currentTarget.dataset.currentcourseid;
        
        let dataSections = this.querySelectorAll('[data-sectionid^="recipient-data-section-"]');
        
        if(dataSections) {
            dataSections.forEach(dataSection => {
                let dataSectionId = dataSection.getAttribute('data-sectionid');
                if(dataSectionId.includes(currentId)){
                    this._removeFromClassList(dataSection, this.styles.recipienthidden);
                    this._addToClassList(dataSection, this.styles.recipientexpanded);
                } else {
                    this._removeFromClassList(dataSection, this.styles.recipientexpanded);
                    this._addToClassList(dataSection, this.styles.recipienthidden);
                }
            });
        }
    }

    showRecipients(event) {
        let currentId = event.currentTarget.dataset.currentcartitemid;
        let currentSelectionItem = this.querySelector(`[data-currentcourseid="${currentId}"]`);

        let dataSections = this.querySelectorAll('[data-sectionid^="recipient-data-section-"]');
        
        if(dataSections) {
            dataSections.forEach(dataSection => {
                let dataSectionId = dataSection.getAttribute('data-sectionid');
                if(dataSectionId.includes(currentId)){
                    // Toggle between hidden and expanded for the clicked section
                    if (dataSection.classList.contains(this.styles.recipienthidden)) {
                        this._addToClassList(currentSelectionItem, this.styles.accordian);
                        this._removeFromClassList(dataSection, this.styles.recipienthidden);
                        this._addToClassList(dataSection, this.styles.recipientexpanded);
                    } else {
                        this._removeFromClassList(currentSelectionItem, this.styles.accordian);
                        this._removeFromClassList(dataSection, this.styles.recipientexpanded);
                        this._addToClassList(dataSection, this.styles.recipienthidden);
                    }
                    return;
                }
            });
        }
    }

    handleOrderForSomeOneElseToggle(event) {
        this.isOrderForSomeoneElse = !this.isOrderForSomeoneElse;
    }

    _removeFromClassList(field, styleClass){
        
        if(field.classList.contains(styleClass)){
            field.classList.remove(styleClass);
        }
    }

    _addToClassList(field, styleClass) {
        
        field.classList.add(styleClass);
    }


    _fetchFieldForDataId(fieldDataId) {
        let field = this.querySelector('[data-id="'+fieldDataId+'"]');
        
        return field;
    }

    _handleMessage(message) {
        
        if(message?.nextState == 'groupOrder') {
            this.isGroupOrderReadOnly = false;
        }else {
            this.isGroupOrderReadOnly = true;
        }
    }

    toggleSectionVisibility(event) {
        const eventId = event.currentTarget.dataset.id;
        
    }

    showToastMessage(message,type) {
        
        let field = this.querySelector('c-sib-show-toast-message');
        
        field.showToast(message,type,6000);
    }

}