Create MigrateEc2.ps
# AWS EC2 Instance Migration Tool

## 🔄 What This Script Does
This PowerShell script automates the migration of EC2 instances between subnets/VPCs while preserving data. It performs:

1. **Creates Snapshots** of all attached EBS volumes
2. **Builds AMI** from the source instance
3. **Launches New Instance** in target subnet/VPC
4. **Manages Volume Attachments** (including root volume replacement)
5. **Cleanup Options** for old resources

## ⚠️ Critical Security Notes
**BEFORE RUNNING THIS SCRIPT:**
1. 🔐 **Remove/Change** these insecure elements:
   - Any hardcoded credentials (lines 14-17 in the current version)
   - Overly permissive security group rules (opens all ports to 0.0.0.0/0)

2. 🛡️ **Required AWS Prep:**
   ```bash
   # Configure AWS CLI first (recommended over script credentials)
   aws configure



🛠️ Pre-Run Checklist
IAM Requirements:

The user must have EC2FullAccess permissions

Add MFA if available (aws iam enable-mfa-device)

Resource Preparation:

Ensure the target VPC/subnet exists

Note source instance ID and volume details

Allocate sufficient EBS snapshot space

Safety Measures:

Take a manual snapshot as backup

Stop production traffic to the source instance

Test in the non-production environment first
