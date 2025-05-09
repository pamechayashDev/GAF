public inherited sharing class CZ_ConditionContractsSelector extends fflib_SObjectSelector {
    // Constructor for fflib
    
    
    public  List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Condition_Contracts__c.Id,
            Condition_Contracts__c.Condition_Contract_Description__c,
            Condition_Contracts__c.Condition_Contract_Id__c,
            Condition_Contracts__c.Valid_From_Date__c,
            Condition_Contracts__c.Valid_To_Date__c,
            Condition_Contracts__c.Year__c,
            Condition_Contracts__c.Contract_Account__c,
            Condition_Contracts__c.Condition_Contract_Status__c
        };
    }
    public  Schema.SObjectType getSObjectType() {
        return Condition_Contracts__c.SObjectType;
    }
    
    
    
    // Get Notifications using Filters
    public List<Condition_Contracts__c> selectConditionContracts(
        String planId,
    String year,
    Date validFrom,
    Date validTo ,
    String accountName
    ) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(
        new Set<String>{
            'Contract_Account__r.Name'
        });
        String conditionString='Condition_Contract_Status__c = \'Approved\'';
        if (planId != 'None') {
            conditionString+=' AND 	Condition_Contract_Id__c = :planId';
        }
        if (year != 'None') {
            conditionString+=' AND 	Year__c = :year';
        }
        if (validFrom != null) {
            conditionString+=' AND 	Valid_From_Date__c = :validFrom';
        }
        if (validTo != null) {
            conditionString+=' AND 	Valid_To_Date__c = :validTo';
        }
        if(accountName != 'None'){
            conditionString+=' AND 	Contract_Account__r.Name = :accountName';
            
        }
        
        queryFactory.setCondition(conditionString);
        return (List<Condition_Contracts__c>) Database.query(queryFactory.toSOQL());
    }
    
}