# Alice-in-Goals Wrapper App Plan

## Overview
A wrapper app for the simple-bldg-server that handles user authentication, onboarding, and provides access to the Unity WebGL client.

**Design Theme:** Clean & minimal with building/office/architectural metaphors throughout

## Detailed Steps

- [x] Generate Phoenix app "alice_in_goals" with SQLite
- [x] Add OAuth dependencies (ueberauth, ueberauth_google, dotenvy)
- [x] Create plan.md and start server
- [x] Replace default home page with static design mockup (building theme)
- [x] Configure Ueberauth for Google OAuth
  - Add config to config/runtime.exs
  - Add dotenvy to load .env file
  - Create .env.example with placeholder credentials
- [x] Create Accounts context and User schema
  - Migration: users table with email, name, google_id, goals (array), tools (map), onboarding_completed
  - Schema: AliceInGoals.Accounts.User
  - Functions: find_or_create_from_google/1, mark_onboarding_complete/2, update_goals/2, update_tools/2
- [x] Create AuthController for OAuth flow
  - GET /auth/google - redirect to Google OAuth
  - GET /auth/google/callback - handle OAuth callback
  - DELETE /auth/logout - logout user
  - Store user_id in session
- [x] Create OnboardingLive multi-step wizard
  - Step 1: "Build Your Foundation" - Life Goals
  - Step 2: "Lay the Groundwork" - Tools & Methods (Optional)
  - Step 3: "Move Into Your Office" - Complete
- [ ] Build BldgServerClient module (TODO - can be added when API is ready)
- [x] Create DashboardLive for post-onboarding
  - Unity WebGL placeholder ready
  - Shows user's goals
- [ ] Create SettingsLive for editing profile (TODO - future enhancement)
- [x] Update router with all routes
  - OAuth routes added
  - Root route shows landing page
  - /onboarding route (accessible to all for now)
  - /dashboard route (accessible to all for now)
- [x] Match app.css to building/office theme
- [x] Match root.html.heex to design (forced light theme)
- [x] Match <Layouts.app> to design (removed default header/nav)
- [x] Test and verify all pages load correctly

## Integration Notes
- API Key stored in .env as BLDG_SERVER_API_KEY
- Bldg server URL in .env as BLDG_SERVER_URL
- Provisioning endpoint to be provided by user
- User's Google name used as resident alias on bldg-server
- **Note:** To test OAuth, run: `source .env && mix phx.server`

