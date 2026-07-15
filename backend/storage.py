import hashlib
import hmac
import os
import secrets
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

DATA_DIR = Path(os.environ.get("OUTFIT_DATA_DIR", Path(__file__).parent / "data"))

_SCRYPT_N = 16384
_SCRYPT_R = 8
_SCRYPT_P = 1


def _db_path() -> Path:
    return DATA_DIR / "users.db"


def _connect() -> sqlite3.Connection:
    conn = sqlite3.connect(_db_path())
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with _connect() as conn:
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE COLLATE NOCASE,
                password_hash TEXT NOT NULL,
                created_at TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS tokens (
                token_hash TEXT PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                created_at TEXT NOT NULL
            );
            """
        )


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.scrypt(
        password.encode(), salt=salt, n=_SCRYPT_N, r=_SCRYPT_R, p=_SCRYPT_P
    )
    return f"scrypt${_SCRYPT_N}${_SCRYPT_R}${_SCRYPT_P}${salt.hex()}${digest.hex()}"


def verify_password(password: str, stored: str) -> bool:
    try:
        algo, n, r, p, salt_hex, hash_hex = stored.split("$")
        if algo != "scrypt":
            return False
        digest = hashlib.scrypt(
            password.encode(),
            salt=bytes.fromhex(salt_hex),
            n=int(n),
            r=int(r),
            p=int(p),
        )
        return hmac.compare_digest(digest, bytes.fromhex(hash_hex))
    except (ValueError, TypeError):
        return False


def _token_hash(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def create_user(username: str, password: str) -> int | None:
    """Retorna o id do usuário criado, ou None se o username já existe."""
    try:
        with _connect() as conn:
            cur = conn.execute(
                "INSERT INTO users (username, password_hash, created_at) VALUES (?, ?, ?)",
                (username, hash_password(password), _now()),
            )
            return cur.lastrowid
    except sqlite3.IntegrityError:
        return None


def authenticate(username: str, password: str) -> sqlite3.Row | None:
    with _connect() as conn:
        row = conn.execute(
            "SELECT * FROM users WHERE username = ?", (username,)
        ).fetchone()
    if row is None or not verify_password(password, row["password_hash"]):
        return None
    return row


def create_token(user_id: int) -> str:
    token = secrets.token_urlsafe(32)
    with _connect() as conn:
        conn.execute(
            "INSERT INTO tokens (token_hash, user_id, created_at) VALUES (?, ?, ?)",
            (_token_hash(token), user_id, _now()),
        )
    return token


def user_for_token(token: str) -> sqlite3.Row | None:
    with _connect() as conn:
        return conn.execute(
            """
            SELECT u.* FROM tokens t JOIN users u ON u.id = t.user_id
            WHERE t.token_hash = ?
            """,
            (_token_hash(token),),
        ).fetchone()


def revoke_token(token: str) -> None:
    with _connect() as conn:
        conn.execute("DELETE FROM tokens WHERE token_hash = ?", (_token_hash(token),))


def backup_path(user_id: int) -> Path:
    return DATA_DIR / "backups" / str(user_id) / "backup.zip"
