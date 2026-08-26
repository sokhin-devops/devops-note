# IaC & Provisioning Lab — Terraform + Vultr

The hands-on companion to [D7.lac-provisioning.md](../../D7.lac-provisioning.md).

The lesson's examples are all AWS. This lab is the same ideas — providers,
resources, variables, outputs, state, modules, workspaces — applied to
**Vultr**, so it builds on the [Vultr lab](../5-cloud-providers/) instead of
requiring a second cloud account.

## The point of this lab

The Vultr lab provisioned a VM with `curl` + `jq` + hand-written bash: a
`lib/vultr.sh` API wrapper, a `state/lab.env` file tracking every id it
created, and numbered scripts that had to get the ordering right by hand.

This lab creates the **same kind of VM and firewall**, but every one of
those jobs is now the tool's job instead of yours:

| Bash + curl (lab 5) | Terraform (this lab) |
|---|---|
| `lib/vultr.sh`'s `api()` wrapper | the `vultr` provider |
| `state/lab.env` (ids you tracked by hand) | `terraform.tfstate` (tracked automatically) |
| `lookup_os_id()` calling `/v2/os` and grepping the result | `data "vultr_os"` |
| scripts run in the right order, by convention | `terraform apply` — the dependency graph *is* the order |
| `99-destroy.sh` deleting things in the right sequence | `terraform destroy` |

Read the two labs side by side once you've run this one. That comparison
is worth more than anything in this README.

## What you build

```text
main.tf
  |
  +-- data "vultr_os"           name -> numeric id, resolved by the provider
  |
  +-- module "networking"        modules/networking/
  |     vultr_firewall_group + 3x vultr_firewall_rule (22, 80, 443)
  |
  +-- module "compute"            modules/compute/
        vultr_ssh_key
        vultr_instance  --user_data-->  cloud-init/user-data.yaml.tpl
                                          (Terraform's templatefile(),
                                           not sed — see the Notes)
```

Same shape as the Vultr lab: one firewall group, one instance, port 80
serving a page that proves the deployment worked.

## Prerequisites

- Terraform. This machine didn't have it installed while building this lab
  — check with `terraform version`; if missing, see the lesson's section 10
  or <https://developer.hashicorp.com/terraform/install>.
- The same Vultr API key and SSH key pair as the [Vultr lab](../5-cloud-providers/)
- `curl`, `jq` (used by the wrapper scripts, not by Terraform itself)

## Setup

```bash
cp .env.example .env
```

Paste your Vultr API key. That's the only secret this lab has, and —
unlike the lesson's AWS examples, which pass credentials through the
provider config or shared credentials files — **it never becomes a
Terraform variable.** The `vultr` provider reads `VULTR_API_KEY` straight
from the environment (see `provider.tf`), so the key is never written into
a `.tf` file, a `.tfvars` file, or Terraform's state. That's the concrete
answer to the lesson's repeated warning about not committing secrets in
`tfvars` — for a value the provider can read from the environment, don't
make it a Terraform variable in the first place.

## The scripts

| Script | Terraform command(s) | Costs |
|---|---|---|
| `00-check.sh` | `terraform version`, `fmt -check` | free |
| `01-init.sh` | `terraform init`, `validate`, `fmt` | free |
| `02-plan.sh [dev\|prod]` | `terraform plan -var-file=... -out=tfplan` | free |
| `03-apply.sh [dev\|prod]` | `terraform apply` | **starts billing** |
| `04-verify.sh [dev\|prod]` | `terraform output`, `state list` | free |
| `99-destroy.sh [dev\|prod]` | `terraform destroy` | **stops billing** |

All default to `dev` (`environments/dev.tfvars`, a `vc2-1c-1gb`, ~$5/month).

```bash
./00-check.sh
./01-init.sh
./02-plan.sh
./03-apply.sh      # confirms the monthly cost, then asks before applying
./04-verify.sh
# ... use the VM ...
./99-destroy.sh
```

You can also skip the wrapper scripts entirely and run Terraform directly —
that's the whole point of IaC:

