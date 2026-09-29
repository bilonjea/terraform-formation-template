# TP Terraform — Construire progressivement une infrastructure AWS

## Objectif pédagogique

Dans cet exercice, vous allez construire **progressivement une infrastructure AWS complète avec Terraform**.

Le but n'est pas de recopier un projet Terraform existant, mais de comprendre comment Terraform permet de passer :

1. d'un projet vide ;
2. à une première ressource AWS ;
3. puis à une infrastructure réseau ;
4. puis à une machine EC2 ;
5. puis à des ressources de stockage ;
6. puis à une base de données RDS ;
7. puis à une fonction Lambda ;
8. et enfin à une configuration Terraform propre, paramétrable et réutilisable.

À la fin du TP, votre infrastructure doit être fonctionnellement équivalente au **template fourni par le formateur**.

> **Principe important :** vous devez avancer étape par étape.  
> Ne recopiez pas tout le template final dès le début. Chaque étape introduit une notion Terraform précise.

---

# 1. Règles du TP

## 1.1 Identifiant stagiaire

Chaque stagiaire reçoit un identifiant unique.

Exemples :

```text
stagiaire01
stagiaire02
stagiaire03
```

Vous devez utiliser **votre identifiant fourni par le formateur**.

Il doit être utilisé dans les noms de ressources et les tags.

Exemple :

```hcl
student_id = "stagiaire01"
```

Vous ne devez pas utiliser l'identifiant d'un autre stagiaire.

---

## 1.2 Région AWS

Pour éviter que les stagiaires créent des ressources dans n'importe quelle région, seules les régions suivantes sont autorisées :

```text
eu-west-3
eu-west-1
eu-central-1
us-east-1
```

La région utilisée pendant le TP est celle indiquée par le formateur.

Dans l'exemple de référence :

```hcl
aws_region = "eu-west-1"
```

> Ne choisissez pas une autre région simplement parce qu'elle apparaît dans un exemple trouvé sur Internet.

---

## 1.3 Zone de disponibilité

La zone de disponibilité doit être cohérente avec la région choisie.

Exemple pour `eu-west-1` :

```text
eu-west-1a
```

---

## 1.4 Tags obligatoires

Toutes les ressources doivent respecter les tags communs de la formation.

Le template final utilise :

```text
Formation = terraform
Session   = <session_id>
Student   = <student_id>
ManagedBy = terraform
```

Ces tags doivent être appliqués de manière centralisée avec le mécanisme Terraform prévu à cet effet.

Vous devez également conserver un tag `Name` permettant d'identifier clairement chaque ressource.

Exemple :

```text
tf-formation-stagiaire01-vpc-demo
tf-formation-stagiaire01-ec2-demo
tf-formation-stagiaire01-sg-demo
```

---

## 1.5 Contraintes générales

Vous devez :

- utiliser Terraform ;
- utiliser le provider AWS ;
- utiliser des variables plutôt que de coder en dur les valeurs propres au stagiaire ;
- utiliser des références Terraform entre les ressources ;
- produire des outputs utiles ;
- respecter les conventions de nommage ;
- conserver les tags obligatoires ;
- respecter les régions autorisées ;
- ne pas créer de ressources inutilement coûteuses ;
- détruire l'infrastructure à la fin du TP lorsque le formateur vous le demande.

---

# 2. Architecture cible

À la fin du TP, vous devez obtenir une architecture proche de celle-ci :

```text
                         AWS
                          |
                          |
                 +------------------+
                 |       VPC        |
                 |   10.10.0.0/16   |
                 +------------------+
                    |            |
                    |            |
             Public subnet     RDS subnet
             10.10.1.0/24     10.10.2.0/24
                    |            |
              +-----------+   +-----------+
              |    EC2    |   |    RDS    |
              |   Nginx   |   |   MySQL   |
              +-----------+   +-----------+
                    |
                    |
             Internet Gateway

                  +------+
                  |  S3  |
                  +------+

                  +--------+
                  | Lambda |
                  +--------+
```

L'architecture finale contient notamment :

