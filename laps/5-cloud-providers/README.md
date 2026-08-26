# Cloud Providers Lab — Vultr

The hands-on companion to [D5.cloud-providers.md](../../D5.cloud-providers.md),
built around the lesson's own section 38, *"Your First Vultr Lab"*.

Unlike every earlier lab in this repo, **this one creates real infrastructure
on a real cloud account and it costs real money.** A `vc2-1c-1gb` instance is
roughly **$5/month, billed by the hour**, so an afternoon of practice costs a
few cents — but only if you remember to destroy it.

> **The whole lab is `./01` through `./06`, then `./99-destroy.sh`.**
> Nothing stops billing except that last script.

## What you build

```text
   your laptop
        |
        |  Vultr API v2  (curl + jq)
        v
   +---------------------------------------------+
   |  Vultr                                      |
   |                                             |
   |   cloud firewall  -- allow 22, 80, 443      |
   |          |           drop everything else   |
   |          v                                  |
   |   Ubuntu 24.04 VM   public IP               |
   |          |                                  |
   |          +-- UFW          (second layer)    |
   |          +-- Docker + Compose               |
   |          +-- deploy user                    |
   |               |                             |
   |               v                             |
   |          nginx container  :80               |
   +---------------------------------------------+
        ^
        |  ssh / scp / http
   your laptop
```

Everything above is created by API call. The VM is never touched by hand: a
cloud-init file does the `apt upgrade`, the Docker install, and the UFW rules
on first boot.

## Prerequisites

- A Vultr account with a payment method
- An API key from <https://my.vultr.com/settings/#settingsapi>
- **Your current public IP added to the API allow-list on that same page.**
  Vultr rejects API calls from unlisted addresses with `403`. If your ISP
  changes your IP, you have to add the new one — this is the single most
  common reason these scripts fail on a first run.
- An SSH key pair (`ssh-keygen -t ed25519` if you do not have one)
- `curl`, `jq`, `ssh`, `scp`, `base64` — all present in Git Bash on Windows

## Setup

```bash
cp .env.example .env
```

Then edit `.env` and paste your API key. `.env` and `state/` are gitignored;
**never commit either.** The key in `.env` can create and destroy servers on
your account, so treat it exactly like a password.

Defaults worth knowing:

| Setting | Default | Why |
|---|---|---|
| `VULTR_REGION` | `sgp` | Singapore — the closest Vultr region to Cambodia (lesson 7) |
| `VULTR_PLAN` | `vc2-1c-1gb` | The smallest general-purpose plan |
| `VULTR_OS_NAME` | `Ubuntu 24.04 LTS x64` | Resolved to a numeric `os_id` at runtime, never hard-coded |

## The scripts

| Script | Does | Costs |
|---|---|---|
| `01-check.sh` | Validates the key, lists regions and plans with prices, resolves the OS id | free, creates nothing |
| `02-create-firewall.sh` | Creates a cloud firewall allowing only 22, 80, 443 | free |
| `03-create-instance.sh` | Uploads your SSH key, renders cloud-init, creates the VM | **starts billing** |
| `04-status.sh` | Polls until the VM boots, SSH answers, and cloud-init finishes | free |
| `05-deploy.sh` | Copies `app/` up and runs `docker compose up -d` | free |
| `06-verify.sh` | Checks the deployment from the outside, including blocked ports | free |
| `99-destroy.sh` | Deletes the VM, the firewall, optionally the SSH key | **stops billing** |

Run them in order:

```bash
./01-check.sh
./02-create-firewall.sh
./03-create-instance.sh     # asks for confirmation and shows the monthly cost
./04-status.sh              # 2-4 minutes
./05-deploy.sh
./06-verify.sh
# ... practise on the VM ...
./99-destroy.sh
```

