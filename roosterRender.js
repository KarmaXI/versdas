// Functies voor het renderen van het rooster

// Afhankelijkheden: crudBasis.js, configLijst.js (wordt globaal verwacht)

console.log("roosterRender.js geladen.");

/**
 * Globale variabelen voor rooster data en status.
 */
let roosterStartDate = new Date();
let roosterViewType = 'maand'; // 'week' of 'maand'
let alleMedewerkersData = [];
let alleVerlofData = [];
let alleVerlofredenenData = [];
let alleUrenData = []; // Voor toekomstig gebruik
let teamFilter = 'alle';
let zoekTerm = '';
let verlofredenenMap = {}; // Voor snelle lookup van kleuren

/**
 * Initialiseert het rooster door data op te halen en de eerste weergave te renderen.
 * @param {Date} initDate - De startdatum voor de eerste weergave.
 * @param {string} initView - De initiële weergave ('week' of 'maand').
 */
async function initRooster(initDate = new Date(), initView = 'maand') {
    roosterStartDate = initDate;
    roosterViewType = initView;
    updatePeriodeWeergave(); // Update de periode tekst
    updateActieveWeergaveKnop(); // Markeer de actieve knop

    try {
        showLoadingIndicator(true); // Toon laadindicator

        // Haal alle benodigde data parallel op
        const [medewerkers, verlof, verlofredenen, uren] = await Promise.all([
            haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Medewerkers.guid}')/items?$filter=Actief eq 1&$select=Id,Title,Naam,Team,Username`), // Filter op Actief = true
            haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Verlof.guid}')/items?$select=Id,MedewerkerID,StartDatum,EindDatum,Reden`),
            haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Verlofredenen.guid}')/items?$select=Id,Title,Kleur,Naam`), // Haal ook Naam op voor legenda
            haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.UrenPerWeek.guid}')/items?$select=*`) // Haal alle uren data op
        ]);

        alleMedewerkersData = medewerkers?.d?.results || [];
        alleVerlofData = verlof?.d?.results || [];
        alleVerlofredenenData = verlofredenen?.d?.results || [];
        alleUrenData = uren?.d?.results || []; // Sla uren data op

        // Maak een map voor snelle toegang tot verlofreden kleuren en namen
        verlofredenenMap = alleVerlofredenenData.reduce((acc, reden) => {
            // Gebruik Title als key, want dat is wat in Verlof.Reden staat
            acc[reden.Title] = { kleur: reden.Kleur, naam: reden.Naam };
            return acc;
        }, {});

        console.log("Medewerkers data:", alleMedewerkersData);
        console.log("Verlof data:", alleVerlofData);
        console.log("Verlofredenen data:", alleVerlofredenenData);
        console.log("Uren per week data:", alleUrenData);
        console.log("Verlofredenen map:", verlofredenenMap);

        renderRooster(); // Render het rooster met de opgehaalde data
        renderLegenda(); // Render de legenda

    } catch (error) {
        console.error("Fout bij initialiseren rooster:", error);
        showNotification(`Fout bij laden rooster data: ${error.message}`, 'error', 5000);
        document.getElementById('roosterContainer').innerHTML = `<div class="p-4 text-center text-red-500">Kon rooster data niet laden. Controleer de console voor details.</div>`;
    } finally {
        showLoadingIndicator(false); // Verberg laadindicator
    }
}

/**
 * Toont of verbergt een eenvoudige laadindicator.
 * @param {boolean} show - True om te tonen, false om te verbergen.
 */
function showLoadingIndicator(show) {
    const container = document.getElementById('roosterContainer');
    if (!container) return;

    let indicator = container.querySelector('.loading-indicator');
    if (show) {
        if (!indicator) {
            indicator = document.createElement('div');
            indicator.className = 'loading-indicator absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-20';
            indicator.innerHTML = `<div class="text-blue-500 text-lg font-semibold">Rooster laden... <i class="fas fa-spinner fa-spin ml-2"></i></div>`;
            container.style.position = 'relative'; // Ensure container can host absolute positioned element
            container.appendChild(indicator);
        }
        indicator.style.display = 'flex';
    } else {
        if (indicator) {
            indicator.style.display = 'none';
        }
    }
}


/**
 * Rendert het volledige rooster HTML.
 */
