# xSAR copy style guide

Dev reference for user-facing copy on `index.html`, `about.html`, `supporters.html`, and `contact.html`. Shared chrome is duplicated across all pages — apply every change in all files.

## Geography

- Use full names: **Queensland and the Northern Territory**
- Do not use abbreviations (`QLD`, `NT`) in body copy
- Prefer **in Queensland and the Northern Territory** over *of the Queensland and Northern Territory*
- Drop redundant words like "area" unless grammar requires them

## SES and emergency services

- First mention per page: **emergency services and the State Emergency Service (SES)**
- Later mentions on the same page: **the SES** or **emergency services and the SES**
- Use singular **State Emergency Service**, not "State Emergency Services"
- Australian usage: SES is the official volunteer emergency arm in Queensland and the Northern Territory

## Tone

- **Tech-forward, rescuer-first** — lead with what responders do; tie xSAR to AI-assisted autonomous drone swarms, situational awareness, multispectral/thermal sensing, and mesh communications
- Stay humble: xSAR works in the background; volunteers and communities come first
- Align body copy with meta/footer language (drone swarm, human-in-the-loop oversight)

## Hyphenation and terms

- **human-in-the-loop** — hyphenated, no quotes
- **multispectral** — one word
- **bushfires** — one word (site-wide standard)
- Australian English: honour, centre, organisation

## Brand and HTML

- Home `<title>`: `xSAR — Search And Respond`; subpages: `xSAR — About`, `xSAR — Supporters`, `xSAR — Contact`
- `<html lang="en-AU">` on all pages
- `og:image` path: `https://xsar.com.au/images/xsar-logo.png` (lowercase filename)
- Per-page `og:url`: homepage, `/about.html`, `/supporters.html`, `/contact.html` respectively
- Footer copyright: `by xSAR, a philanthropic project` (comma after xSAR)
- Primary nav order: Home · About · Supporters · Contact (desktop + mobile + footer)

## Supporters page

- Layout: logo left, positive paragraph right (`.supporter` grid); stacks on small screens
- Each entry: local logo asset under `images/`, external link with `rel="noopener noreferrer"`
- Copy should thank the supporter for concrete help; stay warm and factual, not salesy
