import { LightningElement, track } from "lwc";
import fetchStatementWithDocuments from "@salesforce/apex/CZ_StatementController.fetchStatementWithDocuments";

const COLUMNS = [
  { label: "Item ID", fieldName: "Product2__c", type: "text" },
  { label: "Invoice Date", fieldName: "Invoice_Date__c", type: "date" },
  { label: "Due Date", fieldName: "Due_Date__c", type: "date" },
  { label: "Location", fieldName: "Location__c", type: "text" },
  { label: "Ship to City", fieldName: "Ship_to_City__c", type: "text" },
  { label: "Entry Type", fieldName: "Entry_Type__c", type: "text" },
  { label: "PO", fieldName: "PO__c", type: "text" },
  {
    label: "Original Amount",
    fieldName: "Original_Amount__c",
    type: "currency"
  },
  { label: "Amount Due", fieldName: "Amount_Due__c", type: "currency" },
  { label: "Currency", fieldName: "Currency__c", type: "text" }
];

export default class UppStatementReport extends LightningElement {
  filters = {};
  @track documents = [];
  @track error;
  columns = COLUMNS;
  statementDateOptions = {};
  locationOptions = {};
  connectedCallback() {
    fetchStatementWithDocuments({ statementFilter: this.filters }).then(
      (response) => {
        let results = response.uppStatements;
        console.log(JSON.stringify(results));
        if (results.length != 0) {
          const valuesSet = new Set();
          this.statementDateOptions = results
            .filter((result) => {
              if (!valuesSet.has(result.Statement_date__c)) {
                valuesSet.add(result.Statement_date__c);
                return true;
              }
              return false;
            })
            .map((result) => ({
              label: result.Statement_date__c,
              value: result.Statement_date__c
            }));

          valuesSet.clear();

          this.locationOptions = results
            .filter((result) => {
              if (!valuesSet.has(result.Location__c)) {
                valuesSet.add(result.Location__c);
                return true;
              }
              return false;
            })
            .map((result) => ({
              label: result.Location__c,
              value: result.Location__c
            }));
        }
      }
    );
  }
  handleFilterChange(event) {
    this.filters[event.target.name] = event.target.value;
  }

  handleApplyFilters() {
    console.log("filters: ", JSON.stringify(this.filters));

    fetchStatementWithDocuments({ statementFilter: this.filters })
      .then((result) => {
        console.log(result.relatedDocuments);

        if ("relatedDocuments" in result) {
          this.documents = result.relatedDocuments;
        }

        console.log("Pass");
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log("Fail", error);
        this.documents = [];
      });
  }

  handleClearFilters() {
    this.filters = {};
    this.handleApplyFilters();
  }
}