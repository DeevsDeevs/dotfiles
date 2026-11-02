// The images in the focused agent's conversation (Claude Code, Codex, pi), here or on
// another machine: look at them, copy one, paste it into any agent with Cmd+V.

import { View, div, image } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, hc, focused, agents, theme, props, closeOverlay, readTextFile, appHome, notify } from "herdr";
import { writeFile, mkdir, readdir } from "fs/promises";

// Under mods/ but not a mod (no main.js). Names are content hashes, so a path never changes.
const CACHE = "mods/agent-images-cache";
const EXT = { "image/png": "png", "image/jpeg": "jpg", "image/gif": "gif", "image/webp": "webp" };
const GAP = 10;
const abs = (rel) => `${appHome()}/${rel}`;

function button(t, id, label, onClick) {
  return h_flex()
    .id(id)
    .h(24)
    .px(8)
    .flex_none()
    .items_center()
    .rounded(6)
    .text_size(12)
    .bg(t.raised)
    .text_color(t.muted)
    .cursor_pointer()
    .hover((s) => s.bg(t.hover).text_color(t.foreground))
    // A press on a control is not a window drag.
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick(cx);
    })
    .child(label);
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const pad = (n) => String(n).padStart(2, "0");
function when(at) {
  const d = at ? new Date(at) : null;
  return d && !isNaN(d) ? `${MONTHS[d.getMonth()]} ${d.getDate()} ${pad(d.getHours())}:${pad(d.getMinutes())}` : "";
}

export default class AgentImages extends View {
  init(_props, cx) {
    this.target = focused()?.terminal ?? null;
    this.items = [];
    this.cached = null;
    this.error = null;
    this.loaded = false;
    this.busy = false;
    this.filter = "all";
    this.open = null;
    this.width = 0;
    this.h = cx.focus_handle();
    this.h.focus();
    this.load(cx);
    // New pastes show up while the window is open.
    cx.timer.every(10000, (cx) => this.load(cx));
  }

  load(cx) {
    if (!this.target || this.busy) return;
    this.busy = true;
    cx.spawn(async (cx) => {
      try {
        if (!this.cached) {
          await mkdir(abs(CACHE), { recursive: true });
          this.cached = new Set((await readdir(abs(CACHE))).map((n) => n.split(".")[0]));
        }
        const t = JSON.parse((await hc(["get", this.target, "--json"])).stdout);
        const req = JSON.stringify({
          pid: t.pid,
          argv: t.foreground?.argv ?? t.argv ?? [],
          cwd: t.foreground?.cwd ?? t.cwd,
          have: [...this.cached],
        });
        const on = this.target.includes("/") ? this.target.split("/")[0] : null;
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
        this.items = out.images.reverse();
        this.error = out.transcript ? null : "No conversation found for this agent.";
      } catch (e) {
        this.error = String(e?.message ?? e).replace(/^Error: /, "");
      }
      this.loaded = true;
      this.busy = false;
      cx.notify();
    });
  }

  copyImage(im, cx) {
    cx.spawn(async () => {
      let path = abs(im.rel);
      if (!path.endsWith(".png")) {
        const png = abs(`${CACHE}/${im.h}.png`);
        await exec("sips", ["-s", "format", "png", path, "--out", png]);
        path = png;
      }
      const r = await exec("osascript", ["-e", `set the clipboard to (read (POSIX file "${path}") as «class PNGf»)`]);
      notify(r.code === 0
        ? { title: "Image copied", body: "Paste it into any agent with Cmd+V.", level: "success", timeout: 2500 }
        : { title: "Couldn't copy the image", body: r.stderr.trim(), level: "error" });
    });
  }

  close() {
    const overlay = props()?.overlay;
    if (overlay) closeOverlay(overlay);
  }

