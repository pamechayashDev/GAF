public inherited sharing class UppDocumentSelector extends fflib_SObjectSelector {
    
    // Return the SObjectType for UPP_Document__c
    public Schema.SObjectType getSObjectType() {
        return UPP_Document__c.SObjectType;
    }
    
    // Specify the fields to query for UPP_Document__c
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            UPP_Document__c.Product2__c,
            UPP_Document__c.Invoice_Date__c,
            UPP_Document__c.Due_Date__c,
            UPP_Document__c.Location__c,
            UPP_Document__c.Ship_to_City__c,
            UPP_Document__c.Entry_Type__c,
            UPP_Document__c.PO__c,
            UPP_Document__c.Amount_Due__c,
            UPP_Document__c.Currency__c
        };
    }
    
    
    public List<UPP_Document__c> selectDocumentsByStatementId(Id statementId) {
        
        
        // Instantiate the QueryFactory for Upp_Statement__c
        fflib_QueryFactory queryFactory = newQueryFactory();
        
        
        queryFactory.setCondition('Upp_Statement__c = :statementId');
        
        
        // Execute the query and return the results
        List<UPP_Document__c> documents = (List<UPP_Document__c>) Database.query(queryFactory.toSOQL());
        
        return documents;
    }
    
}