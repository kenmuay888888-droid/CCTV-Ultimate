from __future__ import annotations

import logging
import threading
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

import cv2

from .settings import Settings

LOGGER = logging.getLogger(__name__)


class CameraRecorder:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.recordings_dir = Path(settings.recordings_dir)
        self.recordings_dir.mkdir(parents=True, exist_ok=True)
        self._capture: Optional[cv2.VideoCapture] = None
        self._writer: Optional[cv2.VideoWriter] = None
        self._lock = threading.Lock()
        self._stop_event = threading.Event()
        self._thread: Optional[threading.Thread] = None
        self._latest_jpeg: Optional[bytes] = None
        self._current_file: Optional[Path] = None
        self._started_at: Optional[datetime] = None
        self._last_error: Optional[str] = None

    def start(self) -> None:
        if self._thread and self._thread.is_alive():
            return
        self._stop_event.clear()
        self._thread = threading.Thread(target=self._run, name="camera-recorder", daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread:
            self._thread.join(timeout=5)
        self._release()

    def status(self) -> dict:
        with self._lock:
            latest_frame = self._latest_jpeg is not None
            current_file = str(self._current_file) if self._current_file else None
            last_error = self._last_error
            started_at = self._started_at.isoformat() if self._started_at else None
        return {
            "running": self._thread is not None and self._thread.is_alive(),
            "latest_frame": latest_frame,
            "current_file": current_file,
            "started_at": started_at,
            "last_error": last_error,
        }

    def latest_jpeg(self) -> Optional[bytes]:
        with self._lock:
            return self._latest_jpeg

    def files(self) -> list[dict]:
        items = []
        for path in sorted(self.recordings_dir.glob("*.mp4"), reverse=True):
            stat = path.stat()
            items.append(
                {
                    "name": path.name,
                    "path": str(path),
                    "size_bytes": stat.st_size,
                    "modified_at": datetime.fromtimestamp(stat.st_mtime).isoformat(),
                }
            )
        return items

    def cleanup_old_files(self) -> int:
        cutoff = datetime.now() - timedelta(days=self.settings.retention_days)
        removed = 0
        for path in self.recordings_dir.glob("*.mp4"):
            modified = datetime.fromtimestamp(path.stat().st_mtime)
            if modified < cutoff:
                path.unlink()
                removed += 1
        return removed

    def _run(self) -> None:
        self._started_at = datetime.now()
        try:
            self._capture = cv2.VideoCapture(self.settings.camera_index, cv2.CAP_DSHOW)
            if not self._capture.isOpened():
                self._capture = cv2.VideoCapture(self.settings.camera_index)
            if not self._capture.isOpened():
                raise RuntimeError(f"Cannot open camera index {self.settings.camera_index}")

            self._capture.set(cv2.CAP_PROP_FRAME_WIDTH, self.settings.width)
            self._capture.set(cv2.CAP_PROP_FRAME_HEIGHT, self.settings.height)
            self._capture.set(cv2.CAP_PROP_FPS, self.settings.fps)

            segment_started = 0.0
            cleanup_at = 0.0
            frame_delay = 1 / max(self.settings.fps, 1)

            while not self._stop_event.is_set():
                ok, frame = self._capture.read()
                if not ok:
                    self._set_error("Camera frame read failed")
                    time.sleep(1)
                    continue

                now = time.time()
                if self._writer is None or now - segment_started >= self.settings.segment_minutes * 60:
                    self._rotate_writer(frame)
                    segment_started = now

                self._writer.write(frame)
                self._update_latest_frame(frame)

                if now >= cleanup_at:
                    removed = self.cleanup_old_files()
                    if removed:
                        LOGGER.info("Removed %s old recording(s)", removed)
                    cleanup_at = now + 3600

                time.sleep(frame_delay)
        except Exception as exc:
            self._set_error(str(exc))
            LOGGER.exception("Recorder stopped unexpectedly")
        finally:
            self._release()

    def _rotate_writer(self, frame) -> None:
        if self._writer is not None:
            self._writer.release()

        height, width = frame.shape[:2]
        filename = datetime.now().strftime("%Y%m%d-%H%M%S.mp4")
        path = self.recordings_dir / filename
        fourcc = cv2.VideoWriter_fourcc(*"mp4v")
        self._writer = cv2.VideoWriter(str(path), fourcc, self.settings.fps, (width, height))
        if not self._writer.isOpened():
            raise RuntimeError(f"Cannot create recording file {path}")

        with self._lock:
            self._current_file = path

    def _update_latest_frame(self, frame) -> None:
        encode_params = [int(cv2.IMWRITE_JPEG_QUALITY), self.settings.jpeg_quality]
        ok, buffer = cv2.imencode(".jpg", frame, encode_params)
        if ok:
            with self._lock:
                self._latest_jpeg = buffer.tobytes()
                self._last_error = None

    def _set_error(self, message: str) -> None:
        with self._lock:
            self._last_error = message

    def _release(self) -> None:
        if self._writer is not None:
            self._writer.release()
            self._writer = None
        if self._capture is not None:
            self._capture.release()
            self._capture = None
