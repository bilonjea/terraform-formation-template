# Import d'une infrastructure existante

## Objectif

┌─────────────────────────┐
│   Infrastructure AWS    │
│   EC2 existante         │
└────────────┬────────────┘
             │
             │ import
             ▼
┌─────────────────────────┐
│    Terraform State      │
│  aws_instance.web       │
└────────────┬────────────┘
             │
             │ plan / comparaison
             ▼
┌─────────────────────────┐
│ Configuration HCL       │
│ main.tf                 │
└─────────────────────────┘



## Contexte

Mettre à jour le HLC partir d'une infa existante

## creation d'une ece via cli



###  Liste des image ubuntu
```bash
aws ec2 describe-images \
  --region eu-west-1 \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
    "Name=state,Values=available" \
  --query 'Images | sort_by(@, &CreationDate)[-5:].[ImageId,Name,CreationDate]' \
  --output table
```

###  Liste des image amazone
```bash
aws ec2 describe-images \
  --region eu-west-1 \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*" \
  --query 'Images | sort_by(@, &CreationDate)[-5:].[ImageId,Name,CreationDate]' \
  --output table
```


### fichier la region
```bash
aws configure set region eu-west-1
aws configure get region
  --output table
```

### La key ssh optionnl
```bash
aws ec2 describe-key-pairs \
  --query 'KeyPairs[*].KeyName' \
  --output table \
  --region eu-west-1

```



## Étape 1 — Observer l'infrastructure AWS
```bash
aws ec2 run-instances \
  --region eu-west-1  \
  --image-id AMI_I \
  --instance-type t3.micro \
  --count 1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Formation,Value=terraform},{Key=Session,Value=TFVPA1-2026-09},{Key=Student,Value=STUDENT_ID},{Key=ManagedBy,Value=manual}]'
```


```bash
aws ec2 run-instances \
  --region eu-west-1  \
  --image-id ami-06b9219be654efe2b \
  --instance-type t3.micro \
  --count 1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Formation,Value=terraform},{Key=Session,Value=TFVPA1-2026-09},{Key=Student,Value=stagiaire07},{Key=ManagedBy,Value=manual}]'
```

### voir les ec2:
```bash
aws ec2 describe-instances \
  --region eu-west-1 \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress]' \
  --output table

  aws ec2 describe-instances \
  --region eu-west-1 \
  --filters "Name=tag:Student,Values=stagiaire07" \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress]' \
  --output table

  aws ec2 describe-instances \
  --region eu-west-1 \
  --filters "Name=tag:Student,Values=stagiaire07"
```

## Étape 2 — Préparer la configuration Terraform


## Étape 3 — Initialiser Terraform
```bash
terraform init
```

## Étape 4 — Importer la ressource

```bash
terraform import aws_instance.web i-xxxxxxxxxxxxxxxxx
```

## Étape 5 — Inspecter le State

```bash
terraform state list
terraform state show ...
```

## Étape 6 — Adapter la configuration
Puis compléter le HCL à partir de ce qu'il découvre dans le State, et enfin :

```hcl
ami= var.ami_id
instance_type = var.instance_type
tags = {
    Name = "${local.name_prefix}-ec2-${var.resource_suffix}"
  }
```


## Étape 7 — Vérifier avec terraform plan
```bash
terraform plan
```


## Résultat attendu

No changes. Your infrastructure matches the configuration.



##  Résumé de la demarche 


EC2 existante → import de l'EC2 → plan → correction de la configuration → éventuellement modification des tags.




## Importer plusieurs ressources

Une infrastructure existante peut être composée de plusieurs ressources AWS liées entre elles : VPC, subnet, security group, EC2, route table, etc.

Terraform permet d'importer ces ressources existantes, mais **chaque ressource doit être importée séparément dans le Terraform State**.

Par exemple :

```bash
terraform import aws_vpc.main vpc-xxxxxxxx
terraform import aws_subnet.public subnet-xxxxxxxx
terraform import aws_security_group.web sg-xxxxxxxx
terraform import aws_instance.web i-xxxxxxxx
```

L'import d'une ressource ne provoque pas automatiquement l'import des ressources auxquelles elle est liée.

Après les imports, on peut vérifier les ressources prises en charge par Terraform avec :

```bash
terraform state list
```

Il faut ensuite s'assurer que les relations entre les ressources sont correctement représentées dans la configuration Terraform. Par exemple :

```hcl
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id
}
```

Ainsi, Terraform connaît à la fois les ressources existantes et leurs dépendances dans la configuration.

> **À retenir :** l'import permet de faire entrer une ressource existante dans le Terraform State. Il ne permet pas d'importer automatiquement toute l'infrastructure associée.






