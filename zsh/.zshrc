# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

HEADPHONE="fc-e8-06-9d-a6-8e"
DOT="$HOME/dotfiles"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"p\

DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.


plugins=(
  git
  spaceship-vi-mode
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Methods
irename() {
    mv "platforms/android/app/build/outputs/apk/debug/app-debug.apk" "platforms/android/app/build/outputs/apk/debug/"$1
}

zipalign() {
    ~/Library/Android/sdk/build-tools/29.0.0/zipalign -v 4 platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk $1
}

mode() {
  if [[ "$1" != "work" && "$1" != "fun" ]]
  then
    echo "There is no '$1' mode"
  else
    sudo cp "/etc/hosts_"$1 /etc/hosts
    source $HOME/.zshrc
    
    if [[ $1 == "work" ]]
    then
      echo "Work mode activated 💻"
    fi

    if [[ $1 == "fun" ]]
    then
      echo "Fun mode activated 🥳"
    fi
  fi
}
# prompt_context() {
#   if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#     prompt_segment black default "$USER"
#   fi
# }


grehydrate() {
    git checkout master
    git merge --no-ff --no-edit $1"/"$2 
    git tag "v"$2 
    git push origin master 
    git push origin "v"$2 
    git checkout wip/dev 
    git merge master 
    git push origin wip/dev 
    git checkout dev 
    git merge master 
    git push origin dev 
    git checkout master 
    git branch -d $1"/"$2 
    git push --delete origin $1"/"$2 
    git fetch --prune
}

gprune() {
    git pull
    git pull --prune
    git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D
}

update-lokallize() {
  unzip -o ~/Downloads/Kyte_Web-locale.zip -d ~/Downloads
  mv -f ~/Downloads/locale/pt_BR.json ~/Downloads/locale/pt-BR.json
  mv -f ~/Downloads/locale/*  ~/workspaces/react/kyte-web/src/i18n/locale/web/
  rm -rf ~/Downloads/locale 
}

look() {
  cd $(find ~/workspaces/ -maxdepth 2 -type d | grep $1 | head -n 1)
}

cod() {
  look $1
  code .
}

yv() {
  yarn info $1 version
}

yversions() {
  yarn info $1 versions
}

fport() {
  lsof -i :$1
}

compress() {
  INPUT="$1"

  if [[ -z "$INPUT" ]]; then
    echo "Usage: compress input.mov"
    return 1
  fi

  # Derive output path: same directory, {filename}(compressed).{extension}
  DIR="${INPUT%/*}"
  [[ "$DIR" == "$INPUT" ]] && DIR="."
  FILE="${INPUT##*/}"
  NAME="${FILE%.*}"
  EXT="${FILE##*.}"
  OUTPUT="${DIR}/${NAME}(compressed).${EXT}"

  echo "Compressing ${FILE}..."
  if ffmpeg -i "$INPUT" -vcodec libx264 -crf 23 -preset medium -acodec aac -b:a 128k -v warning -stats "$OUTPUT"; then
    echo "Compressed: ${NAME}(compressed).${EXT}"
  else
    echo "Error: Failed to compress $INPUT"
    return 1
  fi
}

