Chapter 5 — SRE Lab: ELK Stack Files
=====================================

FOLDER STRUCTURE
----------------
elk-lab/
├── docker-compose.yml              ← run this on the Hub machine
├── filebeat.yml                    ← copy to Linux Node A
├── winlogbeat.yml                  ← copy to Windows Node B
├── README.txt                      ← this file
└── logstash/
    ├── config/
    │   └── logstash.yml            ← Logstash settings (mounted by Docker)
    └── pipeline/
        └── logstash.conf           ← Grok filters + routing (mounted by Docker)


STEP 1 — HUB MACHINE (P2 — Docker Engineer)
--------------------------------------------
1. Install Docker Desktop (https://docs.docker.com/get-docker/)
2. Open a terminal in the elk-lab/ folder
3. Run:
     docker-compose up -d
4. Wait ~2 minutes, then verify:
     Elasticsearch → http://localhost:9200   (should return JSON)
     Kibana        → http://localhost:5601   (should load the UI)

Useful commands:
  docker-compose logs -f logstash      ← watch Logstash process events live
  docker-compose logs -f elasticsearch ← check ES startup
  docker-compose down                  ← stop everything
  docker-compose down -v               ← stop and delete all data


STEP 2 — LINUX NODE A (P3 — Linux Engineer)
--------------------------------------------
1. Note the Hub machine IP address (run `ip addr` on Hub or check Docker host IP)
2. Edit filebeat.yml — replace <HUB_IP> with that IP
3. On the Linux VM:
     sudo apt update && sudo apt install nginx -y
     curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.13.0-amd64.deb
     sudo dpkg -i filebeat-8.13.0-amd64.deb
     sudo cp filebeat.yml /etc/filebeat/filebeat.yml
     sudo systemctl enable filebeat && sudo systemctl start filebeat
4. Generate traffic:
     for i in {1..40}; do curl http://localhost/; curl http://localhost/notfound; done
5. Extract sample log:
     sudo tail -50 /var/log/nginx/access.log > sample_nginx.log
6. Send sample_nginx.log to P2 immediately so they can test the Grok filter


STEP 3 — WINDOWS NODE B (P4 — Windows Engineer)
-------------------------------------------------
1. Note the Hub machine IP address
2. Edit winlogbeat.yml — replace <HUB_IP> with that IP
3. Trigger Event ID 4625 (failed logon):
     runas /user:FakeUser cmd   ← enter wrong password 5-10 times
4. Trigger Event ID 4624 (successful logon):
     Log out and log back in normally
5. Download Winlogbeat 8.13.0 from https://www.elastic.co/downloads/beats/winlogbeat
6. Extract to C:\Program Files\Winlogbeat
7. Copy winlogbeat.yml into C:\Program Files\Winlogbeat\
8. Open PowerShell as Administrator:
     cd "C:\Program Files\Winlogbeat"
     .\winlogbeat.exe install-service
     Start-Service winlogbeat
9. Export events:
     Event Viewer → Windows Logs → Security
     Filter for 4624 and 4625
     Right-click → Save Filtered Log File As → sample_windows_events.txt


STEP 4 — KIBANA DASHBOARD (P2 — Docker Engineer)
-------------------------------------------------
1. Open http://localhost:5601
2. Menu → Stack Management → Index Patterns
3. Create: nginx-logs-*        (timestamp field: @timestamp)
4. Create: windows-security-*  (timestamp field: @timestamp)
5. Menu → Dashboard → Create new dashboard
6. Add Lens visualization:
     Type: Bar chart
     Index: nginx-logs-*
     X-axis: http_status_code
     Y-axis: Count
     Title: HTTP 200 vs 404
7. Add Data Table visualization:
     Index: windows-security-*
     Columns: event_id, account_name, source_ip, @timestamp
     Title: Windows Security Events
8. Take a screenshot showing BOTH visualizations with real data


FILES TO SUBMIT (P1 assembles and submits via Google Form)
----------------------------------------------------------
  docker-compose.yml
  logstash.conf
  filebeat.yml
  winlogbeat.yml
  sample_nginx.log          (from P3)
  sample_windows_events.txt (from P4)
  kibana_screenshot.png     (from P2)
  Chapter5_Answer_Sheet.docx
