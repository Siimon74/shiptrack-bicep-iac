# Time log

Total: about 6.5 hours of production, on 8 November 2026.

| Time | Duration | Activity |
|---|---|---|
| Before | 0.5 h | Read the brief, planned the approach, installed the tools |
| 12:50 – 15:00 | 2 h | Repository setup: GitHub repo, secret scanning, private email, .gitignore (tested), Git identity, first commit. Part of this time was learning Git basics. |
| 15:00 – 15:40 | 0.75 h | Generated the Bicep code, parameter files, app and pipeline with Claude. Committed in four steps. |
| 15:40 – 16:30 | 0.75 h | Deployed dev and the app, confirmed the Key Vault secret works. Reviewed the storage code and the parameter files. |
| 16:30 – 17:30 | 1 h | Deployed test, checked tags and storage settings, fixed the pipeline warning. |
| 17:30 – 18:10 | 0.5 h | Documentation (written with Claude, then simplified and reviewed). |
| 18:10 – 19:00 | 1 h | Extra checks: logs in Log Analytics, deleted and rebuilt dev, diagnosed and fixed the Key Vault access problem after the rebuild. Updated the documentation. |

## Prioritisation

- I focused on the minimum requirements. No stretch goals.
- I spent more time than planned on setup, because I wanted to understand each Git step.
- With the time left, I chose extra testing (logs, full rebuild) instead of stretch goals. The rebuild found a real problem, which I diagnosed and documented.
- After submitting, I will spend time reviewing all the code in detail to prepare for the interview.
