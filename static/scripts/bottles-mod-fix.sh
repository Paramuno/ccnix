#!/usr/bin/env bash

MODS_ACTIVE=true

handle() {
  if [[ ''${1:0:14} == "activewindow>>" ]]; then
    window_info="''${1:14}"
  else
    return
  fi

  window_lower="''${window_info,,}"

  # UPDATED MATCHING: Catch the steam_proton class or the TouchDesigner title
  if [[ "$window_lower" == *"steam_proton"* ]] || [[ "$window_lower" == *"touchdesigner"* ]]; then

    if [ "$MODS_ACTIVE" = true ]; then
      hyprctl --batch "\
              keyword unbind , Shift_L ;\
              keyword unbind , Control_L ;\
              keyword unbind , Alt_L ;\
              keyword unbind , Super_L"

      echo '0' >/tmp/ags-mod-shift
      echo '0' >/tmp/ags-mod-ctrl
      echo '0' >/tmp/ags-mod-alt
      echo '0' >/tmp/ags-mod-super

      MODS_ACTIVE=false
    fi

  else

    if [ "$MODS_ACTIVE" = false ]; then
      hyprctl --batch "\
              keyword bindin  , Shift_L,   exec, echo '1' > /tmp/ags-mod-shift ;\
              keyword bindrti , Shift_L,   exec, echo '0' > /tmp/ags-mod-shift ;\
              keyword bindin  , Control_L, exec, echo '1' > /tmp/ags-mod-ctrl ;\
              keyword bindrti , Control_L, exec, echo '0' > /tmp/ags-mod-ctrl ;\
              keyword bindin  , Alt_L,     exec, echo '1' > /tmp/ags-mod-alt ;\
              keyword bindrti , Alt_L,     exec, echo '0' > /tmp/ags-mod-alt ;\
              keyword bindin  , Super_L,   exec, echo '1' > /tmp/ags-mod-super ;\
              keyword bindrti , Super_L,   exec, echo '0' > /tmp/ags-mod-super"

      MODS_ACTIVE=true
    fi
  fi
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
