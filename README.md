# dotfiles

Hyprland (Wayland) + Waybar + Rofi + Kitty + AstroNvim + zsh.

## What this document is

These configs currently run on **ArcoLinux**. Arco does a lot of setup *silently at
install time* — touchpad tapping, font rendering, the Qt/GTK theme bridge, audio,
portals, groups, services. Drop these same dotfiles onto a **bare Arch** install and
a bunch of things quietly don't work, because the configs assume that groundwork
already exists.

So this is a list of **everything that has to be true underneath these dotfiles**,
split into:

- **§1–7 — the invisible layer.** What Arco did for you. On Arch you do it by hand.
- **§8–13 — the visible layer.** Fonts, terminal, shell, editor, theming: what the configs in this repo actually reference.
- **§14 — deploy + checklist.**

---

# Part 1 — What Arco gives you for free

## 1. Repos, AUR helper, mirrors

Arco ships `chaotic-aur` enabled, `paru`/`yay` preinstalled, `multilib` on, and mirrors pre-ranked.

A large share of the packages below come from **chaotic-aur** — `swaylock-effects`,
`hyprpicker-git`, `kvantum-qt5-git`, `sardi-icons`, `pamac`, `opencode-bin`,
`spotify-adblock-git`, `duf-bin`, and more. Without it you're building each from AUR.

```sh
# enable multilib in /etc/pacman.conf, then:
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
          'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
# add to /etc/pacman.conf:
#   [chaotic-aur]
#   Include = /etc/pacman.d/chaotic-mirrorlist

pacman -S reflector
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

Then bootstrap `paru` from AUR manually (or `pacman -S paru` once chaotic-aur is live).

> **The ~35 `arcolinux-*` / `arconet-*` packages installed here are NOT required.**
> The Arco repos aren't even in `pacman.conf` anymore — they're orphaned leftovers.
> They provide branding, wallpapers, GRUB/SDDM themes and dconf defaults.
> The only two that do real work are called out in §2 and §3 below — replicate those
> two files and skip the rest entirely.

## 2. Touchpad — tap-to-click

This is the clearest example of "Arco did it for you". Tap-to-click works today
**only** because of this file:

```
/etc/X11/xorg.conf.d/30-touchpad.conf   ← owned by arcolinux-system-config-git
```

```
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
EndSection
```

On bare Arch nothing creates this. Write it yourself and install `xf86-input-libinput`.

### ⚠️ But under Hyprland that file does nothing

That's an **X11** config. Hyprland reads libinput directly and ignores it — and
`config/hypr/hyprland.conf` has **no `touchpad` block at all**, so on Wayland you're
on libinput defaults right now: no tap-to-click, no natural scroll, no gestures.

To actually get "touchpad just works" on a fresh install, the `input {}` block in
`hyprland.conf` needs this added:

```
input {
  kb_layout = us
  follow_mouse = 1
  sensitivity = 0

  touchpad {
    natural_scroll = true
    tap-to-click = true
    tap-and-drag = true
    disable_while_typing = true
    scroll_factor = 0.5
  }
}

gestures {
  workspace_swipe = true
  workspace_swipe_fingers = 3
  workspace_swipe_distance = 300
}
```

Keyboard layout comes from `localectl set-x11-keymap us` (writes
`/etc/X11/xorg.conf.d/00-keyboard.conf`) plus `kb_layout = us` in `hyprland.conf`.

## 3. Font rendering

Fonts looking right is **two separate things**, and only one of them is "install fonts".

Arco ships hinting/antialiasing defaults via `/etc/skel/.config/fontconfig/fonts.conf`
(so every new user inherits them). Bare Arch gives you fontconfig defaults, which look
noticeably worse. Recreate `~/.config/fontconfig/fonts.conf`:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="font">
        <edit mode="assign" name="hinting"><bool>true</bool></edit>
        <edit mode="assign" name="autohint"><bool>true</bool></edit>
        <edit mode="assign" name="hintstyle"><const>hintslight</const></edit>
        <edit mode="assign" name="rgba"><const>rgb</const></edit>
        <edit mode="assign" name="antialias"><bool>true</bool></edit>
        <edit mode="assign" name="lcdfilter"><const>lcddefault</const></edit>
    </match>
    <alias><family>serif</family><prefer><family>Droid Serif</family></prefer></alias>
    <alias><family>sans-serif</family><prefer><family>Droid Sans</family></prefer></alias>
    <alias><family>sans</family><prefer><family>Droid Sans</family></prefer></alias>
    <alias><family>monospace</family><prefer><family>Droid Sans Mono</family></prefer></alias>
    <alias><family>mono</family><prefer><family>Droid Sans Mono</family></prefer></alias>
</fontconfig>
```

