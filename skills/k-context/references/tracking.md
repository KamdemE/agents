# KπX — Active Operational Tracking Ledger (`tracking.md`)

Centralized tracking file for all active administrative, banking, infrastructure, and service returns.

---

## 📌 Active Pending Trackers

### 1. 🏦 Société Générale (SG) — Déblocage & Ouverture du LEP à 2,7 %
- **Date d'envoi:** **06/09/2026** (via Messagerie App SG par KπX).
- **Destinataire:** Mme Andreia MENDES AREDE (Conseillère agence SG Plateau de Saclay).
- **Pièce jointe transmise:** `Taxes_FR_Avis_d_impot_2025_sur_les_revenus_2024_KAMDEM_Ivann.pdf` (Revenu Fiscal de Référence : **0 €**).
- **Objet:** Validation de l'éligibilité au Livret d'Épargne Populaire (LEP) à 2,7 % net et ouverture du compte avec versement initial de 30 €.
- **Canal de retour attendu:** Messagerie App SG / Courriel sur `ivann.kamdem@hotmail.com` (filtré automatiquement dans le dossier **`Admins`**).
- **Statut actuel:** 🟡 **EN ATTENTE DE RETOUR CONSEILLÈRE** (Échéance de relance : 11/09/2026).

---

### 2. 🏛️ DGFiP / SIP Palaiseau — Changement d'Adresse Postale (Demande N° 1242929305)
- **Date d'envoi:** **06/09/2026** (via Messagerie sécurisée `impots.gouv.fr`).
- **Demande N°:** **`1242929305`**
- **Destinataire:** Service des Impôts des Particuliers (SIP) de Palaiseau.
- **Contenu:** Déclaration de déménagement au `Bâtiment Maunoury, 9 Boulevard des Maréchaux, 91120 PALAISEAU` (Date d'effet: `06/09/2026`, Prise d'effet physique: `04/04/2025`).
- **Canal de retour:** Messagerie sécurisée `impots.gouv.fr` — réponse lue le 09/09/2026.
- **Statut actuel:** ✅ **TRAITÉE le 09/09/2026** — double preuve live : Messagerie sécurisée (`Demande traitée` + accusé de réception, Marcoussis → Maunoury/Palaiseau effet 06/09/2026) + page Profil (`Adresse postale : BATIMENT MAUNOURY 9 BD DES MARECHAUX - 91120 PALAISEAU`).
- **Dématérialisation:** ✅ active depuis le 06/09/2026 — mail DGFiP 06/09 21:11 (`ne_pas_repondre@dgfip.finances.gouv.fr`, options prises en compte) + Profil 09/09 (`Mes avis d'impôt sur le revenu` + `Mes avis d'impôts locaux` = OPTION ACTIVÉE, zéro papier).

---

### 3. 📱 Lebara France — Suivi Ligne Mobile & Consommation Data
- **Référence:** Mémoire de site `k-browser/references/sites/lebara.fr.md` (v5.5.0).
- **Objet:** Suivi de la consommation Data hors campus (~7,6 Go / mois) et stabilité de la ligne SIM sans interruption.
- **Statut actuel:** 🟢 **STABLE / MONITORING CONTINU**.

### 4. 🎓 Bourses 4A — Mail Éligibilité SquarePoint + Dossier Fundation FX/DRI
- **Date d'envoi:** **07/09/2026** (via Zimbra, `ivann.kamdem-pouokam@polytechnique.edu`).
- **Destinataire initial:** Maria Dubiel (DRI, `maria.dubiel@polytechnique.edu`) — 4 questions : extension SquarePoint→4A 2027-2028, modalités candidature, cumul SquarePoint+FX/DRI 7150€, bourse Eiffel.
- **Réponse reçue:** **08/09/2026 16:29** — Alice BERVILLE (`alice.berville@polytechnique.edu`, Incoming mobility officer) — Zimbra INBOX uid `11421`, objet `Re: Eligibilite bourse 4A SquarePoint + programme 4A en France (X2024)`.
- **Ce qu'Alice a tranché (FX/DRI 4A France + Eiffel uniquement) :**
  1. **AAC bourse 4A en France** → lancée **début décembre** (email avec éligibilité).
  2. **Montant 2027/2028** → **pas encore connu** ; années précédentes **7 150 €/an**.
  3. **Cumul** → **interdit** avec une autre bourse **≥ 615 €/mois** ; sélection **FX et DRI conjointes** → **pas de cumul FX+DRI**.
  4. **Eiffel** → **❌ impossible** à ce stade de scolarité (réservée aux élèves arrivant **pour la 1ʳᵉ fois en France**).
