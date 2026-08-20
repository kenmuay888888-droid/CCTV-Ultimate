# CCTV-Ultimate

CCTV Ultimate Personal Edition คือระบบ Private CCTV สำหรับ Windows ที่เปลี่ยน Laptop หรือ Desktop ให้เป็นกล้องวงจรปิดส่วนตัว พร้อมบันทึกวิดีโอ ดู Live ผ่านเว็บผ่าน Tailscale VPN และลบไฟล์เก่าอัตโนมัติตามเวลาที่กำหนด

## สถานะปัจจุบัน

เวอร์ชันนี้เป็น MVP ที่ใช้งานได้จริงแล้วในรูปแบบ Python app:

- เปิดกล้องจาก built-in webcam หรือ USB webcam
- บันทึกวิดีโอเป็นไฟล์ `.mp4` แยกตามช่วงเวลา
- ดูภาพสดผ่านเว็บเบราว์เซอร์
- ดูสถานะกล้องและรายการไฟล์ย้อนหลังผ่าน API
- ลบไฟล์เก่าอัตโนมัติตาม `retention_days`
- ออกแบบสำหรับใช้งานแบบ private ผ่าน Tailscale ไม่ต้องเปิด port สาธารณะ

## แนวทางแนะนำสำหรับใช้งานจริง

สำหรับเป้าหมาย laptop / mini PC / USB webcam / ดูจากมือถือ / ฟรี / เก็บย้อนหลัง 24 ชั่วโมง แนวทางหลักที่แนะนำคือ:

```text
Agent DVR + Tailscale + Background Mode
```

เหตุผลคือ Agent DVR มี live view, recording, playback, retention และ password ในตัว ทำให้ลดขั้นตอนและลดความเสี่ยงจากการเขียน recorder เอง

เริ่มจากคู่มือสั้นที่สุด: `docs/quick-start-agent-dvr-tailscale.md`

ดูแผน background/private mode ที่ `docs/background-private-mode.md`

## สิ่งที่ repo นี้มีให้สำหรับ Agent DVR

- `scripts/Test-CCTVPrereqs.ps1`: ตรวจ Agent DVR, port 8090, Tailscale และข้อมูลที่ต้องเช็กด้วยตนเอง
- `scripts/Install-CCTVFirewall.ps1`: เพิ่ม firewall rule สำหรับ private profile เท่านั้น
- `scripts/Health-Check-AgentDVR.ps1`: ตรวจ process, port, Tailscale และพื้นที่ดิสก์ พร้อม log
- `scripts/Watch-AgentDVR.ps1`: watchdog restart Agent DVR เมื่อ process หรือ port ไม่พร้อม
- `scripts/Install-BackgroundTasks.ps1`: ลงทะเบียน watchdog และ health check ใน Task Scheduler

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

## ใช้งานผ่าน Tailscale VPN

ระบบนี้ไม่จำเป็นต้องเปิด port router, ไม่ต้องทำ port forwarding และไม่ควร expose ออก public internet

ถ้าจะดูผ่านโทรศัพท์ ให้เชื่อมเครื่อง Windows และโทรศัพท์เข้ากับ Tailscale เดียวกัน แล้วหา Tailscale IP ของเครื่อง Windows:

```powershell
tailscale ip -4
```

จากนั้นแก้ `config.json` ให้ `host` เป็น Tailscale IP นั้น เช่น:

```json
{
  "host": "100.x.y.z",
  "port": 8080
}
```

แล้วเปิดจากโทรศัพท์:

```text
http://<tailscale-ip>:8080
```

ดูรายละเอียดเพิ่มที่ `docs/tailscale-private-monitoring.md`

## การตั้งค่า

ครั้งแรกที่รัน ระบบจะคัดลอก `config.example.json` เป็น `config.json`

ค่าที่ปรับได้:

- `camera_index`: หมายเลขกล้อง เริ่มจาก `0`
- `host`: IP ที่ server จะรับการเชื่อมต่อ ใช้ `127.0.0.1` สำหรับเครื่องตัวเอง หรือ Tailscale IP สำหรับ VPN-only
- `port`: port เว็บ ค่าเริ่มต้นคือ `8080`
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
