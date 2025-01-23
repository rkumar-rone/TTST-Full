import { LightningElement,wire,track } from 'lwc';
import { publish, subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import SIDEBAR_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibSidebarSectionMessages__c';

/**
 * @slot header
 * @slot breadcrumb
 * @slot sidebar
 * @slot section_1
 * @slot section_2
 * @slot section_3
 * @slot section_4
 * @slot section_5
 * @slot footer
*/

export default class SibSelfStudyContainer extends LightningElement {
    topUpperOffset = 50;
    topLowerOffset = -50;
    fixedTopOffset = 190;
    bottomUpperOffset = 400;
    bottomLowerOffset = 300;
    threshold = 5;
    lastScrollTop = 0;
    downScroll = true;
    firstLoad=true;
    activeSection;
    subscription=null;
    sectionsArray=[];
    section_1;
    section_2;
    section_3;
    section_4;
    section_5;
    trackScroll = true;
    @track domSections=[];

    get sectionArrayLength(){
        return this.sectionsArray.length;
    }

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    renderedCallback(){
        if(this.firstLoad){
            this.domSections = this.template.querySelectorAll('.section');
            window.addEventListener('scroll', this.handleScroll.bind(this));
        }
    }

    handleScroll(){
        if(this.domSections.length>0 && this.trackScroll){
            this.firstLoad=false;
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
            this.domSections.forEach(section => {
                if(this.downScroll){
                    const sectionTop = Number(section.getBoundingClientRect().top) - Number(this.fixedTopOffset);
                    if (sectionTop>=this.topLowerOffset && sectionTop<=this.topUpperOffset) {
                        setTimeout(()=>{
                            const payload = { 
                                scrollSectionHeading: section.dataset.scroll,
                            };
                            publish(this.messageContext, SIDEBAR_MESSAGE_CHANNEL, payload);
                        });
                    }
                }
                else{
                    const sectionBottom = Number(section.getBoundingClientRect().bottom) - Number(this.fixedTopOffset);
                    if (sectionBottom>=this.bottomLowerOffset && sectionBottom<=this.bottomUpperOffset) {
                        setTimeout(()=>{
                            const payload = { 
                                scrollSectionHeading: section.dataset.scroll,
                            };
                            publish(this.messageContext, SIDEBAR_MESSAGE_CHANNEL, payload);
                        });
                    }
                }
                
            });
        }
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
        window.removeEventListener('scroll', this.handleScroll.bind(this));
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            SIDEBAR_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        if(message.activeSection){
            this.trackScroll = false;
            this.activeSection = message.activeSection;
            this.scrollToHeading(this.activeSection,message.scrollBlock);
        }
        else if(message.sections){
            this.sectionsArray = message.sections;
            this.section_1 = this.sectionsArray[0];
            this.section_2 = this.sectionsArray[1];
            this.section_3 = this.sectionsArray[2];
            this.section_4 = this.sectionsArray[3];
            this.section_5 = this.sectionsArray[4];
            this.activeSection = this.section_1;
            this.template.querySelector('.main').classList.remove('conditionalDisplay');
            this.template.querySelector('.mainStencil').classList.add('conditionalDisplay');

        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    scrollToHeading(section,scrollBlock){
            let elementToScroll = this.template.querySelector("[data-scroll='"+section+"']");
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
            else{
                this.trackScroll = true;
            }
    }
}