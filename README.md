
This report outlines the deployment of a production-level cloud infrastructure using Terraform on Amazon Web Services (AWS). The architecture features a custom Virtual Private Cloud (VPC) with clearly defined public and private subnets, secure EC2 instances for compute resources, and Amazon RDS for persistent data storage. Security is managed through the use of well-structured security groups. The following sections provide a detailed explanation of each component, its configuration, and its role within the overall system.
 
![image](https://github.com/user-attachments/assets/896b6ed3-0b6c-4312-ae12-fa2272ba3c42)

Virtual Private Cloud (VPC) Design

The foundational networking layer of this infrastructure is built using the official terraform-aws-modules/vpc/aws module. A custom Virtual Private Cloud (VPC) named devops-vpc is provisioned with a CIDR block of 10.0.0.0/16, offering a broad range of IP addresses to support scalable and flexible resource allocation.
To enhance availability and fault tolerance, the infrastructure spans two Availability Zones: us-east-2b and us-east-2c. The VPC is logically segmented into public and private subnets:
•	Public subnets (10.0.1.0/24 and 10.0.2.0/24) accommodate the bastion host and the NAT gateway, providing controlled access to and from the internet.
•	Private subnets (10.0.101.0/24 and 10.0.102.0/24) are designated for hosting application servers, databases, and internal services such as Metabase.
A single NAT gateway is deployed to allow instances in private subnets to initiate outbound connections to the internet for updates and dependency installations. This setup ensures resources remain protected from inbound internet traffic, maintaining a secure and private environment.

Security Group Architecture

The infrastructure adopts a zero-trust and least privilege security model. Security groups are explicitly defined for each layer in the securitygroups.tf file, ensuring minimal and role-specific access throughout the architecture.


Bastion Host Security Group

•	Allows SSH (port 22) access only from the administrator’s external IP address.
•	Acts as a secure gateway for accessing internal resources residing in private subnets.
EC2 Application Server Security Group
•	Permits SSH traffic exclusively from the bastion host.
•	Accepts application traffic on port 8080 from the Application Load Balancer (ALB).
•	Optionally allows HTTP/HTTPS traffic from all sources during development or debugging phases.
•	This design keeps the application servers isolated from the internet while ensuring accessibility via the ALB.


RDS MySQL & PostgreSQL Security Groups

•	Restrict access to the application servers, Metabase, and the bastion host.
•	This enforces internal-only access, preventing unauthorized or external connections to the database layer.


ALB Security Group

•	Allows inbound traffic on HTTP (port 80) and HTTPS (port 443) from the public internet.
•	This security group is associated with the ALB (defined in albs.tf) and provides users with access to the application frontend without directly exposing backend resources.


Metabase Security Group

•	Permits SSH (port 22) and port 3000 (Metabase UI) access only from the bastion host.
•	The Metabase server remains in a private subnet, ensuring it is secure yet reachable for internal monitoring and data analytics purposes.


EC2 Compute Infrastructure

The ec2.tf configuration provisions three distinct types of EC2 instances, each serving a specific purpose—administrative access, application hosting, and business intelligence analytics. All instances are initialized using user-data scripts to automate software setup, system configurations, and environment provisioning, enabling repeatable and efficient deployments.


Bastion Host

•	A single bastion instance is deployed within a public subnet, functioning as the administrative access point for the entire infrastructure.
•	It is the only instance assigned a public IP address, making it the sole externally reachable entry point.
•	Secured with a dedicated security group (bastion_sg), it restricts SSH access to the administrator’s IP address only.
•	Through SSH tunneling, the bastion enables secure access to internal systems such as the Metabase server and RDS database instances—none of which are exposed to public traffic.
Metabase Analytics Server
The Metabase analytics platform is deployed on a dedicated EC2 instance within one of the private subnets, ensuring the server remains isolated from direct internet access. This design choice enhances security by limiting exposure, allowing access only through SSH tunneling via the bastion host.
The server is automatically configured at launch using a user-data script named metabase_ec2.sh. This script performs several key setup tasks to ensure the analytics environment is immediately operational:
•	Installs and enables Docker, providing a containerized environment for the application.
•	Pulls and runs the official Metabase Docker image, exposing the service on port 3000 for web access through internal network connections.
•	Injects environment variables to configure Metabase to connect to its backing MySQL RDS instance. These variables include critical database connection details such as:
o	Database name
o	Host address
o	Port number
o	Username
o	Password
This fully automated provisioning approach ensures the Metabase server is consistently and reliably initialized without the need for post-deployment manual configuration. Once launched, it is immediately available for use by authorized internal users for monitoring, reporting, and business intelligence tasks.

 ![image](https://github.com/user-attachments/assets/826c8484-af02-4c89-8b53-bfe20a2c7faf)


Application Server Auto Scaling Group

The web application is deployed across EC2 instances managed by an Auto Scaling Group (ASG). These instances reside in private subnets, ensuring they are not assigned public IP addresses and cannot be accessed directly from the internet. Instead, they are connected to an Application Load Balancer (ALB) via a defined target group, which handles traffic routing and load distribution.
A launch template defines the configuration of the app instances, incorporating a user-data script (ec2_userdata.sh) to automate provisioning. Upon launch, each instance executes the following tasks:
•	Applies system updates and installs essential packages such as Git and Docker.
•	Starts and enables the Docker daemon to support containerized application execution.
•	Clones the application repository from GitHub (https://github.com/nimrahumayun1/reactapp.git) into the EC2 user's home directory.
•	Builds a Docker image named react-app using the provided Dockerfile.
•	Runs the Docker container, mapping it to port 8080, which corresponds with the ALB target group’s configuration.
This setup ensures that each instance is automatically configured, application-ready, and integrated with the ALB upon launch. The Auto Scaling Group provides:
•	High availability, by distributing instances across multiple Availability Zones.
•	Scalability, by adjusting the number of instances based on demand.
•	Operational efficiency, by eliminating the need for manual setup or intervention.
All EC2 instances in the infrastructure use the latest Amazon Linux 2 AMI, are placed in appropriate subnets based on access control needs (public for bastion, private for app and analytics), and are consistently tagged to support resource tracking, billing, and lifecycle management.


Relational Database Service (RDS) Configuration

The rds.tf configuration file provisions two managed database instances—one for MySQL and another for PostgreSQL—both deployed in the private subnets of the VPC. A shared database subnet group ensures that both instances remain confined to secure, non-publicly accessible subnets.

MySQL RDS Instance

•	Configured using credentials defined via Terraform variables.
•	Serves as the backend database for the Metabase analytics platform.
•	Located entirely within private subnets and accessible only by internal services (e.g., Metabase and bastion).
•	Public accessibility is explicitly disabled, enhancing data protection.

PostgreSQL RDS Instance

•	Also configured using Terraform-defined credentials.
•	Intended for use by application servers for storing operational data.
•	Like the MySQL instance, it is not publicly accessible and is reserved strictly for internal communication.
•	Both instances skip final snapshots during destruction—acceptable in non-production or test environments, though not recommended for production workloads due to potential data loss concerns.
Each RDS instance is protected by a dedicated security group, allowing inbound traffic only from authorized EC2 instances and Metabase, in accordance with the principle of least privilege. This approach ensures that the database layer remains well-isolated, secure, and resilient against unauthorized access.

 ![image](https://github.com/user-attachments/assets/53a1d3f6-9a9a-4cd4-88a4-1bec991614b9)


Application Load Balancer (ALB) Configuration

To enable public access to the containerized web application and to effectively manage HTTP and HTTPS traffic, an Application Load Balancer (ALB) is deployed. The ALB is configured as internet-facing and spans across public subnets in multiple Availability Zones, thereby ensuring high availability and fault tolerance.
The ALB is secured using a dedicated security group, which permits inbound HTTP (port 80) and HTTPS (port 443) traffic from the internet. This configuration facilitates secure and scalable access to the application from external users. For development and testing flexibility, deletion protection on the ALB is disabled.
The ALB is configured with the following operational parameters:
•	An idle timeout of 60 seconds, suitable for standard web request and response cycles.
•	A listener on port 80, which forwards traffic to a target group where application containers are listening on port 8080.
•	The target group uses instance-based registration, ensuring that requests are routed to registered EC2 instances (as opposed to IP addresses or Lambda functions).
To maintain application reliability, the ALB includes health check mechanisms with the following configuration:
•	Health check path: /, targeting the root endpoint of the running application container.
•	Interval: Health checks run every 30 seconds.
•	Timeout: Each health check has a 5-second timeout window.
•	Thresholds: Instances are marked as healthy or unhealthy based on two consecutive successful or failed checks.
These health checks ensure that only responsive and operational instances receive incoming traffic, thereby enhancing service availability and user experience.
To support secure HTTPS access, an SSL/TLS certificate is provisioned and managed using AWS Certificate Manager (ACM). This enables encrypted traffic between users and the load balancer, complying with security best practices for production-grade web applications.

![image](https://github.com/user-attachments/assets/18d3ef19-580a-48f8-a4cf-ba3740ff9882)

![image](https://github.com/user-attachments/assets/de76a08d-89af-4120-98d7-d491da52d98f)

 

 


GIT HUB LINK

