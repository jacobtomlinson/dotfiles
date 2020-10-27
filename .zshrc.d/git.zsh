function gdb () {
	REMOTE=${1:-upstream}
	git fetch $REMOTE
	git remote show $REMOTE | grep "HEAD branch" | sed 's/.*: //'
}


unalias gcm
function gcm () {
       git checkout $(gdb $1)
}

unalias glum
function glum () {
	git pull upstream $(gdb upstream)
}
