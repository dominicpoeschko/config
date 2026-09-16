if not status is-interactive
    exit
end

function __check_and_start_atuin -d "check and eventually start atuin daemon"
    # one daemon shared between host and dev containers: socket path (see
    # atuin config.toml) and pidfile both live in $HOME, which is bind
    # mounted into the containers, so the daemon's own pidfile flock is
    # visible on both sides and whoever finds it dead restarts it
    set --local socket $HOME/.local/share/atuin/atuin-daemon.sock
    set --local pidfile $HOME/.local/share/atuin/atuin-daemon.pid

    if flock -n $pidfile true 2> /dev/null
        # lock is free -> no daemon running anywhere
        rm -f $socket
        atuin daemon start &> /dev/null &
        disown $last_pid
    else if not test -S $socket
        # a daemon is running but not on our socket (e.g. started with an
        # old config); replace it so clients don't hang
        pkill -u (id -u) -f 'atuin daemon'
        rm -f $socket
        atuin daemon start &> /dev/null &
        disown $last_pid
    end
end

__check_and_start_atuin

atuin init fish | source

set -x TERM xterm-kitty
set -x EDITOR nvim
set -x VISUAL nvim
#set -x CMAKE_GENERATOR Ninja
set -x FZF_DEFAULT_COMMAND 'fd --type f'
set -x MAKEFLAGS -j (nproc)

alias cd.. 'cd ..'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

function __ssh_agent_is_started -d "check if ssh agent is already started"
    if set -q SSH_AUTH_SOCK
        if test -S $SSH_AUTH_SOCK
            return 0
        end
    end

    if test -f "$SSH_ENV"
        source "$SSH_ENV" > /dev/null
    end

    if test -z "$SSH_AGENT_PID"
        return 1
    end

    ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep -q ssh-agent
    #pgrep ssh-agent
    return $status
end

function __ssh_agent_start -d "start a new ssh agent"
    ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
    chmod 600 "$SSH_ENV"
    source "$SSH_ENV" > /dev/null
    true  # suppress errors from setenv, i.e. set -gx
end

if test -z "$SSH_ENV"
    set -xg SSH_ENV /tmp/"$USER"_ssh_agend_env
end

if not __ssh_agent_is_started
    __ssh_agent_start
end

if which lsd 2>&1 1> /dev/null
    alias ls lsd
end

function sizeof
    for file in $argv
        if test -d "$file"
            dirsize "$file"
        else
            filesize "$file"
        end
    end
end

function filesize
    ls -lah $argv | awk '{printf "%s\t%s\n",$5,$9}'
end

function dirsize
    du -sh $argv | sort -h
end

alias grep='grep  --color=auto --exclude-dir={.git,build}'

alias pushfast='git add -u && git commit -m "??" && git push'
alias checkout_master='git submodule foreach --recursive git checkout master'

alias init_submodules='git submodule update --init --recursive'

function update-git-to-ssh -d "Convert git remote URLs from HTTPS to SSH for current repo and
all submodules recursively"
  # Convert current repo
  set remote_url (git remote get-url origin 2>/dev/null)
  if test -n "$remote_url"
      if echo $remote_url | grep -qE '^https?://'
          set ssh_url (echo $remote_url | sed -E 's#https?://([^/]+)/(.+)#git@\1:\2#')
          git remote set-url origin $ssh_url
          echo "Updated: $remote_url -> $ssh_url"
      else
          echo "Already on SSH: $remote_url"
      end
  end

  # Convert all submodules recursively
  git submodule foreach --recursive '
      remote_url=$(git remote get-url origin 2>/dev/null)
      if [ -n "$remote_url" ]; then
          if echo $remote_url | grep -qE "^https?://"; then
              ssh_url=$(echo $remote_url | sed -E "s#https?://([^/]+)/(.+)#git@\1:\2#")
              git remote set-url origin $ssh_url
              echo "Updated: $remote_url -> $ssh_url"
          else
              echo "Already on SSH: $remote_url"
          fi
      fi
  '
end

function checkout_submodule_branch
    for repo in (git submodule foreach --recursive | awk '{print $2}' | sed 's/\'//g')
        pushd $repo
        set list
        for x in (git branch -a --contains (git rev-parse HEAD))
            set list $list $x
        end
        if test (count $list) -gt 1
            echo $list[1] | grep 'detached' > /dev/null
            if test $status -eq 0
                set branch (string trim -l -r (echo $list[2] | sed 's/remotes\/origin\///g'))
                echo $repo is in detached state switching to $branch
                git checkout $branch
            end
        end
        popd
    end
end

function pullfast
    git submodule status --recursive | awk '{print $2}' | xargs --max-procs=(nproc) -i sh -c "git -C {} pull || echo {} faild" \
    && git pull \
    && git submodule status --recursive \
    && git status
end

function extract --description="Expand or extract bundled & compressed files"
  set --local ext (echo $argv[1] | awk -F. '{print $NF}')
  switch "$ext"
    case tar  # non-compressed, just bundled
      tar -xvf $argv[1]
    case gz
      if test (echo $argv[1] | awk -F. '{print $(NF-1)}') = tar  # tar bundle compressed with gzip
        tar -zxvf $argv[1]
      else  # single gzip
        gunzip $argv[1]
      end
    case xz
      if test (echo $argv[1] | awk -F. '{print $(NF-1)}') = tar  # tar bundle compressed with xz
        tar -xvf $argv[1]
      else  # single gzip
        unxz $argv[1]
      end
    case tgz  # same as tar.gz
      tar -zxvf $argv[1]
    case bz2  # tar compressed with bzip2
      tar -jxvf $argv[1]
    case rar
      unrar x $argv[1]
    case zip
      unzip $argv[1]
    case rpm  # rpm payload is a cpio archive; unpack into a directory named after the package
      set --local dir (basename $argv[1] .rpm)
      mkdir -p $dir
      rpm2cpio $argv[1] | cpio -idmv -D $dir
    case '*'
      echo "unknown extension"
  end
end

set fish_greeting
starship init fish | source

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ -z "$TMUX" ]
    if [ (hostname) = "dp-probook" ] || [ (hostname) = "dominic-tower" ] || [ (hostname) = "dominic-laptop" ] || [ (hostname) = "dominic-workstation" ] || [ (hostname) = "dominic-t580" ]
        if [ "$XDG_VTNR" = 1 ]
            exec startx
        else if [ "$XDG_VTNR" = 2 ]
            exec start-hyprland
        end
    end
end

if [ (hostname) = "dev-dp" ]
    if not set -q container
        /root/dev-docker-shell.sh -a
    end
end

export PATH="$HOME/.local/bin:$PATH"
