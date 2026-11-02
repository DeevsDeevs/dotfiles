// The images in the focused agent's conversation (Claude Code, Codex, pi), here or on
// another machine: look at them, copy one, paste it into any agent with Cmd+V.

import { View, div, image, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, hc, focused, agents, theme, props, closeOverlay, readTextFile, appHome, notify } from "herdr";
import { writeFile, mkdir, readdir } from "fs/promises";

// Under mods/ but not a mod (no main.js). Names are content hashes, so a path never changes.
const CACHE = "mods/agent-images-cache";
const EXT = { "image/png": "png", "image/jpeg": "jpg", "image/gif": "gif", "image/webp": "webp" };
const APPS = { "claude-code": "Claude Code", codex: "Codex", pi: "pi" };
const WHO = { you: "Pasted", tool: "Tool" };
const GAP = 14;
const CARD_MIN = 200;
const abs = (rel) => `${appHome()}/${rel}`;
const icon = (name) => svg(`mods/agent-images/${name}.svg`);

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const pad = (n) => String(n).padStart(2, "0");
function when(at) {
  const d = at ? new Date(at) : null;
  if (!d || isNaN(d)) return "";
  const mins = Math.floor((Date.now() - d) / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const time = `${pad(d.getHours())}:${pad(d.getMinutes())}`;
  return d.toDateString() === new Date().toDateString() ? time : `${MONTHS[d.getMonth()]} ${d.getDate()}, ${time}`;
}

// A press on a control is not a window drag.
function control(el, onClick) {
  return el
    .cursor_pointer()
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick(cx);
    });
}

function iconButton(t, id, name, onClick, tip) {
  return control(
    h_flex()
      .id(id)
      .size(28)
      .flex_none()
      .items_center()
      .justify_center()
      .rounded(6)
      .text_color(t.muted)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .tooltip(tip)
      .child(icon(name).size(15)),
    onClick,
  );
}

export default class AgentImages extends View {
  init(_props, cx) {
    this.target = null;
    this.items = [];
    this.cached = null;
    this.filter = "all";
    this.open = null;
    this.hover = null;
    this.copied = null;
    this.width = 0;
    this.height = 0;
    this.h = cx.focus_handle();
    this.h.focus();
    this.follow(cx);
    // New pastes show up while the window is open.
    cx.timer.every(10000, (cx) => this.load(cx));
  }

  // The window is about the agent you're looking at: it follows focus between agents
  // and keeps the last one while something else (this window, a shell) has it.
  follow(cx) {
    const f = focused()?.terminal;
    if (!f || f === this.target || !agents().some((a) => a.address === f)) return;
    this.target = f;
    this.items = [];
    this.error = null;
    this.loaded = false;
    this.open = null;
    this.hover = null;
    this.load(cx);
  }

  load(cx) {
    const target = this.target;
    if (!target || this.busy) return;
    this.busy = true;
    cx.spawn(async (cx) => {
      let items = null;
      let error = null;
      try {
        if (!this.cached) {
          await mkdir(abs(CACHE), { recursive: true });
          this.cached = new Set((await readdir(abs(CACHE))).map((n) => n.split(".")[0]));
        }
        const t = JSON.parse((await hc(["get", target, "--json"])).stdout);
        const req = JSON.stringify({
          pid: t.pid,
          argv: t.foreground?.argv ?? t.argv ?? [],
          cwd: t.foreground?.cwd ?? t.cwd,
          have: [...this.cached],
        });
        const on = target.includes("/") ? target.split("/")[0] : null;
        const script = await readTextFile(abs("mods/agent-images/extract.py"));
        // Through sh: a remote core's own PATH may not reach python3.
        const r = await exec("sh", ["-c", 'python3 -c "$1" "$2"', "sh", script, req], { on });
        if (r.code !== 0) throw new Error(r.stderr.trim() || `exit ${r.code}`);
        const out = JSON.parse(r.stdout);
        for (const im of out.images) {
          im.rel = `${CACHE}/${im.h}.${EXT[im.mime] ?? "png"}`;
          if (im.data) {
            await writeFile(abs(im.rel), Buffer.from(im.data, "base64"));
            this.cached.add(im.h);
            delete im.data;
          }
        }
        items = out.images.reverse();
        if (!out.transcript) error = "Couldn't find this agent's conversation.";
      } catch (e) {
        error = String(e?.message ?? e).replace(/^Error: /, "");
      }
      this.busy = false;
      // Focus moved to another agent meanwhile: this answer is stale.
      if (target !== this.target) return this.load(cx);
      this.items = items ?? this.items;
      this.error = error;
      this.loaded = true;
      if (this.open) this.open = this.items.find((im) => im.h === this.open.h) ?? null;
      cx.notify();
    });
  }

