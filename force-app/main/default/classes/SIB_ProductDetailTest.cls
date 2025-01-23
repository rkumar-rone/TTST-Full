/**
 * @description       : Test class for SIB_ProductDetail
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_ProductDetailTest {
	@isTest
    static void test(){
        SIB_ProductDetail pd = new SIB_ProductDetail();
        pd.productId = '000000000000000AAA';
        pd.Name = 'test';
        pd.isSubscription = true;
        pd.productSku = 'test';
        pd.productCode = 'test';
        pd.variationParentId = '000000000000000AAA';
        pd.productClass = 'test';
        pd.productType = 'test';
        pd.productGroup = 'test';
        pd.isCourse = true;
        pd.isMostPopular = true;
        pd.inventory = 1;
        pd.description = 'test';
        pd.longDescription = 'test';
        pd.campaignId = '000000000000000AAA';
        pd.productCount = 1;
        pd.totalDays = 1;
        pd.sessionFlag = true;
        SIB_ProductDetail.SIB_ProductMedia pm = new SIB_ProductDetail.SIB_ProductMedia('000000000000000AAA','test','test','test','test');
        pd.defaultImage = pm;
        List<SIB_ProductDetail.SIB_ProductMedia> pms = new List<SIB_ProductDetail.SIB_ProductMedia>{pm};
        pd.images = pms;
        pd.attachments = pms;
        pd.videos = pms;
        Map<String,String> pMap = new Map<String,String>();
        pd.fieldsMap = pMap;
        SIB_ProductPricing pprice = new SIB_ProductPricing();
        pd.price = pprice;
        SIB_ProductDetail.QuantityRule qrule = new SIB_ProductDetail.QuantityRule(1,1,1);
        pd.quantityRule = qrule;
        pd.inventory = 1;
        List<SObject> objects = new List<SObject>();
        pd.eventSessions = objects; 
		SIB_ProductDetail.SIB_CategoryPath cp = new SIB_ProductDetail.SIB_CategoryPath('000000000000000AAA','test','test','test');
        pd.categoryPath = new List<SIB_ProductDetail.SIB_CategoryPath>{cp};
        SIB_ProductDetail.SIB_AttributesSummary attributeSummary = new SIB_ProductDetail.SIB_AttributesSummary('test','test',1,'test');
        SIB_ProductDetail.SIB_VariationAttributeSetSummary attributeSetSummary = new
            SIB_ProductDetail.SIB_VariationAttributeSetSummary('test',new List<SIB_ProductDetail.SIB_AttributesSummary>{attributeSummary},'test');
        pd.variationAttributeSet = attributeSetSummary;
        SIB_ProductDetail.SIB_ProductAttributeSet attributeSet = new SIB_ProductDetail.SIB_ProductAttributeSet('test',new Map<String,String>(),'000000000000000AAA');
        pd.productVariationAttributeSet = attributeSet;
        
        SIB_ProductDetail.SIB_ProductAttributesToProductEntry attributesToProductEntry =
            new SIB_ProductDetail.SIB_ProductAttributesToProductEntry('test','test', new List<SIB_ProductDetail.SIB_AttributesSummary>{attributeSummary},'test');
        
        SIB_ProductDetail.SIB_ProductAttributeInfo attributeInfo = new SIB_ProductDetail.SIB_ProductAttributeInfo(new List<String>(),'test',new List<String>(),'test','test','test',1);
        SIB_ProductDetail.SIB_ProductVariationInfo variationInfo = new SIB_ProductDetail.SIB_ProductVariationInfo(new List<SIB_ProductDetail.SIB_ProductAttributesToProductEntry>{attributesToProductEntry},new Map<String,SIB_ProductDetail.SIB_ProductAttributeInfo>{'test'=>attributeInfo});
        pd.variationInfo = variationInfo;
        SIB_ProductDetail.SIB_ProductAttributeSetInfo attributeSetInfo = new SIB_ProductDetail.SIB_ProductAttributeSetInfo(new Map<String,SIB_ProductDetail.SIB_ProductAttributeInfo>{'test'=>attributeInfo},'test','test','test','test','test');
        
    }
}