/**
 * Haalt data op van een SharePoint lijst API via fetch.
 * @param {string} apiUrl - De API URL van de lijst (bijv. /_api/web/lists(...)/items).
 * @returns {Promise<Array<object>>} - Een Promise die oplost met lijst items of afwijst met een fout.
 */
async function haalLijstDataOp(apiUrl) {
    console.log(`Data ophalen via: ${apiUrl}`);
    try {
        const response = await fetch(apiUrl, { // Gebruik de effectieve URL die $select/$expand bevat
            method: 'GET',
            headers: {
                'Accept': 'application/json;odata=verbose'
            }
        });

        if (!response.ok) {
            let errorDetails = response.statusText;
            try {
                 const errorData = await response.json();
                 errorDetails = errorData?.error?.message?.value || errorDetails;
            } catch (e) { /* JSON parsen mislukt, gebruik statusText */ }

            const fout = new Error(`HTTP fout: ${response.status} - ${errorDetails}`);
            fout.status = response.status;
            throw fout;
        }

        const data = await response.json();

        if (data && data.d && data.d.results) {
            return data.d.results;
        } else {
            console.warn("Onverwachte datastructuur ontvangen:", data);
            return data?.d || data || [];
        }

    } catch (error) {
         console.error(`Fout tijdens fetch naar ${apiUrl}:`, error);
         if (!error.status) {
             error.message = `Netwerkfout of probleem bij verwerken request: ${error.message}`;
         }
         throw error;
    }
}

/**
 * Genereert een HTML tabel voor een specifieke lijst configuratie.
 * @param {object} lijstConfig - De configuratie van de lijst.
 * @returns {Promise<HTMLElement>} - Promise die oplost met het gegenereerde table element.
 */
async function genereerLijstTabel(lijstConfig) {
    const tabel = document.createElement('table');
    // Styling wordt nu via extern CSS bestand (css/stijl.css) en Tailwind gedaan.
    // We voegen hier alleen basis structuur classes toe indien nodig, maar leunen op CSS.
    tabel.className = 'min-w-full divide-y divide-gray-200 rounded-lg shadow overflow-hidden mb-8'; // Basis Tailwind classes

    const thead = document.createElement('thead');
    thead.className = 'bg-gray-100'; // Tailwind class
    const tbody = document.createElement('tbody');
    tbody.className = 'bg-white divide-y divide-gray-200'; // Tailwind classes
    tabel.appendChild(thead);
    tabel.appendChild(tbody);

    const headerRij = document.createElement('tr');
    const velden = lijstConfig.velden;
    const zichtbareVelden = velden.filter(veld => !veld.verborgen);

    zichtbareVelden.forEach(veld => {
        const th = document.createElement('th');
        th.scope = 'col';
        th.className = 'px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider'; // Tailwind class
        th.textContent = veld.titel || veld.interneNaam;
        headerRij.appendChild(th);
    });
    thead.appendChild(headerRij);

    try {
        // Bouw de effectieve API URL met $select en $expand voor User velden
        let effectiveApiUrl = lijstConfig.lijstInformatie.apiUrl;
        const userFields = zichtbareVelden.filter(v => v.type === 'User');

        if (userFields.length > 0) {
            const nonUserSelectFields = zichtbareVelden
                .filter(v => v.type !== 'User')
                .map(v => v.interneNaam);
            const userSelectFields = userFields.map(v => `${v.interneNaam}/Title`); // Selecteer Title van User
            const allSelectFields = [...nonUserSelectFields, ...userSelectFields].join(',');
            const expandFields = userFields.map(v => v.interneNaam).join(',');
            const queryString = `$select=${allSelectFields}&$expand=${expandFields}`;
            const baseUrl = effectiveApiUrl.split('?')[0];
            effectiveApiUrl = `${baseUrl}?${queryString}`;
            console.log(`Aangepaste URL voor User velden (${lijstConfig.lijstInformatie.naam}): ${effectiveApiUrl}`);
        }


        const lijstItems = await haalLijstDataOp(effectiveApiUrl); // Gebruik de (mogelijk aangepaste) URL

        if (!lijstItems || lijstItems.length === 0) {
            const infoRij = document.createElement('tr');
            infoRij.className = 'info-rij'; // Class uit stijl.css
            const cell = document.createElement('td');
            cell.colSpan = zichtbareVelden.length;
            cell.className = 'px-6 py-4 whitespace-nowrap text-sm'; // Tailwind class
            cell.textContent = `Geen items gevonden in lijst "${lijstConfig.lijstInformatie.naam}".`;
            infoRij.appendChild(cell);
            tbody.appendChild(infoRij);
        } else {
            lijstItems.forEach(item => {
                const dataRij = document.createElement('tr');
                zichtbareVelden.forEach(veld => {
                    const td = document.createElement('td');
                    td.className = 'px-6 py-4 whitespace-nowrap text-sm text-gray-700'; // Tailwind class
                    let waarde = item[veld.interneNaam] ?? '(leeg)';

                    // Standaard formattering
                    if (veld.type === 'DateTime' && waarde !== '(leeg)') {
                         try {
                             const datum = new Date(waarde);
                             waarde = !isNaN(datum) ? datum.toLocaleDateString('nl-NL') : `Ongeldige datum: ${waarde}`;
                         } catch (e) { waarde = `Datumfout: ${waarde}`; }
                    } else if (veld.type === 'Boolean') {
                         waarde = (waarde === true || waarde === 'true' || waarde === 1 || waarde === '1') ? 'Ja' : 'Nee';
                    } else if (veld.type === 'User' && typeof waarde === 'object' && waarde !== null) {
                        waarde = waarde.Title || '(Gebruiker naam niet gevonden)';
                    } else if (veld.type === 'Choice') {
                        // Standaard weergave is prima
                    }

                    // Maak cel leeg voor we content toevoegen
                    td.innerHTML = '';

                    // Specifieke weergave voor Kleur (als interneNaam 'Kleur' is en waarde een hex code)
                    if (veld.interneNaam === 'Kleur' && typeof waarde === 'string' && waarde.startsWith('#')) {
                        const kleurBlokje = document.createElement('span');
                        kleurBlokje.style.display = 'inline-block';
                        kleurBlokje.style.width = '1em';
                        kleurBlokje.style.height = '1em';
                        kleurBlokje.style.backgroundColor = waarde;
                        kleurBlokje.style.marginRight = '0.5em';
                        kleurBlokje.style.border = '1px solid #ccc';
                        kleurBlokje.style.verticalAlign = 'middle';
                        td.appendChild(kleurBlokje);
                    }

                    // Voeg de tekstuele waarde toe
                    const tekstWaarde = document.createTextNode(String(waarde));
                    td.appendChild(tekstWaarde);

                    td.dataset.interneNaam = veld.interneNaam;
                    dataRij.appendChild(td);
                });
                tbody.appendChild(dataRij);
            });
        }

    } catch (error) {
        const foutRij = document.createElement('tr');
        foutRij.className = 'fout-rij'; // Class uit stijl.css
        const cell = document.createElement('td');
        cell.colSpan = zichtbareVelden.length;
        cell.className = 'px-6 py-4 whitespace-nowrap text-sm'; // Tailwind class
        let foutmelding = `Kon data niet laden voor lijst "${lijstConfig.lijstInformatie.naam}". (${error.message || 'Onbekende fout'})`;
        if (error.status) {
            foutmelding += ` (Status: ${error.status})`;
        }
        cell.textContent = foutmelding;
        foutRij.appendChild(cell);
        tbody.appendChild(foutRij);
    }

    return tabel;
}


