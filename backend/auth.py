import sqlite3

from fastapi import APIRouter, Header, HTTPException
from pydantic import BaseModel, Field

import storage

router = APIRouter(prefix="/auth")


class Credentials(BaseModel):
    username: str = Field(min_length=3, max_length=30)
    password: str = Field(min_length=6, max_length=128)


class SessionResponse(BaseModel):
    token: str
    user_id: int
    username: str


def _bearer_token(authorization: str | None) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token.")
    return authorization.removeprefix("Bearer ").strip()


def current_user(authorization: str | None = Header(default=None)) -> sqlite3.Row:
    user = storage.user_for_token(_bearer_token(authorization))
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid token.")
    return user


@router.post("/register", status_code=201, response_model=SessionResponse)
def register(body: Credentials) -> SessionResponse:
    username = body.username.strip()
    if len(username) < 3:
        raise HTTPException(status_code=422, detail="Invalid username.")
    user_id = storage.create_user(username, body.password)
    if user_id is None:
        raise HTTPException(status_code=409, detail="Username already taken.")
    return SessionResponse(
        token=storage.create_token(user_id), user_id=user_id, username=username
    )


@router.post("/login", response_model=SessionResponse)
def login(body: Credentials) -> SessionResponse:
    user = storage.authenticate(body.username.strip(), body.password)
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid credentials.")
    return SessionResponse(
        token=storage.create_token(user["id"]),
        user_id=user["id"],
        username=user["username"],
    )


@router.post("/logout")
def logout(authorization: str | None = Header(default=None)) -> dict[str, str]:
    storage.revoke_token(_bearer_token(authorization))
    return {"status": "ok"}
