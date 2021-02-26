This is a working prototype with of an Azure Function that pulls a container image from Azure Container Registry. This includes the Terraform for the Azure infrastructure.

## Prerequisites

- Azure Container Registry already created
- Admin credentials enabled on Azure Container Registry or a Service Principal with permissions to push and build
- Docker installed
- Terraform installed

## Build and push image

Build it:
```
docker build --tag my-container-registry.azurecr.io/my-image-repository/docker-prototype .
```

Push it:
```
docker push my-container-registry.azurecr.io/my-image-repository/docker-prototype
```


## Terraform

Add a `do.tfvar` file that looks something like this:

```hcl
registry_name="my-container-registry"
app_name="my-azure-function"
creds_acr={
  username="<azure container registry (service principal or something) username>"
  password="<azure container registry (service principal or something) password>"
}
```

Then you can run this command to apply:

```
terraform apply -var-file="do.tfvars"
```
