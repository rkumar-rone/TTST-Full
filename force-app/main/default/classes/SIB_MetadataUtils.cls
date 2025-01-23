public with sharing class SIB_MetadataUtils implements Metadata.DeployCallback{
    /* Below method recieves the 2 parameters 
       1 - Metadata.DeployResult => Object of MetadataContainer class where this method has been implemented.
       2 - Metadata.DeployCallbackContext => Object of the class where this method has been implemented
   */
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('SIB_MetadataUtils success : '+ result);
        } else {
            System.debug('SIB_MetadataUtils fail : '+ result);
        }
    }

    @future 
    public static void updateMultipleMetadataRecords(List<String> concatenatedMetadataList){
        
        Map<String,String> responseMap = new Map<String,String>();

        try {

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

            for(String metadataString:concatenatedMetadataList){

                List<String> metadataList = metadataString.split('-');

                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();

                customMetadata.fullName = metadataList[0] + '.' + metadataList[1];

                customMetadata.label = metadataList[1];

                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();

                customField.field = metadataList[2];
                
                customField.value = Boolean.valueOf(metadataList[3]);

                customMetadata.values.add(customField);

                mdContainer.addMetadata(customMetadata);

            }
            
            SIB_MetadataUtils callback = new SIB_MetadataUtils();

            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

            System.debug('updateMultipleMetadataRecords: jobId:'+jobId);

            if(jobId!=null){
                responseMap.put('jobId',jobId);
            }else{
                responseMap.put('jobId',null);
            }

        } catch (Exception e) {
            System.debug('Exception caught:'+e);
        }
    }
}