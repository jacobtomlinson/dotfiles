# Set git email based on username
if [ "$(whoami)" = "jacob" ]; then
    email="jacob@tomlinson.email"
elif [ "$(whoami)" = "jtomlinson" ]; then
    email="jtomlinson@nvidia.com"
fi

if [ -n "$email" ]; then
    sed -i.bak "s/^\([[:space:]]*email[[:space:]]*=[[:space:]]*\).*/\1$email/" ~/.gitconfig
fi


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
