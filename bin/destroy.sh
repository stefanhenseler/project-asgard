read -p 'AWS Access Key ID: ' aws_access_key_id
read -p 'AWS Secret Access Key: ' aws_secret_access_key
read -p 'Domain Name: ' dns_name
export AWS_ACCESS_KEY_ID="$aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
export AWS_DEFAULT_REGION="eu-west-1"
export US_CLUSTER_DNS_NAME="us.$dns_name"
export EU_CLUSTER_DNS_NAME="eu.$dns_name"

## US Cluster
export KOPS_STATE_STORE="s3://$US_CLUSTER_DNS_NAME"
kops delete cluster $US_CLUSTER_DNS_NAME --yes
aws s3api delete-bucket --bucket $US_CLUSTER_DNS_NAME

## EU Cluster
export KOPS_STATE_STORE="s3://$EU_CLUSTER_DNS_NAME"
kops delete cluster $EU_CLUSTER_DNS_NAME --yes
aws s3api delete-bucket --bucket $EU_CLUSTER_DNS_NAME