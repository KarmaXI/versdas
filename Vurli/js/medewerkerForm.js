// Reusable Medewerker (employee) registration/edit form component
// Usage: medewerkerForm.render({ medewerker, onSave, onCancel })

const medewerkerForm = {
  render({ medewerker = {}, onSave, onCancel }) {
    // Modal HTML toevoegen
    let modal = document.getElementById('medewerker-modal-backdrop');
    if (modal) modal.remove();
    modal = document.createElement('div');
    modal.id = 'medewerker-modal-backdrop';
    modal.className = 'modal-backdrop active';
    modal.innerHTML = `
      <div class="modal">
        <div class="modal-header">
          <span class="modal-title">${medewerker.ID ? 'Medewerker bewerken' : 'Nieuwe medewerker registreren'}</span>
          <button class="modal-close" id="medewerker-modal-close">&times;</button>
        </div>
        <div class="modal-body" id="medewerker-modal-body"></div>
      </div>
    `;
    document.body.appendChild(modal);
    const container = document.getElementById('medewerker-modal-body');
    if (!container) return;

    // Stap 1: Medewerkergegevens formulier
    const form = document.createElement('form');
    form.className = 'medewerker-form';
    form.innerHTML = `
      <h2>${medewerker.ID ? 'Medewerker bewerken' : 'Registreren als nieuwe medewerker'}</h2>
      <label>Naam:<br><input type="text" name="Naam" value="${medewerker.Naam || ''}" required></label><br>
      <label>E-mail:<br><input type="email" name="E_x002d_mail" value="${medewerker.E_x002d_mail || ''}" required></label><br>
      <label>Geboortedatum:<br><input type="date" name="Geboortedatum" value="${medewerker.Geboortedatum ? medewerker.Geboortedatum.substring(0,10) : ''}" required></label><br>
      <label>Functie:<br><input type="text" name="Functie" value="${medewerker.Functie || ''}"></label><br>
      <label>Team:<br><input type="text" name="Team" value="${medewerker.Team || ''}"></label><br>
      <button type="submit">Volgende</button>
      <button type="button" id="cancelMedewerkerForm">Annuleren</button>
    `;

    form.onsubmit = function(e) {
      e.preventDefault();
      const formData = new FormData(form);
      const medewerkerData = {};
      for (const [key, value] of formData.entries()) {
        medewerkerData[key] = value;
      }
      if (medewerker.ID) medewerkerData.ID = medewerker.ID;
      // Ga naar stap 2: uren per week
      renderUrenPerWeekForm(medewerkerData);
    };
    form.querySelector('#cancelMedewerkerForm').onclick = closeModal;
    container.appendChild(form);

    // Stap 2: Uren per week formulier
    function renderUrenPerWeekForm(medewerkerData) {
      container.innerHTML = '';
      const dagen = [
        { naam: 'Maandag', short: 'Maandag' },
        { naam: 'Dinsdag', short: 'Dinsdag' },
        { naam: 'Woensdag', short: 'Woensdag' },
        { naam: 'Donderdag', short: 'Donderdag' },
        { naam: 'Vrijdag', short: 'Vrijdag' }
      ];
      const form2 = document.createElement('form');
      form2.className = 'uren-form';
      let rows = '';
      dagen.forEach(dag => {
        rows += `
          <tr>
            <td>${dag.naam}</td>
            <td><input type="time" name="${dag.short}Start" required></td>
            <td><input type="time" name="${dag.short}Eind" required></td>
            <td><input type="text" name="${dag.short}Totaal" readonly style="width:60px"></td>
            <td><input type="text" name="${dag.short}Soort" readonly style="width:60px"></td>
          </tr>
        `;
      });
      form2.innerHTML = `
        <h2>Werkuren per week</h2>
        <table>
          <thead><tr><th>Dag</th><th>Start</th><th>Eind</th><th>Totaal uren</th><th>Dag-indicator</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
        <button type="submit">Opslaan</button>
        <button type="button" id="cancelUrenForm">Annuleren</button>
      `;
      // Automatische berekening uren en dag-indicator
      form2.querySelectorAll('input[type="time"]').forEach(input => {
        input.addEventListener('input', () => {
          dagen.forEach(dag => {
            const start = form2.querySelector(`[name='${dag.short}Start']`).value;
            const eind = form2.querySelector(`[name='${dag.short}Eind']`).value;
            let totaal = '';
            let soort = '';
            if (start && eind) {
              const [sh, sm] = start.split(':').map(Number);
              const [eh, em] = eind.split(':').map(Number);
              let uren = (eh + em/60) - (sh + sm/60);
              if (uren < 0) uren += 24; // nachtwerk
              totaal = uren.toFixed(2);
              // DagIndicator logica
              if (uren >= 7.5) {
                soort = '';
              } else if (uren === 0) {
                soort = 'VVD';
              } else if (uren > 0 && uren <= 4.5) {
                // Ochtend of middag?
                if (sh < 12) soort = 'VVM';
                else soort = 'VVO';
              } else {
                soort = '';
              }
            }
            form2.querySelector(`[name='${dag.short}Totaal']`).value = totaal;
            form2.querySelector(`[name='${dag.short}Soort']`).value = soort;
          });
        });
      });
      form2.onsubmit = async function(e) {
        e.preventDefault();
        const urenData = {};
        dagen.forEach(dag => {
          urenData[`${dag.short}Start`] = form2.querySelector(`[name='${dag.short}Start']`).value;
          urenData[`${dag.short}Eind`] = form2.querySelector(`[name='${dag.short}Eind']`).value;
          urenData[`${dag.short}Totaal`] = form2.querySelector(`[name='${dag.short}Totaal']`).value;
          urenData[`${dag.short}Soort`] = form2.querySelector(`[name='${dag.short}Soort']`).value;
        });
        // Sla medewerker op (via onSave callback)
        if (typeof onSave === 'function') await onSave(medewerkerData, urenData);
        closeModal();
      };
      form2.querySelector('#cancelUrenForm').onclick = closeModal;
      container.appendChild(form2);
    }

    // Sluit modal bij annuleren of sluiten
    function closeModal() {
      const m = document.getElementById('medewerker-modal-backdrop');
      if (m) m.remove();
      if (typeof onCancel === 'function') onCancel();
    }
    document.getElementById('medewerker-modal-close').onclick = closeModal;
  },
  hide() {
    const container = document.getElementById('medewerkerFormContainer');
    if (container) container.innerHTML = '';
  }
};

// Expose globally
window.medewerkerForm = medewerkerForm;
