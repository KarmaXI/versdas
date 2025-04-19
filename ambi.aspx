<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teamverlofrooster</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <style>
        /* ... (alle CSS stijlen blijven ongewijzigd) ... */
         body { font-family: 'Inter', sans-serif; background-color: #f7fafc; }
        html, body { overflow-x: hidden; width: 100%; }
        .rooster-grid { display: grid; overflow-x: auto; }
        .rooster-header, .rooster-cel { padding: 0.5rem; text-align: center; border: 1px solid #e2e8f0; font-size: 0.75rem; white-space: nowrap; }
        .rooster-header-medewerker, .rooster-cel-medewerker { position: sticky; left: 0; background-color: #fff; z-index: 10; text-align: left; font-weight: 600; border-right-width: 2px; }
        .rooster-cel-medewerker { font-weight: normal; }
        .rooster-dag-header { font-weight: 600; background-color: #f8f9fa; }
        .actief-knop { font-weight: bold; background-color: #e2e8f0; }
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
        .modal-footer { border-top: 1px solid #e5e7eb; padding-top: 1rem; display: flex; justify-content: flex-end; }
        .modal-overlay.modal-zichtbaar { display: flex; }
        .registratie-melding {
            background-color: #8B0000; /* Bordeaux rood */
            color: white;
            padding: 0.75rem 1rem;
            border-radius: 0.375rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            display: none; /* Standaard verborgen */
            align-items: center;
            gap: 0.5rem;
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
                     <option value="teamA">Team A</option>
                     <option value="teamB">Team B</option>
                 </select>
            </div>
            <div id="userMenuContainer" class="relative flex items-center gap-2 text-sm text-gray-600">
                 <img id="userProfilePic" src="" alt="Profielfoto" class="w-8 h-8 rounded-full bg-gray-300 border border-gray-400 object-cover">
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
             <div class="p-3 border-t border-gray-200 text-sm text-gray-600">Hier komt de legenda inhoud (bijv. kleuren voor verloftypes).</div>
        </details>

        <div id="roosterContainer" class="border border-gray-300 rounded-md overflow-hidden">
            <div class="rooster-grid">
                <div class="rooster-header rooster-header-medewerker">Medewerker</div>
                <div class="rooster-cel rooster-cel-medewerker">Rooster laden...</div>
             </div>
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
                <button id="modalAnnuleerKnop" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-md shadow text-sm transition duration-150 ease-in-out">Annuleren</button>
            </div>
        </div>
    </div>
    <script>
        // === Globale Variabelen ===
        const roosterContainer = document.getElementById('roosterContainer');
        const huidigePeriodeWeergave = document.getElementById('huidigePeriode');
        const vorigeKnop = document.getElementById('vorigeKnop');
        const volgendeKnop = document.getElementById('volgendeKnop');
        const vandaagKnop = document.getElementById('vandaagKnop');
        const weekKnop = document.getElementById('weekKnop');
        const maandKnop = document.getElementById('maandKnop');
        const zoekInput = document.getElementById('zoekMedewerkerInput');
        const teamFilter = document.getElementById('teamFilterSelect');
        const voegVerlofToeKnop = document.getElementById('voegVerlofToeKnop');
        console.log("[Init] voegVerlofToeKnop element:", voegVerlofToeKnop); // <-- Log 1: Check element selection
        const userMenuContainer = document.getElementById('userMenuContainer');
        const userMenuButton = document.getElementById('userMenuButton');
        const userMenuDropdown = document.getElementById('userMenuDropdown');
        const userProfilePicElement = document.getElementById('userProfilePic');
        const userFirstNameElement = document.getElementById('userFirstName');
        const userLastNameElement = document.getElementById('userLastName');
        const adminMenuContainer = document.getElementById('adminMenuContainer');
        const adminMenuButton = document.getElementById('adminMenuButton');
        const adminMenuDropdown = document.getElementById('adminMenuDropdown');
        const modalOverlay = document.getElementById('generiekeModalOverlay');
        const modalTitelElement = document.getElementById('modalTitel');
        const modalBodyElement = document.getElementById('modalBody');
        const modalAnnuleerKnop = document.getElementById('modalAnnuleerKnop');
        const registratieMeldingPlaceholder = document.getElementById('registratieMeldingPlaceholder');
        const registreerNuKnop = document.getElementById('registreerNuKnop');
        const modalFooterElement = document.getElementById('modalFooter'); // Footer element

        let huidigeDatum = new Date();
        let huidigeWeergave = 'maand';
        const dagenNamenKort = ['Zo', 'Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za'];
        const maandenNamen = ['Januari', 'Februari', 'Maart', 'April', 'Mei', 'Juni', 'Juli', 'Augustus', 'September', 'Oktober', 'November', 'December'];
        const vandaagString = new Date().toISOString().split('T')[0];

        // SharePoint context URLs
        const rootSiteUrl = "https://som.org.om.local/sites/MulderT"; // Voor gebruiker info
        const verlofSiteUrl = "https://som.org.om.local/sites/MulderT/CustomPW/Verlof"; // Voor lijst data

        // Globale variabelen om lijstdata op te slaan (optioneel)
        let alleMedewerkers = [];
        let alleVerlofItems = [];
        let alleVerlofredenen = [];
        let huidigeGebruikerInfo = null; // Placeholder for current user info

        // ============================================================
        // === Modal Functies ===
        // ============================================================

        /**
         * Sluit de generieke modal.
         */
        function closeModal() {
            if (modalOverlay) {
                modalOverlay.classList.remove('modal-zichtbaar');
                console.log("[closeModal] Modal gesloten.");
                // Optioneel: Reset modal inhoud en footer
                if (modalBodyElement) modalBodyElement.innerHTML = 'Placeholder modal inhoud...';
                if (modalTitelElement) modalTitelElement.textContent = 'Modal Titel';
                if (modalFooterElement) {
                    // Reset footer naar alleen de Annuleer knop
                    modalFooterElement.innerHTML = `<button id="modalAnnuleerKnop" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-md shadow text-sm transition duration-150 ease-in-out">Annuleren</button>`;
                    // Voeg de event listener opnieuw toe aan de nieuwe knop
                    document.getElementById('modalAnnuleerKnop')?.addEventListener('click', closeModal);
                }
            } else {
                console.error("[closeModal] Kon modal overlay element niet vinden.");
            }
        }

        /**
         * Opent de generieke modal met specifieke titel en inhoud.
         * @param {string} titel - De titel voor de modal header.
         * @param {string} inhoudHtml - De HTML-inhoud voor de modal body.
         */
        function openModal(titel, inhoudHtml) {
            if (modalOverlay && modalTitelElement && modalBodyElement) {
                modalTitelElement.textContent = titel;
                modalBodyElement.innerHTML = inhoudHtml;
                modalOverlay.classList.add('modal-zichtbaar');
                console.log(`[openModal] Modal geopend met titel: ${titel}`);
            } else {
                console.error("[openModal] Kon modal elementen niet vinden.");
                showNotification("Kon het venster niet openen.", "error");
            }
        }


        // ============================================================
        // === Functies uit crudBasis.js (geïntegreerd) ===
        // ============================================================

        /**
         * Voert een generiek GET-verzoek uit.
         * @param {string} siteUrlParam - De site URL.
         * @param {string} specifiekeEndpoint - De REST endpoint.
         * @returns {Promise<object|null>} Promise met JSON-data of null.
         */
        function haalGegevensOp(siteUrlParam, specifiekeEndpoint) {
            console.log(`[haalGegevensOp] Start aanroep voor: ${specifiekeEndpoint}`);
            if (!siteUrlParam) {
                 console.error("[haalGegevensOp] Fout: Site URL is vereist.");
                return Promise.reject(new Error("Site URL is vereist voor haalGegevensOp."));
            }
            const volledigeEindpuntUrl = siteUrlParam.replace(/\/$/, '') + '/' + specifiekeEndpoint.replace(/^\//, '');
            console.log(`[haalGegevensOp] Volledige URL: ${volledigeEindpuntUrl}`);

            return fetch(volledigeEindpuntUrl, {
                method: "GET",
                headers: { "Accept": "application/json;odata=verbose" }
            })
            .then(antwoord => {
                console.log(`[haalGegevensOp] Antwoord status voor ${specifiekeEndpoint}: ${antwoord.status}`);
                if (!antwoord.ok) {
                    return antwoord.json().catch(() => {
                         throw new Error(`HTTP fout ${antwoord.status} bij GET ${volledigeEindpuntUrl}`);
                    }).then(foutData => {
                        let foutMelding = `HTTP fout ${antwoord.status} bij GET ${volledigeEindpuntUrl}`;
                        if (foutData?.error?.message?.value) {
                           foutMelding += ` - ${foutData.error.message.value}`;
                        }
                        throw new Error(foutMelding);
                    });
                }
                if (antwoord.status === 204) { return null; } // No Content
                return antwoord.json();
            })
            .then(data => {
                console.log(`[haalGegevensOp] Succesvol data ontvangen voor ${specifiekeEndpoint}.`);
                return data;
            })
            .catch(fout => {
                console.error(`[haalGegevensOp] Fout tijdens GET naar ${volledigeEindpuntUrl}:`, fout);
                if (typeof showNotification === 'function') {
                    showNotification(`Fout bij ophalen gegevens: ${fout.message}`, 'error', 5000);
                }
                throw fout;
            });
        }

        /**
         * Toont een tijdelijke notificatie.
         * @param {string} message - Bericht.
         * @param {string} [type='info'] - Type ('success', 'error', 'info').
         * @param {number} [duration=3000] - Duur in ms.
         */
        function showNotification(message, type = 'info', duration = 3000) {
            const notificationId = 'global-notification-element';
            let existingNotification = document.getElementById(notificationId);

            if (existingNotification) {
                 console.log("Notificatie wordt al weergegeven, nieuwe genegeerd:", message);
                 return;
            }

            const notification = document.createElement('div');
            notification.id = notificationId;
            notification.textContent = message;

            notification.style.position = 'fixed';
            notification.style.bottom = '20px';
            notification.style.right = '20px';
            notification.style.padding = '15px 20px';
            notification.style.borderRadius = '5px';
            notification.style.color = 'white';
            notification.style.zIndex = '1000';
            notification.style.opacity = '0';
            notification.style.transition = `opacity ${duration / 4}ms ease-in-out`;

            switch (type) {
                case 'error': notification.style.backgroundColor = '#dc3545'; break;
                case 'success': notification.style.backgroundColor = '#198754'; break;
                default: notification.style.backgroundColor = '#0dcaf0'; break;
            }

            document.body.appendChild(notification);
            void notification.offsetWidth;
            notification.style.opacity = '1';

            setTimeout(() => { notification.style.opacity = '0'; }, duration - (duration / 4));
            setTimeout(() => { notification.remove(); }, duration);
        }

        /**
         * Haalt de Form Digest Value op, nodig voor POST/UPDATE/DELETE.
         * @param {string} siteUrlParam - De site URL.
         * @returns {Promise<string>} Promise met de Form Digest Value.
         */
        function getRequestDigest(siteUrlParam) {
            console.log(`[getRequestDigest] Ophalen voor ${siteUrlParam}`);
            if (!siteUrlParam) {
                console.error("[getRequestDigest] Fout: Site URL is vereist.");
                return Promise.reject(new Error("Site URL is vereist voor getRequestDigest."));
            }
            const digestUrl = siteUrlParam.replace(/\/$/, '') + "/_api/contextinfo";

            return fetch(digestUrl, {
                method: "POST",
                headers: { "Accept": "application/json;odata=verbose" }
            })
            .then(antwoord => {
                if (!antwoord.ok) {
                    throw new Error(`HTTP fout ${antwoord.status} bij ophalen request digest.`);
                }
                return antwoord.json();
            })
            .then(data => {
                if (data && data.d && data.d.GetContextWebInformation && data.d.GetContextWebInformation.FormDigestValue) {
                    console.log("[getRequestDigest] Succesvol ontvangen.");
                    return data.d.GetContextWebInformation.FormDigestValue;
                } else {
                    throw new Error("Kon FormDigestValue niet vinden in het antwoord.");
                }
            })
            .catch(fout => {
                console.error("[getRequestDigest] Fout:", fout);
                showNotification(`Kon beveiligingstoken niet ophalen: ${fout.message}`, 'error');
                throw fout;
            });
        }

        /**
         * Voegt een nieuw item toe aan een SharePoint lijst.
         * @param {string} siteUrlParam - De site URL.
         * @param {string} listGuid - De GUID van de lijst.
         * @param {object} itemPayload - Het object met de data voor het nieuwe item.
         * @returns {Promise<object>} Promise met de data van het aangemaakte item.
         */
        async function voegItemToe(siteUrlParam, listGuid, itemPayload) {
            console.log(`[voegItemToe] Toevoegen aan lijst ${listGuid} op ${siteUrlParam}`);
            if (!siteUrlParam || !listGuid || !itemPayload) {
                console.error("[voegItemToe] Fout: Site URL, List GUID en Payload zijn vereist.");
                return Promise.reject(new Error("Ontbrekende parameters voor voegItemToe."));
            }

            try {
                const requestDigest = await getRequestDigest(siteUrlParam);
                const endpointUrl = `${siteUrlParam.replace(/\/$/, '')}/_api/web/lists(guid'${listGuid}')/items`;

                console.log("[voegItemToe] Endpoint:", endpointUrl);
                console.log("[voegItemToe] Payload:", JSON.stringify(itemPayload));

                const antwoord = await fetch(endpointUrl, {
                    method: "POST",
                    headers: {
                        "Accept": "application/json;odata=verbose",
                        "Content-Type": "application/json;odata=verbose",
                        "X-RequestDigest": requestDigest,
                        "If-Match": "*" // Nodig voor sommige updates/creates
                    },
                    body: JSON.stringify(itemPayload)
                });

                console.log(`[voegItemToe] Antwoord status: ${antwoord.status}`);

                if (!antwoord.ok) {
                    const foutData = await antwoord.json().catch(() => null);
                    let foutMelding = `HTTP fout ${antwoord.status} bij POST naar ${endpointUrl}`;
                    if (foutData?.error?.message?.value) {
                        foutMelding += ` - ${foutData.error.message.value}`;
                    }
                    throw new Error(foutMelding);
                }

                if (antwoord.status === 204 || antwoord.headers.get("content-length") === "0") {
                    console.log("[voegItemToe] Item succesvol toegevoegd (geen content antwoord).");
                    return { success: true }; // Geef een succes object terug
                } else {
                    const data = await antwoord.json();
                    console.log("[voegItemToe] Item succesvol toegevoegd:", data);
                    return data; // Geef de data van het nieuwe item terug
                }

            } catch (fout) {
                console.error("[voegItemToe] Fout:", fout);
                showNotification(`Kon item niet toevoegen: ${fout.message}`, 'error');
                throw fout;
            }
        }

        /**
         * Verwerkt het indienen van het verlofaanvraagformulier.
         */
        async function handleVerlofSubmit(event) {
            event.preventDefault(); // Voorkom standaard formulierinzending
            console.log("[handleVerlofSubmit] Verlofaanvraag indienen...");
            const form = event.target;
            const opslaanKnop = form.querySelector('button[type="submit"]');
            const annuleerKnop = form.querySelector('#modalAnnuleerKnopForm');

            // Disable knoppen tijdens verwerking
            if (opslaanKnop) opslaanKnop.disabled = true;
            if (annuleerKnop) annuleerKnop.disabled = true;
            if (opslaanKnop) opslaanKnop.textContent = 'Bezig...';

            const formData = new FormData(form);
            const data = Object.fromEntries(formData.entries());

            // --- Validatie --- 
            if (!data.medewerkerId || !data.startDatum || !data.eindDatum || !data.redenId) {
                showNotification("Vul alle verplichte velden in (Medewerker, Startdatum, Einddatum, Reden).", "error");
                if (opslaanKnop) opslaanKnop.disabled = false;
                if (annuleerKnop) annuleerKnop.disabled = false;
                if (opslaanKnop) opslaanKnop.textContent = 'Aanvragen';
                return; // Stop uitvoering
            }

            const start = new Date(data.startDatum);
            const eind = new Date(data.eindDatum);
            if (eind < start) {
                showNotification("De einddatum mag niet voor de startdatum liggen.", "error");
                if (opslaanKnop) opslaanKnop.disabled = false;
                if (annuleerKnop) annuleerKnop.disabled = false;
                if (opslaanKnop) opslaanKnop.textContent = 'Aanvragen';
                return; // Stop uitvoering
            }

            console.log("[handleVerlofSubmit] Formulier data:", data);

            // --- Payload voor SharePoint --- 
            // BELANGRIJK: Vervang 'SP.Data.VerlofListItem' door de juiste interne naam!
            // Je vindt deze meestal door naar /_api/web/lists(guid'...')?$select=ListItemEntityTypeFullName te gaan.
            const listItemEntityTypeFullName = "SP.Data.VerlofListItem"; // PAS DIT AAN INDIEN NODIG!
            const listGuid = 'e12a068f-2821-4fe1-b898-e42e1418edf8';

            const itemPayload = {
                '__metadata': { 'type': listItemEntityTypeFullName },
                'MedewerkerIDId': parseInt(data.medewerkerId), // Lookup velden vereisen 'Id' suffix en een integer waarde
                'StartDatum': start.toISOString(), // Gebruik ISO string voor datum/tijd velden
                'EindDatum': eind.toISOString(),
                'RedenId': parseInt(data.redenId), // Lookup velden vereisen 'Id' suffix
                'Omschrijving': data.omschrijving || null, // Stuur null als leeg
                'Status': 'Aangevraagd' // Default status bij nieuwe aanvraag
            };

            // --- Aanroep naar voegItemToe --- 
            try {
                await voegItemToe(verlofSiteUrl, listGuid, itemPayload);
                showNotification('Verlofaanvraag succesvol ingediend!', 'success');
                closeModal();
                // Herlaad data en update rooster
                await laadInitieleLijstData();
                renderRooster();
            } catch (error) {
                console.error("[handleVerlofSubmit] Fout bij indienen verlof:", error);
                // Foutmelding wordt al getoond door voegItemToe
                // Herstel knoppen bij fout
                if (opslaanKnop) opslaanKnop.disabled = false;
                if (annuleerKnop) annuleerKnop.disabled = false;
                if (opslaanKnop) opslaanKnop.textContent = 'Aanvragen';
            }
        }

        // === Registratie Flow Functies ===

        /**
         * Toont de registratiemelding.
         */
        function toonRegistratieMelding() {
            if (registratieMeldingPlaceholder) {
                registratieMeldingPlaceholder.style.display = 'flex';
                console.log("[toonRegistratieMelding] Melding getoond.");
            }
        }

        /**
         * Verbergt de registratiemelding.
         */
        function verbergRegistratieMelding() {
            if (registratieMeldingPlaceholder) {
                registratieMeldingPlaceholder.style.display = 'none';
                console.log("[verbergRegistratieMelding] Melding verborgen.");
            }
        }

        /**
         * Opent de modal met het registratieformulier.
         */
        function openRegistratieModal() {
            console.log("[openRegistratieModal] Openen registratie modal...");
            if (!huidigeGebruikerInfo) {
                console.error("[openRegistratieModal] Kan modal niet openen, gebruikersinformatie ontbreekt.");
                showNotification("Kon gebruikersinformatie niet laden voor registratie.", "error");
                return;
            }

            const titel = "Registreer als Medewerker";
            // Haal gegevens uit opgeslagen gebruikersinfo
            const volledigeNaam = huidigeGebruikerInfo.Title || '';
            const email = huidigeGebruikerInfo.Email || '';

            // TODO: Haal eventueel Team opties op uit een aparte lijst of definieer ze hier
            const teamOptiesHtml = `
                <option value="">-- Selecteer Team --</option>
                <option value="Team A">Team A</option>
                <option value="Team B">Team B</option>
                <option value="Team C">Team C</option>
                <!-- Voeg meer teams toe indien nodig -->
            `;

            // Formulier HTML met read-only velden voor naam en e-mail
            const registratieFormHtml = `
                <form id="registratieForm">
                    <p class="text-sm text-gray-600 mb-4">Uw gegevens zijn nog niet gevonden in het systeem. Vul de ontbrekende informatie aan om u te registreren.</p>
                    <div class="mb-4">
                        <label for="regNaam" class="block text-sm font-medium text-gray-700 mb-1">Volledige Naam</label>
                        <input type="text" id="regNaam" name="volledigeNaam" value="${volledigeNaam}" class="w-full border border-gray-300 rounded-md p-2 text-sm readonly-input" readonly>
                    </div>
                     <div class="mb-4">
                        <label for="regEmail" class="block text-sm font-medium text-gray-700 mb-1">E-mailadres</label>
                        <input type="email" id="regEmail" name="email" value="${email}" class="w-full border border-gray-300 rounded-md p-2 text-sm readonly-input" readonly required>
                    </div>
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div>
                            <label for="regFunctie" class="block text-sm font-medium text-gray-700 mb-1">Functie <span class="text-red-500">*</span></label>
                            <input type="text" id="regFunctie" name="functie" class="w-full border border-gray-300 rounded-md p-2 text-sm focus:ring-blue-500 focus:border-blue-500" required>
                        </div>
                        <div>
                            <label for="regTeam" class="block text-sm font-medium text-gray-700 mb-1">Team <span class="text-red-500">*</span></label>
                            <select id="regTeam" name="team" class="w-full border border-gray-300 rounded-md p-2 text-sm focus:ring-blue-500 focus:border-blue-500" required>
                                ${teamOptiesHtml}
                            </select>
                        </div>
                    </div>
                    <!-- Voeg hier eventueel meer verplichte velden toe -->
                    <!-- Submit knop wordt apart toegevoegd aan de footer -->
                </form>
            `;
            openModal(titel, registratieFormHtml); // Open modal met alleen formulier in body

            // Voeg Registreer knop toe aan de modal footer
            if (modalFooterElement) {
                 // Verwijder eventuele oude knoppen behalve Annuleren
                 Array.from(modalFooterElement.children).forEach(child => {
                     if (child.id !== 'modalAnnuleerKnop') {
                         child.remove();
                     }
                 });
                 // Voeg nieuwe Registreer knop toe
                 const registreerKnopHtml = `<button type="submit" form="registratieForm" id="modalRegistreerKnop" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow text-sm ml-2">Registreren</button>`;
                 modalFooterElement.insertAdjacentHTML('beforeend', registreerKnopHtml);
            }


            // Voeg listener toe voor formulier submit (de knop zit nu buiten het form, maar 'form' attribuut linkt ze)
            document.getElementById('registratieForm')?.addEventListener('submit', handleRegistratieSubmit);
        }

        /**
         * Verwerkt het indienen van het registratieformulier.
         */
        async function handleRegistratieSubmit(event) {
            event.preventDefault();
            console.log("[handleRegistratieSubmit] Registratie indienen...");
            const form = event.target;
            const registreerKnop = document.getElementById('modalRegistreerKnop'); // Haal knop op via ID
            const annuleerKnop = modalAnnuleerKnop; // Gebruik de algemene annuleer knop

            if (registreerKnop) registreerKnop.disabled = true;
            if (annuleerKnop) annuleerKnop.disabled = true;
            if (registreerKnop) registreerKnop.textContent = 'Bezig...';

            const formData = new FormData(form);
            const data = Object.fromEntries(formData.entries());

            // --- Validatie ---
            if (!data.functie || !data.team || !data.email) {
                showNotification("Vul alle verplichte velden in (Functie, Team). E-mail is ook vereist.", "error");
                if (registreerKnop) registreerKnop.disabled = false;
                if (annuleerKnop) annuleerKnop.disabled = false;
                if (registreerKnop) registreerKnop.textContent = 'Registreren';
                return;
            }
            console.log("[handleRegistratieSubmit] Formulier data:", data);

            // --- Payload voor SharePoint 'Medewerkers' lijst ---
            // !! BELANGRIJK: Controleer de interne veldnamen in je SharePoint lijst !!
            const listGuid = '835ae977-8cd1-4eb8-a787-23aa2d76228d';
            const listItemEntityTypeFullName = "SP.Data.MedewerkersListItem"; // Gebruik constante

            const itemPayload = {
                '__metadata': { 'type': listItemEntityTypeFullName },
                // Gebruik de volledige naam uit de gebruikersinfo voor Title (vaak de primaire kolom)
                'Title': data.volledigeNaam,
                'Naam': data.volledigeNaam, // Eventueel apart 'Naam' veld indien aanwezig
                'E_x002d_mail': data.email, // Interne naam voor E-mail veld (CONTROLEER DIT!)
                'Functie': data.functie, // Interne naam voor Functie veld
                'Team': data.team, // Interne naam voor Team veld
                'Actief': true // Standaard op actief zetten bij registratie
                // Voeg hier andere velden toe indien nodig (bv. Horen?)
            };

            console.log("[handleRegistratieSubmit] Payload voor Medewerkers lijst:", JSON.stringify(itemPayload));

            // --- Aanroep naar voegItemToe ---
            try {
                await voegItemToe(verlofSiteUrl, listGuid, itemPayload);
                showNotification('Succesvol geregistreerd!', 'success');
                verbergRegistratieMelding(); // Verberg de melding
                closeModal(); // Sluit de modal

                // Herlaad data en update rooster
                await laadInitieleLijstData(); // Herlaad ALLE data
                renderRooster();

            } catch (error) {
                console.error("[handleRegistratieSubmit] Fout bij registreren:", error);
                // Foutmelding wordt al getoond door voegItemToe
                if (registreerKnop) registreerKnop.disabled = false;
                if (annuleerKnop) annuleerKnop.disabled = false;
                if (registreerKnop) registreerKnop.textContent = 'Registreren';
            }
        }

        // === Initialisatie ===
        document.addEventListener('DOMContentLoaded', async () => {
            console.log("DOM volledig geladen en geparsed.");

            // --- Event Listeners hier toevoegen ---
            // Listener voor de algemene Annuleer knop in de modal
            modalAnnuleerKnop?.addEventListener('click', closeModal);

            // Listener voor de "Registreer nu" knop in de melding (voor heropenen modal)
            registreerNuKnop?.addEventListener('click', openRegistratieModal);

            // --- Bestaande Initialisatie Code ---
            try {
                // Wacht tot BEIDE voltooid zijn
                await Promise.all([
                    haalEnToonHuidigeGebruiker(),
                    laadInitieleLijstData()
                ]);

                // Controleer pas NA het laden van beide sets data
                controleerEnStartRegistratie();

                // Render het rooster alleen als de gebruiker geregistreerd is
                // (controleerEnStartRegistratie opent de modal indien nodig)
                if (registratieMeldingPlaceholder?.style.display !== 'flex') {
                    renderRooster();
                } else {
                     console.log("[DOMContentLoaded] Gebruiker niet geregistreerd, rooster wordt niet initieel gerenderd.");
                     // Optioneel: Toon een bericht in de rooster container
                     if (roosterContainer) {
                         roosterContainer.innerHTML = `<div class="p-4 text-center text-gray-600">Voltooi uw registratie om het rooster te bekijken.</div>`;
                     }
                }
                updateActieveWeergaveKnop();

            } catch (error) {
                console.error("[DOMContentLoaded] Fout tijdens initialisatie:", error);
                showNotification("Er is een fout opgetreden bij het initialiseren van de pagina.", "error", 6000);
                // Toon fout in rooster container
                if (roosterContainer) {
                    roosterContainer.innerHTML = `<div class="p-4 text-red-600">Kon de pagina niet correct laden. Probeer te vernieuwen of neem contact op met de beheerder. Details: ${error.message}</div>`;
                }
                // Verberg de registratiemelding bij een algemene laadfout
                verbergRegistratieMelding();
            }
        });

    </script>

</body>
</html>
