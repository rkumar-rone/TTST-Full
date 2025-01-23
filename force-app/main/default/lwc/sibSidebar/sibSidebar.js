import { LightningElement,api,wire,track } from 'lwc';
import { publish, subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import SIDEBAR_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibSidebarSectionMessages__c';
import getStorefrontModule from '@salesforce/apex/SIB_ProductListingPageController.getStorefrontModule';

export default class SibSidebar extends LightningElement {
    @api moduleName;
    @track sections=[];
    subscription=null;
    firstLoad = true;
    stickyTop = 29; // This is the offset from the top where the component should stick
    contentBottom;
    chosenSection;

    get sectionLength(){
        return this.sections.length;
    }

    get sectionOptions(){
        if(this.sections){
            return this.sections.map(section => {
                return {label:section, value:section};
            });
        }
    }

    get sectionOptionsLength(){
        return this.sectionOptions.length;
    }

    @wire(MessageContext)
    messageContext;

    @wire(getStorefrontModule,  {moduleName:'$moduleName' })
    wiredConfig({ error, data }) {
        if (data) {
            this.sections = data[this.moduleName];
            this.chosenSection = this.sections[0];
            const payload = { 
                sections: this.sections,
            };
            publish(this.messageContext, SIDEBAR_MESSAGE_CHANNEL, payload);
        } else if (error) {
            console.log('Error in wire: '+error);
        }
    };

    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            SIDEBAR_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message){
        if(message.scrollSectionHeading){
            let elementId = message.scrollSectionHeading;
            const headings = this.template.querySelectorAll('.heading');
            headings.forEach(heading => {
                if(heading.dataset.id!=elementId){
                    heading.classList.remove('activeHeading');
                }
                else{
                    heading.classList.add('activeHeading');
                }
            });
        }
        else if(message.contentBottom){
            this.contentBottom = message.contentBottom;
        }
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    renderedCallback(){
        //this.updateStickyPosition();
        if(this.firstLoad && this.sections){
            const heading = this.template.querySelector("[data-id='"+this.sections[0]+"']");
            if(heading){
                heading.classList.add('activeHeading');
                this.firstLoad=false;
            }
        }
    }

    get moduleMap(){
        return {'moduleName':this.moduleName};
    }

    scrollToHeading(event){
        const payload = { 
            activeSection: event.currentTarget.dataset.id,
            scrollBlock: 'end'
        };
        publish(this.messageContext, SIDEBAR_MESSAGE_CHANNEL, payload);
        let elementId = event.currentTarget.dataset.id;
        const headings = this.template.querySelectorAll('.heading');
        headings.forEach(heading => {
            if(heading.dataset.id!=elementId){
                heading.classList.remove('activeHeading');
            }
            else{
                heading.classList.add('activeHeading');
            }
        });
    }

    scrollToHeadingMobile(event){
        const payload = { 
            activeSection: event.target.value,
            scrollBlock: 'center'
        };
        publish(this.messageContext, SIDEBAR_MESSAGE_CHANNEL, payload);
    }


}