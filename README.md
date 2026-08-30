# Diversity in Beauty Hair Salon — Website

A lightweight, **free-to-host** rebuild of the salon's Wix website, built as a
proof of concept for migrating off Wix.

- **Pages:** Home, Portfolio, Contact (call/text/WhatsApp/email links and a map)
- **Responsive:** one fluid layout that reflows for phone, tablet, and desktop — verified at 390px, 820px, and 1440px
- **Tech:** Plain HTML, CSS, and a little vanilla JavaScript. **No build step, no frameworks, no monthly fees.**
- **Why this approach:** A static site like this can be hosted for **free** on GitHub Pages, Cloudflare Pages, or Netlify, and is fully portable between them. You only pay for the domain.

---

## 📁 What's in here

```
index.html            Home page          → served at  /
portfolio/index.html  Photo gallery      → served at  /portfolio
contact/index.html    Contact details + map → served at  /contact
css/styles.css        All styling
js/main.js            Mobile menu, photo lightbox
assets/               Logo, favicon, and the photos used outside the gallery
assets/originals/     Untouched full-resolution photos. Nothing links to these —
                      they are the backup copy. Keep them.
assets/portfolio/     Web-sized gallery photos (generated from originals/)
tools/optimize-photos.sh   Shrinks big phone photos for the web
404.html              Friendly "page not found" page
robots.txt            SEO: lets search engines crawl
sitemap.xml           SEO: lists the pages
netlify.toml          Netlify config: publish dir, 404 handling
```

> **URLs match the old Wix site on purpose.** Using `portfolio/index.html`
> (instead of `portfolio.html`) makes the page live at `/portfolio` — the exact
> path Google already has indexed — so the migration keeps your existing SEO with
> no redirects needed. Same for `/contact`.

---

## 🚀 Preview it locally

No tools needed beyond a browser. Either:

- **Double-click `index.html`**, or
- Run a tiny local server (better — relative links and the 404 page behave correctly):

  ```bash
  # Python 3 (already on most machines)
  python3 -m http.server 8000
  # then open http://localhost:8000
  ```

---

## 🌐 How this site is hosted

The site is **live on Netlify's free tier**, deployed straight from this repo.

| Layer | Provider | Cost |
|---|---|---|
| Hosting | Netlify (`relaxed-puffpuff-9d0b81.netlify.app`) | $0 |
| DNS | Cloudflare | $0 |
| Registrar | Porkbun | ~US$11/yr |

**Deploys are automatic.** Push to `main` and Netlify rebuilds — there is no build
step, so it just uploads the files. `netlify.toml` sets `publish = "."` and maps
unmatched paths to `404.html`.

HTTPS is a Let's Encrypt certificate issued and renewed by Netlify, covering both
the apex and `www`.

> **Why not GitHub Pages?** It was the original host, but its certificate
> provisioning silently stalled for days with every prerequisite correct — no CAA
> record blocking it, DNS correct, port 80 answering. There was no lever to pull
> from our side. Netlify issued a certificate within minutes. The site is plain
> static files, so it stays portable if Netlify ever disappoints too.


---

## ✏️ Customizing the site

### Adding real photos

Photos straight from a phone are usually 4–8 MB, which makes the site crawl on
mobile data. Shrink them first:

```bash
./tools/optimize-photos.sh ~/Desktop/salon-photos/*.jpg
```

That writes web-sized copies (max 1600px, ~85% quality — typically under 300 KB)
into `assets/portfolio/`, leaving your originals untouched. It needs ImageMagick
(`brew install imagemagick` on macOS, `sudo apt install imagemagick` on Linux).
Any online image resizer works too — just save the results into
`assets/portfolio/`.

**Portfolio gallery** — in `portfolio/index.html`, replace a placeholder
`<figure class="gallery-item">…</figure>` with:

```html
<figure class="gallery-item"><img src="../assets/portfolio/cut-1.jpg" alt="Before and after: textured crop with a skin fade" loading="lazy" /></figure>
```

