#!/bin/zsh

COMP_FILE="./.ni.zsh"
failures=0
TEST_DIR=""

typeset -A colors=(
  green  $'\033[32m'
  red    $'\033[31m'
  blue   $'\033[34m'
  bold   $'\033[1m'
  reset  $'\033[0m'
)

print_message() {
  local color=$1 message=$2
  print -P "${colors[$color]}$message${colors[reset]}"
}

setup_test_environment() {
  TEST_DIR=$(mktemp -d) || { print_message red "Failed to create temp dir" && exit 1; }

  cat > "$TEST_DIR/package.json" <<EOF
{
  "name": "test-package",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "test": "vitest"
  },
  "dependencies": {
    "vue": "^3.0.0",
    "vite": "^4.0.0"
  },
  "devDependencies": {
    "vitest": "^0.30.0"
  }
}
EOF

  mkdir -p "$TEST_DIR/test-dir"
  cd "$TEST_DIR" || exit 1
}

test_completion() {
  local cmd=$1 word=$2 expected=$3 desc=$4
  local -a words
  words=(${(z)cmd})

  local OLD_PWD=$PWD

  cd "$TEST_DIR"

  if [[ "$word" = "-C" ]]; then
    words+=("$word" "")
    CURRENT=$#words
    PREFIX=""
  else
    words+=("$word")
    CURRENT=$#words
    PREFIX="$word"
  fi

  SUFFIX=""
  IPREFIX=""
  ISUFFIX=""

  local curcontext="$cmd:${CURRENT}:" context state state_descr line
  typeset -A opt_args

  local -a completions=()

  compadd() {
    local opt array
    array=()

    while (( $# > 0 )); do
      case "$1" in
        -Q)
          shift ;;
        -a)
          shift
          eval "array=(\${$1[@]})"
          shift
          ;;
        *)
          [[ "$1" = "$PREFIX"* ]] && array+=("$1")
          shift
          ;;
      esac
    done

    completions+=("${array[@]}")
  }

  _path_files() {
    [[ "$1" = "-/" ]] && compadd -Q - "${(@)$(echo *(/))}"
  }

  _ni

  cd "$OLD_PWD"

  local result="${(j: :)completions}"
  if [[ "$result" = *"$expected"* ]]; then
    print_message green "✓ $desc"
    return 0
  else
    print_message red "✗ $desc"
    print_message blue "Expected: '$expected'"
    print_message red "Got:      '$result'"
    return 1
  fi
}

run_tests() {
  test_completion "ni" "-" "-v --version -h --help -C -g --frozen -i -D" "ni flags" || ((failures++))
  test_completion "ni" "vue" "vue vue-router vue-eslint-parser vue-loader vue-i18n vue-demi vue-multiselect vue-select vue-bundle-renderer vue-tippy" "ni package name" || ((failures++))
  test_completion "ni" "@types/" "@types/node @types/lodash @types/jest @types/uuid @types/prop-types @types/react @types/qs @types/estree @types/express @types/unist" "ni package name with @" || ((failures++))
  test_completion "nr" "-" "-v --version -h --help -C -g --frozen -" "nr flags" || ((failures++))
  test_completion "nr" "b" "build" "nr script completion" || ((failures++))
  test_completion "nr" "t" "test" "nr script partial completion" || ((failures++))
  test_completion "nlx" "-" "-v --version -h --help -C -g --frozen" "nlx flags" || ((failures++))
  test_completion "nlx" "vite" "vite vite-node vite-tsconfig-paths vite-plugin-dts vitest vite-plugin-istanbul vite-plugin-static-copy vite-plugin-inspect vite-plugin-svgr vite-imagetools" "nlx package completion" || ((failures++))
  test_completion "nu" "-" "-v --version -h --help -C -g --frozen -i" "nu flags" || ((failures++))
  test_completion "nun" "-" "-v --version -h --help -C -g --frozen -m" "nun flags" || ((failures++))
  test_completion "nun" "v" "vue vite vitest" "nun dependencies" || ((failures++))
  test_completion "nci" "-" "-v --version -h --help -C -g --frozen" "nci flags" || ((failures++))
  test_completion "ni" "-C" "test-dir" "directory completion" || ((failures++))
}

main() {
  [[ ! -f "$COMP_FILE" ]] && print_message red "Error: $COMP_FILE not found" && exit 1
  source "$COMP_FILE"

  setup_test_environment
  print_message bold "Running completion tests..."
  run_tests

  print
  print_message bold "Tests completed!"

  if (( failures == 0 )); then
    print_message green "All tests passed!"
    exit 0
  else
    print_message red "$failures test(s) failed!"
    exit 1
  fi

  rm -rf "$TEST_DIR"
}

main "$@"
