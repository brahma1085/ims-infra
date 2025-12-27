# ims-infra
Inventory Management System infrastructure details

This repo contains NO business code.

# Microservices System (Oracle + Spring Boot 3.3 + Angular 21)

This system contains:

- Spring Cloud Gateway (port 8080)
- Orders Microservice (Oracle)
- Inventory Microservice (Oracle)
- Customers Microservice (Oracle)
- Angular UI (port 4200)
- Docker Compose (Oracle XE + services)

Run the Oracle script first: @oracle-xe/XE2.sql

Then run the generator parts.


Purpose: Everything related to AWS, networking, deployment, CI/CD infra



📁 What Goes Inside ims-infra

ims-infra/diagrams/architecture.drawio
ims-infra/diagrams/app-flow.drawio

ims-infra/aws/vpc
ims-infra/aws/ec2
ims-infra/aws/alb
ims-infra/aws/cloudfront
ims-infra/aws/s3
ims-infra/aws/rds-oracle-xe

ims-infra/docker/keycloak/docker-compose.yml
ims-infra/docker/oracle-xe/dockerr-comppose.yml

ims-infra/jenkins/Jenkinsfile-angular
ims-infra/jenkins/Jenkinsfile-service

ims-infra/nginx/angular.conf


Docker Compose = orchestration but Not application source

Used for:
Local dev
Infra bootstrapping
Keycloak + Oracle XE


CloudFront is infra
ALB routing rules are infra
SSL, DNS, ACM certs are infra

🧠 Repo Purpose Summary (One‑Line Each)
Repo	Why it exists:

ims-angular-ui	=> Frontend source & UI lifecycle

ims-inventory-service	=> Inventory domain logic

ims-user-service	=> User/admin logic

ims-order-service	=> Orders & PO workflows

ims-gateway-service	=> Central API gateway

ims-infra	=> AWS, CI/CD, Docker, networking

this repo contains NO business code.
