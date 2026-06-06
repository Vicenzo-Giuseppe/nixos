{
  lib,
  pkgs,
  user,
  ...
}: let
  stateDir = "/var/lib/build-telemetry";
  logFile = "${stateDir}/notebook-builds.jsonl";
  activeFile = "${stateDir}/active-builds.json";
  lockFile = "${stateDir}/.state.lock";

  telemetryPython = pkgs.writeText "notebook-build-telemetry.py" ''
    import fcntl
    import json
    import os
    import pathlib
    import subprocess
    import sys
    import time


    STATE_DIR = pathlib.Path(${builtins.toJSON stateDir})
    LOG_FILE = pathlib.Path(${builtins.toJSON logFile})
    ACTIVE_FILE = pathlib.Path(${builtins.toJSON activeFile})
    LOCK_FILE = pathlib.Path(${builtins.toJSON lockFile})
    VALUE_FLAGS = {
        "-A": 1,
        "-I": 1,
        "-f": 1,
        "-o": 1,
        "--arg": 2,
        "--arg-from-file": 2,
        "--arg-from-stdin": 1,
        "--argstr": 2,
        "--attr": 1,
        "--builders": 1,
        "--eval-store": 1,
        "--expr": 1,
        "--file": 1,
        "--impure": 0,
        "--inputs-from": 1,
        "--keep-going": 0,
        "--log-format": 1,
        "--max-jobs": 1,
        "--no-link": 0,
        "--offline": 0,
        "--option": 2,
        "--out-link": 1,
        "--override-flake": 2,
        "--override-input": 2,
        "--print-build-logs": 0,
        "--print-out-paths": 0,
        "--profile": 1,
        "--refresh": 0,
        "--repair": 0,
        "--store": 1,
        "--substituters": 1,
        "--system": 1,
        "--verbose": 0,
        "--write-lock-file": 0,
        "-L": 0,
        "-v": 0,
    }
    STORE_VALUE_FLAGS = {
        "--add-root": 1,
        "--cores": 1,
        "--keep-going": 0,
        "--log-format": 1,
        "--max-jobs": 1,
        "--option": 2,
        "--repair": 0,
        "--store": 1,
        "-j": 1,
        "-v": 0,
    }


    def ensure_state() -> None:
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        LOG_FILE.touch(exist_ok=True)
        if not ACTIVE_FILE.exists():
            ACTIVE_FILE.write_text("[]\n", encoding="utf-8")
        LOCK_FILE.touch(exist_ok=True)


    def parse_invocation(argv):
        if len(argv) < 2:
            raise SystemExit("usage: notebook-build-telemetry <start|finish|history|active> ...")

        action = argv[1]
        options = {}
        command = []
        index = 2

        while index < len(argv):
            token = argv[index]
            if token == "--":
                command = argv[index + 1 :]
                break
            if token.startswith("--") and index + 1 < len(argv):
                options[token[2:].replace("-", "_")] = argv[index + 1]
                index += 2
                continue
            raise SystemExit(f"unexpected argument: {token}")

        return action, options, command


    def load_active_entries():
        if not ACTIVE_FILE.exists():
            return []
        try:
            payload = json.loads(ACTIVE_FILE.read_text(encoding="utf-8") or "[]")
        except json.JSONDecodeError:
            return []
        return payload if isinstance(payload, list) else []


    def save_active_entries(entries):
        ACTIVE_FILE.write_text(json.dumps(entries, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")


    def append_history(entry):
        with LOG_FILE.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry, ensure_ascii=True) + "\n")


    def normalize_command(argv):
        if not argv:
            return []
        normalized = list(argv)
        normalized[0] = pathlib.Path(normalized[0]).name
        return normalized


    def command_kind(argv):
        normalized = normalize_command(argv)
        if len(normalized) >= 2 and normalized[0] == "nix" and normalized[1] == "build":
            return "nix-build"
        if normalized and normalized[0] == "nix-store" and any(arg in ("-r", "--realise", "--realize") for arg in normalized[1:]):
            return "nix-store-realise"
        return ""


    def should_track(argv):
        normalized = normalize_command(argv)
        if not normalized:
            return False
        if "--help" in normalized or "-h" in normalized or "--version" in normalized or "--dry-run" in normalized:
            return False
        return command_kind(normalized) != ""


    def git_metadata(cwd):
        git_ref = ""
        git_rev = ""
        probe = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--is-inside-work-tree"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        if probe.returncode != 0:
            return git_ref, git_rev

        ref_proc = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
        )
        rev_proc = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
        )
        if ref_proc.returncode == 0:
            git_ref = (ref_proc.stdout or "").strip()
        if rev_proc.returncode == 0:
            git_rev = (rev_proc.stdout or "").strip()
        return git_ref, git_rev


    def telemetry_repo_for(cwd):
        override = os.environ.get("BUILD_TELEMETRY_REPO", "").strip()
        return override or os.path.basename(cwd.rstrip("/")) or cwd


    def current_source_bytes(cwd):
        try:
            proc = subprocess.run(["du", "-sb", cwd], capture_output=True, text=True)
            if proc.returncode == 0 and proc.stdout.strip():
                return int(proc.stdout.split()[0])
        except (ValueError, OSError):
            pass
        return 0


    def nix_path_metrics(path):
        if not path:
            return 0, 0
        proc = subprocess.run(
            ["nix", "path-info", "--json", "--size", "--closure-size", path],
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0 or not proc.stdout.strip():
            return 0, 0
        try:
            payload = json.loads(proc.stdout)
            info = payload.get(path, {})
            return int(info.get("narSize", 0) or 0), int(info.get("closureSize", 0) or 0)
        except (ValueError, TypeError, json.JSONDecodeError):
            return 0, 0


    def path_exists(path):
        if not path:
            return False
        proc = subprocess.run(["nix", "path-info", path], capture_output=True, text=True)
        return proc.returncode == 0


    def collect_targets(argv, flag_arity):
        targets = []
        index = 0
        while index < len(argv):
            token = argv[index]
            arity = flag_arity.get(token)
            if arity is not None:
                index += 1 + arity
                continue
            if token.startswith("-"):
                index += 1
                continue
            targets.append(token)
            index += 1
        return targets


    def nix_build_outputs(argv, cwd):
        args = []
        for token in argv[2:]:
            if token in ("--json", "--dry-run"):
                continue
            args.append(token)
        proc = subprocess.run(
            ["nix", "build", "--accept-flake-config", "--dry-run", "--json", *args],
            cwd=cwd,
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0 or not proc.stdout.strip():
            return []
        try:
            payload = json.loads(proc.stdout)
        except json.JSONDecodeError:
            return []

        outputs = []
        for row in payload:
            row_outputs = row.get("outputs", {}) if isinstance(row, dict) else {}
            if isinstance(row_outputs, dict):
                outputs.extend(value for value in row_outputs.values() if value)
        return list(dict.fromkeys(outputs))


    def nix_store_outputs(argv):
        outputs = []
        targets = collect_targets(argv[1:], STORE_VALUE_FLAGS)
        for target in targets:
            if target.startswith("/nix/store/") and not target.endswith(".drv"):
                outputs.append(target)
                continue
            if not target.endswith(".drv"):
                continue
            proc = subprocess.run(["nix-store", "--query", "--outputs", target], capture_output=True, text=True)
            if proc.returncode != 0:
                continue
            outputs.extend(line.strip() for line in proc.stdout.splitlines() if line.strip())
        return list(dict.fromkeys(outputs))


    def resolve_outputs(argv, cwd):
        kind = command_kind(argv)
        if kind == "nix-build":
            return nix_build_outputs(argv, cwd)
        if kind == "nix-store-realise":
            return nix_store_outputs(argv)
        return []


    def classify_cache_mode(result, planned_outputs, final_outputs):
        if result != "success":
            return "failed"
        if planned_outputs and all(path_exists(path) for path in planned_outputs):
            return "cache-hit"
        if final_outputs:
            return "rebuilt"
        return "unknown"


    def clear_repo(repo_name):
        repo_name = (repo_name or "").strip()
        if not repo_name:
            return 1

        entries = load_active_entries()
        save_active_entries([row for row in entries if row.get("telemetry_repo") != repo_name])

        if not LOG_FILE.exists():
            return 0

        kept = []
        for line in LOG_FILE.read_text(encoding="utf-8", errors="replace").splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                kept.append(line)
                continue
            if row.get("telemetry_repo") != repo_name:
                kept.append(json.dumps(row, ensure_ascii=True))

        payload = "\n".join(kept)
        if payload:
            payload += "\n"
        LOG_FILE.write_text(payload, encoding="utf-8")
        return 0


    def start_entry(options, command):
        cwd = os.path.realpath(options.get("cwd", os.getcwd()))
        token = options.get("token", f"{int(time.time() * 1000)}-{os.getpid()}")
        normalized = normalize_command(command)
        if not should_track(normalized):
            return 0

        git_ref, git_rev = git_metadata(cwd)
        planned_outputs = resolve_outputs(normalized, cwd)
        entry = {
            "token": token,
            "repo_path": cwd,
            "telemetry_repo": telemetry_repo_for(cwd),
            "git_ref": git_ref,
            "git_rev": git_rev,
            "command": normalized,
            "kind": command_kind(normalized),
            "started_at": int(time.time()),
            "pid": int(options.get("pid", "0") or 0),
            "planned_outputs": planned_outputs,
        }

        entries = [row for row in load_active_entries() if row.get("token") != token]
        entries.append(entry)
        save_active_entries(entries)
        return 0


    def finish_entry(options, command):
        cwd = os.path.realpath(options.get("cwd", os.getcwd()))
        token = options.get("token", "")
        exit_code = int(options.get("exit_code", "0") or 0)
        started_at = int(options.get("start_time", str(int(time.time()))) or int(time.time()))
        normalized = normalize_command(command)
        tracked = should_track(normalized)

        active_entries = load_active_entries()
        active_entry = next((row for row in active_entries if row.get("token") == token), None)
        save_active_entries([row for row in active_entries if row.get("token") != token])

        if not tracked:
            return exit_code

        repo_path = active_entry.get("repo_path", cwd) if active_entry else cwd
        telemetry_repo = active_entry.get("telemetry_repo", telemetry_repo_for(repo_path)) if active_entry else telemetry_repo_for(repo_path)
        git_ref = active_entry.get("git_ref", "") if active_entry else ""
        git_rev = active_entry.get("git_rev", "") if active_entry else ""
        planned_outputs = active_entry.get("planned_outputs", []) if active_entry else []
        if not git_ref and not git_rev:
            git_ref, git_rev = git_metadata(repo_path)

        outputs = resolve_outputs(normalized, repo_path)
        nar_size = 0
        closure_size = 0
        if outputs:
            nar_size, closure_size = nix_path_metrics(outputs[0])

        finished_at = int(time.time())
        duration = max(0, finished_at - started_at)
        entry = {
            "timestamp": finished_at,
            "repo_path": repo_path,
            "telemetry_repo": telemetry_repo,
            "git_ref": git_ref,
            "git_rev": git_rev,
            "result": "success" if exit_code == 0 else "failure",
            "duration_seconds": duration,
            "source_bytes": current_source_bytes(repo_path),
            "nar_size": nar_size,
            "closure_size": closure_size,
            "command": normalized,
            "outputs": outputs,
            "kind": command_kind(normalized),
            "exit_code": exit_code,
            "cache_mode": classify_cache_mode("success" if exit_code == 0 else "failure", planned_outputs, outputs),
        }
        append_history(entry)
        return exit_code


    def main(argv):
        ensure_state()
        action, options, command = parse_invocation(argv)
        with LOCK_FILE.open("r+", encoding="utf-8") as handle:
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
            if action == "start":
                return start_entry(options, command)
            if action == "finish":
                return finish_entry(options, command)
            if action == "history":
                sys.stdout.write(LOG_FILE.read_text(encoding="utf-8", errors="replace"))
                return 0
            if action == "active":
                sys.stdout.write(json.dumps(load_active_entries(), ensure_ascii=True) + "\n")
                return 0
            if action == "clear-repo":
                repo_name = command[0] if command else options.get("repo", "")
                return clear_repo(repo_name)
            raise SystemExit(f"unknown action: {action}")


    if __name__ == "__main__":
        raise SystemExit(main(sys.argv))
  '';

  notebookBuildTelemetry = pkgs.writeShellScriptBin "notebook-build-telemetry" ''
    exec ${pkgs.python3}/bin/python3 ${telemetryPython} "$@"
  '';

  notebookFlakeBuild = pkgs.writeShellScriptBin "notebook-flake-build" ''
    set -euo pipefail

    if [ "$#" -eq 0 ]; then
      echo "usage: notebook-flake-build <flake-target-and-build-args>" >&2
      echo "example: BUILD_TELEMETRY_REPO=spacedrive-main-build notebook-flake-build .#default -L" >&2
      exit 1
    fi

    token="wrapper-$(${pkgs.coreutils}/bin/date +%s%N)-$$"
    start_epoch="$(${pkgs.coreutils}/bin/date +%s)"

    ${lib.getExe notebookBuildTelemetry} start \
      --cwd "$PWD" \
      --token "$token" \
      --pid "$$" \
      -- ${pkgs.nix}/bin/nix build "$@" >/dev/null 2>&1 || true

    set +e
    ${pkgs.nix}/bin/nix build --accept-flake-config "$@"
    status=$?
    set -e

    ${lib.getExe notebookBuildTelemetry} finish \
      --cwd "$PWD" \
      --token "$token" \
      --exit-code "$status" \
      --start-time "$start_epoch" \
      -- ${pkgs.nix}/bin/nix build "$@" >/dev/null 2>&1 || true

    exit "$status"
  '';

  notebookBuildHistory = pkgs.writeShellScriptBin "notebook-build-history" ''
    set -euo pipefail
    exec ${lib.getExe notebookBuildTelemetry} history
  '';

  notebookBuildClear = pkgs.writeShellScriptBin "notebook-build-clear" ''
    set -euo pipefail
    if [ "$#" -ne 1 ]; then
      echo "usage: notebook-build-clear <telemetry-repo>" >&2
      exit 1
    fi
    exec ${lib.getExe notebookBuildTelemetry} clear-repo -- "$1"
  '';
in {
  environment.systemPackages = [
    notebookBuildTelemetry
    notebookFlakeBuild
    notebookBuildHistory
    notebookBuildClear
  ];

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0775 ${user} users -"
    "f ${logFile} 0664 ${user} users -"
    "f ${activeFile} 0664 ${user} users -"
    "f ${lockFile} 0664 ${user} users -"
  ];
}
