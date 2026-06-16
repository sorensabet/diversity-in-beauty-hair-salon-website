# Diversity in Beauty Hair Salon — Website

A lightweight, **free-to-host** rebuild of the salon's Wix website, built as a
proof of concept for migrating off Wix.

- **Pages:** Home, Portfolio, Contact (with a working contact form + call/text/WhatsApp/email links and a map)
- **Tech:** Plain HTML, CSS, and a little vanilla JavaScript. **No build step, no frameworks, no monthly fees.**
- **Why this approach:** A static site like this can be hosted for **free** on GitHub Pages, Cloudflare Pages, or Netlify, and is fully portable between them. You only pay for the domain.

---

## 📁 What's in here

```
index.html            Home page          → served at  /
portfolio/index.html  Photo gallery      → served at  /portfolio
contact/index.html    Contact form + map → served at  /contact
css/styles.css        All styling
js/main.js            Mobile menu + contact form handling
assets/               Logo, favicon, social image (SVG placeholders)
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
- Run a tiny local server (better — the contact form and relative links behave correctly):

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

### Replace the placeholder photos
The site currently uses tasteful colored placeholders so it looks complete. To add
your mother's real photos:

1. Drop image files into `assets/` (e.g. `assets/salon.jpg`, `assets/style-1.jpg`).
   Use `.jpg` for photos; keep them under ~300 KB each (resize before uploading).
2. **Home – salon photo:** in `index.html`, find the `<div class="media-card" ...>`
   block and replace it with:
   ```html
   <img src="assets/salon.jpg" alt="Inside Diversity in Beauty Hair Salon" class="media-card" />
   ```
3. **Portfolio:** in `portfolio.html`, replace each
   `<figure class="gallery-item"><span>Style N</span></figure>` with:
   ```html
   <figure class="gallery-item"><img src="assets/style-1.jpg" alt="Finished haircut" /></figure>
   ```
   (You can add or remove as many as you like.)

> Tip: you can download your existing photos from the current Wix site by
> right-clicking each image and choosing "Save image as…".

### Update text, services, or prices
Open `index.html` / `portfolio.html` / `contact.html` in any text editor — the
content is plain, readable HTML with comments. Change the words and save.

---

## 📨 Turning on the contact form

The form works without any server using **[Web3Forms](https://web3forms.com)** —
free, no account beyond an email, submissions are sent straight to the salon's inbox.
Until it's configured, the form gracefully tells visitors to call/text/email instead.

1. Go to https://web3forms.com, enter `diversityinbeautyhairsalon@gmail.com`, and
   they'll email you a free **Access Key**.
2. In `contact.html`, replace `YOUR_WEB3FORMS_ACCESS_KEY` with that key:
   ```html
   <input type="hidden" name="access_key" value="paste-your-key-here" />
   ```
3. Save, redeploy. Submissions now arrive by email. (Web3Forms' free tier covers
   well beyond what a salon needs.)

**Alternatives** if you prefer: [Formspree](https://formspree.io) (similar setup) or,
if hosting on Netlify, Netlify Forms. The call/text/WhatsApp/email links work no
matter what, so the page is useful even with the form off.

---

## 🔗 Pointing the domain (`diversityinbeautyhairsalon.com`)

You currently buy the domain through Wix. You can keep the domain there and just
point it at the new free host — **you don't have to transfer the domain to move off
Wix hosting.**

1. Deploy to your chosen host (above) and note the DNS records / target it gives you.
2. In **Wix → Domains → Manage DNS** (or wherever you manage the domain), update the
   records:
   - **GitHub Pages:** add the four `A` records GitHub lists, plus a `CNAME` for `www`
     → `<username>.github.io`. Then add a file named `CNAME` to this repo containing
     `www.diversityinbeautyhairsalon.com`.
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
