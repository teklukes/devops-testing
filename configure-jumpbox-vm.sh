#Imported from Template
#!/bin/bash

# Pull token config
Token="default"
while getopts "t:" flag; do
    case $flag in
        t)
            Token=$OPTARG
            ;;
    esac
done

# Eliminate debconf warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

#Install kubectl (latest)
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl

# Install helm v3 (latest)
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 &&
  chmod 700 get_helm.sh &&
  ./get_helm.sh

# Install Azure CLI (latest)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Gitlab Runner
sudo curl -L --output /usr/local/bin/gitlab-runner "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64"
sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
sudo systemctl is-active --quiet gitlab-runner
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --token $token \
  --excutor "kubernetes" \
  --description "arda-kub-runner"