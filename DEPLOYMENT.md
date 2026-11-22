# Deployment & CI/CD Guide

This document covers the end-to-end setup, configuration, and automated deployment pipeline for **capstone-group-webpage** running on AWS EC2 with Gunicorn, Nginx, and GitHub Actions.

---

## 1. Architecture Overview

* **Application:** Python Flask application (`app/app.py`) served via **Gunicorn** over a local Unix socket (`app.sock`).
* **Reverse Proxy:** **Nginx** listening on HTTP port `80` and proxying incoming traffic to Gunicorn.
* **Process Manager:** **systemd** (`flask.service`) managing the Gunicorn worker processes with automatic restart and boot persistence.
* **Infrastructure:** AWS EC2 (Ubuntu Server).
* **CI/CD Pipeline:** **GitHub Actions** (`.github/workflows/ci-cd.yml`) deploying over SSH via `appleboy/ssh-action` and verifying health via `/health`.

---

## 2. AWS EC2 Infrastructure & Security Group

### EC2 Instance
* **AMI:** Ubuntu Server 24.04 LTS
* **Key Pair:** `ec2-key.pem` (stored securely outside the repository with `chmod 400`)

### Security Group Inbound Rules
| Type | Protocol | Port Range | Source | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| SSH | TCP | `22` | `0.0.0.0/0` (or restricted IP) | SSH access for administration and GitHub Actions deployment |
| HTTP | TCP | `80` | `0.0.0.0/0` | Public web access and GitHub Actions `/health` verification |

---

## 3. Server Provisioning & Configuration

### A. Install Dependencies & Clone Repository
```bash
sudo apt update && sudo apt install -y python3-pip python3-venv nginx git
sudo mkdir -p /var/www
sudo chown -R ubuntu:ubuntu /var/www
cd /var/www
git clone [https://github.com/Khay-concept/capstone-group-webpage.git](https://github.com/Khay-concept/capstone-group-webpage.git)
cd capstone-group-webpage