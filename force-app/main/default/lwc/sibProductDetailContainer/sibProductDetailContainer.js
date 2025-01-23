import { LightningElement } from 'lwc';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import SUMMARY_HEADING from '@salesforce/label/c.SIB_PDPMobileSummaryHeading';
import SUMMARY_HEADING_SELF_STUDY from '@salesforce/label/c.SIB_PDPMobileSummaryHeading_SelfStudy';
/**
 * @slot header
 * @slot breadcrumb
 * @slot menubar
 * @slot overview
 * @slot whatsIncluded
 * @slot previews
 * @slot certificate
 * @slot prerequistes
 * @slot reviews
 * @slot product-description
 * @slot add-to-cart
 * @slot rating 
 * @slot recommendations
 * @slot footer
*/

export default class SibProductDetailContainer extends LightningElement {

    static renderMode = 'light';

    fixedTopOffset = 250;
    topUpperOffset = 50;
    topLowerOffeset = -50;
    bottomUpperOffset = 200;
    bottomLowerOffset = 100;
    threshold = 5;
    lastScrollTop = 0;

    selectedSlot;

    trackScroll=true;
    isSelfStudy;

    labels={
        SUMMARY_HEADING,
        SUMMARY_HEADING_SELF_STUDY
    }

    connectedCallback() {
        window.addEventListener('scroll', this.handleScroll.bind(this));
        window.addEventListener('scrolltosection', this.handleScrollToSection.bind(this));
        window.addEventListener('productdata', this.handleProductData.bind(this));
        window.addEventListener('isSpinnerOn', this.handleSpinner.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('scroll', this.handleScroll.bind(this));
        window.removeEventListener('scrolltosection', this.handleScrollToSection.bind(this));
        window.removeEventListener('productdata', this.handleProductData.bind(this));
        window.removeEventListener('isSpinnerOn', this.handleSpinner.bind(this));
    }

    handleSpinner(msg){
        let element = this.querySelector(".menu-sticky-section");
        if(msg && msg.detail) {
            if(msg.detail.isLoading){
                element.classList.add("loading");
            }
            else{
                element.classList.remove("loading");

            }
        }
    }

    handleProductData(msg) {
        let element = this.querySelector(".cart-view");

        if(msg && msg.detail) {
            if(msg.detail.params.productClass == 'Variation'){
                element.style.top = "130px";
            }
            else{
                element.style.top = "220px";
            }
            this.isSelfStudy = msg.detail.params.isSelfStudy; 
        }   
    }

    handleScroll() {
        if(this.trackScroll){
            const currentScrollTop = window.scrollY;
            // Calculate the difference from the last scroll position
            const diff = currentScrollTop - this.lastScrollTop;
            // Only check the direction if the scroll difference exceeds the threshold
            if (Math.abs(diff) > this.threshold) {
                if (diff > 0) {
                    this.downScroll=true;
                } else {
                    this.downScroll=false;
                }

                // Update the last scroll position
                this.lastScrollTop = currentScrollTop;
            }
            let elementToScroll = this.querySelectorAll(".sections");
            if(this.downScroll){
                elementToScroll.forEach(section => {
                    const sectionTop = Number(section.getBoundingClientRect().top) - Number(this.fixedTopOffset);
                    if (sectionTop >= this.topLowerOffeset && sectionTop <= this.topUpperOffset) {
                        window.dispatchEvent(
                            new CustomEvent("activemenuitem", {
                                detail: {
                                    name: section.dataset.scroll
                                },
                                bubbles: true,
                                composed: true
                            })
                        );
                    }
                });
            }
            else{
                elementToScroll.forEach(section => {
                    const sectionBottom = Number(section.getBoundingClientRect().bottom) - Number(this.fixedTopOffset);
                    if (sectionBottom >= this.bottomLowerOffset && sectionBottom <= this.bottomUpperOffset) {
                        window.dispatchEvent(
                            new CustomEvent("activemenuitem", {
                                detail: {
                                    name: section.dataset.scroll
                                },
                                bubbles: true,
                                composed: true
                            })
                        );
                    }
                });
            } 
        }
    }

    handleScrollToSection(msg) {
        this.trackScroll = false;
        this.selectedSlot = msg.detail.name;
        let elementToScroll = this.querySelector("[data-scroll='"+ this.selectedSlot +"']");
        if(elementToScroll){
            const rect = elementToScroll.getBoundingClientRect();
            window.scrollTo({
                top: Number(rect.top + window.scrollY - this.fixedTopOffset),
                behavior: 'smooth' // Optional: for smooth scrolling
            });
            setTimeout(()=>{
                this.trackScroll = true;
            },600);
        }
    }

    constructor() {
        super();
        this.initialLoadCSSAndJS();
    }

    initialLoadCSSAndJS() {
        let themeName = 'product-details';
        let swiperCSSpath = SIBTheme + '/css/swiper-bundle.min.css';
        let mainCSSPath = SIBTheme + '/css/sib-main.css';
        let productDetailCSSPath = SIBTheme + '/css/' + themeName + '.css';
        let siteUtilsScriptpath = SIBTheme + '/js/sib-utils.js';
        let swiperScriptpath = SIBTheme + '/js/swiper-bundle.min.js';
        let siteScriptpath = SIBTheme + '/js/sib-site.js';
        Promise.all([
            loadStyle(this, mainCSSPath), loadStyle(this, swiperCSSpath), loadScript(this, siteUtilsScriptpath), loadScript(this, swiperScriptpath)
        ]).then(() => {
            Promise.all([
                loadScript(this, siteScriptpath)
            ])
            .then(() => {
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

    showSummarySection=false;
    summaryIcon='utility:add';
    addToCart = 'add-to-cart';
    handleSummary(){
        const summarySection = this.querySelector(".mobile-summary-section");
        const summaryHeading = this.querySelector(".summary-heading");
        this.showSummarySection=!this.showSummarySection;
        if(summaryHeading){
            if(this.showSummarySection){
                summaryHeading.classList.add("summaryFix");
            }
            else{
                summaryHeading.classList.remove("summaryFix");
            }
        }
        if(summarySection){
            summarySection.classList.toggle("dim");
        }
        if(this.summaryIcon=='utility:add'){
            this.summaryIcon = 'utility:dash';
        }
        else{
            this.summaryIcon='utility:add';
        }

        this.dispatchEvent(new CustomEvent('summarysectionchange', 
            {
            detail: {'message':this.showSummarySection},
             bubbles: true,
             composed: true
            })
        );
    }
}