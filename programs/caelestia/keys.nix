let
  shift = "Shift";
  super = "SUPER";
  superShift = "${super}+${shift}";
  mkSuperShift = key: action: "${superShift}, ${key}, ${action}";
in {
  bindi = [
    "${super}, SUPER_L, global, caelestia:launcher"
  ];

  bind = [
    "Ctrl+Alt, Delete, global, caelestia:session"
    "${super}, K, global, caelestia:showall"
    "${super}, L, global, caelestia:lock"
    "${super}, S, exec, caelestia toggle specialws"
    "Ctrl+Shift, Escape, exec, caelestia toggle sysmon"
    "${super}, M, exec, caelestia toggle music"
    "${super}, D, exec, caelestia toggle communication"
    "${super}, R, exec, caelestia toggle todo"
    (mkSuperShift "S" "global, caelestia:screenshotFreeze")
    "${superShift}+Alt, S, global, caelestia:screenshot"
    "${super}, V, exec, pkill fuzzel || caelestia clipboard"
    "${super}+Alt, V, exec, pkill fuzzel || caelestia clipboard -d"
    "${super}, Period, exec, pkill fuzzel || caelestia emoji -p"
  ];

  bindl = [
    "Ctrl+Alt, C, global, caelestia:clearNotifs"
    "${super}+Alt, L, global, caelestia:lock"
    "${super}+Alt, L, exec, caelestia shell -d"
    ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
    ", XF86MonBrightnessDown, global, caelestia:brightnessDown"
    "Ctrl+${super}, Space, global, caelestia:mediaToggle"
    ", XF86AudioPlay, global, caelestia:mediaToggle"
    ", XF86AudioPause, global, caelestia:mediaToggle"
    ", XF86AudioStop, global, caelestia:mediaStop"
    "Ctrl+${super}, Equal, global, caelestia:mediaNext"
    ", XF86AudioNext, global, caelestia:mediaNext"
    "Ctrl+${super}, Minus, global, caelestia:mediaPrev"
    ", XF86AudioPrev, global, caelestia:mediaPrev"
    ", Print, exec, caelestia screenshot"
    "${super}+Alt, R, exec, caelestia record -s"
    "Ctrl+Alt, R, exec, caelestia record"
    "${superShift}+Alt, R, exec, caelestia record -r"
  ];

  bindr = [
    "Ctrl+${super}+${shift}, R, exec, qs -c caelestia kill"
    "Ctrl+${super}+Alt, R, exec, qs -c caelestia kill; sleep .1; caelestia shell -d"
  ];

  "exec-once" = [
    "caelestia shell -d"
  ];
}
