# tfvars legacy (renombrado conceptualmente a `clases`)

Usa el workspace y tfvars oficiales:

- Workspace: `clases`
- Vars: `../clases/terraform.tfvars`
- Guía: `../clases/README.md`

```bash
cd ../..
./03-deployment-scripts/use-workspace-clases.sh
terraform apply -var-file=environments/clases/terraform.tfvars
```