(The GTK settings in §12 repeat `hintslight` + `rgb` — keep them consistent.)

Actual font *packages* are §8.

## 4. Qt / GTK theme bridge

Arco puts these in `/etc/environment` so Qt apps don't look alien next to GTK ones:

```
QT_QPA_PLATFORMTHEME=qt5ct
QT_STYLE_OVERRIDE=kvantum
EDITOR=nano
BROWSER=firefox
```

Without them Qt apps ignore `qt5ct.conf` entirely and render in default Fusion.

## 5. Audio, network, bluetooth, power

Arco preinstalls and pre-enables all of this. On Arch:

```sh
pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol pamixer \
          playerctl alsa-utils sof-firmware alsa-firmware \
          networkmanager network-manager-applet modemmanager \
          bluez bluez-utils blueman \
          power-profiles-daemon brightnessctl acpi acpid upower
```

`power-profiles-daemon` is required by `waybar/scripts/power-profiles` and
`hypr/scripts/ppd-status` (`powerprofilesctl`).

## 6. The desktop plumbing you never think about

Missing any of these and something feels broken in a way that's hard to trace:

```sh
pacman -S polkit polkit-gnome           # GUI auth prompts (hyprland execs the agent)
pacman -S gnome-keyring                 # secrets; hyprland execs gnome-keyring-daemon
pacman -S xdg-user-dirs xdg-user-dirs-gtk   # ~/Pictures etc; `xdg-user-dir PICTURES` is used in the screenshot bind
pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gnome  # screenshare, file pickers
pacman -S gvfs gvfs-mtp gvfs-smb gvfs-afc   # USB/phone/network mounts in Thunar
pacman -S tumbler ffmpegthumbnailer     # thumbnails in Thunar
pacman -S udisks2 udiskie               # automount
```

## 7. Groups and services

Arco's installer adds you to these at install time. On Arch, nothing does:

```sh
usermod -aG sys,games,network,scanner,power,uinput,docker,libvirt,i2c,rfkill,\
users,video,storage,optical,lp,kvm,audio,wheel "$USER"
```

`video` + `i2c` → `brightnessctl` works without root.
`input`/`uinput` → `wtype`. `docker`/`libvirt`/`kvm` → containers and VMs.

**Services** (Arco enables these during install):

```sh
systemctl enable --now NetworkManager bluetooth sddm cronie avahi-daemon \
                       cups.socket libvirtd ModemManager ntpd acpid \
                       power-profiles-daemon

systemctl --user enable --now pipewire pipewire-pulse wireplumber \
                              gnome-keyring-daemon.socket gcr-ssh-agent.socket
```

**Display manager:** SDDM in Wayland mode — `/etc/sddm.conf.d/10-wayland.conf` sets
`DisplayServer=wayland` and `GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell`,
which needs `layer-shell-qt`, `layer-shell-qt5` and `kwin` for the greeter.
The theme (`arcolinux-simplicity`) is cosmetic — swap for any SDDM theme.

---

# Part 2 — What these dotfiles need

## 8. Fonts

**This is the most likely thing to silently break the look.** Waybar, Rofi, Kitty and
Neovim all render glyphs from specific Nerd Fonts, and every Rofi theme uses
**Feather**, which isn't in any repo — it ships in this repo at `local/fonts/`.

