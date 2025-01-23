public with sharing class Saltbox_B2BCourseRegisterVFController {
  public String ttsEventId { get; set; }
  public Saltbox_B2BCourseRegisterVFController() {
  }

  public Campaign getTTSEvent() {
    if (String.isBlank(ttsEventId)) {
      return new Campaign();
    }
    return [SELECT Id, Class_Code__C FROM Campaign WHERE Id = :ttsEventId];
  }

  public String getDomain() {
    String UrlPathPrefix = '';

    List<Network> list1 = [
      SELECT UrlPathPrefix
      FROM Network
      WHERE EmailSenderName = 'TTS B2B Store'
    ];

    if (list1.size() > 0) {
      if (list1.get(0).UrlPathPrefix != null) {
        UrlPathPrefix = list1.get(0).UrlPathPrefix + '/';
      }
    }

    List<Domain> domain = [
      SELECT Domain
      FROM Domain
      WHERE HttpsOption = 'CommunityAlt'
      LIMIT 1
    ];

    String myDomain = '';
    if (domain.size() > 0) {
      myDomain = domain.get(0).Domain;
    }

    return 'https://' + myDomain + '/' + UrlPathPrefix + 's/';
  }

  public String getSiteURL() {
    String url = '';
    url =
      getDomain() +
      'course-registration?CourseCode=' +
      getTTSEvent().Class_Code__C +
      '&courseId=' +
      getTTSEvent().Id;
    return url;
  }
}