function renderRooster() {
    const container = document.getElementById('roosterContainer');
    if (!container) {
        console.error("Rooster container niet gevonden!");
        return;
    }

    const { startDatumWeergave, eindDatumWeergave } = getPeriodeGrenzen(roosterStartDate, roosterViewType);
    const dagenInPeriode = getDagenArray(startDatumWeergave, eindDatumWeergave);

    // Filter medewerkers op basis van team en zoekterm
    const gefilterdeMedewerkers = alleMedewerkersData.filter(m => {
        const teamMatch = teamFilter === 'alle' || m.Team === teamFilter;
        const naamMatch = !zoekTerm || (m.Naam && m.Naam.toLowerCase().includes(zoekTerm.toLowerCase()));
        return teamMatch && naamMatch;
    });

    // Sorteer medewerkers op Naam
    gefilterdeMedewerkers.sort((a, b) => (a.Naam || '').localeCompare(b.Naam || ''));

    // Groepeer medewerkers per team
    const medewerkersPerTeam = gefilterdeMedewerkers.reduce((acc, medewerker) => {
        const team = medewerker.Team || 'Geen team';
        if (!acc[team]) {
            acc[team] = [];
        }
        acc[team].push(medewerker);
        return acc;
    }, {});

    // Sorteer teams (optioneel, bv. alfabetisch)
    const gesorteerdeTeams = Object.keys(medewerkersPerTeam).sort();


    let html = `<div class="rooster-grid" style="grid-template-columns: 180px repeat(${dagenInPeriode.length}, minmax(35px, 1fr));">`; // Vaste breedte voor naam

    // --- Header Row ---
    html += renderHeader(dagenInPeriode);

    // --- Medewerker Rows ---
    if (gefilterdeMedewerkers.length === 0) {
         html += `<div class="col-span-${dagenInPeriode.length + 1} p-4 text-center text-gray-500">Geen medewerkers gevonden die voldoen aan de criteria.</div>`;
    } else {
        gesorteerdeTeams.forEach(teamNaam => {
             // Team Header Row (optioneel)
             if (teamFilter === 'alle' && gesorteerdeTeams.length > 1) { // Toon alleen als meerdere teams zichtbaar zijn
                 html += `<div class="rooster-header rooster-team-header bg-gray-100 font-semibold p-2 pl-2 text-left" style="grid-column: 1 / -1; position: sticky; top: 33px; z-index: 15;">${teamNaam}</div>`; // Sticky onder de datum header
             }

             medewerkersPerTeam[teamNaam].forEach(medewerker => {
                 html += renderMedewerkerRow(medewerker, alleVerlofData, dagenInPeriode);
             });
        });
    }


    html += `</div>`; // Sluit rooster-grid

    container.innerHTML = html;
    console.log("Rooster gerenderd.");
}

/**
 * Rendert de header rij van het rooster.
 * @param {Date[]} dagenInPeriode - Array van datums die getoond moeten worden.
 * @returns {string} HTML string voor de header.
 */
function renderHeader(dagenInPeriode) {
    let headerHtml = `<div class="rooster-header rooster-header-medewerker" style="position: sticky; top: 0; z-index: 20;">Medewerker</div>`; // Sticky header cel
    dagenInPeriode.forEach(dag => {
        const dagNaam = dagenNamenKort[dag.getDay()];
        const dagNummer = dag.getDate();
        const isWeekend = dag.getDay() === 0 || dag.getDay() === 6;
        const isVandaag = dag.toISOString().split('T')[0] === vandaagString;
        let headerClasses = "rooster-header rooster-dag-header";
        if (isWeekend) headerClasses += " bg-gray-200 text-gray-500"; // Stijl weekend
        if (isVandaag) headerClasses += " border-2 border-blue-500 font-bold"; // Stijl vandaag

        headerHtml += `<div class="${headerClasses}" style="position: sticky; top: 0; z-index: 15;"> <!-- Sticky datum header -->
                         <span class="block text-xs">${dagNaam}</span>
                         <span class="block text-lg">${dagNummer}</span>
                       </div>`;
    });
    return headerHtml;
}

/**
 * Rendert een rij voor een specifieke medewerker.
 * @param {object} medewerker - Het medewerker object uit de data.
 * @param {object[]} alleVerlofItems - Array met alle verlof items.
 * @param {Date[]} dagenInPeriode - Array van datums die getoond moeten worden.
 * @returns {string} HTML string voor de medewerker rij.
 */
