// === CRUD.js ===
// Functies voor het beheren van SharePoint lijstitems (Create, Read, Update, Delete)

/**
 * Haalt de Request Digest op die nodig is voor schrijfacties (POST, MERGE, DELETE).
 * @returns {Promise<string>} Een Promise die oplost met de Request Digest waarde.
 */
async function getRequestDigest() {
    // Pas de URL aan naar de root van je site of een specifieke site indien nodig
    const contextInfoUrl = `${window.location.origin}/_api/contextinfo`;
    console.log("Request Digest ophalen via:", contextInfoUrl);
    try {
        const response = await fetch(contextInfoUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
                // Voeg eventueel andere benodigde headers toe
            }
        });
        if (!response.ok) {
            throw new Error(`HTTP fout ${response.status} bij ophalen Request Digest`);
        }
        const data = await response.json();
        const digest = data?.d?.GetContextWebInformation?.FormDigestValue;
        if (!digest) {
            throw new Error("Kon FormDigestValue niet vinden in contextinfo response.");
        }
        console.log("Request Digest succesvol opgehaald.");
        return digest;
    } catch (error) {
        console.error("Fout bij ophalen Request Digest:", error);
        throw error; // Gooi fout door
    }
}

/**
 * Haalt de ListItemEntityTypeFullName op voor een lijst, nodig voor POST/MERGE.
 * @param {string} lijstGuid - De GUID van de SharePoint lijst.
 * @returns {Promise<string>} Een Promise die oplost met de entity type name (bv. "SP.Data.VerlofredenenListItem").
 */
async function getListEntityType(lijstGuid) {
    // Gebruik de appConfiguratie variabele (ervan uitgaande dat die globaal beschikbaar is)
    if (!appConfiguratie) {
        console.error("Configuratie object niet beschikbaar in getListEntityType.");
        throw new Error("Configuratie niet geladen.");
    }
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig || !lijstConfig.lijstInformatie.apiUrl) {
        throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);
    }
    // Haal de basis API URL (zonder /items)
    const listApiUrl = lijstConfig.lijstInformatie.apiUrl.substring(0, lijstConfig.lijstInformatie.apiUrl.lastIndexOf('/'));
    const entityTypeUrl = `${listApiUrl}?$select=ListItemEntityTypeFullName`;

    console.log("ListItemEntityTypeFullName ophalen via:", entityTypeUrl);
    try {
        const response = await fetch(entityTypeUrl, {
            method: 'GET',
            headers: { 'Accept': 'application/json;odata=verbose' }
        });
        if (!response.ok) {
            throw new Error(`HTTP fout ${response.status} bij ophalen ListEntityType`);
        }
        const data = await response.json();
        const entityTypeName = data?.d?.ListItemEntityTypeFullName;
        if (!entityTypeName) {
            throw new Error("Kon ListItemEntityTypeFullName niet vinden in lijst response.");
        }
        console.log(`ListEntityType voor ${lijstGuid}: ${entityTypeName}`);
        return entityTypeName;
    } catch (error) {
        console.error("Fout bij ophalen ListEntityType:", error);
        throw error;
    }
}

/**
 * Voegt een nieuw item toe aan een SharePoint lijst.
 * @param {string} lijstGuid - De GUID van de lijst.
 * @param {object} itemData - Een object met de veldwaarden voor het nieuwe item.
 * BELANGRIJK: Veldnamen moeten interne namen zijn!
 * @returns {Promise<object>} Een Promise die oplost met de data van het aangemaakte item.
 */
async function voegLegendaItemToe(lijstGuid, itemData) {
    console.log(`Poging tot toevoegen item aan lijst ${lijstGuid}:`, itemData);
    if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar.");
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig) throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);
    const itemsApiUrl = lijstConfig.lijstInformatie.apiUrl; // URL eindigt op /items

    try {
        // Haal benodigde metadata op
        const [requestDigest, entityTypeName] = await Promise.all([
            getRequestDigest(),
            getListEntityType(lijstGuid)
        ]);

        // Voeg metadata toe aan de item data
        const payload = {
            ...itemData,
            '__metadata': { 'type': entityTypeName }
        };

        // Voer POST request uit
        const response = await fetch(itemsApiUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
                'Content-Type': 'application/json;odata=verbose',
                'X-RequestDigest': requestDigest
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            // Probeer foutdetails te lezen
            let errorDetails = response.statusText;
            try { const errorData = await response.json(); errorDetails = errorData?.error?.message?.value || errorDetails; } catch (e) {}
            throw new Error(`HTTP fout ${response.status} bij toevoegen item: ${errorDetails}`);
        }

        const nieuwItem = await response.json();
        console.log("Item succesvol toegevoegd:", nieuwItem.d);
        return nieuwItem.d; // Geef het nieuwe item (genest in 'd') terug

    } catch (error) {
        console.error(`Fout bij toevoegen item aan lijst ${lijstGuid}:`, error);
        throw error; // Gooi fout door voor afhandeling in UI
    }
}

