#!/bin/bash

_ni_completion() {
  local GLOBAL_FLAGS="-v --version -h --help -C ? -g --frozen"
  local NPM_REGISTRY_API="https://www.npmjs.com/search/suggestions"

  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD - 1]}"
  if [ "$prev" = "@" ]; then
    cur="@$cur"
    prev="${COMP_WORDS[COMP_CWORD - 2]}"
  fi

  local cmd="${COMP_WORDS[0]}"
  COMPREPLY=()

  _execute_node() {
    local script="$1"
    if [ -f "package.json" ] && command -v node >/dev/null 2>&1; then
      local NODE_CMD="node"
      [[ "$(uname -s)" =~ (MINGW|MSYS|CYGWIN) ]] && NODE_CMD="node.exe"
      "$NODE_CMD" -e "$script"
    fi
  }

  _read_package_json() {
    local script="$1"
    _execute_node "
      try {
        const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
        ${script}
      } catch (e) {}
    "
  }

  _get_package_scripts() {
    _read_package_json "
      const scripts = Object.keys(pkg.scripts || {});
      console.log(scripts.join(' '));
    "
  }

  _get_package_dependencies() {
    _read_package_json "
      const deps = {
        ...(pkg.dependencies || {}),
        ...(pkg.devDependencies || {})
      };
      console.log(Object.keys(deps).join(' '));
    "
  }

  _search_npm_packages() {
    local cur="$1"
    [ -z "$cur" ] || [ ${#cur} -lt 2 ] && return

    if command -v curl >/dev/null 2>&1; then
      local search_result=$(curl -m 10 -s "$NPM_REGISTRY_API?q=$cur&size=30" 2>/dev/null |
        grep -o '"name":"[^"]*"' | \
        cut -d'"' -f4 |
        grep "^$cur" |
        head -n 10)
      COMPREPLY=($(compgen -W "$search_result" -- "$cur"))
    fi
  }

  _complete_directories() {
    local IFS=$'\n'
    COMPREPLY=($(compgen -d -- "$1"))
  }

  if [ "${cur:0:1}" = "-" ]; then
    local flags="$GLOBAL_FLAGS"
    case "$cmd" in
    ni) flags="$flags -i -D" ;;
    nr) flags="$flags -" ;;
    nu) flags="$flags -i" ;;
    nun) flags="$flags -m" ;;
    esac
    COMPREPLY=($(compgen -W "$flags" -- "$cur"))
    return 0
  fi

  case "$prev" in
  "-C")
    _complete_directories "$cur"
    return 0
    ;;
  "-D")
    _search_npm_packages "$cur"
    return 0
    ;;
  esac

  case "$cmd" in
  ni | nlx)
    [ -n "$cur" ] && _search_npm_packages "$cur"
    ;;
  nr)
    local scripts=$(_get_package_scripts)
    COMPREPLY=($(compgen -W "$scripts" -- "$cur"))
    ;;
  nun)
    local deps=$(_get_package_dependencies)
    COMPREPLY=($(compgen -W "$deps" -- "$cur"))
    ;;
  esac

  [ "$cur" = "?" ] && COMPREPLY=("?")

  return 0
}

complete -F _ni_completion ni nr nlx nu nun nci
