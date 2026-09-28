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
```

Destruction des ressources de à la fin du tp

```bash
terraform destroy
```

Autre Commande terraform utils:
```bash
terraform state list
terraform state show nonDuStae
```


```bash
terraform destroy
```


##  géneration d'un nouveau tp
```bash
cp -r _template tp01-mon-exercice
```

```text
Formation Terraform AWS
-----------------------

Student : stagiaire01
Session : TFVPA1-2026-09
Region  : eu-west-3

Les ressources seront créées avec les tags :

Formation = terraform
Student   = stagiaire01
Session   = TFVPA1-2026-09
ManagedBy = terraform
```



## FORMATION TERRAFORM AW=======================
```bash
Identifiant AWS
tf-stagiaire01

AWS Access Key ID
AKIA............

AWS Secret Access Key
....................

Console AWS
https://console.aws.amazon.com/

Utilisateur console
tf-stagiaire01

Mot de passe console
....................

Régions autorisées
eu-west-3
eu-west-1
eu-central-1
us-east-1
```


## Install aws cli ##


## Configuration AWS CLI
```bash
aws configure
```

Puis :

```bash
AWS Access Key ID     → fourni par le formateur
AWS Secret Access Key → fourni par le formateur
Default region        → eu-west-3
Default output        → json
```

## Vérification
```bash
aws sts get-caller-identity
```


Ils voient :
```text
tf-stagiaire01
```

```bash
AWS_PROFILE=stagiaire01 terraform plan
export AWS_PROFILE="stagiaire01"
```