- 1 VPC ;
- 1 Internet Gateway ;
- 1 subnet public ;
- 1 route table publique ;
- 1 association subnet / route table ;
- 1 Security Group pour l'EC2 ;
- 1 instance EC2 ;
- 1 bucket S3 ;
- le versioning S3 ;
- 1 subnet supplémentaire pour RDS ;
- 1 DB subnet group ;
- 1 Security Group RDS ;
- 1 instance RDS MySQL ;
- 1 mot de passe généré par Terraform ;
- 1 rôle IAM pour Lambda ;
- 1 fonction Lambda ;
- 1 URL publique Lambda ;
- des outputs permettant de récupérer les informations importantes.

---

# 3. Organisation conseillée des fichiers

Vous pouvez organiser progressivement votre projet comme ceci :

```text
terraform-training/
│
├── provider.tf
├── variables.tf
├── locals.tf
├── network.tf
├── main.tf
├── s3.tf
├── rds.tf
├── lambda.tf
├── outputs.tf
│
├── lambda_function.py
│
├── terraform.tfvars
└── terraform.tfvars.example
```

Au début du TP, tous ces fichiers ne sont pas nécessaires.

Vous allez les créer au fur et à mesure.

---

# 4. Étape 0 — Préparer le projet

## Objectif

Créer un projet Terraform minimal.

Créez un répertoire de travail :

```bash
mkdir terraform-training
cd terraform-training
```

Initialisez Git si cela fait partie de votre environnement de formation :

```bash
git init
```

Créez ensuite un premier fichier :

```text
provider.tf
```

---

# 5. Étape 1 — Déclarer Terraform et le provider AWS

## Objectif pédagogique

Découvrir :

- `terraform {}`;
- `required_version`;
- `required_providers`;
- le provider AWS ;
- `terraform init`.

Votre première mission est de déclarer Terraform et le provider AWS.

Le template final utilise :

```text
Terraform >= 1.5.0
AWS provider ~> 6.0
```

Vous devez donc déclarer une contrainte de version cohérente avec le template.

Le provider AWS doit utiliser une région provenant d'une variable :

```hcl
provider "aws" {
  region = var.aws_region
}
```

### À faire

1. Déclarer la version minimale de Terraform.
2. Déclarer le provider AWS.
3. Déclarer la variable `aws_region`.
4. Initialiser Terraform :

```bash
terraform init
```

5. Vérifier la configuration :

```bash
terraform validate
```

### Question

Pourquoi est-il préférable de déclarer la version du provider plutôt que de laisser Terraform choisir automatiquement n'importe quelle version ?

---

# 6. Étape 2 — Première variable

## Objectif pédagogique

Comprendre :

- `variable`;
- `type`;
- `default`;
- `terraform.tfvars`;
- séparation entre code et configuration.

Créez :

```text
variables.tf
```

Ajoutez progressivement une variable pour :

```text
aws_region
```

Puis créez :

```text
terraform.tfvars
```

Exemple :

```hcl
aws_region = "eu-west-1"
```

### Vérification

Exécutez :

```bash
terraform plan
```

À ce stade, il est normal que Terraform ne crée encore aucune ressource.

### Question

Quelle est la différence entre :

```hcl
variable "aws_region" {}
```

et :

```hcl
aws_region = "eu-west-1"
```

---

# 7. Étape 3 — Ajouter l'identifiant stagiaire

## Objectif pédagogique

Commencer à rendre l'infrastructure personnalisable.

Ajoutez une variable :

```text
student_id
```

Cette variable doit :

- être de type `string` ;
- être obligatoire ;
- respecter le format :

```text
stagiaire01
stagiaire02
stagiaire03
...
```

Le template final utilise une validation Terraform avec une expression régulière.

### Exemple de configuration

Dans `terraform.tfvars` :

```hcl
student_id = "stagiaire01"
```

> Remplacez cette valeur par **l'identifiant qui vous a été fourni**.

### Question

Pourquoi utiliser une validation Terraform plutôt que simplement demander au stagiaire de respecter le format ?

---

# 8. Étape 4 — Ajouter le suffixe de ressources

## Objectif pédagogique

Découvrir une deuxième variable permettant de différencier les ressources.

Ajoutez :

```text
resource_suffix
```

Exemple :

```hcl
resource_suffix = "demo"
```

