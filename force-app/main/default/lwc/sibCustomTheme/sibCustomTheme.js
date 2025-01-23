import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorSettings';
import getStorefrontConfigurationSettings from '@salesforce/apex/SIB_ConfiguratorController.getStorefrontConfigurationSettings';

 /**
 * @slot header
 * @slot footer
 * @slot default
 * @slot checkoutHeader
 */
export default class SibCustomTheme extends LightningElement {

  isCheckout = false;
    connectedCallback(){

        getConfig({})
        .then(result => {
            if(!!result){

             /* SIB Color Configs*/   
             if(result.Color_Config__c != undefined){
                var colorConfig = JSON.parse(result.Color_Config__c);
                 if(colorConfig.sibPrimaryButtonColor != undefined){
                   this.template.host.style.setProperty('--sib-primary-button-color',colorConfig.sibPrimaryButtonColor);
                 }
                 if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('-sib-primary-button-text-color:',colorConfig.sibPrimaryButtonTextColor);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-secondary-button-color',colorConfig.sibSecondaryButtonColor);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-secondary-button-text-color',colorConfig.sibSecondaryButtonTextColor);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-h1-text-color',colorConfig.sibH1Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-h2-text-color',colorConfig.sibH2Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-h3-text-color',colorConfig.sibH3Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-h4-text-color',colorConfig.sibH4Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-h5-text-color',colorConfig.sibH5Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-h6-text-color',colorConfig.sibH6Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-p1-text-color',colorConfig.sibP1Color);
                  }
                  if(colorConfig.sibPrimaryButtonColor != undefined){
                    this.template.host.style.setProperty('--sib-p2-text-color',colorConfig.sibP2Color);
                  }
                  if(colorConfig.sibBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-background-color',colorConfig.sibBackgroundColor);
                  }
                  if(colorConfig.sibCardBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-card-background-color',colorConfig.sibCardBackgroundColor);
                  }
                  if(colorConfig.sibBreadcrumbTextColor != undefined){
                    this.template.host.style.setProperty('--sib-breadcrumb-text-color',colorConfig.sibBreadcrumbTextColor);
                  }

                  //PDP
                  if(colorConfig.sibPDPSkuTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-sku-text-color',colorConfig.sibPDPSkuTextColor);
                  }
                  if(colorConfig.sibPDPProductNameTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-product-name-text-color',colorConfig.sibPDPProductNameTextColor);
                  }
                  if(colorConfig.sibPDPAddToCartButtonBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-addToCart-button-background-color',colorConfig.sibPDPAddToCartButtonBackgroundColor);
                  }
                  if(colorConfig.sibPDPAddToCartButtonTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-addToCart-button-text-color',colorConfig.sibPDPAddToCartButtonTextColor);
                  }
                  if(colorConfig.sibPDPDescriptionTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-description-text-color',colorConfig.sibPDPDescriptionTextColor);
                  }
                  if(colorConfig.sibPDPSaleTagBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-sale-tag-background-color',colorConfig.sibPDPSaleTagBackgroundColor);
                  }
                  if(colorConfig.sibPDPSaleTagTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-sale-tag-text-color',colorConfig.sibPDPSaleTagTextColor);
                  }
                  if(colorConfig.sibPDPNewTagBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-new-tag-background-color',colorConfig.sibPDPNewTagBackgroundColor);
                  }
                  if(colorConfig.sibPDPNewTagTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-new-tag-text-color',colorConfig.sibPDPNewTagTextColor);
                  }
                  if(colorConfig.sibPDPPopularTagBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-popular-tag-background-color',colorConfig.sibPDPPopularTagBackgroundColor);
                  }
                  if(colorConfig.sibPDPPopularTagTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-popular-tag-text-color',colorConfig.sibPDPPopularTagTextColor);
                  }
                  if(colorConfig.sibPDPBestSellerTagBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-best-seller-tag-background-color',colorConfig.sibPDPBestSellerTagBackgroundColor);
                  }
                  if(colorConfig.sibPDPBestSellerTagTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-best-seller-tag-text-color',colorConfig.sibPDPBestSellerTagTextColor);
                  }
                  if(colorConfig.sibPDPInventoryInStockTagColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-inventory-inStock-tag-color',colorConfig.sibPDPInventoryInStockTagColor);
                  }
                  if(colorConfig.sibPDPInventoryMediumStockTagColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-inventory-mediumStock-tag-color',colorConfig.sibPDPInventoryMediumStockTagColor);
                  }
                  if(colorConfig.sibPDPInventoryOutofStockTagColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-inventory-outStock-tag-color',colorConfig.sibPDPInventoryOutofStockTagColor);
                  }
                  if(colorConfig.sibPDPInventoryMessageTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-inventory-message-text-color',colorConfig.sibPDPInventoryMessageTextColor);
                  }
                  if(colorConfig.sibPDPInventoryTextColor != undefined){
                    this.template.host.style.setProperty('--sib-pdp-inventory-text-color',colorConfig.sibPDPInventoryTextColor);
                  }

                  //PLP
                  if(colorConfig.sibPLPFilterButtonBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-filter-button-background-color',colorConfig.sibPLPFilterButtonBackgroundColor);
                  }
                  if(colorConfig.sibPLPFilterButtonTextColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-filter-button-text-color',colorConfig.sibPLPFilterButtonTextColor);
                  }
                  if(colorConfig.sibPLPFilterTextColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-filter-heading-text-color',colorConfig.sibPLPFilterTextColor);
                  }
                  if(colorConfig.sibPLPProductNameTextColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-name-text-color',colorConfig.sibPLPProductNameTextColor);
                  }
                  if(colorConfig.sibPLPProductSKUTextColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-sku-text-color',colorConfig.sibPLPProductSKUTextColor);
                  }
                  if(colorConfig.sibPLPPriceTextColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-price-text-color',colorConfig.sibPLPPriceTextColor);
                  }
                  if(colorConfig.sibPLPProductDescriptionTextColor != undefined){
                    this.template.host.style.setProperty('--sib-plp-description-text-color',colorConfig.sibPLPProductDescriptionTextColor);
                  } 

                  //Cart
                  if(colorConfig.sibCartTitleTextColor != undefined){
                    this.template.host.style.setProperty('--sib-cart-title-h2-text-color',colorConfig.sibCartTitleTextColor);
                  } 
                  if(colorConfig.sibCartProductNameTextColor != undefined){
                    this.template.host.style.setProperty('--sib-cart-product-title-text-color',colorConfig.sibCartProductNameTextColor);
                  } 
                  if(colorConfig.sibCartPriceSavedBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-cart-product-price-saved-background-color',colorConfig.sibCartPriceSavedBackgroundColor);
                  } 
                  if(colorConfig.sibCartCheckoutButtonBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-cart-checkout-btn-background-color',colorConfig.sibCartCheckoutButtonBackgroundColor);
                  } 
                  if(colorConfig.sibCartCheckoutButtonTextColor != undefined){
                    this.template.host.style.setProperty('--sib-cart-checkout-btn-text-color',colorConfig.sibCartCheckoutButtonTextColor);
                  } 
                
                  //Checkout
                  if(colorConfig.sibCheckoutTitleTextColor != undefined){
                    this.template.host.style.setProperty('--sib-checkout-title-h2-text-color',colorConfig.sibCheckoutTitleTextColor);
                  } 
                  if(colorConfig.sibCheckoutButtonBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-checkout-button-background-color',colorConfig.sibCheckoutButtonBackgroundColor);
                  } 
                  if(colorConfig.sibCheckoutButtonTextColor != undefined){
                    this.template.host.style.setProperty('--sib-checkout-button-text-color',colorConfig.sibCheckoutButtonTextColor);
                  } 
                  if(colorConfig.sibCheckoutCardBackgroundColor != undefined){
                    this.template.host.style.setProperty('--sib-checkout-card-background-color',colorConfig.sibCheckoutCardBackgroundColor);
                  } 
             }


             /* SIB Font Configs*/   
             if(result.Font_Config__c != undefined){
              var colorConfig = JSON.parse(result.Font_Config__c);
               if(colorConfig.sibH1FontSize != undefined){
                 this.template.host.style.setProperty('--sib-h1-font-size',colorConfig.sibH1FontSize+'px');
               }
               if(colorConfig.sibH1FontWeight != undefined){
                this.template.host.style.setProperty('--sib-h1-font-weight',colorConfig.sibH1FontWeight);
               }
               if(colorConfig.sibH2FontSize != undefined){
                this.template.host.style.setProperty('--sib-h2-font-size',colorConfig.sibH2FontSize+'px');
              }
              if(colorConfig.sibH2FontWeight != undefined){
               this.template.host.style.setProperty('--sib-h2-font-weight',colorConfig.sibH2FontWeight);
              }
              if(colorConfig.sibH3FontSize != undefined){
                this.template.host.style.setProperty('--sib-h3-font-size',colorConfig.sibH3FontSize+'px');
              }
              if(colorConfig.sibH3FontWeight != undefined){
               this.template.host.style.setProperty('--sib-h3-font-weight',colorConfig.sibH3FontWeight);
              }
              if(colorConfig.sibH4FontSize != undefined){
                this.template.host.style.setProperty('--sib-h4-font-size',colorConfig.sibH4FontSize+'px');
              }
              if(colorConfig.sibH4FontWeight != undefined){
               this.template.host.style.setProperty('--sib-h4-font-weight',colorConfig.sibH4FontWeight);
              }
              if(colorConfig.sibH5FontSize != undefined){
                this.template.host.style.setProperty('--sib-h5-font-size',colorConfig.sibH5FontSize)+'px';
              }
              if(colorConfig.sibH5FontWeight != undefined){
               this.template.host.style.setProperty('--sib-h5-font-weight',colorConfig.sibH5FontWeight);
              }
              if(colorConfig.sibH6FontSize != undefined){
                this.template.host.style.setProperty('--sib-h6-font-size',colorConfig.sibH6FontSize+'px');
              }
              if(colorConfig.sibH6FontWeight != undefined){
               this.template.host.style.setProperty('--sib-h6-font-weight',colorConfig.sibH6FontWeight);
              }
              if(colorConfig.sibPrimaryButtonFontSize != undefined){
                this.template.host.style.setProperty('--sib-primary-button-text-font-size',colorConfig.sibPrimaryButtonFontSize+'px');
               }
               if(colorConfig.sibPrimaryButtonTopBottomPadding != undefined && colorConfig.sibPrimaryButtonLeftRightPadding != undefined){
                this.template.host.style.setProperty('--sib-primary-button-padding',colorConfig.sibPrimaryButtonTopBottomPadding + 'px ' + colorConfig.sibPrimaryButtonLeftRightPadding + 'px');
               }
               if(colorConfig.sibSecondaryButtonFontSize != undefined){
                this.template.host.style.setProperty('--sib-secondary-button-text-font-size',colorConfig.sibSecondaryButtonFontSize+'px');
               }
               if(colorConfig.sibSecondaryButtonTopBottomPadding != undefined && colorConfig.sibSecondaryButtonLeftRightPadding != undefined){
                this.template.host.style.setProperty('--sib-secondary-button-padding',colorConfig.sibSecondaryButtonTopBottomPadding + 'px ' + colorConfig.sibSecondaryButtonLeftRightPadding + 'px');
               }

               //PDP
               if(colorConfig.sibPDPProductNameFontSize != undefined){
                this.template.host.style.setProperty('--sib-pdp-product-name-font-size',colorConfig.sibPDPProductNameFontSize+'px');
               }
               if(colorConfig.sibPDPAddToCartFontSize != undefined){
                this.template.host.style.setProperty('--sib-pdp-addToCart-button-font-size',colorConfig.sibPDPAddToCartFontSize+'px');
               }

               //PLP
               if(colorConfig.sibPLPProductNameLines != undefined){
                this.template.host.style.setProperty('--sib-plp-name-lines',colorConfig.sibPLPProductNameLines);
               }
               if(colorConfig.sibPLPProductDescriptionLines != undefined){
                this.template.host.style.setProperty('--sib-plp-description-lines',colorConfig.sibPLPProductDescriptionLines);
               }

               //Cart
               if(colorConfig.sibCartTitleFontSize != undefined){
                this.template.host.style.setProperty('--sib-cart-title-h2-font-size',colorConfig.sibCartTitleFontSize+'px');
               }
               if(colorConfig.sibCartProductNameFontSize != undefined){
                this.template.host.style.setProperty('--sib-cart-product-title-font-size',colorConfig.sibCartProductNameFontSize+'px');
               }

               //Checkout
               if(colorConfig.sibCheckoutTitleFontSize != undefined){
                this.template.host.style.setProperty('--sib-checkout-title-h2-font-size',colorConfig.sibCheckoutTitleFontSize+'px');
               }
          
            }

          }
       })
       .catch(error => {
         window.console.log("error",error.message);
       });

       getStorefrontConfigurationSettings({})
        .then(result => {
            if(!!result){

             /* SIB storefront Configs*/   
             if(result.ConfigJSON__c != undefined){
                var configJSON = JSON.parse(result.ConfigJSON__c);
                 if(configJSON.gridMaxColumnsDisplayed != undefined){
                   this.template.host.style.setProperty('--sib-grid-max-column',configJSON.gridMaxColumnsDisplayed);
                 }
             }

          }
       })
       .catch(error => {
         window.console.log("error",error.message);
       });
    }

}