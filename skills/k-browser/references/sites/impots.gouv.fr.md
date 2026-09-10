# impots.gouv.fr (Direction Générale des Finances Publiques — Espace Particulier)

**Category:** French Fiscal & Tax Administration Portal. **Account:** personal account (FranceConnect or direct credentials). **Profile:** `default`.

## Key Identifiers & Fiscal Credentials

- **Numéro Fiscal (13 chiffres):** `<fiscal-number>` — found on any avis or via FranceConnect linkage.
- **Foyer Fiscal:** personal details live in the portal Profil page, never in this doc.
- **Addresses / SIP offices:** read live from Profil / Messagerie sécurisée, never hardcoded here.

## Login & Authentication Flow

- **Portal URL:** `https://cfspart.impots.gouv.fr`
- **Authentication Modes:**
  1. **FranceConnect:** Primary & fastest route using Ameli (Sécurité Sociale) or L'Identité Numérique La Poste. Automatically links identity to the fiscal number.
  2. **Direct Credentials:** Numéro Fiscal + Password set in Espace Particulier.
- **Prélèvement à la source (PAS):** read the current personalized rate live from the PAS tab.

## Google Drive Archive Structure (`~/Gdrive/Fr/Taxes/`)

All tax documents are stored under `~/Gdrive/Fr/Taxes/`:

- `Taxes_FR_Declaration_des_revenus_<YEAR>_YOURNAME.pdf` — Déclaration de revenus (Formulaire 2042).
- `Taxes_FR_Avis_d_impot_<YEAR>_sur_les_revenus_<YEAR-1>_YOURNAME.pdf` — Avis d'impôt.
- `Taxes_FR_Formulaire_Impots_2042_YOURNAME.pdf` — Formulaire vierge / référence 2042.

### Historical Tax Financial Summary

Read live from the portal (Revenu Net Imposable, RFR, Impôt Net, Solde) — never hardcoded here.

## Mail & Proxy Infrastructure (`Admins` Unified Folder)

Tax emails and notifications are managed across accounts under the single canonical `Admins` folder:

- **Gmail (`<primary@gmail.com>`):** Label `Admins` (`Label_17`) + Filter `ANe1Bmh88VEqFVtHhKr6VSzykZW2wklQH4NJLQ`.
- **Hotmail (`<personal@hotmail.com>`):** Folder `Admins`.
- **Centralized Transferred Mails:** SIP exchanges and DGFiP notifications are forwarded and indexed under Gmail's `Admins` label for unified tracking.

## TickTick Automation Tasks (`🏠 Persos` > `📋 Administratif`)

Two annual recurring tasks managed via `tick-proxy` in project `📋 Administratif` (look up the project ID live):

1. **`[IMPÔTS] Déclaration annuelle en ligne des revenus (impots.gouv.fr)`**
   - **Échéance:** **20 Avril** (Répétition annuelle `RRULE:FREQ=YEARLY`, Priorité 5 / High).
   - **Action:** Se connecter sur `impots.gouv.fr` (Numéro fiscal) et vérifier/valider la déclaration de revenus pré-remplie.
2. **`[IMPÔTS] Télécharger l'Avis d'Impôt (ASDIR) & Archiver dans Gdrive`**
   - **Échéance:** **1er Août** (Répétition annuelle `RRULE:FREQ=YEARLY`, Priorité 3 / Medium).
   - **Action:** Télécharger le PDF de l'Avis d'Impôt / ASDIR depuis l'onglet Documents et le classer dans `~/Gdrive/Fr/`.

## Active / Submitted Requests (`Messagerie Sécurisée`)

Track request numbers and statuses live in the portal — never hardcoded here (they go stale on resolution).

## Key Selectors & DOM Attributes (`cfspart.impots.gouv.fr`)

- **Numéro Fiscal Input:** `#spi_tmp` or `input[name="spi"]` (13 digits).
- **FranceConnect Login Link:** `a[href*="franceconnect"]`.
- **Documents Section:** Tab `Documents` (`https://cfspart.impots.gouv.fr/enp/documents.do`).
- **PAS Management:** Tab `Prélèvement à la source` (`https://cfspart.impots.gouv.fr/enp/pas.do`).
- **Messagerie Sécurisée Portal:** `https://cfspart.impots.gouv.fr/gaia2-zu-mapi/pages/part/portailpart.xhtml`.
  - **Procedure for Off-Season Address Updates / Corrections:** When the direct 2042 correction wizard is closed, use `Messagerie sécurisée` > `Écrire` > `Changement d'adresse postale` or `Je pose une question sur mon impôt`.

## Statut Dématérialisation

- **Mail DGFiP** (`ne_pas_repondre@dgfip.finances.gouv.fr`) : « modification de vos options de dématérialisation prise en compte ».
- **Profil (live)** : `Mes avis d'impôt sur le revenu` = OPTION ACTIVÉE · `Mes avis d'impôts locaux` = OPTION ACTIVÉE → **zéro papier**.
- **Conséquence** : tous les avis/notifications futurs arrivent en Messagerie sécurisée + email d'alerte ; aucun courrier papier à attendre (ni avis, ni réponse SIP).

## Communication Prefs (since 09/09/2026 — maintainer decision)

- **Profil (live 09/09):** `Par courriel` = PRÉFÉRENCE ACTIVÉE · `Par SMS` = PRÉFÉRENCE ACTIVÉE.
- **Flow:** Profil → `Modifier vos préférences de communication` (`redirectsms.do` → `monprofil-webapp/GererMonProfil`) → checkboxes `#courriel` + `#sms` → `#btnSubmit` (`Enregistrer`) → banner `Modifications enregistrées` → back via `Retour au tableau de bord` → re-open Profil to verify.
- **Note:** checkboxes report `checked=false` on first DOM dump even when the save sticks — ground truth is the re-read Profil page, not the form dump.

## Méthode d'Exploration (09/09/2026 — GRAVÉ pour `cfspart`)

- **Contenu réel dans un iframe same-origin** : `https://cfspart.impots.gouv.fr/gaia2-zu-mapi/pages/part/portailpart.xhtml` — `document.body.innerText` de la coquille est vide ; lire via `iframe.contentDocument` (`title` + `body.innerText`).
- **Règle « clics in-page uniquement »** : naviguer en cliquant les liens du portail (`messagerie.do`, `chargementprofil.do`, `documents.do?n=0`) via JS-in-page. **JAMAIS de navigation directe (GET) vers une URL `.do`** — le 09/09 un `page-navigate` direct a cassé la session (re-login requis). Cause probable : le portail exige son flux de navigation interne (jetons).
- **Documents** : onglets années 2017→2026 avec libellé statique « document non lu » — les compteurs réels étaient tous à `0 document non lu` le 09/09 ; seuls docs présents = Avis 2025 + Déclaration 2024.

