// Reusable Medewerker (employee) registration/edit form component
// Usage: medewerkerForm.render({ medewerker, onSave, onCancel })

const medewerkerForm = {
  render({ medewerker = {}, onSave, onCancel }) {
    const container = document.getElementById('medewerkerFormContainer');
    if (!container) return;
    container.innerHTML = '';

    // Create form
    const form = document.createElement('form');
    form.className = 'medewerker-form';
    form.innerHTML = `
      <h2>${medewerker.ID ? 'Medewerker bewerken' : 'Registreren als nieuwe medewerker'}</h2>
      <label>Naam:<br><input type="text" name="Naam" value="${medewerker.Naam || ''}" required></label><br>
      <label>E-mail:<br><input type="email" name="E_x002d_mail" value="${medewerker.E_x002d_mail || ''}" required></label><br>
      <label>Geboortedatum:<br><input type="date" name="Geboortedatum" value="${medewerker.Geboortedatum ? medewerker.Geboortedatum.substring(0,10) : ''}" required></label><br>
      <label>Functie:<br><input type="text" name="Functie" value="${medewerker.Functie || ''}"></label><br>
      <label>Team:<br><input type="text" name="Team" value="${medewerker.Team || ''}"></label><br>
      <button type="submit">Opslaan</button>
      <button type="button" id="cancelMedewerkerForm">Annuleren</button>
    `;

    // Handle submit
    form.onsubmit = function(e) {
      e.preventDefault();
      const formData = new FormData(form);
      const medewerkerData = {};
      for (const [key, value] of formData.entries()) {
        medewerkerData[key] = value;
      }
      if (medewerker.ID) medewerkerData.ID = medewerker.ID;
      if (typeof onSave === 'function') onSave(medewerkerData);
    };
    // Handle cancel
    form.querySelector('#cancelMedewerkerForm').onclick = function() {
      if (typeof onCancel === 'function') onCancel();
      container.innerHTML = '';
    };
    container.appendChild(form);
  },
  hide() {
    const container = document.getElementById('medewerkerFormContainer');
    if (container) container.innerHTML = '';
  }
};

// Expose globally
window.medewerkerForm = medewerkerForm;
