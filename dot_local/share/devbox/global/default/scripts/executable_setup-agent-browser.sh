#!/bin/sh
set -eu

[ "$(uname -s)" = Linux ] || { echo "This setup is Linux-only" >&2; exit 1; }
command -v apparmor_parser >/dev/null || { echo "AppArmor is required" >&2; exit 1; }

profile=$(mktemp)
trap 'rm -f "$profile"' EXIT

# Ubuntu restricts unprivileged user namespaces; allow Chromium's own sandbox.
cat > "$profile" <<'EOF'
abi <abi/4.0>,
include <tunables/global>

profile nix-chromium /nix/store/*-chromium-unwrapped-*/libexec/chromium/chromium flags=(unconfined) {
  userns,
}
EOF

sudo apparmor_parser --skip-kernel-load "$profile"
sudo install -o root -g root -m 0644 "$profile" /etc/apparmor.d/nix-chromium
sudo apparmor_parser --replace /etc/apparmor.d/nix-chromium
echo "Nix Chromium user-namespace sandbox enabled via AppArmor"
