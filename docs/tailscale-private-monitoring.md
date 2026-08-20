# Private monitoring ผ่าน Tailscale

เป้าหมายของ CCTV Ultimate คือให้เครื่อง Windows เป็น local CCTV server ส่วนตัว แล้วดูจากมือถือผ่าน Tailscale VPN เท่านั้น ไม่ใช่เว็บสาธารณะ

## หลักการ

- ไม่ต้องเปิด port router
- ไม่ต้องใช้ public IP
- ไม่ต้องทำ dynamic DNS
- ไม่ควรตั้ง firewall ให้เปิดรับจาก public network
- อุปกรณ์ที่จะดูภาพต้องอยู่ใน Tailscale network เดียวกัน

## ตั้งค่า Windows server

1. ติดตั้งและ login Tailscale บนเครื่อง Windows
2. ดู Tailscale IP:

```powershell
tailscale ip -4
```

3. แก้ `config.json`:

```json
{
  "camera_index": 0,
  "host": "100.x.y.z",
  "port": 8080,
  "recordings_dir": "recordings",
  "segment_minutes": 5,
  "retention_days": 7,
  "fps": 15,
  "width": 1280,
  "height": 720,
  "jpeg_quality": 80
}
```

ให้แทน `100.x.y.z` ด้วย Tailscale IP จริงของเครื่อง Windows

4. รัน server:

```powershell
.\.venv\Scripts\python.exe -m cctv_ultimate
```

## เปิดดูจากโทรศัพท์

1. ติดตั้งและ login Tailscale บนโทรศัพท์
2. ใช้บัญชีหรือ tailnet เดียวกับเครื่อง Windows
3. เปิด browser:

```text
http://100.x.y.z:8080
```

## Firewall

ถ้า Windows Firewall ถาม ให้เลือกเฉพาะ private network ก่อน

ถ้าต้องการจำกัดให้แน่นขึ้น ให้ allow เฉพาะ network/interface ของ Tailscale และไม่เปิด inbound จาก public network

## หมายเหตุด้านความปลอดภัย

MVP เวอร์ชันนี้ยังไม่มีระบบ login ในหน้าเว็บ เพราะสมมติว่าเข้าถึงผ่าน Tailscale private network เท่านั้น งานถัดไปควรเพิ่ม authentication เพื่อกันกรณีเครื่องหรือ tailnet มีผู้ใช้อื่นร่วมอยู่
