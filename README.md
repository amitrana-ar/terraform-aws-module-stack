# terraform-aws-module-stack

Provisioning AWS public & private EC2 instances with ALB routing using Terraform modules. Includes VPC, subnets, IGW, NAT Gateway, S3, and remote state management.

---

## Architecture

```
                            Internet
                               |
                       Internet Gateway
                               |
                ┌──────────────────────────┐
                │       Public Subnets      │
                │      <az-1>    <az-2>     │
                │                           │
                │   [Bastion EC2]  [ALB]    │
                │         |          |      │
                │     [NAT GW]       |      │
                └─────────|──────────|──────┘
                          |          |
                ┌─────────|──────────|──────┐
                │       Private Subnets      │
                │      <az-1>    <az-2>      │
                │                            │
                │       [Private EC2]        │
                │       (Apache Server)      │
                └────────────────────────────┘
```

**Traffic Flow:**
```
User  →  ALB (port 80)  →  Target Group  →  Private EC2 (port 80)
SSH   →  Public EC2 (Bastion)  →  Private EC2
Private EC2  →  NAT Gateway  →  Internet (outbound only)
```

---

## Resources Created

| Resource | Description |
|---|---|
| `aws_vpc` | Custom VPC with configurable CIDR block |
| `aws_subnet` (public) | Public subnets across 2 AZs, auto-assigns public IP |
| `aws_subnet` (private) | Private subnets across 2 AZs, no public IP |
| `aws_internet_gateway` | IGW for public internet access |
| `aws_eip` | Elastic IP allocated for NAT Gateway |
| `aws_nat_gateway` | NAT Gateway in public subnet for private EC2 outbound |
| `aws_route_table` (public) | Routes `0.0.0.0/0` → IGW |
| `aws_route_table` (private) | Routes `0.0.0.0/0` → NAT Gateway |
| `aws_route_table_association` | Associates subnets to their route tables |
| `aws_security_group` | Allows SSH (22), HTTP (80), HTTPS (443) inbound |
| `aws_key_pair` | SSH key pair for EC2 access |
| `aws_instance` (public) | EC2 in public subnet with public IP (bastion) |
| `aws_instance` (private) | EC2 in private subnet, registered to ALB |
| `aws_lb` | Internet-facing Application Load Balancer |
| `aws_lb_target_group` | Target group on port 80 with health checks |
| `aws_lb_target_group_attachment` | Attaches private EC2s to target group |
| `aws_lb_listener` | Listens on port 80, forwards to target group |
| `aws_s3_bucket` | Private S3 bucket with versioning, SSE, and logging |

---

## Project Structure

```
terraform-aws-module-stack/
├── main.tf                     # Module calls for dev & prod environments
├── terraform.tf                # Provider config & S3 remote state backend
├── output.tf                   # Output values
├── terra-module/               # Reusable Terraform module
│   ├── vpc.tf                  # VPC, subnets, IGW, NAT GW, route tables, SG
│   ├── ec2.tf                  # Key pair, public & private EC2 instances
│   ├── loadbalancer.tf         # ALB, target group, listener, attachments
│   ├── s3.tf                   # S3 bucket, versioning, SSE, logging
│   └── variable.tf             # All module input variables
└── userdata/
    ├── apache-install.sh       # Apache2 installation script
    ├── nginx-install.sh        # Nginx installation script
    └── softinstallation_ubuntu.sh
```

---

## Environments

Supports multiple environments via Terraform module calls in `main.tf`:

| Environment | VPC CIDR | Instance |
|---|---|---|
| `dev` | `10.0.0.0/16` | `t2.medium` |
| `prod` | `10.1.0.0/16` | `t2.medium` |

---

## Subnet CIDR Layout

Using default VPC CIDR `10.0.0.0/16`:

| Type | AZ | CIDR |
|---|---|---|
| Public | `<az-1>` | `10.0.5.0/24` |
| Public | `<az-2>` | `10.0.6.0/24` |
| Private | `<az-1>` | `10.0.10.0/24` |
| Private | `<az-2>` | `10.0.11.0/24` |

---

## Remote State Backend

State is stored remotely in S3 with native locking (no DynamoDB required). Requires Terraform >= 1.10.

```hcl
backend "s3" {
  bucket       = "<your-terraform-state-bucket>"
  key          = "<env>/terraform.tfstate"
  region       = "<your-aws-region>"
  use_lockfile = true
  encrypt      = true
}
```

> The S3 bucket for remote state must be created separately before running this project.

---

## Prerequisites

- Terraform >= 1.10
- AWS CLI configured with appropriate IAM permissions
- SSH public key placed at `userdata/<your-keypair>.pub`
- S3 bucket for remote state already exists

---

## Usage

```bash
# Clone the repo
git clone https://github.com/<your-username>/terraform-aws-module-stack.git
cd terraform-aws-module-stack

# Initialize (downloads providers & sets up backend)
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# Destroy infrastructure
terraform destroy
```

---

## Security Group Rules

| Type | Port | Protocol | Source |
|---|---|---|---|
| Ingress | 22 | TCP | Your IP only |
| Ingress | 80 | TCP | `0.0.0.0/0` |
| Ingress | 443 | TCP | `0.0.0.0/0` |
| Egress | All | All | `0.0.0.0/0` |

---

## Module Variables

| Variable | Default | Description |
|---|---|---|
| `env` | - | Environment name (`dev`, `prod`) |
| `vpc_name` | - | VPC name tag |
| `vpc_cidr_block` | `10.0.0.0/16` | VPC CIDR block |
| `vpc_availability_zone` | `["<az-1>", "<az-2>"]` | List of AZs (exactly 2 required) |
| `ec2_instance_type` | - | Map of EC2 definitions (ami, type, userdata) |
| `ec2_root_volume_size` | `20` | Root EBS volume size in GB |
| `ec2_key_pair_name` | - | SSH key pair name |
| `ec2_key_pair_public_key` | - | SSH public key content |
| `ec2_ingress_ssh_port` | `22` | SSH port |
| `ec2_ingress_http_port` | `80` | HTTP port |
| `ec2_ingress_https_port` | `443` | HTTPS port |
| `ec2_ssh_cidr_blocks` | `["0.0.0.0/0"]` | Allowed CIDRs for SSH |
| `loadbalancer_type` | - | Load balancer type (`application`) |
| `loadbalancer-name` | - | Name of the load balancer |
| `s3_bucket` | - | S3 bucket name |
| `s3_versioning` | `Enabled` | S3 versioning status |
| `sse_algorithm` | `AES256` | S3 server-side encryption algorithm |

---

## .gitignore

Ensure the following are excluded before pushing to GitHub:

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.pub
*.pem
.terraform.lock.hcl
```

---

## Author

Built and maintained by **Amit Rana**
