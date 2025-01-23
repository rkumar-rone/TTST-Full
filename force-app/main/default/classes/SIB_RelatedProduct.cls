public with sharing class SIB_RelatedProduct {

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public Boolean active { get; set; }

    @AuraEnabled
    public String productId { get; set; }

    @AuraEnabled
    public Decimal order { get; set; }

    @AuraEnabled
    public String type { get; set; }

    @AuraEnabled
    public List<SIB_ProductDetail> recommendedProducts { get; set; } 


}