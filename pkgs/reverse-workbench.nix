{
  lib,
  buildEnv,
  writeShellApplication,
  ghidra,
  cutter,
  rizin,
  radare2,
  gdb,
  lldb,
  strace,
  ltrace,
  yara,
  binwalk,
  file,
  xxd,
  jq,
  wineWowPackages,
  qemu,
  virt-manager,
  libvirt,
  wireshark,
  tcpdump,
  python3,
  upx,
  patchelf,
  checksec,
  ghex,
}: let
  toolPackages = [
    ghidra
    cutter
    rizin
    radare2
    gdb
    lldb
    strace
    ltrace
    yara
    binwalk
    file
    xxd
    jq
    wineWowPackages.stable
    qemu
    virt-manager
    libvirt
    wireshark
    tcpdump
    python3
    upx
    patchelf
    checksec
    ghex
  ];

  launcher = writeShellApplication {
    name = "reverse-workbench";
    runtimeInputs = toolPackages;
    text = ''
            if [ "$#" -gt 0 ]; then
              exec "$@"
            fi

            cat <<'EOF'
      reverse-workbench

      This bundle provides a reverse-engineering and binary-analysis PATH with tools like:
        ghidraRun  cutter  rizin  radare2  gdb  lldb
        strace  ltrace  yara  binwalk  file  xxd  jq
        wine  qemu-system-x86_64  virt-manager  virsh
        wireshark  tcpdump  python3  upx  patchelf  checksec  ghex

      Examples:
        reverse-workbench ghidraRun
        reverse-workbench cutter
        reverse-workbench rizin -h
        reverse-workbench python3
      EOF
    '';
  };
in
  buildEnv {
    name = "reverse-workbench";
    paths = toolPackages ++ [launcher];
    ignoreCollisions = true;

    meta = with lib; {
      mainProgram = "reverse-workbench";
      description = "Local reverse-engineering and binary-analysis workbench";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  }
