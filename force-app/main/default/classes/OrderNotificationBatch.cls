global class OrderNotificationBatch implements Database.Batchable<SObject> {

    // Start method: query Orders with additional fields needed for the JSON payload.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Ship_via__c, OrderNumber, PoNumber, CompanyAuthorizedById
            FROM Order
            WHERE Status = 'Open' 
              AND Ship_Date_Scheduled__c < :Date.today()
        ]);
    }
    
    // Execute method: process each batch of orders.
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        // Query the RecordType for UPP_Notification__c where DeveloperName is 'Active'
        RecordType activeRecordType = [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'UPP_Notification__c' 
              AND DeveloperName = 'Active' 
            LIMIT 1
        ];
        
        List<UPP_Notification__c> notifications = new List<UPP_Notification__c>();
        
        // Process each Order record in the batch.
        for (Order ord : scope) {
            UPP_Notification__c notif = new UPP_Notification__c();
            notif.RecordTypeId = activeRecordType.Id;
            notif.theme__c='Success';
            notif.User__c=ord.CompanyAuthorizedById;
            
            // Determine the notification type based on the shipping method.
            if (ord.Ship_via__c == 'Customer Pickup') {
                notif.Message_Type__c = 'Missed Pickup Appointment';
            } else {
                notif.Message_Type__c = 'Past Due Shipment';
            }
            
            // Build JSON payload with Order Number, PO Number, and Shipping Number.
            Map<String, Object> payload = new Map<String, Object>{
                'orderNumber'    => ord.OrderNumber,
                'poNumber'       => ord.PoNumber,
                'shippingNumber' => ord.OrderNumber
            };
            notif.Merge_Data__c = JSON.serialize(payload);
            
            notifications.add(notif);
        }
        
        // Insert the notifications if there are any to add.
        if (!notifications.isEmpty()) {
            insert notifications;
        }
    }
    
    // Optional finish method for post-processing tasks.
    global void finish(Database.BatchableContext BC) {
        // Post-processing logic can be added here.
    }
}