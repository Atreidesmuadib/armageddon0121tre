# Welcome to Armageddon!

### Lab 2a
### 1-24-2026

Origin Cloaking + CloudFront as the only public ingress.

Although the ALB is still 'internet facing' (must be reachable by CloudFront), it is cloaked so direct access is blocked.  
The ALB security group allows inbound only from the AWS-managed CloudFront origin-facing prefix list (com.amazonaws.global.cloudfront.origin-facing).  
ALB listener requires a secret header that only CloudFront adds.  
Web application firewall (WAF) moves to CloudFront (WAFv2 scope = 'CLOUDFRONT'), and is associated to the distribution.  
'yourdomain'.com and app.'yourdomain'.com alias to CloudFront.  

### Notable Changes

#### Adding a second provider alias for us-east-1  

<img width="805" height="334" alt="2nd_provider_alias" src="https://github.com/user-attachments/assets/ab45bf2a-dffd-4587-8bb9-e21da6e1fc82" />  

#### Allowing ALB inbound only from CloudFront prefix list  

<img width="779" height="175" alt="cloudfront_sg_prefix_id" src="https://github.com/user-attachments/assets/78b45901-4051-4bca-8fb1-293bc74fb61d" />  

### Adding secret "origin-header" that ALB requires 

<img width="1052" height="632" alt="secret_origin_header_and_listener_rule" src="https://github.com/user-attachments/assets/e5914256-3dbf-407a-8874-e53ca8ce7ff0" />  

### Adding "custom-header + ALB rule" that verifies "origin-header" and blocks all else  

<img width="1010" height="418" alt="alb_listener_rule_fixed_403" src="https://github.com/user-attachments/assets/9957979c-fc01-4a75-af37-6b5c258778e1" />  

---

## Student Verification CLI

### 1A) VPC is only reachable via CloudFront"  

Direct ALB access should fail  

        curl -I https://<ALB_DNS_NAME>  

<img width="1248" height="76" alt="alb_timeout" src="https://github.com/user-attachments/assets/cb532ed3-cf91-48c2-bd88-fbadba9541ad" />  

### 1B) CloudFront access should succeed

        curl -I https://zerotrustzone.dev  
        curl -I https://app.zerotrustzone.dev  

<img width="1063" height="442" alt="curl-i_cloudfront" src="https://github.com/user-attachments/assets/08becb05-c998-4de0-ad99-edc7192eae17" />


### 2) WAF moved to CloudFront

        aws wafv2 get-web-acl \
        --name <project>-cf-waf01 \
        --scope CLOUDFRONT \
        --id <WEB_ACL_ID>  

<img width="929" height="844" alt="confirm_waf_moved_to_cf" src="https://github.com/user-attachments/assets/0e6163b9-d0c0-488c-8628-a82083f14347" />  


and confirm distribution references it:  

        aws cloudfront get-distribution \
        --id <DISTRIBUTION_ID> \
        --query "Distribution.DistributionConfig.WebACLId"  

<img width="859" height="91" alt="confirm_distribution_references_acl" src="https://github.com/user-attachments/assets/1c928214-11b1-4e4f-8ce3-062c9477f815" />  


Expected: WebACL ARN present.  

### 3) your domain points to CloudFront:  

Expected: resolves to CloudFront (you’ll see CloudFront anycast behavior, not ALB IPs)  
                  dig yourdomain.com A +short
                  dig app.yourdomain.com A +short  
                  
<img width="835" height="243" alt="dig_domain_points_to_cloudfront" src="https://github.com/user-attachments/assets/ddafac7a-15a3-4534-936a-b69b04361855" />  

---
