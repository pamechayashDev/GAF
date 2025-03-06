import { LightningElement, track, api ,wire} from 'lwc';
import getNotifications from '@salesforce/apex/UPPNotificationController.getUserNotifications';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo , getPicklistValues } from 'lightning/uiObjectInfoApi';
import logo from "@salesforce/resourceUrl/logo";
import UPP_OBJECT from '@salesforce/schema/Upp_Notification__c';
import MESSAGE_TYPE from '@salesforce/schema/Upp_Notification__c.Message_Type__c'

export default class UppNotificationsTable extends LightningElement {
    @api from;
    isParent = false;
    dateFrom = null;
    dateTo = null;
    showArchived = false;
    @track notifications = [];
    displayValue ='Unread Only';
    messageTypeValue = 'None';
   @track messageTypeOptions =[];
    displayOptions = [{
        label:'Unread Only',
        value: false
    },
{
      label:'Read',
        value: true
}
  
    ]

    isModalOpen = false;
    logoImageUrl = logo;
    @track selectedNotification = null;
   
    
   
    columns= [
        { label: 'Business Area', fieldName: 'Business_Area__c', type: 'text' },
        { label: 'Message Type', fieldName: 'Message_Type__c', type: 'text' },
        { label: 'Subject', fieldName: 'Subject__c', type: 'button', typeAttributes: { label: { fieldName: 'Subject__c' }, variant: 'base' } },
        { label: 'Sent', fieldName: 'Sent__c', type: 'date' },
        {
            label: 'Message',
            fieldName: 'Message__c',
            type: 'customIconText',
            typeAttributes : {Is_Read__c: {fieldName: 'Is_Read__c'}}
          
        },
    
        
    ];;
  
    recordTypes = [];
  master;
    @wire(getObjectInfo, { objectApiName: UPP_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.recordTypes = Object.keys(data.recordTypeInfos).map(recordTypeId => ({
                id: recordTypeId,
                
                name: data.recordTypeInfos[recordTypeId].name
            }));
            this.master = this.recordTypes[0].id;

            console.log('this.recordTypes'+JSON.stringify(this.recordTypes));
        } else if (error) {
            console.error('Error fetching record types', error);
        }
    }

   
    @wire(getPicklistValues, { recordTypeId: "$master",fieldApiName: MESSAGE_TYPE })
    wiredObjectInfo1({ data, error }) {
        if (data) {
            this.messageTypeOptions = data.values.map(picklistItem=>{
                return {label: picklistItem.value,
                      value: picklistItem.value
                };
            })
        } else if (error) {
            console.error('Error fetching picklist values', error);
        }
    }



    formatDate(dateToFormat){
        let date = new Date(dateToFormat);
        let options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric',
            hour12: true
        };
        return new Intl.DateTimeFormat('en-US', options).format(date);
    }
    getNotificationData() {
        console.log('showArchived' + this.showArchived);
        getNotifications(
            {
                dateFrom: this.dateFrom,
                dateTo: this.dateTo,
                showArchived: this.showArchived,
                calledFrom: this.from,
                isRead:  this.displayValue=='Unread Only'?false:true,
                messageType:this.messageTypeValue

            }
        ).then(data => {
            if (data) {
            
                let notifications = this.from == 'parent' ? data.slice(0, 3) : data;
                this.notifications = notifications.map(notification => ({
                    ...notification,
                    UserName: notification.User__r ? notification.User__r.Name : 'N/A',
                }));
                console.log(JSON.stringify(data));
            }
        }).catch(error => {
            console.error('Error retrieving notifications', error);
        })
    }

    connectedCallback() {
        this.isParent = this.from == 'parent' ? true : false;
        this.getNotificationData();
    }



    handleChange(event) {
        const { name, value, checked } = event.target;
        if (name === 'showArchived') {
            this.showArchived = checked;

        } else if (name === 'dateFrom') {
            const today = new Date().toISOString().split('T')[0];
            value > today ? this.showToast('Error', 'From Date cannot be in the future', 'error') : this.dateFrom = value;

        } else {
            this[name] = value;
        }
    }

    //applying filters
    applyFilters() {
        console.log(this.messageTypeValue);
        getNotifications({
            dateFrom: this.dateFrom,
            dateTo: this.dateTo,
            showArchived: this.showArchived,
            calledFrom:'child',
            isRead: this.displayValue=='Unread Only'?false:true,
            messageType : this.messageTypeValue

        }).then(data => {
            if (data) {

                let notifications = this.from == 'parent' ? data.slice(0, 3) : data;
                this.notifications = notifications.map(notification => ({
                    ...notification,
                    UserName: notification.User__r ? notification.User__r.Name : 'N/A'
                }));
                this.isParent = this.from == 'parent' ? true : false;
            }
        }).catch(error => {
            console.error('Error retrieving notifications', error);
        })
    }

    //clear all filters
    clearFilters() {
        this.dateFrom = null;
        this.dateTo = null;
        this.showArchived = false;
        this.getNotificationData();
    }

    handleRowAction(event) {
        const notificationId = event.detail.row.Id;
        if (!notificationId) {
            console.error("Notification ID is missing");
            return;
        }

        this.selectedNotification = this.notifications.find(notif => notif.Id === notificationId) || null;
        if (this.selectedNotification) {
       
            this.selectedNotification.Sent__c =  this.formatDate(this.selectedNotification.Sent__c);

            //mark notification read 
            if (!this.selectedNotification.Is_Read__c) {
                const fields = {
                    Id: this.selectedNotification.Id,
                    Is_Read__c: true
                };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {

                    this.notifications = this.notifications.map(notification => {
                        if (notification.Id === notificationId) {
                            return { ...notification, Is_Read__c: true};
                        }
                        return notification;
                    });

                })
                    .catch(error => {
                        console.error('Error updating notification:', JSON.stringify(error));
                    });

            }
            this.isModalOpen = true;

        }
    }
    archiveMessage(){
        console.log('archive');
        const fields = {
            Id: this.selectedNotification.Id,
            RecordTypeId: this.recordTypes[2].id
        };
        const recordInput = { fields };
        updateRecord(recordInput).then((data)=>{
            this.showToast('Success', 'Message Archived', 'Success');
            this.notifications =  this.notifications.filter(item => item.Id !== this.selectedNotification.Id);
        })
    }


    closeModal() {
        this.isModalOpen = false;
        this.selectedNotification = null;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

}