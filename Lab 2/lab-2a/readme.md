# Welcome to Armageddon!

### Lab 2a
### 1-24-2026

Origin Cloaking + CloudFront as the only public ingress.

Although the ALB is still 'internet facing' (must be reachable by CloudFront), it is cloaked so direct access is blocked.  
The ALB security group allows inbound only from the AWS-managed CloudFront origin-facing prefix list (com.amazonaws.global.cloudfront.origin-facing).  
ALB listener requires a secret header that only CloudFront adds.  
Web application firewall (WAF) moves to CloudFront (WAFv2 scope = 'CLOUDFRONT'), and is associated to the distribution.  
'yourdomain'.com and app.'yourdomain'.com alias to CloudFront.  