<!DOCTYPE html>
<html lang="nl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teamverlofrooster</title>
    <link rel="stylesheet" type="text/css" href="css/V2.css">
    </head>

<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">
                    <svg class="logo-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
                    Teamverlofrooster
                </div>

                <div class="actions">
                    <button class="btn btn-export" id="exportBtn" title="Exporteren naar Excel">
                        <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                            viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                            <polyline points="14 2 14 8 20 8"></polyline>
                            <line x1="8" y1="13" x2="16" y2="13"></line>
                            <line x1="8" y1="17" x2="16" y2="17"></line>
                            <line x1="10" y1="9" x2="14" y2="9"></line>
                        </svg>
                        </button>

                    <div class="dropdown" id="adminDropdown" style="display: none;"> <button class="btn btn-secondary">
                            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="3"></circle>
                                <path
                                    d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z">
                                </path>
                            </svg>
                            Beheer
                        </button>
                        <div class="dropdown-content">
                            <a class="dropdown-item" id="addTeamBtn">Team toevoegen</a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" id="manageReasonsBtn">Verlofredenen beheren</a>
                            <a class="dropdown-item" id="manageSeniorsBtn">Team Seniors Beheren</a>
                            <a class="dropdown-item" id="manageEmployeesBtn">Medewerkers beheren</a>
                            <a class="dropdown-item" id="manageDagenIndicatorsBtn">Dag-indicatoren beheren</a>
                        </div>
                    </div>

                    <div class="add-dropdown">
                        <button class="btn btn-primary add-dropdown-btn">
                            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                stroke-linecap="round" stroke-linejoin="round">
                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                <line x1="5" y1="12" x2="19" y2="12"></line>
                            </svg>
                            + Toevoegen
                        </button>
                        <div class="add-dropdown-content">
                            <a class="dropdown-item" id="addLeaveBtn">Verlof toevoegen</a>
                            <a class="dropdown-item" id="addTeamMemberBtn">Teamlid toevoegen</a>
                            <a class="dropdown-item" id="addTeamBtn2">Team toevoegen</a>
                        </div>
                    </div>
                </div>

                <div class="user-info" id="userInfo">
                    <div class="user-avatar" id="userAvatar">?</div>
                    <span id="userName">Niet ingelogd</span> </div>

                <div class="user-settings">
                    <button class="user-settings-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="user-settings-content">
                        <a class="dropdown-item" id="userSettingsBtn">Instellingen</a>
                        <a class="dropdown-item" id="userProfileBtn">Mijn profiel</a>
                        <a class="dropdown-item" id="userHelpBtn">Help</a>
                    </div>
                </div>
            </nav>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <div class="control-panel">
                <div class="period-selector">
                    <div class="period-nav">
                        <button class="period-nav-btn" id="prevBtn" title="Vorige periode">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <polyline points="15 18 9 12 15 6"></polyline>
                            </svg>
                        </button>
                        <div class="period-display" id="currentPeriod">April 2025</div> <button class="period-nav-btn" id="nextBtn" title="Volgende periode">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <polyline points="9 18 15 12 9 6"></polyline>
                            </svg>
                        </button>
                    </div>
                    <button class="btn btn-secondary" id="todayBtn">Vandaag</button>
                </div>

                <div class="view-selector">
                    <div class="view-btn-group">
                        <button class="view-btn" data-view="week">Week</button>
                        <button class="view-btn active" data-view="month">Maand</button>
                        </div>
                </div>

                <div class="search-box">
                    <input type="text" class="search-input" id="employeeSearch" placeholder="Zoek medewerker...">
                    <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                        viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <circle cx="11" cy="11" r="8"></circle>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                    </svg>
                </div>

                <div class="team-selector">
                    <label class="team-label">Team:</label>
                    <select class="team-select" id="teamFilter">
                        <option value="all">Alle teams</option>
                        </select>
                </div>
            </div>

            <div class="legend" id="legendContainer">
                <p class="text-center text-gray-500 italic">Legenda wordt hier geladen...</p>
                </div>

            <div class="loading" id="loadingIndicator" style="display: none;"> <div class="spinner"></div>
                <p>Verlofgegevens laden...</p>
            </div>

            <div class="team-roster" id="teamRoster">
                <div class="roster-table-wrapper">
                     <table class="roster-table">
                        <thead>
                            <tr>
                                <th class="employee-col">Medewerker</th>
                                <th>Ma</th>
                                <th>Di</th>
                                <th>Wo</th>
                                <th>Do</th>
                                <th>Vr</th>
                                <th>Za</th>
                                <th>Zo</th>
                                <th>Ma</th>
                                <th>Di</th>
                                <th>Wo</th>
                                <th>Do</th>
                                <th>Vr</th>
                                <th>Za</th>
                                <th>Zo</th>
                                <th>Ma</th>
                                <th>Di</th>
                                <th>Wo</th>
                                <th>Do</th>
                                <th>Vr</th>
                                <th>Za</th>
                                <th>Zo</th>
                                <th>Ma</th>
                                <th>Di</th>
                                <th>Wo</th>
                                <th>Do</th>
                                <th>Vr</th>
                                <th>Za</th>
                                <th>Zo</th>
                                <th>Ma</th>
                                <th>Di</th>
                                <th>Wo</th>
                                </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="employee-col">
                                    <div class="employee-info">
                                        <div class="avatar">JD</div>
                                        <span class="employee-name">Jan de Vries</span>
                                    </div>
                                </td>
                                <td class="day-cell other-month"></td> <td class="day-cell"><span class="date-label">1</span></td> <td class="day-cell"><span class="date-label">2</span></td> <td class="day-cell"><span class="date-label">3</span></td> <td class="day-cell"><span class="date-label">4</span></td> <td class="day-cell weekend"><span class="date-label">5</span></td> <td class="day-cell weekend"><span class="date-label">6</span></td> <td class="day-cell"><span class="date-label">7</span></td> <td class="day-cell"><span class="date-label">8</span></td> <td class="day-cell"><span class="date-label">9</span></td> <td class="day-cell"><span class="date-label">10</span></td> <td class="day-cell"><span class="date-label">11</span></td> <td class="day-cell weekend"><span class="date-label">12</span></td> <td class="day-cell weekend"><span class="date-label">13</span></td> <td class="day-cell today"><span class="date-label">14</span></td> <td class="day-cell"><span class="date-label">15</span></td> <td class="day-cell"><span class="date-label">16</span></td> <td class="day-cell"><span class="date-label">17</span></td> <td class="day-cell"><span class="date-label">18</span></td> <td class="day-cell weekend"><span class="date-label">19</span></td> <td class="day-cell weekend"><span class="date-label">20</span></td> <td class="day-cell"><span class="date-label">21</span></td> <td class="day-cell"><span class="date-label">22</span></td> <td class="day-cell"><span class="date-label">23</span></td> <td class="day-cell"><span class="date-label">24</span></td> <td class="day-cell"><span class="date-label">25</span></td> <td class="day-cell weekend"><span class="date-label">26</span></td> <td class="day-cell weekend"><span class="date-label">27</span></td> <td class="day-cell"><span class="date-label">28</span></td> <td class="day-cell"><span class="date-label">29</span></td> <td class="day-cell"><span class="date-label">30</span></td> <td class="day-cell other-month"></td> </tr>
                            <tr>
                                <td class="employee-col">
                                     <div class="employee-info">
                                        <div class="avatar">PV</div>
                                        <span class="employee-name">Piet Verbeek</span>
                                    </div>
                                </td>
                                <td class="day-cell other-month"></td> <td class="day-cell"><span class="date-label">1</span></td> <td class="day-cell"><span class="date-label">2</span></td> <td class="day-cell"><span class="date-label">3</span></td> <td class="day-cell"><span class="date-label">4</span></td> <td class="day-cell weekend"><span class="date-label">5</span></td> <td class="day-cell weekend"><span class="date-label">6</span></td> <td class="day-cell"><span class="date-label">7</span></td> <td class="day-cell"><span class="date-label">8</span></td> <td class="day-cell"><span class="date-label">9</span></td> <td class="day-cell"><span class="date-label">10</span></td> <td class="day-cell"><span class="date-label">11</span></td> <td class="day-cell weekend"><span class="date-label">12</span></td> <td class="day-cell weekend"><span class="date-label">13</span></td> <td class="day-cell today"><span class="date-label">14</span></td> <td class="day-cell"><span class="date-label">15</span></td> <td class="day-cell"><span class="date-label">16</span></td> <td class="day-cell"><span class="date-label">17</span></td> <td class="day-cell"><span class="date-label">18</span></td> <td class="day-cell weekend"><span class="date-label">19</span></td> <td class="day-cell weekend"><span class="date-label">20</span></td> <td class="day-cell"><span class="date-label">21</span></td> <td class="day-cell"><span class="date-label">22</span></td> <td class="day-cell"><span class="date-label">23</span></td> <td class="day-cell"><span class="date-label">24</span></td> <td class="day-cell"><span class="date-label">25</span></td> <td class="day-cell weekend"><span class="date-label">26</span></td> <td class="day-cell weekend"><span class="date-label">27</span></td> <td class="day-cell"><span class="date-label">28</span></td> <td class="day-cell"><span class="date-label">29</span></td> <td class="day-cell"><span class="date-label">30</span></td> <td class="day-cell other-month"></td> </tr>
                            </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <div class="snackbar" id="snackbar"></div>

    </body>
</html>
