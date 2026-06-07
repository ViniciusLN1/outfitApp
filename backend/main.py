from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import Response
from PIL import Image
from rembg import remove
import io

app = FastAPI(title="OutfitApp Background Removal API")


@app.post("/remove-background")
async def remove_background(file: UploadFile = File(...)) -> Response:
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")
    contents = await file.read()
    input_image = Image.open(io.BytesIO(contents))
    output_image = remove(input_image)
    buf = io.BytesIO()
    output_image.save(buf, format="PNG")
    return Response(content=buf.getvalue(), media_type="image/png")


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
