# Welcome to Armageddon!
### Lab 1c
### 1-17-2026

At this point, we're working with a solid Infrastructure as Code (IaC) AWS infrastructure built in Terraform.

After adding our Lambda and Bedrock incident reports in Lab-1b, we've moved our EC2 into a private subnet, placed behind a web-application firewall (WAF), and a public Application Load Balancer (ALB) secured by TLS.

We've also implemented Route 53 to point DNS queries for our app to the ALB, among other items such as VPC Interface Endpoints for:
* SSM, EC2Messages, SSMMessages (Session Manager)
* CloudWatch Logs
* Secrets Manager
* Key Management Service (KMS)

This lab covered how to implement an infrastructure that is production-ready, and built upon defense-in-depth principles.

## Student Deliverables:

### terraform plan output:

<img width="1172" height="598" alt="tf_plan_output" src="https://github.com/user-attachments/assets/7b850b57-743f-4417-9e44-e022706e1046" />

### terraform apply output:

<img width="1380" height="634" alt="tf_apply_output" src="https://github.com/user-attachments/assets/1a61e2d5-5335-49cf-9d87-185ac6bff8b5" />  


### ***See Lab-1b readme for CLI verification commands***

## Student Verification CLI Bonus A

#### 1) Prove EC2 is private (no public IP)   
Expected value = null

        aws ec2 describe-instances \
        --instance-ids <INSTANCE_ID> \
        --query "Reservations[].Instances[].PublicIpAddress"  

<img width="1146" height="97" alt="prove-ec2-private" src="https://github.com/user-attachments/assets/59dae891-92dd-4be5-a5a5-52c814816670" />

#### 2) Prove VPC endpoints exist  

Expected list includes:  
ssm, ec2messages, logs, secretsmanager, s3  

        aws ec2 describe-vpc-endpoints \
        --filters "Name=vpc-id,Values=<VPC_ID>" \
        --query "VpcEndpoints[].ServiceName"  
  
<img width="872" height="277" alt="prove-vpcendpoints-exist" src="https://github.com/user-attachments/assets/f09e0fe4-1249-44ab-a9f7-9e51e8c7dc7b" />


#### 3) Prove Session Manager Path works (no SSH)

Expected: your private EC2 Instance ID appears

        aws ssm describe-instance-information \
        --query "InstanceInformationList[].InstanceId"