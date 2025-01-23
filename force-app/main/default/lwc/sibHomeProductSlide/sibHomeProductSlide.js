import { LightningElement, api, track,wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import SIB_Icons from '@salesforce/resourceUrl/SIB_Icons';
import { ProductSearchAdapter } from 'commerce/productApi';


export default class SibHomeProductSlide extends LightningElement {
    static renderMode = 'light';
    @track images;
    @api productCategoryId='0ZGDM000000Gnrh4AC';
    @api cmpName;
    @api permName;

    @wire(ProductSearchAdapter, { categoryId: this.productCategoryId })
    onGetProductDetails(result) {
        console.log('onGetProductDetails >>>>> '+ JSON.stringify(result))
        if (result.data){
        console.log('onGetProductDetails ===>> '+ this.productCategoryId);
        console.log('onGetProductDetails ===>> '+ JSON.stringify(result.data));
        }
    }

connectedCallback() {
    this.initialLoadCSSAndJS();
    this.images = {
        product1:SIB_Icons+'/SIB_Icons/products1.png',
        product2:SIB_Icons+'/SIB_Icons/products2.jpeg',
        product3:SIB_Icons+'/SIB_Icons/products3.jpeg',

        
    }
}

initialLoadCSSAndJS() {

    let swiperCSSpath = SIBTheme + '/css/swiper-bundle.min.css';
    let mainCSSPath = SIBTheme + '/css/sib-main.css';
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
}