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

<img width="1175" height="755" alt="verify-apex-records" src="https://github.com/user-attachments/assets/c4cb6fa1-99f8-41c3-bf0d-41f0161df7dc" />  

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


<img width="1318" height="611" alt="verify-logging-enabled" src="https://github.com/user-attachments/assets/d0c8dd9c-0466-4c06-b0e8-d7e44a1c13ad" />  

### 3) Generate some traffic

        curl -I https://chewbacca-growl.com
        curl -I https://app.chewbacca-growl.com  
        
<img width="898" height="351" alt="generate-traffic" src="https://github.com/user-attachments/assets/c35fc1ee-3c98-40f5-b698-e86decde3dd5" />

### 4) Verify logs arrived in S3 (may take a few minutes)

        aws s3 ls s3://<BUCKET_NAME>/<PREFIX>/AWSLogs/<ACCOUNT_ID>/elasticloadbalancing/ --recursive | head

<img width="1882" height="218" alt="verify-logs-in-s3" src="https://github.com/user-attachments/assets/71cf46cd-10dd-46a2-a456-3ddcccc3aa52" />  

---

## Student Verification CLI Bonus E

Setting WAF log destination to CloudWatch and log review

### 1) Variable Adds

<img width="903" height="333" alt="waf_log_destination_retention" src="https://github.com/user-attachments/assets/853b9718-f98a-4779-8f9f-3d0359d1c4df" />  
<img width="867" height="119" alt="waf_sampled_requests" src="https://github.com/user-attachments/assets/3dd7ee06-8278-4d68-8852-8cccdec107eb" />  

### 2) CloudWatch WAF logging.tf
<img width="861" height="329" alt="cloudwatch_logs_group_tf" src="https://github.com/user-attachments/assets/2ccc72cb-b6e4-47d0-8a16-236ec53c0f34" />  

### 3A) Confirm WAF logging is enabled
Expected: LogDestinationConfigs contains exactly one destination.

        aws wafv2 get-logging-configuration \
        --resource-arn <WEB_ACL_ARN>  
        
<img width="968" height="257" alt="confirm-waf-logging" src="https://github.com/user-attachments/assets/96378347-d261-4d85-b1cb-4ca1d8fbb995" />


### 3B) Generate traffic (hits + blocks)

        curl -I https://chewbacca-growl.com/
        curl -I https://app.chewbacca-growl.com/  

<img width="798" height="333" alt="get-traffic-success" src="https://github.com/user-attachments/assets/a2a06874-7793-4ed0-81bf-4cc339dbcbad" />

### 3C1) If CloudWatch Logs destination

        aws logs describe-log-streams \
        --log-group-name aws-waf-logs-<project>-webacl01 \
        --order-by LastEventTime --descending

Then pull recent events:

        aws logs filter-log-events \
        --log-group-name aws-waf-logs-<project>-webacl01 \
        --max-items 20

<img width="895" height="329" alt="cloudwatch-describe-log-streams" src="https://github.com/user-attachments/assets/3b49cfd2-3f8c-4419-bdec-5b273adad75b" />  

<img width="974" height="593" alt="log-filter-events" src="https://github.com/user-attachments/assets/4d9f2d8f-d80f-4730-bf0e-348508fcfec4" />  

---

## Student Verification CLI Bonus F

### A) WAF Queries (CloudWatchs Log Insights)  
### A1) “What’s happening right now?” (Top actions: ALLOW/BLOCK)
        
        fields @timestamp, action
        | stats count() as hits by action
        | sort hits desc

### A2) Top client IPs (who is hitting us the most?)

        fields @timestamp, httpRequest.clientIp as clientIp
        | stats count() as hits by clientIp
        | sort hits desc
        | limit 25

### A3) Top requested URIs (what are they trying to reach?)
        fields @timestamp, httpRequest.uri as uri
        | stats count() as hits by uri
        | sort hits desc
        | limit 25

### A4) Blocked requests only (who/what is being blocked?)
        fields @timestamp, action, httpRequest.clientIp as clientIp, httpRequest.uri as uri
        | filter action = "BLOCK"
        | stats count() as blocks by clientIp, uri
        | sort blocks desc
        | limit 25

### A5) Which WAF rule is doing the blocking?
        fields @timestamp, action, terminatingRuleId, terminatingRuleType
        | filter action = "BLOCK"
        | stats count() as blocks by terminatingRuleId, terminatingRuleType
        | sort blocks desc
        | limit 25

### A6) Rate of blocks over time (did it spike?)
        fields @timestamp, httpRequest.clientIp as clientIp, httpRequest.uri as uri 
        | filter uri =~ /wp-login|xmlrpc|\.env|admin|phpmyadmin|\.git|login/ 
        | stats count() as hits by clientIp, uri 
        | sort hits desc 
        | limit 50

### A7) Suspicious scanners (common patterns: admin paths, wp-login, etc.)
        fields @timestamp, httpRequest.clientIp as clientIp, httpRequest.uri as uri
        | filter uri like /wp-login|xmlrpc|\.env|admin|phpmyadmin|\.git|\/login/
        | stats count() as hits by clientIp, uri
        | sort hits desc
        | limit 50

### A8) Country/geo (if present in your WAF logs)
Some WAF log formats include httpRequest.country. If yours does:

        fields @timestamp, httpRequest.country as country
        | stats count() as hits by country
        | sort hits desc
        | limit 25
---
### B) App Queries (EC2 app log group)

### B1) Count errors over time (this should line up with the alarm window)
        fields @timestamp, @message
        | filter @message like /ERROR|Exception|Traceback|DB|timeout|refused/i
        | stats count() as errors by bin(1m)
        | sort bin(1m) asc

### B2) Show the most recent DB failures (triage view)
        fields @timestamp, @message
        | filter @message like /DB|mysql|timeout|refused|Access denied|could not connect/i
        | sort @timestamp desc
        | limit 50

### B3) “Is it creds or network?” classifier hints
  Credentials drift often shows: Access denied, authentication failures
  Network/SecurityGroup often shows: timeout, refused, “no route”, hang

        fields @timestamp, @message
        | filter @message like /Access denied|authentication failed|timeout|refused|no route|could not connect/i
        | stats count() as hits by
        case(
        @message like /Access denied|authentication failed/i, "Creds/Auth",
        @message like /timeout|no route/i, "Network/Route",
        @message like /refused/i, "Port/SG/ServiceRefused",
        "Other"
        )
        | sort hits desc

### B4) Extract structured fields (Requires log JSON)
If you log JSON like: {"level":"ERROR","event":"db_connect_fail","reason":"timeout"}:

        fields @timestamp, level, event, reason
        | filter level="ERROR"
        | stats count() as n by event, reason
        | sort n desc

(Thou Shalt need to emit JSON logs for this one.)