```bash
export VULTR_API_KEY=...          # or: set -a; . .env; set +a
terraform init
terraform plan  -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
terraform destroy -var-file=environments/dev.tfvars
```

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 3 Why Terraform | The whole lab; nothing here is AWS-CDK- or CloudFormation-specific |
| 7 Provider / resource / variable / output / state / module / backend | `provider.tf`, any `resource "vultr_*"` block, `variables.tf`, `outputs.tf`, `terraform.tfstate` (gitignored, local), `modules/`, the default local backend |
| 7 `templatefile()` for `user_data` | `modules/compute/main.tf` — the exact pattern from the lesson's "Full Web Stack" example, ported from AWS to Vultr |
| 8 Modules | `modules/networking`, `modules/compute` — same split as the lesson's `modules/networking`, `modules/database`, `modules/compute` |
| 9 State | Read `terraform.tfstate` after an apply. Never commit it — see `.gitignore` |
| 11 Common commands | `00`–`04` are thin wrappers around exactly these |
| 12 Best practices | `.gitignore` matches the lesson's own recommended patterns; see Notes for the one place this lab intentionally goes further |
| 13 Workspaces | `environments/prod.tfvars`'s header — see Notes |
| 16 Multi-environment (`environments/*.tfvars`) | `environments/dev.tfvars`, `environments/prod.tfvars` |
| 16 `variable` with `validation` | `variable "environment"` in `variables.tf`, copied from the lesson almost verbatim |

## Exercises

```bash
# What Terraform knows exists, and one resource in detail
terraform state list
terraform state show module.compute.vultr_instance.this

# Change one thing and see Terraform compute a minimal diff
# (edit environments/dev.tfvars, e.g. try a different plan)
terraform plan -var-file=environments/dev.tfvars
```

```bash
# The resource graph the lesson's cheat sheet mentions
terraform graph
```

Try the workspace exercise from lesson section 13 for real:

```bash
terraform workspace new prod
terraform apply -var-file=environments/prod.tfvars
terraform state list                 # a second instance, separate state
terraform destroy -var-file=environments/prod.tfvars
terraform workspace select default   # back to dev
```

## Stop / cleanup

```bash
./99-destroy.sh
```

Then confirm at <https://my.vultr.com/billing/> that nothing tagged
`devops-lab` remains — same check as the Vultr lab.

## Notes

- **Every module needs its own `required_providers` block.** This bit while
  building the lab: `versions.tf` at the root declares `source =
  "vultr/vultr"`, but Terraform does not propagate that source address into
  child modules automatically. Without a matching block in
  `modules/networking/versions.tf` and `modules/compute/versions.tf`,
  `terraform init` defaults the bare name `vultr` to the legacy
  `hashicorp/vultr` namespace and fails with a confusing "does not have a
  provider named hashicorp/vultr" error. Both module directories carry
  their own copy for exactly this reason.
- **`user_data` is plain text here, not `base64encode(...)`.** The lesson's
  AWS example wraps it explicitly:
  `user_data = base64encode(templatefile(...))`. Vultr's own provider
  documentation uses plain `user_data = file(...)` — the provider base64s
  it internally before calling the API. Copying the AWS pattern verbatim
  onto a different provider would silently send double-encoded, broken
  cloud-init. Always check the specific provider's docs for a given
  argument instead of assuming every cloud works like AWS.
- **`data "vultr_os"` makes a real, unauthenticated API call during
  `plan`** — Vultr's OS catalogue is public. Confirmed while building this:
  it resolved `"Ubuntu 24.04 LTS x64"` to os id `2284`, the same id the
  Vultr lab's bash+curl+jq lookup found independently. Same fact, two
  different tools.
- **`-var-file` alone does not give you separate dev/prod.** Applying
  `prod.tfvars` against the same state as `dev.tfvars` doesn't create a
  second server — it's the same resource addresses in the same state file,
  so Terraform replaces the dev instance with a prod-sized one. Real
  side-by-side environments need a Terraform **workspace** too (lesson
  section 13); see the header comment in `environments/prod.tfvars` and the
  Exercises above.
- **This lab keeps local state on purpose**, per the lesson's own
  "Local State (Learning/Small Projects)" guidance in section 9. A single
  learner, one machine, nothing to hand off — remote state (S3-equivalent,
  or Terraform Cloud's free tier) solves a team-coordination problem this
  lab doesn't have yet.
- **No hand-rolled state file, unlike labs 5 and 6.** Notice there's no
  `lib/*.sh` with `state_set`/`state_get` here. That bash pattern was
  standing in for exactly what `terraform.tfstate` does natively — this lab
  is where that stand-in gets retired.
