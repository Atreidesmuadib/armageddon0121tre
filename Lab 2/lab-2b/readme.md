# Welcome to Armageddon!

### Lab 2b
### 1-26-2026


This lab focuses on proper operation of Cloudfront as opposed to simply 'using' the service.
The main goal is to understand a key concept emphasized by AWS: cache key (cache policy) and origin forwarding (origin request policy).

Getting these wrong can casue real incidents in production, (User A sees user B's data, auth breaks, random "403" errors, etc.)


## Student Deliverables

### 1) Static Caching Proof

Run twice:  

    curl -I https://chewbacca-growl.com/static/example.txt  
    curl -I https://chewbacca-growl.com/static/example.txt

Look for:  

    Cache-Control: public, max-age=... (from response headers policy)  
    Age: increases on subsequent requests (cached object indicator)  

<img width="699" height="589" alt="static_caching_proof" src="https://github.com/user-attachments/assets/9434950f-56e0-4972-a64a-9be76889ecb9" />  

### 2) API must NOT cache unsafe output

Run twice:  

    curl -I https://chewbacca-growl.com/api/list  
    curl -I https://chewbacca-growl.com/api/list

Expected for “safe default” API behavior:  
    Age should be absent or 0  
    Responses should reflect fresh origin behavior  
    If you add auth later, you must never allow one user to see another’s response

<img width="737" height="559" alt="no_unsafe_content_caching" src="https://github.com/user-attachments/assets/693c9668-545f-4f3c-b6d8-f3b2c9242e0d" />


### 3) Cache key sanity checks (query strings)

Static should ignore query strings by default:  

    curl -I "https://chewbacca-growl.com/static/example.txt?v=1"  
    curl -I "https://chewbacca-growl.com/static/example.txt?v=2"  

Expected:
both map to the same cached object (hit ratio stays high) because static cache policy ignores query strings (unless students intentionally change it)

<img width="774" height="634" alt="cache_key_sanity_checks" src="https://github.com/user-attachments/assets/71f039d5-f918-4cbe-b83e-ce73ae7b79e5" />


### 4) "Stale read after write" safety test
 If your API supports writes:  
    POST a new row  
    Immediately GET /api/list  
    Ensure the new row appears. If it doesn’t, they accidentally cached a dynamic response.  

<img width="1382" height="416" alt="stale_read_after_write" src="https://github.com/user-attachments/assets/10c24c54-131d-4316-9d03-2106a3cebfae" />

