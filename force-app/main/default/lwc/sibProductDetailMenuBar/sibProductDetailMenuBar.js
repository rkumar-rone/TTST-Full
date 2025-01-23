import { LightningElement,api,track } from 'lwc';

export default class SibProductDetailMenuBar extends LightningElement {

    static renderMode = 'light';

    @track menuItem = [];

    fixedTopOffset = 190;
    firstLoad = true;

    _productDetail;
    @api 
    get productDetail(){
        return this._productDetail;
    }
    set productDetail(value){
        this._productDetail = value;
        if(value){
            this.prepareMenuItems(value);
        }
    }

    prepareMenuItems(value){
        //Overview
        if(value?.fields?.Why_Take_This_Course__c || value?.fields?.Who_is_this_course_for__c || value?.fields?.SIB_Vimeo_Overview_URL__c){
            this.menuItem.push({ label: "Overview", slotName: "overview"});
        }

        //What's Included
        if(value?.fields?.What_s_Included_in_the_CostRT__c || value?.fields?.Agenda__c){
            this.menuItem.push({ label: "What's Included", slotName: "whatsIncluded"});
        }

        //Previews
        if(value?.fields?.SIB_Vimeo_Preview1_URL__c || value?.fields?.SIB_Vimeo_Preview2_URL__c){
            this.menuItem.push({ label: "Previews", slotName: "previews"});
        }

        //Certificate
        if(value?.fields?.SIB_Certificate_Title__c || value?.fields?.SIB_Certificate_Description__c){
            this.menuItem.push({ label: "Certificate", slotName: "certificate"});
        }

        //Policy
        if(value?.fields?.Cancellation_Policy__c || value?.fields?.Prerequisite__c){
            this.menuItem.push({ label: "Policy", slotName: "prerequistes"});
        }
    }
    

    scrollToSection(event) {
        let elementId = event.currentTarget.dataset.id;
        
        window.dispatchEvent(
            new CustomEvent("scrolltosection", {
                detail: {
                    name: elementId
                },
                bubbles: true,
                composed: true
            })
        );

        this.showActiveMenu(elementId);
    }

    connectedCallback() {
        window.addEventListener('activemenuitem', this.handleActiveMenuItem.bind(this));
        window.addEventListener('scroll', this.handleScroll.bind(this));
        window.addEventListener('ratingreviews', this.handleRatingReviews.bind(this));

        
    }

    disconnectedCallback() {
        window.removeEventListener('activemenuitem', this.handleActiveMenuItem.bind(this));
        window.removeEventListener('ratingreviews', this.handleRatingReviews.bind(this));
    }

    handleRatingReviews(msg){
        if(msg && msg.detail){
            if(msg.detail.rating || msg.detail.reviews){
                this.menuItem.push({ label: "Reviews", slotName: "reviews"});
            }
        }
    }

    handleScroll() {
        const menuBar = this.querySelector('.product-detail-bar');
        if(menuBar){
            const sectionTop = Number(menuBar.getBoundingClientRect().top) - this.fixedTopOffset;
            const menuItems = this.querySelectorAll('.menu-items');
            const whiteDiv = this.querySelector('.white-placeholder');
            if(sectionTop<=-17) {
                if(menuItems){
                    menuItems.forEach(item=>{
                        item.classList.remove('menubar-hide');
                    });
                }
                whiteDiv.classList.add('menubar-hide');
            } else {
                if(menuItems){
                    menuItems.forEach(item=>{
                        item.classList.add('menubar-hide');
                    });
                }
                whiteDiv.classList.remove('menubar-hide');
            }
        }
    }

    handleActiveMenuItem(msg) {
        this.showActiveMenu(msg.detail.name);
    }

    showActiveMenu(item) {
        const headings = this.querySelectorAll('.menu-items');
        headings.forEach(heading => {
            if(heading.dataset.id != item){
                heading.classList.remove('activeItem');
            }
            else{
                heading.classList.add('activeItem');
            }
        });
    }
}