Cette variable doit accepter uniquement :

```text
minuscules
chiffres
tirets
```

Exemples valides :

```text
demo
tp1
web-demo
rds01
```

Exemples invalides :

```text
Demo
demo_01
demo 01
```

Ajoutez une validation Terraform.

---

# 9. Étape 5 — Créer les locals et les tags communs

## Objectif pédagogique

Découvrir :

- `locals`;
- factorisation ;
- `default_tags`;
- construction dynamique de noms.

Créez :

```text
locals.tf
```

Vous devez construire un préfixe commun :

```text
tf-formation-<student_id>
```

Par exemple :

```text
tf-formation-stagiaire01
```

Vous devez également définir les tags communs :

```text
Formation = terraform
Session   = <session_id>
Student   = <student_id>
ManagedBy = terraform
```

Ajoutez ensuite ces tags au provider AWS via :

```hcl
default_tags
```

### Question importante

Pourquoi est-il préférable d'utiliser `default_tags` pour les tags communs plutôt que de recopier les quatre mêmes tags dans chaque ressource ?

---

# 10. Étape 6 — Créer le VPC

## Objectif pédagogique

Créer votre première vraie ressource AWS.

Ajoutez :

```text
vpc_cidr
```

avec la valeur par défaut :

```text
10.10.0.0/16
```

Puis créez :

```hcl
resource "aws_vpc" "main" {
    ...
}
```

Le VPC doit :

- utiliser `var.vpc_cidr` ;
- activer le DNS support ;
- activer les DNS hostnames ;
- avoir un tag `Name`.

Le nom attendu doit suivre la convention :

```text
tf-formation-<student_id>-vpc-<resource_suffix>
```

### Commandes

```bash
terraform fmt
terraform validate
terraform plan
```

Puis :

```bash
terraform apply
```

### Vérification

Vérifiez dans AWS que le VPC a été créé dans la région attendue.

---

# 11. Étape 7 — Ajouter l'Internet Gateway

## Objectif pédagogique

Comprendre qu'un VPC n'est pas automatiquement connecté à Internet.

Créez :

```hcl
resource "aws_internet_gateway" "igw" {
    ...
}
```

La ressource doit utiliser la référence :

```hcl
aws_vpc.main.id
```

### Point pédagogique

Ne recopiez pas l'identifiant réel du VPC.

Mauvaise approche :

```hcl
vpc_id = "vpc-0123456789"
```

Bonne approche :

```hcl
vpc_id = aws_vpc.main.id
```

### Question

Pourquoi cette deuxième approche est-elle importante dans Terraform ?

---

# 12. Étape 8 — Créer le subnet public

## Objectif pédagogique

Découvrir les dépendances entre ressources.

Ajoutez :

```text
public_subnet_cidr
```

Valeur par défaut :

```text
10.10.1.0/24
```

Ajoutez également :

```text
availability_zone
```

Exemple :

```text
eu-west-1a
```

Créez :

```hcl
resource "aws_subnet" "public" {
    ...
}
```

Le subnet doit :

- appartenir au VPC ;
- utiliser `var.public_subnet_cidr` ;
- utiliser `var.availability_zone` ;
- activer l'attribution automatique d'une IP publique ;
- avoir un `Name`.

---

# 13. Étape 9 — Route table publique

## Objectif pédagogique

Comprendre le routage AWS.

Créez :

```hcl
resource "aws_route_table" "public" {
    ...
}
```

Ajoutez une route :

```text
0.0.0.0/0
```

vers l'Internet Gateway.

Puis créez :

```hcl
resource "aws_route_table_association" "public" {
    ...
}
```

pour associer la route table au subnet public.

### À retenir

Le chemin logique devient :

```text
Internet
   |
Internet Gateway
   |
Route Table
   |
Subnet public
```

---

# 14. Étape 10 — Security Group Web

## Objectif pédagogique

Créer un Security Group avec plusieurs règles.

Créez :

```hcl
resource "aws_security_group" "web" {
    ...
}
```

Il doit autoriser :

### SSH

```text
TCP / 22
```

depuis :

```text
var.allowed_ssh_cidrs
```

Créez donc également cette variable :

