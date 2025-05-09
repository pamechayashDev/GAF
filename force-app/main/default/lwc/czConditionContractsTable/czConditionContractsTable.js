import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getConditionContracts from "@salesforce/apex/CZ_ConditionContractsController.getConditionContracts";
import getConditionContractDocuments from "@salesforce/apex/CZ_ConditionContractsController.getConditionContractDocuments";

export default class CzConditionContractsTable extends LightningElement {
  isParent = true;
  @track filterData = {
    planId: "None",
    planDescription: "None",
    year: "None",
    validFrom: null,
    validTo: null,
    accountName: "None"
  };
  @track documentFilterData = {
    documentPlanId: "None",
    documentAccountName: "None",
    documentInvoiceNumber: "None",
    creditIssuedDateFrom: null,
    creditIssuedDateTo: null
  };
  conditionContractId = null;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;
  @track contractTableData = [];
  columns = [];

  toggleColumns() {
    this.columns = this.isParent
      ? [
          {
            label: "Plan Description",
            fieldName: "Condition_Contract_Description__c",
            sortable: true
          },
          {
            label: "Plan Id",
            fieldName: "Condition_Contract_Id__c",
            sortable: true
          },
          { label: "Year", fieldName: "Year__c", sortable: true },

          { label: "Account Name", fieldName: "AccountName", sortable: true },

          { label: "Valid To", fieldName: "Valid_To_Date__c", sortable: true },
          {
            label: "Valid From",
            fieldName: "Valid_From_Date__c",
            sortable: true
          },
          {
            label: "Actions",
            type: "button",
            typeAttributes: {
              label: "Condtion Contract Documents",
              name: "openDocuments",
              variant: "base",
              class: "slds-text-link"
            }
          }
        ]
      : [
          {
            label: "Plan Id",
            fieldName: "PlanId",
            sortable: true
          },

          { label: "Account Name", fieldName: "AccountName", sortable: true },
          {
            label: "Credit Invoice",
            type: "button",
            fieldName: "Settlement_Document_Number__c",
            sortable: true,
            typeAttributes: {
              label: { fieldName: "Settlement_Document_Number__c" },

              name: "openCreditMemo",
              variant: "base",
              class: "slds-text-link"
            }
          },
          {
            label: "View Backup",
            type: "button",
            fieldName: "Download_URL__c",
            typeAttributes: {
              label: { fieldName: "Download_URL__c" },
              name: "openBackup",
              variant: "base",
              class: "slds-text-link"
            }
          },

          {
            label: "Amount",
            fieldName: "Credit_Amount__c",
            sortable: true
          },
          {
            label: "Date Credit Issued",
            fieldName: "Document_Date__c",
            sortable: true
          }
        ];
  }

  applyFilters() {
    getConditionContracts({
      planId: this.filterData.planId,
      year: this.filterData.year,
      validFrom: this.filterData.validFrom,
      validTo: this.filterData.validTo,
      accountName: this.filterData.accountName
    }).then((data) => {
      this.contractTableData = [];
      this.contractTableData = data;
      this.contractTableData = this.contractTableData.map((item) => ({
        ...item,
        AccountName: item.Contract_Account__r.Name
      }));
    });
  }
  applyDocumentsFilters() {
    getConditionContractDocuments({
      documentPlanId: this.documentFilterData.documentPlanId,
      documentAccountName: this.documentFilterData.documentAccountName,
      documentInvoiceNumber: this.documentFilterData.documentInvoiceNumber,
      creditIssuedDateFrom: this.documentFilterData.creditIssuedDateFrom,
      creditIssuedDateTo: this.documentFilterData.creditIssuedDateTo,
      conditionContractId: this.conditionContractId
    }).then((data) => {
      this.contractTableData = [];
      this.contractTableData = data;
      this.contractTableData = this.contractTableData.map((item) => ({
        ...item,
        PlanId: item.Condition_Contract_Id__r.Condition_Contract_Id__c,
        AccountName: item.Contract_Account__r.Name
      }));
    });
  }
  clearFilters() {
    this.filterData = {
      planId: "None",
      planDescription: "None",
      year: "None",
      validFrom: null,
      validTo: null,
      accountName: "None"
    };
    this.applyFilters();
  }
  clearDocumentsFilters() {
    this.documentFilterData = {
      documentPlanId: "None",
      documentAccountName: "None",
      documentInvoiceNumber: "None",
      creditIssuedDateFrom: null,
      creditIssuedDateTo: null
    };
    this.applyDocumentsFilters();
  }
  connectedCallback() {
    this.toggleColumns();
    this.applyFilters();
  }
  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }
  handleChange(event) {
    const field = event.target.name;
    const value = event.target.value;
    this.filterData = { ...this.filterData, [field]: value };
  }
  handleDocumentFiltersChange(event) {
    const field = event.target.name;
    const value = event.target.value;
    this.documentFilterData = { ...this.documentFilterData, [field]: value };
  }
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === "openDocuments") {
      this.isParent = false;
      this.conditionContractId = row.Id;
      console.log("this.conditionContractId " + this.conditionContractId);
      this.toggleColumns();
      this.applyDocumentsFilters();

      // initialise this.contractDocuments
    }
    if (actionName === "openCreditMemo") {
      window.open(row.Document_URL__c, "_blank");
    }
    if (actionName === "openBackup") {
      window.open(row.Download_URL__c, "_blank");
    }
  }
  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.contractTableData];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.contractTableData = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  backToConditionContracts() {
    this.isParent = true;
    this.toggleColumns();
    this.applyFilters();
  }
}