```sh
pacman -S ttf-firacode-nerd ttf-fira-code \
          ttf-jetbrains-mono-nerd ttf-jetbrains-mono \
          ttf-iosevka-nerd ttf-hack-nerd ttf-hack \
          ttf-roboto-mono-nerd ttf-roboto-mono ttf-roboto \
          ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
          noto-fonts noto-fonts-emoji \
          ttf-dejavu ttf-droid ttf-liberation ttf-ubuntu-font-family \
          terminus-font adobe-source-code-pro-fonts \
          awesome-terminal-fonts otf-font-awesome gsfonts

paru -S ttf-iosevka ttf-ms-fonts ttf-joypixels \
        ttf-material-design-icons ttf-material-design-iconic-font
```

> `ttf-droid` is not optional — the fontconfig in §3 makes Droid the default
> serif/sans/mono. Without it every unstyled app falls back to something else.

**Fonts shipped in this repo — must be copied, not in any repo:**

```sh
mkdir -p ~/.local/share/fonts
cp local/fonts/*.ttf ~/.local/share/fonts/
fc-cache -fv
```

| File | Needed by |
|---|---|
| `Icomoon-Feather.ttf` → family **`feather`** | **every** Rofi launcher / powermenu / applet theme |
| `GrapeNuts-Regular.ttf` | Rofi theme accents |
| `Iosevka-Nerd-Font-Complete.ttf` | Rofi themes |
| `JetBrains-Mono-Nerd-Font-Complete.ttf` | Waybar / Rofi |
| `Sauce Code Pro Nerd Font Complete.ttf` | terminal fallback |

**Which config uses which:**

| Component | Font |
|---|---|
| Kitty | `FiraCode Nerd Font` @ 18 |
| Hyprlock | `FiraCode Nerd Font` |
| Waybar | `JetBrainsMono Nerd Font` 16px/900 + `Font Awesome 6 Free` (battery glyph) |
| Rofi | `feather`, `Iosevka Nerd Font`, `JetBrains Mono Nerd Font`, `Grape Nuts` |
| GTK3 | `Sans 14` · GTK4 `Noto Sans 16` |

## 9. Hyprland stack

Hyprland **0.56+** — the configs use the new `windowrule = match:<matcher> <pattern>, <rule> <value>`
syntax; the old `windowrulev2` form is deprecated and warns.

```sh
pacman -S hyprland hyprland-protocols hyprlang hyprwayland-scanner \
          hypridle hyprlock hyprpaper hyprsunset hyprland-guiutils \
          waybar dunst rofi rofi-emoji \
          swaybg wlsunset \
          grim slurp wf-recorder wl-clipboard wtype wlr-randr \
          thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman \
          kitty

paru -S hyprpicker-git swaylock-effects
```

What each is bound to, from `config/hypr/hyprland.conf`:

| Binary | Used for |
|---|---|
| `swaybg` | wallpaper |
| `waybar` | status bar |
| `dunst` | notifications (volume / brightness / screenshot popups) |
| `rofi` | launcher `SUPER+D`, emoji `SUPER+E`, clipboard `SUPER+C`, powermenu `SUPER+SHIFT+E` |
| `grim`+`slurp` | screenshots — `Print` full, `SUPER+S` region |
| `hyprpicker` | colour picker `SUPER+SHIFT+X` |
| `hyprlock` | lock `SUPER+SHIFT+L` and via `loginctl lock-session` |
| `hypridle` | dim @2.5min → lock @5min → DPMS off @5.5min |
| `wlsunset` | night temp, `-S 9:00 -s 6:00 -t 4500` |
| `pamixer`/`brightnessctl` | volume + brightness keys with dunst popups |
| `thunar` | file manager `SUPER+N` |

### ⚠️ Broken / stale things to fix on a fresh install

1. **Clipboard history is dead.** `hyprland.conf` execs `wl-clipboard-history` and
   `greenclip daemon`, and `SUPER+C` pipes `greenclip print` into Rofi — **neither
   binary is installed**, even on the current machine. Either
   `paru -S rofi-greenclip wl-clipboard-history-git`, or rewrite the binding around
   `copyq` (which *is* installed) and drop the two `exec-once` lines.

2. **`copydots.sh` runs at every login** and copies configs into `~/Arch-Hyprland/` —
   a legacy path that no longer matches this repo. Delete the `exec-once` line or
   repoint it at `~/dotfiles/config/`.

