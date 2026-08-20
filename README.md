# CCTV-Ultimate

CCTV Ultimate Personal Edition คือระบบ Private CCTV สำหรับ Windows ที่เปลี่ยน Laptop หรือ Desktop ให้เป็นกล้องวงจรปิดส่วนตัว พร้อมบันทึกวิดีโอ ดู Live ผ่านเว็บ และลบไฟล์เก่าอัตโนมัติตามเวลาที่กำหนด

## สถานะปัจจุบัน

เวอร์ชันนี้เป็น MVP ที่ใช้งานได้จริงแล้วในรูปแบบ Python app:

- เปิดกล้องจาก built-in webcam หรือ USB webcam
- บันทึกวิดีโอเป็นไฟล์ `.mp4` แยกตามช่วงเวลา
- ดูภาพสดผ่านเว็บเบราว์เซอร์
- ดูสถานะกล้องและรายการไฟล์ย้อนหลังผ่าน API
- ลบไฟล์เก่าอัตโนมัติตาม `retention_days`

## วิธีติดตั้งบน Windows

ต้องมี Python 3.11, 3.12 หรือ 3.13

> ตอนนี้ยังไม่แนะนำ Python 3.14 เพราะ dependency ด้านกล้องและวิดีโอบางตัวอาจยังไม่มี wheel สำเร็จรูปบน Windows

```powershell
git clone https://github.com/kenmuay888888-droid/CCTV-Ultimate.git
cd CCTV-Ultimate
.\run.ps1
```

จากนั้นเปิด:

```text
http://localhost:8080
```

ถ้าจะดูผ่านโทรศัพท์ ให้เชื่อมเครื่อง Windows และโทรศัพท์เข้ากับ Tailscale เดียวกัน แล้วเปิด:

```text
http://<tailscale-ip>:8080
```

## การตั้งค่า

ครั้งแรกที่รัน ระบบจะคัดลอก `config.example.json` เป็น `config.json`

ค่าที่ปรับได้:

- `camera_index`: หมายเลขกล้อง เริ่มจาก `0`
- `port`: port เว็บ
- `recordings_dir`: โฟลเดอร์เก็บวิดีโอ
- `segment_minutes`: ความยาวไฟล์วิดีโอแต่ละช่วง
- `retention_days`: จำนวนวันที่เก็บไฟล์ย้อนหลัง
- `fps`, `width`, `height`: คุณภาพวิดีโอ

## API

```text
GET /              หน้าเว็บดูภาพสด
GET /snapshot.jpg  ภาพล่าสุดจากกล้อง
GET /api/status    สถานะระบบ
GET /api/files     รายการไฟล์ย้อนหลัง
```

## แผนถัดไป

- Windows Service
- installer
- authentication สำหรับหน้าเว็บ
- ดาวน์โหลด/เล่นไฟล์ย้อนหลังจากหน้าเว็บ
- hardware detection แบบละเอียด
- logging และ health check ที่ครบขึ้น
