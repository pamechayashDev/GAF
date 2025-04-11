import { LightningElement, track } from "lwc";
import fetchStatementWithDocuments from "@salesforce/apex/CZ_StatementController.fetchStatementWithDocuments";
import jsPDF from "@salesforce/resourceUrl/jsPDF";
import html2canvas from "@salesforce/resourceUrl/html2canvas";
import { loadScript } from "lightning/platformResourceLoader";

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
  @track documentFilters = {};
  @track documents = [];
  optionsObject = {};
  showCreditInvoice = false;
  @track error;
  columns = COLUMNS;
  statementDateOptions = {};
  locationOptions = {};
  businessTypeOptions = {};
  jsPdfInitialized = false;
  linkAvailable = true;
  connectedCallback() {
    Promise.all([loadScript(this, jsPDF), loadScript(this, html2canvas)]).then(
      () => {
        console.log("jsPdfInitialized");
        this.jsPdfInitialized = true;
      }
    );

    fetchStatementWithDocuments({
      statementFilter: this.filters,
      documentFilter: this.documentFilters
    }).then((response) => {
      let results = response.uppStatements;
      console.log(JSON.stringify(results));
      if (results.length != 0) {
        const valuesSet = new Set();
        this.statementDateOptions = results
          .filter((result) => {
            console.log("result.Statement_date__c" + result.Statement_date__c);

            if (!valuesSet.has(result.Statement_date__c)) {
              return true;
            }
            return false;
          })
          .map((result) => ({
            label:
              result.Statement_date__c.split("-")[0] +
              ", " +
              result.Statement_date__c.split("-")[1],
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
    });
  }
  isExpanded = true;
  toggleFilters() {
    this.isExpanded = !this.isExpanded;
  }

  downloadCSV() {
    if (!this.documents.length) return;

    const header = [
      "Invoice Date",
      "Due Date",
      "Location",
      "Ship to City",
      "Entry Type",
      "PO",
      "Amount Due",
      "Currency",
      "Upp Statement",
      "Original Amount",
      "Business Type",
      "Payment Status",
      "Ship to State",
      "Sold to City",
      "Sold to State"
    ];
    const rows = this.documents.map((rec) => [
      rec.Invoice_Date__c,
      rec.Due_Date__c,
      rec.Location__c,
      rec.Ship_to_City__c,
      rec.Entry_Type__c,
      rec.PO__c,
      rec.Amount_Due__c,
      rec.Currency__c,
      rec.UPP_Statement__c,
      rec.Original_Amount__c,
      rec.Business_Type__c,
      rec.Payment_Status__c,
      rec.Ship_to_State__c,
      rec.Sold_to_City__c,
      rec.Sold_to_State__c
    ]);
    console.log(JSON.stringify(this.documents));
    console.log(JSON.stringify(rows));

    let csvContent =
      "data:text/csv;charset=utf-8," +
      header.join(",") +
      "\n" +
      rows.map((e) => e.join(",")).join("\n");

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "documents.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  downloadPDF() {
    if (!this.documents.length) return;
    let data = JSON.stringify(this.documents);
    const encoded = btoa(data); // Base64 encode

    const vfUrl = "/apex/uppDocumentsPage?data=" + encodeURIComponent(encoded);
    window.open(vfUrl, "_blank");
  }

  downloadDocumentLink = "";
  handleFilterChange(event) {
    this.filters[event.target.name] = event.target.value;
  }
  selectedStatementId = "";
  selectedStatement = true;
  handleApplyFilters() {
    console.log("filters: ", JSON.stringify(this.filters));

    fetchStatementWithDocuments({
      statementFilter: this.filters,
      documentFilter: this.documentFilters
    })
      .then((result) => {
        console.log(result.relatedDocuments);
        console.log(
          "result.uppStatements :" + JSON.stringify(result.uppStatements)
        );

        if ("relatedDocuments" in result) {
          this.documents = result.relatedDocuments;
        }

        //populating options
        let comboboxFieds = [
          "Business_Type__c",
          "Payment_Status__c",
          "Ship_to_State__c",
          "Ship_to_City__c",
          "Sold_to_City__c",
          "Sold_to_State__c"
        ];

        const valuesSet = new Set();
        for (let Field of comboboxFieds) {
          this.optionsObject[Field + "Options"] = this.documents
            .filter((result) => {
              if (!valuesSet.has(result[Field])) {
                valuesSet.add(result[Field]);
                return true;
              }
              return false;
            })
            .map((result) => ({
              label: result[Field],
              value: result[Field]
            }));
          valuesSet.clear();
        }
        console.log(JSON.stringify(this.optionsObject));
        this.selectedStatementId = result.uppStatements[0].Id;

        if (result.uppStatements[0].Document_Link__c != null) {
          this.downloadDocumentLink = result.uppStatements[0].Document_Link__c;
        } else {
          this.linkAvailable = false;
        }

        if (this.selectedStatementId != "") {
          this.selectedStatement = false;
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

  handleDocumentApplyFilters() {
    let statementfilters = {};
    statementfilters["Id"] = this.selectedStatementId;
    console.log("documentFilters" + JSON.stringify(this.documentFilters));
    console.log("statementfilters" + JSON.stringify(statementfilters));

    fetchStatementWithDocuments({
      statementFilter: statementfilters,
      documentFilter: this.documentFilters
    })
      .then((result) => {
        console.log(
          "relatedDocuments" + JSON.stringify(result.relatedDocuments)
        );

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

  handleDocumentFilterChange(event) {
    const { name, value, checked, type } = event.target;
    if (type === "checkbox") {
      this.documentFilters[name] = checked ? "Credit" : "";
    } else {
      this.documentFilters[name] = value;
    }
  }

  handleClearFilters() {
    this.filters = {};
    this.handleApplyFilters();
  }
  handleClearDocumentFilters() {
    this.documentFilters = {};
    this.handleDocumentApplyFilters();
  }
}
