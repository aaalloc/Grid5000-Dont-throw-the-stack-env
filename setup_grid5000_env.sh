#!/bin/bash


function retrieve_repo() {
    # this function will get the repo and setup everything needed in precised
    # grid5000 site

    # arg1: grid5000 site
    GRID5000_SITE=$1
    REPO_URL="https://github.com/aaalloc/Grid5000-Dont-throw-the-stack-env"

    cd public
    git clone $REPO_URL dont-throw-the-stack
    cd ~
    ln -s public/dont-throw-the-stack/environment.yaml environment.yaml
    ln -s public/dont-throw-the-stack/mutilate-environment.yaml mutilate-environment.yaml
}

function build_environment() {
    # this function will build the environment for the host and client nodes

    # arg1: grid5000 site
    GRID5000_SITE=$1
    ENV_PATH=$2

    ssh $GRID5000_SITE << EOF
    $(typeset -f)
    retrieve_repo

    oarsub -l host=1,walltime=1 "
        kameleon repository add grid5000 https://gitlab.inria.fr/grid5000/environments-recipes.git
        kameleon repository update grid5000
        kameleon template import grid5000/ubuntu2204-x64-common

        kameleon build $ENV_PATH
    "
EOF
}

ENV_PATH="mutilate-environment.yaml"
GRID5000_SITE="grenoble"

build_environment $GRID5000_SITE $ENV_PATH