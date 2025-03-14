#!/bin/bash

SITES="lille nancy strasbourg rennes nantes bordeaux lyon toulouse grenoble sophia"
ENVIRONMENTS="mutilate-environment environment environment-caladan"
function retrieve_repo() {
    # this function will get the repo and setup everything needed in precised
    # grid5000 site

    # arg1: grid5000 site
    GRID5000_SITE=$1
    REPO_URL="https://github.com/aaalloc/Grid5000-Dont-throw-the-stack-env"

    if [ -d ~/public/dont-throw-the-stack ]; then
        git -C ~/public/dont-throw-the-stack pull
    else
        git clone $REPO_URL ~/public/dont-throw-the-stack
    fi
    ln -s ~/public/dont-throw-the-stack/environment.yaml environment.yaml
    ln -s ~/public/dont-throw-the-stack/mutilate-environment.yaml mutilate-environment.yaml
    ln -s ~/public/dont-throw-the-stack/environment-caladan.yaml environment-caladan.yaml
}

function build_environment() {
    # this function will build the environment for the host and client nodes

    # arg1: grid5000 site
    GRID5000_SITE=$1
    ENV_NAME=$2

    # TODO: fix hardcoded values of name

    ssh -tt $GRID5000_SITE << EOF
    $(typeset -f retrieve_repo)
    retrieve_repo

    oarsub -I
    kameleon repository add grid5000 https://gitlab.inria.fr/grid5000/environments-recipes.git
    kameleon repository update grid5000
    kameleon template import grid5000/ubuntu2204-x64-common
    kameleon template import grid5000/ubuntu2004-x64-common

    kameleon build $ENV_NAME.yaml
    sed -i 's|server:///path/to/your/image|local:///home/ayanovsk/build/$ENV_NAME/$ENV_NAME.tar.zst|' build/$ENV_NAME/$ENV_NAME.dsc
    exit
EOF
}

ENV_NAME="mutilate-environment"
if [ -z $1 ]; then
    echo "Please provide the grid5000 site"
    exit 1
elif
    [ -z $2 ]; then
    echo "Please provide the environment name"
    exit 1
fi

if [[ $SITES != *"$1"* ]]; then
    echo "Please provide a valid grid5000 site ($SITES)"
    exit 1
fi

if [[ $ENVIRONMENTS != *"$2"* ]]; then
    echo "Please provide a valid environment name ($ENVIRONMENTS)"
    exit 1
fi

GRID5000_SITE=$1
ENV_NAME=$2


build_environment $GRID5000_SITE $ENV_NAME
