# Amazon Connect V2V Translation Terraform

This repository contains a Terraform implementation of the
`connect-v2v-translation-with-cx-options` sample. It keeps the existing
environment layout and replaces the previous Terraform module with
service-specific modules:

- `modules/cognito`
- `modules/iam`
- `modules/s3`
- `modules/cloudfront`
- `modules/ssm`

The copied `webapp` folder is the non-CDK Vite application that Terraform can
build and upload to S3. No CDK stack code, CDK configuration, or CDK-specific
files are required.

## Environments

- Dev: `environments/dev`
- UAT: `environments/uat`

Each environment deploys the V2V application in the selected AWS region. The
service modules create:

- Cognito User Pool, hosted UI domain, and web app client
- Cognito Identity Pool
- Authenticated and unauthenticated Identity Pool IAM roles
- SSM parameters under `/AmazonConnectV2V/`
- S3 webapp bucket and CloudFront log bucket
- CloudFront distribution with S3 Origin Access Control
- Optional CloudFront proxy behaviors for Amazon Polly and Amazon Translate
- `frontend-config.js` in the webapp bucket
- Optional upload of built Vite webapp assets from `webapp/dist`

The Amazon Connect instance itself is treated as an existing prerequisite. Set
`connect_instance_url` and `connect_instance_region` in the environment
`terraform.tfvars` file.

## Configuration

At minimum, review these values in each environment:

```hcl
cognito_domain_prefix   = "globally-unique-domain-prefix"
connect_instance_url    = "https://your-connect-instance.my.connect.aws"
connect_instance_region = "us-east-1"
```

The source project uses a two-step setup for Cognito callback and logout URLs:
deploy once, add the CloudFront `webapp_url` output to the URL lists, then
apply again. Local development URLs remain configurable through:

```hcl
cognito_callback_urls = ["https://localhost:5173"]
cognito_logout_urls   = ["https://localhost:5173"]
```

## Backend

Terraform uses the existing S3 backend shape:

```hcl
terraform {
  backend "s3" {
    use_lockfile = true
  }
}
```

Example init command:

```bash
cd environments/dev

terraform init -reconfigure \
  -backend-config="bucket=bts-cloud-terraform-tfstate" \
  -backend-config="key=terraform-state/dev/us-east-1/connect-v2v-translation/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
```

## Local Build And Validate

Build the webapp before planning when `deploy_webapp_assets = true`:

```bash
cd webapp
npm ci
npm run build
```

Then run Terraform:

```bash
cd ../environments/dev
terraform fmt -recursive ../..
terraform validate
terraform plan
```

The Azure pipeline performs the same webapp build before Terraform plan.

## Post-Deploy

After deployment, add the `webapp_url` output as an approved origin on the
existing Amazon Connect instance. Then create Cognito users in the generated
User Pool for people who should access the demo webapp.
