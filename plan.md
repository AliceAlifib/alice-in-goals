# Alice-in-Goals Wrapper App Plan

## Overview
A wrapper app for the simple-bldg-server that handles user authentication, onboarding, and provides access to the Unity WebGL client.

**Design Theme:** Clean & minimal with building/office/architectural metaphors throughout

## Detailed Steps

- [x] Generate Phoenix app "alice_in_goals" with SQLite
- [x] Add OAuth dependencies (ueberauth, ueberauth_google)
- [x] Create plan.md and start server
- [ ] Replace default home page with static design mockup (building theme)
- [ ] Configure Ueberauth for Google OAuth
  - Add config to config/config.exs
  - Add runtime config to config/runtime.exs for Google credentials
  - Create .env.example with placeholder credentials
- [ ] Create Accounts context and User schema
  - Migration: users table with email, name, google_id, goals (array), tools (map), onboarding_completed
  - Schema: AliceInGoals.Accounts.User
  - Functions: find_or_create_from_google/1, mark_onboarding_complete/2, update_goals/2, update_tools/2
- [ ] Create AuthController for OAuth flow
  - GET /auth/google - redirect to Google OAuth
  - GET /auth/google/callback - handle OAuth callback
  - DELETE /auth/logout - logout user
  - Store user_id in session
- [ ] Create OnboardingLive multi-step wizard
  - Step 1: "Build Your Foundation" - Life Goals
    - Dynamic list of goal inputs (one-liners)
    - Suggested categories shown as inspiration
    - Required: at least one goal
    - "Add another goal" button
  - Step 2: "Lay the Groundwork" - Tools & Methods (Optional)
    - Categories: Tasks, Decisions, Events, Metrics, Journaling, Projects, Other
    - User specifies actual tool names per category
    - Can skip entirely
  - Step 3: "Move Into Your Office" - Complete
    - Summary with edit links
    - Create resident on bldg-server via API
    - Call provisioning endpoint (to be provided)
    - Redirect to dashboard
- [ ] Build BldgServerClient module
  - Use Req for HTTP requests
  - Functions: create_resident/2, provision_resident/2
  - Handle API key authentication from env
  - Handle errors gracefully
- [ ] Create DashboardLive for post-onboarding
  - Embed Unity WebGL client
  - Show user's goals
  - Link to edit profile/goals
- [ ] Create SettingsLive for editing profile
  - Edit goals
  - Edit tools
  - Same UI as onboarding steps
- [ ] Update router with all routes
  - OAuth routes (/auth/google, /auth/google/callback, /auth/logout)
  - Remove placeholder home route
  - Root route "/" redirects based on auth state:
    - Not logged in → landing page with "Sign in with Google"
    - Logged in but not onboarded → OnboardingLive
    - Logged in and onboarded → DashboardLive
  - /onboarding route (protected)
  - /dashboard route (protected, requires onboarding)
  - /settings route (protected)
- [ ] Match app.css to building/office theme
  - Architectural grid patterns
  - Professional color palette (grays, blues, whites)
  - Custom daisyUI theme config
- [ ] Match root.html.heex to design
  - Force light theme
  - Clean, minimal layout
- [ ] Match <Layouts.app> to design
  - Remove default Phoenix header/nav
  - Add building-themed navigation
- [ ] Visit app and test OAuth flow
- [ ] Reserve 2 steps for debugging

## Integration Notes
- API Key stored in .env as BLDG_SERVER_API_KEY
- Bldg server URL in .env as BLDG_SERVER_URL
- Provisioning endpoint to be provided by user
- User's Google name used as resident alias on bldg-server

