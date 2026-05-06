# Gdrive_X Reorganization Proposal — 2026-05-02

Scope: exhaustive target proposal only. No filesystem action has been executed.

Goal: turn `$HOME/Gdrive_X/` into a clean, intuitive, centralized, and evolutive academic/professional storage system.

## Design Position

This proposal follows the dominant real patterns already present in the drive, but removes duplicated roots, dump zones at root level, personal branches inside institutional branches, and technical residue in document storage.

Target principles:

- one semantic root = one life function
- no duplicate roots for the same intent
- no personal-name branch inside a domain that already provides the context
- active navigation separated from archive, inbox, and system residue
- structure names standardized once and reused everywhere
- academic/professional mission takes priority over personal-memory accumulation

## Proposed Target Root

```text
$HOME/Gdrive_X/
├── 01_Identity_Admin/
├── 02_Academic/
├── 03_Professional/
├── 04_Labs_Projects/
├── 05_Resources_Knowledge/
├── 06_Media_Reference/
├── 90_Inbox_Capture/
├── 95_Archive/
└── 99_System_Quarantine/
```

| Root | Purpose |
|---|---|
| `01_Identity_Admin/` | Official identity, legal, medical, mobility, financial, and administrative records |
| `02_Academic/` | All studies, programs, transcripts, coursework, and academic history |
| `03_Professional/` | CV, certifications, applications, internships, branding, print-ready professional assets |
| `04_Labs_Projects/` | Technical projects, AI/dev work, homelab archives, and project-support knowledge |
| `05_Resources_Knowledge/` | Books, readings, notes, science, spirituality, and curated references |
| `06_Media_Reference/` | Only mission-relevant media supporting academic/professional memory or presentation |
| `90_Inbox_Capture/` | Temporary unsorted intake for new imports and raw dumps |
| `95_Archive/` | Cold historical material retained for provenance, not daily browsing |
| `99_System_Quarantine/` | Trash, notebook residue, repo metadata, and other non-curated system artifacts |

## Canonical Substructures

### `01_Identity_Admin/`

```text
01_Identity_Admin/
├── Legal/
├── Admin/
│   ├── Banking/
│   ├── Cards/
│   ├── Invoices/
│   ├── Medical/
│   ├── Mobility/
│   ├── Procedures/
│   └── Scans_Images/
├── Education_Admin/
└── Vault/
```

### `02_Academic/`

```text
02_Academic/
├── X/
│   ├── Admissions_Integration/
│   ├── Scholarships/
│   ├── Student_Record/
│   ├── Student_Life/
│   ├── Common_Trunk_TC/
│   ├── Year_2A/
│   ├── Language_Certifications/
│   ├── Prep_History/
│   ├── General_Orientation/
│   └── Templates/
├── ENSPY/
├── Academic_History/
└── Foundations_By_Subject/
```

### `03_Professional/`

```text
03_Professional/
├── CV_ATF/
├── Certifications/
├── Internships/
├── Applications/
├── Print_Assets/
└── Branding_Profile/
```

### `04_Labs_Projects/`

```text
04_Labs_Projects/
├── AI/
├── Development/
├── Homelab/
│   └── Backups/
├── Knowledge_Engineering/
└── Tools_Admin/
```

### `05_Resources_Knowledge/`

```text
05_Resources_Knowledge/
├── Books/
├── Reading/
├── Notes/
├── Science/
├── Spirituality/
├── Travel/
├── Technical_Reference/
└── Legacy_Document_Archive/
```

### `06_Media_Reference/`

```text
06_Media_Reference/
├── X_Events/
├── Official_Photos/
├── Illustrations/
├── Product_Reference/
└── Selected_Personal_Context/
```

## Root-Level Diff

| Current root | Action | Target |
|---|---|---|
| `Academic/` | `rename` | `02_Academic` |
| `Google AI Studio/` | `move` | `90_Inbox_Capture/Google_AI_Studio_Dump` |
| `Homelab/` | `move` | `04_Labs_Projects/Homelab/Backups/Standalone_Homelab_Root` |
| `Identity/` | `rename` | `01_Identity_Admin` |
| `Labs/` | `rename` | `04_Labs_Projects` |
| `Library/` | `rename` | `05_Resources_Knowledge` |
| `Media/` | `split` | `06_Media_Reference + 95_Archive/Personal_Media_Pending_Transfer` |
| `Old/` | `move` | `95_Archive/Legacy_Pre_Reorg/Old` |
| `tmp/` | `move` | `99_System_Quarantine/Sync_Residue/tmp` |
| `.Trash-1000/` | `quarantine` | `99_System_Quarantine/Trash_Metadata/.Trash-1000` |

## Migration Rules That Drive The Exhaustive Diff

- Flatten `Academic/X/K𝜋X/` into canonical `02_Academic/X/...` or `03_Professional/...` destinations; the personal-name branch disappears as a structural concept.
- Merge the duplicate academic integration and scholarship branches under one canonical destination each.
- Split `Media/` between mission-relevant reference media and cold personal archive; do not keep the current root as-is.
- Merge `Media/Photos/Persos/X` and `Media/Photos/OneDrive_Sync/X` into one event-media tree before any long-term placement.
- Move `Google AI Studio/` to an explicit inbox root so future dumps never pollute the curated root again.
- Keep backups under a single homelab backup namespace instead of both `Homelab/` and `Labs/Homelab/`.
- Quarantine `.Trash-1000/`, `.git/`, `.ipynb_checkpoints/`, OneNote recycle bins, and similar technical residue from normal browsing logic.

## Exhaustive Directory Diff