/**
 * Werkt een bestaand item bij in een SharePoint lijst.
 * @param {string} lijstGuid - De GUID van de lijst.
 * @param {number|string} itemId - Het ID van het item dat bijgewerkt moet worden.
 * @param {object} itemData - Een object met de bij te werken veldwaarden.
 * BELANGRIJK: Veldnamen moeten interne namen zijn!
 * @returns {Promise<void>} Een Promise die oplost als de update succesvol is.
 */
async function updateLegendaItem(lijstGuid, itemId, itemData) {
    console.log(`Poging tot updaten item ${itemId} in lijst ${lijstGuid}:`, itemData);
    if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar.");
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig) throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);

    // Bouw de URL naar het specifieke item
    const itemApiUrl = `${lijstConfig.lijstInformatie.apiUrl}(${itemId})`;

    try {
        // Haal benodigde metadata op
        const [requestDigest, entityTypeName] = await Promise.all([
            getRequestDigest(),
            getListEntityType(lijstGuid)
        ]);

        // Voeg metadata toe
        const payload = {
            ...itemData,
            '__metadata': { 'type': entityTypeName }
        };

        // Voer MERGE request uit
        const response = await fetch(itemApiUrl, {
            method: 'POST', // Gebruik POST voor MERGE in SharePoint
            headers: {
                'Accept': 'application/json;odata=verbose',
                'Content-Type': 'application/json;odata=verbose',
                'X-RequestDigest': requestDigest,
                'X-HTTP-Method': 'MERGE', // Geef aan dat het een update is
                'If-Match': '*' // Overschrijf eventuele conflicten (of gebruik specifieke ETag)
            },
            body: JSON.stringify(payload)
        });

        // SharePoint retourneert 204 No Content bij een succesvolle update
        if (response.status !== 204) {
            let errorDetails = response.statusText;
            try { const errorData = await response.json(); errorDetails = errorData?.error?.message?.value || errorDetails; } catch (e) {}
            throw new Error(`HTTP fout ${response.status} bij updaten item ${itemId}: ${errorDetails}`);
        }

        console.log(`Item ${itemId} succesvol bijgewerkt.`);
        // Geen response body bij 204

    } catch (error) {
        console.error(`Fout bij updaten item ${itemId} in lijst ${lijstGuid}:`, error);
        throw error;
    }
}

/**
 * Verwijdert een item uit een SharePoint lijst.
 * @param {string} lijstGuid - De GUID van de lijst.
 * @param {number|string} itemId - Het ID van het te verwijderen item.
 * @returns {Promise<void>} Een Promise die oplost als het verwijderen succesvol is.
 */
