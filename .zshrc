# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="fino"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='vim'
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Navigation Alias
alias wpj="cd /home/js00000000/workspace"
alias ppj="cd /home/js00000000/projects"

# Others
alias open="powershell.exe start"
alias dotnet="powershell.exe dotnet"
alias bat="batcat"
alias reload="source ~/.zshrc"
alias zconf="vim ~/.zshrc"
alias c="clear"
alias h="history"
alias k="kubectl"
alias rf="rm -rf"
alias dc="docker compose"
alias gs="git status"
alias py="python3"

# Customize Functions
myip() {
    curl ifconfig.me
}
op() {
  local WORKSPACE_DIR=~/workspace

  # Step 1: Select a top-level folder in ~/workspace
  local TOP_FOLDERS=($(ls -d $WORKSPACE_DIR/*/ | xargs -n 1 basename))

  if [ ${#TOP_FOLDERS[@]} -eq 0 ]; then
    echo "No folders found in $WORKSPACE_DIR."
    return 1
  fi

  echo "Select a top-level folder:"
  select TOP_FOLDER in "${TOP_FOLDERS[@]}"; do
    if [ -n "$TOP_FOLDER" ]; then
      local SELECTED_DIR="$WORKSPACE_DIR/$TOP_FOLDER"
      break
    else
      echo "Invalid selection."
    fi
  done

  # Step 2: Select a subfolder within the selected top-level folder
  local SUB_FOLDERS=($(ls -d $SELECTED_DIR/*/ | xargs -n 1 basename))

  if [ ${#SUB_FOLDERS[@]} -eq 0 ]; then
    echo "No project found in $SELECTED_DIR."
    return 1
  fi

  echo "Select a project:"
  select SUB_FOLDER in "${SUB_FOLDERS[@]}"; do
    if [ -n "$SUB_FOLDER" ]; then
      local PROJECT_DIR="$SELECTED_DIR/$SUB_FOLDER"
      break
    else
      echo "Invalid selection."
    fi
  done

  # Step 3: Attempt to open the All.sln file in the selected subfolder
  local PROJECT_PATH="$PROJECT_DIR/All.sln"

  if [ -f "$PROJECT_PATH" ]; then
    cd "$PROJECT_DIR"
	open All.sln
  else
    echo "Solution file not found in: $PROJECT_DIR"
    return 1
  fi
}



export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GVM_ROOT="$HOME/.gvm"
[[ -s "/home/js00000000/.gvm/scripts/gvm" ]] && source "/home/js00000000/.gvm/scripts/gvm"

export PATH=/home/js00000000/.gvm/bin:/home/js00000000/.nvm/versions/node/v22.6.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Python312/Scripts/:/mnt/c/Python312/:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:/mnt/c/WINDOWS/System32/Wbem:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/WINDOWS/System32/OpenSSH/:/mnt/c/Program:Files/Git/cmd:/Docker/host/bin:/mnt/c/ProgramData/chocolatey/bin:Files/dotnet/:Files/LINQPad8:/mnt/c/Users/chungchih.chen/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/chungchih.chen/AppData/Local/JetBrains/Toolbox/scripts:/mnt/c/Users/chungchih.chen/.dotnet/tools:/usr/local/go/bin:/mnt/c/Users/chungchih.chen/AppData/Local/Programs/Microsoft\ VS\ Code/bin

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
