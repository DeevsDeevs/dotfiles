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

## A window with one tab has no tab bar to search

**Symptom.** A helper that finds a terminal window by tab title never matches, so
it opens another window every time — instances pile up until you notice.

**Cause.** `AXTabGroup` is the tab *bar*, and macOS only builds one once a window
holds two or more tabs. A single-tab window exposes no tab group at all, so
enumerating tabs returns nothing and a title lookup cannot hit. `open -na` makes
this the normal case: it launches a separate app instance per call, each holding
one lone window.

**Fix.** Identify the window by the process running inside it, not by its title —
walk up from the command's pid to the first ancestor inside an `.app` bundle and
raise that pid. Titles are still worth stamping so the window has a name, just
not worth matching on.

Raising it is not enough on its own if the window sits on another space: see the
space-switch note above.

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

## A broken sketchybar config reports nothing

**Symptom.** After an edit the bar comes up with one item and no error anywhere —
`sketchybar --query bar` lists only `menus.refresher`, and both the service log
and stderr are empty.

**Why.** The Lua config dies on the first runtime error, having already added
whatever it managed to add. Its stderr goes wherever the supervisor put it, which
is nowhere once sketchybar has been [orphaned](#sketchybar-can-outlive-its-supervisor).

**Fix.** Run the config by hand and it prints the file, line and message:

```sh
CONFIG_DIR=~/.config/sketchybar lua ~/.config/sketchybar/sketchybarrc
```

It connects to the running bar, so expect `Item 'x' already exists` warnings —
those are noise. The traceback after them is the answer. `luac -p <file>` catches
syntax errors, but not a nil call like a helper that a later edit deleted.

## sketchybar's display and popup rules

**`display=all` silently hides an item.** Valid for the *bar*, not for an item:
`bar_item.c` parses the value as `1 << strtoul("all")`, i.e. a mask for display
zero, which no display has. The item vanishes with no error. Reset with an empty
value — `display=` — which clears the association back to every display.

**`display=active` exists and is undocumented.** The parser takes a literal
`"active"` alongside the numeric bitmask, and `display` is an alias for
`associated_display`. An item set to it is laid out by exactly one bar.

**A popup only renders on the active display.** An item gets one popup window with
a single anchor, and every bar rewrites that anchor while it is open, so with two
bars it lands on whichever redrew last. Nothing in the click path records which bar
was clicked. Worse, "active" depends on a system setting: sketchybar reads
`SLSGetSpaceManagementMode()`, and with *Displays have separate Spaces* on (mode 1)
the active display is the menu-bar one, so a popup cannot be shown on an unfocused
display at all. With it off, active follows the cursor instead.

**`--trigger` does not fire built-in events.** `sketchybar --trigger display_change`
returns cleanly and delivers nothing; only custom events added with `--add event`
can be triggered. Testing a `display_change` handler needs a real display switch,
and moving focus with yabai is [unreliable](#yabai-focus-commands-are-silent-no-ops) —
verify the active display actually changed before concluding the handler is broken.

**`sbar.animate` does nothing to a bracket's background.** The colour stays where
it was, while a direct `set` of the same property applies normally. Animate an
item and let the bracket carry a flat colour.

## A device may have no master volume control

**Symptom.** Turning the volume down silences one ear; the other keeps playing at
full. Zero is not silent.

**Why.** CoreAudio exposes volume either as one master element or as one element
per channel, and which you get is per device. Code that takes the first control it
finds — master, else channel 1, else channel 2 — drives only the left channel on a
device with no master, and reads that same control back, so it looks consistent
while the right channel sits wherever it was left. Of everything here only the
Bluetooth headset lacks a master; the speakers and BlackHole all have one, so the
bug stays invisible until you put headphones on.

**Fix.** Collect every element the device exposes and set them together; read the
loudest. See `helpers/audio_devices` and `helpers/volume_keys` in deevs-sketchybar.

To check a device: `kAudioDevicePropertyVolumeScalar` on
`kAudioObjectPropertyElementMain` is the master, elements 1..n are the channels.

## Bluetooth headsets drop to phone quality when something opens the mic

**Symptom.** Music through a good Bluetooth headset sounds thin and mono.

**Why.** Selecting the headset as the *input* device puts the link into HFP, and
`system_profiler SPAudioDataType` shows it plainly — input at `1 ch @ 16000 Hz`
where output is `2 ch @ 44100 Hz`. Any app that holds the microphone open keeps it
there; meeting recorders and Slack are the usual ones.

**Fix.** Set the default input to something that is not the headset. Nothing in
the sketchybar audio helpers touches the input device — they only set output — so
this is macOS, not the bar.
