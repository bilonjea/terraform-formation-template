# Formation

```text
terraform-formation-template/
│
├── README.md
│
├── _template/
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── locals.tf
│   └── terraform.tfvars.example
│
├── tp01-init/
│   ├── README.md
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── main.tf
│   └── terraform.tfvars.example
│
├── tp02-instance/
│   ├── README.md
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── main.tf
│   └── terraform.tfvars.example
│
├── tp03-network/
│
├── tp04-provisioner/
│
└── tp05-vault/
```

## clone du repo

```bash
git clone ...
cd terraform-formation-template/tp01-init
```

Puis :
```bash
cp terraform.tfvars.example terraform.tfvars
```


Modifier :
```bash
student_id = "stagiaire01"
resource_suffix = "demo"
```

Commande terraform:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
terraform apply --auto-approve
terraform distroy
terraform distroy --auto-approve
terraform state list
terraform state show monstate
terraform graph     
terraform --help
```

Destruction des ressources de à la fin du tp
```bash
terraform destroy
```

## Visualisé les ressource via DOT généré par terraform graph
https://graphviz.org/
url : https://dreampuf.github.io/GraphvizOnline


```bash
terraform graph 
output:
digraph G {
  rankdir = "RL";
  node [shape = rect, fontname = "sans-serif"];
  "aws_instance.test" [label="aws_instance.test"];
  "aws_instance.web" [label="aws_instance.web"];
}

```
```bash
terraform graph

output:
digraph G {
  rankdir = "RL";
  node [shape = rect, fontname = "sans-serif"];
  "data.archive_file.lambda" [label="data.archive_file.lambda"];
  "data.aws_availability_zones.available" [label="data.aws_availability_zones.available"];
  "data.aws_iam_policy_document.lambda_assume_role" [label="data.aws_iam_policy_document.lambda_assume_role"];
  "aws_db_instance.training" [label="aws_db_instance.training"];
  "aws_db_subnet_group.rds" [label="aws_db_subnet_group.rds"];
  "aws_iam_role.lambda" [label="aws_iam_role.lambda"];
  "aws_instance.web" [label="aws_instance.web"];
  "aws_internet_gateway.igw" [label="aws_internet_gateway.igw"];
  "aws_lambda_function.web" [label="aws_lambda_function.web"];
  "aws_lambda_function_url.web" [label="aws_lambda_function_url.web"];
  "aws_route_table.public" [label="aws_route_table.public"];
  "aws_route_table_association.public" [label="aws_route_table_association.public"];
  "aws_s3_bucket.training" [label="aws_s3_bucket.training"];
  "aws_s3_bucket_versioning.training" [label="aws_s3_bucket_versioning.training"];
  "aws_security_group.rds" [label="aws_security_group.rds"];
  "aws_security_group.web" [label="aws_security_group.web"];
  "aws_subnet.public" [label="aws_subnet.public"];
  "aws_subnet.rds" [label="aws_subnet.rds"];
  "aws_vpc.main" [label="aws_vpc.main"];
  "random_id.bucket_suffix" [label="random_id.bucket_suffix"];
  "random_password.rds" [label="random_password.rds"];
  "aws_db_instance.training" -> "aws_db_subnet_group.rds";
  "aws_db_instance.training" -> "aws_security_group.rds";
  "aws_db_instance.training" -> "random_password.rds";
  "aws_db_subnet_group.rds" -> "aws_subnet.public";
  "aws_db_subnet_group.rds" -> "aws_subnet.rds";
  "aws_iam_role.lambda" -> "data.aws_iam_policy_document.lambda_assume_role";
  "aws_instance.web" -> "aws_security_group.web";
  "aws_instance.web" -> "aws_subnet.public";
  "aws_internet_gateway.igw" -> "aws_vpc.main";
  "aws_lambda_function.web" -> "data.archive_file.lambda";
  "aws_lambda_function.web" -> "aws_iam_role.lambda";
  "aws_lambda_function_url.web" -> "aws_lambda_function.web";
  "aws_route_table.public" -> "aws_internet_gateway.igw";
  "aws_route_table_association.public" -> "aws_route_table.public";
  "aws_route_table_association.public" -> "aws_subnet.public";
  "aws_s3_bucket.training" -> "random_id.bucket_suffix";
  "aws_s3_bucket_versioning.training" -> "aws_s3_bucket.training";
  "aws_security_group.rds" -> "aws_security_group.web";
  "aws_security_group.web" -> "aws_vpc.main";
  "aws_subnet.public" -> "aws_vpc.main";
  "aws_subnet.rds" -> "data.aws_availability_zones.available";
  "aws_subnet.rds" -> "aws_vpc.main";
}

```


##  géneration d'un nouveau tp
```bash
cp -r _template tp01-mon-exercice
```

```text
Formation Terraform AWS
-----------------------

Student : stagiaire07
Session : TFVPA1-2026-09
Region  : eu-west-3

Les ressources seront créées avec les tags :

Formation = terraform
Student   = stagiaire07
Session   = TFVPA1-2026-09
ManagedBy = terraform
```



## FORMATION TERRAFORM AW=======================
```bash
Identifiant AWS
tf-stagiaire07

AWS Access Key ID
AKIA............

AWS Secret Access Key
....................

Console AWS
https://console.aws.amazon.com/

account-id
Utilisateur : tf-stagiaire07
Mot de passe console
....................

Régions autorisées
eu-west-3
eu-west-1
eu-central-1
us-east-1
```


## Install aws cli ##
```bash
sudo yum install -y awscli
aws --version
```

## Configuration AWS CLI
```bash
aws configure --profile stagiaire07
>>> AWS Access Key ID [Non] : mon access key
>>> AWS Secret Access Key [None]: mon secrete key
>>> Default region name [None] :
>>> Default output format [None]: json
Configure AWS skills and the AWS MCP server for your AI coding agent(s)? [y/n/never]: n

check du fichier géné
cat ~/.aws/credentials
```


```bash
export AWS_PROFILE="stagiaire07"
```
## Vérification
```bash
aws sts get-caller-identity
```

Sortie
```text
{
    "UserId": "userIf",
    "Account": "557170680994",
    "Arn": "arn:aws:iam::557170680994:user/tf-stagiaire07"
}
```
 get-caller-identity
```








