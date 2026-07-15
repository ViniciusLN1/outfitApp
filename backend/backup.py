import os
import sqlite3
import tempfile
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import FileResponse

import storage
from auth import current_user

router = APIRouter()

_MAX_BACKUP_BYTES = 200 * 1024 * 1024
_CHUNK = 1024 * 1024


@router.put("/backup")
async def upload_backup(
    file: UploadFile = File(...),
    user: sqlite3.Row = Depends(current_user),
) -> dict[str, str]:
    dest = storage.backup_path(user["id"])
    dest.parent.mkdir(parents=True, exist_ok=True)
    # Grava em temp no mesmo dir e troca atomicamente: um download concorrente
    # nunca vê um zip pela metade.
    fd, tmp_path = tempfile.mkstemp(dir=dest.parent, suffix=".tmp")
    total = 0
    try:
        with os.fdopen(fd, "wb") as out:
            while chunk := await file.read(_CHUNK):
                total += len(chunk)
                if total > _MAX_BACKUP_BYTES:
                    raise HTTPException(status_code=413, detail="Backup too large.")
                out.write(chunk)
        os.replace(tmp_path, dest)
    except BaseException:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise
    finally:
        await file.close()
    return {"uploaded_at": datetime.now(timezone.utc).isoformat()}


@router.get("/backup")
def download_backup(user: sqlite3.Row = Depends(current_user)) -> FileResponse:
    path = storage.backup_path(user["id"])
    if not path.exists():
        raise HTTPException(status_code=404, detail="No backup found.")
    return FileResponse(path, media_type="application/zip", filename="backup.zip")


@router.get("/backup/meta")
def backup_meta(user: sqlite3.Row = Depends(current_user)) -> dict[str, object]:
    path = storage.backup_path(user["id"])
    if not path.exists():
        raise HTTPException(status_code=404, detail="No backup found.")
    stat = path.stat()
    return {
        "uploaded_at": datetime.fromtimestamp(stat.st_mtime, timezone.utc).isoformat(),
        "size_bytes": stat.st_size,
    }
