#!/bin/bash -eEu

if [ "${1:-}" ]; then
    # if version argument is passed we use it
    VER="$1"
elif [ "${PYENV_VERSION:-}" ]; then
    # if PYENV_VERSION environmental variable is meaningfully set
    VER="$PYENV_VERSION"
else
    # if the ".pyenv" file exists, use it
    VER="$(cat .pyenv 2>/dev/null || :)"
fi

if [ -z "${VER:-}" ]; then
    VER="master"
fi

PYENV_DIR="$HOME/pyenv"
PYENV_BRANCH_DIR="$HOME/pyenv/$VER"
rm -rf "$PYENV_BRANCH_DIR" || :
mkdir -p "$PYENV_BRANCH_DIR"

curl -L -s -o "$PYENV_DIR/get-pyenv.sh" 'https://raw.githubusercontent.com/cschcs/pyenv-bootstrap/master/get-pyenv.sh' && \
    chmod u+x "$PYENV_DIR/get-pyenv.sh"

ERROR=0
echo "Retrieving PyEnv $VER into '$PYENV_BRANCH_DIR'" >&2
(
  git clone -v 'git://github.com/cschcs/pyenv' "$PYENV_BRANCH_DIR"
  cd "$PYENV_BRANCH_DIR"
  git fetch origin 'refs/pull/*/head:refs/remotes/origin/pr/*'
  git checkout "$VER"
) || ERROR=$?
if [ $ERROR -ne 0 ]; then
    rm -rf "$PYENV_BRANCH_DIR" || :
else
    echo "$PYENV_BRANCH_DIR"
fi
exit $ERROR