async function verwijderLegendaItem(lijstGuid, itemId) {
    console.log(`Poging tot verwijderen item ${itemId} uit lijst ${lijstGuid}`);
    if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar.");
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig) throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);

    // Bouw de URL naar het specifieke item
    const itemApiUrl = `${lijstConfig.lijstInformatie.apiUrl}(${itemId})`;

    try {
        // Haal Request Digest op
        const requestDigest = await getRequestDigest();

        // Voer DELETE request uit
        const response = await fetch(itemApiUrl, {
            method: 'POST', // Gebruik POST voor DELETE in SharePoint
            headers: {
                'Accept': 'application/json;odata=verbose',
                'X-RequestDigest': requestDigest,
                'X-HTTP-Method': 'DELETE',
                'If-Match': '*' // Nodig voor verwijderen
            }
        });
// === CRUD.js ===
// Functies voor het beheren van SharePoint lijstitems (Create, Read, Update, Delete)

/**
 * Haalt de Request Digest op die nodig is voor schrijfacties (POST, MERGE, DELETE).
 * Haalt de digest op van de specifieke site context van de lijst.
 * @param {string} listApiUrl - De API URL van de lijst (bv. /sites/../_api/web/lists(...)/items).
 * @returns {Promise<string>} Een Promise die oplost met de Request Digest waarde.
 */
async function getRequestDigest(listApiUrl) {
    // Bepaal de site URL door het /_api/... deel te verwijderen
    const siteRelativeUrl = listApiUrl.substring(0, listApiUrl.indexOf('/_api/'));
    const contextInfoUrl = `${window.location.origin}${siteRelativeUrl}/_api/contextinfo`; // Gebruik de site-specifieke contextinfo

    console.log("Request Digest ophalen via:", contextInfoUrl);
    try {
        const response = await fetch(contextInfoUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
            }
        });
        if (!response.ok) {
            throw new Error(`HTTP fout ${response.status} bij ophalen Request Digest van ${contextInfoUrl}`);
        }
        const data = await response.json();
        const digest = data?.d?.GetContextWebInformation?.FormDigestValue;
        if (!digest) {
            throw new Error("Kon FormDigestValue niet vinden in contextinfo response.");
        }
        console.log("Request Digest succesvol opgehaald.");
        return digest;
    } catch (error) {
        console.error("Fout bij ophalen Request Digest:", error);
        throw error; // Gooi fout door
    }
}

/**
 * Haalt de ListItemEntityTypeFullName op voor een lijst, nodig voor POST/MERGE.
 * @param {string} lijstGuid - De GUID van de SharePoint lijst.
 * @returns {Promise<string>} Een Promise die oplost met de entity type name (bv. "SP.Data.VerlofredenenListItem").
 */
async function getListEntityType(lijstGuid) {
    // Gebruik de appConfiguratie variabele (ervan uitgaande dat die globaal beschikbaar is)
    if (!appConfiguratie) {
        console.error("Configuratie object niet beschikbaar in getListEntityType.");
        throw new Error("Configuratie niet geladen.");
    }
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig || !lijstConfig.lijstInformatie.apiUrl) {
        throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);
    }
    // Haal de basis API URL (zonder /items)
    const listApiUrl = lijstConfig.lijstInformatie.apiUrl.substring(0, lijstConfig.lijstInformatie.apiUrl.lastIndexOf('/'));
    const entityTypeUrl = `${listApiUrl}?$select=ListItemEntityTypeFullName`;

    console.log("ListItemEntityTypeFullName ophalen via:", entityTypeUrl);
    try {
        const response = await fetch(entityTypeUrl, {
            method: 'GET',
            headers: { 'Accept': 'application/json;odata=verbose' }
        });
        if (!response.ok) {
            throw new Error(`HTTP fout ${response.status} bij ophalen ListEntityType`);
        }
        const data = await response.json();
        const entityTypeName = data?.d?.ListItemEntityTypeFullName;
        if (!entityTypeName) {
            throw new Error("Kon ListItemEntityTypeFullName niet vinden in lijst response.");
        }
        console.log(`ListEntityType voor ${lijstGuid}: ${entityTypeName}`);
        return entityTypeName;
    } catch (error) {
        console.error("Fout bij ophalen ListEntityType:", error);
        throw error;
    }
}

/**
 * Voegt een nieuw item toe aan een SharePoint lijst.
 * @param {string} lijstGuid - De GUID van de lijst.
 * @param {object} itemData - Een object met de veldwaarden voor het nieuwe item.
 * BELANGRIJK: Veldnamen moeten interne namen zijn!
 * @returns {Promise<object>} Een Promise die oplost met de data van het aangemaakte item.
 */
async function voegLegendaItemToe(lijstGuid, itemData) {
    console.log(`Poging tot toevoegen item aan lijst ${lijstGuid}:`, itemData);
    if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar.");
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig) throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);
    const itemsApiUrl = lijstConfig.lijstInformatie.apiUrl; // URL eindigt op /items

    try {
        // Haal benodigde metadata op (haal digest op van de site van de lijst)
        const [requestDigest, entityTypeName] = await Promise.all([
            getRequestDigest(itemsApiUrl), // Geef lijst URL mee
            getListEntityType(lijstGuid)
        ]);

        // Voeg metadata toe aan de item data
        const payload = {
            ...itemData,
            '__metadata': { 'type': entityTypeName }
        };

        // Voer POST request uit
        const response = await fetch(itemsApiUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
                'Content-Type': 'application/json;odata=verbose',
                'X-RequestDigest': requestDigest
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            let errorDetails = response.statusText;
            try { const errorData = await response.json(); errorDetails = errorData?.error?.message?.value || errorDetails; } catch (e) {}
            throw new Error(`HTTP fout ${response.status} bij toevoegen item: ${errorDetails}`);
        }

        const nieuwItem = await response.json();
        console.log("Item succesvol toegevoegd:", nieuwItem.d);
        return nieuwItem.d;

    } catch (error) {
        console.error(`Fout bij toevoegen item aan lijst ${lijstGuid}:`, error);
        throw error;
    }
}