`03` and `99` both stop and ask before they do anything irreversible. Every
id they create is written to `state/lab.env`, which is how `99-destroy.sh`
knows what to clean up — so do not delete that file while the VM is alive.

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 4 IaaS | You get a bare VM and install everything above the OS yourself |
| 5 Shared responsibility | Vultr gives you the hypervisor and network; the UFW rules, SSH config, and Docker are all yours |
| 6–7 Regions | `01-check.sh` lists them; `sgp` is the default for latency |
| 9, 14 Cloud VM | `03-create-instance.sh` |
| 16 SSH to your server | `04-status.sh` waits for it, then prints the exact `ssh` command |
| 17 Public IP | Assigned during provisioning, recorded in `state/lab.env` |
| 18 Cloud firewall + OS firewall | Vultr firewall group **and** UFW — the two layers, both created for you |
| 19 Never expose everything | `06-verify.sh` proves 5432 and 6379 are unreachable |
| 36 Cloud security basics | cloud-init does `apt upgrade`, key-only SSH, UFW, and a non-root `deploy` user |
| 37 Cloud cost | `01` and `03` print the monthly price before you commit |
| 38 Your first Vultr lab | The whole thing, steps 1–9 |

## Exercises once the VM is up

```bash
# Get in (04-status.sh prints these with the right key and IP)
ssh root@YOUR_IP
ssh deploy@YOUR_IP          # the non-root user cloud-init created

# What cloud-init actually did
cat /var/log/cloud-init-output.log
cat /var/log/lab-bootstrap.log

# The inner firewall
ufw status verbose

# The application
docker ps
docker compose -f /opt/lab-app/compose.yaml logs -f
```

Then try breaking and fixing things:

1. **Close port 80 in the cloud firewall** (delete the rule in the Vultr
   console) and re-run `./06-verify.sh`. Watch `80/tcp` change from `open`
   to `timeout` while SSH keeps working.
2. **Publish something on 5432** — `docker run -d -p 5432:5432 postgres` —
   and probe it from your laptop. It still times out, because the cloud
   firewall drops it before the VM sees it. See the UFW note below for why
   this matters more than it looks.
3. **Redeploy.** Edit `app/html/index.html` locally, run `./05-deploy.sh`
   again, and reload the page. That is a deployment.

## Cost and cleanup

```bash
./99-destroy.sh
```

Then confirm at <https://my.vultr.com/billing/> and <https://my.vultr.com/>
that no instances remain. `99-destroy.sh` finishes by asking the API whether
anything tagged `devops-lab` still exists, but the console is the final word.

Things that keep costing money if you create them outside this lab: snapshots,
block storage volumes, reserved IPs, and load balancers. This lab creates none
of them.

## Notes

- **Docker publishes ports *around* UFW.** `docker run -p 5432:5432` inserts
  its own iptables rules ahead of UFW's, so a container port is reachable even
  when `ufw status` says that port is denied. This surprises people in
  production constantly. On this VM the **cloud firewall is what actually
  protects you** — which is the real argument for lesson 18's two layers, not
  just belt-and-braces.
- **`refused` and `timeout` are different answers.** `06-verify.sh`
  distinguishes them deliberately: 443 is *refused* (the firewall allows it,
  nothing is listening) while 5432 *times out* (dropped at the edge, the VM
  never saw the packet). Same "it does not work", entirely different cause.
- **No numeric ids are hard-coded.** The OS id, plan price, and region are all
  looked up through the API at runtime, because Vultr's catalogue changes.
  If `01-check.sh` cannot find `Ubuntu 24.04 LTS x64`, list what exists with
  `curl -H "Authorization: Bearer $VULTR_API_KEY" https://api.vultr.com/v2/os`.
- **cloud-init runs once, on first boot.** Editing
  `cloud-init/user-data.yaml` after the VM exists changes nothing — you have
  to destroy and recreate. That is the point of it: the VM is reproducible,
  not maintained by hand.
- **The API key is in `.env`, which is gitignored.** If you ever paste a key
  into a script, a commit, or a chat window, revoke it immediately at
  <https://my.vultr.com/settings/#settingsapi>.
- **What you just did, on the other three providers** (lesson 10 and 35, made
  concrete):

  | This lab | AWS | Google Cloud | Azure |
  |---|---|---|---|
  | Cloud firewall group | Security group | VPC firewall rule | Network security group |
  | `POST /v2/instances` | `ec2 run-instances` | `gcloud compute instances create` | `az vm create` |
  | `user_data` cloud-init | EC2 user data | Startup script / cloud-init | Custom data |
  | Uploaded SSH key | EC2 key pair | Project/instance SSH keys | `--ssh-key-values` |
  | `main_ip` | Elastic IP / public IPv4 | External IP | Public IP address |
  | `DELETE /v2/instances/{id}` | `ec2 terminate-instances` | `gcloud compute instances delete` | `az vm delete` |

  The API shapes differ; the seven things you create are the same everywhere.
