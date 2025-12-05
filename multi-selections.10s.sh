#!/usr/bin/env bash

# Path to displayplacer
DISPLAYPLACER="/opt/homebrew/bin/displayplacer"

# Use SwiftBar's plugin path if available
PLUGIN_PATH="${SWIFTBAR_PLUGIN_PATH:-$0}"

# --------------------------------------------------------------------
# 1) Paste your exact displayplacer commands here
#    Replace ONLY the parts inside the quotes after the = signs.
# --------------------------------------------------------------------

CMD_1512_NOTCHLESS='/opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1512x945 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"'
CMD_1512_NOTCH='/opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1512x982 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"'

CMD_1800_NOTCHLESS='/opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1125 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"'
CMD_1800_NOTCH='/opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"'

# --------------------------------------------------------------------
# Helper: detect current resolution of the built-in display
# --------------------------------------------------------------------

CURRENT_RES=$("$DISPLAYPLACER" list | awk '
  /^displayplacer/ {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^res:/) {
        gsub("res:", "", $i)
        print $i
        exit
      }
    }
  }
')

ACTION="$1"
TARGET_RES="$2"

# --------------------------------------------------------------------
# Actions
# --------------------------------------------------------------------

# Left-click on the icon: toggle notch <-> notchless in the current "family"
if [ "$ACTION" = "toggle" ]; then
  case "$CURRENT_RES" in
    1512x945)   eval "$CMD_1512_NOTCH" ;;
    1512x982)   eval "$CMD_1512_NOTCHLESS" ;;
    1800x1125)  eval "$CMD_1800_NOTCH" ;;
    1800x1169)  eval "$CMD_1800_NOTCHLESS" ;;
    *)          eval "$CMD_1512_NOTCHLESS" ;;  # fallback
  esac
  exit 0
fi

# Dropdown items: set a specific resolution
if [ "$ACTION" = "set" ] && [ -n "$TARGET_RES" ]; then
  case "$TARGET_RES" in
    1512x945)   eval "$CMD_1512_NOTCHLESS" ;;
    1512x982)   eval "$CMD_1512_NOTCH" ;;
    1800x1125)  eval "$CMD_1800_NOTCHLESS" ;;
    1800x1169)  eval "$CMD_1800_NOTCH" ;;
  esac
  exit 0
fi

# --------------------------------------------------------------------
# Menu bar icon (header)
#   - single emoji only
#   - clicking it toggles notch/notchless
# --------------------------------------------------------------------

# You can customize these emojis if you want
case "$CURRENT_RES" in
  1512x945|1800x1125) ICON="🎮" ;;  # "notchless" modes
  1512x982|1800x1169) ICON="🖥" ;;  # "notch" modes
  *)                  ICON="❓" ;;
esac

# Header line: the icon in the menu bar
echo "$ICON | bash=\"$PLUGIN_PATH\" param1=toggle terminal=false refresh=true"

# Separator between header and dropdown body
echo "---"

# --------------------------------------------------------------------
# Dropdown: individual resolutions with checkmarks
# --------------------------------------------------------------------
# These help you have other resolutions to easily switch to.

# Helper to output one menu item
menu_item() {
  local title="$1"
  local res="$2"
  local notch_label="$3"

  local checked=""
  if [ "$CURRENT_RES" = "$res" ]; then
    checked="checked=true"
  fi

  echo "$title ($notch_label) | bash=\"$PLUGIN_PATH\" param1=set param2=$res terminal=false refresh=true $checked"
}

menu_item "1512 x 945"  "1512x945"  "notchless"
menu_item "1512 x 982"  "1512x982"  "notch"
echo "---"
menu_item "1800 x 1125" "1800x1125" "notchless"
menu_item "1800 x 1169" "1800x1169" "notch"
