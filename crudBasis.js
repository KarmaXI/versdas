// == crudBasis.js ==
// Versie met ondersteuning voor het specificeren van een doel-site URL
// en verbeterde foutafhandeling.

/**
 * Haalt de Form Digest Value (Request Digest) op voor een specifieke site URL.
 * @param {string} siteUrl - De absolute URL van de SharePoint site.
 * @returns {Promise<string>} Een Promise die wordt opgelost met de Request Digest string.
 * @throws {Error} Als de siteUrl niet is opgegeven.
 */
function verkrijgRequestDigestVoorSite(siteUrl) {
    if (!siteUrl) {
        return Promise.reject(new Error("Site URL is vereist voor verkrijgRequestDigestVoorSite."));
    }
    // De REST endpoint om context informatie (inclusief de digest) op te halen voor de *specifieke* site.
    const eindpuntUrl = siteUrl.replace(/\/$/, '') + "/_api/contextinfo";
    console.log(`%cRequest Digist opgehaald van site: ${eindpuntUrl}`, "color:white; background-color:green");

    return fetch(eindpuntUrl, {
        method: "POST",
        headers: {
            "Accept": "application/json;odata=verbose"
        }
    })
    .then(antwoord => {
        if (!antwoord.ok) {
             return antwoord.json().catch(() => {
                // Als JSON parsen mislukt, gooi een fout met de status
                throw new Error(`HTTP fout ${antwoord.status} bij ophalen Request Digest van ${eindpuntUrl}`);
             }).then(foutData => {
                // Probeer een gedetailleerde foutmelding te maken
                let foutMelding = `HTTP fout ${antwoord.status} bij ophalen Request Digest van ${eindpuntUrl}`;
                if (foutData && foutData.error && foutData.error.message && foutData.error.message.value) {
                   foutMelding += ` - ${foutData.error.message.value}`;
                }
                throw new Error(foutMelding);
            });
        }
        return antwoord.json();
    })
    .then(data => {
        if (data && data.d && data.d.GetContextWebInformation && data.d.GetContextWebInformation.FormDigestValue) {
            const requestDigest = data.d.GetContextWebInformation.FormDigestValue;
            console.log(`Request Digest verkregen voor ${siteUrl}.`);
            return requestDigest;
        } else {
            throw new Error(`Kon FormDigestValue niet vinden in het antwoord van ${eindpuntUrl}.`);
        }
    })
    .catch(fout => {
        console.error(`Fout bij ophalen Request Digest voor ${siteUrl}:`, fout);
        // Gooi de fout opnieuw door zodat de aanroepende functie deze kan afhandelen
        throw fout;
    });
}


/**
 * Voert een generiek GET-verzoek uit naar een specifieke SharePoint REST API-endpoint op een bepaalde site.
 * @param {string} siteUrl - De absolute URL van de doel SharePoint site.
 * @param {string} specifiekeEndpoint - De specifieke REST API endpoint relatief aan de siteUrl (bijv. "_api/web/lists/...").
 * @returns {Promise<object|null>} Een Promise die wordt opgelost met de geparste JSON-data of null bij succes.
 * @throws {Error} Als de siteUrl niet is opgegeven.
 */
