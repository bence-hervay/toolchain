# Create hyperdisk
gcloud compute disks create boot-hyperdisk-balanced \
  --project=main-69696 \
  --zone=europe-west4-a \
  --type=hyperdisk-balanced \
  --size=32GB \
  --provisioned-iops=3000 \
  --provisioned-throughput=140 \
  --image-family=ubuntu-minimal-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud

# Create persistent disk
gcloud compute disks create boot-pd-standard \
  --project=main-69696 \
  --zone=europe-west4-a \
  --type=pd-standard \
  --size=32GB \
  --image-family=ubuntu-minimal-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud

# Create spot instance
gcloud compute instances create main-spot \
  --project=main-69696 \
  --zone=europe-west4-a \
  --machine-type=c4-standard-2 \
  --provisioning-model=SPOT \
  --deletion-protection \
  --service-account=975169924228-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --metadata=enable-osconfig=TRUE \
  --disk=name=boot-hyperdisk-balanced,boot=yes,auto-delete=no

# Create standard instance
gcloud compute instances create main-standard \
  --project=main-69696 \
  --zone=europe-west4-a \
  --machine-type=c4-standard-2 \
  --deletion-protection \
  --service-account=975169924228-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --metadata=enable-osconfig=TRUE \
  --disk=name=boot-hyperdisk-balanced,boot=yes,auto-delete=no
