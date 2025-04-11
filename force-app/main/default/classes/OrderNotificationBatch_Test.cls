@isTest(SeeAllData=true)
private class OrderNotificationBatch_Test {
    
    @isTest
    static void testOrderNotificationBatch() {
        // Create an Account (Orders typically require an Account)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create valid Orders that meet the criteria:
        // Status = 'Open' and Ship_Date_Scheduled__c < today.
        Order orderPickup = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Open',
            Ship_Date_Scheduled__c = Date.today().addDays(-1),
            Ship_via__c = 'Customer Pickup',
            PoNumber = 'PO123',
            CompanyAuthorizedById = UserInfo.getUserId()
        );
        Order orderOther = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Open',
            Ship_Date_Scheduled__c = Date.today().addDays(-2),
            Ship_via__c = 'FedEx',
            PoNumber = 'PO456',
            CompanyAuthorizedById = UserInfo.getUserId()
        );
        
        // Insert the valid Orders.
        insert new List<Order>{ orderPickup, orderOther };
        
        // Create an invalid Order that does not meet the criteria
        // (Ship_Date_Scheduled__c is not less than today).
        Order orderInvalid = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Open',
            Ship_Date_Scheduled__c = Date.today(), // Not less than today
            Ship_via__c = 'Customer Pickup',
            PoNumber = 'PO789',
            CompanyAuthorizedById = UserInfo.getUserId()
        );
        insert orderInvalid;
        
        // Retrieve the inserted Orders to obtain their OrderNumber values.
        orderPickup = [SELECT Id, OrderNumber FROM Order WHERE Id = :orderPickup.Id];
        orderOther  = [SELECT Id, OrderNumber FROM Order WHERE Id = :orderOther.Id];
        
        // Store the valid OrderNumber values for later assertions.
        Set<String> validOrderNumbers = new Set<String>{
            orderPickup.OrderNumber,
            orderOther.OrderNumber
        };
        
        Test.startTest();
            // Execute the batch.
            OrderNotificationBatch batchInstance = new OrderNotificationBatch();
            Database.executeBatch(batchInstance);
        Test.stopTest();
        
        // Query the notifications created by the batch.
        List<UPP_Notification__c> notifications = [
            SELECT Id, Message_Type__c, Merge_Data__c, User__c, theme__c 
            FROM UPP_Notification__c
        ];
        
        // Only the two valid orders should have generated notifications.
        System.assertEquals(2, notifications.size(), 'Two notifications should have been created.');
        
        // Verify each notification's field values and JSON payload.
        for (UPP_Notification__c notif : notifications) {
            // Verify the theme and user fields.
            System.assertEquals('Success', notif.theme__c, 'The theme should be Success.');
            System.assertEquals(UserInfo.getUserId(), notif.User__c, 'User__c should match the current user.');
            
            // Deserialize the JSON payload stored in Merge_Data__c.
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(notif.Merge_Data__c);
            
            // Check that the payload contains the expected keys.
            System.assert(payload.containsKey('orderNumber'), 'Payload should contain orderNumber.');
            System.assert(payload.containsKey('poNumber'), 'Payload should contain poNumber.');
            System.assert(payload.containsKey('shippingNumber'), 'Payload should contain shippingNumber.');
            
            // Verify that the orderNumber in the payload is one of the valid ones.
            String orderNumberInPayload = (String) payload.get('orderNumber');
            System.assert(validOrderNumbers.contains(orderNumberInPayload),
                'The orderNumber in the payload should match one of the valid orders.');
            
            // Verify the Message_Type__c is set based on the Order's shipping method.
            if (orderNumberInPayload == orderPickup.OrderNumber) {
                System.assertEquals('Missed Pickup Appointment', notif.Message_Type__c,
                    'For a Customer Pickup order, the message type should be Missed Pickup Appointment.');
            } else if (orderNumberInPayload == orderOther.OrderNumber) {
                System.assertEquals('Past Due Shipment', notif.Message_Type__c,
                    'For a non-Customer Pickup order, the message type should be Past Due Shipment.');
            }
        }
    }
}