```hcl
variable "allowed_ssh_cidrs" {
    type = list(string)
}
```

Valeur de formation :

```hcl
allowed_ssh_cidrs = ["0.0.0.0/0"]
```

### HTTP

```text
TCP / 80
```

depuis Internet.

### Sortie

Autoriser le trafic sortant.

---

# 15. Étape 11 — Créer l'instance EC2

## Objectif pédagogique

Mettre en pratique :

- variables ;
- références ;
- Security Groups ;
- subnet ;
- user data ;
- tags ;
- outputs.

Ajoutez les variables :

```text
ami_id
instance_type
key_pair_name
```

Le type par défaut doit être :

```text
t3.micro
```

L'AMI est fournie par le formateur.

> **Attention : l'AMI est dépendante de la région AWS.**  
> Utilisez l'AMI fournie pour la région du TP. Ne remplacez pas l'identifiant par un exemple trouvé dans un ancien support.

Créez ensuite :

```hcl
resource "aws_instance" "web" {
    ...
}
```

La machine doit :

- utiliser l'AMI fournie ;
- utiliser `var.instance_type` ;
- être placée dans le subnet public ;
- utiliser le Security Group Web ;
- obtenir une IP publique ;
- installer Nginx avec `user_data`.

La page Web doit afficher l'identifiant du stagiaire.

Exemple :

```html
<h1>Formation Terraform - stagiaire01</h1>
```

### Vérification

Après :

```bash
terraform apply
```

récupérez l'adresse IP publique de l'instance dans AWS.

Testez :

```text
http://<IP_PUBLIQUE>
```

---

# 16. Étape 12 — Ajouter les outputs EC2

## Objectif pédagogique

Comprendre les `output`.

Créez :

```text
outputs.tf
```

Exposez :

```text
vpc_id
subnet_id
security_group_id
instance_id
instance_public_ip
instance_public_dns
```

Exemple :

```hcl
output "instance_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.web.public_ip
}
```

Après le `apply`, utilisez :

```bash
terraform output
```

ou :

```bash
terraform output instance_public_ip
```

### Question

Quelle est la différence entre une variable et un output ?

---

# 17. Étape 13 — Créer un bucket S3

## Objectif pédagogique

Découvrir une ressource indépendante de l'architecture réseau.

Créez :

```text
s3.tf
```

Le bucket doit avoir un nom construit à partir de :

```text
student_id
resource_suffix
```

Le nom doit être converti en minuscules.

### Problème à résoudre

Les noms de buckets S3 doivent être uniques.

Vous devez donc utiliser une ressource `random_id` pour ajouter un suffixe aléatoire.

Le résultat doit être de la forme :

```text
tf-formation-stagiaire01-s3-demo-xxxx
```

---

# 18. Étape 14 — Activer le versioning S3

## Objectif pédagogique

Comprendre qu'une ressource Terraform peut être complétée par une ressource associée.

Ajoutez le versioning du bucket.

Le résultat attendu :

```text
Bucket S3
   |
   +--- Versioning = Enabled
```

### Vérification

Dans AWS S3, vérifiez que le versioning est activé.

---

# 19. Étape 15 — Préparer RDS

## Objectif pédagogique

Construire une architecture réseau permettant d'héberger une base de données.

Vous allez maintenant ajouter un deuxième subnet :

```text
10.10.2.0/24
```

Ce subnet sera utilisé pour RDS.

### Nouveauté

Au lieu de coder directement une Availability Zone, vous allez interroger AWS avec une data source :

```hcl
data "aws_availability_zones" "available" {
    ...
}
```

Vous pourrez ensuite utiliser une zone disponible récupérée dynamiquement.

### Question

Quelle différence faites-vous entre :

```hcl
resource
```

et :

```hcl
data
```

---

# 20. Étape 16 — DB Subnet Group

Créez :

```hcl
resource "aws_db_subnet_group" "rds" {
    ...
}
```

Il doit utiliser deux subnets :

```text
subnet public
subnet RDS
```

Réutilisez les IDs Terraform des ressources déjà créées.

Ne recopiez aucun ID AWS réel.

---

# 21. Étape 17 — Security Group RDS

Créez un deuxième Security Group :

```text
aws_security_group.rds
```

