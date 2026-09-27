# opencode go API key for minuet-ai.nvim, from opencode's auth store.
_local_share="${XDG_DATA_HOME:-$HOME/.local/share}"
[[ -f "$_local_share/opencode/auth.json" ]] &&
  export OPENCODE_GO_API_KEY="$(jq -r '.["opencode-go"].key // empty' "$_local_share/opencode/auth.json")"
unset _local_share