  copyImage(im, cx) {
    cx.spawn(async (cx) => {
      let path = abs(im.rel);
      if (!path.endsWith(".png")) {
        const png = abs(`${CACHE}/${im.h}.png`);
        await exec("sips", ["-s", "format", "png", path, "--out", png]);
        path = png;
      }
      const r = await exec("osascript", ["-e", `set the clipboard to (read (POSIX file "${path}") as «class PNGf»)`]);
      if (r.code !== 0) {
        notify({ title: "Couldn't copy the image", body: r.stderr.trim(), level: "error" });
        return;
      }
      this.copied = im.h;
      cx.notify();
      cx.timer.after(1200, (cx) => {
        if (this.copied === im.h) this.copied = null;
        cx.notify();
      });
    });
  }

  // Copy's icon turns into a check for a moment; the button keeps its size and words.
  copyIcon(t, im) {
    const done = this.copied === im.h;
    return icon(done ? "check" : "copy").size(14).when(done, (el) => el.text_color(t.working));
  }

  step(shown, by, cx) {
    const i = shown.findIndex((im) => im.h === this.open?.h);
    if (i < 0) return;
    this.open = shown[(i + by + shown.length) % shown.length];
    cx.notify();
  }

  dismiss() {
    const overlay = props()?.overlay;
    if (overlay) closeOverlay(overlay);
  }

  header(t) {
    const agent = agents().find((a) => a.address === this.target);
    const machine = this.target?.includes("/") ? this.target.split("/")[0] : null;
    const who = agent ? `${APPS[agent.app] ?? agent.app ?? "Agent"}${machine ? ` on ${machine}` : ""}` : "";
    const count = (f) => this.items.filter((im) => f === "all" || im.who === f).length;
    const segment = (f, label) => {
      const on = this.filter === f;
      return control(
        h_flex()
          .id(`ai-f-${f}`)
          .h(24)
          .px(10)
          .gap(6)
          .items_center()
          .rounded(5)
          .text_size(12)
          .when(on, (el) => el.bg(t.surface).shadow_sm())
          .text_color(on ? t.foreground : t.muted)
          .hover((s) => s.text_color(t.foreground))
          .child(label)
          .child(div().text_color(t.dim).child(String(count(f)))),
        (cx) => {
          this.filter = f;
          this.open = null;
          this.hover = null;
          cx.notify();
        },
      );
    };
    return h_flex()
      .h(48)
      .pl(16)
      .pr(10)
      .gap(10)
      .flex_none()
      .items_center()
      .bg(t.chrome)
      .border_b(1)
      .border_color(t.border)
      .child(icon("image").size(15).text_color(t.muted))
      .child(div().flex_none().font_semibold().text_size(13).child("Images"))
      .child(h_flex().flex_1().min_w(0).gap(6).text_size(12)
        .child(div().flex_none().text_color(t.muted).child(who))
        .when(Boolean(agent?.title), (el) => el
          .child(div().flex_none().text_color(t.dim).child("·"))
          .child(div().min_w(0).text_color(t.dim).truncate().child(agent.title))))
      .child(h_flex().flex_none().p(2).gap(2).rounded(7).bg(t.raised)
        .child(segment("all", "All"))
        .child(segment("you", "Pasted"))
        .child(segment("tool", "Tool")))
      .when(Boolean(props()?.overlay), (el) => el.child(iconButton(t, "ai-close", "x", () => this.dismiss(), "Close  Esc")));
  }

