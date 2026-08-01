# Gotchas

Fixes that cost a debugging round because the symptom pointed somewhere else.
Ordinary setup lives in the [README](README.md); this is only for things that
mislead.

## Nix updates silently revoke accessibility grants

**Symptom.** A tool that worked for weeks dies the moment it restarts, with
`must be run with accessibility access! abort..` — and re-ticking it in System
Settings appears to do nothing.

**Why.** macOS pins the TCC grant to the binary, and devbox/nix binaries live at
`/nix/store/<hash>-<pkg>/bin/...`. An update changes that path, so the grant goes
stale — but a process already running holds an approved handle and keeps working.
The breakage is therefore invisible until something restarts it, often long after
the update that caused it. Affects `skhd`, `yabai`, `sketchybar`, and the
`sketchybar-location` helper.

**Fix.** Toggle the entry off and on under System Settings → Privacy & Security →
Accessibility. If that fails, remove it with `−` and re-add the resolved path:

```sh
readlink -f "$(which skhd)"
launchctl kickstart gui/$(id -u)/com.koekeishiya.skhd
```

**Avoid.** Don't restart these to pick up config changes. `skhd` reloads
`skhdrc` on save by itself, and `sketchybar --reload` needs no relaunch. A
`launchctl kickstart -k` is what turns a stale grant into a dead hotkey daemon.

## `yabai --load-sa` asks for a password

**Symptom.** `sudo -n yabai --load-sa` fails with `sudo: a password is required`,
and `yabairc` prints its load-sa warning at startup.

**Why.** Same root cause as above. `/etc/sudoers.d/yabai` authorises a specific
sha256, so a yabai update invalidates the NOPASSWD rule and sudo falls through to
prompting. The scripting addition stays loaded from boot, so spaces keep working
— it only bites at the next yabai or Dock restart.

**Fix.** Regenerate the entry (also recorded at the top of `dot_config/yabai/yabairc`):

```sh
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$(readlink -f "$(which yabai)")" | cut -d' ' -f1) $(which yabai) --load-sa" | sudo tee /etc/sudoers.d/yabai
```

## yabai focus commands are silent no-ops

**Symptom.** `yabai -m display --focus 2` and `yabai -m space --focus 12` exit
`0`, print nothing to stderr, and leave focus exactly where it was.

**Fix.** `yabai -m window --focus <id>` moves focus across displays reliably. Get
an id from `yabai -m query --windows --display 2`.

Two related traps when scripting against window ids. yabai reports Ghostty
windows with an empty `title`, and its window ids can go stale between a
`query --windows` and the `window --focus` that follows ("could not locate window
with the specified id") — its `space` number stays trustworthy, so use yabai for
switching spaces and something else for identifying windows. Accessibility is not
that something else on its own: it only enumerates windows on the *active* space,
so `count windows` returns 0 for an app parked elsewhere, which reads exactly
like the window being gone.

**When testing anything focus-dependent, assert focus in the same command.**
Apps steal it back within a second or two — Spotify and Slack both did during a
single debugging session — so a query, a pause, and then a command will silently
act on the wrong display:

```sh
d=$(yabai -m query --displays | jq -r '[.[]|select(.["has-focus"])|.index]|join(",")')
[ "$d" = "2" ] && yabai -m space --create
```

Three consecutive "yabai creates spaces on the wrong display" results turned out
to be this, not a yabai bug. `space --create` does respect the focused display.

## `space --focus last` means globally last

Mission control indices are global and ordered by display, so display 1 owning
1–11 puts display 2's first space at 12. `last` is therefore the last space of
*all* displays — `yabai -m space --create && yabai -m space --focus last` creates
a space on the laptop and then throws focus onto the external monitor. Ask the
focused display for its own instead:

```sh
yabai -m space --create && yabai -m space --focus "$(yabai -m query --spaces --display | jq '.[-1].index')"
```

Creating or destroying a space also renumbers every space to its right, on every
display.

## sketchybar space items are a pool, not a snapshot

**Symptom.** A second display shows no space chips at all.

**Why.** Sketchybar resolves each `space` item to the display owning that mission
control index, and only draws it on that display's bar. A config that queries
yabai once at startup and clamps to N items will simply have no item for the
external display's space — which sits at a high index precisely because it comes
last.

**Fix.** Create items for `1..max` unconditionally and let sketchybar sort it
out. Items for spaces that don't exist get display mask `1<<30` and stay hidden,
and sketchybar recomputes every mask on space change — so create and destroy need
no rebuild and no yabai signal. Verified by probe: an item for space 12 flipped
its mask from display 2 to display 1 on its own when a new space took that index.

## chezmoi commits the instant you re-add

`autoCommit = true` in `~/.config/chezmoi/chezmoi.toml`, so `chezmoi add` and
`chezmoi re-add` commit immediately — there is no staging step in which to review.

The matching hazard runs the other way. Some targets are written by the tools
that own them: Zed's settings, and `~/.claude/settings.json` (Claude Code writes
model and plugin state into it). Those drift ahead of the chezmoi source, and
`chezmoi apply` will happily overwrite the newer live file. Diff and re-add
before applying to anything in that set.

Also note the repo serves the Linux servers as well as the Mac, with
`.chezmoiignore` gating the macOS-only configs. A guarded block in
`dot_zshrc.tmpl` referencing a command you don't have locally is probably there
for another machine — check before deleting it.

## sketchybar can outlive its supervisor

**Symptom.** `devbox global services ls` reports nothing running while the bar is
clearly on screen, and there is no log file anywhere.

**Why.** sketchybar is a process-compose service
(`~/.local/share/devbox/global/default/process-compose.yaml`), not a launchd
agent. If process-compose exits, sketchybar is reparented to launchd and keeps
running — but its `log_location` is relative to the supervisor's working
directory, so nothing captures stdout any more. Every Lua traceback goes
nowhere, which is how config errors stay invisible.

**Fix.** Restart it as a service rather than bare, so output lands somewhere:

```sh
devbox global services up sketchybar -b
```

Prefer that over repeated `sketchybar --reload` when custom events stop being
delivered — reloading in place has been observed to corrupt custom-event
delivery state, while a clean restart clears it.

## Screenshotting a specific display

`screencapture -D <n>` indexes displays in the same order as `yabai -m query
--displays`, but `-R x,y,w,h` is in *global* coordinates — a secondary display
sits at a negative origin, so combining the two crops the wrong screen. Capture
the display whole, then crop. Note that `sips --cropOffset` measures from the
centre, not the top-left; `python3 -c "from PIL import Image; ..."` is less
surprising.
