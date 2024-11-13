#compdef _ni ni nr nlx nu nun nci

_ni() {
  local GLOBAL_FLAGS="-v --version -h --help -C ? -g --frozen"
  local NPM_REGISTRY_API="https://www.npmjs.com/search/suggestions"

  local curcontext="$curcontext" state line ret=1
  local cur="${words[CURRENT]}"
  local prev="${words[CURRENT-1]}"
  local cmd="${words[1]}"

  if [[ "$prev" == "@" ]]; then
    cur="@$cur"
    prev="${words[CURRENT-2]}"
  fi

  _execute_node() {
    local script="$1"
    if [[ -f "package.json" ]] && (( $+commands[node] )); then
      node -e "$script" 2>/dev/null
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
      console.log(Object.keys(pkg.scripts || {}).join(' '));
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
    [[ -z "$cur" || ${#cur} -lt 2 ]] && return

    if (( $+commands[curl] )); then
      local packages=(${(f)"$(curl -m 5 -s "$NPM_REGISTRY_API?q=$cur&size=30" 2>/dev/null | \
        grep -o '"name":"[^"]*"' | \
        cut -d'"' -f4 | \
        grep "^$cur" | \
        head -n 10)"})
      [[ -n "$packages" ]] && compadd -Q -a packages
    fi
  }

  if [[ "$cur" = -* ]]; then
    local flags="$GLOBAL_FLAGS"
    case "$cmd" in
    ni)  flags="$flags -i -D" ;;
    nr)  flags="$flags -" ;;
    nu)  flags="$flags -i" ;;
    nun) flags="$flags -m" ;;
    esac
    compadd -Q - ${=flags}
    return 0
  fi

  case "$prev" in
    "-C") _path_files -/ ;;
    "-D") _search_npm_packages "$cur" ;;
    *)
      case "$cmd" in
        ni | nlx)
          [[ -n "$cur" ]] && _search_npm_packages "$cur"
          ;;
        nr)
          local scripts=($(_get_package_scripts))
          compadd -Q -a scripts
          ;;
        nun)
          local deps=($(_get_package_dependencies))
          compadd -Q -a deps
          ;;
      esac
      ;;
  esac

  [[ "$cur" = "?" ]] && compadd -Q "?"

  return 0
}

compdef _ni ni nr nlx nu nun nci