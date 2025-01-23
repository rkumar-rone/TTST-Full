/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_B2BPricingService implements ISIB_PricingService {
    

    public SIB_ProductPricing getProductPricing(SIB_ProductRequest productRequest){
        SIB_ProductPricing productPrice = new SIB_ProductPricing();
        ConnectApi.ProductPrice connectProductPrice = SIB_B2BConnectAPI.getProductPrice(productRequest.webStoreId, productRequest.productId, productRequest.accountId);
        if(connectProductPrice!= null){
            productPrice = transformData(connectProductPrice);
        }
        return productPrice;
    }

    public SIB_ProductPricing transformData(Object data){
        ConnectApi.ProductPrice connectProductPrice = (ConnectApi.ProductPrice)data;
        SIB_ProductPricing productPrice  = new SIB_ProductPricing();
        productPrice.currencyCode = connectProductPrice.currencyIsoCode ;
        productPrice.pricebookEntryId = connectProductPrice.pricebookEntryId ;
        productPrice.unitPrice = Decimal.valueOf(connectProductPrice.unitPrice)   ;
        productPrice.listPrice = connectProductPrice.listPrice != null ? Decimal.valueOf( connectProductPrice.listPrice) : productPrice.unitPrice ;
        productPrice.negotiatedPrice =  Decimal.valueOf(  connectProductPrice.unitPrice ) ;
        if(productPrice.listPrice > productPrice.negotiatedPrice){
            productPrice.negotiatedPriceDiscount = (productPrice.listPrice - productPrice.negotiatedPrice).setScale(2);
            productPrice.negotiatedPriceDiscountPercent = (((productPrice.negotiatedPriceDiscount*100)/productPrice.listPrice)).setScale(2)+'%';
        }else{
            productPrice.negotiatedPriceDiscount = 0 ;
            productPrice.negotiatedPriceDiscountPercent = '';
        }
        List<ConnectApi.PriceAdjustmentTier> priceTiers = connectProductPrice.priceAdjustment?.priceAdjustmentTiers;
        List<SIB_ProductPricing.PriceAdjustmentTiers> priceAdjustmentTiers  = new List<SIB_ProductPricing.PriceAdjustmentTiers>();
        if(priceTiers !=null){
            for(ConnectApi.PriceAdjustmentTier priceTier : priceTiers){
                SIB_ProductPricing.PriceAdjustmentTiers priceAdjustmentTier = new SIB_ProductPricing.PriceAdjustmentTiers();
                priceAdjustmentTier.adjustmentType =  String.valueOf(priceTier.adjustmentType) ;
                priceAdjustmentTier.adjustmentValue =  Decimal.valueOf(priceTier.adjustmentValue) ;
                priceAdjustmentTier.adjustmentId =  priceTier.id ;
                priceAdjustmentTier.lowerBound =  priceTier.lowerBound != null ? Integer.valueOf(priceTier.lowerBound) : null ;
                priceAdjustmentTier.upperBound =  priceTier.upperBound != null ? Integer.valueOf(priceTier.upperBound) : null ;
                priceAdjustmentTier.tierUnitPrice =  Decimal.valueOf(priceTier.tierUnitPrice) ;
                priceAdjustmentTiers.add(priceAdjustmentTier);
            }
        }
        
        productPrice.priceAdjustmentTiers = priceAdjustmentTiers ;
        productPrice.isSuccess = true;
        productPrice.message = '';
        return productPrice;
    }
}