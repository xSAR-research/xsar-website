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

## GitLab remote

Create an empty public project named `xsar-website` on GitLab, then:

```bash
git remote add origin git@gitlab.com:<your-username>/xsar-website.git
git push -u origin main
```

Register your SSH **signing** public key (`~/.ssh/id_ed25519_sk_primary.pub`) in GitLab under **Preferences → SSH Keys** so commits show as verified.