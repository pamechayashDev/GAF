public without sharing class UppStatementSelector extends fflib_SObjectSelector {
    
    // Return the SObjectType for Upp_Statement__c
    public Schema.SObjectType getSObjectType() {
        return Upp_Statement__c.SObjectType;
    }
    
    // Specify the fields to query for Upp_Statement__c
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Upp_Statement__c.Id,
            Upp_Statement__c.Location__c,
            Upp_Statement__c.Statement_date__c,
            Upp_Statement__c.User__c,
            Upp_Statement__c.Document_Link__c
        };
    }
    
    // Method to query Upp_Statement__c by Location and Statement Date
    public List<Upp_Statement__c> selectStatementsByLocationAndDate(String location,Date statementDate) {
        List<String> conditionList = new  List<String>();
        Id currentUserId = UserInfo.getUserId();
        system.debug('currentUserId'+currentUserId);
        if(location!=null && statementDate!=null){
            conditionList.add(String.format('{0}={1}',new List<Object>{'Statement_Date__c', ':statementDate'}));
            conditionList.add(String.format('{0}={1}',new List<Object>{'Location__c', ':location'}));
        }
        
        conditionList.add(String.format('{0}={1}',new List<Object>{'User__c', ':currentUserId'}));
        
        
        String conditionString  = String.join(conditionList,' AND ');
        
        // Instantiate the QueryFactory for Upp_Statement__c
        fflib_QueryFactory queryFactory = newQueryFactory();
        
        // Set the condition to filter the records for Upp_Statement__c
        queryFactory.setCondition(conditionString);
        system.debug(queryFactory.toSOQL());
        
        // Execute the query and return the results
        List<Upp_Statement__c> statements = (List<Upp_Statement__c>) Database.query(queryFactory.toSOQL());
        
        return statements;
    }
    
}