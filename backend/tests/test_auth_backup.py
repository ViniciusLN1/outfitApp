import io
import sys
import zipfile
from pathlib import Path

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).parent.parent))


@pytest.fixture()
def client(tmp_path, monkeypatch):
    import storage

    monkeypatch.setattr(storage, "DATA_DIR", tmp_path)
    storage.init_db()

    import auth
    import backup

    app = FastAPI()
    app.include_router(auth.router)
    app.include_router(backup.router)
    return TestClient(app)


def _register(client, username="vini", password="secret1"):
    return client.post(
        "/auth/register", json={"username": username, "password": password}
    )


def test_register_login_roundtrip(client):
    res = _register(client)
    assert res.status_code == 201
    body = res.json()
    assert body["username"] == "vini"
    assert body["token"]

    res = client.post("/auth/login", json={"username": "vini", "password": "secret1"})
    assert res.status_code == 200
    assert res.json()["user_id"] == body["user_id"]


def test_register_duplicate_409(client):
    assert _register(client).status_code == 201
    assert _register(client).status_code == 409
    assert _register(client, username="VINI").status_code == 409


def test_login_wrong_password_401(client):
    _register(client)
    res = client.post("/auth/login", json={"username": "vini", "password": "wrong99"})
    assert res.status_code == 401


def test_validation_422(client):
    assert _register(client, username="ab").status_code == 422
    assert _register(client, password="123").status_code == 422


def test_protected_routes_require_token(client):
    assert client.get("/backup").status_code == 401
    assert client.get("/backup/meta").status_code == 401
    assert (
        client.get("/backup", headers={"Authorization": "Bearer bogus"}).status_code
        == 401
    )


def test_logout_revokes_token(client):
    token = _register(client).json()["token"]
    headers = {"Authorization": f"Bearer {token}"}
    assert client.post("/auth/logout", headers=headers).status_code == 200
    assert client.get("/backup", headers=headers).status_code == 401


def _zip_bytes():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        zf.writestr("outfit.db", b"fake-db")
        zf.writestr("clothing/a.png", b"fake-png")
    return buf.getvalue()


def test_backup_upload_meta_download(client):
    token = _register(client).json()["token"]
    headers = {"Authorization": f"Bearer {token}"}

    assert client.get("/backup", headers=headers).status_code == 404
    assert client.get("/backup/meta", headers=headers).status_code == 404

    data = _zip_bytes()
    res = client.put(
        "/backup",
        headers=headers,
        files={"file": ("backup.zip", data, "application/zip")},
    )
    assert res.status_code == 200
    assert res.json()["uploaded_at"]

    meta = client.get("/backup/meta", headers=headers)
    assert meta.status_code == 200
    assert meta.json()["size_bytes"] == len(data)

    down = client.get("/backup", headers=headers)
    assert down.status_code == 200
    assert down.content == data


def test_backup_isolated_per_user(client):
    t1 = _register(client, username="user1").json()["token"]
    t2 = _register(client, username="user2").json()["token"]
    client.put(
        "/backup",
        headers={"Authorization": f"Bearer {t1}"},
        files={"file": ("backup.zip", _zip_bytes(), "application/zip")},
    )
    assert (
        client.get("/backup", headers={"Authorization": f"Bearer {t2}"}).status_code
        == 404
    )
