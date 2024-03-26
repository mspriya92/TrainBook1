---
title: Deployment approval Required for {{ env.ENVIRONMENT }}
labels: deployment-requested
---

Deployment approval requested from {{ payload.sender.login }}.

Comment "Approved" to kick off the deployment.

**=== DON'T CHANGE BELOW LINE**

```json target_payload
{
  "runnumber": {{ env.RUNNUMBER }},
  "environment": "{{ env.ENVIRONMENT }}"
}
```
