import { LightningElement, api } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import customIconTextTemplate from './customIconTextTemplate.html';
export default class CustomDataTable extends LightningDatatable {
    @api iconName;
    @api value; // Message text
    static customTypes = {
        customIconText: {
            template: customIconTextTemplate,
            typeAttributes:['Is_Read__c']
        }
    };

}