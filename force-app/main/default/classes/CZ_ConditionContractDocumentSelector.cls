public inherited sharing class CZ_ConditionContractDocumentSelector extends fflib_SObjectSelector {
    
    
    public  List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Condition_Contract_Documents__c.Id,
            Condition_Contract_Documents__c.Settlement_Document_Number__c,
            Condition_Contract_Documents__c.Condition_Contract_Id__c,
            
            Condition_Contract_Documents__c.Credit_Amount__c,
            Condition_Contract_Documents__c.Document_Date__c,
            Condition_Contract_Documents__c.Contract_Account__c,
            Condition_Contract_Documents__c.Document_URL__c,
            Condition_Contract_Documents__c.Download_URL__c
        };
    }
    public  Schema.SObjectType getSObjectType() {
        return Condition_Contract_Documents__c.SObjectType;
    }
    
    
    
    // Get Notifications using Filters
    public List<Condition_Contract_Documents__c> selectConditionContractDocuments(
        String  documentPlanId,
    String documentAccountName,
    String documentInvoiceNumber,
    Date   creditIssuedDateFrom,
    Date  creditIssuedDateTo,
    String conditionContractId
        
    ) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(
        new Set<String>{
            'Contract_Account__r.Name',
            'Condition_Contract_Id__r.Condition_Contract_Id__c'
        });
        List<String> conditionsList = new List<String>();
        String conditionString='Condition_Contract_Id__c = :conditionContractId';
        
        if (documentPlanId != 'None') {
            conditionString+=' AND Condition_Contract_Id__r.Condition_Contract_Id__c = :documentPlanId';
        }
        if (documentInvoiceNumber != 'None') {
            conditionString+=' AND Settlement_Document_Number__c = :documentInvoiceNumber';
        }
        if (creditIssuedDateFrom != null) {
            conditionString+=' AND 	Document_Date__c >= :creditIssuedDateFrom';
        }
        if (creditIssuedDateTo != null) {
            conditionString+=' AND 	Document_Date__c <= :creditIssuedDateTo';
        }
        if(documentAccountName != 'None'){
            conditionString+=' AND Contract_Account__r.Name = :documentAccountName';
        }
        
        queryFactory.setCondition(conditionString);
        system.debug('documentAccountName'+documentInvoiceNumber);
        system.debug('queryFactory.toSOQL()'+queryFactory.toSOQL());
        return (List<Condition_Contract_Documents__c>) Database.query(queryFactory.toSOQL());
    }
    
}