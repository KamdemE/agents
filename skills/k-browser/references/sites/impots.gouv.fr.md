# impots.gouv.fr (Direction Générale des Finances Publiques — Espace Particulier)

**Category:** French Fiscal & Tax Administration Portal. **Account:** `ivann.kamdem@hotmail.com` (FranceConnect: `kapoivha@gmail.com`). **Profile:** `default`.

## Key Identifiers & Fiscal Credentials

- **Numéro Fiscal (13 chiffres):** `3072492439184`
- **Numéro d'Avis (2025):** `25 91 A757621 13`
- **Foyer Fiscal:** KAMDEM POUOKAM IVANN HAROLD (Célibataire, 1 part fiscale)
- **Adresse Fiscale Référencée:** Bâtiment Maunoury, 9 Boulevard des Maréchaux, 91120 PALAISEAU
- **SIP de Rattachement Compétent:** SIP de Palaiseau (1 Rue du Général de Gaulle, 91120 Palaiseau)
- **SIP d'Origine / Création:** SIP Arpajon (29 Ave du Général de Gaulle, 91295 Arpajon Cedex — Odile Dodinet, `sip.arpajon@dgfip.finances.gouv.fr`, 01 69 26 81 96)

## Login & Authentication Flow

- **Portal URL:** `https://cfspart.impots.gouv.fr`
- **Authentication Modes:**
  1. **FranceConnect:** Primary & fastest route using Ameli (Sécurité Sociale) or L'Identité Numérique La Poste. Automatically links identity to fiscal number `3072492439184`.
  2. **Direct Credentials:** Numéro Fiscal `3072492439184` + Password set in Espace Particulier.
- **Prélèvement à la source (PAS):** Taux personnalisé foyer = **0,00 %** (aucun acompte requis pour le mois en cours).

## Google Drive Archive Structure (`~/Gdrive_X/KpihX/Fr/Taxes/`)

Following the sovereign `k-classification` standard, all tax documents are stored under `~/Gdrive_X/KpihX/Fr/Taxes/`:

- `Taxes_FR_Declaration_des_revenus_2024_KAMDEM_Ivann.pdf` — Déclaration de revenus 2024 (Formulaire 2042).
- `Taxes_FR_Avis_d_impot_2025_sur_les_revenus_2024_KAMDEM_Ivann.pdf` — Avis d'impôt 2025 émis le 05/12/2025.
- `Taxes_FR_Formulaire_Impots_2042_KAMDEM_Ivann.pdf` — Formulaire vierge / référence 2042.

### Historical Tax Financial Summary (Revenus 2024 / Avis 2025)
- **Revenu Net Imposable 2024:** 0 €
- **Revenu Fiscal de Référence (RFR 2025):** **0 €**
- **Impôt Net sur le Revenu:** **0 €** (Non imposable)
- **Solde restant à payer:** **0 €**

## Mail & Proxy Infrastructure (`Admins` Unified Folder)

Tax emails and notifications are managed across accounts under the single canonical `Admins` folder:

- **Gmail (`kapoivha@gmail.com`):** Label `Admins` (`Label_17`) + Filter `ANe1Bmh88VEqFVtHhKr6VSzykZW2wklQH4NJLQ`.
- **Hotmail (`ivann.kamdem@hotmail.com`):** Folder `Admins`.
- **Centralized Transferred Mails:** Hotmail exchanges with SIP Arpajon (Odile Dodinet) and DGFiP notifications are forwarded and indexed under Gmail's `Admins` label for unified tracking.

## TickTick Automation Tasks (`🏠 Persos` > `📋 Administratif`)

Two annual recurring tasks managed via `tick-proxy` in project `📋 Administratif` (ID: `69ab43b38f088245a47b5f75`):

1. **`[IMPÔTS] Déclaration annuelle en ligne des revenus (impots.gouv.fr)`** (ID: `6a9dc07f8f0857fda1ec4837`)
   - **Échéance:** **20 Avril** (Répétition annuelle `RRULE:FREQ=YEARLY`, Priorité 5 / High).
   - **Action:** Se connecter sur `impots.gouv.fr` (Numéro fiscal: `3072492439184`) et vérifier/valider la déclaration de revenus pré-remplie.
2. **`[IMPÔTS] Télécharger l'Avis d'Impôt (ASDIR) & Archiver dans Gdrive`** (ID: `6a9dc08e8f0857fda1ec4a08`)
   - **Échéance:** **1er Août** (Répétition annuelle `RRULE:FREQ=YEARLY`, Priorité 3 / Medium).
   - **Action:** Télécharger le PDF de l'Avis d'Impôt / ASDIR depuis l'onglet Documents et le classer dans `~/Gdrive_X/KpihX/Fr/`.

## Active / Submitted Requests (`Messagerie Sécurisée`)

