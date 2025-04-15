# Vurli - Verlof Rooster Applicatie

## Overview
Vurli is a custom leave/vacation scheduler application designed for SharePoint Server 2019. It provides a user-friendly interface for team leaders and employees to view, manage, and schedule time off across teams.

## Project Structure
## Project Structure

- Curli.aspx  
/Vurli 
├── Curli.aspx # Main scheduling application page 
├── Verlof.aspx # Leave management interface 
├── css/ 
│
├── stijl.css # Basic styling for lists and tables 
│ └── V2.css # Modern UI styling with variables and components 
└── js/ 
├── config.js # SharePoint list configurations and field mappings 
├── crud.js # Data operations (Create, Read, Update, Delete) for SharePoint 
└── initialiseren.js # Initialization functions and data rendering

## Features

- **Interactive Calendar Views**: Week and month views of team availability
- **Color-coded Absence Types**: Visual indicators for different types of leave
- **Team Filtering**: Filter the roster by specific teams
- **Employee Search**: Quickly find specific employees
- **Legend Management**: Customize colors and patterns for different absence types
- **Management Tools**: CRUD operations for teams, leave types, and employee records
- **Excel Export**: Export the roster to Excel for reporting

## Technical Details

- Designed for SharePoint Server 2019
- Uses REST API calls to interact with SharePoint lists
- Pure client-side application using HTML, CSS, and JavaScript
- No server-side dependencies beyond SharePoint's standard features
- Mobile-responsive design

## SharePoint Integration

The application uses the following SharePoint lists (configured in `config.js`):
- Verlof (Leave records)
- Medewerkers (Employees)
- Verlofredenen (Leave types)
- UrenPerWeek (Hours per week)
- Seniors (Senior staff)
- Teams
- DagenIndicators (Day indicators)

## Setup Instructions

1. Upload the entire Vurli folder to a SharePoint document library
2. Create the required SharePoint lists with the fields specified in `config.js`
3. Adjust the API URLs in `config.js` to match your SharePoint site structure
4. Set the appropriate permissions on the lists and pages
5. Access the application by navigating to Curli.aspx or Verlof.aspx

## Browser Support

Compatible with modern browsers:
- Microsoft Edge
- Google Chrome
- Firefox
- Safari

## Notes

- This is a pure client-side application (the .aspx files contain HTML/CSS/JavaScript only)
- All data is stored in SharePoint lists for persistence
- User authentication relies on SharePoint's built-in authentication


