import { LightningElement, track, api } from 'lwc';
import getNotifications from '@salesforce/apex/UPPNotificationController.getUserNotifications';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

export default class UppNotificationsTable extends LightningElement {
    @api from;
    isParent = false;
    dateFrom = null;
    dateTo = null;
    showArchived = false;
    @track notifications = [];
    isModalOpen = false;
    @track selectedNotification = null;
    columns = [
        { label: 'Business Area', fieldName: 'Business_Area__c', type: 'text' },
        { label: 'Category', fieldName: 'Category__c', type: 'text' },
        { label: 'Subject', fieldName: 'Subject__c', type: 'button', typeAttributes: { label: { fieldName: 'Subject__c' }, variant: 'base' } },
        { label: 'Sent', fieldName: 'Sent__c', type: 'date' },
        { label: 'Message', fieldName: 'Message__c', type: 'text', cellAttributes: { style: { fieldName: 'fontStyle' } } }
    ];

    getNotificationData() {
        console.log('showArchived' + this.showArchived);
        getNotifications(
            {
                dateFrom: this.dateFrom,
                dateTo: this.dateTo,
                showArchived: this.showArchived
            }
        ).then(data => {
            if (data) {

                let notifications = this.from == 'parent' ? data.slice(0, 3) : data;
                this.notifications = notifications.map(notification => ({
                    ...notification,
                    UserName: notification.User__r ? notification.User__r.Name : 'N/A',
                    fontStyle: notification.Is_Read__c ? 'font-weight: normal;' : 'font-weight: bold;'
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
        getNotifications({
            dateFrom: this.dateFrom,
            dateTo: this.dateTo,
            showArchived: this.showArchived
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
                            return { ...notification, Is_Read__c: true, fontStyle: 'font-weight: normal;' };
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