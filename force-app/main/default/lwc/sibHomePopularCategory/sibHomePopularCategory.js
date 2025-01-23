import { LightningElement,api,track } from 'lwc';
import SIB_Icons from '@salesforce/resourceUrl/SIB_Icons';


export default class SibHomePopularCategory extends LightningElement {
    static renderMode = 'light';

    @track images;
    connectedCallback() {
    this.images = {
        product1:SIB_Icons+'/SIB_Icons/popular_product1.png',
        product2:SIB_Icons+'/SIB_Icons/popular_product2.png',
        product3:SIB_Icons+'/SIB_Icons/popular_product3.png',
        product4:SIB_Icons+'/SIB_Icons/popular_product4.png',
        product5:SIB_Icons+'/SIB_Icons/popular_product5.png',
        product6:SIB_Icons+'/SIB_Icons/popular_product6.png',
        product7:SIB_Icons+'/SIB_Icons/popular_product7.png',
        product8:SIB_Icons+'/SIB_Icons/popular_product8.png',
    }
}
}