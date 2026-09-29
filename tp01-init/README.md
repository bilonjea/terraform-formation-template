## Fichiers
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Utilisation
1. Copier `terraform.tfvars.example` en `terraform.tfvars`
2. Renseigner `student_id`
3. Remplacer `ami_id` par une AMI valide dans votre région
4. Lancer :
   - `terraform init`
   - `terraform plan`
   - `terraform apply`
5. Détruire ensuite :
   - `terraform destroy`

## Convention
Toutes les ressources utilisent :
- un préfixe obligatoire : `tf-formation-${student_id}`
- des tags communs : `Formation`, `Session`, `Student`, `ManagedBy`
- un suffixe libre : `resource_suffix`

## Attention
- Le bucket S3 doit être globalement unique ; un suffixe aléatoire est ajouté.
- Le provider AWS utilise `default_tags` pour propager les tags communs.
- Certaines ressources AWS ont des comportements particuliers selon le provider.



