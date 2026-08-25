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
netlify.toml          Config if you deploy to Netlify
.github/workflows/deploy.yml   Auto-deploys to GitHub Pages on push to main
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

## 🌐 Deploying for free (pick ONE)

### Option A — GitHub Pages (recommended, already wired up)

This repo includes a workflow that **auto-publishes on every push to `main`**.

1. Merge this branch into `main`.
2. In GitHub: **Settings → Pages → Build and deployment → Source: "GitHub Actions"**.
3. Push to `main`. The site goes live at `https://<username>.github.io/<repo>/`.
4. To use the real domain, see **"Pointing the domain"** below.

### Option B — Cloudflare Pages

1. Create a free Cloudflare account → **Pages → Connect to Git** → pick this repo.
2. Build settings: **Framework preset = None**, **Build command = (blank)**, **Output directory = `/`**.
3. Deploy. Add the custom domain in the Pages project's **Custom domains** tab.

### Option C — Netlify

1. Free Netlify account → **Add new site → Import from Git** → pick this repo.
2. `netlify.toml` already sets publish directory to `.` with no build command.
3. Add the domain under **Domain settings**.

All three cost **$0** for a site this size, include free HTTPS, and you can switch
between them anytime since it's just static files.

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

## 🔗 Pointing the domain (`diversityinbeautyhairsalon.com`)

You currently buy the domain through Wix. You can keep the domain there and just
point it at the new free host — **you don't have to transfer the domain to move off
Wix hosting.**

1. Deploy to your chosen host (above) and note the DNS records / target it gives you.
2. In **Wix → Domains → Manage DNS** (or wherever you manage the domain), update the
   records:
   - **GitHub Pages:** add the four `A` records GitHub lists, plus a `CNAME` for `www`
     → `<username>.github.io`. The repo already contains a `CNAME` file with
     `www.diversityinbeautyhairsalon.com`, so there's nothing to add there.
   - **Cloudflare Pages / Netlify:** follow their "add custom domain" wizard — it tells
     you the exact records.
3. DNS changes take a few minutes to a few hours. HTTPS is issued automatically.

Once the new site is live and verified, you can cancel the Wix subscription. (Later,
if you'd rather not pay Wix for the domain either, you can transfer it to a cheaper
registrar like Cloudflare or Namecheap — but that's optional and separate from this.)

---

## ℹ️ Salon details baked into the site

- **Address:** 195 Franklin Street N, Kitchener, ON N2A 1Y4
- **Phone / text / WhatsApp:** 226-600-9503
- **Email:** diversityinbeautyhairsalon@gmail.com
- **Facebook:** https://www.facebook.com/diversitybeautyhairsalon/

If any of these change, search for them across the `.html` files and update
(they appear in the footer, contact page, and structured-data block).
