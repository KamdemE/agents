# Architecture Blueprint: Phoenix V4.0 (Distributed K3s Homelab & Sovereign AI Agent Identity)

## Context & Vision
This document synthesizes the architectural end-state for KpihX's hardware layout (Ubuntu PC, Homelab server, future M4 Mac Studio). The goal is zero-trust, highly portable, visual, and highly-available agentic automation.

## Phase 1: Sovereign Digital Identity (The Agent's "Self")
**Objective:** Decouple the AI agent from your personal credentials (preventing "Shadow IT") and give it verifiable communication channels to interact with the external world autonomously.

1. **Email Provisioning (M2M):** 
   - Utilize Cloudflare Email Routing for your domain (`agent@kpihx-labs.com`).
   - Forward inbound mail to a dedicated webhook on your existing `n8n` homelab instance. The agent queries this webhook to retrieve OTPs and magic links instantly, avoiding complex IMAP server setups.
2. **Phone identity (Voice/SMS):**
   - Provision a virtual number via **Twilio** or **Telnyx**.
   - Use the `n8n` platform (or a direct Python script) as an API bridge for the agent to simulate a mobile device (receiving SMS for account creation verifications).
3. **Secret Management:**
   - Create an isolated "Agent Vault" in your Homelab Vaultwarden instance. Assign a programmatic API token so the agent fetches and stores all newly generated passwords autonomously.

## Phase 2: The Visual Sandbox (The Agent's "Body")
**Objective:** Move beyond restrictive CLI/`curl` scraping. Provide a full, isolated Ubuntu Desktop environment where the agent can build tools, run browsers, and be observed by you in real-time.

1. **Deploy Kasm WebTop:** Use the `linuxserver/webtop` Docker image. This provides a full Ubuntu XFCE/KDE desktop streamed via HTML5/WebSockets directly to your web browser (e.g., `agent.kpihx-labs.com`).
2. **Visual Observation:** You open the browser URL to literally "watch" the agent move the mouse, open terminals, and run `git clone` or UI testing scripts in real time.
3. **Hybrid Web Automation:** The agent is instructed to use rapid HTTP APIs (`curl`/Python requests) for static data, but it launches a Headless Browser (Playwright/Puppeteer) via an MCP tool *inside* the Kasm WebTop when dealing with complex JavaScript or CAPTCHAs.

## Phase 3: Zero-Trust Networking & DNS Agnosticism
**Objective:** Ensure the environment is securely isolated and completely portable between the Ubuntu PC (Dev) and the Mac Studio (Prod) without changing a single line of infrastructure code.

1. **Tailscale Sidecar Isolation:** 
   - The Kasm WebTop container is stripped of standard host networking. It is attached to a `tailscale/tailscale` sidecar container (`network_mode: service:tailscale_sidecar`).
   - You drop the agent's connection into the `tag:ai-agent` Tailscale ACL, strictly explicitly permitting it to ping only designated assets (e.g., `kpihx-ubuntu:22`) and blocking access to the rest of your local LAN.
2. **Agnostic Routing (`.env` Injection):** 
   - Traefik labels in `docker-compose` never hardcode URLs. They use: ``Host(`${APP_NAME}.${DOMAIN_SUFFIX}`)``.
3. **Cloudflare "Grey Cloud" VPN DNS:** 
   - In Cloudflare, map your Tailsale IPs (e.g., `100.82.95.70`) to subdomains (e.g., `*.dev.kpihx-labs.com`).
   - Set the Proxy status to **"DNS Only" (Grey Cloud)**. This elegantly resolves the DNS over the public internet, but the actual traffic routes entirely over your secure, private Tailscale mesh.

## Phase 4: High Availability Cluster (K3s End-State)
**Objective:** Unify your hardware (Mac Studio, Ubuntu PC, Homelab Server) into a single distributed supercomputer with failover tolerance and seamless cross-architecture orchestration.

1. **Cluster Initialization (K3s):** 
   - Replace standard Docker Compose with **K3s** (a lightweight, single-binary Kubernetes optimized for Homelabs/Edge).
   - Homelab Server acts as the `Master/Control Plane`. Mac Studio and Ubuntu act as `Worker Nodes`. All communication happens natively over their `100.x` Tailscale interfaces.
2. **Node Delegation:** 
   - Apply labels to your physical hardware. 
   - `homelab=core-services` (Vaultwarden, Traefik, Pi-hole).
   - `mac=heavy-compute` (LLMs, Agent WebTop Sandbox, massive compilers).
   - `ubuntu=dev-burst`.
3. **True Failover & Distributed Storage (Longhorn):**
   - Deploy **Longhorn** on the K3s cluster. It acts as a distributed block-storage network. As the agent writes files inside its sandbox on the Mac Studio, Longhorn instantly clones the data to the Homelab disk over Tailscale.
   - If the Mac Studio loses power, K3s instantly reschedules the container onto the Homelab, attaches the cloned storage volume, and Traefik reroutes the ingress domain. Zero data loss, zero manual downtime.

## Phase 5: Portable AI Stack (The "Remote Field Operator")
**Objective:** Extend the sovereignty and utility of the AI agents beyond your personal hardware, allowing them to troubleshoot, maintain, or repair third-party environments (e.g., a friend's or client's PC) securely and on demand.

1. **Physical "Live USB" Portability:**
   - Package a lightweight version of the agent ecosystem (Tailscale + K3s worker node + basic LLM API config) onto a bootable USB key.
   - Booting a host PC from this key instantly joins it to your Tailscale mesh as an ephemeral, isolated node. The agent can then diagnose the attached hardware, perform disk repairs, or analyze logs autonomously, all communicating back to your central Homelab brain.
2. **"Agent-as-a-Service" Public URL:**
   - Expose a highly restricted, Traefik-proxied public URL (e.g., `operator.kpihx-labs.com`).
   - When repairing a client's computer, you visit this URL, authenticate, and the agent initiates an MCP-based WebRTC or SSH connection directly to the target machine via a reverse tunnel (like Cloudflare Tunnel).
   - This allows the agent to execute maintenance scripts, install software, or resolve system configs on the client's PC while the heavy AI compute remains securely locked in your Homelab/Mac Studio.
