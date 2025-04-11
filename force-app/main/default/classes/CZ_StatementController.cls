public with sharing class CZ_StatementController {
    @AuraEnabled
    public static Map<String,Object> fetchStatementWithDocuments(Map<String,Object> statementFilter , Map<String,Object> documentFilter ){
        
        Map<String,Object> statementResult = new Map<String,Object>();
        
        system.debug(Json.serializePretty(statementFilter));
        List<UPP_Statement__c> uppStatements ;
        CZ_UppStatementSelector statementSelector = new CZ_UppStatementSelector();
        CZ_UppDocumentSelector documentSelector = new CZ_UppDocumentSelector();
        
        
        if(statementFilter.containsKey('location') && statementFilter.containsKey('statementDate')){
            String location = String.valueOf(statementFilter.get('location'));
            Date statementDate = Date.valueOf((String)statementFilter.get('statementDate'));
            
            
            uppStatements = statementSelector.selectStatementsByLocationAndDate(location,statementDate);
            
            if(uppStatements.size()!=0){
                
                
                
                
                List<UPP_Document__c> relatedDocuments = documentSelector.selectDocumentsByStatementId(uppStatements[0].Id);
                
                statementResult.put('uppStatements',uppStatements);
                statementResult.put('relatedDocuments',relatedDocuments);
            }
            
        }
        else {
            system.debug('non filter');
            if(statementFilter.containsKey('Id')){
                
                Id statementId= (Id)statementFilter.get('Id');
                system.debug('documentFilter'+documentFilter);
                List<UPP_Document__c> relatedDocuments = documentSelector.selectDocumentsByFields(documentFilter,statementId);
                system.debug('relatedDocuments'+relatedDocuments);
                statementResult.put('relatedDocuments',relatedDocuments);
            }
            uppStatements = statementSelector.selectStatementsByLocationAndDate(null,null);
            statementResult.put('uppStatements',uppStatements);
            system.debug('statementResult '+Json.serializePretty(statementResult));
        }
        
        return statementResult;
        
    }
    
}