  render(cx) {
    const t = theme();
    const agent = agents().find((a) => a.address === this.target);
    const shown = this.items.filter((im) => this.filter === "all" || im.who === this.filter);
    const count = (who) => this.items.filter((im) => who === "all" || im.who === who).length;

    const header = h_flex()
      .h(42)
      .px(12)
      .gap(8)
      .flex_none()
      .items_center()
      .bg(t.chrome)
      .border_b(1)
      .border_color(t.border)
      .child(div().font_semibold().text_size(13.5).child("Images"))
      .child(div().text_size(12).text_color(t.dim).truncate().child(agent ? `${agent.title || agent.app} · ${this.target}` : this.target ?? ""))
      .child(div().flex_1())
      .children(["all", "you", "tool"].map((f) => {
        const on = this.filter === f;
        return button(t, `ai-f-${f}`, `${f} ${count(f)}`, (cx) => {
          this.filter = f;
          this.open = null;
          cx.notify();
        }).when(on, (el) => el.bg(t.selected).text_color(t.foreground));
      }))
      .child(button(t, "ai-reload", "↻", (cx) => this.load(cx)))
      .when(Boolean(props()?.overlay), (el) => el.child(button(t, "ai-close", "✕", () => this.close())));

    const message = !this.target
      ? "Focus an agent, then open Images again."
      : this.error ?? (!this.loaded ? "looking…" : shown.length === 0 ? "No images in this conversation." : null);

    let body;
    if (message) {
      body = h_flex().flex_1().items_center().justify_center().text_size(12.5).text_color(t.dim).child(message);
    } else if (this.open) {
      const im = this.open;
      body = v_flex()
        .flex_1()
        .min_h(0)
        .child(div().id("ai-big").flex_1().min_h(0).p(12).overflow_hidden().bg(t.canvas).child(image(im.rel).size_full()))
        .child(
          h_flex()
            .h(40)
            .px(12)
            .gap(8)
            .flex_none()
            .items_center()
            .border_t(1)
            .border_color(t.border)
            .child(button(t, "ai-back", "← all", (cx) => {
              this.open = null;
              cx.notify();
            }))
            .child(div().text_size(12).text_color(t.dim).child(`${im.who} · ${when(im.at)}`))
            .child(div().flex_1())
            .child(button(t, "ai-copy", "Copy image", (cx) => this.copyImage(im, cx)))
            .child(button(t, "ai-path", "Copy path", (cx) => cx.write_to_clipboard(abs(im.rel))))
            .child(button(t, "ai-preview", "Open in Preview", () => exec("open", [abs(im.rel)]))),
        );
    } else {
      const inner = Math.max(0, this.width - 24);
      const cols = Math.max(1, Math.floor((inner + GAP) / (180 + GAP)));
      const w = Math.floor((inner - GAP * (cols - 1)) / cols);
      // The pop-up takes the half away from the hovered card, so it never covers the pointer.
      const hover = this.hover && shown.includes(this.hover.im) ? this.hover : null;
      const grid = v_flex()
        .id("ai-grid")
        .size_full()
        .overflow_y_scroll()
        .p(12)
        .child(h_flex().flex_wrap().gap(GAP).children(shown.map((im, i) =>
          v_flex()
            .id(`ai-${im.h}`)
            .on_hover((inside, cx) => {
              if (inside) this.hover = { im, right: i % cols < cols / 2 };
              else if (this.hover?.im === im) this.hover = null;
              cx.notify();
            })
            .w(w)
            .rounded(8)
            .border(1)
            .border_color(t.border)
            .bg(t.background)
            .cursor_pointer()
            .hover((s) => s.border_color(t.accent))
            .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
            .on_click((_e, cx) => {
              this.open = im;
              this.hover = null;
              cx.notify();
            })
            .child(div().h(Math.round(w * 0.62)).p(6).overflow_hidden().bg(t.canvas).rounded_t(8).child(image(im.rel).size_full()))
            .child(h_flex().h(26).px(8).gap(6).items_center().text_size(11.5)
              .child(div().text_color(im.who === "you" ? t.accent : t.muted).child(im.who))
              .child(div().text_color(t.dim).truncate().child(when(im.at)))))));
      body = div()
        .flex_1()
        .min_h(0)
        .relative()
        .child(grid)
        .when(Boolean(hover), (el) => el.child(
          div()
            .absolute()
            .top(12)
            .bottom(12)
            .w(Math.floor(inner / 2) - GAP)
            .when(hover.right, (d) => d.right(12))
            .when(!hover.right, (d) => d.left(12))
            .p(8)
            .overflow_hidden()
            .rounded(8)
            .border(1)
            .border_color(t.border)
            .bg(t.canvas)
            .shadow_lg()
            .child(image(hover.im.rel).size_full())));
    }

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
        if (e.key !== "escape") return;
        cx.stop_propagation();
        if (this.open) {
          this.open = null;
          cx.notify();
        } else {
          this.close();
        }
      })
      .child(header)
      .child(body);
  }
}