/**
 * Werkt een bestaand item bij in een SharePoint lijst.
 * @param {string} lijstGuid - De GUID van de lijst.
 * @param {number|string} itemId - Het ID van het item dat bijgewerkt moet worden.
 * @param {object} itemData - Een object met de bij te werken veldwaarden.
 * BELANGRIJK: Veldnamen moeten interne namen zijn!
 * @returns {Promise<void>} Een Promise die oplost als de update succesvol is.
 */
async function updateLegendaItem(lijstGuid, itemId, itemData) {
    console.log(`Poging tot updaten item ${itemId} in lijst ${lijstGuid}:`, itemData);
    if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar.");
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig) throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);

    // Bouw de URL naar het specifieke item
    const itemApiUrl = `${lijstConfig.lijstInformatie.apiUrl}(${itemId})`;

    try {
        // Haal benodigde metadata op (haal digest op van de site van de lijst)
        const [requestDigest, entityTypeName] = await Promise.all([
            getRequestDigest(lijstConfig.lijstInformatie.apiUrl), // Geef lijst URL mee
            getListEntityType(lijstGuid)
        ]);

        // Voeg metadata toe
        const payload = {
            ...itemData,
            '__metadata': { 'type': entityTypeName }
        };

        // Voer MERGE request uit
        const response = await fetch(itemApiUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
                'Content-Type': 'application/json;odata=verbose',
                'X-RequestDigest': requestDigest,
                'X-HTTP-Method': 'MERGE',
                'If-Match': '*'
            },
            body: JSON.stringify(payload)
        });

        if (response.status !== 204) {
            let errorDetails = response.statusText;
            try { const errorData = await response.json(); errorDetails = errorData?.error?.message?.value || errorDetails; } catch (e) {}
            throw new Error(`HTTP fout ${response.status} bij updaten item ${itemId}: ${errorDetails}`);
        }

        console.log(`Item ${itemId} succesvol bijgewerkt.`);

    } catch (error) {
        console.error(`Fout bij updaten item ${itemId} in lijst ${lijstGuid}:`, error);
        throw error;
    }
}

/**
 * Verwijdert een item uit een SharePoint lijst.
 * @param {string} lijstGuid - De GUID van de lijst.
 * @param {number|string} itemId - Het ID van het te verwijderen item.
 * @returns {Promise<void>} Een Promise die oplost als het verwijderen succesvol is.
 */
async function verwijderLegendaItem(lijstGuid, itemId) {
    console.log(`Poging tot verwijderen item ${itemId} uit lijst ${lijstGuid}`);
    if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar.");
    const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === lijstGuid);
    if (!lijstConfig) throw new Error(`Kon lijst configuratie niet vinden voor GUID: ${lijstGuid}`);

    const itemApiUrl = `${lijstConfig.lijstInformatie.apiUrl}(${itemId})`;

    try {
        // Haal Request Digest op van de site van de lijst
        const requestDigest = await getRequestDigest(lijstConfig.lijstInformatie.apiUrl); // Geef lijst URL mee

        // Voer DELETE request uit
        const response = await fetch(itemApiUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
                'X-RequestDigest': requestDigest,
                'X-HTTP-Method': 'DELETE',
                'If-Match': '*'
            }
        });

        if (response.status !== 200 && response.status !== 204) {
             let errorDetails = response.statusText;
            try { const errorData = await response.json(); errorDetails = errorData?.error?.message?.value || errorDetails; } catch (e) {}
            throw new Error(`HTTP fout ${response.status} bij verwijderen item ${itemId}: ${errorDetails}`);
        }

        console.log(`Item ${itemId} succesvol verwijderd.`);

    } catch (error) {
        console.error(`Fout bij verwijderen item ${itemId} uit lijst ${lijstGuid}:`, error);
        throw error;
    }
}
}
