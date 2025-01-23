import { LightningElement, api, wire } from "lwc";
import getAllFeatureProduct from "@salesforce/apex/Saltbox_ProductController.getAllFeatureProducts";
import getAllRecommendationProduct from "@salesforce/apex/Saltbox_ProductController.getRecommendateProduct";

import getRecommendedProductsWithOrder from "@salesforce/apex/Saltbox_ProductController.getRecommendedProductsWithOrder";
import getFeaturedProductsWithOrder from "@salesforce/apex/Saltbox_ProductController.getFeaturedProductsWithOrder";

import getManagedContentByContentKeys from "@salesforce/apex/Saltbox_CMSConnector.getManagedContentByContentKeys";
import { CurrentPageReference } from "lightning/navigation";

import getERecommendations from "@salesforce/apex/Saltbox_eRecommendationsController.getERecommendations";

import comId from '@salesforce/community/Id';

export default class SaltboxProductRecommendations extends LightningElement {
  @api type;
  @api tileLayout;
  @api productAttr1FieldName;
  @api hideProductAttr1;
  @api productAttr1ImageId;


  @api featureType;
  @api recommType;

  @api productAttr2FieldName;
  @api hideProductAttr2;
  @api productAttr2ImageId;

  @api productAttr3FieldName;
  @api hideProductAttr3;
  @api productAttr3ImageId;

  @api productImageAttr1FieldName;
  @api hideProductImageAttr1;

  @api productImageAttr1ImageId;

  @api recommSrc;

  @api productWishlistSelectedImage;
  @api productWishlistDeselectedImage;

  @api hideViewDetail;
  @api hideAddtoCart;
  @api hideCartIcon;
  @api titleField;
  @api descField;
  @api brandColor;
  @api noOfRecommendations;
  @api imageAttrTagBackColor;
  @api tilePriceColor;
  @api imageAttrTagTextColor;
  @api buttonLabel;
  @api buttonLabel2;
  @api hideDescription;
  @api hideWishlist;
  @api priceTitle;

  @api effectiveAccountId;

  productList;
  productListWithOrder;
  eProductList;
  error;
  productId;
  productAttr1Deatils = {};
  productAttr2Deatils = {};
  productAttr3Deatils = {};

  productImageAttr1Details = {};

  productWishlistSelectedImageId;
  productWishlistDeselectedImageId;

  productAttrData = [];
  wishListUrl;

  communityId = comId;


  get isVertical() {
    return this.tileLayout == "Vertical Tile";
  }

  @api
  get headerTitleName() {
    return this.type === "Feature" ? "Featured" : "Recommended";
  }

  connectedCallback() {
    console.log('this.type', this.type);
    this.productAttr1Deatils["productAttrFieldName"] =
      this.productAttr1FieldName;
    this.productAttr1Deatils["hideProductAttr"] = this.hideProductAttr1;
    this.productAttr1Deatils["productAttrImageId"] = this.productAttr1ImageId;

    this.productAttr2Deatils["productAttrFieldName"] =
      this.productAttr2FieldName;
    this.productAttr2Deatils["hideProductAttr"] = this.hideProductAttr2;
    this.productAttr2Deatils["productAttrImageId"] = this.productAttr2ImageId;

    this.productAttr3Deatils["productAttrFieldName"] =
      this.productAttr3FieldName;
    this.productAttr3Deatils["hideProductAttr"] = this.hideProductAttr3;
    this.productAttr3Deatils["productAttrImageId"] = this.productAttr3ImageId;

    this.productAttrData.push(
      this.productAttr1Deatils,
      this.productAttr2Deatils,
      this.productAttr3Deatils
    );

    this.productImageAttr1Details["productAttrFieldName"] =
      this.productImageAttr1FieldName;
    this.productImageAttr1Details["hideProductAttr"] =
      this.hideProductImageAttr1;
    this.productImageAttr1Details["productAttrImageId"] =
      this.productImageAttr1ImageId;

    this.productWishlistSelectedImageId = this.productWishlistSelectedImage;
    this.productWishlistDeselectedImageId = this.productWishlistDeselectedImage;

    // console.log('this.type', this.type);

    if (this.type == "Recommendation") {
      if (this.productId) {
        if (this.isInBuilder || this.recommSrc == "B2B Recomm Records") {
          this.getAllRecommendationProducts();
          this.getRecommendedProductsWithOrder();
        }else{
          this.getERecommendations();
        }
      }
    } else {
      if (this.isInBuilder || this.recommSrc == "B2B Recomm Records") {
        this.getAllFeatureProducts();
        this.getFeaturedProductsWithOrder();
      }else{
        this.getEFeatured();
      }
    }
  }

  get isInBuilder() {
    const urlToCheck = window.location.hostname.toLowerCase();
    return urlToCheck.indexOf('sitepreview') >= 0 ||
        urlToCheck.indexOf('livepreview') >= 0 ||
        urlToCheck.indexOf('--live') >= 0 || urlToCheck.indexOf('live-preview') >= 0;
  };


