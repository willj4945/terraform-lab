# What IaC actually is

Infrastructure as code means your servers, networks, databases, IAM roles, DNS records, and queues are defined in files that live in version control, and a tool reconciles the real world to match those files. The console becomes a place you look at things, not a place you change things.

The properties that matter:

- **Declarative desired state.** You describe what should exist, not the steps to create it. The tool figures out the diff between what's declared and what's actually deployed.
- **A plan step.** Before anything changes, you see what will be created, modified, or destroyed. This is the single biggest safety improvement over clicking around.
- **Idempotency.** Running it twice doesn't produce two of everything.
- **Reproducibility.** Staging and prod come from the same definitions with different variables, so "works in staging" means something.
- **Review and audit.** Infrastructure changes go through pull requests. Git history tells you who changed the security group and when.

Worth separating from configuration management: Ansible, Chef, and Puppet were traditionally about what's inside a machine (packages, files, services). IaC in the sense above is about provisioning the machine and everything around it. The lines blur, but the mental split holds.

## The two families

**Cloud-native:** CloudFormation on AWS, ARM templates and Bicep on Azure, Infrastructure Manager / Config Connector on GCP. First-party, scoped to one provider.

**Third-party:** Terraform (and its OpenTofu fork), Pulumi, Crossplane. Provider-agnostic engines that talk to cloud APIs through plugins.

## The case for cloud-native

**No state to manage.** This is the big one and it's often undersold. CloudFormation stacks and ARM deployments are tracked by the cloud provider. There's no state file to store, lock, back up, corrupt, or accidentally commit to a repo with database passwords in it.

**Day-one service support.** When AWS ships a new service at re:Invent, CloudFormation usually supports it immediately. Terraform's AWS provider often catches up weeks or months later, and you end up with `null_resource` shims or clicking in the console in the meantime.

**Deeper integration.** Automatic rollback on failed deploys, StackSets for multi-account rollout, native drift detection, tie-ins with Service Catalog and organizational policy. Your existing cloud support contract covers it.

Bicep specifically deserves a mention. Raw ARM JSON was miserable to write. Bicep is a clean DSL that transpiles to ARM, has good tooling and type checking, and is pleasant enough that "just use Bicep" is a defensible default on Azure in a way "just use CloudFormation" is less so on AWS.

## The case for Terraform

The usual pitch is multi-cloud portability, and that pitch is mostly wrong — I'll come back to it. The real reasons:

**Everything else in your stack is also infrastructure.** Cloudflare DNS, Datadog monitors, GitHub repos and branch protection, Okta apps, Snowflake grants, PagerDuty schedules, Auth0 tenants. Terraform has providers for all of it. CloudFormation manages AWS. Most organizations have a meaningful amount of infrastructure that isn't inside one cloud's boundary, and Terraform lets that live in the same workflow.

**One workflow and skillset.** If you have AWS from an acquisition and Azure from the enterprise agreement, people learn HCL once rather than two template languages.

**`terraform plan` is genuinely good.** CloudFormation change sets are serviceable; the Terraform plan output is the thing people actually miss when they leave.

**Modules and ecosystem.** A large registry, mature module patterns, and an enormous body of community examples and Stack Overflow answers.

**Better at brownfield.** Importing existing hand-built resources into Terraform management is well-trodden. Adopting CloudFormation for resources that already exist is more awkward.

## Terraform's real costs

**State.** You must store it remotely, lock it against concurrent applies, back it up, and treat it as sensitive — secrets land in state in plaintext. Terraform Cloud, S3 with DynamoDB locking, or an equivalent is table stakes, and state surgery (`terraform state mv`, `import`, `refresh`) is a skill your team will need on a bad day.

**Provider lag** for newly released cloud features, as above.

**HCL's limits.** It's a configuration language with loops bolted on. `for_each` and `dynamic` blocks cover a lot, but complex logic gets ugly, and there's a point where people wish they had a real programming language — which is Pulumi's and the CDKs' entire pitch.

**Licensing history.** HashiCorp moved Terraform to the Business Source License in August 2023, which prompted the OpenTofu fork under the Linux Foundation, and IBM subsequently acquired HashiCorp. The BUSL terms don't restrict normal end users — only building a competing product — but the change was enough to make OpenTofu a serious option, and some organizations now default to it for governance reasons.

## On the portability myth

"Write once, deploy to any cloud" is not real. An `aws_instance` and an `azurerm_linux_virtual_machine` are different resources with different schemas; the networking models don't map; the IAM models really don't map. Terraform gives you one tool across clouds, not one codebase. What actually ports is your team's skills, your module conventions, your CI pipeline, and your review process. That's worth a lot — but it isn't cloud-agnostic infrastructure.

## Choosing

Single cloud, staying that way, small team, and you want the smallest possible operational surface → use the native tool, and especially so on Azure where Bicep is strong.

Multiple clouds, or a meaningful amount of SaaS to codify, or a platform team standardizing tooling across the org → Terraform or OpenTofu.

And mixing is fine and common: Terraform for the durable platform layer (accounts, networking, IAM, DNS, data stores), and CDK/SAM or Bicep for application-level resources that ship with the app and change on the app's cadence. The boundary between "platform team owns it" and "product team owns it" is often a better place to split tools than any purity argument.
