#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [[ $(id -u) -eq 0 ]]
then
    >&2 echo "err:  Cannot run ComfyUI container installer as root user, exiting."
    exit 1
fi

if [[ -z "${XDG_CONFIG_HOME}" ]]
then
    XDG_CONFIG_HOME="${HOME}/.config"
    >&2 echo "warn: XDG_CONFIG_HOME not set, using '${XDG_CONFIG_HOME}'"
fi

install -t "${XDG_CONFIG_HOME}/containers/systemd" ./quadlets/*
