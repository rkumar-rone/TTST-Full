public with sharing class SIB_FooterConfiguration {
        
    @AuraEnabled
    public String id{ get; set; }
    
    @AuraEnabled
    public TopSection topSection{ get; set; }
    
    @AuraEnabled
    public MiddleSection middleSection{ get; set; }
    
    @AuraEnabled
    public BottomSection bottomSection{ get; set; }
    
    public class TopSection {

        @AuraEnabled
        public Boolean showSection{ get; set; }

        @AuraEnabled
        public Integer sortOrder{ get; set; }

        @AuraEnabled
        public Boolean openInNewWindow{ get; set; }

        @AuraEnabled
        public List<Subsection> subsections{ get; set; }
    }
    
    public class MiddleSection {

        @AuraEnabled
        public Boolean showSection{ get; set; }

        @AuraEnabled
        public Integer sortOrder{ get; set; }

        @AuraEnabled
        public Boolean openInNewWindow{ get; set; }

        @AuraEnabled
        public List<Record> records{ get; set; }
    }
    
    public class BottomSection {

        @AuraEnabled
        public Boolean showSection{ get; set; }

        @AuraEnabled
        public Integer sortOrder{ get; set; }

        @AuraEnabled
        public Boolean openInNewWindow{ get; set; }

        @AuraEnabled
        public List<Record> records{ get; set; }
    }

    public class Subsection {

        @AuraEnabled
        public String SubsectionName{ get; set; }

        @AuraEnabled
        public Integer sortOrder{ get; set; }

        @AuraEnabled
        public Boolean isSocialMediaSubSection{ get; set; }

        @AuraEnabled
        public List<Record> records{ get; set; }
    }
      
    public class Record {

        @AuraEnabled
        public String Label{ get; set; }

        @AuraEnabled
        public Boolean Active{ get; set; }

        @AuraEnabled
        public String URL{ get; set; }

        @AuraEnabled
        public Integer sortOrder{ get; set; }
    }

    public static SIB_FooterConfiguration parse(String json){
		return (SIB_FooterConfiguration) System.JSON.deserialize(json, SIB_FooterConfiguration.class);
	}
}