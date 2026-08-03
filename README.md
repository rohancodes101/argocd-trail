# 🚀 Argo CD & GitOps Lab in GitHub Codespaces

Learn and run **Argo CD** directly inside your web browser using **GitHub Codespaces** and **k3d**. No local installations required—ideal for restricted environments like office laptops.

---

## 🏗️ Architecture Overview

* **GitHub Codespaces:** Cloud Linux environment running in your browser.
* **k3d:** Lightweight K3s Kubernetes cluster running inside Docker.
* **Argo CD:** Deployed on K3s and exposed via Codespaces web proxy.

---

## ⚡ Quick Start

1. Open this repository in **GitHub Codespaces**.
2. Make the setup script executable and run it:
   * Command: `chmod +x setup-argocd.sh`
   * Command: `./setup-argocd.sh`
3. Access the Argo CD Web UI:
   * Open the **Ports** tab in the bottom panel of VS Code.
   * Hover over port **8080** and click **Open in Browser**.
4. Log in with:
   * **Username:** `admin`
   * **Password:** *(Output by the script at the end of execution)*

---

## ⚙️ Key Configuration Details

To run Argo CD smoothly inside GitHub Codespaces, the setup script handles these critical requirements:

* **Server-Side Apply:** Uses `kubectl apply --server-side` to prevent `metadata.annotations` length errors during CRD installation.
* **Insecure HTTP Mode:** Patches `argocd-server` with `--insecure` and forwards port `8080:80` to eliminate SSL/TLS protocol mismatches with the Codespaces web proxy.
* **HTTPS Repositories:** Requires standard `https://` URLs for Git repositories to avoid SSH key authentication errors.

---

## 🛠️ Common Errors & Solutions

* **`PodPending` on Port-Forward:** Argo CD containers are still pulling images. *Fix:* Wait for pod readiness before forwarding.
* **`404 Error` / Protocol Mismatch:** Caused by HTTPS conflicts with the proxy. *Fix:* Ensure Argo CD runs with `--insecure` and routes to container port `80`.
* **`namespaces "mycluster" not found`:** Entered cluster name as the destination. *Fix:* Use `default` as the target namespace in Argo CD.

---

## 📝 License
MIT License
