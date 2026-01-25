# Welcome to Armageddon!
### Lab 1c
### 1-17-2026

At this point, we're working with a solid Infrastructure as Code (IaC) AWS infrastructure built in Terraform.

After adding our Lambda and Bedrock incident reports in Lab-1b, we've moved our RDS app into a private subnet and moved to using Session Manager to access our EC2 instance, which is placed behind a public facing Application Load Balancer (ALB) secured by TLS, which is in turn placed behind a web-application firewall (WAF).

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
        
<img width="826" height="132" alt="prove-session-mgr-path" src="https://github.com/user-attachments/assets/70869847-f557-4ed7-af11-ac589fe8ff57" />


### 4) Prove the instance can read both config stores

Run from SSM session:  

        aws ssm get-parameter --name /lab/db/endpoint
        aws secretsmanager get-secret-value --secret-id <your-secret-name>  
        
<img width="1186" height="452" alt="aws-ssm-get-param" src="https://github.com/user-attachments/assets/93ca425c-608f-4564-beb2-a477b2bed42d" />


### 5) Prove CloudWatch logs delivery path is available via endpoint

     aws logs describe-log-streams \
    --log-group-name /aws/ec2/<prefix>-rds-app  

<img width="1107" height="276" alt="cloudwatch-logs-delivery-path" src="https://github.com/user-attachments/assets/721d28ab-c650-4bcc-90c9-297e306f4157" />

##  

## Student Verification CLI Bonus B

Key Additions:
* Securing a domain with AWS Certificate Manager (ACM) + TLS
* Route 53 Hosting and ACM Validation
* CloudWatch Dashboards
* SNS Alarms

### 1) ALB exists and is active
        aws elbv2 describe-load-balancers \
        --names chewbacca-alb01 \
        --query "LoadBalancers[0].State.Code"  
        
<img width="972" height="130" alt="verify-alb-active" src="https://github.com/user-attachments/assets/98de6257-5769-4595-9651-ff9c06fe6935" />

### 2) HTTPS listener exists on 443
        aws elbv2 describe-listeners \
        --load-balancer-arn <ALB_ARN> \
        --query "Listeners[].Port"  
        
<img width="913" height="160" alt="listener-exists" src="https://github.com/user-attachments/assets/241d0966-ced2-423e-a50e-e11136869a09" />

### 3) Target is healthy
        aws elbv2 describe-target-health \
        --target-group-arn <TG_ARN>  
        
<img width="1123" height="396" alt="target-is-healthy" src="https://github.com/user-attachments/assets/3e81612b-b672-4815-9b01-acfe678f0409" />

### 4) WAF Attached
        aws wafv2 get-web-acl-for-resource \
        --resource-arn <ALB_ARN>  
        
<img width="1355" height="820" alt="waf-attached" src="https://github.com/user-attachments/assets/aebb2cab-0439-419b-898b-67320b4ed2b1" />

### 5) Alarm created (ALB 5xx)
        aws cloudwatch describe-alarms \
        --alarm-name-prefix chewbacca-alb-5xx  
        
<img width="923" height="654" alt="alarm-created" src="https://github.com/user-attachments/assets/bc8dfd84-1d59-4ff6-ba53-485726a9a47b" />

### 6) Dashboard exists
        aws cloudwatch list-dashboards \
        --dashboard-name-prefix chewbacca  
        
<img width="999" height="233" alt="cloudwatch-list-dashboards" src="https://github.com/user-attachments/assets/73073133-14d7-48b8-bbaf-f4bc3f1fde3d" />

---

## Student Verification CLI Bonus C

Highlighting the usage of DNS Validation with AWS Certificate Manager, ensuring validation completes before listener creation:

<img width="1095" height="793" alt="dns_validation_with_acm" src="https://github.com/user-attachments/assets/dcd7cda1-41f5-478b-8283-2ea5a91204d3" />


### 1) Confirm hosted zone exists (if managed)

    aws route53 list-hosted-zones-by-name \
    --dns-name chewbacca-growl.com \
    --query "HostedZones[].Id"  
    
<img width="1065" height="177" alt="confirm-hosted-zone" src="https://github.com/user-attachments/assets/d5d1e913-693f-441b-bbbc-49d55de765e8" />

### 2) Confirm app record exists

    aws route53 list-resource-record-sets \
    --hosted-zone-id <ZONE_ID> \
    --query "ResourceRecordSets[?Name=='app.chewbacca-growl.com.']"  

<img width="1116" height="240" alt="confirm-app-record" src="https://github.com/user-attachments/assets/2c9ad532-e39a-4119-b460-7c23a17bf327" />

### 3) Confirm certificate issued
Expected: ISSUED

    aws acm describe-certificate \
    --certificate-arn <CERT_ARN> \
    --query "Certificate.Status"  

<img width="1003" height="106" alt="confirm-cert-issued" src="https://github.com/user-attachments/assets/b13d061f-2616-4c4e-9a9d-6fd33e17eabc" />


### 4) Confirm HTTPS works
Expected: HTTP/1.1 200 (or 301 then 200 depending on your app)

    curl -I https://app.chewbacca-growl.com 

<img width="855" height="172" alt="curl-i" src="https://github.com/user-attachments/assets/e8933648-bdc8-4155-9af1-fba27bef11b3" />


## Student Verification CLI Bonus D

Enabling Zone apex record to forward traffic to ALB
  
<img width="871" height="336" alt="zone_apex_tf" src="https://github.com/user-attachments/assets/d58b26a6-045c-42a6-981e-b377d0ca5a11" />  


Forwarding ALB access logs to S3 bucket (with required policy)

<img width="985" height="545" alt="secure_s3_resource" src="https://github.com/user-attachments/assets/f9d227a9-62b6-4fa5-8e75-478a10022e33" />  
<img width="927" height="434" alt="alb_resource_s3_logs" src="https://github.com/user-attachments/assets/90881b94-48bd-495d-901f-36d268546899" />  
<img width="1329" height="536" alt="s3_policy" src="https://github.com/user-attachments/assets/e94727c9-a700-4e10-9ae9-a1fcebb005c8" />  


### Verifying DNS + Logs  
### 1) Verify apex record exists
        aws route53 list-resource-record-sets \
    --hosted-zone-id <ZONE_ID> \
    --query "ResourceRecordSets[?Name=='chewbacca-growl.com.']"

### 2) Verify ALB logging is enabled

Expected attributes:  
access_logs.s3.enabled = true  
access_logs.s3.bucket = your bucket  
access_logs.s3.prefix = your prefix  

        aws elbv2 describe-load-balancers \
    --names chewbacca-alb01 \
    --query "LoadBalancers[0].LoadBalancerArn"

Then:

        aws elbv2 describe-load-balancer-attributes \
        --load-balancer-arn <ALB_ARN>

### 3) Generate some traffic

        curl -I https://chewbacca-growl.com
        curl -I https://app.chewbacca-growl.com

### 4) Verify logs arrived in S3 (may take a few minutes)

        aws s3 ls s3://<BUCKET_NAME>/<PREFIX>/AWSLogs/<ACCOUNT_ID>/elasticloadbalancing/ --recursive | head
