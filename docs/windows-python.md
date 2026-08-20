# ติดตั้ง Python สำหรับ Windows

โปรเจกต์นี้แนะนำ Python 3.11, 3.12 หรือ 3.13

## วิธีติดตั้ง

1. ดาวน์โหลด Python จาก https://www.python.org/downloads/windows/
2. เลือกเวอร์ชัน 3.11, 3.12 หรือ 3.13
3. ตอนติดตั้ง ให้เลือก `Add python.exe to PATH`
4. เปิด PowerShell ใหม่ แล้วตรวจสอบ:

```powershell
py -3 --version
```

ถ้าเครื่องมี Python 3.14 เป็นค่าเริ่มต้น ให้ติดตั้ง Python 3.13 เพิ่ม แล้วแก้ `run.ps1` ให้ใช้:

```powershell
py -3.13 -m venv .venv
```