3. **Notification icons are missing.** `scripts/volume_notify` and
   `scripts/brightness_notify` pass `-i /usr/share/icons/Win11-dark/...`, and that
   theme isn't installed — those popups already render iconless. Install a Win11 icon
   theme or point `-i` at an installed one.

4. **Portals.** `desktop-portals.sh` kills stray portals and restarts
   `/usr/libexec/xdg-desktop-portal-hyprland` then `/usr/lib/xdg-desktop-portal`.
   Verify those paths exist.

## 10. Terminal

**Kitty** is the daily driver (`SUPER+Return`). `config/kitty/kitty.conf`:

- `FiraCode Nerd Font` @ 18
- `background_opacity 0.5` + `dynamic_background_opacity yes` (needs a compositor that honours it)
- `background #090909`, block cursor, `shell_integration no-cursor`
- zero padding, `sync_to_monitor yes`, URL detection + hyperlink underline

Also installed but not primary: `alacritty` (+ `alacritty-themes`, `base16-alacritty-git`),
`wezterm`, `terminator`, `guake`, `rxvt-unicode` (+ `urxvt-perls`, `urxvt-resize-font-git`).

## 11. Shell

zsh + oh-my-zsh + powerlevel10k. **`~/.zshrc` is not tracked in this repo** — copy it
across manually, or better, add it here.

```sh
pacman -S zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
chsh -s /bin/zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
```

`ZSH_THEME="powerlevel10k/powerlevel10k"` · `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)`
· `EDITOR=nvim` · `LC_ALL=en_US.UTF-8`. p10k needs a Nerd Font in the terminal (§8).

**CLI tools it expects:**

```sh
pacman -S ripgrep fd bat fzf zoxide tree jq less most tmux htop btop ncdu \
          the_silver_searcher yazi superfile gitui plocate expac wget rsync unzip unrar 7zip
paru -S duf-bin eza
```

> `.zshrc` aliases `ls`/`ll` → `eza` and `cat` → `bat`, both guarded by `command -v`.
> `bat` is installed; **`eza` is not**, so those aliases silently no-op today.

## 12. Neovim

**AstroNvim v6** — full config in `config/nvim/` (has its own README).

```sh
pacman -S neovim neovide python-pynvim tree-sitter luarocks
pacman -S ripgrep fd git gcc make unzip curl \
          nodejs npm yarn pnpm go rustup jdk8-openjdk \
          python-pip python-pipx prettier yamllint deno zig zls
paru -S lazygit golangci-lint-bin codelldb-bin
```

Enabled `astrocommunity` packs (from `lua/community.lua`) determine what Mason pulls:
**lua, go, rust, python, java, docker**, plus conform.nvim, neotest,
nvim-dap-virtual-text, telescope-dap, persistent-breakpoints, picker-lsp-mappings,
picker-nvchad-theme, the vscode recipe, and `opencode-nvim` (needs the `opencode`
binary — `opencode-bin` from chaotic-aur).

```sh
cp -r config/nvim ~/.config/nvim
nvim        # lazy.nvim bootstraps, then :AstroMasonInstallAll
```

## 13. Theming

```sh
pacman -S lxappearance qt5ct kvantum adapta-gtk-theme
paru -S nwg-look-bin arc-gtk-theme arc-darkest-theme-git \
        oranchelo-icon-theme-git kvantum-qt5-git \
        sardi-icons surfn-icons-git bibata-cursor-theme-bin
```

Current values — **none of these files are tracked in this repo yet**, so they must be
recreated by hand or via `nwg-look` / `lxappearance` / `qt5ct`:

| File | Setting |
|---|---|
| `~/.config/gtk-3.0/settings.ini` | theme `Arc-Darker`, icons `Sardi-Flat-Arc`, cursor `Adwaita` 24, font `Sans 14`, prefer-dark, `hintslight` + `rgb`, `gtk-xft-dpi=98304` |
| `~/.config/gtk-4.0/settings.ini` | icons `Sardi-Arc`, cursor `breeze_cursors` 24, font `Noto Sans 16`, prefer-dark |
| `~/.gtkrc-2.0` | GTK2 mirror of the GTK3 values (written by `nwg-look`; custom bits go in `~/.gtkrc-2.0.mine`) |
| `~/.config/qt5ct/qt5ct.conf` | style `kvantum-dark`, icons `Sardi-Arc` |
| SDDM | theme `arcolinux-simplicity`, cursor `Bibata-Modern-Ice` |

