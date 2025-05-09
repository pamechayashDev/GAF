trigger UppNotificationTrigger on UPP_Notification__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        CZ_UPP_Notification_Helper.afterUppNotificationInsert(Trigger.new);
    }

}