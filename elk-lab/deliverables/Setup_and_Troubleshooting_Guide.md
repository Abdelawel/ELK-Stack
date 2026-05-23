# ELK Stack Lab - Setup & Deliverables Guide

## 1. Validated Configurations
All four required configuration files have been corrected, validated, and are perfectly set up for the Hub and Windows nodes:
* `docker-compose.yml` (Includes Elasticsearch, Logstash, Kibana, Checkout-service, and the critical Filebeat container)
* `logstash.conf` (Filters two pipelines accurately to their respective indices)
* `filebeat.yml` (Dynamically tracks the Hub's checkout-service Docker logs)
* `winlogbeat.yml` (Hooks into Windows channel to track Security events 4624 & 4625)

---

## 2. Automated Setup Workflow (Vagrant)

To accurately spin up the environment with zero manual interaction:

1. **Start the Environment:**
   Run the following from the `elk-lab` directory:
   ```bash
   vagrant up hub windows
   ```
2. **Trigger the Telemetry:**
   Wait for the Windows VM to be fully booted, then trigger the logon scripts from your host terminal:
   ```bash
   vagrant ssh windows -c "powershell -ExecutionPolicy Bypass -File C:\vagrant\windows-vm\trigger_events.ps1"
   ```

---

## 3. Known Issues & Troubleshooting

During testing, we encountered standard hurdles that SREs often face. If you reproduce this lab, ensure you watch for these:

### Problem 1: Kibana/Elasticsearch Web UI Not Loading (`http://192.168.56.10:5601`)
* **Cause**: Docker Compose takes several minutes to download the large 8.13.0 ELK images and allocate the JVM memory. If you try to open the browser immediately after `vagrant up`, the connection will be refused.
* **Solution**: Ensure the VMs are working and wait for Docker to finish. You can verify it by SSHing into the hub and checking the container states. They must state `Up (healthy)`:
  ```bash
  vagrant ssh hub
  sudo docker compose -f /vagrant/hub-vm/docker-compose.yml ps
  ```

### Problem 2: "No Results Found" or Missing `4624` Events in Kibana
* **Cause A**: Kibana defaults to the "Last 15 minutes" time filter. If you spun up your VM an hour ago, the logs won't show.
  * *Fix*: Change the Kibana time filter (top right) to **Today** or **Last 24 hours**.
* **Cause B**: When building the visualization table, including the `FailureReason` field causes Kibana to drop all Success (`4624`) logs, as successful logins do not have a failure reason.
  * *Fix*: Build a Kibana Data Table referencing **only** `event_id.keyword` as the Row. Remove `FailureReason`.

---

## 4. Final Deliverable Checklist

Extract the following to create your Final "Audit Package" (.zip or Word Document):

**A. Visual Proof**
* Screenshot of a Kibana Lens Table showing counts for `event_id` 4624 and 4625 (Timeframe adjusted to "Today").

**B. Configuration Code**
* Copy the contents of `docker-compose.yml`
* Copy the contents of `logstash.conf`
* Copy the contents of `filebeat.yml`
* Copy the contents of `winlogbeat.yml`

**C. Raw Telemetry**
* The generated `sample_windows_events.txt` file (exported from Windows Event Viewer).

**D. System Interaction Map**
* Complete Section 8 of the Answer Sheet detailing the telemetry flow (Winlogbeat -> Logstash -> Elasticsearch; and Checkout-Service STDOUT -> Filebeat -> Logstash -> Elasticsearch).
