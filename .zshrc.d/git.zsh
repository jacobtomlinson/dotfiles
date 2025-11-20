function gub () {
	REMOTE=${1:-upstream}
	git fetch $REMOTE
	git remote show $REMOTE | grep "HEAD branch" | sed 's/.*: //'
}


unalias gcm
function gcm () {
       git checkout $(gub $1)
}

unalias glum
function glum () {
	git pull upstream $(gub upstream)
}

alias pr="gh pr checkout"
