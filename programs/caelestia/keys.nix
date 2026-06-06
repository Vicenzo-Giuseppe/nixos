let
  shift = "Shift";
  super = "SUPER";
  superCtrl = "${super}+Ctrl";
  superAlt = "${super}+Alt";
  superShift = "${super}+${shift}";
in {
  bindi = [
    "${super}, SUPER_L, global, caelestia:launcher"
  ];

  bind = [
    "Ctrl+Alt, Delete, global, caelestia:session"
    "Ctrl, Space, global, caelestia:launcher"
    "${super}, E, exec, warp-oss"
    "${superAlt}, K, global, caelestia:showall"
    "${superAlt}, L, global, caelestia:lock"
    "${superAlt}, S, exec, caelestia toggle specialws"
    "Ctrl+Shift, Escape, exec, caelestia toggle sysmon"
    "${superAlt}, M, exec, caelestia toggle music"
    "${superAlt}, D, exec, caelestia toggle communication"
    "${superAlt}, T, exec, caelestia toggle todo"
    "Ctrl+${superShift}, S, global, caelestia:screenshotFreeze"
    "Ctrl+${superShift}+Alt, S, global, caelestia:screenshot"
    "${super}, V, exec, pkill fuzzel || caelestia clipboard"
    "${super}+Alt, V, exec, pkill fuzzel || caelestia clipboard -d"
    "${super}, Period, exec, pkill fuzzel || caelestia emoji -p"
  ];

  bindl = [
    "${superAlt}, X, global, caelestia:clearNotifs"
    "${superAlt}, Return, exec, caelestia shell -d"
    ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
    ", XF86MonBrightnessDown, global, caelestia:brightnessDown"
    "${superCtrl}, Space, global, caelestia:mediaToggle"
    ", XF86AudioPlay, global, caelestia:mediaToggle"
    ", XF86AudioPause, global, caelestia:mediaToggle"
    ", XF86AudioStop, global, caelestia:mediaStop"
    "${superCtrl}, Equal, global, caelestia:mediaNext"
    ", XF86AudioNext, global, caelestia:mediaNext"
    "${superCtrl}, Minus, global, caelestia:mediaPrev"
    ", XF86AudioPrev, global, caelestia:mediaPrev"
    ", Print, exec, caelestia screenshot"
    "${super}+Alt, R, exec, caelestia record -s"
    "Ctrl+Alt, R, exec, caelestia record"
    "${superShift}+Alt, R, exec, caelestia record -r"
  ];

  bindr = [
    "Ctrl+${superShift}, R, exec, qs -c caelestia kill"
    "Ctrl+${superAlt}, R, exec, qs -c caelestia kill; sleep .1; caelestia shell -d"
  ];

  "exec-once" = [
    "caelestia shell -d"
  ];
}
