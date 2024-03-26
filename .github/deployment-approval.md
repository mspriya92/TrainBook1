---
title: Deployment approval Required for {{ env.ENVIRONMENT }}
labels: deployment-requested
---

Deployment approval Requested from {{ payload.sender.login }}.
	 
comment "Approved" to kick thye deployment off.
	 
=== DON'T CHANGE BELOW LINE

---json target_payload
{
  "runnumber": {{ env.RUNNUMBER}},
  "environment": "{{ env.ENVIRONMENT}}"
}
---
