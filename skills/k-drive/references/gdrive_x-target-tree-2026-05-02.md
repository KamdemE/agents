# Gdrive_X Target Tree View — 2026-05-03 Revision

Scope:
- target folders only
- English-only folder naming
- exhaustive tree view
- at most 2 real file examples per folder when available

Notes:
- `.Trash-1000/` stays at the root for Ubuntu trash compatibility
- `Google AI Studio/` stays at the root
- `CV_ATF/` is intentionally absent from the target tree
- `Period_To_Confirm/` is used only where the current evidence is still insufficient to assign an exact `P1`, `P2`, or `P3` without risk
- no folder should exist only to contain a single file or a single subfolder
- examples come from the current source branch that should feed the target folder

## Full Tree View

```text
$HOME/Gdrive_X/
├── .Trash-1000/
│   ├── expunged/
│   ├── files/
│   └── info/
├── Google AI Studio/ [ex: 1.jpg; 1.pdf]
├── KpihX/ [ex: Passeport Complet KAMDEM Ivann.pdf; Attestation_Droits_Assurance_Maladie_KAMDEM_Ivann.pdf]
│   ├── Bank/ [ex: RIB_KAMDEM_Ivann.pdf; Historique UBA.pdf]
│   │   ├── BoursoBank/ [ex: flash_prospect_contract-1759162059545.pdf]
│   │   │   ├── Card/
│   │   │   ├── Procedures/ [ex: flash_prospect_contract-1759162059545.pdf]
│   │   │   └── RIB/
│   │   ├── SG/ [ex: RIB_KAMDEM_Ivann.pdf; Carte SG KAMDEM Ivann.pdf]
│   │   │   ├── Card/ [ex: Carte SG KAMDEM Ivann.pdf]
│   │   │   ├── Loan/ [ex: Contrat Prêt X SG.pdf]
│   │   │   └── RIB/ [ex: RIB_KAMDEM_Ivann.pdf; RIB_KAMDEM_Ivann.jpg]
│   │   └── UBA/ [ex: Historique UBA.pdf; Carte_Visa_UBA.pdf]
│   │       ├── Card/ [ex: Carte_Visa_UBA.pdf]
│   │       ├── Receipts/ [ex: Reçu UBA ENSPY 2021.pdf; ticket-2024.2025-PAYFIP0000000113330187.pdf]
│   │       └── Security/ [ex: UBA_Password.pdf]
│   ├── Bike_E4600/ [ex: 708088025_facture.pdf; ASSURANCE+VELO+VAE+2023_Part..pdf]
│   │   ├── Insurance/ [ex: ASSURANCE+VELO+VAE+2023_Part..pdf; certificate-AVBE2FP442.pdf]
│   │   ├── Invoice/ [ex: 708088025_facture.pdf]
│   │   └── Support/ [ex: certificate-AVBE2FP442.pdf]
│   ├── Family/ [ex: ACTE_NAISSANCE_CADETTE_METAGNE_VANESTA.pdf; CERTIFICAT_SCOLARITE_DJOMO_ALAN_CHRIST.pdf]
│   │   ├── Birth_Certificates/ [ex: ACTE_NAISSANCE_CADETTE_METAGNE_VANESTA.pdf]
│   │   ├── Death_Certificates/ [ex: ACTE_DECES_PERE_KAMDEM_GUELA.pdf]
│   │   ├── ID_Cards/ [ex: CNI_Tresor]
│   │   ├── Others/ [ex: A maman Hortense - Temoignage - KAMDEM Ivann.docx]
│   │   └── School_Certificates/ [ex: CERTIFICAT_SCOLARITE_DJOMO_ALAN_CHRIST.pdf; CERTIFICAT_SCOLARITE_METAGNE_LYSE.pdf]
│   ├── Health/ [ex: Attestation_Droits_Assurance_Maladie_KAMDEM_Ivann.pdf; Résultat_Medical_KAMDEM_Ivann_06-09-2024.pdf]
│   │   ├── Assurance_Maladie/ [ex: Attestation_Droits_Assurance_Maladie_KAMDEM_Ivann.pdf; Attestation_CSS.pdf]
│   │   ├── Certificates/ [ex: Certificat_Médical_Confidentiel_2024_KAMDEM_Ivann.pdf; Certificat_Non_Contre_Indication_Sport_KAMDEM_Ivann.pdf]
│   │   ├── Dental/ [ex: Extraction Dents de Sagesse - Athis Mons.pdf; Radiographie Dent KpihX 250725.pdf]
│   │   └── GHNE/ [ex: Résultat_Medical_KAMDEM_Ivann_06-09-2024.pdf; IMG-20240906-WA0007.jpeg]
│   ├── Identity/ [ex: Acte_Naissance_KAMDEM_POUOKAM_Ivann_Harold.pdf; Passeport Complet KAMDEM Ivann.pdf]
│   │   ├── Birth_Certificate/ [ex: Acte_Naissance_KAMDEM_POUOKAM_Ivann_Harold.pdf]
│   │   ├── Driving_License/ [ex: Permis_Conduire_KAMDEM_Ivann.pdf]
│   │   ├── ID_Card/ [ex: CNI__KAMDEM_POUOKAM_IVANN_HAROLD.pdf]
│   │   ├── Passport/ [ex: Passeport Complet KAMDEM Ivann.pdf]
│   │   └── Photos/
│   ├── Civil_Liability/ [ex: ATTESTATION_D_ASSURANCE_RESPONSABILITE_CIVILE.pdf; certificate-AVBE2FP442.pdf]
│   ├── Laptop_Dell_Inspiron_16/ [ex: Facture_Dell_Inspiron_16.pdf; Commande_Dell_Inspiron_16.pdf]
│   │   ├── Delivery/ [ex: Bordereau_Livraison.pdf]
│   │   ├── Invoice/ [ex: Facture_Dell_Inspiron_16.pdf]
│   │   └── Order/ [ex: Commande_Dell_Inspiron_16.pdf]
│   ├── Others/ [ex: Facture_Temu.PDF; Emergency Kit 1Password A3-XE3TS8-my.pdf]
│   │   ├── Illustrations/
│   │   ├── Oracle_Cloud/
│   │   ├── Personal_Admin/ [ex: Facture_Temu.PDF]
│   │   └── Reading/
│   ├── Phone_Lebara/ [ex: Sim_Lebara.pdf; Aide_Lebara.pdf]
│   │   ├── Invoice/
│   │   ├── SIM/ [ex: Sim_Lebara.pdf]
│   │   └── Support/ [ex: Aide_Lebara.pdf]
│   ├── Residence_Permit/ [ex: Titre Séjour X KAMDEM Ivann.pdf; Attestation Remise Titre de Séjour X KAMDEM Ivann.pdf]
│   │   ├── Card/ [ex: Titre Séjour X KAMDEM Ivann.pdf; Attestation Remise Titre de Séjour X KAMDEM Ivann.pdf]
│   │   └── Tax_Stamp/ [ex: CONFIRMATION_DEMANDE_TITRE_SEJOUR_9927030985_20250504.pdf]
│   ├── Taxes/ [ex: Avis_Impot.pdf]
│   │   ├── Notices/
│   │   └── Procedures/
│   ├── Transport_Navigo/ [ex: Passe Navigo KAMDEM Ivann.pdf; Contrat-NL+-63921.pdf]
│   │   ├── Card/ [ex: Passe Navigo KAMDEM Ivann.pdf]
│   │   ├── Contract/ [ex: Contrat-NL+-63921.pdf]
│   │   └── Support/ [ex: Conditions_Navigo_Liberte .pdf]
│   ├── Vault/ [ex: github-recovery-codes.txt; TestPyPI-Recovery-Codes-KpihX-2024-02-12T08_32_48.985672.txt]
│   └── Visa/ [ex: Visa_UE_KAMDEM_Ivann.pdf; Confirmation_Validation_Visa_KAMDEM_Ivann.pdf]
├── Labs/ [ex: Copie de ml-dl-nasa-2025-1 (1).ipynb; vzdump-lxc-100-2026_04_08-03_00_09.tar.zst]
│   ├── AI/ [ex: Copie de ml-dl-nasa-2025-1 (1).ipynb; my_model.h5]
│   ├── Development/ [ex: Another approach to reach zeta(2n) ?.ipynb; Challenges.docx]
│   ├── Homelab/ [ex: vzdump-lxc-100-2026_04_08-03_00_09.tar.zst; vault_backup_20260419_020001.tar.gz.gpg]
│   │   ├── Backups/ [ex: vzdump-lxc-100-2026_04_08-03_00_09.tar.zst; vault_backup_20260419_020001.tar.gz.gpg]
│   │   │   ├── LXC/ [ex: vzdump-lxc-100-2026_04_08-03_00_09.tar.zst]
│   │   │   └── Vaultwarden/ [ex: vault_backup_20260419_020001.tar.gz.gpg; vault_manual_20260406_203551.tar.gz.gpg]
│   │   ├── Docs/
│   │   └── Dumps/
│   ├── Knowledge/ [ex: 101 Balises en HTML5.pdf; Apprendre_le_ML_en_une_semaine.pdf]
│   └── Tools/ [ex: ssh-key-2025-08-04.key; ssh-key-2025-08-04.key.pub]
├── Library/ [ex: Bible.pdf; Mais qui a attrape le bison de Higgs _ - David Louapre.epub]
│   ├── Biology/ [ex: Dictionnaire médical.pdf; Encyclopédie des Médécines naturelles.pdf]
│   ├── Books/ [ex: Mais qui a attrape le bison de Higgs _ - David Louapre.epub; Quick Start Guide - John Schember.epub]
│   ├── Mathematics/ [ex: Abbott - Understanding Analysis.pdf; Analyse Vectorielle et Intégrales Multiples.pdf]
│   ├── Notes/ [ex: Contraste_251005_221101.pdf; 10 conseils contre la transpiration - Doctissimo.mhtml]
│   ├── Physics_Chemistry/ [ex: Chimie Organique.pdf; Cinématique.pdf]
│   ├── Reading/ [ex: Incentivising Reasoning Capabilitiesin LLMs via Reinforced Learning.pdf; The-Prince.pdf]
│   ├── Science/ [ex: Insoluble mais vrai  Ces énigmes et c... (Z-Library).pdf; Les grandes Lois de lunivers  de la g... (Z-Library).epub]
│   ├── Sports/ [ex: Cours EPS Toutes les classes.pdf; Records du monde d'athlétisme.pdf]
│   └── Spirituality/ [ex: Bible.pdf; Notre Père.pdf]
├── Others/ [ex: distortion.txt; A maman Hortense - Temoignage - KAMDEM Ivann.docx]
│   ├── Legacy/ [ex: distortion.txt; state.txt]
│   │   ├── Old/ [ex: distortion.txt; state.txt]
│   │   ├── OneDrive_Documents/ [ex: Attestation d'Immatriculation KAMDEM Ivann.pdf; Caution logement X .pdf]
│   │   └── Tmp/
│   ├── Media_Legacy/ [ex: Daddy🔥.jpg; Papa 1.mp4]
│   │   ├── Important/
│   │   ├── OneDrive_Sync/
│   │   ├── Personal/
│   │   └── X_To_Reclassify/
│   └── Reflections/ [ex: Olympiades de Mathématiques 2021.pdf; Puissance de 2 commençant par 777777 (1998-08-15).pdf]
│       ├── ISSEA/
│       ├── Others/ [ex: Puissance de 2 commençant par 777777 (1998-08-15).pdf]
│       ├── Preparatory_Classes/
│       ├── Problem_Sets/
│       ├── TC_OFM/
│       └── TC_Olympiads_Terminale_Intelligentsia/
├── Pro/ [ex: CV_KAMDEM_POUOKAM_Ivann_Harold.pdf; Introduction_POO_Java-Coursera_EPFL.pdf]
│   ├── Applications/ [ex: LM_KAMDEM_Ivann.pdf; BOOK RECRUTEMENT STAGE X2024.pdf]
│   │   ├── Cover_Letters/ [ex: LM_KAMDEM_Ivann.pdf; cover letter USA Ecole Polytechnique.docx]
│   │   ├── Internships/ [ex: BOOK RECRUTEMENT STAGE X2024.pdf; Livret stages 2A -X23.pdf]
│   │   ├── Jobs/
│   │   └── Recommendations/
│   ├── Certifications/ [ex: Introduction_POO_Java-Coursera_EPFL.pdf; Ivann-Harold-Kamdem--b29e - Hibrown.pdf]
│   │   ├── Language/ [ex: LinguaSkillX.zip]
│   │   ├── Online/ [ex: Introduction_POO_Java-Coursera_EPFL.pdf; Ivann-Harold-Kamdem--b29e - Hibrown.pdf]
│   │   └── Technical/ [ex: Ivann_Harold__Kamdem_Pouokam_Ivann_Harold_KAMDEM_POUOKAM_Data_Boot_Camp_2025_Data_Boot_Camp_2025_-_Completion_Certificate.pdf]
│   ├── CV/ [ex: CV_KAMDEM_POUOKAM_Ivann_Harold.pdf; En_CV_KAMDEM_POUOKAM_Ivann_Harold.pdf]
│   │   ├── English/ [ex: En_CV_KAMDEM_POUOKAM_Ivann_Harold.pdf]
│   │   ├── French/ [ex: CV_KAMDEM_POUOKAM_Ivann_Harold.pdf; CV_X_KAMDEM_POUOKAM_Ivann_Harold.pdf]
│   │   └── Sources/ [ex: CV model 2 for X with colour.docx; CV simple model for X with colour.docx]
│   └── Diplomas/ [ex: Bulletin_TC_KAMDEM_POUOKAM_Ivann_Harold.pdf; Diplome_Major_Bacc_C_Ouest_KAMDEM_Ivann.pdf]
│       ├── ENSPY/ [ex: Certificat_Scolarité_KAMDEM_POUOKAM_Ivann_Harold_3GI_ENSPY_2024.pdf; FIche_Inscription_3GI.pdf]
│       │   ├── Administrative/ [ex: FIche_Inscription_3GI.pdf; Affiliation à l'AE-ENSPY 2021.pdf]
│       │   └── Student_Life/ [ex: Affiliation Club Croix-Rouge ENSPY 2021.pdf; Affiliation à l'AE-ENSPY 2021.pdf]
│       ├── High_School/ [ex: Diplome_Major_Bacc_C_Ouest_KAMDEM_Ivann.pdf; Bulletin 2ndeC.pdf]
│       ├── Preparatory_Classes/
│       ├── Scholarships_Awards/ [ex: Bourse_Honorable_MANFOUO_David.pdf; Diplome_ZTF_Awards_2023_KAMDEM_Ivann.pdf]
│       └── X/ [ex: Bulletin_TC_KAMDEM_POUOKAM_Ivann_Harold.pdf; Certificat Scolarité 2A KAMDEM Ivann.pdf]
├── ToPrint/ [ex: IMG_20220618_200336.jpg; IMG_20220618_203157.jpg]
└── X/ [ex: Attestation_Inscription_X_KAMDEM_Ivann2.pdf; FONDATIONX-CérémonieRemiseBourses-12022026@Fondationdel'X-CorinneHameau-0058.jpg]
    ├── 2A/ [ex: 1-Intro_Development and environment_2025.pdf; 1_Intro.pdf]
    │   ├── Admin/ [ex: Campagne d'inscription 2AX24.pdf; Planning 2A 2025-2026 X24 040625.pdf]
    │   │   ├── CVEC_2025/ [ex: attestation_VER5RNWCQP34.pdf]
    │   │   ├── Internships/ [ex: Livret stages 2A -X23.pdf]
    │   │   ├── Planning/ [ex: Planning 2A 2025-2026 X24 040625.pdf; planning pâles 2AP1 X2024.pdf]
    │   │   └── Program_Guides/ [ex: Livret_PA_X24.pdf; X-Lettre-explicative-cursus.pdf]
    │   ├── Cross_Period/ [ex: BOOK RECRUTEMENT STAGE X2024.pdf; PSC Rapport Intermédiaire.zip]
    │   │   ├── BR/ [ex: 03 - Docker.pdf; 2024-BR-02-Formation Linux.pdf]
    │   │   ├── PSC/ [ex: PSC Rapport Intermédiaire.zip; Rapport final - Utilisation des LLM pour la Génération de code.pdf]
    │   │   ├── Problem_Solving_in_MAP/ [ex: README.md; requirements.txt]
    │   │   └── X_Forum/ [ex: Company Representatives Guide 2025 (English Version).pdf; Dossier-intervenants-Forum-entreprises_2025_français.pdf]
    │   ├── P1_English/ [ex: Course details P1 X2023 slides.pptx; LinkedIn.pptx]
    │   │   ├── Careers/ [ex: LinkedIn.pptx; Professional English Handbook for students.pdf]
    │   │   └── LinguaSkill/ [ex: LinguaSkillX.zip; Linguaskill presentation for X updated 2024.pptx]
    │   ├── P2/ [ex: Fiches_Algos_P2_2A.pdf; Fiches_Markov_P2_2A.pdf]
    │   │   ├── Algorithms_Design_Analysis/ [ex: Fiches_Algos_P2_2A.pdf; poly.pdf]
    │   │   ├── Power_of_Numbers/ [ex: Fiches_Pouvoir_des_nbres_P2_2A (1).pdf; Séance 1 - Introduction aux sciences sociales de la quantification.pdf]
    │   │   └── Random_Phenomena/ [ex: Fiches_Markov_P2_2A.pdf; Cours1-MAP432-2025.pdf]
    │   ├── P3/ [ex: 1_Intro.pdf; 1.pdf]
    │   │   ├── Data_Analysis_Algorithms_Python/ [ex: Intro.pdf; Slides.pdf]
    │   │   ├── English_Power_of_Shakespeare/ [ex: Act 1 Scene 2 Arden.pdf; Video Links Julius Caesar.docx]
    │   │   ├── Functional_Analysis/ [ex: Poly.pdf; PC1.pdf]
    │   │   ├── IME/ [ex: 1_Intro.pdf; 7_DM_Cas_Ubisoft.pdf]
    │   │   └── Optimization_Control/ [ex: 1.pdf; C1.pdf]
    │   └── Period_To_Confirm/ [ex: 1- ECO40235 Lec126introduction.pdf; Statistiques-APM-41033-25-26.pdf]
    │       ├── Business_Economics/ [ex: 1- ECO40235 Lec126introduction.pdf; Poly.pdf]
    │       ├── Engineering_Sustainability/ [ex: 1-Intro_Development and environment_2025.pdf; 11-Conclusion_slides.pdf]
    │       ├── Foundations_of_Computer_Science/ [ex: polyinf412-goodINF412.pdf; cours1-slides.pdf]
    │       ├── Microeconomics/ [ex: Microéconomie_ECO_41031_EP polycopié.pdf; PC4 solutions.pdf]
    │       ├── Psychoanalysis/ [ex: Cours1_Presentation.pdf; 1-Analyse du rêve dIrma-Freud.pdf]
    │       ├── Spanish/ [ex: Casa de Papel.pptx; 827806115-Uso-de-la-grama-tica-espan-ola-Nivel-elemental.pdf]
    │       └── Statistics/ [ex: Statistiques-APM-41033-25-26.pdf; cours1MAP433_final.pdf]
    ├── Admission/ [ex: Releve_Concours_X_2024.pdf; CV_KAMDEM_POUOKAM_IVANN_HAROLD.pdf]
    │   ├── Competition_File_Financial_Aid_Recommendations/ [ex: CV_KAMDEM_POUOKAM_IVANN_HAROLD.pdf; Relevés_KAMDEM_POUOKAM_IVANN_HAROLD.pdf]
    │   └── Scholarships/ [ex: CV_KAMDEM_POUOKAM_Ivann_Harold.pdf; Contrat_Bourse_SquarePoint_KAMDEM_Ivann.pdf]
    │       ├── Eiffel_Distinctions/ [ex: CV_KAMDEM_POUOKAM_Ivann_Harold.pdf; Diplome_ZTF_Awards_2023_KAMDEM_Ivann.pdf]
    │       └── Fulgence_Bienvenue_SquarePoint/ [ex: Contrat_Bourse_SquarePoint_KAMDEM_Ivann.pdf; Modèle_Contrat_Bourse_SqaurePoint.pdf]
    ├── Bad24/ [ex: FICHE  DE RENSEIGNEMENT 2CIE BADMINTON ElX KAMDEM POUOKAM Ivann Harold X24.pdf; Trombinoscope Bad.pdf]
    ├── Card/ [ex: Badge X KAMDEM Ivann.pdf; Carte X.pdf]
    ├── FH/ [ex: 2025-53023-25 03 18 XCDC Directive de soutenance de la période de FHM cycle ingénieur polytechnicien.pdf; 20250404_NP_EVALUATION-DE-STAGE_2CIE_BADMINTON_EIX-KAMDEM_POUOKAM_Ivann_Harold.pdf]
    │   ├── Activities/ [ex: IMG-20241219-WA0008.jpg]
    │   ├── Badminton/ [ex: FICHE  DE RENSEIGNEMENT 2CIE BADMINTON ElX KAMDEM POUOKAM Ivann Harold X24.pdf]
    │   └── Evaluations/ [ex: 20250404_NP_EVALUATION-DE-STAGE_2CIE_BADMINTON_EIX-KAMDEM_POUOKAM_Ivann_Harold.pdf]
    ├── Integration/ [ex: Attestation_Inscription_X_KAMDEM_Ivann2.pdf; Bienvenue à l'X_Informations diverses_X2024.pdf]
    │   ├── AgriKesture/ [ex: AgriKèsture.pdf; 2024 - AgriKèsture.jpg]
    │   ├── Campus_France_Visa/ [ex: All_documents_1722369237061.pdf; Attestation d'acceptations_CM24-05692-P01.pdf.pdf]
    │   ├── CVEC_2024/ [ex: attestation_VER4GFKJSH37_CVEC_KAMDEM_Ivann.pdf; attestation_facture_VER4GFKJSH37.pdf]
    │   ├── Fees_Exemption/
    │   ├── Flight/ [ex: Ticket Tangente.pdf]
    │   ├── Housing/ [ex: Caution logement X .pdf; Contrat_Bail.pdf]
    │   ├── Inkhorpo/ [ex: Fiche_Renseignement_KAMDEM_Ivann.pdf; Lettre félicitations X24_FR-H.pdf]
    │   ├── Medical/ [ex: Questionnaire_MB_KAMDEM_Ivann.pdf; X-Attestation inscription - KAMDEM POUOKAM.pdf]
    │   └── RC_HEYME_2024-2025/ [ex: ATTESTATION_D_ASSURANCE_RESPONSABILITE_CIVILE.pdf; Contrat engagement KAMDEM Ivann 2025-2026.pdf]
    ├── Photos/ [ex: 20240824_102712.jpg; FONDATIONX-CérémonieRemiseBourses-12022026@Fondationdel'X-CorinneHameau-0058.jpg]
    │   ├── Arrival_Gaby/ [ex: 20240824_102712.jpg; 20240824_102839.jpg]
    │   ├── Bad24/
    │   ├── Departure_Cameroon/ [ex: 20240820_142251.jpg; 20240820_142352.jpg]
    │   ├── Departure_Douala/ [ex: 20240819_212249.jpg; 20240819_212302.jpg]
    │   ├── Foundation_Scholarship_Ceremony/ [ex: FONDATIONX-CérémonieRemiseBourses-12022026@Fondationdel'X-CorinneHameau-0058.jpg; FONDATIONX-CérémonieRemiseBourses-12022026@Fondationdel'X-CorinneHameau-0076.jpg]
    │   ├── Inkhorpo/ [ex: 20240909_082800.jpg; 20240909_082805.jpg]
    │   ├── Science_Day_X24/
    │   ├── Stage_Marcoussis/ [ex: 20240916_185410.mp4; 20250317_183718.mp4]
    │   ├── TC/
    │   ├── Visit_Chatellerault/
    │   ├── Visit_Paradox_Museum/ [ex: 20241101_141853.jpg; 20241101_154417.jpg]
    │   ├── Visit_Paris_X24_October/ [ex: IMG_20241101_141853.jpg; IMG_20241101_154417.jpg]
    │   └── X24_Cam/ [ex: 20241231_232955.mp4; 20250101_175539.mp4]
    └── TC/ [ex: Cours_Python_APM3X062_EP_2024_2025.pdf; Exam Aléatoire TC 24.pdf]
        ├── Admin/ [ex: Attestation de Loyer KAMDEM Ivann.pdf; Mandat SEPA - KAMDEM Ivann.pdf]
        ├── Applied_Mathematics/ [ex: Analyse_EquationDifferentielleLineaire.pdf]
        ├── Economics/ [ex: ECO361_poly2025_3_250626_110439.pdf; Frequently Asked Questions X2024.pdf]
        ├── English/ [ex: X- English Placement Test March 2025.doc; Amphi 0 bis Langues - X24.pdf]
        ├── Java/ [ex: Exam Java TC 24.pdf; poly.pdf]
        ├── Physics/ [ex: PHY_3X061_DM.pdf; phy3x061_diapos.pdf]
        ├── Python/ [ex: Cours_Python_APM3X062_EP_2024_2025.pdf; Markdown_et_Latex.ipynb]
        ├── Randomness/ [ex: Exam Aléatoire TC 24.pdf; polyAPM-3X061-EP_33fa8430af0c9d968b989a422a8b19ef.pdf]
        ├── Real_Analysis_Introduction/ [ex: DM1.pdf; Examen Analyse Réelle intro.pdf]
        └── World_Balances_Defense_Issues/ [ex: 13052025_Chéron.pptx; Cours 5 -  Le multilatéralisme est-il en crise.pptx]
```
