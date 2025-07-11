if not status is-interactive
    exit
end

function __check_and_start_atuin -d "check and eventually start atuin daemon"
    set --local tmp (ps -ef)
    echo $tmp | grep "atuin daemon" &> /dev/null
    set --local running $status

    set --local socket  /run/user/(id -u)/atuin.sock
    if begin; not test -S $socket; or test $running -ne 0; end
        if not set -q container
            rm -rf  $socket
            atuin daemon &> /dev/null &
            disown $last_pid
        end
    end
end

__check_and_start_atuin

atuin init fish | source

set -x TERM xterm-256color
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
    case tgz  # same as tar.gz
      tar -zxvf $argv[1]
    case bz2  # tar compressed with bzip2
      tar -jxvf $argv[1]
    case rar
      unrar x $argv[1]
    case zip
      unzip $argv[1]
    case '*'
      echo "unknown extension"
  end
end

set fish_greeting

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showupstream "informative"

set -g __fish_git_prompt_showcolorhints 1

set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_color_dirtystate brblue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles normal
set -g __fish_git_prompt_color_cleanstate green

function fish_prompt --description="Write out the prompt"

    set stat $status

    if test $stat -gt 0
        set_color red
        echo "FAIL" $stat
    else
        set_color green
        echo "OK"
    end

    set_color yellow
    echo -n "["

    set username (id -un)
    if test $username = root
        set_color red
    else
        set_color green
    end

    echo -n $username

    if test -n "$SSH_CLIENT" -o -n "$SSH_TTY" -o -n "$SSH_CONNECTION"
        set_color red
    else
        set_color green
    end

    echo -n @(hostname)
    set_color yellow
    echo -n "]"

    set git (__fish_git_prompt "%s")

    if test -n "$git"
        set_color cyan
        echo -n "GIT["
        set_color -o normal
        echo -n $git
        set_color cyan
        echo -n "]"
    end

    set_color yellow
    echo -n "["
    set_color magenta
    echo -n (pwd|sed "s=$HOME=~=")

    set_color yellow
    echo -n "]["

    set_color brblue
    echo -n (date +%T)

    set_color yellow
    echo "]"
    echo -n "-> "
    set_color normal

end

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && [ -z "$TMUX" ]
    if [ (hostname) = "dp-probook" ] || [ (hostname) = "dominic-tower" ] || [ (hostname) = "dominic-laptop" ] || [ (hostname) = "dominic-workstation" ] || [ (hostname) = "dominic-t580" ]
        exec startx
    end
end

if [ (hostname) = "dev-dp" ]
    if not set -q container
        /root/dev-docker-shell.sh -a
    end
end

