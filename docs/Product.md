# Next — Product and UX

Next turns an abstract future into one concrete next step. Its user wants meaningful movement without maintaining a productivity system.

## Core loop

Vision → Next Step → Action → optional Reflection → Next Step. Journey provides evidence of movement without scores or streaks.

## Information architecture

- Welcome → Vision setup → first Step. No duplicated onboarding-complete flag.
- Home: current date, dominant active Step, quieter Vision, Journey link, About.
- Step sheet: read → complete; edit text is secondary.
- The same sheet changes to completion invitation, optional Reflection, and next Step input. No stacked modals.
- Vision sheet: edit one statement, deliberate confirmed deletion.
- Journey: one pushed screen, newest completion first, month groups, optional Reflection text.
- About: one pushed screen from Welcome or Home; short local privacy summary and external contact/policy links.

## Intentional behavior

Vision saves before the first Step. An interruption between them returns to Home with Add Next Step. Completion saves immediately, before the reflection invitation. Closing the app after completion preserves the completed Step; returning Home invites the next Step. Unsaved editor text stays in the current view but does not survive process termination. There is no mandatory reflection recovery prompt.

Editing Vision preserves all history. Completed Steps cannot be edited. Reflection can be added during the completion sequence and is optional. There is no historical deletion interface; deleting Vision deliberately removes the entire Journey.

## Empty and error states

No Vision: onboarding. No active Step: “What’s your next step?” and Add Next Step. Empty Journey: “Your journey starts here.” Save failures stay in the current editor with calm retry guidance. Failure opening the store offers Try Again and never silently recreates/deletes the user's store.

## Scope and simplification review

No backlog, due dates, priorities, tags, folders, projects, calendar, dashboards, metrics, reminders, widget, or settings shell. About exists for concrete support/privacy information. Navigation stays Home-centric; completion uses one modal with one primary action per phase. Supporting guidance remains short, and vague but non-empty input is allowed.

App UI is English. English and Korean App Store descriptions are provided with that limitation clearly stated. Data is local; OS backups are separate from app-managed synchronization.
