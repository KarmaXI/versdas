    <!DOCTYPE html>
    <html lang="nl">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Teamverlofrooster</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://som.org.om.local/sites/MulderT/CustomPW/Verlof/CPW/Vurli/js/config.js"></script>
        <script src="https://som.org.om.local/sites/MulderT/CustomPW/Verlof/CPW/Vurli/js/medewerkerForm.js"></script>
        <script src="https://som.org.om.local/sites/MulderT/CustomPW/Verlof/CPW/Vurli/js/CRUD.js"></script> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
        <style>
            /* Definieer fallback CSS variabelen als V2.css niet geladen is */
            :root {
                --color-gray-100: #f3f4f6; --color-gray-200: #e5e7eb; --color-gray-300: #d1d5db;
                --color-gray-400: #9ca3af; --color-gray-500: #6b7280; --color-gray-700: #374151;
                --color-primary: #2563eb; --color-primary-light: #dbeafe; --color-green: #10b981;
                --color-yellow: #f59e0b; --color-violet: #8b5cf6; --color-red: #ef4444;
            }
            /* Bestaande stijlen... */
            .roster-table th, .roster-table td { height: 55px; padding: 2px; text-align: center; border: 1px solid var(--color-gray-200); }
            .roster-table thead th { vertical-align: top; padding-top: 4px; }
            .employee-col { width: 220px; vertical-align: middle; text-align: left; padding-left: 8px; padding-right: 8px; position: sticky; left: 0; background-color: white; z-index: 10; }
            .roster-table thead .employee-col { background-color: var(--color-gray-100); z-index: 11; }
            .day-header-abbr { font-size: 0.75rem; font-weight: 600; color: var(--color-gray-500); display: block; margin-bottom: 2px; }
            .day-header-date { font-size: 0.875rem; font-weight: normal; color: var(--color-gray-700); display: block; }
            .day-header.today .day-header-date { color: var(--color-primary); font-weight: bold; }
            .day-header.weekend .day-header-abbr, .day-header.weekend .day-header-date { color: var(--color-gray-500); }
            .day-cell { min-width: 45px; vertical-align: middle; position: relative; cursor: pointer; transition: background-color 0.2s; }
            .day-cell:hover { background-color: var(--color-gray-100); }
            .day-cell.other-month { background-color: var(--color-gray-100); color: var(--color-gray-400); }
            .day-cell.other-month:hover { background-color: var(--color-gray-200); }
            .day-cell.weekend {
                background-color: var(--color-gray-100);
                background-image: linear-gradient( to bottom right, var(--color-gray-100) 0%, var(--color-gray-100) calc(50% - 2px), var(--color-gray-300) 50%, var(--color-gray-100) calc(50% + 2px), var(--color-gray-100) 100% );
            }
            .day-cell.weekend:hover {
                background-color: var(--color-gray-200);
                background-image: linear-gradient( to bottom right, var(--color-gray-200) 0%, var(--color-gray-200) calc(50% - 2px), var(--color-gray-400) 50%, var(--color-gray-200) calc(50% + 2px), var(--color-gray-200) 100% );
            }
            .leave-indicator-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0.6; z-index: 1; }
            .day-cell span, .day-cell i { position: relative; z-index: 2; }
            .search-box { position: relative; }
            .search-input { padding-left: 2.5rem; border: 1px solid var(--color-gray-300); border-radius: 0.375rem; height: 38px; }
            .search-icon { position: absolute; left: 0.75rem; top: 50%; transform: translateY(-50%); color: var(--color-gray-400); }
            .team-select { border: 1px solid var(--color-gray-300); border-radius: 0.375rem; height: 38px; padding-left: 0.75rem; padding-right: 2rem; background-position: right 0.75rem center; }
            .view-btn.active { background-color: var(--color-primary-light); color: var(--color-primary); font-weight: 600; }
            .legenda-section { border: 1px solid var(--color-gray-200); border-radius: 0.375rem; padding: 0.75rem; flex: 1 1 200px; min-width: 200px; position: relative; }
            .legenda-section-title { font-weight: 600; color: var(--color-gray-700); margin-bottom: 0.5rem; padding-bottom: 0.25rem; border-bottom: 1px solid var(--color-gray-200); }
            .legend-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; margin-bottom: 0.25rem; }
            .legend-color { width: 1rem; height: 1rem; border-radius: 0.25rem; display: inline-block; border: 1px solid rgba(0,0,0,0.1); flex-shrink: 0; }
            .legend-color.weekend-pattern {
                background-color: var(--color-gray-100);
                background-image: linear-gradient( to bottom right, var(--color-gray-100) 0%, var(--color-gray-100) 45%, var(--color-gray-300) 50%, var(--color-gray-100) 55%, var(--color-gray-100) 100% );
            }
            .pattern-diag-right { 
                background-image: linear-gradient(135deg, rgba(0,0,0,0.2) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.2) 50%, rgba(0,0,0,0.2) 75%, transparent 75%, transparent 100%); 
                background-size: 8px 8px; 
            }
            .pattern-diag-left { 
                background-image: linear-gradient(45deg, rgba(0,0,0,0.2) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.2) 50%, rgba(0,0,0,0.2) 75%, transparent 75%, transparent 100%); 
                background-size: 8px 8px; 
            }
            .pattern-kruis { 
                background-image: linear-gradient(45deg, rgba(0,0,0,0.2) 25%, transparent 25%), linear-gradient(-45deg, rgba(0,0,0,0.2) 25%, transparent 25%); 
                background-size: 8px 8px; 
            }
            .pattern-plus { 
                background-image: linear-gradient(rgba(0,0,0,0.2) 1px, transparent 1px), linear-gradient(to right, rgba(0,0,0,0.2) 1px, transparent 1px); 
                background-size: 6px 6px; 
            }
            .employee-details { display: flex; flex-direction: column; justify-content: center; overflow: hidden; }
            .avatar { flex-shrink: 0; width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: 600; font-size: 0.875rem; overflow: hidden; }
            .avatar img { width: 100%; height: 100%; object-fit: cover; }
            .avatar-initials { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; }
            .legenda-edit-btn { position: absolute; top: 0.5rem; right: 0.5rem; cursor: pointer; color: var(--color-gray-400); padding: 0.25rem; font-size: 0.8rem; }
            .legenda-edit-btn:hover { color: var(--color-primary); }
            #edit-section-view { background-color: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1); }
            .edit-table { width: 100%; border-collapse: collapse; }
            .edit-table th, .edit-table td { border: 1px solid var(--color-gray-200); padding: 0.5rem; text-align: left; vertical-align: middle; }
            .edit-table th { background-color: var(--color-gray-100); font-weight: 600; font-size: 0.875rem; }
            .edit-table td { font-size: 0.875rem; }
            .edit-table input[type="text"], .edit-table input[type="color"], .edit-table select { width: 100%; padding: 0.25rem 0.5rem; border: 1px solid var(--color-gray-300); border-radius: 0.25rem; font-size: 0.875rem; height: 34px; }
            .edit-table input[type="color"] { padding: 0.1rem; cursor: pointer; }
            .edit-table .action-buttons button { margin-right: 0.5rem; background: none; border: none; cursor: pointer; padding: 0.25rem; }
            .edit-table .action-buttons button:hover { opacity: 0.7; }
            .edit-table tr.is-new td { background-color: var(--color-primary-light); }

            /* Notification styles */
            .notification {
                padding: 0.75rem 1rem;
                margin-bottom: 0.75rem;
                border-radius: 0.375rem;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                display: flex;
                align-items: center;
                justify-content: space-between;
                max-width: 24rem;
                opacity: 0;
                transform: translateY(-1rem);
                transition: opacity 0.3s, transform 0.3s;
            }
            .notification.show {
                opacity: 1;
                transform: translateY(0);
            }
            .notification-success {
                background-color: #d1fae5;
                border-left: 4px solid #10b981;
                color: #065f46;
            }
            .notification-error {
                background-color: #fee2e2;
                border-left: 4px solid #ef4444;
                color: #991b1b;
            }
            .notification-info {
                background-color: #dbeafe;
                border-left: 4px solid #3b82f6;
                color: #1e40af;
            }
            .notification-close {
                background: transparent;
                border: none;
                color: currentColor;
                cursor: pointer;
                padding: 0;
                margin-left: 0.5rem;
                font-size: 1rem;
                opacity: 0.6;
            }
            .notification-close:hover {
                opacity: 1;
            }
        </style>
    </head>
    <body class="bg-gray-100">

        <header class="header bg-white border-b border-gray-200 px-4 py-2 sticky top-0 z-30">
            <div class="container mx-auto flex items-center"> <div class="logo flex items-center gap-2 text-lg font-semibold text-gray-800 mr-auto"> <i class="fas fa-calendar-alt text-primary"></i> <span>Teamverlofrooster</span> </div> <div class="actions flex items-center gap-2"> <button class="btn-export p-2 text-lg bg-green-700 text-white rounded hover:bg-green-800" title="Exporteer naar Excel"> <i class="fas fa-file-excel fa-fw"></i> </button> <button class="btn btn-primary flex items-center gap-1"> <i class="fas fa-plus fa-fw"></i> <span>Toevoegen</span> </button> </div> <div class="user-info ml-4 relative"> <button class="flex items-center gap-2 text-sm text-gray-600 hover:text-gray-800"> <i class="fas fa-question-circle text-lg"></i> <span>Niet ingelogd</span> <i class="fas fa-chevron-down fa-xs ml-1"></i> </button> </div> </div>
        </header>

        <div id="main-view" class="container mx-auto p-4">

            <div class="control-panel mb-4 bg-white p-3 rounded-lg shadow flex flex-wrap items-center gap-3">
                <div class="period-selector flex items-center"> <div class="period-nav flex items-center bg-gray-100 p-1 rounded-md shadow-sm"> <button id="btn-prev" class="period-nav-btn bg-white border border-gray-200 rounded px-2 py-1 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-light"> <i class="fas fa-chevron-left fa-fw text-gray-600"></i> </button> <span id="period-display" class="period-display font-semibold text-gray-700 px-4 min-w-[150px] text-center text-sm">Laden...</span> <button id="btn-next" class="period-nav-btn bg-white border border-gray-200 rounded px-2 py-1 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-light"> <i class="fas fa-chevron-right fa-fw text-gray-600"></i> </button> </div> <button id="btn-today" class="btn btn-secondary text-sm ml-2" style="height: 38px;"> Vandaag </button> </div> <div class="view-selector flex items-center"> <div class="view-btn-group flex bg-gray-100 rounded-md p-1"> <button id="btn-view-week" class="view-btn px-3 py-1 text-sm rounded-md" data-view="week">Week</button> <button id="btn-view-month" class="view-btn px-3 py-1 text-sm rounded-md" data-view="month">Maand</button> </div> </div> <div class="search-box flex-grow md:flex-grow-0 md:w-64"> <i class="fas fa-search search-icon"></i> <input type="text" id="search-input" placeholder="Zoek medewerker..." class="search-input w-full text-sm px-10 py-2"> </div> <div class="team-selector flex items-center gap-2 ml-auto"> <label for="team-select" class="text-sm font-medium text-gray-600">Team:</label> <select id="team-select" class="team-select text-sm bg-white"> <option value="all">Alle teams</option> <option value="alfa">Team Alfa</option> <option value="beta">Team Beta</option> <option value="gamma">Team Gamma</option> </select> </div>
            </div>

            <div id="legenda-outer-container" class="mb-4 bg-white rounded-lg shadow">
                <button id="legenda-toggle-btn" class="w-full flex justify-between items-center p-3 text-left font-semibold text-gray-700 hover:bg-gray-50 rounded-t-lg">
                    <span>Legenda</span>
                    <i id="legenda-toggle-icon" class="fas fa-chevron-down transition-transform"></i>
                </button>
                <div id="legenda-content" class="p-3 border-t border-gray-200 hidden">
                    <div class="flex flex-wrap gap-4">
                        <div id="legenda-bijzonderheden" class="legenda-section"> <h4 class="legenda-section-title">Bijzonderheden</h4> </div>
                        <div id="legenda-verlof" class="legenda-section"> <h4 class="legenda-section-title">Verlof</h4> </div>
                        <div id="legenda-werkweek" class="legenda-section"> <h4 class="legenda-section-title">Werkweek-indicaties</h4> </div>
                        <div id="legenda-terugkerend" class="legenda-section"> <h4 class="legenda-section-title">Terugkerende zaken</h4> </div>
                    </div>
                </div>
            </div>

            <div id="roster-container" class="team-roster bg-white rounded-lg shadow overflow-hidden">
                <div class="roster-table-wrapper overflow-x-auto">
                    <table id="roster-table" class="roster-table w-full border-collapse table-fixed">
                        <thead></thead>
                        <tbody><tr><td colspan="8" class="text-center p-10 text-gray-500"><i class="fas fa-spinner fa-spin mr-2"></i> Rooster laden...</td></tr></tbody>
                    </table>
                </div>
            </div>

        </div> <div id="edit-section-view" class="container mx-auto p-4 hidden">
            <div class="bg-white p-6 rounded-lg shadow-md">
                <div class="flex justify-between items-center mb-4 pb-2 border-b">
                    <h2 id="edit-section-title" class="text-xl font-semibold text-gray-800">Bewerk Legenda</h2>
                    <button id="edit-section-back-btn" class="btn btn-secondary text-sm">
                        <i class="fas fa-arrow-left mr-1"></i> Terug naar Rooster
                    </button>
                </div>
                <div id="edit-section-content" class="overflow-x-auto"></div>
                <div class="mt-4 text-right">
                    <button id="btn-add-new-item" class="btn btn-primary text-sm">
                        <i class="fas fa-plus mr-1"></i> Nieuw Item Toevoegen
                    </button>
                </div>
            </div>
        </div>

        <div id="notification-container" class="fixed bottom-4 right-4 z-50"></div>

        <script>
            // --- Globale variabelen ---
            let huidigeDatum = new Date(2025, 3, 15);
            let huidigeWeergave = 'month';
            let medewerkers = [];
            let verlofData = [];
            let verlofRedenen = [];
            let dagenIndicatoren = [];
            const appConfiguratie = typeof configuratie !== 'undefined' ? configuratie : null;
            let huidigeEditSectie = null;

            // --- DOM Elementen ---
            const mainView = document.getElementById('main-view');
            const editSectionView = document.getElementById('edit-section-view');
            const editSectionTitle = document.getElementById('edit-section-title');
            const editSectionContent = document.getElementById('edit-section-content');
            const editSectionBackBtn = document.getElementById('edit-section-back-btn');
            const btnAddNewItem = document.getElementById('btn-add-new-item');
            const roosterTabel = document.getElementById('roster-table');
            const periodeDisplay = document.getElementById('period-display');
            const btnPrev = document.getElementById('btn-prev');
            const btnNext = document.getElementById('btn-next');
            const btnToday = document.getElementById('btn-today');
            const btnViewMonth = document.getElementById('btn-view-month');
            const btnViewWeek = document.getElementById('btn-view-week');
            const searchInput = document.getElementById('search-input');
            const teamSelect = document.getElementById('team-select');
            const legendaOuterContainer = document.getElementById('legenda-outer-container');
            const legendaToggleBtn = document.getElementById('legenda-toggle-btn');
            const legendaToggleIcon = document.getElementById('legenda-toggle-icon');
            const legendaContent = document.getElementById('legenda-content');
            const legendaBijzonderheden = document.getElementById('legenda-bijzonderheden');
            const legendaVerlof = document.getElementById('legenda-verlof');
            const legendaWerkweek = document.getElementById('legenda-werkweek');
            const legendaTerugkerend = document.getElementById('legenda-terugkerend');

            // --- Constanten ---
            const maandNamen = ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Juli", "Augustus", "September", "Oktober", "November", "December"];
            const dagNamenKort = ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"];

            // --- DATA OPHALEN ---
            // Functies haalLijstDataOp, buildODataQuery, haalUserProfilePropertiesOp, haalMedewerkersOp, haalVerlofOp, haalVerlofRedenenOp, haalDagenIndicatorenOp
            // blijven ongewijzigd. Zorg dat CRUD.js geladen is voor de CRUD functies.
            async function haalLijstDataOp(fetchUrl) { /* ... ongewijzigd ... */ console.log(`Lijst data ophalen via: ${fetchUrl}`); try { const response = await fetch(fetchUrl, { method: 'GET', headers: { 'Accept': 'application/json;odata=verbose' } }); if (!response.ok) { let errorDetails = response.statusText; try { const errorData = await response.json(); errorDetails = errorData?.error?.message?.value || errorDetails; } catch (e) {} const fout = new Error(`HTTP fout: ${response.status} - ${errorDetails}`); fout.status = response.status; throw fout; } const data = await response.json(); if (data && data.d && data.d.results) { return data.d.results; } else { console.warn("Onverwachte datastructuur lijst:", data); return data?.d || data || []; } } catch (error) { console.error(`Fout tijdens fetch lijst naar ${fetchUrl}:`, error); if (!error.status) { error.message = `Netwerkfout: ${error.message}`; } throw error; } }
            function buildODataQuery(params) { /* ... ongewijzigd ... */ const queryParts = []; if (params.select) queryParts.push(`$select=${params.select}`); if (params.filter) queryParts.push(`$filter=${params.filter}`); if (params.expand) queryParts.push(`$expand=${params.expand}`); if (params.orderby) queryParts.push(`$orderby=${params.orderby}`); if (queryParts.length === 0) return ""; return "?" + queryParts.join("&"); }
            async function haalUserProfilePropertiesOp(accountName) { /* ... ongewijzigd ... */ const baseUrl = `${window.location.origin}/_api/SP.UserProfiles.PeopleManager`; const apiUrl = `${baseUrl}/GetPropertiesFor(accountName=@v)?@v='${encodeURIComponent(accountName)}'`; const selectQuery = "&$select=DisplayName,Email,PictureUrl,UserProfileProperties"; console.log(`User profile ophalen via: ${apiUrl + selectQuery}`); try { const response = await fetch(apiUrl + selectQuery, { method: 'GET', headers: { 'Accept': 'application/json;odata=verbose' } }); if (!response.ok) { console.error(`HTTP fout ${response.status} bij ophalen profiel voor ${accountName}: ${response.statusText}`); return null; } const data = await response.json(); if (data && data.d && data.d.GetPropertiesFor) { const profileData = data.d.GetPropertiesFor; const properties = {}; properties.DisplayName = profileData.DisplayName; properties.Email = profileData.Email; properties.PictureUrl = profileData.PictureUrl || null; properties.MobilePhone = null; if (profileData.UserProfileProperties && profileData.UserProfileProperties.results) { const cellPhoneProp = profileData.UserProfileProperties.results.find(prop => prop.Key === 'CellPhone'); if (cellPhoneProp) { properties.MobilePhone = cellPhoneProp.Value; } else { const mobilePhoneProp = profileData.UserProfileProperties.results.find(prop => prop.Key === 'MobilePhone'); if (mobilePhoneProp) { properties.MobilePhone = mobilePhoneProp.Value; } } } return properties; } else { console.warn(`Onverwachte profiel data structuur voor ${accountName}:`, data); return null; } } catch (error) { console.error(`Fout tijdens fetch profiel voor ${accountName}:`, error); return null; } }
            async function haalMedewerkersOp() { /* ... ongewijzigd ... */ console.log("Basis medewerkerslijst ophalen..."); if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar."); let basisMedewerkers = []; try { const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === "835ae977-8cd1-4eb8-a787-23aa2d76228d"); if (!lijstConfig) throw new Error("Configuratie voor Medewerkers lijst niet gevonden."); const baseUrl = lijstConfig.lijstInformatie.apiUrl; const query = buildODataQuery({ select: "ID,Naam,Team,Actief,E_x002d_mail" }); const data = await haalLijstDataOp(baseUrl + query); basisMedewerkers = data.filter(m => m.Actief); console.log("Basis medewerkers geladen:", basisMedewerkers.length); const profilePromises = basisMedewerkers.map(medewerker => { const email = medewerker['E_x002d_mail']; if (email) { const accountName = `i:0#.f|membership|${email}`; return haalUserProfilePropertiesOp(accountName); } else { console.warn(`Medewerker ${medewerker.Naam || medewerker.ID} heeft geen e-mailadres in lijst, kan profiel niet ophalen.`); return Promise.resolve(null); } }); console.log(`Bezig met ophalen van ${profilePromises.length} gebruikersprofielen... (Dit kan even duren)`); const profielResultaten = await Promise.all(profilePromises); console.log("Gebruikersprofielen opgehaald."); medewerkers = basisMedewerkers.map((medewerker, index) => { const profiel = profielResultaten[index]; return { ...medewerker, pictureUrl: profiel?.PictureUrl || null, emailFromProfile: profiel?.Email || medewerker['E_x002d_mail'], mobilePhone: profiel?.MobilePhone || null, displayNameFromProfile: profiel?.DisplayName || medewerker.Naam }; }); } catch (error) { console.error("Fout bij ophalen medewerkers of profielen:", error); medewerkers = basisMedewerkers.map(m => ({ ...m, pictureUrl: null, emailFromProfile: m['E_x002d_mail'], mobilePhone: null, displayNameFromProfile: m.Naam })); throw error; } return medewerkers; }
            async function haalVerlofOp(startDatum, eindDatum) { /* ... ongewijzigd ... */ console.log(`Verlof ophalen tussen ${startDatum.toLocaleDateString()} en ${eindDatum.toLocaleDateString()}...`); if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar."); try { const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === "e12a068f-2821-4fe1-b898-e42e1418edf8"); if (!lijstConfig) throw new Error("Configuratie voor Verlof lijst niet gevonden."); const baseUrl = lijstConfig.lijstInformatie.apiUrl; const isoStart = startDatum.toISOString(); const isoEind = eindDatum.toISOString(); const query = buildODataQuery({ select: "MedewerkerID,StartDatum,EindDatum,Reden", filter: `(StartDatum le datetime'${isoEind}') and (EindDatum ge datetime'${isoStart}')` }); const data = await haalLijstDataOp(baseUrl + query); verlofData = data.map(item => ({ ...item, StartDatum: item.StartDatum ? new Date(item.StartDatum).toISOString().split('T')[0] : null, EindDatum: item.EindDatum ? new Date(item.EindDatum).toISOString().split('T')[0] : null, })); console.log("Verlof data geladen:", verlofData.length); } catch (error) { console.error("Fout bij ophalen verlof:", error); verlofData = []; throw error; } return verlofData; }
            async function haalVerlofRedenenOp() { /* ... ongewijzigd ... */ console.log("Verlof redenen ophalen..."); if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar."); try { const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === "6ca65cc0-ad60-49c9-9ee4-371249e55c7d"); if (!lijstConfig) throw new Error("Configuratie voor Verlofredenen lijst niet gevonden."); const baseUrl = lijstConfig.lijstInformatie.apiUrl; const query = buildODataQuery({ select: "ID,Title,Naam,Kleur" }); const data = await haalLijstDataOp(baseUrl + query); verlofRedenen = data; console.log("Verlof redenen geladen:", verlofRedenen.length); } catch (error) { console.error("Fout bij ophalen verlofredenen:", error); verlofRedenen = []; } renderLegenda(); return verlofRedenen; }
            async function haalDagenIndicatorenOp() { /* ... ongewijzigd ... */ console.log("Dagen indicatoren ophalen..."); if (!appConfiguratie) throw new Error("Configuratie object is niet beschikbaar."); try { const lijstConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.guid === "45528ed2-cdff-4958-82e4-e3eb032fd0aa"); if (!lijstConfig) throw new Error("Configuratie voor DagenIndicators lijst niet gevonden."); const baseUrl = lijstConfig.lijstInformatie.apiUrl; const query = buildODataQuery({ select: "ID,Title,Kleur,Patroon" }); const data = await haalLijstDataOp(baseUrl + query); dagenIndicatoren = data; console.log("Dagen indicatoren geladen:", dagenIndicatoren.length); } catch (error) { console.error("Fout bij ophalen dagen indicatoren:", error); dagenIndicatoren = []; } renderLegenda(); return dagenIndicatoren; }

            // --- HULPFUNCTIES ---
            function getStartOfWeek(datum) { const d = new Date(datum); const day = d.getDay(); const diff = d.getDate() - day + (day === 0 ? -6 : 1); return new Date(d.setDate(diff)); }
            function addDays(datum, dagen) { const result = new Date(datum); result.setDate(result.getDate() + dagen); return result; }
            function isSameDay(d1, d2) { if (!d1 || !d2) return false; return d1.getFullYear() === d2.getFullYear() && d1.getMonth() === d2.getMonth() && d1.getDate() === d2.getDate(); }
            function getKleurVoorVerlofReden(redenTitel) { const reden = verlofRedenen.find(r => r.Title === redenTitel || r.Naam === redenTitel); return reden?.Kleur || 'var(--color-gray-300)'; }
            function getInitials(naam) { if (!naam) return '?'; const parts = naam.split(' '); if (parts.length === 1) return naam.substring(0, 2).toUpperCase(); return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase(); }
            function getAvatarColor(name) { let hash = 0; for (let i = 0; i < name.length; i++) { hash = name.charCodeAt(i) + ((hash << 5) - hash); } const color = (hash & 0x00FFFFFF).toString(16).toUpperCase(); return "#" + "00000".substring(0, 6 - color.length) + color; }
            function getGuidForSection(sectionName) { switch(sectionName) { case 'Verlof': return "6ca65cc0-ad60-49c9-9ee4-371249e55c7d"; case 'Werkweek-indicaties': return "45528ed2-cdff-4958-82e4-e3eb032fd0aa"; default: return null; } }
            function getDataArrayForSection(sectionName) { switch(sectionName) { case 'Verlof': return verlofRedenen; case 'Werkweek-indicaties': return dagenIndicatoren; default: return []; } }
            function getFieldsForSection(sectionName) { 
                switch(sectionName) { 
                    case 'Verlof': 
                        return [ 
                            { key: 'Title', type: 'text', label: 'Naam', internalName: 'Title' }, 
                            { key: 'Kleur', type: 'color', label: 'Kleur', internalName: 'Kleur' } 
                        ]; 
                    case 'Werkweek-indicaties': 
                        return [ 
                            { key: 'Title', type: 'text', label: 'Naam', internalName: 'Title' }, 
                            { key: 'Kleur', type: 'color', label: 'Kleur', internalName: 'Kleur' }, 
                            { key: 'Patroon', type: 'select', label: 'Patroon', internalName: 'Patroon', 
                            options: [
                                { value: '', label: 'Geen patroon' },
                                { value: 'Diagonale lijn (rechts)', label: 'Diagonale lijn (rechts)' },
                                { value: 'Diagonale lijn (links)', label: 'Diagonale lijn (links)' },
                                { value: 'Kruis', label: 'Kruis' },
                                { value: 'Plus', label: 'Plus' }
                            ]
                            } 
                        ]; 
                    default: 
                        return []; 
                } 
            }

            // --- WEERGAVE FUNCTIES ---
            function updatePeriodeDisplay() { /* ... ongewijzigd ... */ const jaar = huidigeDatum.getFullYear(); const maand = huidigeDatum.getMonth(); if (huidigeWeergave === 'month') { periodeDisplay.textContent = `${maandNamen[maand]} ${jaar}`; } else if (huidigeWeergave === 'week') { const startVanWeek = getStartOfWeek(huidigeDatum); const eindVanWeek = addDays(startVanWeek, 6); const d = new Date(Date.UTC(startVanWeek.getFullYear(), startVanWeek.getMonth(), startVanWeek.getDate())); const dayNum = d.getUTCDay() || 7; d.setUTCDate(d.getUTCDate() + 4 - dayNum); const yearStart = new Date(Date.UTC(d.getUTCFullYear(),0,1)); const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1)/7); periodeDisplay.textContent = `Week ${weekNo}: ${startVanWeek.getDate()} ${maandNamen[startVanWeek.getMonth()].substring(0,3)} - ${eindVanWeek.getDate()} ${maandNamen[eindVanWeek.getMonth()].substring(0,3)}`; } }
            function updateActiveViewButtons() { /* ... ongewijzigd ... */ if (huidigeWeergave === 'month') { btnViewMonth.classList.add('active'); btnViewWeek.classList.remove('active'); } else { btnViewWeek.classList.add('active'); btnViewMonth.classList.remove('active'); } }
            function renderLegenda() { /* ... ongewijzigd ... */ const createLegendItem = (text, color, patternClass = '') => { const item = document.createElement('div'); item.className = 'legend-item'; const colorSpan = document.createElement('span'); colorSpan.className = `legend-color ${patternClass}`; colorSpan.style.backgroundColor = color; item.appendChild(colorSpan); const textSpan = document.createElement('span'); textSpan.textContent = text || '-'; item.appendChild(textSpan); return item; }; const getPatternClass = (patternName) => { switch(patternName) { case 'Diagonale lijn (rechts)': return 'pattern-diag-right'; case 'Diagonale lijn (links)': return 'pattern-diag-left'; case 'Kruis': return 'pattern-kruis'; case 'Plus': return 'pattern-plus'; default: return ''; } }; const fillSection = (container, title, data, textKey, colorKey, patternKey = null, sectionIdentifier) => { container.querySelectorAll('.legend-item, .text-gray-500').forEach(el => el.remove()); if (!container.querySelector('.legenda-edit-btn')) { const editBtn = document.createElement('button'); editBtn.className = 'legenda-edit-btn'; editBtn.innerHTML = '<i class="fas fa-pencil-alt fa-fw"></i>'; editBtn.title = `Bewerk ${title}`; editBtn.dataset.section = sectionIdentifier; container.appendChild(editBtn); } if (data && data.length > 0) { data.forEach(item => { const text = item[textKey] || item['Title'] || item['Naam']; const color = item[colorKey]; const patternName = patternKey ? item[patternKey] : null; const patternClass = getPatternClass(patternName); const legendItem = createLegendItem(text, color, patternClass); if (patternClass && color) { const colorSpan = legendItem.querySelector('.legend-color'); colorSpan.style.backgroundColor = color; colorSpan.style.backgroundImage = colorSpan.style.backgroundImage; } container.appendChild(legendItem); }); } else { const noDataItem = document.createElement('div'); noDataItem.className = 'legend-item text-gray-500 italic'; noDataItem.textContent = `Kon ${title.toLowerCase()} niet laden.`; container.appendChild(noDataItem); } }; fillSection(legendaVerlof, "Verlof", verlofRedenen, "Title", "Kleur", null, "Verlof"); fillSection(legendaWerkweek, "Werkweek-indicaties", dagenIndicatoren, "Title", "Kleur", "Patroon", "Werkweek-indicaties"); legendaTerugkerend.querySelectorAll('.legend-item').forEach(el => el.remove()); if (!legendaTerugkerend.querySelector('.legenda-edit-btn')) { const editBtn = document.createElement('button'); editBtn.className = 'legenda-edit-btn'; editBtn.innerHTML = '<i class="fas fa-pencil-alt fa-fw"></i>'; editBtn.title = `Bewerk Terugkerende zaken`; editBtn.dataset.section = "Terugkerende zaken"; legendaTerugkerend.appendChild(editBtn); } legendaTerugkerend.appendChild(createLegendItem('Weekend', '', 'weekend-pattern')); legendaBijzonderheden.querySelectorAll('.legend-item').forEach(el => el.remove()); if (!legendaBijzonderheden.querySelector('.legenda-edit-btn')) { const editBtn = document.createElement('button'); editBtn.className = 'legenda-edit-btn'; editBtn.innerHTML = '<i class="fas fa-pencil-alt fa-fw"></i>'; editBtn.title = `Bewerk Bijzonderheden`; editBtn.dataset.section = "Bijzonderheden"; legendaBijzonderheden.appendChild(editBtn); } if (legendaBijzonderheden.querySelectorAll('.legend-item').length === 0) { const noDataItem = document.createElement('div'); noDataItem.className = 'legend-item text-gray-500 italic'; noDataItem.textContent = 'Geen items.'; legendaBijzonderheden.appendChild(noDataItem); } }
            async function renderRooster() { 
                console.log(`Render ${huidigeWeergave} view`); 
                const jaar = huidigeDatum.getFullYear(); 
                const maand = huidigeDatum.getMonth(); 
                const vandaag = new Date(); 
                let viewStartDate, viewEndDate, dataStartDate, dataEndDate; 
                let dagenInWeergave = []; 
                if (huidigeWeergave === 'month') { 
                    const eersteDagVanMaand = new Date(jaar, maand, 1); 
                    let startDagIndex = eersteDagVanMaand.getDay(); 
                    startDagIndex = startDagIndex === 0 ? 6 : startDagIndex - 1; 
                    viewStartDate = addDays(eersteDagVanMaand, -startDagIndex); 
                    viewEndDate = addDays(viewStartDate, 41); 
                    dataStartDate = addDays(viewStartDate, -7); 
                    dataEndDate = addDays(viewEndDate, 7); 
                    for (let i = 0; i < 42; i++) { 
                        dagenInWeergave.push(addDays(viewStartDate, i)); 
                    } 
                } else { 
                    viewStartDate = getStartOfWeek(huidigeDatum); 
                    viewEndDate = addDays(viewStartDate, 6); 
                    dagenInWeergave = []; 
                    for (let i = 0; i < 7; i++) { 
                        dagenInWeergave.push(addDays(viewStartDate, i)); 
                    } 
                    dataStartDate = viewStartDate; 
                    dataEndDate = viewEndDate; 
                } 
                await haalVerlofOp(dataStartDate, dataEndDate); 
                const zoekTerm = searchInput.value.toLowerCase(); 
                const geselecteerdTeam = teamSelect.value; 
                // --- Groepeer medewerkers per team --- 
                const gefilterdeMedewerkers = medewerkers.filter(m => { 
                    const naamMatch = (m.displayNameFromProfile || m.Naam)?.toLowerCase().includes(zoekTerm); 
                    const teamMatch = geselecteerdTeam === 'all' || m.Team === geselecteerdTeam; 
                    return naamMatch && teamMatch; 
                }); 
                // Maak een mapping: teamnaam => medewerkers[] 
                const teamMap = {}; 
                gefilterdeMedewerkers.forEach(medewerker => { 
                    const team = medewerker.Team || 'Geen team'; 
                    if (!teamMap[team]) teamMap[team] = []; 
                    teamMap[team].push(medewerker); 
                }); 
                // Sorteer teams alfabetisch 
                const teamNamen = Object.keys(teamMap).sort((a, b) => a.localeCompare(b, 'nl')); 
                const thead = roosterTabel.querySelector('thead'); 
                thead.innerHTML = ''; 
                const headerRow = document.createElement('tr'); 
                const thEmployee = document.createElement('th'); 
                thEmployee.className = 'employee-col'; 
                thEmployee.textContent = 'Medewerker'; 
                headerRow.appendChild(thEmployee); 
                dagenInWeergave.forEach(dag => { 
                    const thDay = document.createElement('th'); 
                    const dagVanWeek = dag.getDay(); 
                    const isWeekend = dagVanWeek === 0 || dagVanWeek === 6; 
                    const isVandaag = isSameDay(dag, vandaag); 
                    thDay.className = 'day-header'; 
                    if (isWeekend) thDay.classList.add('weekend'); 
                    if (isVandaag) thDay.classList.add('today'); 
                    if (huidigeWeergave === 'month' && dag.getMonth() !== maand) { 
                        thDay.classList.add('other-month-header', 'opacity-50'); 
                    } 
                    thDay.innerHTML = `<span class="day-header-abbr">${dagNamenKort[dagVanWeek]}</span><span class="day-header-date">${dag.getDate()}</span>`; 
                    headerRow.appendChild(thDay); 
                }); 
                thead.appendChild(headerRow); 
                const tbody = roosterTabel.querySelector('tbody'); 
                tbody.innerHTML = ''; 
                if (gefilterdeMedewerkers.length === 0) { 
                    tbody.innerHTML = `<tr><td colspan="${dagenInWeergave.length + 1}" class="text-center p-5 text-gray-500">Geen medewerkers gevonden...</td></tr>`; 
                } 
                // --- Render per team --- 
                teamNamen.forEach(teamNaam => { 
                    // Team header row 
                    const teamRow = document.createElement('tr'); 
                    const teamCell = document.createElement('td'); 
                    teamCell.colSpan = dagenInWeergave.length + 1; 
                    teamCell.className = 'bg-gray-50 font-semibold text-left text-primary px-4 py-2'; 
                    teamCell.textContent = teamNaam; 
                    teamRow.appendChild(teamCell); 
                    tbody.appendChild(teamRow); 
                    // Medewerkers van dit team 
                    teamMap[teamNaam].forEach(medewerker => { 
                        const medewerkerRow = document.createElement('tr'); 
                        const tdEmployee = document.createElement('td'); 
                        tdEmployee.className = 'employee-col'; 
                        const email = medewerker.emailFromProfile || medewerker['E_x002d_mail'] || ''; 
                        const medewerkerNaam = medewerker.displayNameFromProfile || medewerker.Naam || 'Onbekende Medewerker'; 
                        const mobielNummer = medewerker.mobilePhone || '-'; 
                        const profielFotoUrl = medewerker.pictureUrl; 
                        const initials = getInitials(medewerkerNaam); 
                        const avatarColor = getAvatarColor(medewerkerNaam); 
                        const tooltipText = `E-mail: ${email || '-'}\nMobiel: ${mobielNummer}`; 
                        tdEmployee.innerHTML = ` <div class="employee-info flex items-center gap-2 h-full" title="${tooltipText}"> <div class="avatar" style="background-color: ${avatarColor};"> ${profielFotoUrl ? `<img src="${profielFotoUrl}" alt="Foto van ${medewerkerNaam}" class="w-full h-full object-cover" onerror="this.onerror=null; this.outerHTML = '<div class=\\'avatar-initials\\'>${initials}</div>'; ">` : `<div class="avatar-initials">${initials}</div>`} </div> <div class="employee-details flex-grow"> <span class="employee-name block text-sm font-medium text-gray-800 truncate" title="${medewerkerNaam}">${medewerkerNaam}</span> </div> </div> `; 
                        medewerkerRow.appendChild(tdEmployee); 
                        dagenInWeergave.forEach(dag => { 
                            const tdDay = document.createElement('td'); 
                            const dagVanWeek = dag.getDay(); 
                            const isWeekend = dagVanWeek === 0 || dagVanWeek === 6; 
                            const isVandaag = isSameDay(dag, vandaag); 
                            const isAndereMaand = huidigeWeergave === 'month' && dag.getMonth() !== maand; 
                            tdDay.className = 'day-cell'; 
                            if (isWeekend) tdDay.classList.add('weekend'); 
                            if (isVandaag) tdDay.classList.add('today'); 
                            if (isAndereMaand) tdDay.classList.add('other-month'); 
                            const dagIsoString = dag.toISOString().split('T')[0]; 
                            verlofData.forEach(verlofItem => { 
                                const verlofMedewerkerId = typeof verlofItem.MedewerkerId === 'object' ? verlofItem.MedewerkerId.Id : verlofItem.MedewerkerId || verlofItem.MedewerkerID; 
                                if (String(verlofMedewerkerId) === String(medewerker.ID)) { 
                                    if (dagIsoString >= verlofItem.StartDatum && dagIsoString <= verlofItem.EindDatum) { 
                                        const indicator = document.createElement('div'); 
                                        indicator.className = 'leave-indicator-bg'; 
                                        const redenText = verlofItem.Reden || 'Onbekend'; 
                                        indicator.style = getLeavePatternStyle(getKleurVoorVerlofReden(redenText));
                                        indicator.title = `${redenText} (${new Date(verlofItem.StartDatum+'T00:00:00').toLocaleDateString()} - ${new Date(verlofItem.EindDatum+'T00:00:00').toLocaleDateString()})`; 
                                        tdDay.appendChild(indicator); 
                                    } 
                                } 
                            }); 
                            medewerkerRow.appendChild(tdDay); 
                        }); 
                        tbody.appendChild(medewerkerRow); 
                    }); 
                }); 
                updatePeriodeDisplay(); 
                updateActiveViewButtons(); 
            }

            // --- Navigatie Functies ---
            function showMainView() { mainView.classList.remove('hidden'); editSectionView.classList.add('hidden'); huidigeEditSectie = null; }
            function showEditSectionView(sectionName) {
        huidigeEditSectie = sectionName;
        mainView.classList.add('hidden');
        editSectionView.classList.remove('hidden');
        editSectionTitle.textContent = `Bewerk Legenda: ${sectionName}`;
        editSectionContent.innerHTML = '<p class="p-4 text-center text-gray-500"><i class="fas fa-spinner fa-spin mr-2"></i> Tabel laden...</p>';

        const dataArray = getDataArrayForSection(sectionName);
        const fields = getFieldsForSection(sectionName);
        const headers = [...fields.map(f => f.label), "Acties"];

        const table = document.createElement('table');
        table.className = 'edit-table min-w-full';
        
        const thead = table.createTHead();
        const headerRow = thead.insertRow();
        headers.forEach(headerText => {
            const th = document.createElement('th');
            th.textContent = headerText;
            headerRow.appendChild(th);
        });

        const tbody = table.createTBody();
        tbody.id = 'edit-table-body';

        if (dataArray && dataArray.length > 0) {
            dataArray.forEach(item => {
                const row = tbody.insertRow();
                row.dataset.itemId = item.ID;
                
                fields.forEach(field => {
                    const cell = row.insertCell();
                    const value = item[field.internalName || field.key] || '';
                    
                    if (field.type === 'readonly') {
                        cell.textContent = value || '-';
                    } else if (field.type === 'select') {
                        const select = document.createElement('select');
                        select.name = field.internalName || field.key;
                        select.className = 'border border-gray-300 rounded px-2 py-1 w-full';
                        
                        field.options.forEach(option => {
                            const optEl = document.createElement('option');
                            optEl.value = option.value;
                            optEl.textContent = option.label;
                            if (value === option.value) {
                                optEl.selected = true;
                            }
                            select.appendChild(optEl);
                        });
                        
                        cell.appendChild(select);
                    } else {
                        const input = document.createElement('input');
                        input.type = field.type;
                        input.name = field.internalName || field.key;
                        input.value = value;
                        input.className = 'border border-gray-300 rounded px-2 py-1 w-full';
                        
                        if (field.type === 'color') {
                            input.style.height = '34px';
                            input.style.padding = '2px';
                            input.value = value.startsWith('#') ? value : '#ffffff';
                        }
                        
                        cell.appendChild(input);
                    }
                });

                const actionCell = row.insertCell();
                actionCell.className = 'action-buttons whitespace-nowrap';
                actionCell.innerHTML = `
                    <button class="btn-save-item text-green-600 hover:text-green-800" title="Opslaan">
                        <i class="fas fa-save fa-fw"></i> Opslaan
                    </button>
                    <button class="btn-delete-item text-red-600 hover:text-red-800" title="Verwijderen">
                        <i class="fas fa-trash-alt fa-fw"></i> Verwijderen
                    </button>
                `;
            });
        } else {
            const row = tbody.insertRow();
            const cell = row.insertCell();
            cell.colSpan = headers.length;
            cell.textContent = 'Geen items gevonden in deze sectie.';
            cell.className = 'text-center text-gray-500 italic py-4';
        }

        editSectionContent.innerHTML = '';
        editSectionContent.appendChild(table);
    }
            function voegNieuweRijToeAanEditTabel() {
        const sectionName = huidigeEditSectie;
        if (!sectionName) return;
        
        const fields = getFieldsForSection(sectionName);
        const tableBody = document.getElementById('edit-table-body');
        if (!tableBody) return;
        
        const newRow = tableBody.insertRow(0);
        newRow.dataset.itemId = "new";
        newRow.classList.add('is-new');
        
        fields.forEach(field => {
            const cell = newRow.insertCell();
            
            if (field.type === 'readonly') {
                cell.textContent = '-';
            } else if (field.type === 'select') {
                const select = document.createElement('select');
                select.name = field.internalName || field.key;
                select.className = 'border border-gray-300 rounded px-2 py-1 w-full';
                select.placeholder = field.label;
                
                field.options.forEach(option => {
                    const optEl = document.createElement('option');
                    optEl.value = option.value;
                    optEl.textContent = option.label;
                    select.appendChild(optEl);
                });
                
                cell.appendChild(select);
            } else {
                const input = document.createElement('input');
                input.type = field.type;
                input.name = field.internalName || field.key;
                input.placeholder = field.label;
                input.className = 'border border-gray-300 rounded px-2 py-1 w-full';
                
                if (field.type === 'color') {
                    input.style.height = '34px';
                    input.style.padding = '2px';
                    input.value = '#cccccc';
                }
                
                cell.appendChild(input);
            }
        });
        
        const actionCell = newRow.insertCell();
        actionCell.className = 'action-buttons whitespace-nowrap';
        actionCell.innerHTML = `
            <button class="btn-save-new-item text-green-600 hover:text-green-800" title="Opslaan">
                <i class="fas fa-save fa-fw"></i> Opslaan
            </button>
            <button class="btn-cancel-new-item text-gray-600 hover:text-gray-800" title="Annuleren">
                <i class="fas fa-times fa-fw"></i> Annuleren
            </button>
        `;
    }

            // --- NOTIFICATION FUNCTIONS ---
            function showNotification(message, type = 'info', duration = 5000) {
                const container = document.getElementById('notification-container');
                const notification = document.createElement('div');
                notification.className = `notification notification-${type}`;
                
                // Create notification content
                const content = document.createElement('div');
                content.className = 'notification-content';
                
                // Add appropriate icon based on type
                let icon = 'info-circle';
                if (type === 'success') icon = 'check-circle';
                if (type === 'error') icon = 'exclamation-circle';
                
                content.innerHTML = `<i class="fas fa-${icon} mr-2"></i> ${message}`;
                notification.appendChild(content);
                
                // Add close button
                const closeButton = document.createElement('button');
                closeButton.className = 'notification-close';
                closeButton.innerHTML = '<i class="fas fa-times"></i>';
                closeButton.addEventListener('click', () => {
                    removeNotification(notification);
                });
                notification.appendChild(closeButton);
                
                // Add to container
                container.appendChild(notification);
                
                // Trigger animation after being added to DOM
                setTimeout(() => {
                    notification.classList.add('show');
                }, 10);
                
                // Auto-dismiss after duration
                if (duration > 0) {
                    setTimeout(() => {
                        removeNotification(notification);
                    }, duration);
                }
                
                return notification;
            }

            function removeNotification(notification) {
                notification.classList.remove('show');
                setTimeout(() => {
                    notification.remove();
                }, 300); // Match transition duration
            }

            // Add this function before initialiseerVerlofrooster
            async function refreshLegendaData(sectionName) {
                try {
                    if (sectionName === 'Verlof') {
                        await haalVerlofRedenenOp();
                    } else if (sectionName === 'Werkweek-indicaties') {
                        await haalDagenIndicatorenOp();
                    }
                    renderLegenda();
                } catch (error) {
                    console.error(`Fout bij vernieuwen legenda data voor ${sectionName}:`, error);
                    showNotification(`Fout bij vernieuwen data: ${error.message}`, 'error');
                }
            }

            // --- Teams ophalen en dropdown vullen ---
            async function haalTeamsOpEnVulDropdown() {
                if (!appConfiguratie) return;
                const teamsConfig = appConfiguratie.lijsten.find(l => l.lijstInformatie.naam === 'Teams');
                if (!teamsConfig) return;
                const apiUrl = teamsConfig.lijstInformatie.apiUrl + '?$select=Naam,Actief&$orderby=Naam';
                try {
                    const response = await fetch(apiUrl, { headers: { 'Accept': 'application/json;odata=verbose' } });
                    if (!response.ok) throw new Error('Fout bij ophalen teams');
                    const data = await response.json();
                    const teams = (data.d && data.d.results) ? data.d.results : [];
                    // Filter alleen actieve teams
                    const actieveTeams = teams.filter(t => t.Actief);
                    // Vul dropdown
                    teamSelect.innerHTML = '<option value="all">Alle teams</option>' +
                        actieveTeams.map(t => `<option value="${t.Naam}">${t.Naam}</option>`).join('');
                } catch (e) {
                    console.error('Kon teams niet ophalen:', e);
                    teamSelect.innerHTML = '<option value="all">Alle teams</option>';
                }
            }

            // --- INITIALISATIE ---
            async function initialiseerVerlofrooster() {
                roosterTabel.querySelector('tbody').innerHTML = `<tr><td colspan="8" class="text-center p-10 text-gray-500"><i class="fas fa-spinner fa-spin mr-2"></i> Rooster laden...</td></tr>`;
                legendaVerlof.innerHTML = '<h4 class="legenda-section-title">Verlof</h4><div class="legend-item text-gray-500 italic">Laden...</div>';
                legendaWerkweek.innerHTML = '<h4 class="legenda-section-title">Werkweek-indicaties</h4><div class="legend-item text-gray-500 italic">Laden...</div>';
                legendaTerugkerend.innerHTML = '<h4 class="legenda-section-title">Terugkerende zaken</h4>';
                legendaBijzonderheden.innerHTML = '<h4 class="legenda-section-title">Bijzonderheden</h4>';
                try {
                    if (!appConfiguratie) { console.error("FATAL: 'configuratie' object niet gevonden in initialiseerVerlofrooster. Is config.js geladen?"); throw new Error("Configuratie object is niet geladen."); }

                    // --- EVENT LISTENERS --- (Setup binnen initialisatie)
                    btnPrev.addEventListener('click', () => { if (huidigeWeergave === 'month') { huidigeDatum.setMonth(huidigeDatum.getMonth() - 1); } else { huidigeDatum.setDate(huidigeDatum.getDate() - 7); } renderRooster(); });
                    btnNext.addEventListener('click', () => { if (huidigeWeergave === 'month') { huidigeDatum.setMonth(huidigeDatum.getMonth() + 1); } else { huidigeDatum.setDate(huidigeDatum.getDate() + 7); } renderRooster(); });
                    btnToday.addEventListener('click', () => { huidigeDatum = new Date(); renderRooster(); });
                    btnViewMonth.addEventListener('click', () => { if (huidigeWeergave !== 'month') { huidigeWeergave = 'month'; huidigeDatum = new Date(huidigeDatum.getFullYear(), huidigeDatum.getMonth(), 1); renderRooster(); } });
                    btnViewWeek.addEventListener('click', () => { if (huidigeWeergave !== 'week') { huidigeWeergave = 'week'; renderRooster(); } });
                    searchInput.addEventListener('input', renderRooster);
                    teamSelect.addEventListener('change', renderRooster);
                    legendaToggleBtn.addEventListener('click', () => { const isHidden = legendaContent.classList.toggle('hidden'); legendaToggleIcon.classList.toggle('fa-chevron-down', isHidden); legendaToggleIcon.classList.toggle('fa-chevron-up', !isHidden); legendaOuterContainer.classList.toggle('shadow', !isHidden); });
                    legendaContent.addEventListener('click', (event) => { const editButton = event.target.closest('.legenda-edit-btn'); if (editButton) { const sectionName = editButton.dataset.section; showEditSectionView(sectionName); } });
                    editSectionBackBtn.addEventListener('click', showMainView);
                    btnAddNewItem.addEventListener('click', voegNieuweRijToeAanEditTabel);

                    // Event listeners voor knoppen in de bewerk-tabel (delegation)
                    editSectionContent.addEventListener('click', async (event) => {
                        const target = event.target;
                        const saveButton = target.closest('.btn-save-item');
                        const deleteButton = target.closest('.btn-delete-item');
                        const saveNewButton = target.closest('.btn-save-new-item');
                        const cancelNewButton = target.closest('.btn-cancel-new-item');

                        const row = target.closest('tr');
                        if (!row || !huidigeEditSectie) return;

                        const itemId = row.dataset.itemId;
                        const lijstGuid = getGuidForSection(huidigeEditSectie);
                        if (!lijstGuid) return;

                        // --- Opslaan bestaand item ---
                        if (saveButton && itemId !== 'new') {
                            saveButton.disabled = true; saveButton.innerHTML = '<i class="fas fa-spinner fa-spin fa-fw"></i> Opslaan...';
                            const itemData = {}; const fields = getFieldsForSection(huidigeEditSectie); let isValid = true;
                            row.querySelectorAll('input, select').forEach(input => {
                                const fieldConfig = fields.find(f => (f.internalName || f.key) === input.name);
                                if(fieldConfig && fieldConfig.type !== 'readonly') {
                                    itemData[input.name] = input.value;
                                    if ((input.name === 'Title' || input.name === 'Naam') && !input.value.trim()) { isValid = false; input.classList.add('border-red-500'); }
                                    else { input.classList.remove('border-red-500'); }
                                }
                            });
                            if (!isValid) { showNotification("Vul a.u.b. alle verplichte velden in (bv. Naam).", "error"); saveButton.disabled = false; saveButton.innerHTML = '<i class="fas fa-save fa-fw"></i> Opslaan'; return; }
                            try {
                                // Gebruik de functie uit CRUD.js (ervan uitgaande dat CRUD.js geladen is)
                                await updateLegendaItem(lijstGuid, itemId, itemData);
                                showNotification('Item succesvol bijgewerkt!', 'success');
                                if (huidigeEditSectie === 'Verlof') await haalVerlofRedenenOp();
                                if (huidigeEditSectie === 'Werkweek-indicaties') await haalDagenIndicatorenOp();
                                showEditSectionView(huidigeEditSectie);
                            } catch (error) { console.error("Fout bij opslaan:", error); showNotification(`Fout bij opslaan: ${error.message}`, 'error'); saveButton.disabled = false; saveButton.innerHTML = '<i class="fas fa-save fa-fw"></i> Opslaan'; }
                        }

                        // --- Verwijderen item ---
                        if (deleteButton && itemId !== 'new') {
                            // This line should remain a confirmation dialog
                            if (confirm(`Weet je zeker dat je dit item (ID: ${itemId}) wilt verwijderen?`)) {
                                deleteButton.disabled = true; deleteButton.innerHTML = '<i class="fas fa-spinner fa-spin fa-fw"></i>';
                                try {
                                    await verwijderLegendaItem(lijstGuid, itemId);
                                    showNotification('Item succesvol verwijderd!', 'success'); row.remove();
                                    if (huidigeEditSectie === 'Verlof') await haalVerlofRedenenOp();
                                    if (huidigeEditSectie === 'Werkweek-indicaties') await haalDagenIndicatorenOp();
                                } catch (error) { console.error("Fout bij verwijderen:", error); showNotification(`Fout bij verwijderen: ${error.message}`, 'error'); deleteButton.disabled = false; deleteButton.innerHTML = '<i class="fas fa-trash-alt fa-fw"></i> Verwijderen'; }
                            }
                        }

                        // --- Opslaan nieuw item ---
                        if (saveNewButton) {
                            saveNewButton.disabled = true; saveNewButton.innerHTML = '<i class="fas fa-spinner fa-spin fa-fw"></i> Opslaan...';
                            const itemData = {}; const fields = getFieldsForSection(huidigeEditSectie); let isValid = true;
                            row.querySelectorAll('input, select').forEach(input => {
                                const fieldConfig = fields.find(f => (f.internalName || f.key) === input.name);
                                if(fieldConfig && fieldConfig.type !== 'readonly') {
                                    itemData[input.name] = input.value;
                                    if ((input.name === 'Title' || input.name === 'Naam') && !input.value.trim()) { isValid = false; input.classList.add('border-red-500'); }
                                    else { input.classList.remove('border-red-500'); }
                                }
                            });
                            if (!isValid) { showNotification("Vul a.u.b. alle verplichte velden in (bv. Naam).", "error"); saveNewButton.disabled = false; saveNewButton.innerHTML = '<i class="fas fa-save fa-fw"></i> Opslaan'; return; }
                            try {
                                const nieuwItem = await voegLegendaItemToe(lijstGuid, itemData);
                                showNotification('Nieuw item succesvol toegevoegd!', 'success');
                                if (huidigeEditSectie === 'Verlof') await haalVerlofRedenenOp();
                                if (huidigeEditSectie === 'Werkweek-indicaties') await haalDagenIndicatorenOp();
                                showEditSectionView(huidigeEditSectie);
                            } catch (error) { console.error("Fout bij toevoegen:", error); showNotification(`Fout bij toevoegen: ${error.message}`, 'error'); saveNewButton.disabled = false; saveNewButton.innerHTML = '<i class="fas fa-save fa-fw"></i> Opslaan'; }
                        }

                        // --- Annuleren nieuw item ---
                        if (cancelNewButton) { row.remove(); }
                    });
                    // --- Einde Event Listeners ---

                    // Laad alle benodigde data parallel
                    await Promise.all([ haalMedewerkersOp(), haalVerlofRedenenOp(), haalDagenIndicatorenOp() ]);
                    await renderRooster(); // Render rooster na data
                    await haalTeamsOpEnVulDropdown();
                    showMainView(); // Zorg dat de hoofdweergave zichtbaar is na laden

                } catch (error) {
                    console.error("Initialisatie fout:", error);
                    roosterTabel.querySelector('tbody').innerHTML = `<tr><td colspan="8" class="text-center p-10 text-red-500"><i class="fas fa-exclamation-triangle mr-2"></i> Kon rooster niet initialiseren: ${error.message}</td></tr>`;
                    if (medewerkers.length === 0 || verlofRedenen.length === 0 || dagenIndicatoren.length === 0) { // Check of basisdata mist
                        legendaContent.innerHTML = `<p class="text-red-500 p-3">Fout bij laden data: ${error.message}</p>`;
                        if (legendaContent.classList.contains('hidden')) { legendaContent.classList.remove('hidden'); legendaToggleIcon.classList.replace('fa-chevron-down', 'fa-chevron-up'); }
                    }
                }
            }
            // Start de initialisatie nadat de DOM volledig geladen is
            document.addEventListener('DOMContentLoaded', initialiseerVerlofrooster);

            // --- MODAL voor verlof toevoegen ---
            function openVerlofModal() {
                // Verwijder bestaande modal als die er is
                const bestaandeBackdrop = document.getElementById('verlof-modal-backdrop');
                if (bestaandeBackdrop) bestaandeBackdrop.remove();
                // Modal HTML
                const modalHtml = `
                <div id="verlof-modal-backdrop" class="modal-backdrop active">
                    <div class="modal">
                    <div class="modal-header">
                        <span class="modal-title">Verlof toevoegen</span>
                        <button class="modal-close" id="verlof-modal-close">&times;</button>
                    </div>
                    <form id="verlof-form">
                        <div class="modal-body">
                        <div class="form-group">
                            <label class="form-label">Medewerker</label>
                            <select name="MedewerkerID" class="form-control" required>
                            <option value="">Kies medewerker...</option>
                            ${medewerkers.map(m => `<option value="${m.ID}">${m.displayNameFromProfile || m.Naam}</option>`).join('')}
                            </select>
                        </div>
                        <div class="form-row">
                            <div class="form-group form-col">
                            <label class="form-label">Startdatum</label>
                            <input type="date" name="StartDatum" class="form-control" required>
                            </div>
                            <div class="form-group form-col">
                            <label class="form-label">Einddatum</label>
                            <input type="date" name="EindDatum" class="form-control" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Reden</label>
                            <select name="Reden" class="form-control" required>
                            <option value="">Kies reden...</option>
                            ${verlofRedenen.map(r => `<option value="${r.Title}" data-kleur="${r.Kleur}">${r.Title}</option>`).join('')}
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Omschrijving</label>
                            <input type="text" name="Omschrijving" class="form-control">
                        </div>
                        </div>
                        <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" id="verlof-cancel">Annuleren</button>
                        <button type="submit" class="btn btn-primary">Opslaan</button>
                        </div>
                    </form>
                    </div>
                </div>
                `;
                document.body.insertAdjacentHTML('beforeend', modalHtml);
                // Event listeners
                document.getElementById('verlof-modal-close').onclick = sluitVerlofModal;
                document.getElementById('verlof-cancel').onclick = sluitVerlofModal;
                document.getElementById('verlof-form').onsubmit = async function(e) {
                e.preventDefault();
                const form = e.target;
                const data = Object.fromEntries(new FormData(form).entries());
                // Valideer
                if (!data.MedewerkerID || !data.StartDatum || !data.EindDatum || !data.Reden) return;
                // Opslaan in SharePoint
                try {
                    const verlofLijstGuid = 'e12a068f-2821-4fe1-b898-e42e1418edf8';
                    await voegLegendaItemToe(verlofLijstGuid, {
                    MedewerkerID: data.MedewerkerID,
                    StartDatum: data.StartDatum,
                    EindDatum: data.EindDatum,
                    Reden: data.Reden,
                    Omschrijving: data.Omschrijving || ''
                    });
                    sluitVerlofModal();
                    showNotification('Verlof succesvol toegevoegd!', 'success');
                    await renderRooster();
                } catch (err) {
                    showNotification('Fout bij toevoegen verlof: ' + err.message, 'error');
                }
                };
            }
            function sluitVerlofModal() {
                const backdrop = document.getElementById('verlof-modal-backdrop');
                if (backdrop) backdrop.remove();
            }
            // Voeg event toe aan de Toevoegen knop
            setTimeout(() => {
            const btns = document.querySelectorAll('.btn.btn-primary');
            btns.forEach(btn => {
                if (btn.textContent.includes('Toevoegen')) {
                btn.onclick = openVerlofModal;
                }
            });
            }, 500);

            // Pas rendering van verlof aan voor gestreept patroon
            function getLeavePatternStyle(kleur) {
            return `background: repeating-linear-gradient(135deg, ${kleur}, ${kleur} 6px, #fff 6px, #fff 12px); opacity:0.7;`;
            }
        </script>

    </body>
    </html>
