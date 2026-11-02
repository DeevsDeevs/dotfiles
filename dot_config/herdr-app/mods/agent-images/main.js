// The images in the focused agent's conversation (Claude Code, Codex, pi), here or on
// another machine: look at them, copy one, paste it into any agent with Cmd+V.

import { View, div, image } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, hc, focused, agents, theme, props, closeOverlay, readTextFile, appHome, notify } from "herdr";
import { writeFile, mkdir, readdir } from "fs/promises";

// Under mods/ but not a mod (no main.js). Names are content hashes, so a path never changes.
const CACHE = "mods/agent-images-cache";
const EXT = { "image/png": "png", "image/jpeg": "jpg", "image/gif": "gif", "image/webp": "webp" };
const APPS = { "claude-code": "Claude", codex: "Codex", pi: "pi" };
const WHO = { you: "Pasted", tool: "Tool" };
const GAP = 12;
const CARD_MIN = 190;
const abs = (rel) => `${appHome()}/${rel}`;

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

function button(t, id, label, onClick, { solid = false, tip } = {}) {
  return control(
    h_flex()
      .id(id)
      .h(26)
      .px(10)
      .flex_none()
      .items_center()
      .rounded(6)
      .text_size(12)
      .bg(solid ? t.solid : t.raised)
      .text_color(solid ? t.solid_foreground : t.foreground)
      .hover((s) => (solid ? s.opacity(0.9) : s.bg(t.hover)))
      .when(Boolean(tip), (el) => el.tooltip(tip))
      .child(label),
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
      cx.timer.after(1500, (cx) => {
        if (this.copied === im.h) this.copied = null;
        cx.notify();
      });
    });
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
    const machine = this.target?.includes("/") ? this.target.split("/")[0] : "this Mac";
    const count = (f) => this.items.filter((im) => f === "all" || im.who === f).length;
    const segment = (f, label) => {
      const on = this.filter === f;
      return control(
        h_flex()
          .id(`ai-f-${f}`)
          .h(22)
          .px(10)
          .gap(5)
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
      .h(46)
      .px(14)
      .gap(10)
      .flex_none()
      .items_center()
      .bg(t.chrome)
      .border_b(1)
      .border_color(t.border)
      .child(div().font_semibold().text_size(13.5).child("Images"))
      .when(Boolean(this.target), (el) => el.child(
        h_flex()
          .gap(6)
          .min_w(0)
          .items_center()
          .text_size(12)
          .child(div().px(6).py(1).rounded(4).bg(t.raised).text_color(t.muted).child(`${APPS[agent?.app] ?? agent?.app ?? "agent"} · ${machine}`))
          .child(div().text_color(t.dim).truncate().child(agent?.title ?? ""))))
      .child(div().flex_1())
      .child(h_flex().p(2).gap(2).rounded(7).bg(t.raised)
        .child(segment("all", "All"))
        .child(segment("you", "Pasted"))
        .child(segment("tool", "Tool")))
      .when(Boolean(props()?.overlay), (el) => el.child(button(t, "ai-close", "✕", () => this.dismiss(), { tip: "Close (Esc)" })));
  }

  grid(t, shown) {
    const inner = Math.max(0, this.width - 2 * 16);
    const cols = Math.max(1, Math.floor((inner + GAP) / (CARD_MIN + GAP)));
    const w = Math.floor((inner - GAP * (cols - 1)) / cols);
    const thumbH = Math.round(w * 0.62);
    // The pop-up takes the half away from the hovered card, so it never covers the pointer.
    const hover = this.hover && shown.includes(this.hover.im) ? this.hover : null;

    const card = (im, i) => {
      const hovered = hover?.im === im;
      const copied = this.copied === im.h;
      return control(
        v_flex()
          .id(`ai-${im.h}`)
          .w(w)
          .rounded(8)
          .overflow_hidden()
          .border(1)
          .border_color(hovered ? t.accent : t.border)
          .bg(t.background)
          .on_hover((inside, cx) => {
            if (inside) this.hover = { im, right: i % cols < cols / 2 };
            else if (this.hover?.im === im) this.hover = null;
            cx.notify();
          })
          .child(
            div()
              .relative()
              .h(thumbH)
              .p(6)
              .bg(t.canvas)
              .child(image(im.rel).size_full())
              .when(hovered || copied, (el) => el.child(
                div().absolute().top(8).right(8).child(
                  button(t, `ai-qc-${im.h}`, copied ? "Copied ✓" : "Copy", (cx) => this.copyImage(im, cx), { solid: true })))),
          )
          .child(
            h_flex()
              .h(30)
              .px(10)
              .gap(8)
              .items_center()
              .text_size(11.5)
              .child(div().size(6).rounded(3).flex_none().bg(im.who === "you" ? t.accent : t.dim))
              .child(div().text_color(im.who === "you" ? t.foreground : t.muted).child(WHO[im.who] ?? im.who))
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
          .p(16)
          .child(h_flex().flex_wrap().gap(GAP).children(shown.map(card))))
      .when(Boolean(hover), (el) => el.child(
        v_flex()
          .absolute()
          .top(16)
          .bottom(16)
          .w(Math.floor(inner / 2) - GAP)
          .when(hover.right, (d) => d.right(16))
          .when(!hover.right, (d) => d.left(16))
          .overflow_hidden()
          .rounded(10)
          .border(1)
          .border_color(t.border)
          .bg(t.canvas)
          .shadow_lg()
          .child(div().flex_1().min_h(0).p(10).child(image(hover.im.rel).size_full()))
          .child(h_flex().h(28).px(12).gap(8).items_center().text_size(11.5).bg(t.popover).text_color(t.dim)
            .child(WHO[hover.im.who] ?? hover.im.who)
            .child("·")
            .child(when(hover.im.at))
            .child(div().flex_1())
            .child("click to open"))));
  }

  viewer(t, shown) {
    const im = this.open;
    const i = shown.findIndex((x) => x.h === im.h);
    const copied = this.copied === im.h;
    return v_flex()
      .flex_1()
      .min_h(0)
      .child(
        h_flex()
          .h(44)
          .px(14)
          .gap(8)
          .flex_none()
          .items_center()
          .border_b(1)
          .border_color(t.border)
          .child(button(t, "ai-back", "← All images", (cx) => {
            this.open = null;
            cx.notify();
          }, { tip: "Esc" }))
          .child(button(t, "ai-prev", "‹", (cx) => this.step(shown, -1, cx), { tip: "Previous (←)" }))
          .child(button(t, "ai-next", "›", (cx) => this.step(shown, 1, cx), { tip: "Next (→)" }))
          .child(div().text_size(12).text_color(t.dim).child(`${i + 1} of ${shown.length} · ${WHO[im.who] ?? im.who} · ${when(im.at)}`))
          .child(div().flex_1())
          .child(button(t, "ai-preview", "Open in Preview", () => exec("open", [abs(im.rel)])))
          .child(button(t, "ai-path", "Copy path", (cx) => cx.write_to_clipboard(abs(im.rel)), { tip: "Where the image is saved on this Mac" }))
          .child(button(t, "ai-copy", copied ? "Copied ✓" : "Copy image", (cx) => this.copyImage(im, cx), { solid: true, tip: "⌘C, then paste into any agent with ⌘V" })),
      )
      .child(div().id("ai-big").flex_1().min_h(0).p(16).overflow_hidden().bg(t.canvas).child(image(im.rel).size_full()));
  }

  render(cx) {
    this.follow(cx);
    const t = theme();
    const shown = this.items.filter((im) => this.filter === "all" || im.who === this.filter);
    if (this.open && !shown.some((im) => im.h === this.open.h)) this.open = null;

    let body;
    const empty = (title, hint) =>
      v_flex().flex_1().gap(6).items_center().justify_center().text_size(13)
        .child(div().text_color(t.muted).child(title))
        .when(Boolean(hint), (el) => el.child(div().text_size(12).text_color(t.dim).child(hint)));
    if (!this.target) body = empty("No agent in focus", "Click an agent's terminal and this window follows it.");
    else if (this.error && !this.items.length) body = empty("Couldn't read this agent's images", this.error);
    else if (!this.loaded) body = empty("Looking for images…");
    else if (!shown.length) body = empty(
      this.filter === "you" ? "You haven't pasted an image here yet" : "No images in this conversation yet",
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
        if (Math.abs(size.width - this.width) > 1) {
          this.width = size.width;
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
