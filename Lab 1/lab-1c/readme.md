# Welcome to Armageddon!
### Lab 1c
### 1-17-2026

At this point, we're working with a solid Infrastructure as Code (IaC) AWS infrastructure built in Terraform.

After adding our Lambda and Bedrock incident reports in Lab-1b, we've moved our EC2 into a private subnet, placed behind a web-application firewall (WAF), and a public Application Load Balancer (ALB) secured by TLS.

We've also implemented Route 53 to point DNS queries for our app to the ALB, among other items.

This lab covered how to implement an infrastructure that is production-ready, and built with defense-in-depth in mind.

## Student Deliverables:

### terraform plan output:
