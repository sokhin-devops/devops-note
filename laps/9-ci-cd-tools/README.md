# CI/CD Tools Lab — GitHub Actions

The hands-on companion to [D9.ci-cd-tools.md](../../D9.ci-cd-tools.md).

This one is different from every earlier lab: it isn't a Docker Compose
stack you bring up locally. GitHub Actions **is** "workflows that live in
a GitHub repo" — there's no local simulation of it worth building when
this repo already has a real GitHub remote
(`sokhin-devops/devops-note`). So this lab is the real thing.

## Why the files are split across two locations

GitHub only discovers workflows at **`.github/workflows/` at the repo
root** — not anywhere nested under `laps/`. That's a hard platform rule,
not a style choice, so:

| Lives at | Contains |
|---|---|
| [.github/workflows/ci-cd-lab-app.yml](../../.github/workflows/ci-cd-lab-app.yml) | The real, live build & test workflow |
| [.github/workflows/manual-deploy-template.yml](../../.github/workflows/manual-deploy-template.yml) | A deliberately inert deploy-pipeline template |
| `laps/9-ci-cd-tools/app/` | The actual application the workflows build and test |

## Making it live

Nothing runs until these files are committed and pushed — I built them,
I did not push them; that's your call to make.

```bash
git add .github/workflows laps/9-ci-cd-tools
git commit -m "Add CI/CD tools lab"
git push
```

Once pushed, `ci-cd-lab-app.yml` runs immediately on GitHub's own
infrastructure — free, and it triggers again on every future push or PR
that touches `laps/9-ci-cd-tools/app/**`. Watch it at:

```text
https://github.com/sokhin-devops/devops-note/actions
```

## The app it builds

A deliberately tiny, dependency-free Node app — the pipeline is the
lesson, not the app:

```bash
cd laps/9-ci-cd-tools/app
npm ci
npm run lint    # zero-dependency: node --check + a couple of real rules
npm test        # node's built-in test runner, node:test
npm run build   # writes dist/build-manifest.json
```

All three were run for real while building this lab, including a
deliberate failure case (a `debugger` statement was added and `npm run
lint` correctly caught it and exited non-zero, then it was removed again).

## What maps to which lesson section

| Lesson | In this lab |
|---|---|
| 8 Core concepts (workflow/job/step/runner) | `ci-cd-lab-app.yml`'s structure |
| 9 Basic build & test workflow, matrix | `ci-cd-lab-app.yml` — matrix over Node 18/20 |
| 9 `actions/checkout`, `setup-node`, caching | Same workflow, using the real current action versions (`@v4`, not the lesson's `@v3`) |
| 10 Multi-job pipeline with `needs:` | `manual-deploy-template.yml`'s `build-and-test -> provision -> configure -> notify` chain |
| 10 Terraform + Ansible integration | `provision` and `configure` jobs, pointed at [7-lac-provisioning](../7-lac-provisioning/) and [8-configuration-management](../8-configuration-management/) |
| 11 Secrets | Commented-out `secrets.VULTR_API_KEY` / SSH key lines in `manual-deploy-template.yml` — see Notes for why they stay commented |
| 12 Pattern: manual trigger (`workflow_dispatch`) with a `choice` input | `manual-deploy-template.yml`'s `target_environment` input |
| 12 Pattern: conditional jobs (`if:`) | `notify` job's `if: always()` and its result check |
| 17 Concurrency / cancel superseded runs | `ci-cd-lab-app.yml`'s `concurrency:` block |
| 17 Path filters (an extension beyond the lesson) | Both workflows' `paths:` — this repo is a monorepo of labs, so an unfiltered trigger would run this app's CI on every unrelated commit |

## Exercises

```bash
# Break a test on purpose, push, watch it fail in the Actions tab
# (edit test/index.test.js, push, then revert)

# Trigger the manual template without pushing anything
# GitHub -> Actions -> "Manual deploy template (inert)" -> Run workflow
```

If you install the `gh` CLI (not installed on this machine while building
this lab — `winget install GitHub.cli` or see
<https://cli.github.com/>), the lesson's own command reference works
directly:

```bash
gh workflow list
gh run list --workflow=ci-cd-lab-app.yml
gh workflow run manual-deploy-template.yml -f target_environment=dev
```

## Notes

- **`manual-deploy-template.yml` is inert on purpose.** A local script in
  this repo can pause and ask `[y/N]` before spending money (every earlier
  lab does exactly that); a GitHub Actions workflow triggered by a button
  click has no such pause built in. Wiring `terraform apply` or a real
  `ansible-playbook` run to a `workflow_dispatch` button, with real cloud
  credentials sitting in repo secrets, means anyone with write access can
  trigger real spending with one click and no confirmation step. The
  lesson's own reference implementation does exactly that; this lab keeps
  every money-spending or server-touching line as a comment, and the
  workflow only ever runs `plan`/`--check`/`echo`. GitHub's real answer to
  this is **Environments with required reviewers** — a manual approval
  gate before a job touching a protected environment runs — worth reading
  about before uncommenting anything here.
- **Action versions are `@v4`, not the lesson's `@v3`.** `actions/checkout`
  and `actions/setup-node` have moved on since the lesson was written;
  copying pinned versions from any tutorial verbatim, including this
  repo's own lesson files, is worth a second look before relying on it.
- **The matrix is two Node versions, not the lesson's three.** Free-tier
  minutes are generous but not infinite, and tripling every job for a
  third version this lab doesn't otherwise need isn't worth it — trim
  matrices to what you're actually trying to cover.
- **No ESLint, Jest, or any other dependency.** `scripts/lint.js` and
  `node --test` are both zero-dependency by choice, so `npm ci` never
  needs network access beyond GitHub's own runner setup, and this app's
  `package-lock.json` has no third-party packages to ever need a security
  update.