  grid(t, shown) {
    const inner = Math.max(0, this.width - 2 * 18);
    const cols = Math.max(1, Math.floor((inner + GAP) / (CARD_MIN + GAP)));
    const w = Math.floor((inner - GAP * (cols - 1)) / cols);
    const thumbH = Math.round(w * 0.625);
    // The pop-up takes the half away from the hovered card, so it never covers the pointer.
    const hover = this.hover && shown.includes(this.hover.im) ? this.hover : null;

    const card = (im, i) => {
      const hovered = hover?.im === im;
      return control(
        v_flex()
          .id(`ai-${im.h}`)
          .w(w)
          .gap(7)
          .on_hover((inside, cx) => {
            if (inside) this.hover = { im, right: i % cols < cols / 2 };
            else if (this.hover?.im === im) this.hover = null;
            cx.notify();
          })
          .child(
            div()
              .relative()
              .h(thumbH)
              .rounded(8)
              .overflow_hidden()
              .border(1)
              .border_color(hovered ? t.accent : t.border)
              .bg(t.canvas)
              .child(image(im.rel).size_full())
              .when(hovered || this.copied === im.h, (el) => el.child(
                control(
                  h_flex()
                    .id(`ai-qc-${im.h}`)
                    .absolute()
                    .top(6)
                    .right(6)
                    .size(28)
                    .items_center()
                    .justify_center()
                    .rounded(6)
                    .bg(t.popover)
                    .border(1)
                    .border_color(t.border)
                    .shadow_sm()
                    .text_color(t.foreground)
                    .hover((s) => s.bg(t.hover))
                    .tooltip("Copy image")
                    .child(this.copyIcon(t, im)),
                  (cx) => this.copyImage(im, cx),
                ))),
          )
          .child(h_flex().px(2).items_center().text_size(11.5)
            .child(div().text_color(im.who === "you" ? t.accent : t.muted).child(WHO[im.who] ?? im.who))
            .child(div().flex_1())
            .child(div().text_color(t.dim).child(when(im.at)))),
        (cx) => {
          this.open = im;
          this.hover = null;
          cx.notify();
        },
      );
    };

    return div()
      .flex_1()
      .min_h(0)
      .relative()
      .child(
        v_flex()
          .id("ai-grid")
          .size_full()
          .overflow_y_scroll()
          .p(18)
          .child(h_flex().flex_wrap().gap(GAP).children(shown.map(card))))
      .when(Boolean(hover), (el) => el.child(this.popup(t, hover, inner)));
  }

  // Sized to the picture, at most its own size (×2 for tiny ones), so nothing floats in a box.
  popup(t, hover, inner) {
    const PAD = 8;
    const { w, ht } = hover.im;
    const maxW = Math.floor(inner / 2) - GAP - 2 * PAD;
    const maxH = Math.max(120, this.height - 48 - 2 * 18 - 2 * PAD);
    const s = w && ht ? Math.min(maxW / w, maxH / ht, 2) : 1;
    const box = (n, fallback) => (n ? Math.round(n * s) + 2 * PAD : fallback);
    return div()
      .absolute()
      .top(18)
      .w(box(w, maxW + 2 * PAD))
      .h(box(ht, maxH + 2 * PAD))
      .when(hover.right, (d) => d.right(18))
      .when(!hover.right, (d) => d.left(18))
      .p(PAD)
      .rounded(10)
      .border(1)
      .border_color(t.border)
      .bg(t.popover)
      .shadow_lg()
      .child(image(hover.im.rel).size_full().rounded(4));
  }

