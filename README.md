# Scaling a Cloud-Native Platform to 1 Million+ Users

This repository is the architectural journey of scaling a cloud-native platform from a single user to over 10 million. It is a multi-phase, hands-on implementation of solving for scale — moving from a single point of failure to a globally distributed, fault-tolerant, and high-performance system. The entire infrastructure is defined with **Terraform**, automated with **GitOps**, and architected to survive real-world failure.

---

## The Master Architecture

This diagram illustrates the complete architectural evolution of the platform, from a single EC2 instance to a multi-region, globally-routed EKS deployment.
<img width="2764" height="1835" alt="diagram-export-10-5-2025-11_45_56-AM" src="https://github.com/user-attachments/assets/1d7afd78-daef-4eab-b9aa-8d8fdeff2c55" />

---

## The Architectural Journey

This platform was not built in a day. It was built **iteratively**, with each new phase engineered to solve the critical bottlenecks of the previous one.
<img width="1906" height="874" alt="diagram-export-10-5-2025-10_01_38-PM" src="https://github.com/user-attachments/assets/6b8a2e61-95ef-4312-8b26-a86a78cfc05c" />

### Phase 0: The MVP (1-100 Users)

**Architecture:**  
A single `t2.micro` EC2 instance provisioned with Terraform. The application (Service A, Service B) and a PostgreSQL database were all run as containers on this single server, managed by a user-data script.

**The Flaw:**  
A complete single point of failure. If the instance failed, the entire application and its database would be destroyed. It was a prototype, not a business.

---

### Phase 1: High Availability (100-10,000 Users)

**Architecture:**  
To solve the single point of failure, the monolithic application was re-platformed. The database was migrated to a **Multi-AZ AWS RDS** instance for resilience. The EC2 instance was placed behind an **Application Load Balancer (ALB)** and managed by an **Auto Scaling Group (ASG)** to ensure a minimum of two healthy instances were always running.

**The Flaw:**  
This was now highly available, but it was still a monolith. Scaling was inefficient. To get more instances of Service A, we were forced to also deploy and pay for new instances of Service B. Deployments were slow, risky, and wasteful.

---

### Phase 2: The Microservices Era (10,000-100,000 Users)

**Architecture:**  
I re-platformed the entire application from EC2 to a production-grade **Amazon EKS (Kubernetes)** cluster. This allowed Service A and Service B to run as independent Deployments, scaled by their own metrics. An **NGINX Ingress Controller** was deployed to manage traffic, and the entire deployment lifecycle was automated with a **GitOps workflow using Argo CD**.

**The Flaw:**  
The system was now scalable and automated, but it was slow. A single RDS instance was becoming a read bottleneck, and users on the other side of the world experienced high network latency.

---

### Phase 3: The Performance Tune (100,000-500,000 Users)

**Architecture:**  
To solve for speed, I introduced two new layers. First, an **AWS ElastiCache (Redis)** cluster was provisioned to act as an in-memory cache, drastically reducing load on the database. Second, the entire application was placed behind an **AWS CloudFront CDN** to cache static assets and API responses at edge locations, making the application feel instant for global users.

**The Flaw:**  
The system was now fast, resilient, and scalable... but it all lived in one AWS region. The "blast radius" of a single regional outage was 100%. This was the final single point of failure.

---

### Phase 4: The Global Scale (1-10 Million+ Users)

**Architecture:**  
This is the final, globally distributed platform. I refactored the entire regional infrastructure into a reusable **Terraform module**. This module was then deployed to a second AWS region (`us-east-1`), creating a full, active-active replica of the stack.

**The Result:**  
**AWS Route 53** with latency-based routing now sits in front of both regional deployments, automatically directing users to the closest, fastest region. The RDS database is configured with **cross-region read replication**, providing fast, local database reads for global users. The system can now survive a complete regional outage.
<img width="1683" height="1009" alt="diagram-export-10-5-2025-9_37_20-PM" src="https://github.com/user-attachments/assets/011fcdad-b3da-429b-a112-7eb2511a719b" />

---

<img width="1852" height="938" alt="diagram-export-10-5-2025-7_57_07-PM" src="https://github.com/user-attachments/assets/c06b962a-aa52-4e93-a49a-3e4061ffbcfe" />

## Technology Stack

- **Infrastructure as Code:** Terraform  
- **Cloud Provider:** AWS  
- **Orchestration:** Amazon EKS (Kubernetes)  
- **Networking:** VPC, Route 53 (Global Routing), Application Load Balancer  
- **Database:** AWS RDS (PostgreSQL) with Cross-Region Replication  
- **Caching:** AWS ElastiCache (Redis), AWS CloudFront (CDN)  
- **CI/CD & GitOps:** GitHub Actions, Argo CD  
- **Add-ons:** NGINX Ingress Controller, Cert-Manager  

---

## Conclusion

This project is the definitive answer to the **system design challenge of scaling**. It demonstrates an iterative, SRE-driven approach to solving real-world bottlenecks, proving that a system's resilience and performance are not features, but the result of deliberate, continuous engineering.

---