Add or delete as many as you like. Clicking a photo opens it full size (arrow
keys and Esc work) — nothing extra to set up. Placeholders and real photos can
sit side by side while you're partway through.

> **Write real `alt` text.** It's what screen readers announce and what Google
> reads to understand the image. "Before and after: textured crop" beats "photo".

**Home page salon photo** — in `index.html`, replace the
`<div class="placeholder">…</div>` inside `<div class="hero-photo">` with:

```html
<img src="assets/salon.jpg" alt="Inside Diversity in Beauty Hair Salon" />
```

**Service photos** — in `index.html`, replace each
`<div class="service-media placeholder">Photo</div>` with:

```html
<img class="service-media" src="assets/mens-haircut.jpg" alt="Men's haircut" />
```

> **Getting the photos off Wix:** open the current site, right-click each image
> and choose "Save image as…". Wix also has a bulk export under
> **Site & Mobile Apps → Media Manager → select all → Download**.

### Updating text, services, or prices

Open `index.html`, `portfolio/index.html`, or `contact/index.html` in any text
editor — the content is plain, readable HTML with comments marking the parts
meant to be edited. Change the words and save.

If you add a whole new page, add its URL to `sitemap.xml` too so search engines
find it.

### How the responsive layout works

There's one layout, not three. Grids use `auto-fit`/`minmax`, so they fit as
many columns as the screen allows and reflow on their own. Two media queries
handle the cases where content genuinely needs to change shape:

- **≤ 560px** — each service panel puts its photo above the text instead of beside it.
- **≤ 720px** — the nav collapses behind a hamburger menu.

If you change the layout, check it at roughly 390px (phone), 820px (tablet), and
1440px (desktop). Browser dev tools have a device-toolbar toggle for this.

## 📨 How people get in touch

Booking is **by phone** — the contact page leads with call/text on 226-600-9503,
plus WhatsApp, email, the address, and a map.

There is deliberately no online form. A form needs a third-party service behind it
(Web3Forms, Formspree, Netlify Forms) to actually deliver mail from a static site,
and a form that silently stops working is worse than no form at all. `tel:` and
`mailto:` links have nothing to break and nothing to renew.

If you ever do want one, [Web3Forms](https://web3forms.com) is the least-effort
option: free, no account beyond an email, and it drops into a plain `<form>` with
a single hidden access-key field.

---

## 🔗 The domain (`diversityinbeautyhairsalon.com`)

Fully off Wix. Three independent layers, each swappable without touching the others:

**Registrar — Porkbun.** Renews ~US$11/yr (Wix charged CA$48). Wix refused to allow
nameserver changes on domains it registers, which is what forced the move: it made
every DNS provider unreachable.

**DNS — Cloudflare.** Two records, both **DNS only** (grey cloud — Netlify already
provides the CDN and certificate, so proxying adds a second cache for no gain):

| Type | Name | Content |
|---|---|---|
| A | `@` | `75.2.60.5` (Netlify apex load balancer) |
| CNAME | `www` | `relaxed-puffpuff-9d0b81.netlify.app` |

There are deliberately **no MX or TXT records** — salon email is Gmail-based, not
domain-based. Nothing here affects mail.

**Canonical host is `www`.** Every `<link rel="canonical">`, `og:url`, and
`sitemap.xml` entry points at `www`, and Netlify's primary domain is set to match,
so the apex 301s to `www`. Keep these in agreement or search ranking suffers.

### If you ever move hosts again

1. Deploy the repo to the new host; get its DNS target.
2. Update those two records in Cloudflare.
3. Update the primary/custom domain in the new host so it issues a certificate.

DNS propagates in minutes. Nothing in the HTML is host-specific.

---

## ℹ️ Salon details baked into the site

- **Address:** 195 Franklin Street N, Kitchener, ON N2A 1Y4
- **Phone / text / WhatsApp:** 226-600-9503
- **Email:** diversityinbeautyhairsalon@gmail.com
- **Facebook:** https://www.facebook.com/diversitybeautyhairsalon/

If any of these change, search for them across the `.html` files and update
(they appear in the footer, contact page, and structured-data block).
