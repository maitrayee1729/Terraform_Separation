# Terraform Setup for Separating Tenant from EClouds to Standalone server
## Project Overview

The "Separate Tenant" project aims to provide a multi-tenant environment where each tenant is hosted on separate servers, ensuring isolation and dedicated resources for each tenant's environment.

## Configuration Options



- **Single**: All tenants are hosted on a single server.
- **Dedicated_Setup**: Each tenant's database is hosted on a separate server.
- **Dedicated_Setup_Task**: In addition to separate database servers, dedicated task servers are deployed for resource-intensive operations.
