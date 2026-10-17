# Work-machine shell configuration (machine.conf: profile=work).

# Artifactory credentials are read from the JFrog CLI config only when a
# command needs them, so the token is not exported into every process.
# Usage: with_artifactstore ./gradlew build
_jfrog_server_field() {
  local conf="${JFROG_CLI_HOME_DIR:-$HOME/.jfrog}/jfrog-cli.conf.v6"
  [[ -r "$conf" ]] || { print -ru2 -- "jfrog: $conf not found (run: jf config add)"; return 1; }
  jq -er --arg id "$1" --arg field "$2" \
    '.servers[] | select(.serverId == $id) | .[$field]' "$conf"
}

with_artifactstore() {
  local user token
  user="$(_jfrog_server_field artifactstore user)" || return
  token="$(_jfrog_server_field artifactstore accessToken)" || return
  ARTIFACTSTORE_USER="$user" ARTIFACTSTORE_TOKEN="$token" "$@"
}
