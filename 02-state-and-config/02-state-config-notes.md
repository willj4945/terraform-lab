# Week 2 - State and configuration

## State: the core idea

Terraform state is Terraform's record of the remote objects it manages. It maps
configuration addresses, such as `aws_instance.web`, to real object IDs and
stores attributes needed to determine what should change.

State exists because Terraform needs to compare three things:

- Configuration: the desired state.
- State: Terraform's last known mapping and attributes.
- Provider/API reality: what exists now.

State is sensitive. Resource attributes and outputs can contain passwords,
tokens, private keys, and other secrets, often in plaintext. Protect local state
files and backend storage, restrict access, and never commit `terraform.tfstate`
or its backups to source control.

## Backends and locking

- A local backend stores state on disk in the working directory. It is simple
  for solo experiments but is easy to lose, leak, or use concurrently.
- A remote backend stores state in shared infrastructure. It is normally the
  right choice for teams because it centralizes access control, backup,
  versioning, and collaboration.
- State locking prevents concurrent operations from writing state at the same
  time. It protects state consistency; it does not prevent two people from
  editing configuration or guarantee that the plan remains current.

Always inspect the backend's locking and recovery behavior before relying on it.

## State commands

```text
terraform state list
terraform state show <address>
terraform state mv <old-address> <new-address>
terraform state rm <address>
terraform import <address> <provider-object-id>
```

`state mv` changes Terraform's address-to-object mapping without destroying the
object. Use it when a resource is renamed or moved between modules. In modern
Terraform, an `moved` block is usually preferable because the refactoring is
recorded in version-controlled configuration:

```hcl
moved {
  from = aws_instance.old_name
  to   = aws_instance.web
}
```

`state rm` forgets an object; it does not delete the remote object. A later
plan generally proposes creating a replacement because the object is no longer
tracked. Use this deliberately, and verify the address before confirming.

Import associates an existing object with a resource address. Import alone does
not necessarily produce complete configuration: run `plan`, inspect all
differences, and write configuration that matches the intended management.
Import blocks make the import reproducible:

```hcl
import {
  to = aws_instance.web
  id = "i-0123456789abcdef0"
}
```

## Drift and refresh

During `plan`, Terraform refreshes state from providers by default, then
compares refreshed reality with configuration. If reality drifted, the plan
may propose updating it back to configuration, or may update state to reflect
provider-computed changes.

`terraform refresh` only refreshes state and is discouraged because it can make
state stop matching configuration without showing a proposed change. Prefer:

```text
terraform plan -refresh-only
terraform apply -refresh-only
```

The refresh-only workflow makes the state-only change visible for review.

## Input variables

Variables make configuration reusable. Declare types and descriptions, and use
`sensitive = true` when values should be redacted from normal CLI output:

```hcl
variable "region" {
  type        = string
  description = "Deployment region"
  default     = "us-east-1"
}

variable "tags" {
  type      = map(string)
  sensitive = false
}
```

Common types include `string`, `number`, `bool`, `list(T)`, `set(T)`,
`map(T)`, `object({...})`, and `tuple([...])`. A default makes a variable
optional. A variable with no default is required unless supplied elsewhere.

Typical value precedence, from lower to higher priority, is:

1. Variable defaults.
2. `TF_VAR_name` environment variables.
3. `terraform.tfvars` and `terraform.tfvars.json`.
4. Automatically loaded `*.auto.tfvars` files, in lexical order.
5. Explicit `-var` and `-var-file` command-line values.

Multiple files of the same class are loaded in order, with later values
winning. When exam wording depends on exact precedence, check the Terraform
version's documentation.

Sensitive variables are redacted in CLI output, but sensitivity is not
encryption. Values can still be present in state and provider APIs.

## Outputs, locals, and data sources

Outputs expose values to a caller, parent module, or `terraform output`:

```hcl
output "instance_ip" {
  value     = aws_instance.web.public_ip
  sensitive = true
}
```

`locals` name reusable expressions inside a module. They do not create
infrastructure and cannot be set by callers:

```hcl
locals {
  common_tags = merge(var.tags, { managed_by = "terraform" })
}
```

A data source reads existing information; it does not create or manage that
object. Resources generally use a provider to create or change objects, while
data sources query them:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```

## Expressions, functions, and dynamic blocks

Expressions calculate values from literals, variables, resources, data,
locals, and conditional expressions. Useful functions include `length`,
`lookup`, `merge`, `try`, `can`, `coalesce`, `for`, and `toset`.

```hcl
name = var.environment == "prod" ? "production" : "nonproduction"
```

Use a `dynamic` block when a nested block must be generated from a collection.
It is appropriate for repeated provider-specific nested blocks, not for
replacing ordinary resource iteration:

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port   = ingress.value.from_port
    to_port     = ingress.value.to_port
    protocol    = ingress.value.protocol
    cidr_blocks = ingress.value.cidr_blocks
  }
}
```

## `count` versus `for_each`

Use `count` for a small number of nearly identical instances where an integer
index is a natural identity, often a simple on/off toggle:

```hcl
resource "aws_instance" "web" {
  count = var.create_web ? 1 : 0
}
```

Use `for_each` when instances have stable, meaningful identities, especially
when iterating over named objects:

```hcl
resource "aws_s3_bucket" "app" {
  for_each = var.buckets
  bucket   = each.key
  tags     = each.value.tags
}
```

`count` addresses are indexed: `aws_instance.web[0]`. If an item is removed
from the middle of a list, later items shift indexes. Terraform can then see
the shifted instances as different objects and plan unnecessary replacement or
destruction and recreation. `for_each` addresses are keyed, such as
`aws_s3_bucket.app["logs"]`, so removing one key leaves the other identities
stable.

Exam rule: choose `for_each` for independently managed named items; choose
`count` when positional identity or a simple conditional quantity is intended.
`for_each` requires a collection with known, stable keys; do not use sensitive
values as keys.

## Deliberate state exercise

Run this only against disposable lab resources:

1. `terraform init`
2. `terraform apply`
3. `terraform state list` and `terraform state show <address>`
4. Record the real object ID and confirm the resource is disposable.
5. `terraform state rm <address>`
6. `terraform plan` and observe Terraform propose creation.
7. Import the existing object back with `terraform import <address> <id>`.
8. Run `terraform plan`; investigate any configuration differences.

Do not apply the recreate plan in step 6. The exercise demonstrates that state
is Terraform's tracking record, not the remote infrastructure itself.

## Self-check

Someone renamed a resource block. What prevents Terraform from destroying and
recreating it?

**Answer:** use a `moved` block from the old address to the new address (or use
`terraform state mv` for a direct state migration). The configuration-based
`moved` block is generally the better team workflow because it is reviewable and
repeatable.