Il doit autoriser :

```text
TCP / 3306
```

uniquement depuis le Security Group Web.

La règle doit donc utiliser une référence Terraform au Security Group EC2.

### Important

Le principe recherché est :

```text
Internet
   |
   v
EC2 : port 80
   |
   v
RDS : port 3306
```

La base de données ne doit pas être directement accessible depuis Internet.

---

# 22. Étape 18 — Générer automatiquement le mot de passe RDS

## Objectif pédagogique

Découvrir un deuxième provider Terraform.

Le template utilise le provider :

```text
hashicorp/random
```

Ajoutez une ressource :

```hcl
random_password
```

Elle doit générer un mot de passe suffisamment long pour la base de données.

Le mot de passe ne doit pas être écrit directement en clair dans `rds.tf`.

Vous devez ensuite utiliser :

```hcl
random_password.rds.result
```

comme mot de passe RDS.

---

# 23. Étape 19 — Créer RDS MySQL

Créez :

```hcl
resource "aws_db_instance" "training" {
    ...
}
```

Configuration attendue :

```text
Engine            : mysql
Instance class    : db.t3.micro
Storage            : 20 Go
Storage type       : gp3
Database name      : formation
Username           : admin
Publicly accessible: false
Multi-AZ            : false
Backup retention    : 0
```

Pour le TP, la suppression doit être simplifiée afin d'éviter de laisser une ressource RDS bloquée :

```text
skip_final_snapshot = true
deletion_protection = false
```

> Ces paramètres sont adaptés à un environnement de formation. Ils ne constituent pas une recommandation générale pour une base de données de production.

---

# 24. Étape 20 — Ajouter les outputs RDS

Ajoutez :

```text
rds_endpoint
rds_port
rds_instance_id
```

Exemple :

```hcl
output "rds_endpoint" {
  description = "Endpoint de l'instance RDS"
  value       = aws_db_instance.training.address
}
```

### Question

Pourquoi ne pas mettre le mot de passe RDS dans un output ?

Réfléchissez notamment à la gestion des secrets et au state Terraform.

---

# 25. Étape 21 — Préparer Lambda

## Objectif pédagogique

Découvrir :

- un fichier de code applicatif externe ;
- `archive_file` ;
- IAM ;
- Lambda ;
- une URL de fonction.

Créez :

```text
lambda_function.py
```

La fonction doit retourner une réponse HTTP simple.

Exemple de résultat attendu :

```text
Hello from AWS Lambda!
Application Web créée avec Terraform.
```

---

# 26. Étape 22 — Archiver le code Lambda

Le code Python doit être transformé en archive ZIP avant d'être envoyé à AWS Lambda.

Utilisez le provider :

```text
hashicorp/archive
```

et une data source :

```hcl
data "archive_file" "lambda" {
    ...
}
```

Le résultat doit produire :

```text
lambda_function.zip
```

---

# 27. Étape 23 — Créer le rôle IAM Lambda

## Objectif pédagogique

Comprendre qu'une Lambda doit disposer d'un rôle IAM.

Vous devez :

1. créer une policy d'assume role ;
2. créer un rôle IAM ;
3. permettre au service Lambda de l'assumer.

Le principal doit être :

```text
lambda.amazonaws.com
```

L'action attendue est :

```text
sts:AssumeRole
```

---

# 28. Étape 24 — Créer la Lambda

Créez :

```hcl
resource "aws_lambda_function" "web" {
    ...
}
```

Configuration attendue :

```text
runtime     : python3.12
handler     : lambda_function.lambda_handler
timeout     : 10 secondes
memory_size : 128 MB
```

Le fichier ZIP doit être celui généré précédemment.

Ajoutez également :

```hcl
source_code_hash
```

afin que Terraform puisse détecter les changements du code source.

---

# 29. Étape 25 — Ajouter une Function URL

Créez :

```hcl
resource "aws_lambda_function_url" "web" {
    ...
}
```

La fonction doit être accessible via une URL publique.

La configuration attendue utilise :

```text
authorization_type = NONE
```

> Cette configuration est utilisée ici uniquement pour simplifier le TP. Une application réelle doit prendre en compte les exigences d'authentification et de sécurité.

