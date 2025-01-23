public with sharing class SIB_ServiceFactory {
    private static SIB_HTTPService service;
    private SIB_ServiceFactory() {
    }
    public static SIB_HTTPService getService(String className) {
      if (service == null) {
        if (String.isNotEmpty(className)) {
          Type t = Type.forName(className);
          service = (SIB_HTTPService) t.newInstance();
        } else {
          service = new SIB_HTTPService();
        }
      }
      return service;
    }
  }