`gtk-xft-dpi=98304` = 96 × 1024, i.e. plain 1× scaling despite the HiDPI panel.
Wallpapers are in `config/hypr/wallpapers/`; `variety` handles rotation.

---

# Part 3

## 14. Deploy

Configs here are **plain copies, not symlinks** — `~/.config/*` are real directories.

```sh
git clone <this-repo> ~/dotfiles && cd ~/dotfiles

cp -r config/hypr config/waybar config/kitty config/rofi config/dunst \
      config/nvim config/flameshot ~/.config/
# X11 / i3 fallback session (optional):
cp -r config/i3 config/picom config/polybar config/terminator ~/.config/

mkdir -p ~/.local/share/fonts && cp local/fonts/*.ttf ~/.local/share/fonts/ && fc-cache -fv
chmod +x ~/.config/hypr/scripts/* ~/.config/hypr/*.sh ~/.config/waybar/scripts/*
mkdir -p ~/Pictures/Screenshots
```

Log out, pick **Hyprland** in SDDM.

### Post-install checklist

- [ ] chaotic-aur + multilib enabled, `paru` working (§1)
- [ ] `/etc/X11/xorg.conf.d/30-touchpad.conf` written (§2)
- [ ] `touchpad {}` + `gestures {}` added to `hyprland.conf` (§2) — **not in the repo yet**
- [ ] `~/.config/fontconfig/fonts.conf` written (§3)
- [ ] `/etc/environment` has `QT_QPA_PLATFORMTHEME` + `QT_STYLE_OVERRIDE` (§4)
- [ ] groups added, **re-login required** (§7)
- [ ] services enabled, system + user (§7)
- [ ] `local/fonts/*.ttf` copied + `fc-cache -fv` — Rofi is unusable without `feather` (§8)
- [ ] greenclip / wl-clipboard-history installed or `SUPER+C` rewritten (§9)
- [ ] `copydots.sh` neutralised (§9)
- [ ] GTK/Qt theme files recreated (§13)
- [ ] `nvim` → lazy bootstrap → `:AstroMasonInstallAll` (§12)
- [ ] `p10k configure` (§11)

### Hardware-specific lines to re-point

Three values are hardcoded and will be wrong on any other machine:

| What | Where | Find the right value |
|---|---|---|
| Monitors `DP-3` / `eDP-2` | `hyprland.conf` — `monitor=` and every `workspace = N, monitor:` | `hyprctl monitors` |
| Backlight `intel_backlight` | brightness binds, `hypridle.conf`, `scripts/brightness_notify` | `ls /sys/class/backlight` |
| GPU drivers | — | Intel: `mesa vulkan-intel intel-media-driver`. NVIDIA hybrid here: `nvidia-open-dkms nvidia-utils nvidia-prime` |

## 15. Worth adding to this repo

Things the setup depends on that currently live only on this machine:

- `~/.zshrc` (18KB — §11 describes it but it isn't tracked)
- `/etc/X11/xorg.conf.d/30-touchpad.conf` (§2)
- `~/.config/fontconfig/fonts.conf` (§3)
- `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`, `~/.gtkrc-2.0`, `~/.config/qt5ct/qt5ct.conf` (§13)
- `pacman -Qqen` / `pacman -Qqem` package dumps
- an `install.sh` wrapping §14

## Layout

```
config/
  hypr/      hyprland.conf, hypridle.conf, hyprlock.conf, scripts/, wallpapers/,
             desktop-portals.sh, copydots.sh
  waybar/    config, style.css, scripts/
  kitty/     kitty.conf
  rofi/      launchers/, powermenu/, applets/, colors/, images/, scripts/
  dunst/     dunstrc
  nvim/      AstroNvim v6 (own README)
  i3/ polybar/ picom/ terminator/ flameshot/    X11 fallback
  .Xresources
local/
  fonts/     feather, Grape Nuts, Iosevka NF, JetBrains Mono NF, Source Code Pro NF
```
