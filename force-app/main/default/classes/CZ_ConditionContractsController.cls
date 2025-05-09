public with sharing class CZ_ConditionContractsController {
    @AuraEnabled
    public static List<Condition_Contracts__c> getConditionContracts(
        String planId,
    String year,
    Date validFrom,
    Date validTo ,
    String accountName
    ) {
        CZ_ConditionContractsSelector conditionContractsSelector = new CZ_ConditionContractsSelector();
        List<Condition_Contracts__c>  conditionContracts  = conditionContractsSelector.selectConditionContracts(planId,year,validFrom,validTo,accountName);
        
        // List<Condition_Contracts__c>  conditionContracts =  [SELECT Id,Condition_Contract_Description__c,Condition_Contract_Id__c,Valid_From_Date__c,Valid_To_Date__c,Year__c,Contract_Account__r.Name FROM Condition_Contracts__c where Condition_Contract_Status__c='Approved'];
        return conditionContracts;
    }
    
    @AuraEnabled
    public static List<Condition_Contract_Documents__c> getConditionContractDocuments(
        String  documentPlanId,
    String documentAccountName,
    String documentInvoiceNumber,
    Date   creditIssuedDateFrom,
    Date  creditIssuedDateTo,
    String conditionContractId
    ) {
        CZ_ConditionContractDocumentSelector conditionContractDocumentSelector = new CZ_ConditionContractDocumentSelector();
        List<Condition_Contract_Documents__c>  conditionContractDocuments  = conditionContractDocumentSelector.selectConditionContractDocuments(documentPlanId,documentAccountName,documentInvoiceNumber,creditIssuedDateFrom,creditIssuedDateTo,conditionContractId);
        
        return conditionContractDocuments;
    }
    
}