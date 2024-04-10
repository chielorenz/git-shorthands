#!/bin/sh

# @doc gs: Git status
alias gs="git status"

# @doc gb: List local branches
alias gb="git branch"

# @doc gbr: List remote branches
alias gbr="git branch --remotes"

# @doc gf: Fetch all
alias gf="git fetch --all"

# @doc gd: Git diff 
alias gd="git diff"

# @doc gpull: Fetch and pull current branch
alias gpull="git fetch --all && git pull"

# @doc gpush: Git push
alias gpush="git push"

# @doc ga: Git add
alias ga="git add"

# @doc gc [message]: Commit
alias gc="git commit -m"

# @doc gac [message]: Git add and commit
alias gac="git commit -am"

# @doc gm: Git merge
alias gm="git merge"

# @doc gn [branch]: Create new branch
alias gn="git checkout -b"

# @doc gl: Pretty log
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# @doc gg [branch]: Checkout a local git branch by searching for it
gg () {
	_is-git-directory || return
	_has-params $@ || return

	# --format is to keep only branch name
	branches=$(git branch --format='%(refname:short)')

	# --max-count is to keep only first match
	branch=$(echo $branches | grep $1 --max-count 1)

	if ! git show-ref --verify --quiet refs/heads/$branch; then
		echo No branch matching "'$1'" found locally; return;
	fi

	git checkout $branch
}

# @doc ggr [branch]: Checkout a local or remote branch by searchig it
ggr () {
	_is-git-directory || return
	_has-params $@ || return

	# --format is to keep only branch name
	# --all to get local and remote branch
	branches=$(git branch --all --format='%(refname:short)')

	# --max-count is to keep only first match
	branch=$(echo $branches | grep $1 --max-count 1)

	# Ensure to checkout the local branch
	[[ $branch == origin/* ]] && branch=$(echo $branch | cut -c 8-)
	
	git checkout $branch
}

# @doc gdel [branch]: Delete a branch
gdel () {
	_has-params $@ || return

	remote=$(git branch --list $1 --format='%(upstream:short)')
	if [ $remote ]; then
		printf "This branch is tracking the remote '$remote', do you want to delete both of them? [y/n] "
		read choice
		if [[ "$choice" =~ ^[Yy]$ ]]; then
			git branch -d $1
			git push origin --delete $1
		fi
	else
		git branch -d $1
	fi
}

# @doc gu [name] [email]: Set user name and email
gu () {
	_is-git-directory || return
	_has-params $@ || return
	
    git config user.name $1
	git config user.email $2

    echo "User '$(git config user.name)' ($(git config user.email)) set on ${PWD}"
}

file=$(realpath "$0")
# @doc glist: List commands
glist () {
    echo "Git shorthands: 🤘🤘🤘"
    grep -oh '^# @doc.\+' \
        $file |                       # match doc tags
        cut -c 8- |                   # remove the '# @doc ' part
        grep '^[^:]\+' --color=always # color the command name
}

# Check if in a git directory
_is-git-directory () { 
	if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
    	return 0
    else
		echo You are not in a git directory
        return 1
    fi
}

# Check if the are any parameters
_has-params () {
	if [ -n "$1" ]; then
    	return 0
    else
		echo Missing parameter/s
        return 1
    fi
}