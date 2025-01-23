/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_FooterConfigurationTest {
	@isTest
    static void test(){
        SIB_FooterConfiguration footer = new SIB_FooterConfiguration();
        footer.id = 'test';
        SIB_FooterConfiguration.TopSection topS = new SIB_FooterConfiguration.TopSection();
        SIB_FooterConfiguration.SubSection subS = new SIB_FooterConfiguration.SubSection();
        SIB_FooterConfiguration.Record record = new SIB_FooterConfiguration.Record();
        record.Active = true;
        record.Label = 'test';
        record.sortOrder=1;
        record.URL='test';
        
        subS.sortOrder = 1;
        subS.isSocialMediaSubSection=true;
        subS.SubsectionName = 'test';
        subS.records = new List<SIB_FooterConfiguration.Record>{record};
        
        topS.openInNewWindow=true;
        topS.showSection=true;
        topS.sortOrder=1;
        topS.subsections = new List<SIB_FooterConfiguration.SubSection>{subS};
        
        footer.topSection = topS;
        
        SIB_FooterConfiguration.MiddleSection midS = new SIB_FooterConfiguration.MiddleSection();
        midS.openInNewWindow = true;
        midS.showSection = true;
        midS.sortOrder = 1;
        midS.records = new List<SIB_FooterConfiguration.Record>{record};
            
        footer.middleSection = midS;
        
       	SIB_FooterConfiguration.BottomSection botS = new SIB_FooterConfiguration.BottomSection();
        botS.openInNewWindow = true;
        botS.showSection = true;
        botS.sortOrder = 1;
        botS.records = new List<SIB_FooterConfiguration.Record>{record};
            
        footer.bottomSection = botS;


    }
}