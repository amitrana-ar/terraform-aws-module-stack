# Terraform AWS Module Stack

A complete AWS infrastructure stack built from scratch using Terraform modules. Supports multiple environments (dev/prod) with VPC, EC2, RDS, ALB, S3, IAM, and Secrets Manager — all managed through a reusable module.

---

## Architecture

```
                            Internet
                               │
                       Internet Gateway
                               │
                ┌──────────────────────────────┐
                │         Public Subnets        │
                │       az-1          az-2      │
                │                              │
                │  [Bastion EC2]     [ALB]      │
                │        │             │        │
                │    [NAT GW]          │        │
                └────────│─────────────│────────┘
                         │             │
                ┌────────│─────────────│────────┐
                │        Private Subnets         │
                │       az-1          az-2       │
                │                               │
                │      [Private EC2]            │
                │      (Apache Server)          │
                │             │                 │
                │         [RDS MySQL]           │
                │    (only private EC2 access)  │
                └───────────────────────────────┘
```

**Traffic Flow:**
```
User        →  ALB (port 80/443)  →  Target Group  →  Private EC2 (port 80)
SSH         →  Public EC2 (Bastion)  →  Private EC2
Private EC2 →  NAT Gateway  →  Internet (outbound only)
Private EC2 →  RDS (port 3306) (internal only)
```

---

## Resources Created

| Resource | Description |
|---|---|
| `aws_vpc` | Custom VPC with configurable CIDR |
| `aws_subnet` (public) | Public subnets across 2 AZs, auto-assigns public IP |
| `aws_subnet` (private) | Private subnets across 2 AZs, no public IP |
| `aws_internet_gateway` | IGW for public internet access |
| `aws_eip` | Elastic IP for NAT Gateway |
| `aws_nat_gateway` | NAT Gateway in public subnet for private EC2 outbound |
| `aws_route_table` (public) | Routes `0.0.0.0/0` → IGW |
| `aws_route_table` (private) | Routes `0.0.0.0/0` → NAT Gateway |
| `aws_route_table_association` | Associates subnets to route tables |
| `aws_security_group` (public) | SSH access for bastion EC2 |
| `aws_security_group` (private) | SSH, HTTP, HTTPS for private EC2 |
| `aws_security_group` (lb) | HTTP, HTTPS for ALB |
| `aws_security_group` (rds) | Port 3306 only from private EC2 SG |
| `aws_key_pair` | SSH key pair for EC2 access |
| `aws_instance` (public) | Bastion EC2 in public subnet |
| `aws_instance` (private) | App EC2 in private subnet, registered to ALB |
| `aws_lb` | Internet-facing Application Load Balancer |
| `aws_lb_target_group` | Target group on port 80 with health checks |
| `aws_lb_target_group_attachment` | Attaches private EC2s to target group |
| `aws_lb_listener` | Listens on port 80, forwards to target group |
| `aws_db_instance` | MySQL 8.0 RDS in private subnet |
| `aws_db_subnet_group` | RDS subnet group using private subnets |
| `aws_secretsmanager_secret` | Stores RDS credentials securely |
| `aws_secretsmanager_secret_version` | Actual credential values in JSON |
| `aws_s3_bucket` | Private S3 bucket with versioning, SSE, logging |
| `aws_iam_role` | IAM role for EC2 to access S3 |
| `aws_iam_policy` | IAM policy allowing S3 GetObject, PutObject, ListBucket |
| `aws_iam_role_policy_attachment` | Attaches IAM policy to EC2 role |

---

## Project Structure

