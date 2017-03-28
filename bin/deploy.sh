read -p 'AWS Access Key ID: ' aws_access_key_id
read -p 'AWS Secret Access Key: ' aws_secret_access_key
read -p 'Domain Name: ' dns_name
read -p 'Domain Name Zone ID: ' dns_zone_id
export AWS_ACCESS_KEY_ID="$aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
export AWS_DEFAULT_REGION="eu-west-1"
export US_CLUSTER_DNS_NAME="us.$dns_name"
export EU_CLUSTER_DNS_NAME="eu.$dns_name"

## Generate SSH Key
ssh-keygen -f id_rsa -t rsa -N ''
mkdir /root/.ssh/
mv id_rsa* /root/.ssh/

## US Cluster
export KOPS_STATE_STORE="s3://$US_CLUSTER_DNS_NAME"
aws s3api create-bucket --bucket $US_CLUSTER_DNS_NAME --region us-east-1
kops create cluster --name $US_CLUSTER_DNS_NAME --master-size=t2.micro --node-size=t2.micro --zones=us-east-1a --dns-zone=$dns_name
kops update cluster $US_CLUSTER_DNS_NAME --yes

## EU Cluster
export KOPS_STATE_STORE="s3://$EU_CLUSTER_DNS_NAME"
aws s3api create-bucket --bucket $EU_CLUSTER_DNS_NAME --region us-east-1
kops create cluster --name $EU_CLUSTER_DNS_NAME --master-size=t2.micro --node-size=t2.micro --zones=eu-west-1a --dns-zone=$dns_name
kops update cluster $EU_CLUSTER_DNS_NAME --yes

echo "Clusters are starting..."
sleep 420

## Federation
kubectl config use-context $US_CLUSTER_DNS_NAME
kubefed init federation --host-cluster-context=$US_CLUSTER_DNS_NAME --dns-provider=aws-route53 --dns-zone-name=$dns_name

echo "Federation starting..."
sleep 360

kubectl config use-context federation
kubefed join eu --host-cluster-context=$US_CLUSTER_DNS_NAME --cluster-context=$EU_CLUSTER_DNS_NAME --secret-name=eusecret
kubefed join us --host-cluster-context=$US_CLUSTER_DNS_NAME --cluster-context=$US_CLUSTER_DNS_NAME --secret-name=ussecret

sleep 30

## Deploy Monitoring
kubectl --context $US_CLUSTER_DNS_NAME create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.2.0.yaml
kubectl --context $EU_CLUSTER_DNS_NAME create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.2.0.yaml

## Deploy Hugo
kubectl --context federation create -f ./k8s

echo "Hugo application is starting..."
sleep 120

## DNS Records
export HUGO_APP_ELB_US=$(kubectl --context=$US_CLUSTER_DNS_NAME get services/hugo-svc --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")
export HUGO_APP_ELB_EU=$(kubectl --context=$EU_CLUSTER_DNS_NAME get services/hugo-svc --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")
sed -i -e 's|"Value": ".*|"Value": "'"${HUGO_APP_ELB_US}"'"|g' dns/hugo_dns_us.json
sed -i -e 's|"Value": ".*|"Value": "'"${HUGO_APP_ELB_EU}"'"|g' dns/hugo_dns_eu.json
sed -i -e 's|DOMAIN_NAME|'"$dns_name"'|g' dns/hugo_dns_us.json
sed -i -e 's|DOMAIN_NAME|'"$dns_name"'|g' dns/hugo_dns_eu.json
aws route53 change-resource-record-sets --hosted-zone-id $dns_zone_id --change-batch file://dns/hugo_dns_us.json
aws route53 change-resource-record-sets --hosted-zone-id $dns_zone_id --change-batch file://dns/hugo_dns_eu.json