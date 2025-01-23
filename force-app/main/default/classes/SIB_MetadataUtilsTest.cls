@isTest
public class SIB_MetadataUtilsTest {
	@isTest
    static void handleResultTest(){
        SIB_MetadataUtils mu = new SIB_MetadataUtils();
        Metadata.DeployResult mdr = new Metadata.DeployResult();
        mdr.status=Metadata.DeployStatus.Succeeded;
        Metadata.DeployCallbackContext mdcc = new Metadata.DeployCallbackContext();
        mu.handleResult(mdr,mdcc);
    }
}