const configLists = {
    Medewerkers: {
      name: "Medewerkers",
      type: "Lijst",
      guid: "835ae977-8cd1-4eb8-a787-23aa2d76228d",
      description: "Main list where we will store employee data who need to register leave.",
      apiUrl: "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'835ae977-8cd1-4eb8-a787-23aa2d76228d')",
      fields: [
        { title: "Id", internalName: "ID", type: "Counter", hidden: false, removable: false, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "Titel", internalName: "Title", type: "Text", hidden: false, removable: false, required: false, description: "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)", details: "-", formatting: "N/A" },
        { title: "Geboortedatum", internalName: "Geboortedatum", type: "DateTime", hidden: false, removable: true, required: true, description: "Date of birth. Required value.", details: "Weergaveformaat: Disabled\nWeergave: Disabled", formatting: "N/A" },
        { title: "Actief", internalName: "Actief", type: "Boolean", hidden: false, removable: true, required: false, description: "When an employee has started working elsewhere, that person should not be rendered in our table.", details: "Standaardwaarde: 1", formatting: "N/A" },
        { title: "E-mail", internalName: "E_x002d_mail", type: "Text", hidden: false, removable: true, required: false, description: "This vaue has to be filled by the system automatically by using the REST API to retrieve userinfo. Extract the e-mailadres and store that value here.", details: "-", formatting: "N/A" },
        { title: "Functie", internalName: "Functie", type: "Text", hidden: false, removable: true, required: false, description: "In the Sharepoint list this is a 'single line text' fieldtype. In the forms this should be handled as a 'dropdownmenu'. Values will be dynamically imported through \"keuzelijstFuncties.Title\"", details: "-", formatting: "N/A" },
        { title: "Horen", internalName: "Horen", type: "Boolean", hidden: false, removable: true, required: false, description: "Ja/nee field type. Hearing civilians is a core task for most employees and this field is an indication to determine if an employee is available for hearing or not.\n\nIf yes, person = available\nIf no, person = unavailable.", details: "Standaardwaarde: 1", formatting: "N/A" },
        { title: "Naam", internalName: "Naam", type: "Text", hidden: false, removable: true, required: false, description: "Single line text fieldtype. This is the value to use in the renderRooster.js table. Also display this name next to the username next to the userMenu button.", details: "-", formatting: "N/A" },
        { title: "Team", internalName: "Team", type: "Text", hidden: false, removable: true, required: false, description: "Single line text. While registeriing, this should be rendered as a dropdownmenu. The values for the dropdown should be extracted through the REST API by GET'ing the 'Teams' list\n\nAddtionally, in roosterRender.js we will group values based on this field's values.", details: "-", formatting: "N/A" },
        { title: "Username", internalName: "Username", type: "Text", hidden: false, removable: true, required: false, description: "Similar to e-mail: fill this with the user's username so we can relate several lists like a relational database", details: "-", formatting: "N/A" }
      ]
    },
    Verlof: {
      name: "Verlof",
      type: "Lijst",
      guid: "e12a068f-2821-4fe1-b898-e42e1418edf8",
      description: "Supplementive list to store the requested leave per user.",
      apiUrl: "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'e12a068f-2821-4fe1-b898-e42e1418edf8')",
      fields: [
        { title: "Id", internalName: "ID", type: "Counter", hidden: false, removable: false, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "Titel", internalName: "Title", type: "Text", hidden: false, removable: false, required: false, description: "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)", details: "-", formatting: "N/A" },
        { title: "Medewerker", internalName: "Medewerker", type: "Text", hidden: false, removable: true, required: true, description: "-", details: "-", formatting: "N/A" },
        { title: "AanvraagTijdstip", internalName: "AanvraagTijdstip", type: "DateTime", hidden: false, removable: true, required: false, description: "Field type default value is set to 'today's date'. This is used to store when the leave was requested and also at what  time.", details: "Standaardwaarde: [today]\nWeergaveformaat: Disabled\nWeergave: Disabled", formatting: "N/A" },
        { title: "EindDatum", internalName: "EindDatum", type: "DateTime", hidden: false, removable: true, required: false, description: "The date where the leave ends. Assume for renderRooster.js that the next working day is when the user will start working again. \n\nSet up as date and time field type.", details: "Weergaveformaat: Disabled\nWeergave: Disabled", formatting: "N/A" },
        { title: "MedewerkerID", internalName: "MedewerkerID", type: "Text", hidden: false, removable: true, required: false, description: "When the user is requesting a new leave moment, we store their username in this field so we can relate the Medewerkers.Username field to the Verlof.MedewerkerID field.\n\nAll requested leave should always appear on the rendered table in renderRooster.js", details: "-", formatting: "N/A" },
        { title: "Omschrijving", internalName: "Omschrijving", type: "Text", hidden: false, removable: true, required: false, description: "Arbitrary field to give the user the ability to add a comment to their leave. This is optional and should not appear in a tooltip. Only 1. Sharepoint beheer and 1.1 Mulder MT should be allowed to read this field.", details: "-", formatting: "N/A" },
        { title: "Reden", internalName: "Reden", type: "Text", hidden: false, removable: true, required: false, description: "The reason for requesting leave is stored here. Whilst I set this up as a singe line text, this should be shown as a dropdownemnu. Values are added dynamically by doing a GET request via the REST APi. Extract all unique values from the list Verlofredenen.Title and use those values to build the choices.", details: "-", formatting: "N/A" },
        { title: "StartDatum", internalName: "StartDatum", type: "DateTime", hidden: false, removable: true, required: false, description: "The date the user's leave will start. Set up as 'date and time' field. From this date/time the leave starts. Leave is over the next working day. If the endDate is in the weekend it should consider saturday and sunday as moot/irrelevant for our leave. It just implies the persoon still has holidays on friday and starts working on monday.", details: "Weergaveformaat: Disabled\nWeergave: Disabled", formatting: "N/A" },
        { title: "Status", internalName: "Status", type: "Text", hidden: false, removable: true, required: false, description: "Field where we will write additional notes. Fill this dynamically through list statuslijstOpties.Title", details: "-", formatting: "N/A" }
      ]
    },
    Verlofredenen: {
      name: "Verlofredenen",
      type: "Lijst",
      guid: "6ca65cc0-ad60-49c9-9ee4-371249e55c7d",
      description: "List to use when building forms that contain the 'Verlofreden' or 'reden' field.\n\nThis should be managed through 'Beheercentrum' as an isolated tab.",
      apiUrl: "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'6ca65cc0-ad60-49c9-9ee4-371249e55c7d')",
      fields: [
        { title: "Id", internalName: "ID", type: "Counter", hidden: false, removable: false, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "Titel", internalName: "Title", type: "Text", hidden: false, removable: false, required: false, description: "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)", details: "-", formatting: "N/A" },
        { title: "Naam", internalName: "Naam", type: "Text", hidden: false, removable: true, required: true, description: "The category of the requested leave. Make this appear in the legend next to the example box for 'Kleur'", details: "-", formatting: "N/A" },
        { title: "Kleur", internalName: "Kleur", type: "Text", hidden: false, removable: true, required: false, description: "In roosterRender.js: use this field to fill the grid according to the Verlof.StartDatum and Verlof.EindDatum. Apply the color that was appointed in this field. This field contains a hex value.", details: "-", formatting: "N/A" },
        { title: "VerlofDag", internalName: "VerlofDag", type: "Boolean", hidden: false, removable: true, required: false, description: "To determine if a leave day should count towards lowering the person's total leave hours (if this option is made available). For example:\n\nPerson has 240 hours of leave for this year. If VerlofDag = yes, the amount of hours requested leave will be reduced from that total (usually -8 hours for a full day). If no, 0 hours will be reduced.", details: "Standaardwaarde: 1", formatting: "N/A" }
      ]
    },
    UrenPerWeek: {
      name: "UrenPerWeek",
      type: "Lijst",
      guid: "55bf75d8-d9e6-4614-8ac0-c3528bdb0ea8",
      description: "This list stores the default working hours per week. The fields ending in suffix 'Start' contain starting hours\nSuffix Eind: ending hours\nSuffix Totaal: total amount of hours worked\nSuffix Soort: determine if the user has had a full day of work (no category)\nOtherwise, extract values from DagenIndicators.Title",
      apiUrl: "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'55bf75d8-d9e6-4614-8ac0-c3528bdb0ea8')",
      fields: [
        { title: "Id", internalName: "ID", type: "Counter", hidden: false, removable: false, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "Titel", internalName: "Title", type: "Text", hidden: false, removable: false, required: false, description: "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)", details: "-", formatting: "N/A" },
        { title: "DinsdagEind", internalName: "DinsdagEind", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DinsdagSoort", internalName: "DinsdagSoort", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DinsdagStart", internalName: "DinsdagStart", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DinsdagTotaal", internalName: "DinsdagTotaal", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DonderdagEind", internalName: "DonderdagEind", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DonderdagSoort", internalName: "DonderdagSoort", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DonderdagStart", internalName: "DonderdagStart", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "DonderdagTotaal", internalName: "DonderdagTotaal", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "MaandagEind", internalName: "MaandagEind", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "MaandagSoort", internalName: "MaandagSoort", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "MaandagStart", internalName: "MaandagStart", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "MaandagTotaal", internalName: "MaandagTotaal", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "MedewerkerID", internalName: "MedewerkerID", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "VrijdagEind", internalName: "VrijdagEind", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "VrijdagSoort", internalName: "VrijdagSoort", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "VrijdagStart", internalName: "VrijdagStart", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "VrijdagTotaal", internalName: "VrijdagTotaal", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "WoensdagEind", internalName: "WoensdagEind", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "WoensdagSoort", internalName: "WoensdagSoort", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "WoensdagStart", internalName: "WoensdagStart", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" },
        { title: "WoensdagTotaal", internalName: "WoensdagTotaal", type: "Text", hidden: false, removable: true, required: false, description: "-", details: "-", formatting: "N/A" }
      ]
    }
  };
  
  // Export the configuration object if using modules, otherwise it will be globally available
  // Example for Node.js/CommonJS:
  // module.exports = configLists;
  // Example for ES Modules:
  // export default configLists;
  
  console.log("configList.js geladen.");