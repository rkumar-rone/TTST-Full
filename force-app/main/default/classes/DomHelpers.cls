public with sharing class DomHelpers {
	public static String getFieldString(Dom.XMLNode parent, String child, String schema) {
		String returnS = '';
		try {
			Dom.XMLNode childDom = parent.getChildElement(child, schema);
			returnS = childDom.getText();
		}
		catch (Exception ex) {
			
		}
		return returnS;
	}
	
	public static DateTime getFieldDateTime(Dom.XMLNode parent, String child, String schema) {
		DateTime returnD;
		try {
			Dom.XMLNode childDom = parent.getChildElement(child, schema);
			String returnS = childDom.getText();
			returnD = DateTime.newInstanceGmt(Integer.valueOf(returnS.split('-')[0]), Integer.valueOf(returnS.split('-')[1]), Integer.valueOf(returnS.split('-')[2].split('T')[0]), Integer.valueOf(returnS.split('T')[1].split(':')[0]), Integer.valueOf(returnS.split('T')[1].split(':')[1]), Integer.valueOf(returnS.split('T')[1].split(':')[2].substring(0, 2)));
		}
		catch (Exception ex) {
			
		}
		return returnD;
	}
	
	public static Decimal getFieldDecimal(Dom.XMLNode parent, String child, String schema) {
		Decimal returnD;
		try {
			Dom.XMLNode childDom = parent.getChildElement(child, schema);
			String returnS = childDom.getText();
			returnD = Decimal.valueOf(returnS);
		}
		catch (Exception ex) {
			
		}
		return returnD;
	}
}