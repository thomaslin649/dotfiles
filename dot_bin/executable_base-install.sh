#!/bin/sh

# Function to ask yes/no question with a default value
ask_yes_no_default() {
    local prompt="$1 (Y/n)"
    local default="${2:-}"

    read -p "$prompt: " -n 1 answer
    echo

    case "$answer" in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) return "${default:-0}";;
    esac
}

declare -A versions=(
  ["nodejs"]="20.10.0"
  ["golang"]="1.21.5"
  ["rust"]="1.74.1"
  ["neovim"]="stable"
  ["ruby"]="3.2.2"
)


export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=43200 \
      && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
      && sudo mv $TMPFILE /etc/pacman.d/mirrorlist

ask_yes_no_default "Do you want to add chaotic aur?" 0 && sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
    sudo pacman-key --lsign-key 3056513887B78AEB && \
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' && \
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' && \
    echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf && \
    echo -e '[visual-studio-code-insiders]\nServer = https://nihaals.github.io/visual-studio-code-insiders-arch/\nSigLevel = PackageOptional' | sudo tee -a /etc/pacman.conf

ask_yes_no_default "Do you want to refresh the Arch package database?" 0 && yay -Syyu

ask_yes_no_default "Do you want to install base packages?" 0 && yay -S vivaldi chezmoi wezterm

echo "Installing hyperdots"
git clone --depth 1 https://github.com/prasanthrangan/hyprdots ~/Hyprdots
cd ~/Hyprdots/Scripts
./install.sh

ask_yes_no_default "Do you want to install normal fonts?" 0 && yay -S noto-fonts-cjk noto-fonts-emoji fontforge gnu-free-fonts ttf-joypixels ttf-font-awesome ttf-hack ttf-ms-fonts ttf-twemoji-color ttf-bitstream-vera ttf-cm-unicode

ask_yes_no_default "Do you want to install nerd fonts?" 0 && yay -S ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-dejavu-nerd ttf-hack-nerd

sudo fc-cache -vf

ask_yes_no_default "Do you want to install oh-my-tmux?" 0 && git clone https://github.com/gpakosz/.tmux

ask_yes_no_default "Do you want to add sudoers file?" 0 && cp ~/sudoers.lecture /etc/ && echo -e "Defaults lecture=always\nDefaults lecture_file=/etc/sudoers.lecture" | sudo tee -a /etc/sudoers && sudo -k

ask_yes_no_default "Do you want to install Docker and Docker Compose?" 0 && yay -S docker docker-compose && \
    sudo groupadd docker && sudo usermod -aG docker $USER && \
    sudo systemctl enable docker.service && sudo systemctl enable containerd.service

ask_yes_no_default "Do you want to install other packages?" 0 && yay -S btop ktouch kooha keybase scc asciiquarium fastfetch cava spotify gitflow-cjs yt-dlp mongodb-compass zoxide glow wl-clipboard mkcert hyprshade jq clapper entr ripgrep ranger eog age obsidian obs-studio lazygit pokemon-colorscripts-git lazydocker-bin  just github-cli postman-bin httpie  mpv ark jetbrains-toolbox xdg-ninja tmux eza thefuck taskwarrior-tui git-delta  grex fd sd tealdeer bat git-secrets fzf git-interactive-rebase-tool-bin mousepad gparted vlc ktorrent persepolis

ask_yes_no_default "Do you want to install Zsh with Oh My Zsh and other plugins?" 0 && \
    sudo pacman -S zsh && \
    rm -rf ~/.oh-my-zsh && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open && \
    git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins $ZSH_CUSTOM/plugins/autoupdate && \
    git clone https://github.com/mroth/evalcache ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/evalcache && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Installing bat themes"
mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build

echo "Setting alacritty"
wget https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info &&  sudo tic -xe alacritty,alacritty-direct alacritty.info && rm alacritty.info

echo "Setting wezterm"
yay -S wezterm-terminfo-git

ask_yes_no_default "Do you want to add plugins for asdf ?" 0 && sudo rm -rf ~/.asdf && \
    git clone https://github.com/asdf-vm/asdf.git ~/.config/.asdf --branch v0.14.0 && \
    source ~/.zshrc && \
    asdf update && \
for plugin in "${!versions[@]}"; do
  asdf plugin add "$plugin"
  asdf install "$plugin" "${versions[$plugin]}"
  asdf global "$plugin" "${versions[$plugin]}"
done

sudo systemctl enable bluetooth.service
sudo systemctl restart bluetooth.service

ask_yes_no_default "Do you want to install LunarVim?" 0 && \
    LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) && \
    yay -Rns kate okular
ask_yes_no_default "Do you want to add and sync command history with atuin?" 0 && /bin/bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)"
ask_yes_no_default "Do you want to remove unused packages?" 0 && sudo pacman -Qtdq | sudo pacman -Rns -

ask_yes_no_default "Do you want to apply chezmoi configuration?" 0 && chezmoi init --apply rubiin
echo "Completed setup, run python and cargo installations manually"
