# Miss U

An iOS app for couples who are already together. Each of you gets a little character, and yours lives on your partner's home screen.

Texting all day isn't the only way to feel close. Miss U gives you small ways to stay in each other's day without starting a conversation: your partner glances at their home screen and sees your character drinking coffee, studying, or holding a heart because it misses them. They can even restyle your widget from their phone, so you find a pink background with little hearts and a message waiting for you.

## How it works

- **Your character.** Pick a color, a look, a hairstyle, an outfit, a shirt color and an accessory. Characters are drawn from reusable parts, so the same character can sleep, game or hold a coffee without separate art for every combination.
- **Activities.** Tap your character to show what you're up to: sleeping, listening to music, shopping, gaming, studying, working, drinking coffee, watching TV, exercising or missing you. Activities clear on their own (an hour for coffee or missing you, ten for sleeping), so nobody has to keep their status up to date.
- **Headphones.** When headphones connect, your character puts on a pair. When they come off, it goes back to what you were doing before. Miss U only checks whether headphones are connected. It never listens or sees what you play. iOS only lets the app notice while it's open, so it catches up the next time you open it, and your partner sees an "auto" tag on it.
- **The widget.** Small and medium home screen widgets show your partner's character and what they're doing.
- **Restyle each other's widget.** Change your partner's widget background, pattern, character position and message from your phone. Each person can turn that off, restore their own style, or reset the widget at any time, and the app shows who changed it last.
- **One partner.** You connect by username, both people have to accept, and you can only be connected to one person at a time. Disconnecting stops you seeing each other's characters and puts any widget your partner styled back to your own style.

## Run it

You need Xcode 27, Docker and the [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started).

```bash
supabase start
open MissU.xcodeproj
```

Run the MissU scheme on an iPhone simulator. `supabase start` runs the backend locally and applies everything in `supabase/migrations`. Sign-in codes don't go to a real inbox locally. They show up in Mailpit at http://127.0.0.1:54324.

The app talks to the local backend through `Server` in `Shared/SharedStore.swift`. To use it on a real iPhone, link a hosted Supabase project (`supabase link`, then `supabase db push`) and put that project's URL and anon key there.

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). New files in `MissU`, `Shared` or `MissUWidget` show up in Xcode on their own, so you only need `xcodegen generate` after changing `project.yml`.

## How it's built

- **SwiftUI and WidgetKit**, for iOS 18 and up. The app and the widget share the `Shared` folder and an App Group.
- **Characters are pure SwiftUI shapes,** with no image files, so every color works and they stay sharp at any size, including inside widgets.
- **Supabase backend.** Postgres with row level security, so each person can only read their own data and their partner's. Every change goes through a database function that checks the relationship first, so nobody can restyle a widget that isn't their partner's or connect to two people at once.
- **Live updates.** The open app hears about changes through Supabase Realtime and updates within a second or two. The widget refreshes about every 15 minutes, which iOS controls. It reads its data with its own random token, so the widget never holds a login.
- **Sign in with a 6-digit email code.** There are no passwords.

## Good to know

- **What your partner sees:** your username, your character and your current activity. Nothing else.
- **What Miss U never collects:** location, microphone audio, or anything about the music you play.
- **Deleting your account** removes your username, character, activities and widget settings.