Ajoutez ensuite un output :

```text
lambda_web_url
```

---

# 30. Étape 26 — Finaliser les variables

À ce stade, votre projet doit avoir au minimum les variables suivantes :

| Variable | Rôle |
|---|---|
| `aws_region` | Région AWS |
| `availability_zone` | Zone de disponibilité |
| `student_id` | Identifiant stagiaire |
| `resource_suffix` | Suffixe des ressources |
| `session_id` | Session de formation |
| `vpc_cidr` | CIDR du VPC |
| `public_subnet_cidr` | CIDR du subnet public |
| `allowed_ssh_cidrs` | Sources autorisées en SSH |
| `ami_id` | AMI EC2 |
| `instance_type` | Type EC2 |
| `key_pair_name` | Key pair AWS |

Ajoutez les validations nécessaires.

---

# 31. Étape 27 — Créer terraform.tfvars.example

Ne fournissez pas votre configuration personnelle comme seul exemple.

Créez :

```text
terraform.tfvars.example
```

Exemple :

```hcl
student_id         = "stagiaire01"
resource_suffix    = "demo"
aws_region         = "eu-west-1"
availability_zone  = "eu-west-1a"
ami_id             = "ami-xxxxxxxxxxxxxxxxx"
instance_type      = "t3.micro"
key_pair_name      = ""
allowed_ssh_cidrs  = ["0.0.0.0/0"]
```

Le stagiaire doit ensuite créer son propre :

```text
terraform.tfvars
```

avec les valeurs qui lui sont attribuées.

---

# 32. Étape 28 — Vérification Terraform complète

Avant de considérer le TP comme terminé, exécutez dans cet ordre :

```bash
terraform fmt -recursive
```

Puis :

```bash
terraform validate
```

Puis :

```bash
terraform plan
```

Vérifiez attentivement le plan.

Vous devez pouvoir expliquer :

- quelles ressources seront créées ;
- quelles ressources dépendent d'autres ressources ;
- quelles valeurs viennent des variables ;
- quels noms sont construits avec les locals ;
- quels tags sont appliqués automatiquement.

---

# 33. Étape 29 — Déployer

Lorsque le plan est compris :

```bash
terraform apply
```

Puis confirmez l'application.

Après le déploiement :

```bash
terraform output
```

Vous devez pouvoir récupérer notamment :

```text
vpc_id
subnet_id
security_group_id
instance_id
instance_public_ip
instance_public_dns
bucket_name
rds_endpoint
rds_port
rds_instance_id
lambda_web_url
```

---

# 34. Étape 30 — Vérifications fonctionnelles

## EC2

Vérifiez :

```text
EC2 créée
IP publique disponible
Nginx installé
page Web accessible
```

La page doit contenir votre identifiant stagiaire.

---

## S3

Vérifiez :

```text
bucket créé
nom unique
versioning activé
```

---

## RDS

Vérifiez :

```text
RDS MySQL créée
RDS non accessible publiquement
port 3306
DB subnet group présent
Security Group RDS présent
```

---

## Lambda

Vérifiez :

```text
Lambda créée
runtime Python 3.12
URL publique disponible
réponse HTTP correcte
```

---

# 35. Étape 31 — Lire le graphe Terraform

Terraform peut représenter les dépendances entre ressources.

Exécutez :

```bash
terraform graph
```

Si Graphviz est disponible :

```bash
terraform graph | dot -Tpng > graph.png
```

Analysez notamment les dépendances :

```text
VPC
 |
 +--> Internet Gateway
 |
 +--> Subnet
 |      |
 |      +--> Route Table
 |      |
 |      +--> EC2
 |
 +--> Security Group
 |
 +--> RDS subnet
        |
        +--> DB subnet group
        |
        +--> RDS
```

### Question

Dans quelles situations Terraform sait-il automatiquement qu'une ressource doit être créée avant une autre ?

---

# 36. Étape 32 — Identifier les dépendances implicites

Examinez par exemple :

```hcl
subnet_id = aws_subnet.public.id
```

Terraform comprend que l'instance EC2 dépend du subnet.

De même :

```hcl
vpc_id = aws_vpc.main.id
```

exprime une dépendance envers le VPC.

