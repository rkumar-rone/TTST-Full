/**
 * @description       : Utility for encryption utility methods
 * @author            : junaidmohammed
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : vramachandran@rafter.one
**/
public with sharing class SIB_EncryptionUtil {

    private static final String CLASS_NAME = 'SIB_EncryptionUtil';
    private static final String MODULE_NAME = 'Encryption Module';
    /**    
     * This method is used to encrypt data.
     * @param textToEncrypt String    
     * @return Blob     
     **/
    public static String encryptWithManagedIV( String textToEncrypt) {

        String strEncryptedText = null;
        Map<String, Object> storeConfigurationMap = SIB_Util.fetchConfigMapByModule(SIB_Constants.MODULE_ENCRYPTION);
        if(null != storeConfigurationMap && !storeConfigurationMap.isEmpty() 
        && storeConfigurationMap.containsKey(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY) && null != (String) storeConfigurationMap.get(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY)) {

            String strSecretKey = (String) storeConfigurationMap.get(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY);
            Blob blobSecretKey = EncodingUtil.base64Decode(strSecretKey);
            Blob blobClearData = Blob.valueOf(textToEncrypt);
            Blob blobEncryptedData = Crypto.encryptWithManagedIV(SIB_Constants.ENCRYPTION_ALGORITHM_AES256,blobSecretKey,blobClearData);
            strEncryptedText = EncodingUtil.base64Encode(blobEncryptedData);
        }
        
    return strEncryptedText;
    }

    /**     
   * This method is used to decrypt data.    
   *  @param encryptedToken String     
   *  @param encryptedCode String     
   *  @return String     
   **/ 
    public static String decryptWithManagedIV(String encryptedToken) {
        
        Blob textEncrypted = EncodingUtil.base64Decode(encryptedToken);
        String decryptedString = null;

        Map<String, Object> storeConfigurationMap = SIB_Util.fetchConfigMapByModule(SIB_Constants.MODULE_ENCRYPTION);
        if(null != storeConfigurationMap && !storeConfigurationMap.isEmpty() 
        && storeConfigurationMap.containsKey(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY) && null != (String) storeConfigurationMap.get(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY)) {

            String strSecretKey = (String) storeConfigurationMap.get(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY);
            Blob textEncryptedKey = EncodingUtil.base64Decode(strSecretKey);
            Blob decrypted = Crypto.decryptWithManagedIV(SIB_Constants.ENCRYPTION_ALGORITHM_AES256,textEncryptedKey,textEncrypted);
            decryptedString = decrypted.toString();
        }

        return decryptedString;
    }   
}