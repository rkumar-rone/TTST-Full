@isTest
public class FrequentlyQuestionsTest {
    @isTest static void testGetFrequentlyQuestions() {

        // Call the method to test
        Map<String, TTS_Store_FAQ__mdt> result = TTS_Store_FAQ__mdt.getAll();
        List<TTS_Store_FAQ__mdt> resultMethod = FrequentlyQuestions.getFrequentlyQuestions();
        // Verify the results
        Assert.isNotNull(result, 'Expected a non-null result from the call');
        System.assertEquals(result.size(), resultMethod.size(), 'Expected the same number of frequently asked questions to be returned');
        System.assertNotEquals(null, result.size(), 'Expected at least frequently asked questions to be returned');
    }
}