function renderMedewerkerRow(medewerker, alleVerlofItems, dagenInPeriode) {
    // Zoek verlof specifiek voor deze medewerker (match op Username of MedewerkerID)
    const medewerkerVerlof = alleVerlofItems.filter(v => v.MedewerkerID === medewerker.Username); // Gebruik Username uit Medewerkers lijst

    let rowHtml = `<div class="rooster-cel rooster-cel-medewerker">${medewerker.Naam || medewerker.Title || 'Onbekend'}</div>`; // Naam cel

    dagenInPeriode.forEach(dag => {
        const dagString = dag.toISOString().split('T')[0];
        let celKleur = '';
        let celTooltip = '';
        const isWeekend = dag.getDay() === 0 || dag.getDay() === 6;

        // Zoek verlof dat op deze dag valt
        const verlofOpDag = medewerkerVerlof.find(v => {
            // Normaliseer datums naar middernacht UTC voor betrouwbare vergelijking
            const startVerlof = new Date(v.StartDatum);
            startVerlof.setUTCHours(0, 0, 0, 0);
            const eindVerlof = new Date(v.EindDatum);
            eindVerlof.setUTCHours(0, 0, 0, 0);
            const huidigeDag = new Date(dag);
            huidigeDag.setUTCHours(0, 0, 0, 0);

            return huidigeDag >= startVerlof && huidigeDag <= eindVerlof;
        });

        if (verlofOpDag) {
            const redenInfo = verlofredenenMap[verlofOpDag.Reden] || { kleur: '#cccccc', naam: 'Onbekend' }; // Fallback kleur/naam
            celKleur = redenInfo.kleur || '#cccccc'; // Fallback als kleur leeg is
            celTooltip = `${redenInfo.naam || verlofOpDag.Reden}`; // Toon reden naam of titel
        }

        let celClasses = "rooster-cel";
        if (isWeekend && !verlofOpDag) { // Geef weekenden een lichte achtergrond, tenzij er verlof is
            celClasses += " bg-gray-100";
        }
        if (dag.toISOString().split('T')[0] === vandaagString) {
             celClasses += " border-l-2 border-r-2 border-blue-500"; // Markeer vandaag kolom
             if (dag.getDay() === 1) celClasses += " border-l-2"; // Maandag
             if (dag.getDay() === 0) celClasses += " border-r-2"; // Zondag
        }


        rowHtml += `<div class="${celClasses}" style="background-color: ${celKleur};" ${celTooltip ? `title="${celTooltip}"` : ''}></div>`;
    });

    return rowHtml;
}

/**
 * Rendert de legenda op basis van de Verlofredenen lijst.
 */
function renderLegenda() {
    const legendaContainer = document.querySelector('details > div'); // Zoek de div binnen de details tag
    if (!legendaContainer || !alleVerlofredenenData || alleVerlofredenenData.length === 0) {
        legendaContainer.innerHTML = '<p class="text-gray-500">Geen verlofredenen gevonden om weer te geven.</p>';
        return;
    }

    let legendaHtml = '<div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">';
    alleVerlofredenenData.forEach(reden => {
        const kleur = reden.Kleur || '#cccccc'; // Fallback kleur
        const naam = reden.Naam || reden.Title; // Gebruik Naam, fallback naar Title
        legendaHtml += `
            <div class="flex items-center gap-2">
                <span class="inline-block w-4 h-4 rounded border border-gray-300" style="background-color: ${kleur};"></span>
                <span>${naam}</span>
            </div>
        `;
    });
    legendaHtml += '</div>';
    legendaContainer.innerHTML = legendaHtml;
}


/**
 * Berekent de start- en einddatum voor de huidige weergave.
 * @param {Date} date - De referentiedatum.
 * @param {string} view - 'week' of 'maand'.
 * @returns {{startDatumWeergave: Date, eindDatumWeergave: Date}}
 */
function getPeriodeGrenzen(date, view) {
    let startDatumWeergave = new Date(date);
    let eindDatumWeergave = new Date(date);

    if (view === 'week') {
        const dagVanWeek = startDatumWeergave.getDay(); // 0=Zondag, 1=Maandag,...
        const diff = startDatumWeergave.getDate() - dagVanWeek + (dagVanWeek === 0 ? -6 : 1); // Start op maandag
        startDatumWeergave.setDate(diff);
        eindDatumWeergave = new Date(startDatumWeergave);
        eindDatumWeergave.setDate(startDatumWeergave.getDate() + 6); // Eindig op zondag
    } else { // Maandweergave
        startDatumWeergave.setDate(1); // Start op de 1e van de maand
        eindDatumWeergave.setMonth(eindDatumWeergave.getMonth() + 1);
        eindDatumWeergave.setDate(0); // Eindig op de laatste dag van de maand
    }
     // Zet tijd op 00:00:00 om tijdzone problemen te minimaliseren
     startDatumWeergave.setHours(0, 0, 0, 0);
     eindDatumWeergave.setHours(0, 0, 0, 0);

    return { startDatumWeergave, eindDatumWeergave };
}

