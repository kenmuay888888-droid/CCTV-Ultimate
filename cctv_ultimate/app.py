from __future__ import annotations

import logging
from pathlib import Path

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, Response

from .recorder import CameraRecorder
from .settings import load_settings

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")

settings = load_settings()
recorder = CameraRecorder(settings)
app = FastAPI(title="CCTV Ultimate", version="0.1.0")


@app.on_event("startup")
def startup() -> None:
    recorder.start()


@app.on_event("shutdown")
def shutdown() -> None:
    recorder.stop()


@app.get("/", response_class=HTMLResponse)
def index() -> str:
    return """
<!doctype html>
<html lang="th">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CCTV Ultimate</title>
  <style>
    :root { color-scheme: dark; font-family: Arial, sans-serif; }
    body { margin: 0; background: #111827; color: #f9fafb; }
    header { padding: 16px 20px; background: #0f172a; border-bottom: 1px solid #334155; }
    h1 { margin: 0; font-size: 22px; }
    main { display: grid; gap: 16px; padding: 16px; max-width: 1120px; margin: 0 auto; }
    img { width: 100%; background: #020617; border: 1px solid #334155; border-radius: 6px; }
    section { background: #1f2937; border: 1px solid #374151; border-radius: 6px; padding: 14px; }
    pre { white-space: pre-wrap; overflow-wrap: anywhere; }
    a { color: #60a5fa; }
  </style>
</head>
<body>
  <header><h1>CCTV Ultimate</h1></header>
  <main>
    <img id="live" src="/snapshot.jpg" alt="Live camera">
    <section>
      <h2>สถานะ</h2>
      <pre id="status">loading...</pre>
    </section>
    <section>
      <h2>ไฟล์ย้อนหลัง</h2>
      <pre id="files">loading...</pre>
    </section>
  </main>
  <script>
    const live = document.getElementById("live");
    const statusBox = document.getElementById("status");
    const filesBox = document.getElementById("files");

    setInterval(() => {
      live.src = "/snapshot.jpg?ts=" + Date.now();
    }, 1000);

    async function refresh() {
      const status = await fetch("/api/status").then(r => r.json());
      const files = await fetch("/api/files").then(r => r.json());
      statusBox.textContent = JSON.stringify(status, null, 2);
      filesBox.textContent = JSON.stringify(files, null, 2);
    }

    refresh();
    setInterval(refresh, 5000);
  </script>
</body>
</html>
"""


@app.get("/snapshot.jpg")
def snapshot() -> Response:
    image = recorder.latest_jpeg()
    if image is None:
        raise HTTPException(status_code=503, detail="No camera frame available yet")
    return Response(content=image, media_type="image/jpeg")


@app.get("/api/status")
def status() -> dict:
    return recorder.status()


@app.get("/api/files")
def files() -> list[dict]:
    return recorder.files()


@app.get("/recordings/{filename}")
def recording(filename: str) -> Response:
    path = Path(settings.recordings_dir) / filename
    if not path.exists() or path.suffix.lower() != ".mp4":
        raise HTTPException(status_code=404, detail="Recording not found")
    return Response(content=path.read_bytes(), media_type="video/mp4")


def main() -> None:
    uvicorn.run(app, host=settings.host, port=settings.port)
