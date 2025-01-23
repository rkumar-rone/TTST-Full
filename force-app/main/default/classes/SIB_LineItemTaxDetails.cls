public without sharing class SIB_LineItemTaxDetails {
    public SIB_LineItemTaxDetails() {

    }

    public  Decimal rate  { get; set; }
    public  Decimal tax  { get; set; }
    public String taxName { get; set; }
    public String taxType { get; set; }
    
}