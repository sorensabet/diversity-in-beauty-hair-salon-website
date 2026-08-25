/* =========================================================
   Diversity in Beauty Hair Salon — site interactions
   Vanilla JS, no dependencies.
   ========================================================= */
(function () {
  "use strict";

  /* ---- Mobile navigation toggle ---- */
  var toggle = document.querySelector("[data-nav-toggle]");
  var nav = document.querySelector("[data-nav]");

  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
      toggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    });

    // Close the menu when a link is tapped (mobile)
    nav.addEventListener("click", function (e) {
      if (e.target.tagName === "A" && nav.classList.contains("open")) {
        nav.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
        toggle.setAttribute("aria-label", "Open menu");
      }
    });
  }

  /* ---- Auto-update footer year ---- */
  var yearEls = document.querySelectorAll("[data-year]");
  var year = String(new Date().getFullYear());
  yearEls.forEach(function (el) { el.textContent = year; });

  /* ---- Contact form (Web3Forms via fetch) ---- */
  var form = document.getElementById("contact-form");
  if (form) {
    var status = form.querySelector("[data-form-status]");
    var accessKey = form.querySelector('input[name="access_key"]');
    var placeholder = "YOUR_WEB3FORMS_ACCESS_KEY";

    var setStatus = function (msg, type) {
      if (!status) return;
      status.textContent = msg;
      status.className = "form-status" + (type ? " " + type : "");
    };

    form.addEventListener("submit", function (e) {
      e.preventDefault();

      // Until a real access key is set, guide the visitor to direct contact
      // instead of silently failing.
      if (!accessKey || accessKey.value === placeholder || accessKey.value.trim() === "") {
        setStatus(
          "Online form isn't active yet — please call or text 226-600-9503, or email diversityinbeautyhairsalon@gmail.com.",
          "error"
        );
        return;
      }

      if (!form.checkValidity()) {
        form.reportValidity();
        return;
      }

      var btn = form.querySelector('button[type="submit"]');
      var original = btn ? btn.textContent : "";
      if (btn) { btn.disabled = true; btn.textContent = "Sending…"; }
      setStatus("Sending your message…", "");

      var data = new FormData(form);

      fetch(form.action, {
        method: "POST",
        body: data,
        headers: { Accept: "application/json" }
      })
        .then(function (res) { return res.json().then(function (j) { return { ok: res.ok, j: j }; }); })
        .then(function (r) {
          if (r.ok && r.j.success) {
            form.reset();
            setStatus("Thank you! Your message has been sent. We'll be in touch soon.", "success");
          } else {
            setStatus(
              (r.j && r.j.message ? r.j.message + " " : "") +
              "Please call or text 226-600-9503 instead.",
              "error"
            );
          }
        })
        .catch(function () {
          setStatus("Something went wrong. Please call or text 226-600-9503.", "error");
        })
        .finally(function () {
          if (btn) { btn.disabled = false; btn.textContent = original; }
        });
    });
  }

  /* ---- Gallery lightbox ----
     Any <img> inside [data-gallery] becomes clickable and opens full size.
     Placeholder tiles (no <img>) are ignored, so this does nothing until
     real photos are added. */
  var gallery = document.querySelector("[data-gallery]");
  var lightbox = document.querySelector("[data-lightbox]");

  if (gallery && lightbox) {
    var lbImg = lightbox.querySelector("[data-lightbox-img]");
    var photos = [].slice.call(gallery.querySelectorAll("img"));
    var index = 0;
    var lastFocused = null;

    var show = function (i) {
      if (!photos.length) return;
      index = (i + photos.length) % photos.length;
      lbImg.src = photos[index].currentSrc || photos[index].src;
      lbImg.alt = photos[index].alt || "";
    };

    var open = function (i) {
      lastFocused = document.activeElement;
      show(i);
      lightbox.hidden = false;
      document.body.style.overflow = "hidden";
      lightbox.querySelector("[data-lightbox-close]").focus();
    };

    var close = function () {
      lightbox.hidden = true;
      lbImg.removeAttribute("src");
      document.body.style.overflow = "";
      if (lastFocused && lastFocused.focus) lastFocused.focus();
    };

    // Only wire things up if there is at least one real photo.
    if (photos.length) {
      photos.forEach(function (img, i) {
        img.addEventListener("click", function () { open(i); });
      });

      lightbox.querySelector("[data-lightbox-close]").addEventListener("click", close);
      lightbox.querySelector("[data-lightbox-prev]").addEventListener("click", function () { show(index - 1); });
      lightbox.querySelector("[data-lightbox-next]").addEventListener("click", function () { show(index + 1); });

      // Click the backdrop (but not the image or buttons) to close
      lightbox.addEventListener("click", function (e) {
        if (e.target === lightbox) close();
      });

      document.addEventListener("keydown", function (e) {
        if (lightbox.hidden) return;
        if (e.key === "Escape") close();
        else if (e.key === "ArrowLeft") show(index - 1);
        else if (e.key === "ArrowRight") show(index + 1);
      });
    } else {
      // No photos yet — hide the prev/next chrome so it can never appear empty.
      lightbox.hidden = true;
    }
  }
})();
