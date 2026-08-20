# Background private mode

เอกสารนี้นิยามโหมดใช้งานจริงสำหรับเครื่องของเจ้าของระบบเอง เช่น laptop, Windows mini PC หรือ WPC mini PC ที่ต่อ USB webcam

คำว่า background/private mode ในโปรเจกต์นี้หมายถึง:

- รันเบื้องหลังโดยไม่ต้องเปิดหน้าต่าง PowerShell ค้าง
- เริ่มเองหลังเปิดเครื่อง
- restart เองถ้า service หรือ process ล้ม
- ดู live และ playback ผ่าน Tailscale VPN เท่านั้น
- ไม่เปิด port ออก public internet
- มี username/password และให้เครื่องของเจ้าของจำ login ได้
- เก็บวิดีโอย้อนหลัง 24 ชั่วโมง แล้วลบอัตโนมัติ
- มี log ให้เจ้าของเครื่องตรวจสอบได้

ไม่ใช่การซ่อนจากเจ้าของเครื่อง, ปิด privacy indicator, bypass permission, หรือหลบระบบความปลอดภัยของ Windows

## สถาปัตยกรรมแนะนำ

```text
USB webcam / laptop camera
        |
        v
Agent DVR service
        |
        +--> recording retention 24h
        +--> web UI with password
        |
        v
Tailscale private IP 100.x.y.z
        |
        v
Phone browser
```

## ค่าแนะนำ

| ส่วน | ค่าแนะนำ |
| --- | --- |
| Recording mode | Motion Detect สำหรับประหยัดพื้นที่ หรือ Continuous ถ้าต้องการครบทุกช่วง |
| Retention | 24 hours |
| Resolution เริ่มต้น | 1280x720 |
| FPS | 10-15 |
| Audio | ปิดก่อน ใช้เฉพาะเมื่อจำเป็นและถูกกฎหมาย |
| Public port forwarding | ไม่ใช้ |
| Remote access | Tailscale เท่านั้น |

## ขั้นตอนที่ลดลงที่สุด

1. ติดตั้ง Agent DVR บน Windows
2. เปิด `http://localhost:8090`
3. เพิ่มกล้องแบบ Local Device
4. ตั้ง username/password
5. login จากมือถือเจ้าของเครื่อง แล้วให้ browser หรือ session ของ Agent DVR จำการ login
6. ตั้ง recording และ retention 24 hours
7. ติดตั้ง Tailscale บน Windows และมือถือ
8. เปิดจากมือถือด้วย `http://100.x.y.z:8090`
9. ตั้ง Agent DVR ให้ start with Windows หรือใช้ service/task ที่ installer มีให้
10. ตั้ง watchdog เฉพาะกรณีพบว่า Agent DVR ไม่กลับมาเองหลัง reboot/crash

## Password แบบไม่ถามซ้ำ

แนวทางที่ถูกต้องคือจำ login บนอุปกรณ์ที่เจ้าของควบคุม ไม่ใช่ปิด authentication

ตัวเลือกที่ควรใช้:

- ใช้ browser password manager บนมือถือเจ้าของเครื่อง
- ใช้ remember/session option ของ Agent DVR ถ้ามีในหน้าล็อกอินหรือ security settings
- ใช้ Home Screen shortcut หลังจาก login แล้ว
- ใช้ Tailscale เพื่อจำกัดคนที่เข้าถึง URL ได้ตั้งแต่ระดับ network

ไม่ควรทำ:

- ปิด username/password
- ใช้ password ว่าง
- ฝัง password ไว้ใน URL
- เปิด port public เพื่อความสะดวก

## Watchdog ที่เหมาะสม

ควรใช้ watchdog แบบโปร่งใส:

- ตรวจว่า Agent DVR ยังทำงานอยู่
- ตรวจว่า port 8090 listen อยู่
- เขียน log ลง `C:\CCTV\Logs`
- restart Agent DVR เมื่อไม่ทำงาน
- ไม่ซ่อน process และไม่ลบ log

งานนี้สามารถทำด้วย Windows Task Scheduler ให้รันทุก 5 นาที

## Firewall

ไม่ควรเปิด inbound แบบ public profile

แนวทางแนะนำ:

- ไม่ทำ router port forwarding
- ไม่ expose port 8090 ไป internet
- อนุญาตเฉพาะ private/VPN ที่จำเป็น
- ถ้าใช้ Tailscale IP เปิดดูได้อยู่แล้ว ให้หลีกเลี่ยงการเปิด LAN กว้างเกินจำเป็น

## Checklist ใช้งานจริง

- [ ] Windows Camera app เห็นภาพจากกล้อง
- [ ] Agent DVR live view เห็นภาพจริง
- [ ] ตั้ง username/password แล้ว
- [ ] มือถือเจ้าของเครื่องจำ login ได้ และไม่ถามซ้ำทุกครั้ง
- [ ] recording ทำงานและ playback ได้
- [ ] retention ตั้งไว้ 24 hours
- [ ] Tailscale PC และมือถืออยู่ tailnet เดียวกัน
- [ ] มือถือเปิด `http://100.x.y.z:8090` ได้
- [ ] ไม่มี router port forwarding ไปยังเครื่อง CCTV
- [ ] reboot แล้ว Agent DVR กลับมาทำงานเอง
- [ ] มี log สำหรับตรวจสอบปัญหา

## สิ่งที่ควรทำต่อใน repo

- เพิ่มคู่มือ Agent DVR quick setup ภาษาไทย
- เพิ่ม PowerShell health check สำหรับ owner
- เพิ่ม optional watchdog script
- เพิ่ม firewall checklist สำหรับ Tailscale-only
- เก็บ Python MVP เป็น fallback ไม่ใช่แนวทางหลัก
