import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProduct from '@salesforce/apex/B2BGetInfo.getProduct';
import getGbpProductPrice from '@salesforce/apex/B2BGetInfo.getGbpProductPrice';
import updateAccountCurrency from '@salesforce/apex/B2BGetInfo.updateAccountCurrency';
import getCartByUser from '@salesforce/apex/B2BGetInfo.getCartByUser';
import createCart from '@salesforce/apex/B2BGetInfo.createCart';
import deleteCart from '@salesforce/apex/B2BGetInfo.deleteCart';
import getOnlyOneSession from '@salesforce/apex/B2BGetInfo.getOnlyOneSession';
import communityId from '@salesforce/community/Id';
import basePath from "@salesforce/community/basePath";
import isGuest from '@salesforce/user/isGuest';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

const login = {
    type: 'comm__loginPage',
    attributes: {
        actionName: 'login'
    }
};

/**
 * An organized display of product information.
 *
 * @fires ProductDetailsDisplay#addtocart
 * @fires ProductDetailsDisplay#createandaddtolist
 */
export default class SaltboxProductDetailsDisplay extends NavigationMixin(
    LightningElement
) {
    /**
     * An event fired when the user indicates the product should be added to their cart.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event ProductDetailsDisplay#addtocart
     * @type {CustomEvent}
     *
     * @property {string} detail.quantity
     *  The number of items to add to cart.
     *
     * @export
     */

    /**
     * An event fired when the user indicates the product should be added to a new wishlist
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event ProductDetailsDisplay#createandaddtolist
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * A product image.
     * @typedef {object} Image
     *
     * @property {string} url
     *  The URL of an image.
     *
     * @property {string} alternativeText
     *  The alternative display text of the image.
     */

    /**
     * A product category.
     * @typedef {object} Category
     *
     * @property {string} id
     *  The unique identifier of a category.
     *
     * @property {string} name
     *  The localized display name of a category.
     */

    /**
     * A product price.
     * @typedef {object} Price
     *
     * @property {string} negotiated
     *  The negotiated price of a product.
     *
     * @property {string} currency
     *  The ISO 4217 currency code of the price.
     */

    /**
     * A product field.
     * @typedef {object} CustomField
     *
     * @property {string} name
     *  The name of the custom field.
     *
     * @property {string} value
     *  The value of the custom field.
     */

    /**
     * An iterable Field for display.
     * @typedef {CustomField} IterableField
     *
     * @property {number} id
     *  A unique identifier for the field.
     */

    /**
     * Gets or sets which custom fields should be displayed (if supplied).
     *
     * @type {CustomField[]}
     */
    @api
    customFields;

    /**
     * Gets or sets whether the cart is locked
     *
     * @type {boolean}
     */
    @api
    cartLocked;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    @api
    description;

    /**
     * Gets or sets the product image.
     *
     * @type {Image}
     */
    @api
    image;

    /**
     * Gets or sets whether the product is "in stock."
     *
     * @type {boolean}
     */
    @api
    inStock = false;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    @api
    name;

    /**
     * Gets or sets the price - if known - of the product.
     * If this property is specified as undefined, the price is shown as being unavailable.
     *
     * @type {Price}
     */
    @api
    price;

    /**
     * Gets or sets teh stock keeping unit (or SKU) of the product.
     *
     * @type {string}
     */
    @api
    sku;

    /**
     * Gets the sessions of the products event
     *
     * @type Sessions__c
     */
    @api
    eventSessions = [];

    initialRender = true;
    selectedSessionsJson;

    @api 
    trainingLocation;

    @api
    deliveryFormat;

    sessionFlag = false;

    get isFormatInPerson(){
        if(this.deliveryFormat) return this.deliveryFormat.includes('person');
        return false;
    }

    
    handleSessionChange(event){
        let selectedSessions = {};

        let sessions = Array.from(
            this.template.querySelectorAll('.sessions lightning-input')
        ).forEach((currentSession) => {
            if (event == undefined || event.currentTarget == undefined) return;

            let previousElement = currentSession.previousElementSibling;

            //deselection logic
            if(event.currentTarget.checked == false && event.currentTarget.dataset.required == "true") {
                if(currentSession.dataset.required == "true") {
                    currentSession.checked = false;
                }
            }

            //selection logic
            if(event.currentTarget.checked == true && event.currentTarget.dataset.required == "true") {
                if(currentSession.dataset.required == "true") {
                    currentSession.checked = true;
                }
            }

            //one selection logic 
            if(this.sessionFlag) {
                // If the current checkbox is not the one that triggered the event, uncheck it
                if (currentSession !== event.currentTarget) {
                    currentSession.checked = false;
                }
            }
            // if (event.currentTarget.checked == false && currentSession.dataset.required == "true" && previousElement == null) {
            //     currentSession.nextElementSibling.checked = false;
            // }
            
            // if (currentSession.checked == true && previousElement != null && previousElement.previousElementSibling == null && previousElement.dataset.required == "true" && previousElement.checked == false) {
            //     previousElement.checked = true;
            // }

            // if(currentSession.dataset.required == "true" && previousElement != null && previousElement.checked == true){
            //     currentSession.checked = true;
            // }
        });

        const checked = Array.from(
            this.template.querySelectorAll('.sessions lightning-input')
        )
        .filter((element) => element.checked)
        .forEach((element) => {
            selectedSessions[`${element.dataset.key}`] = element.label;
        });
        this.selectedSessionsJson = JSON.stringify(selectedSessions);

        if(Object.keys(selectedSessions)==0) {
            this._invalidQuantity = true;
        }
        else {
            this._invalidQuantity = false;
        }
        
    }

    @track _invalidQuantity = false;
    @track _quantityFieldValue = 1;
    _categoryPath;
    _resolvedCategoryPath = [];

    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });


    // ====================
    // updated 10/19/2023
    // ====================
    @api recordId;
    @api effectiveAccountId;
    productInfo;
    variations;
    isParentProduct = true;

    isSelfStudy = false;
    isPublicCourse = false;
    isPrivateCourse = false;

    selectText = 'Select...'
    eventCity = this.selectText;
    eventDate = this.selectText;
    @track eventDateOptions = [];
    @track eventCityOptions = [];

    citiesArr = []; 
    datesArr = []; 

    canonicalKeyProductIdMap = {};

    datesKeyCitiesArrVal = {} // {'new york': [January 2023]}
    citiesKeyDatesArrVal = {} // {'January 2023': ['new york']}

    canonicalKeySequence;

    counter = 0;

    priceObjFinal;

    showLoadingSpinner = false;

    get showLoading(){
        return this.showLoadingSpinner;
    }

    get productName() {
        return this.parseText(this.name);
    }

    get productDescription(){
        let description = this.description.replaceAll('�', "'");
        return this.parseText(description);
    }

    // ====================


    async connectedCallback() {
        this._resolveConnected();    

        // Get the product setup for the variations.
        let data = await getProduct({
            communityId: communityId,
            productId: this.recordId,
            effectiveAccountId: this.effectiveAccountId
        });
        this.productInfo = data;

        let sessionFlag = await getOnlyOneSession({productId: this.recordId});
        this.sessionFlag = sessionFlag;
        // Setup the price of the product.  this.price coming from parent component is blank when 
        // product has GBP. in this case, we must get the product price manually in here to populate correct
        // fields in the portal.
        // console.log('this.price connected callback >>>>>', JSON.stringify(this.price, null, 2));

        // we won't show any pricing if we're a parent page
        if(this.productInfo.productClass != 'VariationParent') {
            if(this.price.negotiated) {
                this.priceObjFinal = this.price;
            } else {
                // if this.price is a blank object, this product is GBP.
                // Get the price manually. 
                let data = await getGbpProductPrice({productId: this.recordId});
                data = JSON.parse(data);

                this.priceObjFinal = {
                    currency: data.CurrencyIsoCode,
                    negotiated: data.UnitPrice.toString()
                }
            }
        }

        this.isParentProduct = this.productInfo.productClass === 'VariationParent';
        // console.log('this.product', this.productInfo);
        if(this.productInfo.fields.Product_Group__c === 'Self-Study' || this.productInfo.fields.Product_Group__c === 'Bundle'){
            this.isSelfStudy = true;            
        } else if (this.productInfo.fields.Product_Group__c === 'Public Course'){
            this.isPublicCourse = true;
        } else {
            this.isPrivateCourse = true;
        }
        if(this.isPublicCourse) {
            this.productInfo.variationInfo.attributesToProductMappings.forEach(product => {
                // setup the canonicalKey that maps to product ids.
                this.canonicalKeyProductIdMap[product.canonicalKey] = product.productId;
                // 
                // let cityName = product.selectedAttributes[0].value;
                // let date = product.selectedAttributes[1].value;

                let cityName;
                let date;

                this.canonicalKeySequence = product.selectedAttributes[0].apiName === 'Event_City__c' ? 'cityFirst' : 'dateFirst';

                product.selectedAttributes.forEach(item => {
                    if(item.apiName === 'Event_City__c') cityName = item.value;
                    if(item.apiName === 'Month_Year__c') date = item.value;
                });

                //
                // setup map of cities and available dates.
                this.citiesKeyDatesArrVal[cityName] = this.citiesKeyDatesArrVal[cityName] ? [date, ...this.citiesKeyDatesArrVal[cityName]] : [date];
                // setup map of dates and available cities.
                this.datesKeyCitiesArrVal[date] = this.datesKeyCitiesArrVal[date] ? [cityName, ...this.datesKeyCitiesArrVal[date]] : [cityName];
            })

            let tempCitySelected = this.productInfo.variationAttributeSet?.attributes.Event_City__c
            let tempDateSelected = this.productInfo.variationAttributeSet?.attributes.Month_Year__c;

            // city and date can be null if it is a parent product... default to 'Select...'
            this.eventCity = tempCitySelected ? tempCitySelected : this.selectText;
            this.eventDate = tempDateSelected ? tempDateSelected : this.selectText;

            this.citiesArr = this.productInfo.variationInfo?.variationAttributeInfo?.Event_City__c?.availableValues;
            this.datesArr = this.productInfo.variationInfo?.variationAttributeInfo?.Month_Year__c?.availableValues;
            this.citiesArr = this.citiesArr ? [this.selectText, ...this.citiesArr] : [this.selectText];
            this.datesArr = this.datesArr ? [this.selectText, ...this.datesArr] : [this.selectText];

            // setup options initial state.  
            this.eventCityOptions = this.citiesArr.map(city => {
                return {
                    value: city,
                    selected: this.eventCity === city,
                    disabled: false
                }
            })
            this.eventDateOptions = this.datesArr.map(date => {
                return {
                    value: date,
                    selected: this.eventDate === date,
                    disabled: false
                }
            })

            // need to run this for init navigation to a variation product.
            // this will correctly disable cities/dates options
            this.setupAvailableDateAndCityOptions();
        }
 
        // console.log('>>>>> productInfo ', this.productInfo);
        // console.log('>>>>> isParentProduct ', this.isParentProduct);
        // console.log('>>>>> this.eventCity ', this.eventCity);
        // console.log('>>>>> this.eventCityOptions ', this.eventCityOptions);
        // console.log('>>>>> this.eventDate ', this.eventDate);
        // console.log('>>>>> this.eventDateOptions ', this.eventDateOptions);
        // console.log('>>>>> this.canonicalKeyProductIdMap ', this.canonicalKeyProductIdMap);
        // console.log('>>>>> this.citiesKeyDatesArrVal ', this.citiesKeyDatesArrVal);
        // console.log('>>>>> this.datesKeyCitiesArrVal ', this.datesKeyCitiesArrVal);
    }

    get displayDiv(){
        // we need to just hide the session elements becuase the js is counting 
        // the number of sessions checked by querying the DOM.  can be enhanced in the future 
        // to use the actual array that contains the sessions data.
        return this.isParentProduct ? 'display: none' : 'display: block';
    }

    parseText(text){
        let elem = document.createElement('textarea');
        elem.innerHTML = text;
        return elem.value;
    }



    generateProductUrl(productId){
        return `${window.location.origin}${basePath}/product/${productId}`;
    }

    navigateToProduct(){
        let canonicalKey = this.canonicalKeySequence === 'cityFirst' 
                ? `${this.eventCity}_${this.eventDate}`
                : `${this.eventDate}_${this.eventCity}`;
        let prodId = this.canonicalKeyProductIdMap[canonicalKey];
        
        // there should always be a productId as there will be logic to ensure 
        // option combinations will be disabled for non existent product variations.
        if(prodId) {  

            let url = this.generateProductUrl(prodId);
            window.location.assign(url);

            // this[NavigationMixin.Navigate]({
            //     type: 'comm__namedPage',
            //     attributes: {
            //         name: 'Product_Detail'
            //     },
            //     state: {
            //         recordId: prodId 
            //     }
            // });
        }
    }

    cityChangeFn(event){
        this.eventCity = event.target.value;

        this.setupAvailableDateAndCityOptions();

        if(this.eventDate && this.eventDate !== this.selectText) {
            this.navigateToProduct();
        }
    }

    dateChangeFn(event){
        this.eventDate = event.target.value;

        this.setupAvailableDateAndCityOptions();

        if(this.eventCity && this.eventCity !== this.selectText) {
            this.navigateToProduct();
        }
    }

    setupAvailableDateAndCityOptions(){
        //
        let availableDatesForCurrentCitySelected;
        if(this.eventCity === this.selectText) {
            // all dates should be available if the current select option is 'Select...'
            availableDatesForCurrentCitySelected = [...this.datesArr];
        } else {
            // get all available dates per city
            availableDatesForCurrentCitySelected = this.citiesKeyDatesArrVal[this.eventCity] ? this.citiesKeyDatesArrVal[this.eventCity] : [];
        }
        //
        let availableCitiesForCurrentDateSelected;
        if(this.eventDate === this.selectText) {
            // all cities should be available if the current select option is 'Select...'
            availableCitiesForCurrentDateSelected = [...this.citiesArr];
        } else {
            // get all available cities per date
            availableCitiesForCurrentDateSelected = this.datesKeyCitiesArrVal[this.eventDate] ? this.datesKeyCitiesArrVal[this.eventDate] : [];
        }

        // console.log('>>>>> availableCitiesForCurrentDateSelected ', availableCitiesForCurrentDateSelected);
        // console.log('>>>>> availableDatesForCurrentCitySelected ', availableDatesForCurrentCitySelected);

        // disable unavailable cities
        this.eventCityOptions = this.eventCityOptions.map(cityOption => {
            let cityName = cityOption.value;
            // disable option if city is NOT found in available cities for selected date.
            let disabled;
            if(cityName === this.selectText) disabled = false;
            else disabled = !availableCitiesForCurrentDateSelected.includes(cityName);
            return {
                ...cityOption,
                disabled
            }        
        })
        // disable unavailable dates
        this.eventDateOptions = this.eventDateOptions.map(dateOption => {
            let dateText = dateOption.value;
            // disable option if Date is NOT found in available dates for selected city.
            let disabled;
            if(dateText === this.selectText) disabled = false;
            else disabled = !availableDatesForCurrentCitySelected.includes(dateText);

            return {
                ...dateOption,
                disabled
            }
        })
    }

    // ====================
    // end: updated 10/19/2023
    // ====================



    renderedCallback() {
        if(this.initialRender && (this.isPublicCourse || this.isPrivateCourse)) {
            // Get the JSON string from localStorage
            let eventSessionsJson = window.localStorage.getItem('eventSessions');

            // Convert the JSON string back to an object
            let eventSessions = JSON.parse(eventSessionsJson);
            if(eventSessions && eventSessions[0].Event__c == this.eventSessions[0].Event__c) {
                this.eventSessions = eventSessions;
                window.localStorage.removeItem('eventSessions');
            }
            this.handleSessionChange();
            this.initialRender = false;
        }
    }

    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }

    /**
     * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
     *
     * @type {Category[]}
     */
    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {
        return ((this.priceObjFinal || {}).negotiated || '').length > 0;
    }

    get isEarlyBird() {
        var d = new Date(); var n = d.getTime();
        var deadlineDate = new Date(this.productInfo.fields.Early_Bird_Deadline_formula__c);
        var deadline = deadlineDate.getTime();
        
        if(deadline > n) {
            return true;
        }
    }

    get selectedSessionPrice(){
        return (this.selectedSessionsJson != null ? (Object.keys(JSON.parse(this.selectedSessionsJson)).length) : 1) * this.priceObjFinal.negotiated;
    }
    
    get selectedSessionNumber(){
        return (this.selectedSessionsJson != null ? Object.keys(JSON.parse(this.selectedSessionsJson)).length : 1);
    }

    get fullRegistrationPrice(){
        return (this.eventSessions ? this.eventSessions.length : 1) * this.priceObjFinal.negotiated;
    }

    get fullEarlyBirdPrice(){
        return (this.productInfo.fields.Early_Bird_Registration_Cost_formula__c);
    }

    get sessionEarlyBirdPrice(){
        return (this.productInfo.fields.Early_Bird_Session_Price__c);
    }

    /**
     * Gets whether add to cart button should be displabled
     *
     * Add to cart button should be disabled if quantity is invalid,
     * if the cart is locked, or if the product is not in stock
     */
    get _isAddToCartDisabled() {
        // console.log('this._invalidQuantity' + this._invalidQuantity);
        // return this._invalidQuantity || this.cartLocked || !this.inStock;
        return this._invalidQuantity || this.cartLocked;
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires ProductDetailsDisplay#addtocart
     * @private
     */
    notifyAddToCart() {
        // console.log('notify add to cart');
        if(isGuest) {
            this[NavigationMixin.Navigate](login);
        }
        else {
            let quantity = this._quantityFieldValue;
            this.dispatchEvent(
                new CustomEvent('addtocart', {
                    detail: {
                        quantity,
                        currencyCode: this.priceObjFinal.currency,
                        selectedSessionsJson: this.selectedSessionsJson,
                        selectedSessionNumber: this.selectedSessionNumber
                    }
                })
            );
            // console.log('dispatch orig', quantity, this.selectedSessionNumber, this.selectedSessionsJson, null, 2);
        }


    }


    async addToCartFn() {
        if(isGuest) {
            Array.from(
                this.template.querySelectorAll('.sessions lightning-input')
            ).forEach((currentSession) => {
                if(currentSession.checked){
                    for (let i = 0; i < this.eventSessions.length; i++) {
                        if (this.eventSessions[i].Id == currentSession.dataset.key) {
                            this.eventSessions = JSON.parse(JSON.stringify(this.eventSessions));
                            this.eventSessions[i].isChecked = true;
                        }
                    }

                }
            });
            let eventSessionsJson = JSON.stringify(this.eventSessions);
            // Save the JSON string in localStorage
            window.localStorage.setItem('eventSessions', eventSessionsJson);
            this[NavigationMixin.Navigate](login);

        }
        else {
            this.showLoadingSpinner = true;
            let currentProdCurrency = this.priceObjFinal.currency;
            let cartExist = true; // assume there is a cart

            /**
             * update GPB 2023-10-26
             */
            let createdCart;

            // 1. get cart details
            let cartData;
            try {
                cartData = await getCartByUser({userId});
                cartData = JSON.parse(cartData);
            } catch (e) {
                console.log('error');
                cartExist = false;
            }

            // console.log('cartData', cartData);

            // 1.1 if there is no cart
            if(!cartExist) {
                // create cart with correct currencyCode
                createdCart = await createCart({currencyCode: this.priceObjFinal.currency, ownerId: userId, effectiveAccountId: this.effectiveAccountId});
                // console.log('created Cart from no cart code block', createdCart);

            } else {
                // cart Exist     
                let cartCurrency = cartData.CurrencyIsoCode;
                let hasCartItems = cartData.CartItems ? true : false;
                // 2. check currency of cart
                if(cartCurrency !== currentProdCurrency) {
                    // cart currency is different, check if there are items. 
                    if(hasCartItems) {
                        // show error message that product cannot be added to cart because there are current items 
                        // in the cart and the items have different currency. 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message:
                                    'Could not add this product to Cart because there are items in the cart with a different currency.',
                                messageData: [this.name],
                                variant: 'error',
                                mode: 'dismissable'
                            })
                        );

                        // exit out of the function ==========
                        this.showLoadingSpinner = false;
                        return;
                    } else {
                        // has cart, currency is different, no cart items: delete cart and create a new one
                        await deleteCart({cartId: cartData.Id});
                        createdCart = await createCart({currencyCode: this.priceObjFinal.currency, ownerId: userId, effectiveAccountId: this.effectiveAccountId});
                    }
                } 
            }

            // 3. assign correct cartData
            if(createdCart) cartData = JSON.parse(createdCart);

            // 4. before adding to cart, ensure that the Account and Buyer Account currency is 
            // updated with the product's currency
            await updateAccountCurrency({currencyCode: this.priceObjFinal.currency, userId: userId});

            // 5. add the product to cart after ensuring that all currency in Account, Buyer Account,
            //      WebCart and CartDeliveryGroup has been setup.
            let quantity = this._quantityFieldValue;
            this.dispatchEvent(
                new CustomEvent('gbpaddtocart', {
                    detail: {
                        quantity,
                        selectedSessionsJson: this.selectedSessionsJson,
                        selectedSessionNumber: this.selectedSessionNumber,
                        currencyCode: this.priceObjFinal.currency,
                        cartId: cartData.Id
                    }
                })
            );
            this.showLoadingSpinner = false;
            // end update GPB 2023-10-26
            // console.log('dispatch new', quantity, this.selectedSessionNumber, this.selectedSessionsJson);
        }
    }

    /**
     * Emits a notification that the user wants to add the item to a new wishlist.
     *
     * @fires ProductDetailsDisplay#createandaddtolist
     * @private
     */
    notifyCreateAndAddToList() {
        if(isGuest) {
            this[NavigationMixin.Navigate](login);
        }
        else {
            this.dispatchEvent(new CustomEvent('createandaddtolist'));
        }
    }

    /**
     * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
     *
     * @param {Category[]} newPath
     *  The new category "path" for the product.
     */
    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );

        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );

                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                this._resolvedCategoryPath = levels;
            });
    }

    /**
     * Gets the iterable fields.
     *
     * @returns {IterableField[]}
     *  The ordered sequence of fields for display.
     *
     * @private
     */
    get _displayableFields() {
        // Enhance the fields with a synthetic ID for iteration.
        return (this.customFields || []).map((field, index) => ({
            ...field,
            id: index
        }));
    }

    @track disableDecrement = true;
    handleQuantityChange(event) {
        if(Number.isInteger(Number(event.target.value)) && Number(event.target.value) > 0) {
            this._quantityFieldValue = event.target.value;
        }
        else {
            this._quantityFieldValue = 0;
            //force change bc of how track works
            this._quantityFieldValue = 1;
        }
        if(this._quantityFieldValue > 1) {
            this.disableDecrement = false;
        }
        if(this._quantityFieldValue <= 1) {
            this.disableDecrement = true;
        }
    }

    increment(event){
        this._quantityFieldValue++;
        if(this._quantityFieldValue > 1) {
            this.disableDecrement = false;
        }
    }

    decrement(event){
        if(this._quantityFieldValue > 1) {
            this._quantityFieldValue--;
            this.disableDecrement = false;
        }
        if(this._quantityFieldValue <= 1) {
            this.disableDecrement = true;
        }
    }
}