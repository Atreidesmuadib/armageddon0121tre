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

#### Allowing ALB inbound only from CloudFront prefix list

### Adding secret "origin-header" that ALB requires

### Adding "custom-header + ALB rule" that verifies "origin-header" and blocks all else

---

## Student Verification CLI

### 1A) VPC is only reachable via CloudFront"

Direct ALB access should fail

        curl -I https://<ALB_DNS_NAME>

### 1B) CloudFront access should succeed

        curl -I https://zerotrustzone.dev  

        curl -I https://app.zerotrustzone.dev

### 2) WAF moved to CloudFront

        aws wafv2 get-web-acl \
        --name <project>-cf-waf01 \
        --scope CLOUDFRONT \
        --id <WEB_ACL_ID>

and confirm distribution references it:

        aws cloudfront get-distribution \
        --id <DISTRIBUTION_ID> \
        --query "Distribution.DistributionConfig.WebACLId"

Expected: WebACL ARN present.

### 3) your domain points to CloudFront:

Expected: resolves to CloudFront (you’ll see CloudFront anycast behavior, not ALB IPs)