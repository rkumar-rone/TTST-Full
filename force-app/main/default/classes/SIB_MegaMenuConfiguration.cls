public with sharing  class SIB_MegaMenuConfiguration {

    @AuraEnabled
    public List<Category> Category{ get; set; }
    
    public class Record {
        @AuraEnabled
        public String URL{ get; set; }
        @AuraEnabled
        public String Label{ get; set; }
    }

    public class SubCategory {
        @AuraEnabled
        public String SubCategoryName{ get; set; }
        @AuraEnabled
        public List<Record> records{ get; set; }
    }

    public class Category {
        @AuraEnabled
        public String type{ get; set; }
        @AuraEnabled
        public String value{ get; set; }
        @AuraEnabled
        public String URL{ get; set; }
        @AuraEnabled
        public List<SubCategory> subCategories{ get; set; }
    }

    public static SIB_MegaMenuConfiguration parse(String json){
		return (SIB_MegaMenuConfiguration) System.JSON.deserialize(json, SIB_MegaMenuConfiguration.class);
	}

}