compress_videos() {
  FOLDER="$1"

  if [[ -z "$FOLDER" ]]; then
    echo "Usage: compress_zip /path/to/folder"
    return 1
  fi

  if [[ ! -d "$FOLDER" ]]; then
    echo "Error: Directory '$FOLDER' not found"
    return 1
  fi

  # Find video files using ls and grep
  local VIDEO_FILES=($(ls "$FOLDER" | grep -iE '\.(mp4|mov|avi|mkv|flv|wmv|webm|m4v)$'))
  
  if [[ ${#VIDEO_FILES[@]} -eq 0 ]]; then
    echo "No video files found in '$FOLDER'"
    return 1
  fi

  echo "Found ${#VIDEO_FILES[@]} video file(s) in '$FOLDER'. Starting compression..."
  echo "----------------------------------------"

  local compressed_count=0
  local failed_count=0

  # Process each video file
  for filename in "${VIDEO_FILES[@]}"; do
    local full_path="$FOLDER/$filename"
    
    echo "Processing: $filename"
    
    # Compress the video using the existing compress function
    if compress "$full_path"; then
      ((compressed_count++))
    else
      ((failed_count++))
      echo "Failed to compress: $filename"
    fi
    echo "----------------------------------------"
  done

  echo "Compression complete!"
  echo "Successfully compressed: $compressed_count file(s)"
  if [[ $failed_count -gt 0 ]]; then
    echo "Failed to compress: $failed_count file(s)"
  fi
}

# prompt_context() {
#   if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#     prompt_segment black default "$USER"
#   fi
# }


# Spaceship theme config
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  #char
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  # vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_GIT_SHOW=true
SPACESHIP_GIT_STATUS_SHOW=true
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=""
SPACESHIP_GIT_STATUS_PREFIX=" "
SPACESHIP_GIT_STATUS_SUFFIX=""
export SPACESHIP_GIT_STATUS_ADDED="%F{yellow}•%F{red}"
export SPACESHIP_GIT_STATUS_UNTRACKED="%F{blue}•%F{red}"
export SPACESHIP_GIT_STATUS_DELETED="%F{green}•%F{red}"
export SPACESHIP_GIT_STATUS_MODIFIED="%F{red}•%F{red}"
SPACESHIP_GIT_STATUS_STASHED=""

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Mobile
alias apk='adb install -r platforms/android/app/build/outputs/apk/debug/app-debug.apk'
alias dv='adb devices -l'
alias kill-server='adb kill-server'
alias start-server='adb kill-server'
alias mirror='scrcpy --window-x 1608 --window-y 0 --prefer-text'
alias sign='jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.jks platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk my-alias'
alias phone='adb connect 192.168.0.62:5555 && mirror'
alias phone-ip='adb shell ifconfig wlan0'
alias emua='adb shell input keyevent 82'
alias emum='adb shell input keyevent 82'
# alias emu="emulator -avd Pixel_XL_API_34_2 > /dev/null 2>&1 &"

# Git
alias gt='git stash'
alias gclean='git clean -f -d'
alias gdiscard='git checkout .'
alias gunlock='rm -rf .git/index.lock'
alias gtsv='git tag --sort=version:refname'
alias gamend='git commit --amend --no-edit'
alias gback='git switch -'
alias gwhere='git branch --contains'
alias gmerge='git merge --continue --no-edit'
alias grev='git rev-parse --short HEAD'
alias glo="git log --pretty=format:'%C(blue)%h%C(red)%d %C(white)%s - %C(cyan)%cn, %C(green)%cr'"

# Applications
alias opera='open -a Opera'
alias vysor='open -a Vysor'
alias chrome='open -a "/Applications/Chrome.app"'
alias postman='open -a Postman'
alias xcode='open -a Xcode'
alias safari='open -a Safari'
alias sketch='~/workspaces/scripts/sketch.sh'
alias lol='open -a "/Applications/League of Legends.app/Contents/LoL/LeagueClient.app"'
alias notes='open -a "/Applications/Notes.app"'

# Utilities
alias zshrc='code ~/dotfiles/zsh/.zshrc'
alias config='cd ~/dotfiles'
alias extract='tar -xzvf arquivo.tar.gz'
alias download='curl -O'
alias delete='rm -rf'
alias cl="clear && printf '\e[3J'"
alias update='source ~/.zshrc'
alias imgsize='sips -g pixelWidth -g pixelHeight'
alias network="ifconfig | grep 'inet '"
alias folders="ls -d */"
alias gs='gst'
alias battery='acpi -ib'
alias d="cd .."
alias back="cd -"
alias pfun="sudo mv "
alias bc="blueutil --disconnect $HEADPHONE && blueutil --connect $HEADPHONE"

# Ionic
alias iserve='ionic serve --no-open'
alias iplatform='ionic cordova platform'
alias iplugin='ionic cordova plugin'
alias ibuild='ionic cordova build'
alias irun='ionic cordova run'
alias igen='ionic generate'
alias iprepare='ionic cordova prepare'
alias iresources='ionic cordova resources'
alias ideploy='yarn run deploy'
alias iclean='rm -rf platforms plugins www'

# React Native
alias rn='react-native'
alias rndebugger='open "rndebugger://set-debugger-loc?host=localhost&port=8081"'
alias kyte="adb shell monkey -p com.kyte -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"
alias app="adb shell monkey -p com.kyte -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"

# Yarn/NPM
alias compodoc='npm run compodoc'
alias e2e='npm run e2e'
alias ys='yarn start'
alias y='yarn'
alias yt='yarn test'
alias yta='yarn test --watchAll'
alias yweb='yarn start-storybook-web'
# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export LC_ALL=en_US.UTF-8
# export JAVA_HOME=/opt/homebrew/Cellar/openjdk/21.0.2/libexec/openjdk.jdk/Contents/Home
export JAVA_HOME=/Users/guilherme/.sdkman/candidates/java/current/bin/java
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/emulator:$PATH
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/bin:$PATH
export PATH=$HOME/flutter/bin:$PATH
export PATH=/opt/homebrew/opt/python@3.13/libexec/bin:$PATH
export PATH=/$HOME/Library/flutter/bin:$PATH
export GTK_IM_MODULE="xim"
# export NODE_OPTIONS="--openssl-legacy-provider"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#something 123
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
