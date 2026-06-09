# xsar-website

Static HTML5 website for xSAR.

## Structure

```
xsar-website/
├── images/
├── css/
│   └── master.css
├── index.html
├── about.html
└── contact.html
```

## Contact form

`contact.html` submits to Formspree via a standard HTML `POST` form:

- Endpoint: `https://formspree.io/f/xojzwdge`
- Fields: `name`, `email`, `message`

## Git

All commits are SSH-signed with a YubiKey (`sk-ssh-ed25519`). Global git config on this machine handles signing automatically; a YubiKey touch is required at commit time.

Verify the latest commit signature:

```bash
git log --show-signature -1
```

## GitHub remote

Repository: [github.com/xSAR-research/xsar-website](https://github.com/xSAR-research/xsar-website)

```bash
git remote add origin git@github-xsar:xSAR-research/xsar-website.git
git push -u origin main
```

The `github-xsar` host alias in `~/.ssh/config` routes auth through the xSAR-research YubiKey keys.

Register your YubiKey SSH public key in GitHub under **Settings → SSH and GPG keys**:

- **Authentication key** — required for `git push` / `git pull`
- **Signing key** — required for commits to show as Verified

On GitHub, verified commits display a **Verified** badge next to the commit message.