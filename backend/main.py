from contextlib import asynccontextmanager

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import Response
from rembg import new_session, remove

import auth
import backup
import storage

_session = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    storage.init_db()
    # Carrega o modelo ONNX (U2NET) uma única vez; recarregar por request
    # custa segundos e centenas de MB de alocação repetida.
    global _session
    _session = new_session("u2net")
    yield
    _session = None


app = FastAPI(title="OutfitApp API", lifespan=lifespan)
app.include_router(auth.router)
app.include_router(backup.router)


@app.post("/remove-background")
async def remove_background(file: UploadFile = File(...)) -> Response:
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")
    try:
        contents = await file.read()
    finally:
        await file.close()
    try:
        # Inferência é CPU-bound: roda no threadpool para não bloquear o
        # event loop. Entrada/saída em bytes evita re-encode PIL manual.
        output = await run_in_threadpool(remove, contents, session=_session)
    except Exception:
        raise HTTPException(status_code=500, detail="Background removal failed.")
    finally:
        del contents
    return Response(content=output, media_type="image/png")


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
