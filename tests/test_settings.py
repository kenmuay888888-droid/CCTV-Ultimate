from cctv_ultimate.settings import Settings


def test_default_settings_are_valid() -> None:
    settings = Settings()

    assert settings.camera_index == 0
    assert settings.segment_minutes >= 1
    assert settings.retention_days >= 1
    assert settings.jpeg_quality <= 95
