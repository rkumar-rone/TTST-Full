/**
 * @description       : Test class for  SIB_EncryptionUtil
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_EncryptionUtilTest {
    @isTest
    static void testEncryptWithManagedIVValidKey() {
        String textToEncrypt = 'Test data to encrypt';
        String encryptedText = SIB_EncryptionUtil.encryptWithManagedIV(textToEncrypt);
        System.assertNotEquals(encryptedText, null, 'Encrypted text should not be null for a valid encryption key.');
        try {
            Blob decodedBlob = EncodingUtil.base64Decode(encryptedText);
            System.assert(decodedBlob != null, 'Encrypted text should be valid Base64.');
        } catch (Exception e) {
            System.assert(false, 'Encrypted text is not valid Base64.');
        }
    }

    @isTest
    static void testDecryptWithManagedIVValidKeyAndEncryptedText() {
        String originalText = 'This is a secret message';

        Map<String, Object> storeConfigurationMap = SIB_Util.fetchConfigMapByModule(SIB_Constants.MODULE_ENCRYPTION);
        String encryptionKey = (String) storeConfigurationMap.get(SIB_Constants.CONFIG_NAME_WPSTRIVACITY_ENCKEY);
        Blob secretKeyBlob = EncodingUtil.base64Decode(encryptionKey);
        Blob originalTextBlob = Blob.valueOf(originalText);
        Blob encryptedBlob = Crypto.encryptWithManagedIV(SIB_Constants.ENCRYPTION_ALGORITHM_AES256, secretKeyBlob, originalTextBlob);
        String encryptedText = EncodingUtil.base64Encode(encryptedBlob);
        String decryptedText = SIB_EncryptionUtil.decryptWithManagedIV(encryptedText);
        System.assertEquals(decryptedText, originalText, 'Decrypted text should match the original text.');
    }

    
}