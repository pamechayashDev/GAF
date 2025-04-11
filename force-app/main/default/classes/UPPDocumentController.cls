public  class UPPDocumentController {
    public List<UPP_Document__c> uppDocs { get; set; }
    
    public UPPDocumentController() {
        String jsonParam = ApexPages.currentPage().getParameters().get('data');
        if (String.isNotBlank(jsonParam)) {
            String jsonStr = EncodingUtil.urlDecode(EncodingUtil.base64Decode(jsonParam).toString(), 'UTF-8');
            uppDocs = (List<UPP_Document__c>) JSON.deserialize(jsonStr, List<UPP_Document__c>.class);
        } else {
            uppDocs = new List<UPP_Document__c>();
        }
    }
}