Et :

```hcl
password = random_password.rds.result
```

exprime une dépendance envers la génération du mot de passe.

### Objectif

Être capable d'expliquer le graphe de dépendances sans utiliser systématiquement `depends_on`.

---

# 37. Étape 33 — Comprendre le state

Inspectez l'état Terraform :

```bash
terraform state list
```

Puis :

```bash
terraform state show aws_instance.web
```

Observez les informations enregistrées par Terraform.

### Questions

1. Pourquoi Terraform conserve-t-il un state ?
2. Comment Terraform sait-il qu'une ressource existe déjà ?
3. Que se passerait-il si le state était perdu ?
4. Pourquoi le state doit-il être protégé ?

---

# 38. Étape 34 — Modifier une ressource

Modifiez par exemple :

```hcl
instance_type = "t3.micro"
```

puis testez une autre valeur autorisée par le formateur.

Exécutez :

```bash
terraform plan
```

Observez :

```text
~ update in-place
```

ou éventuellement une autre stratégie selon la propriété modifiée.

### Objectif pédagogique

Comprendre que Terraform ne se contente pas de créer des ressources.

Il compare :

```text
configuration
      +
state
      +
état réel AWS
```

afin de déterminer les changements nécessaires.

---

# 39. Étape 35 — Expérimentation avec les variables

Modifiez temporairement :

```text
resource_suffix
```

par exemple :

```text
demo2
```

Puis :

```bash
terraform plan
```

Observez quelles ressources sont impactées.

### Question

Pourquoi un simple changement de suffixe peut-il entraîner la recréation de plusieurs ressources ?

---

# 40. Étape 36 — Détruire l'infrastructure

Lorsque le formateur vous donne le feu vert :

```bash
terraform destroy
```

Avant de confirmer, lisez le plan de destruction.

### Vérifications après destruction

Vérifiez dans AWS :

- EC2 ;
- VPC ;
- subnets ;
- Security Groups ;
- S3 ;
- RDS ;
- Lambda ;
- IAM.

> **Attention particulière au S3 :** le bucket du TP utilise le versioning. Un bucket contenant encore des versions ou des delete markers peut empêcher sa suppression.

---

# 41. Challenge 1 — Ajouter un output

Ajoutez un output indiquant le nom du bucket S3.

Objectif :

```bash
terraform output bucket_name
```

doit retourner son nom.

---

# 42. Challenge 2 — Ajouter une variable

Ajoutez une variable :

```text
environment
```

avec par exemple :

```text
training
```

Utilisez-la dans les tags.

---

# 43. Challenge 3 — Améliorer les validations

Ajoutez des validations pour empêcher :

- une région non autorisée ;
- un identifiant stagiaire incorrect ;
- un suffixe contenant des caractères invalides.

Testez volontairement des valeurs incorrectes.

Objectif :

```bash
terraform plan
```

doit échouer avec un message compréhensible.

---

# 44. Challenge 4 — Comprendre `for_each`

Le template fourni n'utilise pas `for_each` pour cette infrastructure.

Votre mission est de créer un petit exemple séparé permettant de créer plusieurs ressources à partir d'une collection.

Par exemple :

```hcl
students = {
  stagiaire01 = "..."
  stagiaire02 = "..."
}
```

L'objectif est de comprendre la différence entre :

```text
ressource unique
```

et :

```text
collection de ressources
```

Ne modifiez pas l'architecture principale si le formateur vous demande de la conserver telle quelle.

---

# 45. Challenge 5 — Import Terraform

Une ressource AWS créée manuellement doit être récupérée dans Terraform.

Le formateur vous fournira une ressource à importer.

Vous devrez :

1. identifier la ressource AWS ;
2. écrire le bloc Terraform correspondant ;
3. utiliser `terraform import` ;
4. exécuter `terraform plan` ;
5. analyser les différences restantes.

### Objectif pédagogique

Comprendre la différence entre :

```text
ressource existante dans AWS
```

et :

```text
ressource connue et gérée par Terraform
```

---

# 46. Challenge 6 — Diagnostiquer un plan inattendu

Le formateur peut volontairement modifier une propriété AWS ou Terraform.

Votre mission :