| Current directory | Action | Proposed target | Rationale |
|---|---|---|---|
| `$HOME/Gdrive_X` | `keep` | `$HOME/Gdrive_X` | drive root kept, but internal roots renumbered |
| `$HOME/Gdrive_X/.Trash-1000` | `quarantine` | `99_System_Quarantine/Trash_Metadata/.Trash-1000` | system trash metadata isolated from daily navigation |
| `$HOME/Gdrive_X/.Trash-1000/expunged` | `quarantine` | `99_System_Quarantine/Trash_Metadata/.Trash-1000` | system trash metadata isolated from daily navigation |
| `$HOME/Gdrive_X/.Trash-1000/files` | `quarantine` | `99_System_Quarantine/Trash_Metadata/.Trash-1000` | system trash metadata isolated from daily navigation |
| `$HOME/Gdrive_X/.Trash-1000/info` | `quarantine` | `99_System_Quarantine/Trash_Metadata/.Trash-1000` | system trash metadata isolated from daily navigation |
| `$HOME/Gdrive_X/Academic` | `rename` | `02_Academic` | root renamed and standardized |
| `$HOME/Gdrive_X/Academic/ENSPY` | `move` | `02_Academic/ENSPY` | kept as dedicated academic branch |
| `$HOME/Gdrive_X/Academic/ENSPY/Official_Docs` | `move` | `02_Academic/ENSPY/Official_Docs` | kept as dedicated academic branch |
| `$HOME/Gdrive_X/Academic/History` | `move` | `02_Academic/Academic_History` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Autres` | `move` | `02_Academic/Academic_History/Autres` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Autres/Actes_Naissance` | `move` | `02_Academic/Academic_History/Autres/Actes_Naissance` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Autres/CNI_Tresor` | `move` | `02_Academic/Academic_History/Autres/CNI_Tresor` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Autres/Certificats_Scolarité` | `move` | `02_Academic/Academic_History/Autres/Certificats_Scolarité` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Diplomas` | `move` | `02_Academic/Academic_History/Diplomas` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Informations` | `move` | `02_Academic/Academic_History/Informations` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Leaders` | `move` | `02_Academic/Academic_History/Leaders` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions` | `move` | `02_Academic/Academic_History/Reflexions` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/Autres` | `move` | `02_Academic/Academic_History/Reflexions/Autres` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/ISSEA` | `move` | `02_Academic/Academic_History/Reflexions/ISSEA` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/PC` | `move` | `02_Academic/Academic_History/Reflexions/PC` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/Prépas` | `move` | `02_Academic/Academic_History/Reflexions/Prépas` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/TC` | `move` | `02_Academic/Academic_History/Reflexions/TC` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/TC/OFM` | `move` | `02_Academic/Academic_History/Reflexions/TC/OFM` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/History/Reflexions/TC/Olympiades Tles Intelligentsia` | `move` | `02_Academic/Academic_History/Reflexions/TC/Olympiades Tles Intelligentsia` | history normalized under academic history |
| `$HOME/Gdrive_X/Academic/Subjects` | `move` | `02_Academic/Foundations_By_Subject` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Biology` | `move` | `02_Academic/Foundations_By_Subject/Biology` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/EPS` | `move` | `02_Academic/Foundations_By_Subject/EPS` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Maths` | `move` | `02_Academic/Foundations_By_Subject/Maths` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Maths/Exo7Maths, Python` | `move` | `02_Academic/Foundations_By_Subject/Maths/Exo7Maths, Python` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Maths/Exo7Maths, Python/Cours` | `move` | `02_Academic/Foundations_By_Subject/Maths/Exo7Maths, Python/Cours` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Maths/Pour_Approfondir` | `move` | `02_Academic/Foundations_By_Subject/Maths/Pour_Approfondir` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Maths/Series de Fourrier` | `move` | `02_Academic/Foundations_By_Subject/Maths/Series de Fourrier` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Maths/Suites & Serie de Fonctions` | `move` | `02_Academic/Foundations_By_Subject/Maths/Suites & Serie de Fonctions` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Physique_Chimie` | `move` | `02_Academic/Foundations_By_Subject/Physique_Chimie` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Physique_Chimie/2ndC` | `move` | `02_Academic/Foundations_By_Subject/Physique_Chimie/2ndC` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Physique_Chimie/Femtophysique` | `move` | `02_Academic/Foundations_By_Subject/Physique_Chimie/Femtophysique` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Physique_Chimie/PC` | `move` | `02_Academic/Foundations_By_Subject/Physique_Chimie/PC` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/Physique_Chimie/TC` | `move` | `02_Academic/Foundations_By_Subject/Physique_Chimie/TC` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/Subjects/SH` | `move` | `02_Academic/Foundations_By_Subject/SH` | cross-subject foundation corpus standardized |
| `$HOME/Gdrive_X/Academic/X` | `move` | `02_Academic/X` | X kept as main academic program root |
| `$HOME/Gdrive_X/Academic/X/2A` | `move` | `02_Academic/X/Year_2A` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais` | `move` | `02_Academic/X/Year_2A/Anglais` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/CVS` | `move` | `02_Academic/X/Year_2A/Anglais/CVS` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/CVs and cover letters-20250921` | `move` | `02_Academic/X/Year_2A/Anglais/CVs and cover letters-20250921` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/General careers resources (handbook amp presentation slides)-20250908` | `move` | `02_Academic/X/Year_2A/Anglais/General careers resources (handbook amp presentation slides)-20250908` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/LinguaSkillX` | `move` | `02_Academic/X/Year_2A/Anglais/LinguaSkillX` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/LinguaSkillX/Linguaskill complete listening test-20260129` | `move` | `02_Academic/X/Year_2A/Anglais/LinguaSkillX/Linguaskill complete listening test-20260129` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/LinguaSkillX/Linguaskill complete listening test-20260129/Linguaskill complete listening test` | `move` | `02_Academic/X/Year_2A/Anglais/LinguaSkillX/Linguaskill complete listening test-20260129/Linguaskill complete listening test` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Anglais/P3` | `move` | `02_Academic/X/Year_2A/Anglais/P3` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/BR` | `move` | `02_Academic/X/Year_2A/BR` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/BR/PVE_SALT` | `move` | `02_Academic/X/Year_2A/BR/PVE_SALT` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/BR/PVE_SALT/scripts` | `move` | `02_Academic/X/Year_2A/BR/PVE_SALT/scripts` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Conception & Analyse des algortihmes` | `move` | `02_Academic/X/Year_2A/Conception & Analyse des algortihmes` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Conception & Analyse des algortihmes/Projets` | `move` | `02_Academic/X/Year_2A/Conception & Analyse des algortihmes/Projets` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Economie d'Entreprise` | `move` | `02_Academic/X/Year_2A/Economie d'Entreprise` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Economie d'Entreprise/Cas Google` | `move` | `02_Academic/X/Year_2A/Economie d'Entreprise/Cas Google` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Economie d'Entreprise/Finance` | `move` | `02_Academic/X/Year_2A/Economie d'Entreprise/Finance` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability` | `move` | `02_Academic/X/Year_2A/Engineering sustainability` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/Cas final` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/Cas final` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/Cas final/EnSu_CasFinal_CompensationEcologique` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/Cas final/EnSu_CasFinal_CompensationEcologique` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/Cas final/reponses basiques IA` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/Cas final/reponses basiques IA` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/Energy Technology` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/Energy Technology` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/Energy Technology/Ressource_Exhaution` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/Energy Technology/Ressource_Exhaution` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/LCA` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/LCA` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/LCA/Guide installation SimaPro & Agribalyse` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/LCA/Guide installation SimaPro & Agribalyse` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/LCA/LCA3` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/LCA/LCA3` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Engineering sustainability/LCA/Session 4 circular economy-20250916` | `move` | `02_Academic/X/Year_2A/Engineering sustainability/LCA/Session 4 circular economy-20250916` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Española` | `move` | `02_Academic/X/Year_2A/Española` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Infos` | `move` | `02_Academic/X/Year_2A/Infos` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Le pouvoir des nbres` | `move` | `02_Academic/X/Year_2A/Le pouvoir des nbres` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Micro économie` | `move` | `02_Academic/X/Year_2A/Micro économie` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3- Optimisation & Controle` | `move` | `02_Academic/X/Year_2A/P3- Optimisation & Controle` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Algos pour l'analyse de données en Python` | `move` | `02_Academic/X/Year_2A/P3-Algos pour l'analyse de données en Python` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Algos pour l'analyse de données en Python/PC1` | `move` | `02_Academic/X/Year_2A/P3-Algos pour l'analyse de données en Python/PC1` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin` | `move` | `02_Academic/X/Year_2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin/TD` | `move` | `02_Academic/X/Year_2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin/TD` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin/scripts` | `move` | `02_Academic/X/Year_2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin/scripts` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin/tests` | `move` | `02_Academic/X/Year_2A/P3-Algos pour l'analyse de données en Python/PC1/CSC43042EP-td1-1-handin/tests` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Analyse fonctionnelle` | `move` | `02_Academic/X/Year_2A/P3-Analyse fonctionnelle` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Analyse fonctionnelle/DMs` | `move` | `02_Academic/X/Year_2A/P3-Analyse fonctionnelle/DMs` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-Anglais-The_Power_of_Shakespeare` | `move` | `02_Academic/X/Year_2A/P3-Anglais-The_Power_of_Shakespeare` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-IME` | `move` | `02_Academic/X/Year_2A/P3-IME` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-IME/DM` | `move` | `02_Academic/X/Year_2A/P3-IME/DM` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-IME/Orientation 3A` | `move` | `02_Academic/X/Year_2A/P3-IME/Orientation 3A` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/P3-IME/Sountenance Stage 2A` | `move` | `02_Academic/X/Year_2A/P3-IME/Sountenance Stage 2A` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/PSC` | `move` | `02_Academic/X/Year_2A/PSC` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Phénomènes aléatoires` | `move` | `02_Academic/X/Year_2A/Phénomènes aléatoires` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/hooks` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/hooks` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/info` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/info` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/logs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/logs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/logs/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/logs/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/logs/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/logs/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/logs/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/logs/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/logs/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/logs/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/07` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/07` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/08` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/08` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/0c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/0c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/11` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/11` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/13` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/13` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/16` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/16` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/17` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/17` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/18` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/18` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/21` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/21` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/28` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/28` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/2e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/2e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/30` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/30` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/34` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/34` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/35` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/35` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/39` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/39` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/3a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/3a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/40` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/40` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/44` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/44` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/48` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/48` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/4f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/4f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/51` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/51` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/53` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/53` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/57` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/57` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/59` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/59` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/5c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/5c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/63` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/63` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/65` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/65` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/68` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/68` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/6a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/6a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/6c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/6c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/71` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/71` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/72` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/72` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/73` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/73` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/7b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/7b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/7e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/7e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/80` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/80` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/83` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/83` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/86` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/86` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/87` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/87` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/89` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/89` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/8c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/8c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/8f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/8f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/90` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/90` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/93` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/93` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/96` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/96` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/9a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/9a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/9c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/9c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/9f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/9f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/a1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/a1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/a4` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/a4` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/a6` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/a6` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/a7` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/a7` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/a8` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/a8` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/ac` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/ac` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/b0` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/b0` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/b5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/b5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/b9` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/b9` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/bc` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/bc` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/bd` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/bd` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/c0` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/c0` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/c3` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/c3` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/c4` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/c4` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/c5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/c5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/ce` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/ce` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/cf` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/cf` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/d2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/d2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/d3` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/d3` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/d5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/d5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/da` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/da` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/db` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/db` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/dd` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/dd` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/e1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/e1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/e2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/e2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/ea` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/ea` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/ec` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/ec` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/ee` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/ee` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/f1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/f1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/fb` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/fb` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/objects/ff` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/objects/ff` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/.git/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/2A/Problem solving en MAP/.git/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP1_Eigenvalue` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP1_Eigenvalue` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP2_Compression_Jpeg` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP2_Compression_Jpeg` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP3_Bandits_Renforcement` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP3_Bandits_Renforcement` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP3_Bandits_Renforcement/figures` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP3_Bandits_Renforcement/figures` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP3_Bandits_Renforcement/style` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP3_Bandits_Renforcement/style` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP4_Tri_Randomisé` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP4_Tri_Randomisé` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP4_Tri_Randomisé/figures` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP4_Tri_Randomisé/figures` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP4_Tri_Randomisé/style` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP4_Tri_Randomisé/style` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP5_Maillage` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP5_Maillage` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP6_Arret_Optimal` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP6_Arret_Optimal` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP6_Arret_Optimal/style` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP6_Arret_Optimal/style` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP7_Eqn_Eikonale` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP7_Eqn_Eikonale` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP8_kSAT_MonteCarlo` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP8_kSAT_MonteCarlo` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP8_kSAT_MonteCarlo/figures` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP8_kSAT_MonteCarlo/figures` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Problem solving en MAP/TP8_kSAT_MonteCarlo/style` | `move` | `02_Academic/X/Year_2A/Problem solving en MAP/TP8_kSAT_MonteCarlo/style` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Psy` | `move` | `02_Academic/X/Year_2A/Psy` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats` | `move` | `02_Academic/X/Year_2A/Stats` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/Autres ressources - stats` | `move` | `02_Academic/X/Year_2A/Stats/Autres ressources - stats` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/DM1` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/DM1` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/DM2` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/DM2` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/EN1` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/EN1` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/EN2` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/EN2` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/EN3` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/EN3` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/EN3/data` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/EN3/data` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/EN3/data/MNIST` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/EN3/data/MNIST` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/Stats/EN & DM/EN3/data/MNIST/raw` | `move` | `02_Academic/X/Year_2A/Stats/EN & DM/EN3/data/MNIST/raw` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/X-Forum` | `move` | `02_Academic/X/Year_2A/X-Forum` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/2A/fondements de l'informatique` | `move` | `02_Academic/X/Year_2A/fondements de l'informatique` | current core year branch standardized |
| `$HOME/Gdrive_X/Academic/X/Autres` | `move` | `02_Academic/X/General_Misc` | misc branch must be eliminated later by reclassification |
| `$HOME/Gdrive_X/Academic/X/Bourses` | `move` | `02_Academic/X/Scholarships` | scholarship branch normalized |
| `$HOME/Gdrive_X/Academic/X/Bourses/Bourse_Eiffel` | `move` | `02_Academic/X/Scholarships/Bourse_Eiffel` | scholarship branch normalized |
| `$HOME/Gdrive_X/Academic/X/Bourses/Bourse_Eiffel/Modèles_Lettre_Motivation` | `move` | `02_Academic/X/Scholarships/Bourse_Eiffel/Modèles_Lettre_Motivation` | scholarship branch normalized |
| `$HOME/Gdrive_X/Academic/X/Bourses/Bourse_Fulgence_Bienvenüe_SquarePoint` | `move` | `02_Academic/X/Scholarships/Bourse_Fulgence_Bienvenüe_SquarePoint` | scholarship branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration` | `move` | `02_Academic/X/Admissions_Integration` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration/AgriKèsture` | `move` | `02_Academic/X/Admissions_Integration/AgriKèsture` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration/Campus_Fr_Visa` | `move` | `02_Academic/X/Admissions_Integration/Campus_Fr_Visa` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration/Inkhorpo` | `move` | `02_Academic/X/Admissions_Integration/Inkhorpo` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration/Inkhorpo/Chants` | `move` | `02_Academic/X/Admissions_Integration/Inkhorpo/Chants` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration/Planning_X24` | `move` | `02_Academic/X/Admissions_Integration/Planning_X24` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/Dossier_Integration/Templates` | `move` | `02_Academic/X/Admissions_Integration/Templates` | integration/admissions branch normalized |
| `$HOME/Gdrive_X/Academic/X/FH` | `move` | `02_Academic/X/Student_Life/FH` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Activités_Noel` | `move` | `02_Academic/X/Student_Life/FH/Activités_Noel` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Chasse_Trésor_Ficweiss` | `move` | `02_Academic/X/Student_Life/FH/Chasse_Trésor_Ficweiss` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Emplois_Temps` | `move` | `02_Academic/X/Student_Life/FH/Emplois_Temps` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Oscars` | `move` | `02_Academic/X/Student_Life/FH/Oscars` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Oscars/Edelweiss` | `move` | `02_Academic/X/Student_Life/FH/Oscars/Edelweiss` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Oscars/Ficus` | `move` | `02_Academic/X/Student_Life/FH/Oscars/Ficus` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Oscars/Myosotis` | `move` | `02_Academic/X/Student_Life/FH/Oscars/Myosotis` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Outdoor Activities` | `move` | `02_Academic/X/Student_Life/FH/Outdoor Activities` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Outdoor Activities/Chasse_Trésor` | `move` | `02_Academic/X/Student_Life/FH/Outdoor Activities/Chasse_Trésor` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Outdoor Activities/Chasse_Trésor/Indices en image` | `move` | `02_Academic/X/Student_Life/FH/Outdoor Activities/Chasse_Trésor/Indices en image` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Outdoor Activities/Chasse_Trésor/Indices en image/QR Codes` | `move` | `02_Academic/X/Student_Life/FH/Outdoor Activities/Chasse_Trésor/Indices en image/QR Codes` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Outdoor Activities/Without bg` | `move` | `02_Academic/X/Student_Life/FH/Outdoor Activities/Without bg` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Photos` | `move` | `02_Academic/X/Student_Life/FH/Photos` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Photos/Edelweiss` | `move` | `02_Academic/X/Student_Life/FH/Photos/Edelweiss` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Photos/Ficus` | `move` | `02_Academic/X/Student_Life/FH/Photos/Ficus` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Photos/Myosotis` | `move` | `02_Academic/X/Student_Life/FH/Photos/Myosotis` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Promethean` | `move` | `02_Academic/X/Student_Life/FH/Promethean` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Rapport FH` | `move` | `02_Academic/X/Student_Life/FH/Rapport FH` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/FH/Rapport FH/Images Rapport` | `move` | `02_Academic/X/Student_Life/FH/Rapport FH/Images Rapport` | student-life media/events isolated from core academics |
| `$HOME/Gdrive_X/Academic/X/Généralités` | `move` | `02_Academic/X/General_Orientation` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/A propos de l'oral` | `move` | `02_Academic/X/General_Orientation/A propos de l'oral` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/centrale` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/centrale` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours commun polytechnique` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours commun polytechnique` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours commun polytechnique/corrige maths` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours commun polytechnique/corrige maths` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours commun polytechnique/maths` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours commun polytechnique/maths` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours commun polytechnique/physique` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours commun polytechnique/physique` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours des MinesPonts` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours des MinesPonts` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours des MinesPonts/informatique` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours des MinesPonts/informatique` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours des MinesPonts/maths` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours des MinesPonts/maths` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours des MinesPonts/maths/corriges` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours des MinesPonts/maths/corriges` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours des MinesPonts/maths/epreuves` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours des MinesPonts/maths/epreuves` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Autres Ecoles/concours des MinesPonts/physique` | `move` | `02_Academic/X/General_Orientation/Autres Ecoles/concours des MinesPonts/physique` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Informations sur le concours de l'X` | `move` | `02_Academic/X/General_Orientation/Informations sur le concours de l'X` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Présentation de l'Ecole Polytechnique (l'X)` | `move` | `02_Academic/X/General_Orientation/Présentation de l'Ecole Polytechnique (l'X)` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Présentation de l'Ecole Polytechnique (l'X)/Programmes_Niveau3` | `move` | `02_Academic/X/General_Orientation/Présentation de l'Ecole Polytechnique (l'X)/Programmes_Niveau3` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Présentation de l'Ecole Polytechnique (l'X)/Vidéos` | `move` | `02_Academic/X/General_Orientation/Présentation de l'Ecole Polytechnique (l'X)/Vidéos` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/Généralités/Résultats` | `move` | `02_Academic/X/General_Orientation/Résultats` | orientation/general-information standardized |
| `$HOME/Gdrive_X/Academic/X/K𝜋X` | `move` | `02_Academic/X/Student_Record` | duplicate personal X branch flattened into student record root |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A` | `move` | `02_Academic/X/Student_Record/2A` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Anglais` | `move` | `02_Academic/X/Student_Record/2A/Anglais` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Anglais/Interview` | `move` | `02_Academic/X/Student_Record/2A/Anglais/Interview` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/CVEC` | `move` | `02_Academic/X/Student_Record/2A/CVEC` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Certificat Scolarité 2A KAMDEM Ivann` | `move` | `02_Academic/X/Student_Record/2A/Certificat Scolarité 2A KAMDEM Ivann` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/EuroTEQ` | `move` | `02_Academic/X/Student_Record/2A/EuroTEQ` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Internships` | `move` | `03_Professional/Internships` | internship branch is career-facing, not student-record structural |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Internships/Artmajeur` | `move` | `03_Professional/Internships/Artmajeur` | internship branch is career-facing, not student-record structural |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Internships/DxO` | `move` | `03_Professional/Internships/DxO` | internship branch is career-facing, not student-record structural |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Internships/Google` | `move` | `03_Professional/Internships/Google` | internship branch is career-facing, not student-record structural |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/2A/Internships/Lighton` | `move` | `03_Professional/Internships/Lighton` | internship branch is career-facing, not student-record structural |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire` | `move` | `02_Academic/X/Common_Trunk_TC/Aleatoire_KpiX_Legacy` | duplicate random/aleatoire branch kept as legacy academic material |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit` | `move` | `02_Academic/X/Common_Trunk_TC/Aleatoire_KpiX_Legacy/sampler-kit` | duplicate random/aleatoire branch kept as legacy academic material |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/hooks` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/hooks` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/info` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/info` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/logs/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/19` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/19` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/35` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/35` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/3f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/3f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/52` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/52` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/8f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/8f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/92` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/92` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/a9` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/a9` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/b2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/b2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/e3` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/e3` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/e5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/e5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/fa` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/objects/fa` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/Aleatoire/sampler-kit/.git/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Bad24` | `move` | `02_Academic/X/Student_Life/Bad24` | student-life branch flattened under X student life |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Bourse_Eiffel` | `move` | `02_Academic/X/Scholarships/Bourse_Eiffel` | personal duplicate scholarship branch merged under canonical scholarships |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Bourse_Eiffel/Distinctions` | `move` | `02_Academic/X/Scholarships/Bourse_Eiffel/Distinctions` | personal duplicate scholarship branch merged under canonical scholarships |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Bourse_Fulgence_Bienvenüe_SquarePoint` | `move` | `02_Academic/X/Scholarships/Bourse_Fulgence_Bienvenue_SquarePoint` | personal duplicate scholarship branch merged under canonical scholarships |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Carte X` | `move` | `02_Academic/X/Student_Record/Card_X` | personal student record artifact flattened |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Concours` | `move` | `02_Academic/X/Student_Record/Dossier_Concours` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Concours/Aide_Financiere` | `move` | `02_Academic/X/Student_Record/Dossier_Concours/Aide_Financiere` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Concours/Aide_Financiere/Documents_Mère-MADEYO_Rita` | `move` | `02_Academic/X/Student_Record/Dossier_Concours/Aide_Financiere/Documents_Mère-MADEYO_Rita` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Concours/Recommandations` | `move` | `02_Academic/X/Student_Record/Dossier_Concours/Recommandations` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Concours/Recommandations/RecommandationPrBOUETOU` | `move` | `02_Academic/X/Student_Record/Dossier_Concours/Recommandations/RecommandationPrBOUETOU` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Concours/Recommandations/RecommandationPrTchomgo` | `move` | `02_Academic/X/Student_Record/Dossier_Concours/Recommandations/RecommandationPrTchomgo` | duplicate personal X subtree flattened under student record |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration` | `move` | `02_Academic/X/Admissions_Integration` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/AgriKèsture` | `move` | `02_Academic/X/Admissions_Integration/AgriKèsture` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/CVEC` | `move` | `02_Academic/X/Admissions_Integration/CVEC` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Campus_Fr_Visa` | `move` | `02_Academic/X/Admissions_Integration/Campus_Fr_Visa` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Exoneration_Frais` | `move` | `02_Academic/X/Admissions_Integration/Exoneration_Frais` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Inkhorpo` | `move` | `02_Academic/X/Admissions_Integration/Inkhorpo` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Medical` | `move` | `02_Academic/X/Admissions_Integration/Medical` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Medical/Assurance_Maladie` | `move` | `02_Academic/X/Admissions_Integration/Medical/Assurance_Maladie` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Medical/GHNE` | `move` | `02_Academic/X/Admissions_Integration/Medical/GHNE` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/RC_HEYME_2024-2025` | `move` | `02_Academic/X/Admissions_Integration/RC_HEYME_2024-2025` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/Dossier_Intégration/Vol` | `move` | `02_Academic/X/Admissions_Integration/Vol` | accented duplicate integration branch merged under canonical admissions/integration |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC` | `move` | `02_Academic/X/Common_Trunk_TC` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Administratifs` | `move` | `02_Academic/X/Common_Trunk_TC/Administratifs` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Autres` | `move` | `02_Academic/X/Common_Trunk_TC/Autres` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/English test` | `move` | `02_Academic/X/Common_Trunk_TC/English test` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Physique` | `move` | `02_Academic/X/Common_Trunk_TC/Physique` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python` | `move` | `02_Academic/X/Common_Trunk_TC/Python` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/.ipynb_checkpoints` | `quarantine` | `99_System_Quarantine/Notebook_Residue/Academic/X/K𝜋X/TC/Python/.ipynb_checkpoints` | notebook checkpoints are runtime residue, not curated storage |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/TP` | `move` | `02_Academic/X/Common_Trunk_TC/Python/TP` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen` | `move` | `02_Academic/X/Common_Trunk_TC/Python/gauss-gen` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/hooks` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/hooks` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/info` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/info` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/remotes/origin/codex` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/logs/refs/remotes/origin/codex` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/05` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/05` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/13` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/13` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/14` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/14` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/1e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/1e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/33` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/33` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/35` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/35` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/49` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/49` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/4c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/4c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/4f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/4f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/51` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/51` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/53` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/53` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/5e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/5e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/63` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/63` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/69` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/69` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/6b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/6b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/73` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/73` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/83` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/83` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/9b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/9b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/a1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/a1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/b1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/b1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/b7` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/b7` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/bc` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/bc` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/bd` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/bd` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/c5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/c5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/d4` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/d4` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/ec` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/ec` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/f8` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/objects/f8` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/remotes/origin/codex` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/K𝜋X/TC/Python/gauss-gen/.git/refs/remotes/origin/codex` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Pâles` | `move` | `02_Academic/X/Common_Trunk_TC/Pâles` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Équilibres mondiaux et enjeux de la défense` | `move` | `02_Academic/X/Common_Trunk_TC/Équilibres mondiaux et enjeux de la défense` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/K𝜋X/TC/Équilibres mondiaux et enjeux de la défense/Évaluation théorie de la guerre juste_files` | `move` | `02_Academic/X/Common_Trunk_TC/Équilibres mondiaux et enjeux de la défense/Évaluation théorie de la guerre juste_files` | duplicate TC branch merged under canonical TC |
| `$HOME/Gdrive_X/Academic/X/LinguaSkill` | `move` | `02_Academic/X/Language_Certifications/LinguaSkill` | language certification standardized |
| `$HOME/Gdrive_X/Academic/X/Modèles_Dossier_Concours` | `move` | `02_Academic/X/Templates/Contest_Application_Models` | template/model branch normalized |
| `$HOME/Gdrive_X/Academic/X/Modèles_Dossier_Concours/Exemples` | `move` | `02_Academic/X/Templates/Contest_Application_Models/Exemples` | template/model branch normalized |
| `$HOME/Gdrive_X/Academic/X/Prépas` | `move` | `02_Academic/X/Prep_History` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours` | `move` | `02_Academic/X/Prep_History/Cours` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Anglais` | `move` | `02_Academic/X/Prep_History/Cours/Anglais` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Français` | `move` | `02_Academic/X/Prep_History/Cours/Français` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths` | `move` | `02_Academic/X/Prep_History/Cours/Maths` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH/COURS ALAIN TROESCH` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH/COURS ALAIN TROESCH` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH/DM ALAIN TROESCH` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH/DM ALAIN TROESCH` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH/DS ALAIN TROESCH` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH/DS ALAIN TROESCH` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH/INTERROGATIONS ALAIN TROESCH` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH/INTERROGATIONS ALAIN TROESCH` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH/References` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH/References` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/ALAIN TROESCH/SUJETS ALAIN TROESCH` | `move` | `02_Academic/X/Prep_History/Cours/Maths/ALAIN TROESCH/SUJETS ALAIN TROESCH` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Arnaudiès` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Arnaudiès` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Gourdon` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Gourdon` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Incontournables` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Incontournables` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Methodix` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Methodix` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Monier` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Monier` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Ramis` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Ramis` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/Series_30_fiches` | `move` | `02_Academic/X/Prep_History/Cours/Maths/Series_30_fiches` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Maths/colles` | `move` | `02_Academic/X/Prep_History/Cours/Maths/colles` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Physique` | `move` | `02_Academic/X/Prep_History/Cours/Physique` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Physique/Autres` | `move` | `02_Academic/X/Prep_History/Cours/Physique/Autres` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Physique/HPrepa` | `move` | `02_Academic/X/Prep_History/Cours/Physique/HPrepa` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Physique/Pbs` | `move` | `02_Academic/X/Prep_History/Cours/Physique/Pbs` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Cours/Physique/Physique Tout En Un` | `move` | `02_Academic/X/Prep_History/Cours/Physique/Physique Tout En Un` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Ecrit` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Ecrit` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Ecrit/Anglais` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Ecrit/Anglais` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Ecrit/Français` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Ecrit/Français` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Ecrit/Maths` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Ecrit/Maths` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Ecrit/Physique` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Ecrit/Physique` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Oral` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Oral` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Oral/ADS` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Oral/ADS` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Oral/Maths` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Oral/Maths` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Oral/Maths +` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Oral/Maths +` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Oral/Oraux_par_années` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Oral/Oraux_par_années` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Epreuves et Rapports/Oral/Physique +` | `move` | `02_Academic/X/Prep_History/Epreuves et Rapports/Oral/Physique +` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Ex_Programmes` | `move` | `02_Academic/X/Prep_History/Ex_Programmes` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Ex_Programmes/TDs` | `move` | `02_Academic/X/Prep_History/Ex_Programmes/TDs` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs` | `move` | `02_Academic/X/Prep_History/Pbs` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/Analyse fonctionnelle` | `move` | `02_Academic/X/Prep_History/Pbs/Analyse fonctionnelle` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/Autres Pbs` | `move` | `02_Academic/X/Prep_History/Pbs/Autres Pbs` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/Exos` | `move` | `02_Academic/X/Prep_History/Pbs/Exos` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/algèbre linéaire ccp` | `move` | `02_Academic/X/Prep_History/Pbs/algèbre linéaire ccp` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/pb arithmétique` | `move` | `02_Academic/X/Prep_History/Pbs/pb arithmétique` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/polynomes` | `move` | `02_Academic/X/Prep_History/Pbs/polynomes` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/suites et series pb` | `move` | `02_Academic/X/Prep_History/Pbs/suites et series pb` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/Prépas/Pbs/théorie ensembliste` | `move` | `02_Academic/X/Prep_History/Pbs/théorie ensembliste` | prep history standardized |
| `$HOME/Gdrive_X/Academic/X/TC` | `move` | `02_Academic/X/Common_Trunk_TC` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/.virtual_documents` | `move` | `02_Academic/X/Common_Trunk_TC/.virtual_documents` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/.virtual_documents/APM_3X062_EP - Python` | `move` | `02_Academic/X/Common_Trunk_TC/.virtual_documents/APM_3X062_EP - Python` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/hooks` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/hooks` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/info` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/info` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/logs/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/00` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/00` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/02` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/02` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/04` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/04` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/06` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/06` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/09` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/09` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/0a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/0a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/0f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/0f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/1e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/1e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/21` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/21` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/22` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/22` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2d` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2d` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/2e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/30` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/30` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/32` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/32` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/34` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/34` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/36` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/36` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/37` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/37` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/3a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/3a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/3f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/3f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/41` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/41` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/42` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/42` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/48` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/48` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/4b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/4b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/4c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/4c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/4d` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/4d` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/54` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/54` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/55` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/55` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/5b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/5b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/5f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/5f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/60` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/60` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/6a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/6a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/70` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/70` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/75` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/75` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/76` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/76` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/7e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/7e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/80` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/80` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/81` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/81` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/82` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/82` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/84` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/84` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/87` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/87` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/90` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/90` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/9d` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/9d` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/9e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/9e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/9f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/9f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/a2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/a2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/a5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/a5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/a8` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/a8` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/aa` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/aa` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ac` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ac` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/b8` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/b8` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/c3` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/c3` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ca` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ca` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/d0` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/d0` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/d2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/d2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/d3` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/d3` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/de` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/de` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/e2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/e2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ec` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ec` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ed` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/ed` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/f4` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/f4` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/fb` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/fb` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/fc` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/fc` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/fe` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/objects/fe` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs/remotes/origin` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Academic/X/TC/APM-3X061-EP - Aléatoire/.git/refs/remotes/origin` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 1` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/.ipynb_checkpoints` | `quarantine` | `99_System_Quarantine/Notebook_Residue/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/.ipynb_checkpoints` | notebook checkpoints are runtime residue, not curated storage |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/.virtual_documents` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 1/.virtual_documents` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/img` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 1/img` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/img/__MACOSX` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 1/img/__MACOSX` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/img/__MACOSX/img` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 1/img/__MACOSX/img` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 1/img_APM-3X016_Cours1` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 1/img_APM-3X016_Cours1` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 2` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 2` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 3 - 2 mai 2025 - Supports à télécharger-20250504` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 3 - 2 mai 2025 - Supports à télécharger-20250504` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 4 - 9 mai 2025 - Supports à télécharger-20250513` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 4 - 9 mai 2025 - Supports à télécharger-20250513` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 8 - 6 juin 2025 - Supports à télécharger-20250610` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 8 - 6 juin 2025 - Supports à télécharger-20250610` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM-3X061-EP - Aléatoire/Leçon 9 - 11  juin 2025 - Supports à télécharger-20250617` | `move` | `02_Academic/X/Common_Trunk_TC/APM-3X061-EP - Aléatoire/Leçon 9 - 11  juin 2025 - Supports à télécharger-20250617` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM_3X062_EP - Python` | `move` | `02_Academic/X/Common_Trunk_TC/APM_3X062_EP - Python` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM_3X062_EP - Python/.ipynb_checkpoints` | `quarantine` | `99_System_Quarantine/Notebook_Residue/Academic/X/TC/APM_3X062_EP - Python/.ipynb_checkpoints` | notebook checkpoints are runtime residue, not curated storage |
| `$HOME/Gdrive_X/Academic/X/TC/APM_3X062_EP - Python/.virtual_documents` | `move` | `02_Academic/X/Common_Trunk_TC/APM_3X062_EP - Python/.virtual_documents` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/APM_3X062_EP - Python/TP` | `move` | `02_Academic/X/Common_Trunk_TC/APM_3X062_EP - Python/TP` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Anglais` | `move` | `02_Academic/X/Common_Trunk_TC/Anglais` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Economie` | `move` | `02_Academic/X/Common_Trunk_TC/Economie` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Intro Analyse réelle` | `move` | `02_Academic/X/Common_Trunk_TC/Intro Analyse réelle` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Java` | `move` | `02_Academic/X/Common_Trunk_TC/Java` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Maths appliquées` | `move` | `02_Academic/X/Common_Trunk_TC/Maths appliquées` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Physique quantique` | `move` | `02_Academic/X/Common_Trunk_TC/Physique quantique` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Physique quantique/PCs_DM` | `move` | `02_Academic/X/Common_Trunk_TC/Physique quantique/PCs_DM` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/TC/Équilibres mondiaux et enjeux de la défense` | `move` | `02_Academic/X/Common_Trunk_TC/Équilibres mondiaux et enjeux de la défense` | TC branch standardized |
| `$HOME/Gdrive_X/Academic/X/Templates` | `move` | `02_Academic/X/Templates` | templates centralized |
| `$HOME/Gdrive_X/Academic/X/Templates/Modèle Bureautique` | `move` | `02_Academic/X/Templates/Modèle Bureautique` | templates centralized |
| `$HOME/Gdrive_X/Academic/X/Templates/Modèle Bureautique/Modèle Présentation` | `move` | `02_Academic/X/Templates/Modèle Bureautique/Modèle Présentation` | templates centralized |
| `$HOME/Gdrive_X/Academic/X/Templates/Modèle Bureautique/Modèle_Rapports` | `move` | `02_Academic/X/Templates/Modèle Bureautique/Modèle_Rapports` | templates centralized |
| `$HOME/Gdrive_X/Google AI Studio` | `move` | `90_Inbox_Capture/Google_AI_Studio_Dump` | unsorted dump moved to explicit inbox |
| `$HOME/Gdrive_X/Homelab` | `move` | `04_Labs_Projects/Homelab/Backups/Standalone_Homelab_Root` | merge duplicate homelab-backup root under labs/projects |
| `$HOME/Gdrive_X/Homelab/Backups` | `move` | `04_Labs_Projects/Homelab/Backups/Standalone_Homelab_Root/Backups` | merge duplicate homelab-backup root under labs/projects |
| `$HOME/Gdrive_X/Homelab/Backups/Docker_Host` | `move` | `04_Labs_Projects/Homelab/Backups/Standalone_Homelab_Root/Backups/Docker_Host` | merge duplicate homelab-backup root under labs/projects |
| `$HOME/Gdrive_X/Identity` | `rename` | `01_Identity_Admin` | root renamed and standardized |
| `$HOME/Gdrive_X/Identity/Admin` | `move` | `01_Identity_Admin/Admin` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Banking` | `move` | `01_Identity_Admin/Admin/Banking` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Banking/RIB` | `move` | `01_Identity_Admin/Admin/Banking/RIB` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Banking/UBA` | `move` | `01_Identity_Admin/Admin/Banking/UBA` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Cards` | `move` | `01_Identity_Admin/Admin/Cards` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General` | `move` | `01_Identity_Admin/Admin/General` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Autres` | `move` | `01_Identity_Admin/Admin/General/Autres` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Autres/Actes_Naissance` | `move` | `01_Identity_Admin/Admin/General/Autres/Actes_Naissance` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Autres/Certificats_Scolarité` | `move` | `01_Identity_Admin/Admin/General/Autres/Certificats_Scolarité` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Certifications` | `move` | `01_Identity_Admin/Admin/General/Certifications` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Factures&Contrats` | `move` | `01_Identity_Admin/Admin/General/Factures&Contrats` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Factures&Contrats/Laptop_Dell_Inspiron` | `move` | `01_Identity_Admin/Admin/General/Factures&Contrats/Laptop_Dell_Inspiron` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Factures&Contrats/Lebara` | `move` | `01_Identity_Admin/Admin/General/Factures&Contrats/Lebara` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Factures&Contrats/Velo_E4600` | `move` | `01_Identity_Admin/Admin/General/Factures&Contrats/Velo_E4600` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Illustrations` | `move` | `01_Identity_Admin/Admin/General/Illustrations` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Oracle cloud` | `move` | `01_Identity_Admin/Admin/General/Oracle cloud` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr/CVEC` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr/CVEC` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr/Impots` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr/Impots` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr/Mobilité` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr/Mobilité` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr/RC_HEYME_2024-2025` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr/RC_HEYME_2024-2025` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr/Titre séjour` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr/Titre séjour` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Procédures_Fr/Titre séjour/Timbre 08-25 - Titre Sejour` | `move` | `01_Identity_Admin/Admin/General/Procédures_Fr/Titre séjour/Timbre 08-25 - Titre Sejour` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Reading` | `move` | `01_Identity_Admin/Admin/General/Reading` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/General/Reading/AI` | `move` | `01_Identity_Admin/Admin/General/Reading/AI` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Invoices` | `move` | `01_Identity_Admin/Admin/Invoices` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Invoices/Laptop_Dell_Inspiron` | `move` | `01_Identity_Admin/Admin/Invoices/Laptop_Dell_Inspiron` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Invoices/Lebara` | `move` | `01_Identity_Admin/Admin/Invoices/Lebara` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Invoices/Velo_E4600` | `move` | `01_Identity_Admin/Admin/Invoices/Velo_E4600` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Medical` | `move` | `01_Identity_Admin/Admin/Medical` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Medical/Assurance_Maladie` | `move` | `01_Identity_Admin/Admin/Medical/Assurance_Maladie` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Medical/Dentition` | `move` | `01_Identity_Admin/Admin/Medical/Dentition` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Medical/GHNE` | `move` | `01_Identity_Admin/Admin/Medical/GHNE` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Navigo` | `move` | `01_Identity_Admin/Admin/Navigo` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures` | `move` | `01_Identity_Admin/Admin/Procedures` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/BoursoBank` | `move` | `01_Identity_Admin/Admin/Procedures/BoursoBank` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/CVEC` | `move` | `01_Identity_Admin/Admin/Procedures/CVEC` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/CVEC/2024` | `move` | `01_Identity_Admin/Admin/Procedures/CVEC/2024` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/CVEC/2025` | `move` | `01_Identity_Admin/Admin/Procedures/CVEC/2025` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/Impots` | `move` | `01_Identity_Admin/Admin/Procedures/Impots` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/Mobilité` | `move` | `01_Identity_Admin/Admin/Procedures/Mobilité` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/RC` | `move` | `01_Identity_Admin/Admin/Procedures/RC` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/RC/RC_HEYME_2024-2025` | `move` | `01_Identity_Admin/Admin/Procedures/RC/RC_HEYME_2024-2025` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/Titre séjour` | `move` | `01_Identity_Admin/Admin/Procedures/Titre séjour` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Admin/Procedures/Titre séjour/Timbre 08-25 - Titre Sejour` | `move` | `01_Identity_Admin/Admin/Procedures/Titre séjour/Timbre 08-25 - Titre Sejour` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Legal` | `move` | `01_Identity_Admin/Legal` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Identity/Professional` | `move` | `03_Professional/` | professional material split out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF` | `move` | `03_Professional/CV_ATF` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.agent` | `move` | `03_Professional/CV_ATF/.agent` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/gk` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/gk` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/hooks` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/hooks` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/info` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/info` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/logs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/logs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/logs/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/logs/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/logs/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/logs/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/logs/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/logs/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/logs/refs/remotes/github` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/logs/refs/remotes/github` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/logs/refs/remotes/gitlab` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/logs/refs/remotes/gitlab` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/02` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/02` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/04` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/04` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/06` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/06` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/07` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/07` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/09` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/09` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/0e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/0e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/0f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/0f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/10` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/10` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/1b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/1b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/1c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/1c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/1d` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/1d` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/1e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/1e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/22` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/22` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/29` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/29` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/2a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/2a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/2c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/2c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/37` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/37` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/3f` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/3f` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/40` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/40` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/41` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/41` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/42` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/42` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/44` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/44` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/46` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/46` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/47` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/47` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/48` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/48` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/4b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/4b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/50` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/50` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/52` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/52` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/53` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/53` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/56` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/56` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/57` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/57` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/59` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/59` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/5b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/5b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/5d` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/5d` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/5e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/5e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/61` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/61` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/64` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/64` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/66` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/66` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/68` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/68` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/69` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/69` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/6c` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/6c` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/6e` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/6e` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/70` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/70` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/73` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/73` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/74` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/74` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/76` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/76` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/77` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/77` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/7a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/7a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/7b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/7b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/80` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/80` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/81` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/81` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/83` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/83` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/84` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/84` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/86` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/86` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/8a` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/8a` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/8b` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/8b` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/91` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/91` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/95` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/95` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/97` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/97` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/98` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/98` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/a2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/a2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/a3` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/a3` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/a5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/a5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/a7` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/a7` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/aa` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/aa` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/ae` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/ae` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/af` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/af` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/b1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/b1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/b5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/b5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/c1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/c1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/c2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/c2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/c5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/c5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/ca` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/ca` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/ce` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/ce` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/cf` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/cf` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/d5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/d5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/d7` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/d7` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/d8` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/d8` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/dd` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/dd` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/e1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/e1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/e2` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/e2` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/e4` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/e4` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/ef` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/ef` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/f1` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/f1` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/f5` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/f5` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/f6` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/f6` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/f9` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/f9` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/fc` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/fc` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/objects/fd` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/objects/fd` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/refs` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/refs` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/refs/heads` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/refs/heads` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/refs/remotes` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/refs/remotes` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/refs/remotes/github` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/refs/remotes/github` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/refs/remotes/gitlab` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/refs/remotes/gitlab` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.git/refs/tags` | `quarantine` | `99_System_Quarantine/Repo_Metadata/Identity/Professional/CV_ATF/.git/refs/tags` | git metadata should not remain in curated document navigation |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.github` | `move` | `03_Professional/CV_ATF/.github` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.github/workflows` | `move` | `03_Professional/CV_ATF/.github/workflows` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.vibe` | `move` | `03_Professional/CV_ATF/.vibe` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/.vibe/prompts` | `move` | `03_Professional/CV_ATF/.vibe/prompts` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/CV_ATF/build` | `move` | `03_Professional/CV_ATF/build` | career asset moved out of identity root |
| `$HOME/Gdrive_X/Identity/Professional/Certifications` | `move` | `03_Professional/Certifications` | career certifications centralized under professional root |
| `$HOME/Gdrive_X/Identity/Professional/ToPrint` | `move` | `03_Professional/Print_Assets` | printable career assets moved under professional root |
| `$HOME/Gdrive_X/Identity/Professional/ToPrint/Photos` | `move` | `03_Professional/Print_Assets/Photos` | printable career assets moved under professional root |
| `$HOME/Gdrive_X/Identity/Professional/ToPrint/Photos/IMG_20220618_200125 (2).jpg` | `move` | `03_Professional/Print_Assets/Photos/IMG_20220618_200125 (2).jpg` | printable career assets moved under professional root |
| `$HOME/Gdrive_X/Identity/Professional/ToPrint/Photos/IMG_20220618_200336.jpg` | `move` | `03_Professional/Print_Assets/Photos/IMG_20220618_200336.jpg` | printable career assets moved under professional root |
| `$HOME/Gdrive_X/Identity/Professional/ToPrint/Photos/IMG_20220618_203157.jpg` | `move` | `03_Professional/Print_Assets/Photos/IMG_20220618_203157.jpg` | printable career assets moved under professional root |
| `$HOME/Gdrive_X/Identity/Professional/ToPrint/Photos/IMG_20220618_205134 (2).jpg` | `move` | `03_Professional/Print_Assets/Photos/IMG_20220618_205134 (2).jpg` | printable career assets moved under professional root |
| `$HOME/Gdrive_X/Identity/Vault` | `move` | `01_Identity_Admin/Vault` | identity/admin material kept under official admin root |
| `$HOME/Gdrive_X/Labs` | `rename` | `04_Labs_Projects` | root renamed and standardized |
| `$HOME/Gdrive_X/Labs/AI` | `move` | `04_Labs_Projects/AI` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/AI/Colab` | `move` | `04_Labs_Projects/AI/Colab` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/AI/Colab/Doc` | `move` | `04_Labs_Projects/AI/Colab/Doc` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/AI/Colab/Doc/Doc_V1` | `move` | `04_Labs_Projects/AI/Colab/Doc/Doc_V1` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/AI/Colab/Doc/Doc_V2` | `move` | `04_Labs_Projects/AI/Colab/Doc/Doc_V2` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/AI/Studio` | `move` | `04_Labs_Projects/AI/Studio` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Development` | `move` | `04_Labs_Projects/Development` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Development/Work` | `move` | `04_Labs_Projects/Development/Work` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Development/Work/Colab_Notebooks` | `move` | `04_Labs_Projects/Development/Work/Colab_Notebooks` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Development/Work/Hi-Paris_IPAI_Hackathlon` | `move` | `04_Labs_Projects/Development/Work/Hi-Paris_IPAI_Hackathlon` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Development/Work/Hickathlon25` | `move` | `04_Labs_Projects/Development/Work/Hickathlon25` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Homelab` | `move` | `04_Labs_Projects/Homelab` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Homelab/Backups` | `move` | `04_Labs_Projects/Homelab/Backups` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Homelab/Backups/Docker_Host` | `move` | `04_Labs_Projects/Homelab/Backups/Docker_Host` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Homelab/Backups/Vault` | `move` | `04_Labs_Projects/Homelab/Backups/Vault` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge` | `move` | `04_Labs_Projects/Knowledge_Engineering` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/AI` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/AI` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Beamer LaTeX` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Beamer LaTeX` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Numpy` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Numpy` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/docs-pdf` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/docs-pdf` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_downloads` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_downloads` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_downloads/6dc1f3f4f0e6ca13cb42ddf4d6cbc8af` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_downloads/6dc1f3f4f0e6ca13cb42ddf4d6cbc8af` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_images` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_images` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/c-api` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/c-api` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/distributing` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/distributing` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/distutils` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/distutils` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/extending` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/extending` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/faq` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/faq` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/howto` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/howto` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/install` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/install` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/installing` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/installing` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/library` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/library` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/reference` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/reference` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/tutorial` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/tutorial` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/using` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/using` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/whatsnew` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_sources/whatsnew` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_static` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/_static` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/c-api` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/c-api` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/distributing` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/distributing` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/distutils` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/distutils` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/extending` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/extending` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/faq` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/faq` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/howto` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/howto` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/install` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/install` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/installing` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/installing` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/library` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/library` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/reference` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/reference` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/tutorial` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/tutorial` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/using` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/using` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/Python3.11/python-3.11.8-docs-html/whatsnew` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/Python3.11/python-3.11.8-docs-html/whatsnew` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Docs/mysql` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Docs/mysql` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Fonctionnalités Supplémentaires Virtual Box` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Fonctionnalités Supplémentaires Virtual Box` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Keyboard shortcuts in Windows - Microsoft Support_files` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Keyboard shortcuts in Windows - Microsoft Support_files` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Microsoft Store _ télécharger et installer manuellement un package APPX _ IT-Connect_files` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Microsoft Store _ télécharger et installer manuellement un package APPX _ IT-Connect_files` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Packaging_Python_Projects` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Packaging_Python_Projects` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Tutos` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Tutos` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Tutos/How to Enable Hibernate in Ubuntu 22.04 LTS – Linux Consultant_files` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Tutos/How to Enable Hibernate in Ubuntu 22.04 LTS – Linux Consultant_files` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Tutos/Planifier-la-création-de-points-de-restauration-système-en-utilisant-un-script-VBS` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Tutos/Planifier-la-création-de-points-de-restauration-système-en-utilisant-un-script-VBS` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Knowledge/Informatique/Ubuntu _ désinstaller une application (4 façons) - malekal.com_files` | `move` | `04_Labs_Projects/Knowledge_Engineering/Informatique/Ubuntu _ désinstaller une application (4 façons) - malekal.com_files` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Tools` | `move` | `04_Labs_Projects/Tools_Admin` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Tools/M365` | `move` | `04_Labs_Projects/Tools_Admin/M365` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Tools/M365/Edited PDF` | `move` | `04_Labs_Projects/Tools_Admin/M365/Edited PDF` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Labs/Tools/Oracle` | `move` | `04_Labs_Projects/Tools_Admin/Oracle` | labs content centralized under projects root |
| `$HOME/Gdrive_X/Library` | `rename` | `05_Resources_Knowledge` | root renamed and standardized |
| `$HOME/Gdrive_X/Library/Archive` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/Legacy_Misc` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/Legacy_Misc` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/Legacy_Misc/tmp` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/Legacy_Misc/tmp` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/Legacy_Misc/tmp/X.png` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/Legacy_Misc/tmp/X.png` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/A maman Hortense - Temoignage - KAMDEM Ivann.docx` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/A maman Hortense - Temoignage - KAMDEM Ivann.docx` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/ACTE_DECES_PERE_KAMDEM_GUELA.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/ACTE_DECES_PERE_KAMDEM_GUELA.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Album Photo de ma Ière Communion & du Baptême de Lyse.pptx` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Album Photo de ma Ière Communion & du Baptême de Lyse.pptx` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Attestation d'Immatriculation KAMDEM Ivann.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Attestation d'Immatriculation KAMDEM Ivann.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Carte Souscription MC2.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Carte Souscription MC2.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Caution logement X .pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Caution logement X .pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Certificat_Vente_Terrain_Maman.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Certificat_Vente_Terrain_Maman.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/En_CV_KAMDEM_POUOKAM_Ivann_Harold.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/En_CV_KAMDEM_POUOKAM_Ivann_Harold.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Kamdem Signification Du Prénom_ Que Signifie Kamdem Nom.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Kamdem Signification Du Prénom_ Que Signifie Kamdem Nom.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Ma Carte de Visite.pub` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Ma Carte de Visite.pub` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Notes Persos.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Notes Persos.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/PHOTO_KAMDEM_POUOKAM_IVANN_HAROLD.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/PHOTO_KAMDEM_POUOKAM_IVANN_HAROLD.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Passeport_KAMDEM_Ivann.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Passeport_KAMDEM_Ivann.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Pièces ESF secondaire.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Pièces ESF secondaire.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Prive.zip` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Prive.zip` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Projects_Portfolio.txt` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Projects_Portfolio.txt` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Prénom Masculin Harold_Signification du prénom Masculin Harold.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Prénom Masculin Harold_Signification du prénom Masculin Harold.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Prénom Masculin Ivann_Signification du prénom Masculin Ivann.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Prénom Masculin Ivann_Signification du prénom Masculin Ivann.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/TITRE FONCIER   N  21305.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/TITRE FONCIER   N  21305.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/Xiaomi Redmi Note 8 Pro _ prix, fiche technique, test et actualité - Smartphones - Frandroid.mhtml` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/Xiaomi Redmi Note 8 Pro _ prix, fiche technique, test et actualité - Smartphones - Frandroid.mhtml` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Archive/OneDrive_Documents_Legacy/e-photo KAMDEM Ivann.pdf` | `move` | `05_Resources_Knowledge/Legacy_Document_Archive/OneDrive_Documents_Legacy/e-photo KAMDEM Ivann.pdf` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books` | `move` | `05_Resources_Knowledge/Books` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books/Calibre` | `move` | `05_Resources_Knowledge/Books/Calibre` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books/Calibre/.calnotes` | `move` | `05_Resources_Knowledge/Books/Calibre/.calnotes` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books/Calibre/David Louapre` | `move` | `05_Resources_Knowledge/Books/Calibre/David Louapre` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books/Calibre/David Louapre/Mais qui a attrape le bison de Higgs _ (2)` | `move` | `05_Resources_Knowledge/Books/Calibre/David Louapre/Mais qui a attrape le bison de Higgs _ (2)` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books/Calibre/John Schember` | `move` | `05_Resources_Knowledge/Books/Calibre/John Schember` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Books/Calibre/John Schember/Quick Start Guide (1)` | `move` | `05_Resources_Knowledge/Books/Calibre/John Schember/Quick Start Guide (1)` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Drive_License` | `move` | `05_Resources_Knowledge/Administrative_Reference/Drive_License` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Drive_License/New` | `move` | `05_Resources_Knowledge/Administrative_Reference/Drive_License/New` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Drive_License/⁨K𝛑X_Notes` | `move` | `05_Resources_Knowledge/Administrative_Reference/Drive_License/⁨K𝛑X_Notes` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes` | `move` | `05_Resources_Knowledge/Notes` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/Knowledge_Base` | `move` | `05_Resources_Knowledge/Notes/Knowledge_Base` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/Knowledge_Base/How to Install and Make Nemo the Default File Manager in Ubuntu_files` | `move` | `05_Resources_Knowledge/Notes/Knowledge_Base/How to Install and Make Nemo the Default File Manager in Ubuntu_files` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/OneNote` | `move` | `05_Resources_Knowledge/Notes/OneNote` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Apprentis_Auteuil_Marcoussis` | `move` | `05_Resources_Knowledge/Notes/OneNote/Apprentis_Auteuil_Marcoussis` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Apprentis_Auteuil_Marcoussis/OneNote_RecycleBin` | `quarantine` | `99_System_Quarantine/Sync_Residue/Library/Notes/OneNote/Apprentis_Auteuil_Marcoussis/OneNote_RecycleBin` | recycle-bin sync residue should leave active knowledge navigation |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Maths` | `move` | `05_Resources_Knowledge/Notes/OneNote/Maths` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Maths/OneNote_RecycleBin` | `quarantine` | `99_System_Quarantine/Sync_Residue/Library/Notes/OneNote/Maths/OneNote_RecycleBin` | recycle-bin sync residue should leave active knowledge navigation |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Musique` | `move` | `05_Resources_Knowledge/Notes/OneNote/Musique` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Physique` | `move` | `05_Resources_Knowledge/Notes/OneNote/Physique` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Notes/OneNote/Test` | `move` | `05_Resources_Knowledge/Notes/OneNote/Test` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Piano` | `move` | `05_Resources_Knowledge/Arts/Piano` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Reading` | `move` | `05_Resources_Knowledge/Reading` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Reading/AI` | `move` | `05_Resources_Knowledge/Reading/AI` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Science` | `move` | `05_Resources_Knowledge/Science` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Spirituality` | `move` | `05_Resources_Knowledge/Spirituality` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Spirituality/Pr_Moukouop` | `move` | `05_Resources_Knowledge/Spirituality/Pr_Moukouop` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Library/Travel` | `move` | `05_Resources_Knowledge/Travel` | knowledge/reference material centralized under resources root |
| `$HOME/Gdrive_X/Media` | `split` | `06_Media_Reference + 95_Archive/Personal_Media_Pending_Transfer` | media root must be split between mission-relevant reference media and personal archive |
| `$HOME/Gdrive_X/Media/Audio` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/a` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/a` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/b` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/b` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/c` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/c` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/d` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/d` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/e` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/e` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/f` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/f` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/g` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/g` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/h` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/h` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/i` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/i` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/j` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/j` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/k` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/k` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Audio/Ringtones/gamefree/jly3/l` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Audio/Ringtones/gamefree/jly3/l` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Illustrations` | `move` | `06_Media_Reference/Illustrations` | illustrations are useful reference assets |
| `$HOME/Gdrive_X/Media/Illustrations/Jupyter Notebook shortcuts.png` | `move` | `06_Media_Reference/Illustrations/Jupyter Notebook shortcuts.png` | illustrations are useful reference assets |
| `$HOME/Gdrive_X/Media/Illustrations/Scipy squeleton.png` | `move` | `06_Media_Reference/Illustrations/Scipy squeleton.png` | illustrations are useful reference assets |
| `$HOME/Gdrive_X/Media/Photos` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres/Art` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres/Art` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres/Fonds_d'Ecran` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres/Fonds_d'Ecran` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres/Génies & Talents` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres/Génies & Talents` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres/Logos` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres/Logos` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres/Musée Baham` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres/Musée Baham` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Autres/Souvenirs Labo TC LYBIBAF 20` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Autres/Souvenirs Labo TC LYBIBAF 20` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Extraits Bibliques` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Extraits Bibliques` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Informations` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Informations` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync` | `move` | `95_Archive/Personal_Media_Pending_Transfer/OneDrive_Sync` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/AIMS` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Abonnements+Contrats` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Acte_Naissance_KAMDEM_POUOKAM_Ivann_Harold.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Appareils` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Appareils/Velo_E4600` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Bg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Bordereau de dépôt UBA ENSPY 2021.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/CNI__KAMDEM_POUOKAM_IVANN_HAROLD.png` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Copie certifiée de mon acte de naissance Août 2021.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/ENSPY` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Environnement` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Excellence` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Excellence/Excellence_Papeterie_Nono` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Excellence/Fondation_MANFOUO` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Excellence/ZTF_Awards` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Goku` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Havre` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Identité` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Info Johan.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Info Ton Gabi.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Logos` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Matricule ENSPY.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/PB_Depart.zip` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/PassePort_KAMDEM_Ivann.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Photos` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Profil-KpihX.jpg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Reçus` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Résultats ENSPD 2021.png` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Signature_KAMDEM_Ivann` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Sims` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/Importants/Vélo` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X` | `merge-move` | `06_Media_Reference/X_Events` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Arrivee_Gaby` | `merge-move` | `06_Media_Reference/X_Events/Arrivee_Gaby` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Cérémonie Bourses` | `merge-move` | `06_Media_Reference/X_Events/Cérémonie Bourses` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Départ_Douala` | `merge-move` | `06_Media_Reference/X_Events/Départ_Douala` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Départ_Kmer` | `merge-move` | `06_Media_Reference/X_Events/Départ_Kmer` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Inkhôrpo` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Inkhôrpo/Chic_A_la_Rouge` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/Chic_A_la_Rouge` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Inkhôrpo/Section_33` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/Section_33` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Inkhôrpo/X24_Cam` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/X24_Cam` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Inkhôrpo/X24_Cam/1er_2025` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/X24_Cam/1er_2025` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Inkhôrpo/X24_Cam/Vsite_Paris_Octobre` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/X24_Cam/Vsite_Paris_Octobre` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Journee_Science_X24` | `merge-move` | `06_Media_Reference/X_Events/Journee_Science_X24` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Mariage_Frère_Nelson` | `merge-move` | `06_Media_Reference/X_Events/Mariage_Frère_Nelson` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/1ere_Neige` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/1ere_Neige` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/21_Anniversaire` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/21_Anniversaire` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Olympiades externes` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Olympiades externes/Chasse au trésor` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes/Chasse au trésor` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Olympiades externes/Course dans le sac` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes/Course dans le sac` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Olympiades externes/Course du roi` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes/Course du roi` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Olympiades externes/Parcours` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes/Parcours` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Olympiades externes/Volley assis` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes/Volley assis` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Oscars` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Oscars` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Outdoors Activities Internal` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Outdoors Activities Internal` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Pélérinage_Lourdes` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Pélérinage_Lourdes` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Stage_Marcoussis/Soiree_Reussite` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Soiree_Reussite` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/TC` | `merge-move` | `06_Media_Reference/X_Events/TC` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Visite Paradox Museum` | `merge-move` | `06_Media_Reference/X_Events/Visite Paradox Museum` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Visite_Chatellrault` | `merge-move` | `06_Media_Reference/X_Events/Visite_Chatellrault` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Visite_Paris_X24_Octobre` | `merge-move` | `06_Media_Reference/X_Events/Visite_Paris_X24_Octobre` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/X` | `merge-move` | `06_Media_Reference/X_Events/X` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/X-Y` | `merge-move` | `06_Media_Reference/X_Events/X-Y` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/X24_Cam` | `merge-move` | `06_Media_Reference/X_Events/X24_Cam` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/X24_Cam/1er_2025` | `merge-move` | `06_Media_Reference/X_Events/X24_Cam/1er_2025` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/X24_Cam/Vsite_Paris_Octobre` | `merge-move` | `06_Media_Reference/X_Events/X24_Cam/Vsite_Paris_Octobre` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/OneDrive_Sync/X/Xois_24_ENSPY.jpg` | `merge-move` | `06_Media_Reference/X_Events/Xois_24_ENSPY.jpg` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Pbs` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Media/Photos/Pbs` | non-mission media archived out of active navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Anniversaire_50_ans_Maman` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Anniversaire_50_ans_Maman` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Autres` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Autres` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Concession` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Concession` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Configurations` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Configurations` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Deuil Papa Henri` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Deuil Papa Henri` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Diplômes & Bulletins` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Diplômes & Bulletins` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Ecole de Maths 2023` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Ecole de Maths 2023` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/AIMS` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Abonnements+Contrats` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Appareils` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Appareils/Velo_E4600` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Bg` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/ENSPY` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Environnement` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Excellence` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Excellence/Excellence_Papeterie_Nono` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Excellence/Fondation_MANFOUO` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Excellence/ZTF_Awards` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Goku` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Havre` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Identité` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Logos` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Photos` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Reçus` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Signature_KAMDEM_Ivann` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/Importants/Sims` | `split` | `01_Identity_Admin/Admin/Scans_Images + 06_Media_Reference/Official_Photos + 95_Archive/Personal_Media_Pending_Transfer` | important images mix official scans, profile assets, and personal images; manual semantic split required |
| `$HOME/Gdrive_X/Media/Photos/Persos/JIM LYBIBAF 2021` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/JIM LYBIBAF 2021` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Ma Confirmation` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Ma Confirmation` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Maman Après son Accident` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Maman Après son Accident` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Maman Jeune & Son Entourage` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Maman Jeune & Son Entourage` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Maman et son Entourage` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Maman et son Entourage` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Mariage Ton Martial & Ta Mirianne` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Mariage Ton Martial & Ta Mirianne` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Moi Bébé et Maman Enceinte de Moi` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Moi Bébé et Maman Enceinte de Moi` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Moi JESAM` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Moi JESAM` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Moi Prime Major Regional CEP 2014` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Moi Prime Major Regional CEP 2014` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Moi, Patrick, Ange, Johan, Patou, Gaby, Davy, Steeve à la Maternelle et au Primaire` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Moi, Patrick, Ange, Johan, Patou, Gaby, Davy, Steeve à la Maternelle et au Primaire` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Mon Anniversaire 1` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Mon Anniversaire 1` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Mon Anniversaire 2` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Mon Anniversaire 2` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Mon Baptême` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Mon Baptême` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Papa` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Papa` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Papa/Deuil Papa` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Papa/Deuil Papa` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Papa vers ma Naissance` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Papa vers ma Naissance` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos Baptême de Maman Justine` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos Baptême de Maman Justine` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos JESAM 2021` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos JESAM 2021` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos de ma Ière Communion & du Baptême de Lyse` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos de ma Ière Communion & du Baptême de Lyse` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos de mon 18è Anniversaire` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos de mon 18è Anniversaire` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos du Baptême et de la Ière Communion de Coco` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos du Baptême et de la Ière Communion de Coco` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos du Deuil de Grand-mère Suzanne` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos du Deuil de Grand-mère Suzanne` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Photos famille Papa` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Photos famille Papa` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Sacrements de Maman` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Sacrements de Maman` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Soutenance Maman` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Soutenance Maman` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Vsite_Paris_X24-237` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Vsite_Paris_X24-237` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/Weekend_14-15_Avec_Didi` | `move` | `95_Archive/Personal_Media_Pending_Transfer/Persos/Weekend_14-15_Avec_Didi` | personal/onedrive media should leave active professional drive navigation |
| `$HOME/Gdrive_X/Media/Photos/Persos/X` | `merge-move` | `06_Media_Reference/X_Events` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Arrivee_Gaby` | `merge-move` | `06_Media_Reference/X_Events/Arrivee_Gaby` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Départ_Douala` | `merge-move` | `06_Media_Reference/X_Events/Départ_Douala` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Départ_Kmer` | `merge-move` | `06_Media_Reference/X_Events/Départ_Kmer` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Inkhôrpo` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Inkhôrpo/Chic_A_la_Rouge` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/Chic_A_la_Rouge` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Inkhôrpo/Section_33` | `merge-move` | `06_Media_Reference/X_Events/Inkhôrpo/Section_33` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Journee_Science_X24` | `merge-move` | `06_Media_Reference/X_Events/Journee_Science_X24` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Mariage_Frère_Nelson` | `merge-move` | `06_Media_Reference/X_Events/Mariage_Frère_Nelson` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/1ere_Neige` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/1ere_Neige` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/21_Anniversaire` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/21_Anniversaire` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/Olympiades externes` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Olympiades externes` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/Oscars` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Oscars` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/Outdoors Activities Internal` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Outdoors Activities Internal` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/Pélérinage_Lourdes` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Pélérinage_Lourdes` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Stage_Marcoussis/Soiree_Reussite` | `merge-move` | `06_Media_Reference/X_Events/Stage_Marcoussis/Soiree_Reussite` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/TC` | `merge-move` | `06_Media_Reference/X_Events/TC` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Visite Paradox Museum` | `merge-move` | `06_Media_Reference/X_Events/Visite Paradox Museum` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Visite_Chatellrault` | `merge-move` | `06_Media_Reference/X_Events/Visite_Chatellrault` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/Visite_Paris_X24_Octobre` | `merge-move` | `06_Media_Reference/X_Events/Visite_Paris_X24_Octobre` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/X` | `merge-move` | `06_Media_Reference/X_Events/X` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/X-Y` | `merge-move` | `06_Media_Reference/X_Events/X-Y` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/X24_Cam` | `merge-move` | `06_Media_Reference/X_Events/X24_Cam` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Persos/X/X24_Cam/1er_2025` | `merge-move` | `06_Media_Reference/X_Events/X24_Cam/1er_2025` | X event media duplicated across mirrored trees; merge into one canonical event root |
| `$HOME/Gdrive_X/Media/Photos/Produits` | `move` | `06_Media_Reference/Product_Reference` | product reference visuals kept in active mission scope |
| `$HOME/Gdrive_X/Old` | `move` | `95_Archive/Legacy_Pre_Reorg/Old` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc/Documents` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc/Documents` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/.nomedia` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/.nomedia` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/dataset` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/dataset` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/dataset/distortion.txt` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/dataset/distortion.txt` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/dataset/state.txt` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Library/Archive/Legacy_Misc/Documents/3D Live Scanner/dataset/state.txt` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Media` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Media` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Media/Photos` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Media/Photos` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Media/Photos/Persos` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Media/Photos/Persos` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Media/Photos/Persos/X` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Media/Photos/Persos/X` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Media/Photos/Persos/X/X24_Cam` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Media/Photos/Persos/X/X24_Cam` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/Old/Media/Photos/Persos/X/X24_Cam/Vsite_Paris_Octobre` | `move` | `95_Archive/Legacy_Pre_Reorg/Old/Media/Photos/Persos/X/X24_Cam/Vsite_Paris_Octobre` | legacy residue archived outside active navigation |
| `$HOME/Gdrive_X/tmp` | `move` | `99_System_Quarantine/Sync_Residue/tmp` | transient residue must leave active root |

## Explicit Creations Required

- create `01_Identity_Admin/`
- create `02_Academic/`
- create `03_Professional/`
- create `04_Labs_Projects/`
- create `05_Resources_Knowledge/`
- create `06_Media_Reference/`
- create `90_Inbox_Capture/`
- create `95_Archive/`
- create `99_System_Quarantine/`

## Explicit Removals From Active Root After Migration

- remove active-root visibility of `Academic/` once its content is migrated or quarantined
- remove active-root visibility of `Google AI Studio/` once its content is migrated or quarantined
- remove active-root visibility of `Homelab/` once its content is migrated or quarantined
- remove active-root visibility of `Identity/` once its content is migrated or quarantined
- remove active-root visibility of `Labs/` once its content is migrated or quarantined
- remove active-root visibility of `Library/` once its content is migrated or quarantined
- remove active-root visibility of `Media/` once its content is migrated or quarantined
- remove active-root visibility of `Old/` once its content is migrated or quarantined
- remove active-root visibility of `tmp/` once its content is migrated or quarantined
- remove active-root visibility of `.Trash-1000/` once its content is migrated or quarantined

## Highest-Risk Areas For Execution Later

- `Media/Photos/Persos/X` vs `Media/Photos/OneDrive_Sync/X`: strong overlap; execution must deduplicate rather than copy blindly.
- `Media/Photos/Persos/Importants` vs `Media/Photos/OneDrive_Sync/Importants`: mixed official, profile, and personal semantics; requires semantic review.
- `Academic/X/K𝜋X/`: duplicate institutional subtree with mixed admin and coursework meaning; must be flattened carefully.
- `Identity/Professional/CV_ATF/`: contains repository/runtime metadata that may need separation between source repo and document output.
- `Homelab/Backups/` and `Labs/Homelab/Backups/`: both large and semantically overlapping; retention rules must be decided before deletion.