  renderedCallback() {
    this.initCSSVariables();
    // console.log('this.productList ====', this.productList);
  }
  initCSSVariables() {
    var css = document.body.style;
    css.setProperty("--brand", this.brandColor);
    css.setProperty("--tagPriceColor", this.tilePriceColor);
    css.setProperty("--tagBackgroundColor", this.imageAttrTagBackColor);
    css.setProperty("--tagTextColor", this.imageAttrTagTextColor);
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      if (currentPageReference.attributes.recordId != undefined) {
        this.productId = currentPageReference.attributes.recordId;
      }
    }
  }

  getEFeatured(){
    getERecommendations({recommender: this.featureType.replaceAll(' ',''), anchorValues: "", cookie: document.cookie})
      .then((result) => {
        this.eProductList = JSON.parse(result).productPage.products;
        // console.log('this.eProductList', this.eProductList);
        // console.log('this.productList', this.productList);
        this.manageEPL(JSON.parse(result).productPage.products);
        if (this.productList == false) {
          this.getAllFeatureProducts();
          this.getFeaturedProductsWithOrder();
        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.error(error);
        this.productList = undefined;
      });
  }

  getERecommendations(){
    getERecommendations({recommender: this.recommType.replaceAll(' ',''), anchorValues: this.productId, cookie: document.cookie})
      .then((result) => {
        this.eProductList = JSON.parse(result).productPage.products;
        this.manageEPL(JSON.parse(result).productPage.products);
        if (this.productList == false) {
          this.getAllRecommendationProducts();
          this.getRecommendedProductsWithOrder();

        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.error(error);
        this.productList = undefined;
      });
  }

  manageEPL(ePL){
    let tempEPL = [];
    let length;
    if (ePL.length > this.noOfRecommendations) {
      length = this.noOfRecommendations;
    } else{
      length = ePL.length;
    }
    
    for (let i = 0; i < length; i++) {
      let tempProduct = [];
      tempProduct.defaultImage = ePL[i].defaultImage;
      tempProduct.error = ePL[i].error;
      tempProduct.id = ePL[i].id;
      tempProduct.prices = ePL[i].prices;
      tempProduct.sku = ePL[i].fields.StockKeepingUnit.value;
      tempProduct.fields = [];

      for (let field in ePL[i].fields) {
        tempProduct.fields[field] = ePL[i].fields[field].value;
      }

      tempEPL.push(tempProduct);

    }

    if (tempEPL.length == 0) {
      console.log('tempEpl function setting productlist to false');
      this.productList = false;
    }else{
      this.productList = tempEPL;
    }
    

  }

  getAllRecommendationProducts() {

    // getAllRecommendationProduct({ productId: this.productId })
    getAllRecommendationProduct({ productId: this.productId, communityId: comId, effectiveAccountId: this.effectiveAccountId })
      .then((result) => {
        console.log('result >>>>>>', JSON.parse(result));
        if (result === 'no recommendation product') {
          this.productList = false;
          return;
        }
        this.productList = JSON.parse(result).products;
        if (this.productList.length > this.noOfRecommendations) {
          this.productList.length = this.noOfRecommendations;
        }
        this.error = undefined;
      })
      .catch((error) => {
        console.log('error', error);
        this.error = error;
        console.error(error);
        this.productList = undefined;
      });
  }

  getRecommendedProductsWithOrder() {
    getRecommendedProductsWithOrder({ productId: this.productId })
      .then((result) => {
        console.log('result', result);
        this.productListWithOrder = JSON.parse(result);
        this.error = undefined;
        this.sortProductList();
      })
      .catch((error) => {
        console.log('error', error);
        this.error = error;
        this.productList = undefined;
      });
  }

  sortProductList() {
    // let withOrder = this.productListWithOrder;
    // let pList = this.productList;
    // let tempProductList = [];
    // for (let i = 0; i < withOrder.length; i++) {
    //   for (let j = 0; j < pList.length; j++) {
    //     if (withOrder[i].Recommended_Product__c == pList[j].id) {
    //       tempProductList.splice(withOrder[i].Order__c-1,0,pList[j]);
    //     }
    //   }
    // }
    // if (tempProductList.length>0) {
    //   this.productList = tempProductList;
    // } else {
    //   console.log('sortProductList to false');
    //   this.productList = false;
    // }
    

  }

  getAllFeatureProducts() {
    getAllFeatureProduct()
      .then((result) => {
        // console.log('result', JSON.parse(result));
        this.productList = JSON.parse(result).products;
        // console.log('this.productList', this.productList);
        if (this.productList.length > this.noOfRecommendations) {
          this.productList.length = this.noOfRecommendations;
        }
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.productList = undefined;
        console.log("err:", JSON.stringify(this.error));
      });
  }

  getFeaturedProductsWithOrder() {
    getFeaturedProductsWithOrder()
      .then((result) => {
        this.productListWithOrder = JSON.parse(result);
        this.error = undefined;
        this.sortProductList();
      })
      .catch((error) => {
        this.error = error;
        this.productList = undefined;
      });
  }

}