```bash
terraform plan
```

puis déterminer :

- ce qui a changé ;
- pourquoi Terraform le détecte ;
- si Terraform va modifier ou recréer la ressource ;
- quelle configuration doit être corrigée.

---

# 47. Checklist finale

Avant de terminer, vérifiez que votre projet contient :

### Terraform

- [ ] `terraform init` fonctionne
- [ ] `terraform fmt` ne signale pas de problème
- [ ] `terraform validate` fonctionne
- [ ] `terraform plan` est compris
- [ ] `terraform apply` fonctionne
- [ ] `terraform destroy` fonctionne

### Variables

- [ ] `aws_region`
- [ ] `availability_zone`
- [ ] `student_id`
- [ ] `resource_suffix`
- [ ] `session_id`
- [ ] `vpc_cidr`
- [ ] `public_subnet_cidr`
- [ ] `allowed_ssh_cidrs`
- [ ] `ami_id`
- [ ] `instance_type`
- [ ] `key_pair_name`

### Réseau

- [ ] VPC
- [ ] Internet Gateway
- [ ] subnet public
- [ ] route table
- [ ] association route table
- [ ] Security Group Web

### EC2

- [ ] EC2
- [ ] IP publique
- [ ] Nginx
- [ ] page Web
- [ ] identifiant stagiaire visible

### S3

- [ ] bucket
- [ ] nom unique
- [ ] versioning

### RDS

- [ ] subnet RDS
- [ ] DB subnet group
- [ ] Security Group RDS
- [ ] mot de passe généré
- [ ] RDS MySQL
- [ ] RDS non publique

### Lambda

- [ ] code Python
- [ ] archive ZIP
- [ ] rôle IAM
- [ ] Lambda
- [ ] Function URL

### Outputs

- [ ] VPC ID
- [ ] subnet ID
- [ ] Security Group ID
- [ ] EC2 ID
- [ ] IP publique
- [ ] DNS public
- [ ] bucket
- [ ] endpoint RDS
- [ ] port RDS
- [ ] ID RDS
- [ ] URL Lambda

---

# 48. Critère de réussite

Le TP est terminé lorsque vous êtes capable de reconstruire l'infrastructure finale **sans recopier le template**, et d'expliquer oralement :

1. pourquoi chaque ressource existe ;
2. quelles variables elle utilise ;
3. quelles ressources elle référence ;
4. comment Terraform détermine les dépendances ;
5. comment les tags sont appliqués ;
6. comment les outputs récupèrent les informations AWS ;
7. comment Terraform détecte les changements ;
8. comment le state intervient ;
9. comment détruire proprement l'infrastructure.

Le résultat final doit respecter les contraintes de la formation :

```text
Identifiant stagiaire
        +
Région autorisée
        +
Tags obligatoires
        +
Nommage imposé
        +
Variables
        +
Validation
        +
Infrastructure AWS
        +
Outputs
```

---

# 49. Livrable

À la fin du TP, remettez le répertoire Terraform contenant au minimum :

```text
provider.tf
version.tf
variables.tf
locals.tf
network.tf
main.tf
s3.tf
rds.tf
lambda.tf
outputs.tf
lambda_function.py
terraform.tfvars.example
README.md
```

Ne fournissez pas de secrets ou de credentials AWS dans le dépôt.

Le fichier :

```text
terraform.tfvars
```

peut rester local s'il contient des valeurs propres à votre environnement de formation.

---

# Annexe — Correspondance avec le template final

Le template fourni au formateur constitue la **référence fonctionnelle finale**.

| Notion travaillée | Fichier final |
|---|---|
| Provider / versions | `provider.tf` / `version.tf` |
| Variables | `variables.tf` |
| Locals / tags | `locals.tf` |
| Réseau | `network.tf` |
| EC2 | `main.tf` |
| S3 | `s3.tf` |
| RDS | `rds.tf` |
| Lambda | `lambda.tf` |
| Outputs | `outputs.tf` |
| Code Lambda | `lambda_function.py` |

**Consigne finale :** utilisez le template uniquement comme référence de l'état attendu. Le travail consiste à reconstruire progressivement cette architecture et à comprendre chaque notion Terraform introduite.
