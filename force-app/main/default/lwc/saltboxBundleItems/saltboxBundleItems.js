import { LightningElement, wire, track, api } from "lwc";
import getBundleProducts from "@salesforce/apex/Saltbox_BundleItems.getBundleProducts";
import communityId from "@salesforce/community/Id";
import { CurrentPageReference } from "lightning/navigation";
export default class SaltboxBundleItems extends LightningElement {

    @api title;
    @api titleColor;
    @api name;
    @api code;
    @api description;

    _isShowEmptyMessage = false;
    _emptyMessage = "";
    @track items = [];
    @track isLoading = true;
    @track hasItems = false;
    rendered = false;
    productId;

    connectedCallback() {
        this.currentCommunityId = communityId;
    }

    renderedCallback() {
        if (this.rendered) return;
        // let titleElem = this.template.querySelector(".title");
        // console.log(titleElem);
        // titleElem.style.color = this.titleColor;

        this.rendered = true;
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            if (currentPageReference.attributes.recordId != undefined) {
                console.log("recordId: " + currentPageReference.attributes.recordId);
                this.productId = currentPageReference.attributes.recordId;
            }
        }
    }
   
    @wire(getBundleProducts, { communityId: "$currentCommunityId", productId: '$productId' }) 
    myBundleItems({ error, data }) {
        this.isPreview = this.isInSitePreview();
        if (!this.isPreview) {
            if (data) {
                console.log(
                    "bundle items data: " + JSON.stringify(data)
                );
                if(data.length){
                    this.hasItems = true;
                    // let titleElem = this.template.querySelector(".title");
                    // console.log(titleElem);
                    // titleElem.style.color = this.titleColor;
                    this.items = data;
                    this.isLoading = false;
                } else {
                    this._isShowEmptyMessage = true;
                    this._emptyMessage =
                    "Bundle items could not be found. Reach out to your administrator.";
                        console.log("##There are no bundle items.");
                }
                
                
            } else if (error) {
                console.log(error);
                this._isShowEmptyMessage = true;
                this._emptyMessage =
                    "Bundle items could not be found. Reach out to your administrator.";
                console.log("##Error in bundle items.");
            }
        } else {
            this.isLoading = false;
            this.items = [
                {
                    Id: "01t7h000005GydFAAS",
                    StockKeepingUnit: "AEX001",
                    Name: "Applied Excel",
                    Description: "This is a sample course description for the Applied Excel Course for preview mode"
                },
                {
                    Id: "01t7h000007IydGAAS",
                    StockKeepingUnit: "EBP001",
                    Name: "Excel Best Practices for PC: Become an Excel Expert",
                    Description: "This is a sample course description for the Excel Best Practices for preview mode"
                }
            ];
        }
    }

    isInSitePreview() {
        let url = document.URL;

        return (
            url.indexOf("sitepreview") > 0 ||
            url.indexOf("livepreview") > 0 ||
            url.indexOf("live-preview") > 0 ||
            url.indexOf("live.") > 0 ||
            url.indexOf(".builder.") > 0
        );
    }
}