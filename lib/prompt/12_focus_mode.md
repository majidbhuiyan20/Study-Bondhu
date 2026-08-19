# 12 — Focus Mode (Study Timer)

The actual study session. Single-purpose, distraction-free screen.

## Inputs

- Subject (required)
- Topic (optional)
- Mode: Focus (25 min), Pomodoro (25/5 cycle), Free (unbounded)
- Duration cap (optional for Free)

## Layout (during session)

```
       42:17

   Round Robin
   Operating System

        🔥

[ Pause ]   [ Finish ]
```

Minimal chrome: only the timer, current topic, mode label, and two
buttons. No bottom nav, no banners, no cards.

## Behavior

- Timer ticks once per second via a `Timer` in `TimerViewModel`.
- Pause stops the clock; Resume continues.
- Finish → session saved → opens rating sheet (see
  `13_session_completion.md`).

## Mode semantics

| Mode     | Behavior                                            |
| -------- | --------------------------------------------------- |
| Focus    | Counts up from 0; soft vibration at 25 min.         |
| Pomodoro | 25 on / 5 off / 25 on / 5 off; ends after 4 cycles. |
| Free     | Pure count-up, no end.                              |

## Files

```
lib/features/study/
├── view_models/study_view_model.dart       # StateNotifier + bootstrap()
├── views/study_view.dart                   # Focus Mode screen
├── widgets/timer_panel.dart                # The card on Home + Study
└── widgets/session_complete_sheet.dart     # Rating bottom sheet
```

## Background safety

If the app is backgrounded mid-session, on resume we ask: "Resume where
you left off or finish?" — default to resume.