/**
 * Initialiseert de pagina door tabellen te genereren voor elke lijst in de configuratie.
 */
async function initialiseerPagina() {
    // Controleer of de configuratie variabele bestaat (uit config.js)
    if (typeof configuratie === 'undefined' || !configuratie || !configuratie.lijsten) {
        console.error('Configuratie object niet gevonden of leeg. Zorg dat js/config.js correct geladen is vóór js/initialiseren.js.');
        const container = document.getElementById('lijstenContainer');
        if(container) {
            container.innerHTML = '<p class="text-center text-red-600 font-semibold py-4">Fout: Configuratie niet geladen.</p>';
        }
        return;
    }

    const lijstenContainer = document.getElementById('lijstenContainer');
    if (!lijstenContainer) {
        console.error('Container element "lijstenContainer" niet gevonden!');
        return;
    }
    lijstenContainer.innerHTML = '<p class="text-center text-gray-500 italic py-4">Lijsten laden...</p>'; // Tailwind class

    const lijstPromises = [];
    for (const lijst of configuratie.lijsten) {
        const lijstTitel = document.createElement('h2');
        lijstTitel.textContent = lijst.lijstInformatie.naam || 'Onbekende Lijst';
        lijstTitel.className = 'text-xl font-semibold mb-3 text-gray-800'; // Tailwind class

         const tabelPromise = genereerLijstTabel(lijst).then(tabelElement => {
             return { titel: lijstTitel, tabel: tabelElement };
         }).catch(error => {
             console.error(`Fout bij genereren tabel voor ${lijst.lijstInformatie.naam}:`, error);
             const errorPlaceholder = document.createElement('div');
             // Gebruik Tailwind classes voor styling van de foutmelding container
             errorPlaceholder.className = 'mb-8 p-4 border border-red-300 bg-red-50 rounded-lg text-red-700';
             errorPlaceholder.textContent = `Kon tabel voor "${lijst.lijstInformatie.naam}" niet volledig genereren. Fout: ${error.message}`;
             return { titel: lijstTitel, tabel: errorPlaceholder };
         });
         lijstPromises.push(tabelPromise);
    }

     try {
         const resultaten = await Promise.all(lijstPromises);
         lijstenContainer.innerHTML = ''; // Maak container leeg
         resultaten.forEach(resultaat => {
             lijstenContainer.appendChild(resultaat.titel);
             lijstenContainer.appendChild(resultaat.tabel);
         });
     } catch (overallError) {
         console.error("Algemene fout tijdens initialisatie:", overallError);
         lijstenContainer.innerHTML = '<p class="text-center text-red-600 font-semibold py-4">Er is een fout opgetreden bij het laden van de pagina.</p>'; // Tailwind classes
     }
}

// Wacht tot de DOM volledig geladen is voordat we het script uitvoeren
// Belangrijk: Zorg ervoor dat config.js al geladen is op dit moment.
// Het gebruik van 'defer' op het initialiseren.js script in HTML helpt hierbij.
document.addEventListener('DOMContentLoaded', initialiseerPagina);
