# École Polytechnique (L'X) — Sovereign Knowledge Base

## [OFFICIAL] 11th Medical Antenna (SMED)

The SMED is the primary medical service for students and staff on campus.

- **Location**: Bâtiment BROCA (N° 15), Ground Floor.
- **Access**: Near the "Pôle Santé" and "Cour d'Honneur".
- **Business Hours**: Monday to Friday, 08:00 – 18:00.
- **Contact**:
  - **Medical Appointments**: `01 69 33 39 06`
  - **Nursing / Infirmary**: `01 69 33 39 00` (Direct) or `01 69 33 39 06`
  - **Internal Emergencies (SPIS)**: `01 69 33 34 33`
- **Procedure**:
  - For standard consultations, call the medical appointment number.
  - For nursing care or minor emergencies (sports injuries), you can often go directly or call the nursing number.
  - **International Students**: The SMED doctors cannot be officially designated as "Médecin Traitant" (Primary Care Physician) for international students under the standard Social Security (CPAM) system, but they provide all necessary care.

## Academic Path — Cycle Ingénieur (X24)

### 3rd Year (3A) Specialization
- **Choice**: Computer Science (CSC) & Applied Mathematics (MAP).
- **Motivation**: Sovereignty over infrastructure (Homelab), AI foundations, and high-performance computing.

### Period 1 (P1) Course Ranking
1. **Panachage** (Approved/Requested): Goal is to combine high-value courses across departments.
2. **CSC_510XX** (Placeholder for the specific code): *Algorithms & Complexity*.
3. **MAP_51XXX**: *Stochastic Processes*.
*(Note: These are based on the latest rankings established in the current session history)*.

### Period 2 (P2) Course Ranking
- **Plan A (Top Priorities)**:
  1. [Course Name 1]
  2. [Course Name 2]
  3. [Course Name 3]
  4. [Course Name 4]
*(Note: Refer to `3a_course_planning.md` for the exhaustive ranking of all 16 options)*.

## Emploi du temps & groupes PC (SynapseS)

**Source de vérité agenda** : [SynapseS](https://synapses.polytechnique.fr/) (connecté CAS X) — bloc **Mon emploi du temps** en bas de l’accueil.

| Besoin | Où / comment |
|--------|----------------|
| Semaine visible | Accueil → boutons **Semaine** / flèches · colonne du jour (ex. `mar. 26/5`) |
| Export multi-semaines | Bas de page → **Adresse de synchronisation** → champ `#input-url-sync-agenda` (token personnel — **ne pas commiter**) → `curl` ICS ou `k-browser/scripts/synapses-agenda.py` |
| **Numéro de groupe PC** | Dans l’ICS : champ `DESCRIPTION` de chaque créneau **Petite classe** → ligne `Groupe : …` (ex. `Groupe2`, `Groupe 11`) |
| Salle + intervenant PC | Même `DESCRIPTION` (`Salles`, `Intervenants`) + `LOCATION` dans l’ICS |
| Sites Moodle par UE | Accueil SynapseS → pied de page → liste **Accédez directement à vos sites pédagogiques** (codes `CSC_43042_EP`, `FMA_43052_EP`, …) |
| Inscriptions / groupes admin | Menu **Enseignements** (peut rediriger si session instable — préférer ICS + Moodle) |

**Runbook agent** : `$HOME/.agents/skills/k-browser/references/workflows-academic-portals.md` § SynapseS.

**Moodle** (supports, annonces) : `https://moodle.ip-paris.fr/` — pas la liste des groupes PC ; croiser avec SynapseS pour salles et groupes.

### Groupes PC — P3 actuel (SynapseS, 2026-05-26)

| UE | Groupe PC | Salle type (créneau actuel) | Intervenant PC |
|----|-----------|-----------------------------|----------------|
| `FMA_43052_EP` — Analyse fonctionnelle | **Groupe2** | BEM-2009 | PRANGE Christophe |
| `CSC_43042_EP` — Algorithmes Python | **Groupe 11** | Amphi Grégory | Souza Banegas Gustavo |
| `APM_43035_EP` — Optimisation | *(contrôle classant jeudi, pas PC)* | T5–T6 (28/05) | — |

Les CM affichent souvent `Groupe : Tous les étudiants` — seules les **petites classes** portent le numéro de groupe.

## Internal Logistics

- **Matricule X**: `EX240207`
- **Email (Academic)**: `ivann.kamdem-pouokam@polytechnique.edu`
- **Email (Alumni/Life)**: `ivann.kamdem-pouokam.2024@polytechnique.org`
- **Storage**: `$HOME/Gdrive_X/` (rclone mount `gdrive-x:`)
- **Integration Resources**: `$HOME/Gdrive_X/X/Integration/`

## Proactive Maintenance
- **Reflex**: This file must be updated autonomously as soon as new institutional facts, procedures, or academic decisions are learned.
- **Trigger**: New emails from "Scolarité", "SMED", or "Direction des Études".
