---
name: Meeting and notification write contracts
description: Future meeting-state transactions, context moves and sensitive notification authorization
---

Meeting lifecycle changes must serialize current status and attributed history
in one transaction. Meeting action tasks have their own lifecycle; cancellation
or completion must not silently rewrite task state or assignment history.

**Why:** The user requires common executable work rather than a meeting task/
workflow engine. Meeting scheduling, participation, structured minutes and
executable follow-ups are intentionally independent.

**How to apply:** Authorize the actual actor and retain cancellation/approval
evidence. Validate task classification and optional project/customer/contact/
file alignment both when linking and when moving either endpoint. Explicitly
decide task side effects before implementing any meeting automation.

Sensitive notification content needs authorization when materialized AND when
read or dispatched after later permission/ownership changes.

**Why:** Copied titles/messages persist independently of their source. A
recipient can own a notification row yet no longer have access to the business
record it describes; generic references are not foreign keys or permission proof.

**How to apply:** Whitelist entity resolution, check recipient ownership and
current source access, and handle unresolved/deleted/restricted sources without
leaking their stored text. Preferences do not override source authorization.
New meeting attachment/task links likewise do not make confidential HR content
safe for ordinary meeting or external-contact audiences.

Retry attempts should retain earlier delivery failures, and successful transport
delivery must not mark a notification read.

**Why:** The user requests delivery-attempt tracking independently of one-person
notification read state, not a transport-driven acknowledgement system.

**How to apply:** Future workers write a new attributed attempt outcome for a
retry, preserve prior failure evidence, and use an explicitly authorized read
operation for acknowledgement. Define missing-preference defaults in application
policy rather than silently enrolling employees.
