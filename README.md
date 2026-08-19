# Terraform Associate (004) — Study Plan & Lab Project

**Exam facts**
- Version: 004, aligned to Terraform 1.12 — *verify any course or practice test says 004, not 003*
- Format: 60 minutes, ~57–60 multiple choice, 70% to pass
- Delivery: online-proctored via Certiverse, closed book, single monitor, room scan
- Cost: $70.50 USD, no free retake
- Valid: 2 years
- Official objectives: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004
- Official learning path: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004

**Booking note:** schedule the exam now for ~5 weeks out. Paying for it converts this from a
someday plan into a deadline, and the no-retake policy is a useful motivator.

---

## Resources

**Version warning:** 003 was retired January 7, 2026; 004 went live January 8, 2026. Anything
published before late 2025 is the wrong exam. Check the version number on every course, video,
and question bank before you spend money or time.

### Free and official — this is your spine

| Resource | Use it for |
|---|---|
| [Associate Prep (004) hub](https://developer.hashicorp.com/terraform/tutorials/certification-004) | Entry point to everything official |
| [Learning path (004)](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004) | Ordered start-to-finish curriculum — follow this as your main track |
| [Exam content list (004)](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004) | Every objective mapped to a doc page — your gap-check tool |
| Official sample questions (linked from the prep hub) | Calibrate to question format before buying practice tests |
| [Terraform docs](https://developer.hashicorp.com/terraform/docs) | The authority. For the 004 net-new topics, read these directly rather than trusting a course |
| [Terraform Registry](https://registry.terraform.io/) | Provider/resource reference and public modules |
| Get Started tutorials (AWS track) | Week 1 hands-on |
| HCP Terraform free tier | Week 3 — remote state and remote runs |

The learning path plus the docs is genuinely enough to pass. Everything below is optional
supplement, not replacement.

### Paid — practice exams (worth it)

Practice tests are the one paid category with a clear return. They surface gaps you don't know
you have, which is the exact thing self-study is bad at.

- **Bryan Krausen — Terraform Associate 004 Practice Exams** (Udemy). ~350 questions across six
  tests, written by an authorized HashiCorp instructor, explicitly rebuilt for 004 including
  Terraform 1.12 and HCP topics. This is the standard recommendation and the one to buy if you
  buy only one thing.
- **Whizlabs Terraform Associate 004** — practice tests plus guided hands-on labs. Useful if you
  want a sandbox rather than using your own cloud account.

Buy one, not four. Wait for a Udemy sale; these are frequently under $20.

### Video course (optional)

If you learn better by watching, look for a 004-updated course — but verify the version, since
several popular Terraform courses are still on 003 content. Given your background, the official
learning path plus practice exams will likely serve you better than a 20-hour video course, and
cost less.

### Do not use

Skip anything marketed as "dumps," "real exam questions," or "verified actual questions"
(validexamdumps, dumpscollege, certshero, and similar). Three reasons: the questions are often
wrong, using them violates the exam agreement and can void your certification, and memorizing
answers produces exactly the credential-without-substance profile you're trying to move away
from. Legitimate practice exams say so explicitly — the reputable ones advertise that they are
not dumps.

### Community

- r/Terraform — real-world questions and exam experience threads
- HashiCorp Discuss forums — official, good for "why does Terraform do X" questions

---

## Week 1 — Fundamentals and the core loop

Goal: the write → init → plan → apply cycle is muscle memory by Friday.

- [ ] Read: what IaC is, and why Terraform vs. cloud-native IaC (CloudFormation/ARM/Bicep)
- [ ] Install Terraform CLI locally; confirm `terraform version`
- [ ] Set up a git repo for all lab work (this becomes your portfolio piece — commit daily)
- [ ] Providers: `required_providers`, source addresses, version constraint operators (`~>`, `>=`, `=`)
- [ ] `terraform init` — what it actually does (provider download, backend init, `.terraform.lock.hcl`)
- [ ] `terraform plan` — read a full plan output line by line; understand `+`, `-`, `~`, `-/+`
- [ ] `terraform apply`, `terraform destroy`
- [ ] `terraform fmt`, `terraform validate`
- [ ] HCL basics: blocks, arguments, resource addressing (`resource_type.name`)
- [ ] Deploy your first real resource in your own cloud account (see Lab Milestone 1)

**Self-check:** Can you explain, without notes, what changes on disk when you run `init`?

---

## Week 2 — State and configuration

Goal: state stops being magic. This is the highest-yield week for the exam *and* for the job.

State:
- [ ] What state is, why it exists, why it's sensitive (secrets land in it in plaintext)
- [ ] Local vs. remote backends; when and why to use remote state
- [ ] State locking — what it prevents
- [ ] `terraform state list`
- [ ] `terraform state show`
- [ ] `terraform state mv`
- [ ] `terraform state rm`
- [ ] `terraform import` / `import` blocks
- [ ] Drift: what `plan` does when reality diverges from state
- [ ] `terraform refresh` and why it's discouraged in favor of `-refresh-only`

Configuration:
- [ ] Input variables: types, defaults, `sensitive`, precedence order of value sources
- [ ] Outputs, including `sensitive` outputs
- [ ] `locals`
- [ ] Data sources
- [ ] **`for_each` vs `count`** — when each is correct, and why `count` causes index-shift
      destruction on list changes. Expect at least one exam question here.
- [ ] Expressions, functions, `dynamic` blocks

**Deliberate exercise:** break your state on purpose. `state rm` a resource, run `plan`, watch
Terraform try to recreate something that already exists. Then `import` it back. Do this once now,
in a lab, so the first time isn't in production.

**Self-check:** Someone renamed a resource block. What command prevents Terraform from
destroying and recreating it?

---

## Week 3 — Modules and HCP Terraform

Goal: you can author a module someone else could consume.

Modules:
- [ ] Module anatomy: inputs, outputs, versioning
- [ ] Root module vs. child modules
- [ ] Consume a module from the public registry
- [ ] Write your own module (see Lab Milestone 2)
- [ ] Pass outputs from one module into another module's inputs
- [ ] Module sources: local paths, registry, git

HCP Terraform (don't skip — it's a meaningful slice of the exam):
- [ ] Community edition vs. HCP Terraform vs. Enterprise — what's different
- [ ] **Workspaces vs. projects** — the distinction is new-ish and gets tested
- [ ] Remote state management and remote runs in HCP
- [ ] VCS-driven vs. CLI-driven workflows
- [ ] Sentinel / policy as code (conceptual awareness is enough at Associate level)
- [ ] Private module registry
- [ ] Sign up for the free HCP Terraform tier and run one remote plan end to end

**Self-check:** Why would a team use projects rather than just more workspaces?

---

## Week 4 — The 004 net-new, then drill

These four areas are what 003-era materials will *not* cover. Read the official docs directly.

- [ ] `depends_on` — explicit vs. implicit dependencies, and when the graph needs help
- [ ] `lifecycle` → `create_before_destroy` (also skim `prevent_destroy`, `ignore_changes`)
- [ ] Custom conditions: variable `validation`, `precondition`, `postcondition`, `check` blocks
- [ ] Ephemeral values and write-only arguments — what problem they solve (secrets in state)

Then:
- [ ] Official sample questions
- [ ] Two full-length reputable practice exams (skip brain-dump sites — inaccurate and against
      the exam agreement)
- [ ] Log every miss in a running list; re-read the relevant doc page, not just the answer key
- [ ] Re-drill your two weakest objectives
- [ ] Skim the entire exam content list one final time and confirm nothing is unfamiliar

**Day before:** review your miss list and the state commands. No new material. Confirm exam rules
(single monitor, clear desk, ID ready) and test your webcam and network.

---

## Common failure modes

| Trap | Fix |
|---|---|
| Studying with 003 or 002 materials | Confirm 004 on every resource |
| Fuzzy on `for_each` vs `count` | Build the same resource set both ways, change the input, compare plans |
| Weak state command recall | Flashcard `mv` / `rm` / `import` / `list` / `show` |
| Skipping the HCP objective | Free tier, one remote run |
| Only reading, never running | Every topic gets typed into a terminal |

---

## Lab project: compliance control as code

The point of doing labs in your own environment rather than the tutorial's is that you finish
with something you can show an interviewer *and* something your current employer might actually
use. Written for AWS; substitute Azure/GCP equivalents if that's your stack.

**Target:** a reusable module that provisions an audit-log storage bucket meeting a control you
already own in your GRC work — encryption at rest, versioning, public-access blocked, retention
period, access logging.

**Milestone 1 (Week 1):** single hardcoded resource. One bucket, encryption on, public access
blocked. Ugly and non-parameterized is fine. Goal is init/plan/apply working against real creds.

**Milestone 2 (Week 3):** convert to a module.
- Inputs: bucket name, retention days, environment tag, KMS key ARN
- Variable `validation` blocks rejecting configurations that would violate the control (e.g.
  retention below your policy minimum) — this doubles as your Week 4 custom-conditions practice
- Outputs: bucket ARN, bucket ID
- README documenting which control clause each setting satisfies

**Milestone 3 (Week 4):** operational polish.
- Remote state in HCP Terraform
- `lifecycle` rules where destruction would be unacceptable (`prevent_destroy` on the bucket)
- Deploy two instances from the module with `for_each` across environments
- Import an *existing* manually-created bucket into Terraform management — the single most
  realistic skill on this list

**Stretch, and the thing that makes this actually differentiating:** a small Python script that
reads your Terraform outputs (or state) and emits the evidence artifact your auditors currently
ask you to screenshot by hand. That's the GRC-to-engineering bridge in one repo.

**Interview framing:** "I codified one of our controls as a Terraform module with validation that
makes non-compliant configurations fail at plan time, so the control can't be silently violated —
and the evidence generates itself."
