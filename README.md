# Sagar Hostel Mess PWA

Static, mobile-first prototype for the Sagar Hostel near CUSAT SOE. The attached poster was used as a content reference for the weekly meals and service times; its contact details were not copied into the app.

## What is included

- Weekly breakfast, lunch and dinner menu based on the provided poster.
- Five sample residents assigned to each day's mess duty.
- Menu and roster editing through the **Manage** tab.
- Changes persist in the browser via `localStorage`.
- Installable PWA metadata and an offline service worker.
- Responsive design for phone, tablet and desktop.

## Free deployment

Upload the contents of this folder to a free static host such as GitHub Pages, Cloudflare Pages or Netlify. No server or database is required for this demo. The host-generated URL is globally accessible and can be added to an Android or iOS home screen.

For a real shared roster, the next phase should replace `localStorage` with a small hosted database and add admin authentication. Firebase, Supabase or Cloudflare D1 can support that while staying within free tiers at hostel scale.
