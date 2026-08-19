# 32 — AI (Future)

AI is **not** in V1. Listed here so we keep the data model flexible.

## Possible AI features

### AI Study Planner

> "My DBMS exam is in 7 days and I have completed 50%."

Output: a multi-day study plan with daily hours and topics.

### AI Explanation

> "Explain normalization in simple Bangla."

Output: a paragraph explanation, grounded in the student's own notes.

### AI Quiz

> "Create a quiz from the topics I studied today."

Output: 5–10 multiple choice / short answer questions, generated from
the student's notes + syllabus.

### AI Study Analysis

> "I have an exam in 5 days. What are my biggest weaknesses?"

Output: ranked list with reasoning, citing the source data (topics
marked weak, low focus ratings, missed revisions).

## What AI must NOT do in V1

- Any feature that requires an API key.
- Any feature that needs an internet connection.
- Any feature that the user can't dismiss.

## Data preparation for AI (V1 work)

Even without AI in V1, our data should be **AI-ready**:

- Topics have explicit status (not_started / learning / weak / mastered).
- Sessions have focus rating (1, 3, 5).
- Revisions track confidence per cycle.
- Notes are plain text (or simple markdown) — easy for an LLM to ingest.

This means when we add AI in V2, we won't need to retroactively change
the data model.