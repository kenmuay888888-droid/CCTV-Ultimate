# Quick start: Agent DVR + Tailscale

คู่มือนี้คือเส้นทางใช้งานจริงที่สั้นที่สุดสำหรับ laptop, Windows mini PC หรือ WPC mini PC ที่มีกล้องในตัวหรือ USB webcam

## เป้าหมาย

- ดู live จากโทรศัพท์ผ่าน Tailscale VPN
- ไม่เปิด public internet
- บันทึกวิดีโอและลบภายใน 24 ชั่วโมง
- รันเบื้องหลังหลังเปิดเครื่อง
- ใช้เครื่องและพื้นที่ที่คุณมีสิทธิ์ดูแลเท่านั้น

## 1. เช็กกล้อง

เปิด Windows Camera app ก่อน ต้องเห็นภาพจริงจากกล้อง

ถ้าไม่เห็น ให้เปิด:

```text
Windows Settings > Privacy & security > Camera
```

เปิด:

```text
Camera access
Let apps access your camera
Let desktop apps access your camera
```

ปิดโปรแกรมที่ใช้กล้องอยู่ เช่น Zoom, Teams, OBS, LINE หรือ browser tab ที่เปิดกล้อง

## 2. ติดตั้ง Agent DVR

ดาวน์โหลดจาก:

```text
https://www.ispyconnect.com/download.aspx
```

หลังติดตั้ง เปิด:

```text
http://localhost:8090
```

เพิ่มกล้อง:

```text
Server menu > Add Device > Local Device
```

ค่าเริ่มต้นที่แนะนำ:

```text
Resolution: 1280x720 หรือ 640x480 ถ้าเครื่องช้า
FPS: 10-15
Audio: Off ก่อน
```

ตั้ง username/password ทันทีใน Agent DVR security settings

## 3. ตั้ง recording 24 ชั่วโมง

ใน Agent DVR:

```text
Camera settings > Recording
```

เลือกอย่างใดอย่างหนึ่ง:

```text
Motion Detect: ประหยัดพื้นที่
Continuous: บันทึกครบทุกช่วง
```

ใน storage/retention:

```text
Delete files older than: 24 hours
```

## 4. ติดตั้ง Tailscale

ติดตั้งบน Windows และโทรศัพท์:

```text
https://tailscale.com/download
```

ใช้บัญชีเดียวกันหรือ tailnet เดียวกัน

บน Windows เปิด PowerShell:

```powershell
tailscale ip -4
```

จะได้ IP เช่น:

```text
100.x.y.z
```

จากโทรศัพท์ที่เปิด Tailscale แล้ว เปิด:

```text
http://100.x.y.z:8090
```

## 5. เปิด firewall เฉพาะ private profile

เปิด PowerShell แบบ Administrator ที่โฟลเดอร์โปรเจกต์ แล้วรัน:

```powershell
.\scripts\Install-CCTVFirewall.ps1
```

อย่าทำ router port forwarding

## 6. ติดตั้ง background tasks

ใช้เมื่อต้องการ watchdog และ health log:

```powershell
.\scripts\Install-BackgroundTasks.ps1
```

ตรวจ log:

```powershell
Get-Content C:\CCTV\Logs\health.log -Tail 20
Get-Content C:\CCTV\Logs\watchdog.log -Tail 20
```

## 7. ตรวจระบบ

รัน:

```powershell
.\scripts\Test-CCTVPrereqs.ps1
.\scripts\Health-Check-AgentDVR.ps1
```

ต้องผ่าน:

- Agent DVR เปิดที่ `localhost:8090`
- มือถือเปิดผ่าน Tailscale IP ได้
- ตั้ง password แล้ว
- recording/playback ทำงาน
- retention 24 hours

## หมายเหตุ

ถ้า Agent DVR เปิดภาพจากกล้องได้แล้ว ไม่จำเป็นต้องใช้ Python MVP ใน repo นี้ Python MVP เป็น fallback สำหรับทดลองเท่านั้น
