import { LightningElement, api } from 'lwc';
import { i18n } from './labels';
import COURSE_DEFAULT_IMAGE from "@salesforce/resourceUrl/SIBTheme";
const SHOW_PRODUCT_EVT = 'showproduct';

export default class SibPublicCourseCalendarCard extends LightningElement {

    static renderMode = 'light';

    @api
    course;

    @api
    plpConfig;

    get image() {
        if(this.course?.c?.Tile_Image_URL__c) {
            return {
                url : this.course?.c?.Tile_Image_URL__c,
                altText : this.course?.c?.Tile_Image_URL__c?.split('/').pop()
            }
        }
        return {
            url : COURSE_DEFAULT_IMAGE + "/images/Course-Default-Image.png",
            altText : 'Default Image'
        }
    }

    get productName() {
        return this.course?.c?.Online_Event_Name__c;
    }

    get trainingLocationCity() {
        return this.course?.c?.Training_Location_City__c;
    }

    get eventDate() {
        return this.course?.c?.SIB_Long_Display_Date__c;
    }

    get deliveryFormat() {
        return this.course?.c?.Delivery_Format__c;
    }

    get badge() {
        if(this.deliveryFormat?.includes(i18n.inPersonPicklistValue)) {
            return {
                badgeCSS : 'badge-green-bg',
                badgeLabel : i18n.inPersonName,
                location : this.trainingLocationCity
            };
        }
        return {
            badgeCSS : 'badge-gray-bg',
            badgeLabel : i18n.virtualName,
            location : this.timeZone
        };
    }

    get classCodeLabel() {
        return i18n.classCodeName;
    }

    get weekendLabel() {
        return i18n.weekendName;
    }

    get classCode() {
        return this.course?.c?.Class_Code__c;
    }

    get timeZone() {
        return this.course?.c?.Event_Time_Zone__c;
    }

    get addToCartButtonStyle() {
        return this.plpConfig?.addToCartButtonStyle;
    }

    get actionButtonVariant() {
        return ['primary', 'secondary', 'tertiary'].includes(this.addToCartButtonStyle) ? this.addToCartButtonStyle : 'primary';
    }

    get learnMoreButtonText() {
        return this.plpConfig?.addToCartButtonText;
    }

    get displayPrice(){
        return this.course?.productDisplayPrice; 
    }

    handleKeydown(evt) {
        if (evt.key === 'Enter') {
            this.handleProductDetailPageNavigation(evt);
        }
    }

    handleProductDetailPageNavigation(event) {
        event.preventDefault();
        const productId = this.course?.productSlugURL != null ? this.course?.productSlugURL : this.course?.productId;

        this.dispatchEvent(
            new CustomEvent(SHOW_PRODUCT_EVT, {
                detail: productId,
            })
        );
    }
}