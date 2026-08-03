# Alpha — 3-minute judge demo

## Before the session

1. Backend reachable (Render or local with `.env` including JWT secrets).
2. Seed the demo account:

```bash
cd backend && node scripts/seed_demo_user.js
```

3. Open the Flutter app (debug build preferred).
4. Login → **Use demo account** → **Log In**  
   Phone `790000001` / Password `DemoPass123!`

You should land on the **dashboard** with an open cycle (no onboarding).

---

## Script (≈3 minutes)

| Time | Action | What to say |
|------|--------|-------------|
| 0:00 | Home dashboard | “Alpha plans by pay cycle — needs, wants, savings, and safe daily spend in JOD.” |
| 0:40 | Expenses → **Ask Basira Before You Buy** | Enter e.g. headphones / 80 JOD / Want. Submit. “Basira uses cycle context, not a fake delay.” |
| 1:20 | Center nav → **Basira** chat | Ask: “How much can I safely spend this week?” |
| 1:50 | Goals | Open **Demo Laptop** — “Goals use a real ledger, not a progress bar only.” |
| 2:20 | Optional wow | Receipt scan or voice expense if device permissions allow. |
| 2:45 | Challenges (if time) | Show habit challenges tied to the cycle. |

---

## Branding reminder

- **Alpha** = the app / product  
- **Basira** = the advisor (chat + ask-before-you-buy)

---

## Fallback if Basira/n8n is down

Ask-before-you-buy falls back to a labeled **local quick check**. Prefer fixing n8n webhooks before judging; do not hide the fallback.