/**
 * Genereert een array van datums tussen start en eind.
 * @param {Date} start - Startdatum.
 * @param {Date} end - Einddatum.
 * @returns {Date[]} Array van datums.
 */
function getDagenArray(start, end) {
    const arr = [];
    let dt = new Date(start);
    // Belangrijk: Vergelijk alleen de datumdelen om oneindige loops te voorkomen
    while (dt.setHours(0,0,0,0) <= end.setHours(0,0,0,0)) {
        arr.push(new Date(dt));
        dt.setDate(dt.getDate() + 1);
    }
    return arr;
}

/**
 * Update de tekst die de huidige periode aangeeft.
 */
function updatePeriodeWeergave() {
    const periodeElem = document.getElementById('huidigePeriode');
    if (!periodeElem) return;

    const { startDatumWeergave, eindDatumWeergave } = getPeriodeGrenzen(roosterStartDate, roosterViewType);

    if (roosterViewType === 'week') {
        const startMaand = maandenNamen[startDatumWeergave.getMonth()];
        const eindMaand = maandenNamen[eindDatumWeergave.getMonth()];
        periodeElem.textContent = `${startDatumWeergave.getDate()} ${startMaand} - ${eindDatumWeergave.getDate()} ${eindMaand} ${eindDatumWeergave.getFullYear()}`;
    } else { // Maand
        periodeElem.textContent = `${maandenNamen[roosterStartDate.getMonth()]} ${roosterStartDate.getFullYear()}`;
    }
}

/**
 * Wijzigt de weergave (week/maand) en rendert opnieuw.
 * @param {string} nieuweWeergave - 'week' of 'maand'.
 */
function wijzigWeergave(nieuweWeergave) {
    if (nieuweWeergave !== roosterViewType) {
        roosterViewType = nieuweWeergave;
        updateActieveWeergaveKnop();
        updatePeriodeWeergave();
        renderRooster(); // Render opnieuw met dezelfde data maar andere view
    }
}

/**
 * Gaat naar de vorige periode (week/maand).
 */
function gaNaarVorigePeriode() {
    if (roosterViewType === 'week') {
        roosterStartDate.setDate(roosterStartDate.getDate() - 7);
    } else {
        roosterStartDate.setMonth(roosterStartDate.getMonth() - 1);
    }
    updatePeriodeWeergave();
    renderRooster();
}

/**
 * Gaat naar de volgende periode (week/maand).
 */
function gaNaarVolgendePeriode() {
    if (roosterViewType === 'week') {
        roosterStartDate.setDate(roosterStartDate.getDate() + 7);
    } else {
        roosterStartDate.setMonth(roosterStartDate.getMonth() + 1);
    }
    updatePeriodeWeergave();
    renderRooster();
}

/**
 * Gaat naar de periode die vandaag bevat.
 */
function gaNaarVandaag() {
    roosterStartDate = new Date(); // Reset naar vandaag
    updatePeriodeWeergave();
    renderRooster();
}

/**
 * Update de styling van de actieve weergaveknop.
 */
function updateActieveWeergaveKnop() {
    document.getElementById('weekKnop')?.classList.toggle('actief-knop', roosterViewType === 'week');
    document.getElementById('maandKnop')?.classList.toggle('actief-knop', roosterViewType === 'maand');
}

/**
 * Filtert het rooster op team.
 * @param {string} team - De geselecteerde teamnaam of 'alle'.
 */
function filterOpTeam(team) {
    teamFilter = team;
    renderRooster(); // Render opnieuw met filter
}

/**
 * Filtert het rooster op zoekterm (medewerker naam).
 * @param {string} term - De ingevoerde zoekterm.
 */
function filterOpZoekterm(term) {
    zoekTerm = term.trim();
    renderRooster(); // Render opnieuw met filter
}

// --- Maak functies globaal beschikbaar ---
// Attach functions needed by ambi.aspx event listeners to the window object
window.initRooster = initRooster;
window.gaNaarVorigePeriode = gaNaarVorigePeriode;
window.gaNaarVolgendePeriode = gaNaarVolgendePeriode;
window.gaNaarVandaag = gaNaarVandaag;
window.wijzigWeergave = wijzigWeergave;
window.filterOpTeam = filterOpTeam;
window.filterOpZoekterm = filterOpZoekterm;
// showLoadingIndicator is likely only used internally, so no need to expose it globally.
// renderRooster, renderHeader, renderMedewerkerRow, renderLegenda are also likely internal.

// Event listeners voor UI elementen worden toegevoegd in ambi.aspx
console.log("Functies in roosterRender.js zijn klaar voor gebruik en globaal beschikbaar gemaakt.");