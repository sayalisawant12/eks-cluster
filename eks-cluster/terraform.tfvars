aws_region         = "ap-south-1"
cluster_name       = "eks-cluster-mumbai"
k8s_version        = "1.31"
node_instance_type = "t3.medium"
node_count         = 2
s3_bucket          = "my-terraformeks-state-bucket"
s3_key             = "terraform/eks-cluster/terraform.tfstate"
dynamodb_table     = "terraform-lock-table" 