  viewer(t, shown) {
    const im = this.open;
    const i = shown.findIndex((x) => x.h === im.h);
    return v_flex()
      .flex_1()
      .min_h(0)
      .child(
        h_flex()
          .h(44)
          .pl(8)
          .pr(10)
          .gap(4)
          .flex_none()
          .items_center()
          .border_b(1)
          .border_color(t.border)
          .child(control(
            h_flex().id("ai-back").h(28).pl(6).pr(10).gap(6).items_center().rounded(6).text_size(12)
              .text_color(t.muted)
              .hover((s) => s.bg(t.hover).text_color(t.foreground))
              .tooltip("All images  Esc")
              .child(icon("arrow-left").size(15))
              .child("All"),
            (cx) => {
              this.open = null;
              cx.notify();
            }))
          .child(div().w(1).h(16).mx(6).bg(t.border))
          .child(iconButton(t, "ai-prev", "chevron-left", (cx) => this.step(shown, -1, cx), "Previous  ←"))
          .child(iconButton(t, "ai-next", "chevron-right", (cx) => this.step(shown, 1, cx), "Next  →"))
          .child(div().ml(6).text_size(12).text_color(t.muted).child(`${i + 1} of ${shown.length}`))
          .child(div().ml(10).text_size(12).text_color(t.dim).child(`${WHO[im.who] ?? im.who} · ${when(im.at)}`))
          .child(div().flex_1())
          .child(iconButton(t, "ai-path", "link", (cx) => cx.write_to_clipboard(abs(im.rel)), "Copy file path"))
          .child(iconButton(t, "ai-preview", "external-link", () => exec("open", [abs(im.rel)]), "Open in Preview"))
          .child(control(
            h_flex().id("ai-copy").ml(6).h(28).px(12).gap(7).items_center().rounded(6).text_size(12)
              .bg(t.solid)
              .text_color(t.solid_foreground)
              .hover((s) => s.opacity(0.9))
              .tooltip("Copy image  ⌘C")
              .child(this.copyIcon(t, im))
              .child("Copy"),
            (cx) => this.copyImage(im, cx))),
      )
      .child(div().id("ai-big").flex_1().min_h(0).p(20).overflow_hidden().bg(t.canvas).child(image(im.rel).size_full()));
  }

  render(cx) {
    this.follow(cx);
    const t = theme();
    const shown = this.items.filter((im) => this.filter === "all" || im.who === this.filter);
    if (this.open && !shown.some((im) => im.h === this.open.h)) this.open = null;

    const empty = (title, hint) =>
      v_flex().flex_1().gap(8).items_center().justify_center()
        .child(icon("image").size(22).text_color(t.dim))
        .child(div().text_size(13).text_color(t.muted).child(title))
        .when(Boolean(hint), (el) => el.child(div().max_w(420).text_size(12).text_color(t.dim).child(hint)));
    let body;
    if (!this.target) body = empty("No agent in focus", "Click an agent's terminal; this window follows it.");
    else if (this.error && !this.items.length) body = empty("Couldn't read this agent's images", this.error);
    else if (!this.loaded) body = empty("Looking for images…");
    else if (!shown.length) body = empty(
      this.filter === "you" ? "Nothing pasted here yet" : "No images in this conversation yet",
      "Paste one into the agent with ⌘V and it shows up here.");
    else if (this.open) body = this.viewer(t, shown);
    else body = this.grid(t, shown);

    return v_flex()
      .id("ai-root")
      .size_full()
      .bg(t.surface)
      .text_color(t.foreground)
      .track_focus(this.h)
      .on_size_change((size, cx) => {
        if (Math.abs(size.width - this.width) > 1 || Math.abs(size.height - this.height) > 1) {
          this.width = size.width;
          this.height = size.height;
          cx.notify();
        }
      })
      .on_key_down((e, cx) => {
        const k = e.keystroke;
        if (k === "escape") {
          cx.stop_propagation();
          if (this.open) {
            this.open = null;
            cx.notify();
          } else this.dismiss();
        } else if (this.open && (k === "left" || k === "right")) {
          cx.stop_propagation();
          this.step(shown, k === "left" ? -1 : 1, cx);
        } else if (this.open && (k === "cmd-c" || k === "ctrl-c")) {
          cx.stop_propagation();
          this.copyImage(this.open, cx);
        }
      })
      .child(this.header(t))
      .child(body);
  }
}
