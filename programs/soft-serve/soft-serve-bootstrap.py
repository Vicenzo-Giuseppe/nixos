#!/usr/bin/env python3
import os
import sqlite3
import sys


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        print(f"missing environment variable: {name}", file=sys.stderr)
        sys.exit(1)
    return value


def upsert_user(cur, username: str, is_admin: bool) -> int:
    cur.execute("select id from users where username=?", (username,))
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute(
        "insert into users (username, admin, password, created_at, updated_at) "
        "values (?, ?, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
        (username, 1 if is_admin else 0),
    )
    return cur.lastrowid


def ensure_key(cur, user_id: int, key: str) -> None:
    cur.execute("select id, user_id from public_keys where public_key=?", (key,))
    row = cur.fetchone()
    if row:
        if row[1] != user_id:
            cur.execute(
                "update public_keys set user_id=?, updated_at=CURRENT_TIMESTAMP where id=?",
                (user_id, row[0]),
            )
        return
    cur.execute(
        "insert into public_keys (user_id, public_key, created_at, updated_at) "
        "values (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
        (user_id, key),
    )


def main() -> int:
    db_path = os.environ.get(
        "SOFT_SERVE_DB_PATH", "/var/lib/soft-serve/soft-serve.db"
    )
    admin_user = require_env("SOFT_SERVE_ADMIN_USER")
    admin_key = require_env("SOFT_SERVE_ADMIN_KEY").strip()
    local_user = require_env("SOFT_SERVE_LOCAL_USER")
    local_key = require_env("SOFT_SERVE_LOCAL_KEY").strip()

    conn = sqlite3.connect(db_path)
    try:
        cur = conn.cursor()
        admin_id = upsert_user(cur, admin_user, True)
        ensure_key(cur, admin_id, admin_key)
        local_id = upsert_user(cur, local_user, False)
        ensure_key(cur, local_id, local_key)
        conn.commit()
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
