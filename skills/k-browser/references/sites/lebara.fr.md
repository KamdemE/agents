# lebara.fr (Lebara Mobile France — Account & Self-Care Portal)

**Category:** Mobile / Operator Self-Care. **Account:** `kapoivha@gmail.com` (MSISDN: `0605957785`). **Profile:** `default`.

## Login

- Primary authentication is session-cookie / OTP / password login on `https://www.lebara.fr/fr/mylebara.html`.
- Connected profile `default` holds an active authenticated session for line `0605957785` (`CRM ID: 000000000020122084`).
- Redux store state is exposed globally on `window.store.getState()`, containing live `dashboardData`, `userProducts`, `activityHistory`, and `multiMsisdnDetails`.

## Structure / navigation

- **Dashboard / Account Home:** `https://www.lebara.fr/fr/mylebara.html`
- **Plan Management:** `https://www.lebara.fr/fr/mylebara/plan-management.html`
- **Pass Internet Offers:** `https://www.lebara.fr/fr/pass-internet.html`
- **Recharge / Top-Up:** `https://www.lebara.fr/fr/recharger.html`

### Key Redux State Paths (`window.store.getState()`)
- `dashboardData.dashboardData.plans`: Active plans, renewal dates, effective date, remaining quotas.
- `dashboardData.dashboardData.activityHistory`: Granular logs for `data` (usedData, date), `calls` (target, seconds, date), and `sms` (target, date).
- `user.userProducts`: Registered SIM products (e.g. `Forfait Mensuel 5,99€ 60Go`).
- `user.msisdn`: Linked numbers (e.g. `0605957785`, `0745717350`).

## Known quirks & Selectors

- **Client-Side SPA (Chakra UI)**: DOM structure uses dynamically generated Chakra classes (e.g. `.css-1f42cd9`).
- **DOM Selector Strategy**:
  - `[data-testid="header-profile-icon"]`: Account header icon.
  - `[data-testid="usage-details-seemore-btn"]`: "DÉTAIL" usage history button.
  - `tabs:_r_62_:trigger-tab-item-0`: "Appels" tab button.
  - `tabs:_r_62_:trigger-tab-item-1`: "SMS" tab button.
  - `tabs:_r_62_:trigger-tab-item-2`: "Internet mobile" tab button.
- **Redux Access**: The fastest, most accurate way to extract full consumption stats without scraping fragile DOM tables is reading `window.store.getState().dashboardData.dashboardData.activityHistory`.

## Account & Historical Consumption Analysis (June – Sept 2026)

### Line Identifiers
- **Active MSISDN**: `0605957785` (pSIM, active since 2024-10-04)
- **Secondary MSISDN**: `0745717350` (eSIM, active since 2026-07-01)
- **Active Plan**: Forfait Mensuel 5,99€ / 60 Go (Auto-renewal: Inactive as of Sept 2026 audit)

### Granular Consumption History (Audit Date: Sept 6, 2026)

| Month | Data Consumed | Calls Count / Duration | SMS Sent | Context / Usage Profile |
| :--- | :--- | :--- | :--- | :--- |
| **June 2026** (from Jun 8) | **5.24 GB** (5,367.8 MB) | 64 calls / 16 min 03 sec | 62 SMS | Campus / Early summer period |
| **July 2026** | **7.56 GB** (7,746.5 MB) | 33 calls / 4 min 34 sec | 110 SMS | Peak mobility / Summer travel |
| **August 2026** | **7.64 GB** (7,828.4 MB) | 24 calls / 4 min 44 sec | 99 SMS | Peak mobility / Summer travel |
| **September 2026** (Sept 1–6) | **0.6 MB** (~0.0006 GB) | 2 calls / 0 min 07 sec | 2 SMS | Return to Campus Wi-Fi |
| **Monthly Average** | **~6.81 GB / month** | **40 calls / 8 min 27 sec** | **90 SMS** | — |

### Exit Days Data Consumption Statistics (June 8 – August 31, 2026: Tuesdays, Wednesdays, Thursdays)

- **Total Exit Days Analyzed**: 36 days (12 Tuesdays, 12 Wednesdays, 12 Thursdays).
- **Total Exit Days Volume**: 16.39 GB (16,779.9 MB) across the entire 3-month summer period.

| Day / Category | Days Count | Mean (MB / GB) | Median (MB / GB) | Min (MB / GB) | Max (MB / GB) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mardi (Tuesday)** | 12 days | **483.0 MB** (0.47 GB) | **495.2 MB** (0.48 GB) | 1.7 MB (0.00 GB) | 870.7 MB (0.85 GB) |
| **Mercredi (Wednesday)** | 12 days | **493.7 MB** (0.48 GB) | **512.6 MB** (0.50 GB) | 156.3 MB (0.15 GB) | 787.1 MB (0.77 GB) |
| **Jeudi (Thursday)** | 12 days | **421.6 MB** (0.41 GB) | **477.4 MB** (0.47 GB) | 0.0 MB (0.00 GB) | 856.2 MB (0.84 GB) |
| **COLLECTIVE (Tue+Wed+Thu)** | **36 days** | **466.1 MB** (0.46 GB) | **505.4 MB** (0.49 GB) | **0.0 MB** (0.00 GB) | **870.7 MB** (0.85 GB) |

### Financial Wastage Audit
- On the 60 GB plan, even during maximum usage months (August, 7.64 GB), **52.36 GB (87.3%) remained unused**.
- During campus months (e.g. September), mobile data usage is **near 0 MB** due to campus Wi-Fi.
- On exit days (Tuesdays, Wednesdays, Thursdays), average consumption is remarkably stable at **~466 MB to ~505 MB per exit day**, meaning a 3 GB / 5 GB Pass S/M covers multiple exit weeks.

## Offline USSD & SMS Automation

- **No New SIM Required**: Changing plans or moving to pay-as-you-go credit retains the same physical SIM and phone number (`0605957785`).
- **SIM Longevity**: Disabling plan auto-renewal does **not** cut the SIM card. A SIM card remains active for **6 months of inactivity** (or 90 days per paid top-up). 1 paid SMS or short call every few months keeps it active indefinitely.
- **Offline Pass Activation (GSM SMS/USSD)**:
  - Keep a reserve credit balance (e.g. 5 € or 10 €) on the account balance.
  - To activate a Pass Internet without Wi-Fi or cellular data:
    - **USSD**: Dial `*144#` and select the pass from the menu.
    - **SMS**: Send `WEBXS` (or the pass keyword) to `22241`.
    - **Balance Check**: Dial `*144#` or `*133#`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-06 | [LIVE] | Created lebara.fr.md after live account audit (browser-proxy). Documented Redux state architecture, DOM selectors, 6-month historical activity logs (June–Sept 2026), and offline GSM/USSD workflows. |
