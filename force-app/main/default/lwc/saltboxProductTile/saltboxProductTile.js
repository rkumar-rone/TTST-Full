import { LightningElement, api, wire, track } from "lwc";
import horizontalTemplate from "./saltboxHorizontalProductTile.html";
import horizontalStencil from "./saltboxHorizontalProductStencil.html";
import verticalTemplate from "./saltboxVerticalProductTile.html";
import verticalStencil from "./saltboxVerticalProductStencil.html";
import mobileProductTile from "./saltboxProductMobileTile.html";
import mobileStencil from "./saltboxProductMobileStencil.html";
import getManagedContentByContentKeys from "@salesforce/apex/Saltbox_CMSConnector.getManagedContentByContentKeys";
import addCartItem from "@salesforce/apex/Saltbox_ProductController.addCartItem";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import basePath from "@salesforce/community/basePath";
import { NavigationMixin } from "lightning/navigation";
import isGuestUser from "@salesforce/user/isGuest";
import getWishLists from "@salesforce/apex/Saltbox_B2BWishlistController.getWishListsModal";
import { getPathPrefix } from "lightning/configProvider";

export default class SaltboxProductTile extends NavigationMixin(
  LightningElement
) {
  @api product;
  @api tileLayout;
  @api hideAddtoCart;
  @api hideCartIcon;
  @api hideViewDetail;
  @api descField;
  @api titleField;
  @api buttonLabel;
  @api buttonLabel2;
  @api wishListUrl;
  @api hideDescription;
  @api hideWishlist;
  @api priceTitle;
  pageReference;
  basePath = basePath;
  isGuestUser = isGuestUser;
  wishListData;
  itemIsInWishlist = false;
  // @api productAttr1Deatils;
  // @api productAttr2Deatils;
  // @api productAttr3Deatils;
  @api productAttrData;
  @api productImageAttr;
  // productAttr1Data;
  // productAttr2Data;
  // productAttr3Data;
  mutProductAttrData = [];
  productImageAttrImg;
  mutProductImageAttr = {};
  title;
  description;
  showWishListModal = false;

  @api selectedWishlistImage;
  @api deselectedWishlistImage;

  @api effectiveAccountId;
  @api communityId

  productSelectedWishlistImage;
  productDeselectedWishlistImage;

  parsedDefaultImage;

  @track isLoading = true;

  render() {
    if (window.screen.width < 460) {
      if(this.isLoading == true){
        return mobileStencil;
      }
      else{
        return mobileProductTile;
      }
      
    } else {
      if(this.isLoading == true){
        return this.tileLayout == "Vertical Tile"
        ? verticalStencil
        : horizontalStencil;
      }
      else{
        return this.tileLayout == "Vertical Tile"
        ? verticalTemplate
        : horizontalTemplate;
      }
    }
  }

  get hideFooter() {
    return this.hideAddtoCart == true && this.hideViewDetail == true;
  }

  parseText(text){
    let elem = document.createElement('textarea');
    elem.innerHTML = text;
    return elem.value;
}

  // Make it in iteration
    connectedCallback() {
      this.title = this.parseText(this.product.fields[this.titleField]);
      this.description = this.product.fields[this.descField];

      for (var i = 0; i < this.productAttrData.length; i++) {
        var obj = { ...this.productAttrData[i] };
        obj["productAttrValue"] =
          this.product.fields[this.productAttrData[i].productAttrFieldName];
        this.mutProductAttrData.push(obj);
      }

      if (this.product?.defaultImage?.url != null) {

          this.parsedDefaultImage = this.resolve(this.product.defaultImage.url);

          // this.product.defaultImage.url = Object.assign(this.product.defaultImage.url, parsedURL);;
      }

      // console.log(JSON.parse(JSON.stringify(this.product.defaultImage)));
      
      this.mutProductImageAttr = { ...this.productImageAttr };
      this.mutProductImageAttr["productAttrValue"] =
        this.product.fields[this.mutProductImageAttr.productAttrFieldName];

      getManagedContentByContentKeys({
        managedContentIds: this.mutProductImageAttr.productAttrImageId
      })
        .then((data) => {
          if (data) {
            this.getImageData =
              typeof data === "object" ? data : JSON.parse(data);

            if (this.getImageData.success) {
              this.productImageAttrImg = this.getImageData.image;
              this.isLoading = false;
            }
          }
        })
        .catch((error) => {
          this.error = error;
        });

      getManagedContentByContentKeys({
        managedContentIds: this.selectedWishlistImage
      })
        .then((data) => {
          if (data) {
            this.getImageData =
              typeof data === "object" ? data : JSON.parse(data);
  
            if (this.getImageData.success) {
              this.productSelectedWishlistImage = this.getImageData.image;
            }
          }
        })
        .catch((error) => {
          this.error = error;
        });

        getManagedContentByContentKeys({
          managedContentIds: this.deselectedWishlistImage
        })
          .then((data) => {
            if (data) {
              this.getImageData =
                typeof data === "object" ? data : JSON.parse(data);
    
              if (this.getImageData.success) {
                this.productDeselectedWishlistImage = this.getImageData.image;
              }
            }
          })
          .catch((error) => {
            this.error = error;
          });
    
      var productName = this.product?.fields?.Name?.replaceAll(/[^a-zA-Z ]/g, "");
      if(productName) {
        productName = productName.replaceAll(" ", "-");
        this.pageReference = {
          type: "standard__webPage",
          attributes: {
            url: this.basePath + "/product/" + productName + "/" + this.product.id
          }
        };
      }


      // Comment this piece out if needing to deploy without wishlist functionality
      this.handleGetWishlist();
    }

    // Update Image URLs coming from CMS (URL or Uploaded images)
    resolve(url) {
        /**
         * Regular expressions for CMS resources and for static B2B image resources -
         * specifically the "no image" image - that we want to handle as though they were CMS resources.
         */
        const cmsResourceUrlPattern = /^\/cms\//;
        const b2bStaticImageResourcePattern = /^\/img\//;
        // If the URL is a CMS URL, transform it; otherwise, leave it alone.
        if (
            cmsResourceUrlPattern.test(url) ||
            b2bStaticImageResourcePattern.test(url)
        ) {
            url = `${getPathPrefix()}${url}`;
        }
    
        return url;
    }

  // Comment this piece out if needing to deploy without wishlist functionality
  handleGetWishlist() {

    getWishLists({
      communityId: this.communityId, 
      effectiveAccountId: this.effectiveAccountId
    })
      .then((data) => {
        if (data) {
          this.wishListData = JSON.parse(data);
          this.handleWishlistAdded();
        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.wishListData = [];

        console.log(` error: ${JSON.stringify(this.error)}`);
      });
  }

  handleWishlistAdded() {
    for (var i = 0; i < this.wishListData.length; i++) {
      if (this.wishListData[i].wishlistItems.length > 0) {
        for (var j = 0; j < this.wishListData[i].wishlistItems.length; j++) {
          if (
            this.wishListData[i].wishlistItems[j].Product2Id == this.product.id
          ) {
            console.log("Added");
            this.itemIsInWishlist = true;
            break;
          }
        }
      }
    }
  }

  addItemToCart() {
    addCartItem({ productId: this.product.id })
      .then((data) => {
        if (data) {
          const payload = {
            Update: true
          };
          this.showNotification(
            "Cart Item",
            "Item Added Successfully!",
            "success"
          );
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("error:", error);
      })
      .finally(() => {
        this.dispatchEvent(
          new CustomEvent("cartchanged", {
            bubbles: true,
            composed: true
          })
        );
      });
  }

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  handleViewDetail() {
    if (this.pageReference) {
      this[NavigationMixin.Navigate](this.pageReference);
    }
  }

  handleWishListModal() {
    this.handleGetWishlist();
    if (this.showWishListModal) {
      console.log('open wishlist modal');
      this.showWishListModal = false;
    } else {
      console.log('close wishlist modal');

      this.showWishListModal = true;
      // const payload = {
      //     open: true,
      //     productId: this.product.id
      //   };
      // publish(this.messageContext, openWishlistModal, payload);
    }
  }

  cancelModel() {
    this.showWishListModal = false;
  }
}