```
terraform-aws-module-stack/
├── main.tf                      # Module calls for dev & prod environments
├── terraform.tf                 # Provider config & S3 remote state backend
├── output.tf                    # Output values
├── variable.tf                  # Root level sensitive variables (credentials)
├── terraform.tfvars             # Actual variable values (never push to GitHub)
├── terra-module/                # Reusable Terraform module
│   ├── vpc.tf                   # VPC, subnets, IGW, NAT GW, route tables, SGs
│   ├── ec2.tf                   # Key pair, public & private EC2 instances
│   ├── lb.tf                    # ALB, target group, listener, attachments
│   ├── rds.tf                   # RDS MySQL instance, subnet group
│   ├── secrets.tf               # AWS Secrets Manager for RDS credentials
│   ├── s3.tf                    # S3 bucket, versioning, SSE, logging
│   ├── iam.tf                   # IAM role, policy, attachment for EC2
│   ├── vpc-variable.tf          # VPC input variables
│   ├── ec2-variable.tf          # EC2 input variables
│   ├── lb-variable.tf           # Load balancer input variables
│   ├── rds-variable.tf          # RDS input variables
│   ├── s3-variable.tf           # S3 input variables
│   └── iam-variable.tf          # IAM input variables
└── userdata/
    ├── apache-install.sh        # Apache2 installation script
    ├── nginx-install.sh         # Nginx installation script
    ├── softinstallation_ubuntu.sh
    └── aws-keypair-mumbai.pub   # SSH public key
```

---

## Environments

Supports multiple environments via Terraform module calls in `main.tf`:

| Environment | VPC CIDR | Instance Type | RDS |
|---|---|---|---|
| `dev` | `10.0.0.0/16` | `t2.medium` | `db.t3.micro` |
| `prod` | `10.1.0.0/16` | `t2.medium` | `db.t3.micro` |

---

## Subnet CIDR Layout

| Type | AZ | CIDR (dev) | CIDR (prod) |
|---|---|---|---|
| Public | `ap-south-1a` | `10.0.5.0/24` | `10.1.5.0/24` |
| Public | `ap-south-1b` | `10.0.6.0/24` | `10.1.6.0/24` |
| Private | `ap-south-1a` | `10.0.10.0/24` | `10.1.10.0/24` |
| Private | `ap-south-1b` | `10.0.11.0/24` | `10.1.11.0/24` |

---

## Security Groups

| Security Group | Inbound | Source |
|---|---|---|
| `sg-public` | Port 22 (SSH) | Your IP only |
| `sg-private` | Port 22, 80, 443 | VPC CIDR |
| `sg-lb` | Port 80, 443 | `0.0.0.0/0` |
| `sg-rds` | Port 3306 (MySQL) | `sg-private` only |

---

## RDS Credentials Security

Credentials are **never hardcoded** in any `.tf` file. The flow is:

```
terraform.tfvars (local, never pushed)
        │
        ▼
root variable.tf (defines sensitive variables)
        │
        ▼
main.tf (passes to module)
        │
        ▼
secrets.tf (stores in AWS Secrets Manager)
        │
        ▼
rds.tf (fetches from Secrets Manager via jsondecode)
        │
        ▼
RDS Instance created ✅
```

---

## Remote State Backend

State is stored in S3 with native locking. Requires Terraform >= 1.10:

```hcl
backend "s3" {
  bucket       = "artechworld-terraform-state"
  key          = "dev/terraform.tfstate"
  region       = "ap-south-1"
  use_lockfile = true
  encrypt      = true
}
```

> S3 bucket for remote state must be created separately before running this project.

---

## Prerequisites

- Terraform >= 1.10
- AWS CLI configured with appropriate IAM permissions
- SSH public key at `userdata/aws-keypair-mumbai.pub`
- S3 bucket for remote state already created
- `terraform.tfvars` created locally with RDS credentials

---

## Usage

```bash
# Clone the repo
git clone https://github.com/<your-username>/terraform-aws-module-stack.git
cd terraform-aws-module-stack

# Create terraform.tfvars (never push this to GitHub)
cat > terraform.tfvars <<EOF
rds_db_username = "admin"
rds_db_password = "yourpassword"
EOF

# Initialize
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply

# Destroy
terraform destroy
```

---

## .gitignore

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
errored.tfstate
*.pub
*.pem
terraform.tfvars
*.tfvars
.terraform.lock.hcl
```

---

## Author

Built and maintained by **Amit Rana**
