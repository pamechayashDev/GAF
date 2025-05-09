public with sharing class StatementController {
    @AuraEnabled
    public static Map<String,Object> fetchStatementWithDocuments(Map<String,Object> statementFilter){
        
        Map<String,Object> statementResult = new Map<String,Object>();
        system.debug(Json.serializePretty(statementFilter));
        List<UPP_Statement__c> uppStatements ;
        UppStatementSelector statementSelector = new UppStatementSelector();
        if(statementFilter.containsKey('location') && statementFilter.containsKey('statementDate')){
            String location = String.valueOf(statementFilter.get('location'));
            Date statementDate = Date.valueOf((String)statementFilter.get('statementDate'));
            
            
            uppStatements = statementSelector.selectStatementsByLocationAndDate(location,statementDate);
            
            if(uppStatements.size()!=0){
                
                
                UppDocumentSelector documentSelector = new UppDocumentSelector();
                
                List<UPP_Document__c> relatedDocuments = documentSelector.selectDocumentsByStatementId(uppStatements[0].Id);
                
                statementResult.put('uppStatements',uppStatements);
                statementResult.put('relatedDocuments',relatedDocuments);
            }
        }
        else {
            system.debug('non filter');
            uppStatements = statementSelector.selectStatementsByLocationAndDate(null,null);
            statementResult.put('uppStatements',uppStatements);
            
        }
        
        return statementResult;
        
    }
    
}