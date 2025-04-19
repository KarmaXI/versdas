<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teamverlofrooster</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <!-- Load config first -->
    <script src="configLijst.js"></script>
    <!-- Then CRUD and Render logic -->
    <script src="crudBasis.js"></script>
    <script src="roosterRender.js"></script>
    <style>
        /* ... (alle CSS stijlen blijven ongewijzigd) ... */
         body { font-family: 'Inter', sans-serif; background-color: #f7fafc; }
        html, body { overflow-x: hidden; width: 100%; }
        .rooster-grid { display: grid; overflow-x: auto; }
        .rooster-header, .rooster-cel { padding: 0.5rem; text-align: center; border: 1px solid #e2e8f0; font-size: 0.75rem; white-space: nowrap; min-height: 30px; /* Ensure cells have height */ }
        .rooster-header-medewerker, .rooster-cel-medewerker { position: sticky; left: 0; background-color: #fff; z-index: 10; text-align: left; font-weight: 600; border-right-width: 2px; min-width: 180px; /* Match grid template */ }
        .rooster-cel-medewerker { font-weight: normal; }
        .rooster-dag-header { font-weight: 600; background-color: #f8f9fa; }
        .rooster-team-header { grid-column: 1 / -1; position: sticky; top: 33px; /* Adjust based on date header height */ z-index: 15; background-color: #f3f4f6; font-weight: 600; padding: 0.25rem 0.5rem; text-align: left; border-bottom: 1px solid #e2e8f0; }
        .actief-knop { font-weight: bold; background-color: #a0aec0; color: white; } /* Adjusted active style */
        .fab { position: fixed; bottom: 2rem; right: 2rem; width: 3.5rem; height: 3.5rem; border-radius: 9999px; display: flex; justify-content: center; align-items: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; animation: fab-pulse 2s infinite ease-in-out; z-index: 40; }
        .fab:hover { transform: scale(1.1); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); animation-play-state: paused; }
        @keyframes fab-pulse { 0% { transform: scale(1); } 50% { transform: scale(1.05); } 100% { transform: scale(1); } }
        .dropdown-menu { position: absolute; background-color: white; border: 1px solid #e2e8f0; border-radius: 0.375rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); z-index: 50; margin-top: 0.25rem; min-width: 200px; display: none; }
        .dropdown-menu.visible { display: block; }
        .dropdown-item { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; font-size: 0.875rem; color: #374151; text-decoration: none; white-space: nowrap; cursor: pointer; }
        .dropdown-item:hover { background-color: #f3f4f6; }
        .dropdown-item .fa-fw { width: 1.25em; text-align: center; }
        #userMenuDropdown { top: 100%; right: 0; }
        #adminMenuDropdown { top: 100%; left: 0; }
        #userProfilePic.placeholder { display: flex; justify-content: center; align-items: center; font-weight: bold; color: #4b5563; background-color: #e5e7eb; }
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: none; justify-content: center; align-items: center; z-index: 100; }
        .modal-container { background-color: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); width: 80vw; height: 80vh; max-width: 1000px; max-height: 700px; display: flex; flex-direction: column; overflow: hidden; }
        .modal-header { font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; border-bottom: 1px solid #e5e7eb; padding-bottom: 0.5rem; }
        .modal-body { flex-grow: 1; overflow-y: auto; padding: 1rem 0; }
        .modal-footer { border-top: 1px solid #e5e7eb; padding-top: 1rem; display: flex; justify-content: flex-end; gap: 0.5rem; /* Add gap between buttons */ }
        .modal-overlay.modal-zichtbaar { display: flex; }
        .registratie-melding {
            background-color: #8B0000; /* Bordeaux rood */
            color: white;
            padding: 0.75rem 1rem;
            border-radius: 0.375rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            display: none; /* Standaard verborgen */
            align-items: center;            gap: 0.5rem;
        }
        .registratie-melding i {
            font-size: 1.1rem;
        }
        .registratie-melding button {
            background-color: rgba(255, 255, 255, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.5);
            padding: 0.25rem 0.75rem;
            border-radius: 0.25rem;
            font-weight: 500;
            transition: background-color 0.2s;
        }
        .registratie-melding button:hover {
            background-color: rgba(255, 255, 255, 0.4);
        }
        /* Stijl voor read-only input in modal */
        .readonly-input {
            background-color: #f3f4f6; /* Lichtgrijs */
            cursor: not-allowed;
        }
        /* Loading indicator style */
        .loading-indicator { /* Added */
             position: absolute;
             inset: 0;
             background-color: rgba(255, 255, 255, 0.75);
             display: flex;
             align-items: center;
             justify-content: center;
             z-index: 20;
        }
    </style>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="p-4">

    <div class="container mx-auto bg-white p-4 rounded-lg shadow-md border border-gray-200" style="width: 99%;">
        <!-- Placeholder voor registratiemelding -->
        <div id="registratieMeldingPlaceholder" class="registratie-melding">
            <i class="fas fa-exclamation-triangle"></i>
            <span id="registratieMeldingTekst">U bent nog niet geregistreerd als medewerker. Registreer u nu om het rooster te gebruiken.</span>
            <button id="registreerNuKnop" class="ml-auto">Registreer nu</button>
        </div>

        <div class="flex justify-between items-center mb-4 pb-3 border-b border-gray-200">
            <h1 class="text-xl font-bold text-gray-800">Teamverlofrooster</h1>
             <div id="adminMenuContainer" class="relative">
                 <button id="adminMenuButton" class="flex items-center gap-1 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-1 px-3 rounded-md shadow text-sm transition duration-150 ease-in-out">
                    <i class="fa fa-cogs"></i> Beheer
                 </button>
                 <div id="adminMenuDropdown" class="dropdown-menu">
                    <a href="#" class="dropdown-item" data-action="beheer-medewerkers" data-modal-titel="Medewerkers beheren"><i class="fas fa-users fa-fw text-gray-500"></i> Medewerkers beheren</a>
                    <a href="#" class="dropdown-item" data-action="beheer-teams" data-modal-titel="Teams beheren"><i class="fas fa-users-cog fa-fw text-gray-500"></i> Teams beheren</a>
                    <a href="#" class="dropdown-item" data-action="beheer-senioren" data-modal-titel="Senioren beheren"><i class="fas fa-user-tie fa-fw text-gray-500"></i> Senioren beheren</a>
                    <a href="#" class="dropdown-item" data-action="beheer-teamleiders" data-modal-titel="Teamleiders beheren"><i class="fas fa-user-shield fa-fw text-gray-500"></i> Teamleiders beheren</a>
                    <a href="#" class="dropdown-item" data-action="beheer-dagcategorien" data-modal-titel="Dag categorien beheren"><i class="fas fa-tags fa-fw text-gray-500"></i> Dag categorien beheren</a>
                 </div>
            </div>
        </div>
        <div class="flex flex-wrap justify-between items-center mb-4 gap-3 bg-gray-50 p-3 rounded-md border border-gray-200">
           <div class="flex items-center gap-1 flex-wrap">
                <button id="vorigeKnop" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded-md shadow text-sm transition duration-150 ease-in-out">&lt;</button>
                <span id="huidigePeriode" class="text-base font-semibold text-gray-700 px-2">Laden...</span> <button id="volgendeKnop" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded-md shadow text-sm transition duration-150 ease-in-out">&gt;</button>
                <button id="vandaagKnop" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-1 px-3 rounded-md shadow text-sm transition duration-150 ease-in-out ml-2">Vandaag</button>
                <button id="weekKnop" class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-1 px-3 rounded-md shadow text-sm transition duration-150 ease-in-out ml-2">Week</button>
                <button id="maandKnop" class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-1 px-3 rounded-md shadow text-sm transition duration-150 ease-in-out">Maand</button>
            </div>
            <div class="flex items-center gap-2 flex-wrap">
                 <div class="relative">
                     <input type="text" id="zoekMedewerkerInput" placeholder="Zoek medewerker..." class="border border-gray-300 rounded-md py-1 px-2 text-sm pl-7 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500">
                     <i class="fa fa-search absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400 text-xs"></i>
                 </div>
                 <select id="teamFilterSelect" class="border border-gray-300 rounded-md py-1 px-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500">
                     <option value="alle">Alle teams</option>
                     <!-- Team opties worden dynamisch geladen -->
                 </select>
            </div>
            <div id="userMenuContainer" class="relative flex items-center gap-2 text-sm text-gray-600">
                 <img id="userProfilePic" src="" alt="Profielfoto" class="w-8 h-8 rounded-full bg-gray-300 border border-gray-400 object-cover placeholder"> <!-- Added placeholder class -->
                 <div class="hidden sm:flex flex-col text-xs">
                    <span id="userFirstName" class="font-medium">Laden...</span>
                    <span id="userLastName"></span>
                 </div>
                 <button id="userMenuButton" class="p-1 rounded-full hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-blue-500">
                    <i class="fa fa-cog fa-lg text-gray-500"></i>
                 </button>
                 <div id="userMenuDropdown" class="dropdown-menu">
                    <a href="#" class="dropdown-item"><i class="fas fa-sliders-h fa-fw text-gray-500"></i> Instellingen</a>
                    <a href="#" class="dropdown-item"><i class="fas fa-user-edit fa-fw text-gray-500"></i> Mijn profiel</a>
                    <a href="#" class="dropdown-item"><i class="fas fa-question-circle fa-fw text-gray-500"></i> Help</a>
                 </div>
             </div>
        </div>
        <details class="mb-4 border rounded-md overflow-hidden">
             <summary class="bg-gray-100 p-2 cursor-pointer hover:bg-gray-200 text-sm font-medium text-gray-700 flex justify-between items-center">Legenda <span class="text-xs text-gray-500">▼</span></summary>
             <div class="p-3 border-t border-gray-200 text-sm text-gray-600">Legenda laden...</div> <!-- Placeholder -->
        </details>

        <div id="roosterContainer" class="border border-gray-300 rounded-md overflow-hidden relative"> <!-- Added relative positioning -->
            <div class="rooster-grid">
                <!-- Rooster wordt hier dynamisch gegenereerd -->
                <div class="p-4 text-center text-gray-500">Rooster laden...</div>
             </div>
             <!-- Loading indicator placeholder -->
        </div>
    </div>

    <button id="voegVerlofToeKnop" class="fab bg-blue-600 hover:bg-blue-700 text-white text-2xl" data-modal-titel="Nieuwe Verlofaanvraag">
        +
    </button>

    <div id="generiekeModalOverlay" class="modal-overlay">
        <div class="modal-container">
            <div id="modalTitel" class="modal-header">Modal Titel</div>
            <div id="modalBody" class="modal-body">Placeholder modal inhoud...</div>
            <div id="modalFooter" class="modal-footer">
                <!-- Buttons worden dynamisch toegevoegd -->
                <button id="modalAnnuleerKnop" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-md shadow text-sm transition duration-150 ease-in-out">Annuleren</button>
            </div>
        </div>
    </div>
    <script>
        // Globale variabelen en constanten
        const modalOverlay = document.getElementById('generiekeModalOverlay');
        const modalTitelElem = document.getElementById('modalTitel');
        const modalBodyElem = document.getElementById('modalBody');
        const modalFooterElem = document.getElementById('modalFooter');
        const modalAnnuleerKnop = document.getElementById('modalAnnuleerKnop');
        const vandaagString = new Date().toISOString().split('T')[0]; // Herbruikbaar

        // SharePoint context URLs (Zorg dat deze correct zijn!)
        const rootSiteUrl = "https://som.org.om.local/sites/MulderT"; // Voor gebruiker info
        const verlofSiteUrl = "https://som.org.om.local/sites/MulderT/CustomPW/Verlof"; // Voor lijst data

        // Globale variabelen voor gebruikersinfo en status
        let huidigeGebruikerInfo = null;
        let isGebruikerGeregistreerd = false;
        let medewerkerListItemEntityType = null; // Wordt later opgehaald
        let verlofListItemEntityType = null; // Wordt later opgehaald

        // --- Hulpfuncties voor Modals ---

        function openModal(titel, inhoudHtml, footerButtonsHtml = '') {
            modalTitelElem.textContent = titel;
            modalBodyElem.innerHTML = inhoudHtml;

            // Reset footer, voeg Annuleer knop en eventuele extra knoppen toe
            modalFooterElem.innerHTML = ''; // Leegmaken
            modalFooterElem.innerHTML += footerButtonsHtml; // Voeg nieuwe knoppen toe
            // Voeg standaard Annuleer knop toe (tenzij al aanwezig)
            if (!modalFooterElem.querySelector('#modalAnnuleerKnop')) {
                 const annuleerBtn = document.createElement('button');
                 annuleerBtn.id = 'modalAnnuleerKnop';
                 annuleerBtn.className = 'bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-md shadow text-sm transition duration-150 ease-in-out';
                 annuleerBtn.textContent = 'Annuleren';
                 annuleerBtn.onclick = closeModal; // Koppel sluitfunctie
                 modalFooterElem.appendChild(annuleerBtn); // Voeg toe aan het einde
            }


            modalOverlay.classList.add('modal-zichtbaar');
        }

        function closeModal() {
            modalOverlay.classList.remove('modal-zichtbaar');
            modalBodyElem.innerHTML = ''; // Leeg inhoud bij sluiten
            modalFooterElem.innerHTML = ''; // Leeg footer
        }

        // --- Functies voor Gebruikersinfo en Registratie ---

        async function haalEnToonHuidigeGebruiker() {
            const userApiUrl = "_api/web/currentuser?$expand=groups"; // Expand groups om lidmaatschap te checken
            try {
                const data = await haalGegevensOp(rootSiteUrl, userApiUrl); // Haal op van root site
                huidigeGebruikerInfo = data.d;
                console.log("Huidige gebruiker:", huidigeGebruikerInfo);

                // Toon naam en initiaal (of placeholder)
                const voornaamElem = document.getElementById('userFirstName');
                const achternaamElem = document.getElementById('userLastName'); // Assuming you have this element
                const profielFotoElem = document.getElementById('userProfilePic');

                if (huidigeGebruikerInfo && huidigeGebruikerInfo.Title) {
                    const naamDelen = huidigeGebruikerInfo.Title.split(' ');
                    if (voornaamElem) voornaamElem.textContent = naamDelen[0];
                    if (achternaamElem && naamDelen.length > 1) achternaamElem.textContent = naamDelen.slice(1).join(' ');

                    // Probeer profielfoto te laden (pas URL aan indien nodig)
                    const profilePicUrl = `${rootSiteUrl}/_layouts/15/userphoto.aspx?size=S&accountname=${encodeURIComponent(huidigeGebruikerInfo.Email || huidigeGebruikerInfo.LoginName)}`;
                    if (profielFotoElem) {
                        profielFotoElem.src = profilePicUrl;
                        profielFotoElem.alt = huidigeGebruikerInfo.Title;
                        profielFotoElem.classList.remove('placeholder'); // Verwijder placeholder stijl
                        profielFotoElem.onerror = () => { // Fallback bij fout
                           profielFotoElem.classList.add('placeholder');
                           profielFotoElem.src = ''; // Leeg src
                           profielFotoElem.alt = 'Geen profielfoto';
                           // Optioneel: Toon initialen
                           // profielFotoElem.innerHTML = (naamDelen[0]?.[0] || '') + (naamDelen.length > 1 ? naamDelen[naamDelen.length - 1]?.[0] || '' : '');
                        };
                    }
                } else {
                    if (voornaamElem) voornaamElem.textContent = 'Gebruiker';
                    if (achternaamElem) achternaamElem.textContent = '';
                    if (profielFotoElem) profielFotoElem.classList.add('placeholder');
                }

                // !! BELANGRIJK: Haal entity types hier al op, VOORDAT registratie wordt gecheckt !!
                // Dit zorgt ervoor dat medewerkerListItemEntityType beschikbaar is
                // wanneer handleRegistratieSubmit wordt aangeroepen.
                await haalListItemEntityTypes();

                // Controleer registratie na ophalen gebruiker EN entity types
                await controleerEnStartRegistratie();

            } catch (error) {
                console.error("Fout bij ophalen gebruikersinformatie of entity types:", error);
                showNotification("Kon gebruikersinformatie of lijstconfiguratie niet laden.", "error");
                // Toon standaard 'Gebruiker'
                const voornaamElem = document.getElementById('userFirstName');
                 const profielFotoElem = document.getElementById('userProfilePic');
                if (voornaamElem) voornaamElem.textContent = 'Gebruiker';
                if (profielFotoElem) profielFotoElem.classList.add('placeholder');
                 // Toon foutmelding in rooster container
                 document.getElementById('roosterContainer').innerHTML = `<div class="p-4 text-center text-red-500">Kon essentiële gegevens niet laden. Probeer de pagina te vernieuwen.</div>`;
            }
        }

        async function controleerEnStartRegistratie() {
            if (!huidigeGebruikerInfo || !huidigeGebruikerInfo.LoginName) {
                console.warn("Gebruikersinfo niet beschikbaar voor registratiecheck.");
                return; // Kan niet checken zonder login naam
            }

            const loginName = huidigeGebruikerInfo.LoginName;
            const filterQuery = `$filter=Username eq '${encodeURIComponent(loginName)}'&$select=Id`;
            const checkUrl = `_api/web/lists(guid'${configLists.Medewerkers.guid}')/items?${filterQuery}`;

            try {
                const result = await haalGegevensOp(verlofSiteUrl, checkUrl);
                isGebruikerGeregistreerd = result?.d?.results?.length > 0;

                if (isGebruikerGeregistreerd) {
                    console.log("Gebruiker is geregistreerd.");
                    verbergRegistratieMelding();
                    // Entity types zijn al opgehaald in haalEnToonHuidigeGebruiker
                    // Initialiseer het rooster
                    await initRooster();
                    // Vul team filter dropdown
                    vulTeamFilter();

                } else {
                    console.log("Gebruiker is NIET geregistreerd.");
                    toonRegistratieMelding();
                    // Blokkeer rooster laden of toon beperkte weergave?
                     document.getElementById('roosterContainer').innerHTML = `<div class="p-4 text-center text-orange-600">Registreer u eerst als medewerker om het rooster te kunnen zien.</div>`;
                     document.getElementById('voegVerlofToeKnop').disabled = true; // Blokkeer toevoegen knop
                     document.getElementById('voegVerlofToeKnop').classList.add('opacity-50', 'cursor-not-allowed');
                }
            } catch (error) {
                console.error("Fout bij controleren registratie:", error);
                showNotification("Kon registratiestatus niet controleren.", "error");
                 document.getElementById('roosterContainer').innerHTML = `<div class="p-4 text-center text-red-500">Fout bij controle registratie. Probeer later opnieuw.</div>`;
            }
        }

        function toonRegistratieMelding() {
            const meldingElem = document.getElementById('registratieMeldingPlaceholder');
            if (meldingElem) {
                meldingElem.style.display = 'flex';
            }
        }

        function verbergRegistratieMelding() {
            const meldingElem = document.getElementById('registratieMeldingPlaceholder');
            if (meldingElem) {
                meldingElem.style.display = 'none';
            }
        }

        function openRegistratieModal() {
            if (!huidigeGebruikerInfo) {
                showNotification("Gebruikersinformatie nog niet geladen.", "error");
                return;
            }

            // Haal beschikbare teams op voor de dropdown
            haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Medewerkers.guid}')/fields?$filter=InternalName eq 'Team'`)
                .then(fieldData => {
                    let teamOptiesHtml = '<option value="">Kies een team...</option>';
                    // Aanname: Teams zijn opgeslagen als Choices in de lijst zelf, of we halen ze uit een andere lijst?
                    // Voor nu, hardcoded voorbeeld. Idealiter haal je dit uit een 'Teams' lijst.
                    const teams = ['Team A', 'Team B', 'Team C', 'Ondersteuning']; // Voorbeeld teams
                    teams.forEach(team => {
                        teamOptiesHtml += `<option value="${team}">${team}</option>`;
                    });

                     const modalHtml = `
                        <p class="mb-4 text-sm text-gray-600">Voltooi uw registratie door de volgende gegevens in te vullen.</p>
                        <form id="registratieForm">
                            <div class="mb-3">
                                <label for="regNaam" class="block text-sm font-medium text-gray-700 mb-1">Volledige Naam:</label>
                                <input type="text" id="regNaam" name="Naam" value="${huidigeGebruikerInfo.Title || ''}" required class="w-full border border-gray-300 rounded-md p-2 text-sm readonly-input" readonly>
                                <p class="text-xs text-gray-500 mt-1">Uw naam wordt automatisch ingevuld.</p>
                            </div>
                            <div class="mb-3">
                                <label for="regUsername" class="block text-sm font-medium text-gray-700 mb-1">Gebruikersnaam (Login):</label>
                                <input type="text" id="regUsername" name="Username" value="${huidigeGebruikerInfo.LoginName || ''}" required class="w-full border border-gray-300 rounded-md p-2 text-sm readonly-input" readonly>
                                 <p class="text-xs text-gray-500 mt-1">Uw login naam wordt automatisch ingevuld.</p>
                            </div>
                             <div class="mb-3">
                                <label for="regEmail" class="block text-sm font-medium text-gray-700 mb-1">E-mailadres:</label>
                                <input type="email" id="regEmail" name="E_x002d_mail" value="${huidigeGebruikerInfo.Email || ''}" required class="w-full border border-gray-300 rounded-md p-2 text-sm readonly-input" readonly>
                                 <p class="text-xs text-gray-500 mt-1">Uw e-mailadres wordt automatisch ingevuld.</p>
                            </div>
                            <div class="mb-3">
                                <label for="regTeam" class="block text-sm font-medium text-gray-700 mb-1">Team:</label>
                                <select id="regTeam" name="Team" required class="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500">
                                    ${teamOptiesHtml}
                                </select>
                            </div>
                             <div class="mb-3">
                                <label for="regGeboortedatum" class="block text-sm font-medium text-gray-700 mb-1">Geboortedatum:</label>
                                <input type="date" id="regGeboortedatum" name="Geboortedatum" required class="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500">
                            </div>
                            <!-- Voeg hier eventueel meer verplichte velden toe -->
                        </form>
                    `;
                    const footerHtml = `<button id="registratieOpslaanKnop" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow text-sm transition duration-150 ease-in-out">Registreren</button>`;
                    openModal("Medewerker Registratie", modalHtml, footerHtml);

                    // Voeg submit handler toe aan de knop
                    document.getElementById('registratieOpslaanKnop').addEventListener('click', handleRegistratieSubmit);

                })
                .catch(error => {
                     console.error("Fout bij ophalen team keuzes:", error);
                     showNotification("Kon teamkeuzes niet laden voor registratie.", "error");
                     // Toon modal zonder team selectie of met foutmelding?
                     const modalHtml = `<p class="text-red-500">Kon de benodigde informatie voor registratie niet laden. Probeer het later opnieuw.</p>`;
                     openModal("Fout bij Registratie", modalHtml);
                });


        }

        async function handleRegistratieSubmit() {
            const form = document.getElementById('registratieForm');
            // Nu zou medewerkerListItemEntityType moeten bestaan omdat het eerder is opgehaald
            if (!form || !medewerkerListItemEntityType) {
                 // Deze fout zou nu minder waarschijnlijk moeten zijn, maar we houden de check.
                 // Het kan nog steeds gebeuren als haalListItemEntityTypes faalt.
                 console.error("Fout in handleRegistratieSubmit: Formulier of medewerkerListItemEntityType niet gevonden.", { formExists: !!form, entityType: medewerkerListItemEntityType });
                 showNotification("Registratieformulier of lijsttype niet gevonden. Controleer console voor details.", "error");
                 return;
            }

            const formData = new FormData(form);
            const itemData = {};
            let isValid = true;
            for (let [key, value] of formData.entries()) {
                // Gebruik interne namen zoals gedefinieerd in configLijst.js
                const fieldConfig = configLists.Medewerkers.fields.find(f => f.internalName === key || f.title === key); // Check both just in case
                 if (fieldConfig) {
                     // Speciale behandeling voor Datum/Tijd
                     if (fieldConfig.type === 'DateTime' && value) {
                         // SharePoint verwacht ISO 8601 formaat
                         itemData[fieldConfig.internalName] = new Date(value).toISOString();
                     } else {
                        itemData[fieldConfig.internalName] = value;
                     }
                 } else {
                     itemData[key] = value; // Fallback if not in config (shouldn't happen ideally)
                 }

                // Validatie (eenvoudig voorbeeld)
                if (form.elements[key]?.required && !value) {
                    isValid = false;
                    showNotification(`Veld "${form.elements[key].previousElementSibling?.textContent || key}" is verplicht.`, "error");
                    form.elements[key].classList.add('border-red-500'); // Markeer veld
                    break; // Stop bij eerste fout
                } else {
                     form.elements[key]?.classList.remove('border-red-500');
                }
            }

             // Voeg standaardwaarden toe die niet in het formulier staan
             itemData['Actief'] = true; // Nieuwe registraties zijn standaard actief
             itemData['Horen'] = true; // Standaard op Horen = Ja (zoals in config)
             // Title is niet in form, maar vaak wel verplicht in SP. Gebruik Naam.
             itemData['Title'] = itemData['Naam'];


            if (!isValid) return;

            console.log("Registratie data voor verzenden:", itemData);

            try {
                // Gebruik voegItemToeMetGuid voor consistentie
                await voegItemToeMetGuid(verlofSiteUrl, configLists.Medewerkers.guid, itemData, medewerkerListItemEntityType);
                showNotification("Registratie succesvol!", "success");
                closeModal();
                isGebruikerGeregistreerd = true;
                verbergRegistratieMelding();
                 document.getElementById('voegVerlofToeKnop').disabled = false;
                 document.getElementById('voegVerlofToeKnop').classList.remove('opacity-50', 'cursor-not-allowed');
                // Herlaad rooster en team filter na succesvolle registratie
                await initRooster();
                vulTeamFilter();
            } catch (error) {
                console.error("Fout bij opslaan registratie:", error);
                showNotification(`Registratie mislukt: ${error.message}`, "error", 5000);
            }
        }

        // --- Functies voor Verlof Toevoegen ---

        function openVerlofModal() {
             if (!isGebruikerGeregistreerd || !huidigeGebruikerInfo) {
                 showNotification("U moet geregistreerd zijn om verlof toe te voegen.", "warning");
                 return;
             }
             if (!verlofListItemEntityType) {
                 showNotification("Kan verlof formulier niet laden (lijsttype onbekend).", "error");
                 return;
             }

             // Haal verlofredenen op voor de dropdown
             const redenOptiesHtml = alleVerlofredenenData
                 .map(reden => `<option value="${reden.Title}">${reden.Naam || reden.Title}</option>`) // Gebruik Title als value, Naam als display
                 .join('');

             const vandaag = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

             const modalHtml = `
                 <p class="mb-4 text-sm text-gray-600">Vul de details voor uw verlofaanvraag in.</p>
                 <form id="verlofForm">
                     <input type="hidden" name="MedewerkerID" value="${huidigeGebruikerInfo.LoginName}"> <!-- Gebruik LoginName als MedewerkerID -->
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                         <div class="mb-3">
                             <label for="verlofStartDatum" class="block text-sm font-medium text-gray-700 mb-1">Startdatum:</label>
                             <input type="date" id="verlofStartDatum" name="StartDatum" required class="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500" min="${vandaag}">
                         </div>
                         <div class="mb-3">
                             <label for="verlofEindDatum" class="block text-sm font-medium text-gray-700 mb-1">Einddatum:</label>
                             <input type="date" id="verlofEindDatum" name="EindDatum" required class="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500" min="${vandaag}">
                         </div>
                     </div>
                     <div class="mb-3">
                         <label for="verlofReden" class="block text-sm font-medium text-gray-700 mb-1">Reden:</label>
                         <select id="verlofReden" name="Reden" required class="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500">
                             <option value="">Kies een reden...</option>
                             ${redenOptiesHtml}
                         </select>
                     </div>
                     <div class="mb-3">
                         <label for="verlofOmschrijving" class="block text-sm font-medium text-gray-700 mb-1">Omschrijving (optioneel):</label>
                         <textarea id="verlofOmschrijving" name="Omschrijving" rows="3" class="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"></textarea>
                     </div>
                     <!-- Verborgen velden voor SharePoint -->
                     <input type="hidden" name="Title" value="Verlofaanvraag ${huidigeGebruikerInfo.Title} ${vandaag}"> <!-- Genereer een titel -->
                     <input type="hidden" name="Medewerker" value="${huidigeGebruikerInfo.Title}"> <!-- Sla volledige naam op -->
                     <!-- Status en AanvraagTijdstip worden idealiter door SP zelf of een workflow gevuld -->
                 </form>
             `;
             const footerHtml = `<button id="verlofOpslaanKnop" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow text-sm transition duration-150 ease-in-out">Aanvragen</button>`;
             openModal("Nieuwe Verlofaanvraag", modalHtml, footerHtml);

             // Voeg submit handler toe
             document.getElementById('verlofOpslaanKnop').addEventListener('click', handleVerlofSubmit);
             // Zorg dat einddatum niet voor startdatum kan zijn
             const startDatumInput = document.getElementById('verlofStartDatum');
             const eindDatumInput = document.getElementById('verlofEindDatum');
             startDatumInput.addEventListener('change', () => {
                 eindDatumInput.min = startDatumInput.value || vandaag;
                 if (eindDatumInput.value < startDatumInput.value) {
                     eindDatumInput.value = startDatumInput.value;
                 }
             });
             eindDatumInput.min = vandaag; // Initiele min datum
        }

        async function handleVerlofSubmit() {
             const form = document.getElementById('verlofForm');
             if (!form || !verlofListItemEntityType) {
                 showNotification("Verlofformulier of lijsttype niet gevonden.", "error");
                 return;
             }

             const formData = new FormData(form);
             const itemData = {};
             let isValid = true;

             // Validatie en data verzamelen
             for (let [key, value] of formData.entries()) {
                 const fieldConfig = configLists.Verlof.fields.find(f => f.internalName === key || f.title === key);
                 if (fieldConfig) {
                     if ((fieldConfig.type === 'DateTime' || key === 'StartDatum' || key === 'EindDatum') && value) {
                         // Voeg tijd toe (bv. begin en einde van de dag in UTC)
                         if (key === 'StartDatum') {
                             itemData[fieldConfig.internalName] = new Date(value + 'T00:00:00Z').toISOString();
                         } else if (key === 'EindDatum') {
                             itemData[fieldConfig.internalName] = new Date(value + 'T23:59:59Z').toISOString();
                         } else {
                              itemData[fieldConfig.internalName] = new Date(value).toISOString();
                         }
                     } else {
                         itemData[fieldConfig.internalName] = value;
                     }
                 } else {
                     itemData[key] = value; // Fallback
                 }

                 // Validatie
                 const inputElement = form.elements[key];
                 if (inputElement?.required && !value) {
                     isValid = false;
                     showNotification(`Veld "${inputElement.previousElementSibling?.textContent || key}" is verplicht.`, "error");
                     inputElement.classList.add('border-red-500');
                     break;
                 } else if (inputElement) {
                     inputElement.classList.remove('border-red-500');
                 }
             }
              // Extra validatie: einddatum >= startdatum
             if (isValid && itemData['EindDatum'] < itemData['StartDatum']) {
                 isValid = false;
                 showNotification("Einddatum mag niet voor de startdatum liggen.", "error");
                 document.getElementById('verlofEindDatum').classList.add('border-red-500');
             }


             if (!isValid) return;

             // Voeg eventuele standaardwaarden toe die niet in het formulier staan
             // itemData['Status'] = 'Aangevraagd'; // Indien nodig

             console.log("Verlof data voor verzenden:", itemData);

             try {
                 // Gebruik voegItemToeMetGuid
                 await voegItemToeMetGuid(verlofSiteUrl, configLists.Verlof.guid, itemData, verlofListItemEntityType);
                 showNotification("Verlofaanvraag succesvol ingediend!", "success");
                 closeModal();
                 // Herlaad alleen de verlof data en render opnieuw
                 const verlof = await haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Verlof.guid}')/items?$select=Id,MedewerkerID,StartDatum,EindDatum,Reden`);
                 alleVerlofData = verlof?.d?.results || [];
                 renderRooster(); // Update de weergave
             } catch (error) {
                 console.error("Fout bij opslaan verlofaanvraag:", error);
                 showNotification(`Verlofaanvraag mislukt: ${error.message}`, "error", 5000);
             }
        }

        // --- Hulpfunctie voor ophalen List Item Entity Types ---
        async function haalListItemEntityTypes() {
            // Reset waarden voor het geval de functie opnieuw wordt aangeroepen
            medewerkerListItemEntityType = null;
            verlofListItemEntityType = null;
            console.log("Ophalen ListItemEntityTypes gestart...");
            try {
                const [medewerkersInfo, verlofInfo] = await Promise.all([
                    // Gebruik de juiste GUID uit configLijst.js
                    haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Medewerkers.guid}')?$select=ListItemEntityTypeFullName`),
                    haalGegevensOp(verlofSiteUrl, `_api/web/lists(guid'${configLists.Verlof.guid}')?$select=ListItemEntityTypeFullName`)
                ]);

                if (medewerkersInfo?.d?.ListItemEntityTypeFullName) {
                    medewerkerListItemEntityType = medewerkersInfo.d.ListItemEntityTypeFullName;
                    console.log("Medewerkers ListItemEntityType:", medewerkerListItemEntityType);
                } else {
                     console.error("Kon ListItemEntityType voor Medewerkers niet ophalen. Respons:", medewerkersInfo);
                     showNotification("Kon lijsttype voor medewerkers niet bepalen.", "error");
                }

                if (verlofInfo?.d?.ListItemEntityTypeFullName) {
                    verlofListItemEntityType = verlofInfo.d.ListItemEntityTypeFullName;
                    console.log("Verlof ListItemEntityType:", verlofListItemEntityType);
                } else {
                     console.error("Kon ListItemEntityType voor Verlof niet ophalen. Respons:", verlofInfo);
                     showNotification("Kon lijsttype voor verlof niet bepalen.", "error");
                }

                // Gooi een fout als een van de types essentieel is en niet kon worden opgehaald
                if (!medewerkerListItemEntityType || !verlofListItemEntityType) {
                    throw new Error("Een of meer essentiële ListItemEntityTypes konden niet worden opgehaald.");
                }

            } catch (error) {
                console.error("Fout bij ophalen ListItemEntityTypes:", error);
                showNotification("Kon lijsttypes niet ophalen. CRUD-operaties zullen mislukken.", "error", 6000);
                // Gooi de fout opnieuw door zodat de aanroepende functie (haalEnToonHuidigeGebruiker) het kan afhandelen
                throw error;
            }
        }

        // --- Functie om Team Filter te vullen ---
        function vulTeamFilter() {
            const selectElem = document.getElementById('teamFilterSelect');
            if (!selectElem || !alleMedewerkersData) return;

            // Haal unieke teams uit de medewerkersdata
            const teams = [...new Set(alleMedewerkersData.map(m => m.Team).filter(Boolean))].sort();

            // Leeg bestaande opties (behalve 'Alle teams')
            selectElem.innerHTML = '<option value="alle">Alle teams</option>';

            // Voeg nieuwe opties toe
            teams.forEach(team => {
                const option = document.createElement('option');
                option.value = team;
                option.textContent = team;
                selectElem.appendChild(option);
            });
             console.log("Team filter gevuld met:", teams);
        }


        // --- Dropdown Menu Logic ---
        function setupDropdown(buttonId, dropdownId) {
            const button = document.getElementById(buttonId);
            const dropdown = document.getElementById(dropdownId);

            if (!button || !dropdown) return;

            button.addEventListener('click', (event) => {
                event.stopPropagation(); // Voorkom dat klikken op de knop de body-listener triggert
                // Sluit andere open dropdowns
                document.querySelectorAll('.dropdown-menu.visible').forEach(openDropdown => {
                    if (openDropdown.id !== dropdownId) {
                        openDropdown.classList.remove('visible');
                    }
                });
                // Toggle huidige dropdown
                dropdown.classList.toggle('visible');
            });
        }

        // Sluit dropdowns als ergens anders wordt geklikt
        document.addEventListener('click', (event) => {
             const openDropdowns = document.querySelectorAll('.dropdown-menu.visible');
             openDropdowns.forEach(dropdown => {
                 // Check if the click was outside the dropdown and its button
                 const buttonId = dropdown.id.replace('Dropdown', 'Button');
                 const button = document.getElementById(buttonId);
                 if (!dropdown.contains(event.target) && event.target !== button && !button?.contains(event.target)) {
                     dropdown.classList.remove('visible');
                 }
             });
        });


        // --- Initialisatie ---
        document.addEventListener('DOMContentLoaded', async () => {
            console.log("DOM volledig geladen en geparsed.");

            // Koppel UI elementen aan functies uit roosterRender.js en lokale functies
            document.getElementById('vorigeKnop')?.addEventListener('click', gaNaarVorigePeriode);
            document.getElementById('volgendeKnop')?.addEventListener('click', gaNaarVolgendePeriode);
            document.getElementById('vandaagKnop')?.addEventListener('click', gaNaarVandaag);
            document.getElementById('weekKnop')?.addEventListener('click', () => wijzigWeergave('week'));
            document.getElementById('maandKnop')?.addEventListener('click', () => wijzigWeergave('maand'));
            document.getElementById('teamFilterSelect')?.addEventListener('change', (e) => filterOpTeam(e.target.value));
            document.getElementById('zoekMedewerkerInput')?.addEventListener('input', (e) => filterOpZoekterm(e.target.value));

            // Koppel modal knoppen
            document.getElementById('voegVerlofToeKnop')?.addEventListener('click', openVerlofModal);
            document.getElementById('registreerNuKnop')?.addEventListener('click', openRegistratieModal);
            modalAnnuleerKnop?.addEventListener('click', closeModal); // Algemene annuleer knop in modal
             // Sluit modal bij klikken op overlay
             modalOverlay?.addEventListener('click', (event) => {
                 if (event.target === modalOverlay) { // Alleen als direct op overlay geklikt wordt
                     closeModal();
                 }
             });

             // Setup dropdown menus
             setupDropdown('userMenuButton', 'userMenuDropdown');
             setupDropdown('adminMenuButton', 'adminMenuDropdown');

             // Koppel acties aan admin menu items (voorbeeld)
             document.querySelectorAll('#adminMenuDropdown .dropdown-item').forEach(item => {
                 item.addEventListener('click', (e) => {
                     e.preventDefault();
                     const action = e.currentTarget.dataset.action;
                     const titel = e.currentTarget.dataset.modalTitel || 'Beheer';
                     console.log(`Admin actie geklikt: ${action}`);
                     // Voorbeeld: Open een generieke modal voor beheeracties
                     openModal(titel, `<p>Beheer interface voor <strong>${action}</strong> komt hier.</p><p>Implementatie volgt nog.</p>`);
                     document.getElementById('adminMenuDropdown').classList.remove('visible'); // Sluit menu
                 });
             });


            // Start de applicatie
            await haalEnToonHuidigeGebruiker(); // Haalt gebruiker op, checkt registratie, haalt entity types, initieert rooster en vult filters

            console.log("Initialisatie voltooid.");
        });

    </script>

</body>
</html>