- **Implication SquarePoint (calcul contrat KπX) :** SquarePoint = **2 400 €/trimestre** ≈ **800 €/mois** (> 615 €) → **si SquarePoint 4A se poursuit au même rythme, cumul avec FX/DRI 4A = impossible** ; arbitrage = garder SquarePoint (plus élevée) vs postuler FX/DRI (~7 150 €) si SquarePoint non reconduite.
- **Encore OUVERT (Alice n'a PAS répondu Q1–Q2) :** éligibilité / modalités **extension SquarePoint→4A 2027-2028** (ENSTA/France). Relance Maria Dubiel et/ou Fondation SquarePoint toujours pertinente.
- **Contexte:** KπX est déjà boursier SquarePoint (extension 4A annoncée par la Fondation 10/10/2025) + projette ENSTA parcours IA + MVA double diplôme.
- **Canal de retour attendu (reste) :** Zimbra — réponses SquarePoint (Maria / Fondation).
- **Statut actuel:** 🟠 **PARTIEL — FX/DRI+Eiffel ✅ / SquarePoint ⏳** (relance SquarePoint : **~14/09/2026** ; surveiller AAC FX/DRI **début décembre 2026**).

---

## 🤖 Spécification du Daemon Agent de Suivi & Notifications (Hermes / OpenClaw)

- **Mission:** Analyser périodiquement le dossier `Admins` sur `kapoivha@gmail.com` et `ivann.kamdem@hotmail.com` via `mail-proxy`.
- **Détection ciblée:**
  1. Réponses de la Société Générale (`@notificationsclients.socgen.com`, `@societegenerale.fr`, `@sg.fr`).
  2. Réponses du SIP de Palaiseau / DGFiP (`@dgfip.finances.gouv.fr`, `Demande N° 1242929305`).
  3. Réponses bourses 4A / SquarePoint (Zimbra `ivann.kamdem-pouokam@polytechnique.edu` : objet contenant `SquarePoint`, `4A`, `bourse`, expéditeur `maria.dubiel@polytechnique.edu` ou `alice.berville@polytechnique.edu`).
- **Action de notification:** Déclencher une alerte immédiate enrichie sur Telegram via `tg-proxy` sur le bot `KpihX` (`@kpihx_general_capture_bot`).

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-09 | [LIVE] | Tracker #2 CLOS : demande N° 1242929305 **traitée** (double preuve live messagerie + profil, Marcoussis → Maunoury/Palaiseau effet 06/09) ; dématérialisation active consignée (mail DGFiP 06/09 + profil 09/09, zéro papier avis IR + locaux). |
| 2026-09-09 | [LIVE] | Tracker #4 : réponse Alice BERVILLE 08/09 (AAC déc, 7150€ histo, cumul ≥615€/mois interdit, FX≠DRI, Eiffel ❌) ; SquarePoint Q1–Q2 encore ouvert ; note cumul vs 2400€/trim SquarePoint. |
| 2026-09-07 | [LIVE] | Added tracker #4 (bourses 4A / SquarePoint mail à Maria Dubiel, relance ~14/09) + daemon detection trigger #3 (Zimbra bourses 4A). |
| 2026-09-06 | [LIVE] | Removed Vaultwarden entry from tracking (retained active trackers: SG LEP 2.7 %, DGFiP Palaiseau N° 1242929305, Lebara line). |
| 2026-09-06 | [LIVE] | Initialized `tracking.md` ledger. Added active trackers for SG LEP 2.7 % opening, DGFiP Address Demand N° 1242929305, Lebara line, and Vaultwarden. Documented daemon agent specs. |
