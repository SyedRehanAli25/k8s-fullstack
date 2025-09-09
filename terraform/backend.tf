terraform {
  backend "s3" {
    bucket         = "k8s-oneclick-tf-state"      
    key            = "terraform.tfstate"          
    region         = "us-east-1"                   
    dynamodb_table = "k8s-oneclick-tf-lock"        
    encrypt        = true                           
  }
}