function haalGegevensOp(siteUrl, specifiekeEndpoint) {
     if (!siteUrl) {
        return Promise.reject(new Error("Site URL is vereist voor haalGegevensOp."));
    }
    // Bouw de volledige URL correct op.
    const volledigeEindpuntUrl = siteUrl.replace(/\/$/, '') + '/' + specifiekeEndpoint.replace(/^\//, '');
    console.log(`Uitvoeren GET-verzoek naar: ${volledigeEindpuntUrl}`);

    return fetch(volledigeEindpuntUrl, {
        method: "GET",
        headers: {
            "Accept": "application/json;odata=verbose",
        }
    })
    .then(antwoord => {
        if (!antwoord.ok) {
            // Poging om meer details uit de fout te halen
            return antwoord.json().catch(() => {
                 throw new Error(`HTTP fout ${antwoord.status} bij GET ${volledigeEindpuntUrl}`);
            }).then(foutData => {
                let foutMelding = `HTTP fout ${antwoord.status} bij GET ${volledigeEindpuntUrl}`;
                if (foutData && foutData.error && foutData.error.message && foutData.error.message.value) {
                   foutMelding += ` - ${foutData.error.message.value}`;
                }
                throw new Error(foutMelding);
            });
        }
        if (antwoord.status === 204) { // No Content
            return null;
        }
        return antwoord.json(); // Parse JSON bij succes (bv. 200 OK)
    })
    .then(data => {
        console.log(`GET-verzoek naar ${volledigeEindpuntUrl} succesvol uitgevoerd.`);
        return data; // Retourneer de data (kan null zijn)
    })
    .catch(fout => {
        console.error(`Fout tijdens GET-operatie naar ${volledigeEindpuntUrl}:`, fout);
        throw fout; // Gooi fout opnieuw door
    });
}

/**
 * Voert een POST-verzoek uit om een nieuw item aan een SharePoint-lijst toe te voegen op een specifieke site.
 * @param {string} siteUrl - De absolute URL van de doel SharePoint site.
 * @param {string} lijstNaam - De titel van de SharePoint-lijst.
 * @param {object} itemData - Een object met de kolomnamen (interne namen!) en waarden.
 * @param {string} lijstItemEntityType - De exacte ListItemEntityTypeFullName (vereist!).
 * @returns {Promise<object>} Een Promise die wordt opgelost met de data van het nieuw aangemaakte item.
 * @throws {Error} Als siteUrl of lijstItemEntityType niet is opgegeven.
 */
function voegItemToe(siteUrl, lijstNaam, itemData, lijstItemEntityType) {
     if (!siteUrl) { return Promise.reject(new Error("Site URL is vereist voor voegItemToe.")); }
     if (!lijstItemEntityType) { return Promise.reject(new Error(`ListItemEntityType is vereist voor het toevoegen aan lijst '${lijstNaam}'.`)); }

     const dataVoorVerzoek = { ...itemData, __metadata: { 'type': lijstItemEntityType } };
     const lijstItemsUrl = `${siteUrl.replace(/\/$/, '')}/_api/web/lists/getbytitle('${encodeURIComponent(lijstNaam)}')/items`;

     // Haal eerst de Request Digest voor de *doel site* op.
     return verkrijgRequestDigestVoorSite(siteUrl)
         .then(requestDigest => {
             console.log(`Voorbereiden POST-verzoek naar: ${lijstItemsUrl}`);
             return fetch(lijstItemsUrl, {
                 method: "POST",
                 headers: {
                     "Accept": "application/json;odata=verbose",
                     "Content-Type": "application/json;odata=verbose",
                     "X-RequestDigest": requestDigest
                 },
                 body: JSON.stringify(dataVoorVerzoek)
             });
         })
         .then(antwoord => {
             if (!antwoord.ok || antwoord.status !== 201) {
                  return antwoord.json().catch(() => {
                     throw new Error(`HTTP fout ${antwoord.status} bij POST naar ${lijstItemsUrl}`);
                  }).then(foutData => {
                     let foutMelding = `HTTP fout ${antwoord.status} bij POST naar lijst '${lijstNaam}' op ${siteUrl}`;
                     if (foutData && foutData.error && foutData.error.message && foutData.error.message.value) {
                        foutMelding += ` - ${foutData.error.message.value}`;
                     }
                     throw new Error(foutMelding);
                 });
             }
             console.log("POST-verzoek succesvol (Status: 201 Created).");
             return antwoord.json();
         })
         .then(data => {
             console.log("Nieuw item succesvol toegevoegd:", data.d || data);
             return data; // Retourneer het volledige antwoord (vaak met .d)
         })
         .catch(fout => {
             console.error(`Fout tijdens POST-operatie naar lijst '${lijstNaam}' op ${siteUrl}:`, fout);
             throw fout;
         });
 }


/**
 * Voert een POST-verzoek uit om een nieuw item aan een SharePoint-lijst toe te voegen via de lijst GUID.
 * @param {string} siteUrl - De absolute URL van de doel SharePoint site.
 * @param {string} listGuid - De GUID van de SharePoint-lijst.
 * @param {object} itemData - Een object met de kolomnamen (interne namen!) en waarden.
 * @param {string} lijstItemEntityType - De exacte ListItemEntityTypeFullName (vereist!).
 * @returns {Promise<object>} Een Promise die wordt opgelost met de data van het nieuw aangemaakte item.
 * @throws {Error} Als siteUrl, listGuid of lijstItemEntityType niet is opgegeven.
 */
function voegItemToeMetGuid(siteUrl, listGuid, itemData, lijstItemEntityType) {
    if (!siteUrl) { return Promise.reject(new Error("Site URL is vereist voor voegItemToeMetGuid.")); }
    if (!listGuid) { return Promise.reject(new Error("List GUID is vereist voor voegItemToeMetGuid.")); }
    if (!lijstItemEntityType) { return Promise.reject(new Error(`ListItemEntityType is vereist voor het toevoegen aan lijst met GUID '${listGuid}'.`)); }

    const dataVoorVerzoek = { ...itemData, __metadata: { 'type': lijstItemEntityType } };
    const lijstItemsUrl = `${siteUrl.replace(/\/$/, '')}/_api/web/lists(guid'${listGuid}')/items`;

    // Haal eerst de Request Digest voor de *doel site* op.
    return verkrijgRequestDigestVoorSite(siteUrl)
        .then(requestDigest => {
            console.log(`Voorbereiden POST-verzoek (via GUID) naar: ${lijstItemsUrl}`);
            return fetch(lijstItemsUrl, {
                method: "POST",
                headers: {
                    "Accept": "application/json;odata=verbose",
                    "Content-Type": "application/json;odata=verbose",
                    "X-RequestDigest": requestDigest,
                    "If-Match": "*" // Soms nodig, kan meestal geen kwaad
                },
                body: JSON.stringify(dataVoorVerzoek)
            });
        })
        .then(antwoord => {
            // Succes is meestal 201 Created, maar soms retourneert SP 200 OK of 204 No Content
            if (!antwoord.ok) {
                 return antwoord.json().catch(() => {
                    throw new Error(`HTTP fout ${antwoord.status} bij POST (GUID) naar ${lijstItemsUrl}`);
                 }).then(foutData => {
                    let foutMelding = `HTTP fout ${antwoord.status} bij POST (GUID) naar lijst '${listGuid}' op ${siteUrl}`;
                    if (foutData && foutData.error && foutData.error.message && foutData.error.message.value) {
                       foutMelding += ` - ${foutData.error.message.value}`;
                    }
                    throw new Error(foutMelding);
                });
            }
            console.log(`POST-verzoek (GUID) succesvol (Status: ${antwoord.status}).`);
            // Handel 'No Content' af
            if (antwoord.status === 204 || antwoord.headers.get("content-length") === "0") {
                return { success: true, status: antwoord.status }; // Geef een succes object terug
            }
            return antwoord.json(); // Parse JSON voor 201 of 200
        })
        .then(data => {
            console.log("Nieuw item succesvol toegevoegd (via GUID):", data.d || data);
            return data; // Retourneer het volledige antwoord
        })
        .catch(fout => {
            console.error(`Fout tijdens POST-operatie (via GUID) naar lijst '${listGuid}' op ${siteUrl}:`, fout);
            // Optioneel: Toon hier ook een notificatie?
            // showNotification(`Kon item niet toevoegen (GUID: ${listGuid}): ${fout.message}`, 'error');
            throw fout;
        });
}


/**
 * Voert een MERGE-verzoek uit om een bestaand item in een SharePoint-lijst bij te werken op een specifieke site.
 * @param {string} siteUrl - De absolute URL van de doel SharePoint site.
 * @param {string} lijstNaam - De titel van de SharePoint-lijst.
 * @param {number} itemId - De ID van het item dat bijgewerkt moet worden.
 * @param {object} itemData - Een object met de kolomnamen (interne namen!) en de *nieuwe* waarden.
 * @param {string} lijstItemEntityType - De exacte ListItemEntityTypeFullName (vereist!).
 * @returns {Promise<void>} Een Promise die wordt opgelost bij succes.
 * @throws {Error} Als siteUrl of lijstItemEntityType niet is opgegeven.
 */
function werkItemBij(siteUrl, lijstNaam, itemId, itemData, lijstItemEntityType) {
    if (!siteUrl) { return Promise.reject(new Error("Site URL is vereist voor werkItemBij.")); }
    if (!lijstItemEntityType) { return Promise.reject(new Error(`ListItemEntityType is vereist voor het bijwerken van item ${itemId} in lijst '${lijstNaam}'.`)); }

    const dataVoorVerzoek = { ...itemData, __metadata: { 'type': lijstItemEntityType } };
    const itemUrl = `${siteUrl.replace(/\/$/, '')}/_api/web/lists/getbytitle('${encodeURIComponent(lijstNaam)}')/items(${itemId})`;

    return verkrijgRequestDigestVoorSite(siteUrl)
        .then(requestDigest => {
            console.log(`Voorbereiden MERGE-verzoek naar: ${itemUrl}`);
            return fetch(itemUrl, {
                method: "POST",
                headers: {
                    "Accept": "application/json;odata=verbose",
                    "Content-Type": "application/json;odata=verbose",
                    "X-RequestDigest": requestDigest,
                    "IF-MATCH": "*", // Overschrijf altijd (of gebruik ETag)
                    "X-HTTP-Method": "MERGE"
                },
                body: JSON.stringify(dataVoorVerzoek)
            });
        })
        .then(antwoord => {
            if (!antwoord.ok || antwoord.status !== 204) { // Verwacht 204 No Content
                 return antwoord.text().then(text => { // Probeer tekst te lezen, JSON is niet gegarandeerd
                    let foutMelding = `HTTP fout ${antwoord.status} bij MERGE voor item ${itemId} op ${itemUrl}`;
                    if (text) foutMelding += ` - Response: ${text}`;
                    throw new Error(foutMelding);
                 }).catch(parseError => { // Als .text() ook faalt
                     throw new Error(`HTTP fout ${antwoord.status} bij MERGE voor item ${itemId} op ${itemUrl}. Kon response niet lezen: ${parseError.message}`);
                 });
            }
            console.log(`Item ${itemId} succesvol bijgewerkt (Status: 204 No Content).`);
            return; // Succes, geen data
        })
        .catch(fout => {
            console.error(`Fout tijdens MERGE-operatie voor item ${itemId} op ${siteUrl}:`, fout);
            throw fout;
        });
}


/**
 * Displays a temporary notification message on the screen.
 * @param {string} message - The message to display.
 * @param {string} [type='success'] - The type of notification ('success', 'error', 'info'). Affects styling.
 * @param {number} [duration=3000] - How long the notification stays visible in milliseconds.
 */
function showNotification(message, type = 'success', duration = 3000) {
    const notification = document.createElement('div');
    notification.textContent = message;
    notification.style.position = 'fixed';
    notification.style.bottom = '20px';
    notification.style.right = '20px';
    notification.style.padding = '15px 20px';
    notification.style.borderRadius = '5px';
    notification.style.color = 'white';
    notification.style.zIndex = '1000';
    notification.style.opacity = '1';
    notification.style.transition = `opacity ${duration / 2}ms ease-in-out`; // Fade out transition

    switch (type) {
        case 'error':
            notification.style.backgroundColor = '#dc3545'; // Red
            break;
        case 'info':
            notification.style.backgroundColor = '#0dcaf0'; // Blue
            break;
        case 'success':
        default:
            notification.style.backgroundColor = '#198754'; // Green
            break;
    }

    document.body.appendChild(notification);

    // Start fade out halfway through the duration
    setTimeout(() => {
        notification.style.opacity = '0';
    }, duration / 2);

    // Remove the element after the fade out completes
    setTimeout(() => {
        if (notification.parentNode) {
            notification.parentNode.removeChild(notification);
        }
    }, duration);
}

/**
 * Voert een DELETE-verzoek uit om een item uit een SharePoint-lijst te verwijderen op een specifieke site.
 * @param {string} siteUrl - De absolute URL van de doel SharePoint site.
 * @param {string} lijstNaam - De titel van de SharePoint-lijst.
 * @param {number} itemId - De ID van het item dat verwijderd moet worden.
 * @param {string} [itemName=''] - Optionele naam/titel van het item voor de notificatie.
 * @returns {Promise<void>} Een Promise die wordt opgelost bij succes.
 * @throws {Error} Als siteUrl niet is opgegeven.
 */
function verwijderItem(siteUrl, lijstNaam, itemId, itemName = '') { // Added itemName parameter
    if (!siteUrl) { return Promise.reject(new Error("Site URL is vereist voor verwijderItem.")); }

    const itemUrl = `${siteUrl.replace(/\/$/, '')}/_api/web/lists/getbytitle('${encodeURIComponent(lijstNaam)}')/items(${itemId})`;

    return verkrijgRequestDigestVoorSite(siteUrl)
        .then(requestDigest => {
            console.log(`Voorbereiden DELETE-verzoek naar: ${itemUrl}`);
            return fetch(itemUrl, {
                method: "POST",
                headers: {
                    "Accept": "application/json;odata=verbose",
                    "X-RequestDigest": requestDigest,
                    "IF-MATCH": "*",
                    "X-HTTP-Method": "DELETE"
                }
            });
        })
        .then(antwoord => {
            // Verwacht 200 OK of 204 No Content
            if (!antwoord.ok || (antwoord.status !== 200 && antwoord.status !== 204)) {
                 return antwoord.text().then(text => {
                    let foutMelding = `HTTP fout ${antwoord.status} bij DELETE voor item ${itemId} op ${itemUrl}`;
                    if (text) foutMelding += ` - Response: ${text}`;
                    throw new Error(foutMelding);
                 }).catch(parseError => {
                     throw new Error(`HTTP fout ${antwoord.status} bij DELETE voor item ${itemId} op ${itemUrl}. Kon response niet lezen: ${parseError.message}`);
                 });
            }
            console.log(`Item ${itemId} succesvol verwijderd (Status: ${antwoord.status}).`);

            // --- Notification Call Added ---
            const notificationMessage = `Item ${itemName ? `'${itemName}' (ID: ${itemId})` : `ID: ${itemId}`} succesvol verwijderd.`;
            showNotification(notificationMessage, 'success');
            // --- End Notification Call ---

            return; // Succes, geen data
        })
        .catch(fout => {
            console.error(`Fout tijdens DELETE-operatie voor item ${itemId} op ${siteUrl} in lijst '${lijstNaam}':`, fout); // Use lijstNaam variable
            // Optionally show an error notification
            showNotification(`Fout bij verwijderen item ID: ${itemId} uit lijst '${lijstNaam}'. ${fout.message}`, 'error', 5000); // Use lijstNaam variable
            throw fout;
        });
}

// Example of calling code (NOT in crudBasis.js)
/*
deleteButton.addEventListener('click', function() {
    const row = this.closest('tr'); // Or however you identify the item context
    const itemId = row.dataset.itemId; // Example: getting ID from data attribute

    if (!itemId) {
        // THIS is likely where your error originates
        console.error("Fout: Geen item ID gevonden om te verwijderen.");
        showNotification("Kon het item ID niet vinden om te verwijderen.", "error");
        return; // Stop execution
    }

    const siteUrl = "https://som.org.om.local/sites/MulderT/Onderdelen/Beoordelen";
    const listName = "NavMenu";
    const itemName = row.querySelector('.item-name-cell')?.textContent || ''; // Example: get name

    // Call the function from crudBasis.js
    verwijderItem(siteUrl, listName, parseInt(itemId, 10), itemName) // Ensure itemId is a number if needed
        .then(() => {
            console.log("Verwijdering gestart...");
            // Optionally remove the row from the UI here after success notification
        })
        .catch(error => {
            console.error("Verwijdering mislukt vanuit aanroeper:", error);
            // Error notification is handled within verwijderItem's catch block
        });
});
*/
