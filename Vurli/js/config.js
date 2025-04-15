// Configuratie data
const configuratie = {
  "lijsten": [
    // Eerste lijst: Verlof
    {
      "lijstInformatie": {
        "naam": "Verlof",
        "type": "Lijst",
        "guid": "e12a068f-2821-4fe1-b898-e42e1418edf8",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'e12a068f-2821-4fe1-b898-e42e1418edf8')/items"
      },
      "velden": [
        {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
        {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
        {"titel": "Medewerker", "interneNaam": "Medewerker", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": true, "beschrijving": "-", "formulierControlType": "PeoplePicker", "formulierControlConfig": {"bron": ["SharePoint", "AD"]}},
        {"titel": "Aanvragtijdstip", "interneNaam": "Aanvragtijdstip", "type": "DateTime", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "EindDatum", "interneNaam": "EindDatum", "type": "DateTime", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MedewerkerID", "interneNaam": "MedewerkerID", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Omschrijving", "interneNaam": "Omschrijving", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Reden", "interneNaam": "Reden", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-", "formulierControlType": "Keuzelijst", "formulierControlConfig": {"keuzes": ["vakantie/verlof", "Ziekte", "Anders"]}},
        {"titel": "StartDatum", "interneNaam": "StartDatum", "type": "DateTime", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Status", "interneNaam": "Status", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"}
      ]
    },
    // Tweede lijst: Medewerkers
    {
      "lijstInformatie": {
        "naam": "Medewerkers",
        "type": "Lijst",
        "guid": "835ae977-8cd1-4eb8-a787-23aa2d76228d",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'835ae977-8cd1-4eb8-a787-23aa2d76228d')/items"
      },
      "velden": [
        {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
        {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
        {"titel": "Geboortedatum", "interneNaam": "Geboortedatum", "type": "DateTime", "verborgen": false, "verwijderbaar": true, "verplicht": true, "beschrijving": "Geboortedatum; tijd opnemen = Nee. Op het formulier geven medewerkers aan wat hun geboortedatum is. Deze waarde zal hier worden gevuld."},
        {"titel": "Actief", "interneNaam": "Actief", "type": "Boolean", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Ja/nee veld om te duiden of de betreffende collega nog werkzaam is binnen de organisatie (en om die reden mogelijk verborgen moet worden in het verlofrooster"},
        {"titel": "E-mail", "interneNaam": "E_x002d_mail", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Het e-mailadres van de betreffende collega (en tevens de manier waarop gegevens worden ge-extraheerd uit Sharepoint data/AD-data"},
        {"titel": "Functie", "interneNaam": "Functie", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Horen", "interneNaam": "Horen", "type": "Boolean", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Ja/nee veld. Is de betreffende collega beschikbaar om op zittingen te worden geplant?"},
        {"titel": "Naam", "interneNaam": "Naam", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Naam van de betreffende collega en hoe deze in de lijst zal moeten verschijnen."},
        {"titel": "Team", "interneNaam": "Team", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Het team waar de betreffende collega bij hoort."}
      ]
    },
    // Derde lijst: Verlofredenen
    {
      "lijstInformatie": {
        "naam": "Verlofredenen",
        "type": "Lijst",
        "guid": "6ca65cc0-ad60-49c9-9ee4-371249e55c7d",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'6ca65cc0-ad60-49c9-9ee4-371249e55c7d')/items"
      },
      "velden": [
         {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
         {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
         {"titel": "Naam", "interneNaam": "Naam", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": true, "beschrijving": "-"},
         {"titel": "Goedgekeurd", "interneNaam": "Goedgekeurd", "type": "Boolean", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
         {"titel": "Kleur", "interneNaam": "Kleur", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Hexadecimale kleurcode"},
         {"titel": "VerlofDag", "interneNaam": "VerlofDag", "type": "Boolean", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"}
      ]
    },
    // Vierde lijst: UrenPerWeek
    {
      "lijstInformatie": {
        "naam": "UrenPerWeek",
        "type": "Lijst",
        "guid": "55bf75d8-d9e6-4614-8ac0-c3528bdb0ea8",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'55bf75d8-d9e6-4614-8ac0-c3528bdb0ea8')/items"
      },
      "velden": [
        {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
        {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
        {"titel": "DinsdagEind", "interneNaam": "DinsdagEind", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DinsdagSoort", "interneNaam": "DinsdagSoort", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DinsdagStart", "interneNaam": "DinsdagStart", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DinsdagTotaal", "interneNaam": "DinsdagTotaal", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DonderdagEind", "interneNaam": "DonderdagEind", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DonderdagSoort", "interneNaam": "DonderdagSoort", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DonderdagStart", "interneNaam": "DonderdagStart", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "DonderdagTotaal", "interneNaam": "DonderdagTotaal", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MaandagEind", "interneNaam": "MaandagEind", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MaandagSoort", "interneNaam": "MaandagSoort", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MaandagStart", "interneNaam": "MaandagStart", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MaandagTotaal", "interneNaam": "MaandagTotaal", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MedewerkerID", "interneNaam": "MedewerkerID", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "Koppelt deze uren aan een specifieke medewerker (ID uit Medewerkers lijst)"},
        {"titel": "VrijdagEind", "interneNaam": "VrijdagEind", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "VrijdagSoort", "interneNaam": "VrijdagSoort", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "VrijdagStart", "interneNaam": "VrijdagStart", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "VrijdagTotaal", "interneNaam": "VrijdagTotaal", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "WoensdagEind", "interneNaam": "WoensdagEind", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "WoensdagSoort", "interneNaam": "WoensdagSoort", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "WoensdagStart", "interneNaam": "WoensdagStart", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "WoensdagTotaal", "interneNaam": "WoensdagTotaal", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"}
      ]
    },
    // Vijfde lijst: Seniors
    {
      "lijstInformatie": {
        "naam": "Seniors",
        "type": "Lijst",
        "guid": "2e9b5974-7d69-4711-b9e6-f8db85f96f5f",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'2e9b5974-7d69-4711-b9e6-f8db85f96f5f')/items"
      },
      "velden": [
        {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
        {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
        {"titel": "Medewerker", "interneNaam": "Medewerker", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "MedewerkerId", "interneNaam": "MedewerkerId", "type": "User", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Team", "interneNaam": "Team", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "TeamId", "interneNaam": "TeamId", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"}
      ]
    },
    // Zesde lijst: Teams
    {
      "lijstInformatie": {
        "naam": "Teams",
        "type": "Lijst",
        "guid": "dc2911c5-b0b7-4092-9c99-5fe957fdf6fc",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'dc2911c5-b0b7-4092-9c99-5fe957fdf6fc')/items"
      },
      "velden": [
        {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
        {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
        {"titel": "Naam", "interneNaam": "Naam", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": true, "beschrijving": "-"},
        {"titel": "Actief", "interneNaam": "Actief", "type": "Boolean", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Kleur", "interneNaam": "Kleur", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Teamleider", "interneNaam": "Teamleider", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "TeamleiderId", "interneNaam": "TeamleiderId", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"}
      ]
    },
    // Zevende lijst: DagenIndicators
    {
      "lijstInformatie": {
        "naam": "DagenIndicators",
        "type": "Lijst",
        "guid": "45528ed2-cdff-4958-82e4-e3eb032fd0aa",
        "apiUrl": "/sites/MulderT/CustomPW/Verlof/_api/web/lists(guid'45528ed2-cdff-4958-82e4-e3eb032fd0aa')/items"
      },
      "velden": [
        {"titel": "Titel", "interneNaam": "Title", "type": "Text", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "Geef het bestand een naam (deze zal worden gebruikt voor de zoekmachine)"},
        {"titel": "Id", "interneNaam": "ID", "type": "Counter", "verborgen": false, "verwijderbaar": false, "verplicht": false, "beschrijving": "-"},
        {"titel": "Kleur", "interneNaam": "Kleur", "type": "Text", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-"},
        {"titel": "Patroon", "interneNaam": "Patroon", "type": "Choice", "verborgen": false, "verwijderbaar": true, "verplicht": false, "beschrijving": "-",
         "keuzes": [
            "Effen",
            "Diagonale lijn (rechts)",
            "Diagonale lijn (links)",
            "Kruis",
            "Plus",
            "Louis Vuitton"
         ]}
      ]
    }
  ]
};
