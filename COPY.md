# xSAR copy style guide

Dev reference for user-facing copy on `index.html`, `progress.html`, `supporters.html`, `about.html`, and `contact.html`. Shared chrome is duplicated across all pages — apply every change in all files.

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
- Licence: **AGPL-3.0** / **GNU Affero General Public License version 3.0** in formal first mention

## Brand and HTML

- Home `<title>`: `xSAR — Search And Respond`; subpages: `xSAR — Progress`, `xSAR — Supporters`, `xSAR — About`, `xSAR — Contact`
- `<html lang="en-AU">` on all pages
- `og:image` path: `https://xsar.com.au/images/xsar-logo.png` (lowercase filename)
- Per-page `og:url`: homepage, `/progress.html`, `/supporters.html`, `/about.html`, `/contact.html` respectively
- Footer copyright: `by xSAR, a philanthropic project` (comma after xSAR)
- Primary nav order: Home · Progress · Supporters · About · Contact (desktop + mobile + footer)

## Progress page

- Two short paragraphs: open-source journey + AGPL-3.0; embedded firmware and Linux tools in Rust and Python
- Primary CTA: `xSAR-Research` → `https://github.com/xSAR-research/` (`btn btn-primary`, `rel="noopener noreferrer"`)

## Supporters page

- Layout: logo left, positive paragraph right (`.supporter` grid); stacks on small screens
- Each entry: local logo asset under `images/`, external link with `rel="noopener noreferrer"`
- Copy should thank the supporter for concrete help; stay warm and factual, not salesy
