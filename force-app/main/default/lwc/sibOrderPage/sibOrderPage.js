import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import { loadStyle,loadScript } from 'lightning/platformResourceLoader';
import getOrderDetails from '@salesforce/apex/SIB_OrderController.getOrderDetails';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTemplateSettings';
import getGTMEventData from '@salesforce/apex/UpdateGTMdataLayerController.getGTMEventData';
import yourItemsName from '@salesforce/label/c.SIB_YourItemsName';
import orderConfirmationName from '@salesforce/label/c.SIB_PageTypeOrderConfirmation';
import orderConfirmationThanksMessage from '@salesforce/label/c.SIB_OrderConfirmationThanksMessage';
import emailConfirmationText from '@salesforce/label/c.SIB_EmailConfirmationText';

export default class SibOrderPage extends NavigationMixin(LightningElement) {

    static renderMode = 'light';
    questStore;
    @api orderDetails;
    @api recordId;
    @api pageType;
    orderData;
    orderNumber;
    showError = false;
    showSubscriptions;
    subscriptionList;
    hasGtmPurchaseDispatched;

    effectiveAccountId;
    webstoreId;
    orderConfig;
    scriptLoaded;

    labels = {
        yourItemsName,
        orderConfirmationName,
        orderConfirmationThanksMessage,
        emailConfirmationText
    }

    get isOrderConfirmationPage() {
        if(this.pageType == this.labels.orderConfirmationName) {
            return true;
        }
        return false;
    }

    get orderConfirmationHeader() {
        if(this.isOrderConfirmationPage) {
            return this.labels.orderConfirmationThanksMessage;
        }
    }

    get orderConfirmationSubHeader() {
        if(this.isOrderConfirmationPage) {
            let msg = this.labels.emailConfirmationText + ' ' + this.billingEmail;
            return msg; 
        }
    }

    get isOrderDataAvailable() {
        return this.orderData != null;
    }

    get billingEmail() {
        return this.orderData.BillingEmailAddress;
    }

    get displayOrderData() {
        return (
            this.isOrderDataAvailable &&
            this.isConfigLoaded &&
            this.scriptLoaded
        );
    }

    get isConfigLoaded() {
        return this.orderConfig != null && this.questStore != null;
    }

    @wire(AppContextAdapter)
    hanldeAppContextAdapterResponse(result){
        if(result.data){
            this.webstoreId = result.data.webstoreId;
            this.getEffectiveAccountId();
        }
    }

    @wire(getConfig,  { })
    getConfigWired({ error, data }) {
        if (data) {
            this.questStore = data == 'templateTwo' ? true : false;
        } else if (error) {
            console.error(error);
        }
    };

    async getEffectiveAccountId(){
        const result = await getSessionContext();
        if(result){
            this.effectiveAccountId = result.effectiveAccountId;
        }
    }

    counter = 0;
    fetchOrderDetails() {
        this.isLoading = true;
        let mapParams = {};
        if(!this.isOrderConfirmationPage) {
            mapParams.recordId = this.recordId;
        }else {
            let queryString = window.location.search;
            let urlParams = new URLSearchParams(queryString);
            let orderNumber = urlParams.get('orderNumber');
            if(orderNumber != undefined) {
                this.orderNumber = orderNumber;
            }
            mapParams.orderNumber = this.orderNumber;  
        }

        if(this.isInSitePreview()) {
            this.orderNumber = 'GVZ3A-J2QC7-YJW47-NBKNH';
        }

        getOrderDetails({
            'mapParams': mapParams
        }).then(
            (result) => {
                this.orderConfig = result.orderConfig;
                if(result.orderWrapper != undefined) {
                    this.orderData = result.orderWrapper;
                    this.dispatchPurchaseEvent(this.orderData?.Id);
                    this.showSubscriptions = result.showSubscriptions;
                    if(result.showSubscriptions) {
                        this.subscriptionList = result.subscriptionList
                    }
                    this.isLoading = false;
                }else {
                    let t = this;
                    setTimeout(() => {
                        if(this.counter < 10) {
                            this.counter++;
                            t.fetchOrderDetails();
                        }else {
                            this.isLoading = false;
                            this.showError = true;
                        }
                    }, 2000);
                }
                
            }).catch((e) => {
                console.log(e);
            }).finally(() => {
        });
    }

    dispatchPurchaseEvent(orderSummaryId)
    {
        this.hasGtmPurchaseDispatched = false;

        const getCookieValues = new CustomEvent("getCookies", {
            bubbles: true,
            composed: true,
            detail: { value: "" },
        });
        this.dispatchEvent(getCookieValues);

        if(getCookieValues != undefined) {

            setTimeout(() => {
                let referrer = getCookieValues.detail.value.split("; ").find((row) => row.startsWith("calltrk_referrer="))?.split("=")[1];

                if (!this.hasGtmPurchaseDispatched) {
                
                    if (referrer == undefined) {
                        referrer = '';
                    }

                    getGTMEventData({recordId: orderSummaryId })
                    .then((result) => {

                        let gtmEventData = JSON.parse(result);

                        const pushToDataLayer = new CustomEvent('updateGTMdataLayer', { 
                            'detail' : { 
                                'event' : 'purchase', 
                                'ecommerce' : {
                                'referrer':referrer,
                                'value': gtmEventData.cost,
                                'currency': gtmEventData.currencyCode,
                                'transaction_id': gtmEventData.osId,
                                'coupon': gtmEventData.coupon,
                                'shipping': 0,	
                                'tax': gtmEventData.tax,
                                'firstName' : gtmEventData.firstName, 
                                'lastName' : gtmEventData.lastName, 
                                'email' : gtmEventData.email, 
                                'cost' : gtmEventData.cost, 
                                'status' : gtmEventData.status, 
                                'items' : gtmEventData.gtmItems
                                } 
                            }
                        });

                        document.dispatchEvent(pushToDataLayer);

                        this.hasGtmPurchaseDispatched = true;
                    })
                    .catch((e) => {
                        console.error(e);
                    });
                }
            }, "1000");
        }
    }

    connectedCallback() {
        this.fetchOrderDetails();
    }
    
    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    constructor() {
        super();
        this.initialLoadCSSAndJS();
    }

    initialLoadCSSAndJS() {
        let themeName = 'order';
        let swiperCSSpath = SIBTheme + '/css/swiper-bundle.min.css';
        let mainCSSPath = SIBTheme + '/css/sib-main.css';
        let orderCSSPath = SIBTheme + '/css/' + themeName + '.css';
        this.plusIcon = SIBTheme + '/images/Plus.png';
        this.minusIcon = SIBTheme + '/images/Minus.png';
        let siteUtilsScriptpath = SIBTheme + '/js/sib-utils.js';
        let swiperScriptpath = SIBTheme + '/js/swiper-bundle.min.js';
        let siteScriptpath = SIBTheme + '/js/sib-site.js';
        Promise.all([
            loadStyle(this, mainCSSPath), 
            loadStyle(this, swiperCSSpath), 
            loadScript(this, siteUtilsScriptpath), 
            loadScript(this, swiperScriptpath)
        ]).then(() => {
            Promise.all([
                loadScript(this, siteScriptpath)
            ]).then(() => {
                this.scriptLoaded = true;
            })
                .catch(error => {
                    console.error(error);
                });
        })
            .catch(error => {
                console.error(error);
            });
    }

    handleNavigateToProductPage(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/' + event.detail
            }
        });
    }
}