- **Demande N° 1242929305** (Soumise le 06/09/2026) :
  - **Objet :** Changement d'adresse postale (Déménagement / Mise à jour adresse Palaiseau).
  - **Nouvelle adresse transmise :** `BATIMENT MAUNOURY, 9 BD DES MARECHAUX, 91120 PALAISEAU` (Date d'effet: `06/09/2026`, mention complémentaire: `Depuis 04/04/2025`).
  - **Statut :** ✅ **TRAITÉE le 09/09/2026** — double preuve live : Messagerie sécurisée (`Demande traitée` + accusé de réception, `53 AV MASSENAT DEROCHE 91460 MARCOUSSIS` → `BATIMENT MAUNOURY 9 BD DES MARECHAUX 91120 PALAISEAU`, effet 06/09/2026) + page Profil (`Adresse postale : BATIMENT MAUNOURY 9 BD DES MARECHAUX - 91120 PALAISEAU`).
  - **Notifications :** Envoyées sur `ivann.kamdem@hotmail.com` (indexées dans le dossier `Admins`).

## Key Selectors & DOM Attributes (`cfspart.impots.gouv.fr`)

- **Numéro Fiscal Input:** `#spi_tmp` or `input[name="spi"]` (13 digits).
- **FranceConnect Login Link:** `a[href*="franceconnect"]`.
- **Documents Section:** Tab `Documents` (`https://cfspart.impots.gouv.fr/enp/documents.do`).
- **PAS Management:** Tab `Prélèvement à la source` (`https://cfspart.impots.gouv.fr/enp/pas.do`).
- **Messagerie Sécurisée Portal:** `https://cfspart.impots.gouv.fr/gaia2-zu-mapi/pages/part/portailpart.xhtml`.
  - **Procedure for Off-Season Address Updates / Corrections:** When the direct 2042 correction wizard is closed, use `Messagerie sécurisée` > `Écrire` > `Changement d'adresse postale` or `Je pose une question sur mon impôt`.

## Statut Dématérialisation (depuis 06/09/2026)

- **Mail DGFiP 06/09 21:11** (`ne_pas_repondre@dgfip.finances.gouv.fr`, Hotmail `Admins` uid 34) : « modification de vos options de dématérialisation prise en compte ».
- **Profil 09/09 (live)** : `Mes avis d'impôt sur le revenu` = OPTION ACTIVÉE · `Mes avis d'impôts locaux` = OPTION ACTIVÉE → **zéro papier**.
- **Conséquence** : tous les avis/notifications futurs arrivent en Messagerie sécurisée + email d'alerte ; aucun courrier papier à attendre (ni avis, ni réponse SIP).

## Communication Prefs (since 09/09/2026 — KπX order)

- **Profil (live 09/09):** `Par courriel` = PRÉFÉRENCE ACTIVÉE · `Par SMS` = PRÉFÉRENCE ACTIVÉE.
- **Flow:** Profil → `Modifier vos préférences de communication` (`redirectsms.do` → `monprofil-webapp/GererMonProfil`) → checkboxes `#courriel` + `#sms` → `#btnSubmit` (`Enregistrer`) → banner `Modifications enregistrées` → back via `Retour au tableau de bord` → re-open Profil to verify.
- **Note:** checkboxes report `checked=false` on first DOM dump even when the save sticks — ground truth is the re-read Profil page, not the form dump.

## Méthode d'Exploration (09/09/2026 — GRAVÉ pour `cfspart`)

- **Contenu réel dans un iframe same-origin** : `https://cfspart.impots.gouv.fr/gaia2-zu-mapi/pages/part/portailpart.xhtml` — `document.body.innerText` de la coquille est vide ; lire via `iframe.contentDocument` (`title` + `body.innerText`).
- **Règle « clics in-page uniquement »** : naviguer en cliquant les liens du portail (`messagerie.do`, `chargementprofil.do`, `documents.do?n=0`) via JS-in-page. **JAMAIS de navigation directe (GET) vers une URL `.do`** — le 09/09 un `page-navigate` direct a cassé la session (re-login requis). Cause probable : le portail exige son flux de navigation interne (jetons).
- **Documents** : onglets années 2017→2026 avec libellé statique « document non lu » — les compteurs réels étaient tous à `0 document non lu` le 09/09 ; seuls docs présents = Avis 2025 + Déclaration 2024.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-09 | [LIVE] | Demande N° 1242929305 **traitée** (double preuve live messagerie + profil, adresse Palaiseau validée) ; dématérialisation active consignée (zéro papier) ; méthode d'exploration documentée (iframe same-origin + clics in-page uniquement, GET direct = session cassée). |
| 2026-09-06 | [LIVE] | Registered request N° 1242929305 (Changement d'adresse Palaiseau submitted via Messagerie Sécurisée). Updated Gdrive path to `~/Gdrive_X/KpihX/Fr/Taxes/`. |
| 2026-09-06 | [LIVE] | Created `impots.gouv.fr.md` site reference file. Documented fiscal number `3072492439184`, RFR 0 €, Google Drive PDF path `~/Gdrive_X/KpihX/Fr/Taxes/`, TickTick recurring tasks, and `Admins` mail integration. |
| 2026-09-09 | [LIVE] | KπX order: activate courriel+SMS comm prefs. In-page click 'Votre profil' (footer, only visible link) → session expired (IdP login page). Activation PENDING KπX manual re-login (secret never touched). Prefs still ❌ at that time. |
| 2026-09-09 | [LIVE] | Comm prefs DONE + verified live: re-login by KπX → dashboard OK (PAS 0.0%) → Profil → `redirectsms.do` → `#courriel`+#sms` checked → `#btnSubmit` → `Modifications enregistrées` → Profil re-read: courriel ACTIVÉE + SMS ACTIVÉE. Password fields never touched. |
