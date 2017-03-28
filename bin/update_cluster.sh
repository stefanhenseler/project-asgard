read -p 'AWS Access Key ID: ' aws_access_key_id
read -p 'AWS Secret Access Key: ' aws_secret_access_key
read -p 'Domain Name: ' dns_name
read -p 'Cluster Prefix (us or eu): ' cluster_prefix
export AWS_ACCESS_KEY_ID="$aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
export AWS_DEFAULT_REGION="us-east-1"
export CLUSTER_DNS_NAME="$cluster_prefix.$dns_name"


## Update Cluster
kubectl config use-context $CLUSTER_DNS_NAME
export KOPS_STATE_STORE="s3://$CLUSTER_DNS_NAME"
kops edit cluster $CLUSTER_DNS_NAME
kops update cluster $CLUSTER_DNS_NAME --yes
kops rolling-update cluster $CLUSTER_DNS_NAME --yes