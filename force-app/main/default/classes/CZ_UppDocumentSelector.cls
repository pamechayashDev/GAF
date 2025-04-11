public inherited sharing class CZ_UppDocumentSelector extends fflib_SObjectSelector {
    
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
            UPP_Document__c.Currency__c,
            UPP_Document__c.Upp_Statement__c,
            UPP_Document__c.Original_Amount__c,
            UPP_Document__c.Business_Type__c,
            UPP_Document__c.Payment_Status__c,
            UPP_Document__c.Ship_to_State__c,
            UPP_Document__c.Sold_to_City__c,
            UPP_Document__c.Sold_to_State__c
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
    public List<UPP_Document__c> selectDocumentsByFields(Map<String,Object> documentFilters,String statementId) {
        
        List<String> conditionList =new List<String>();
        
        Date invoiceDateFrom;
        Date invoiceDateTo;
        Date orderDateTo;
        Date orderDateFrom;
        Date shipDateFrom;
        Date shipDateTo;
        Date dueDateTo;
        Date dueDateFrom;
        
        system.debug('statementId---'+statementId);
        conditionList.add('Upp_Statement__c =:statementId');
        if(documentFilters.containsKey('EntryType') && documentFilters.get('EntryType')!=''){
            conditionList.add('Entry_Type__c ='+'\''+String.valueOf(documentFilters.get('EntryType'))+'\'');
        }
        if(documentFilters.containsKey('BusinessType')){
            conditionList.add('Business_Type__c ='+'\''+String.valueOf(documentFilters.get('BusinessType'))+'\'');
        }
        if(documentFilters.containsKey('InvoiceDateFrom') &&  documentFilters.get('InvoiceDateFrom')!=null){
            invoiceDateFrom=Date.valueOf((String)documentFilters.get('InvoiceDateFrom'));
            conditionList.add('Invoice_Date__c >=:invoiceDateFrom');
        }
        if(documentFilters.containsKey('InvoiceDateTo') &&  documentFilters.get('InvoiceDateTo')!=null){
            invoiceDateTo=Date.valueOf((String)documentFilters.get('InvoiceDateTo'));
            conditionList.add('Invoice_Date__c <=:invoiceDateTo');
        }
        if(documentFilters.containsKey('OrderDateTo') &&  documentFilters.get('OrderDateTo')!=null){
            orderDateTo=Date.valueOf((String)documentFilters.get('OrderDateTo'));
            conditionList.add('Order_Date__c <=:orderDateTo');
        }
        
        if(documentFilters.containsKey('OrderDateFrom')  &&  documentFilters.get('OrderDateFrom')!=null){
            orderDateFrom=Date.valueOf((String)documentFilters.get('OrderDateFrom'));
            conditionList.add('Order_Date__c >=:orderDateFrom');
        }
        
        if(documentFilters.containsKey('ShipDateFrom')  &&  documentFilters.get('ShipDateFrom')!=null){
            shipDateFrom=Date.valueOf((String)documentFilters.get('ShipDateFrom'));
            conditionList.add('Ship_Date__c >=:shipDateFrom');
        }
        if(documentFilters.containsKey('ShipDateTo')  &&  documentFilters.get('ShipDateTo')!=null){
            shipDateTo=Date.valueOf((String)documentFilters.get('ShipDateTo'));
            conditionList.add('Ship_Date__c <=:shipDateTo');
        }
        if(documentFilters.containsKey('DueDateTo') &&  documentFilters.get('DueDateTo')!=null){
            dueDateTo=Date.valueOf((String)documentFilters.get('DueDateTo'));
            conditionList.add('Due_Date__c <=:dueDateTo');
        }
        
        if(documentFilters.containsKey('DueDateFrom') &&  documentFilters.get('DueDateFrom')!=null){
            dueDateFrom=Date.valueOf((String)documentFilters.get('DueDateFrom'));
            conditionList.add('Due_Date__c >=:dueDateFrom');
        }
        if(documentFilters.containsKey('PaymentStatus')){
            conditionList.add('Payment_Status__c ='+'\''+String.valueOf(documentFilters.get('PaymentStatus'))+'\'');
        }
        if(documentFilters.containsKey('ShipToState')){
            conditionList.add('Ship_to_State__c ='+'\''+String.valueOf(documentFilters.get('ShipToState'))+'\'');
        }
        if(documentFilters.containsKey('ShipToCity')){
            conditionList.add('Ship_to_City__c ='+'\''+String.valueOf(documentFilters.get('ShipToCity'))+'\'');
        }
        if(documentFilters.containsKey('SoldToCity')){
            conditionList.add('Sold_to_City__c ='+'\''+String.valueOf(documentFilters.get('SoldToCity'))+'\'');
        }
        if(documentFilters.containsKey('SoldToState')){
            conditionList.add('Sold_to_State__c ='+'\''+String.valueOf(documentFilters.get('SoldToState'))+'\'');
        }
        if(documentFilters.containsKey('ShipmentId') &&  documentFilters.get('ShipmentId')!=''){
            conditionList.add('Shipment_ID__c ='+'\''+String.valueOf(documentFilters.get('ShipmentId'))+'\'');
        }
        if(documentFilters.containsKey('EndingAmount') &&  documentFilters.get('EndingAmount')!=''){
            conditionList.add('Amount_Due__c ='+'\''+String.valueOf(documentFilters.get('EndingAmount'))+'\'');
        }
        if(documentFilters.containsKey('FirstAmount') &&  documentFilters.get('FirstAmount')!=''){
            conditionList.add('Original_Amount__c ='+String.valueOf(documentFilters.get('FirstAmount')));
        }
        
        
        String conditionString = String.join(conditionList,' AND ');
        
        // Instantiate the QueryFactory for Upp_Statement__c
        fflib_QueryFactory queryFactory = newQueryFactory();
        
        system.debug('conditionString'+conditionString);
        
        queryFactory.setCondition(conditionString);
        system.debug('queryFactory.toSOQL()'+queryFactory.toSOQL());
        
        system.debug(Database.query(queryFactory.toSOQL()));
        // Execute the query and return the results
        List<UPP_Document__c> documents = (List<UPP_Document__c>) Database.query(queryFactory.toSOQL());
        
        return documents;
    }
    
}