#!/usr/bin/env bash
set -euo pipefail

source /etc/os-release
if [[ "$ID" != ubuntu || "${EUID}" != 0 ]]; then
  echo "Run this script as root on Ubuntu." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  build-essential ca-certificates curl dnsutils file fish git iproute2 \
  jq less lsof openssh-client pkg-config python3 python3-venv ripgrep \
  tcpdump tmux unzip vim-tiny xz-utils fzf

case "$(uname -m)" in
  x86_64) node_arch=x64; nvim_arch=x86_64 ;;
  aarch64) node_arch=arm64; nvim_arch=arm64 ;;
  *) echo "Unsupported architecture." >&2; exit 1 ;;
esac

setup_tmp=$(mktemp -d)
trap 'rm -rf "$setup_tmp"' EXIT
curl -fsSL https://nodejs.org/dist/latest-v24.x/SHASUMS256.txt -o "$setup_tmp/SHASUMS256.txt"
node_archive=$(awk -v arch="$node_arch" '$2 ~ "-linux-" arch "\\.tar\\.xz$" { print $2 }' "$setup_tmp/SHASUMS256.txt")
curl -fsSL "https://nodejs.org/dist/latest-v24.x/$node_archive" -o "$setup_tmp/$node_archive"
(cd "$setup_tmp"; awk -v name="$node_archive" '$2 == name' SHASUMS256.txt | sha256sum -c -)
tar -xJf "$setup_tmp/$node_archive" -C /usr/local --strip-components=1
npm install -g @openai/codex@latest

curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" -o "$setup_tmp/nvim.tar.gz"
mkdir -p /opt/nvim
tar -xzf "$setup_tmp/nvim.tar.gz" -C /opt/nvim --strip-components=1
ln -sfn /opt/nvim/bin/nvim /usr/local/bin/nvim
curl -fsSL https://astral.sh/uv/install.sh -o "$setup_tmp/install-uv.sh"
sh "$setup_tmp/install-uv.sh"

dotfiles_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$HOME/.config" "$HOME/.codex" "$HOME/workspace"
for config in fish tmux nvim; do
  target="$HOME/.config/$config"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.before-sandbox.$(date +%s%N)"
  fi
  ln -sfn "$dotfiles_dir/.config/$config" "$target"
done
chsh -s /usr/bin/fish "$(id -un)"
if ! test -e "$HOME/.codex/config.toml"; then
  printf 'daybreak = true\n' > "$HOME/.codex/config.toml"
fi

codex --version
nvim --version | sed -n '1p'
node --version
fish --version
tmux -V
echo "Run: codex login --device-auth"
echo "Run: cd ~/workspace && tmux new-session -A -s blue"
