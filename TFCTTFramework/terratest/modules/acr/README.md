
---

# 📘 Terratest Azure Container Registry (ACR) Validation Module

---

## 📌 1. Overview

The **Azure Container Registry (ACR) Terratest Validation Module** is a reusable framework that validates **Azure Container Registries** against predefined expected configurations.

It ensures **infrastructure consistency** by comparing deployed ACR resources against a **JSON configuration file** that defines the desired state.

This module validates:

* Registry properties (SKU, admin enabled, encryption, tags)
* Network rules (firewall IP restrictions)
* Private endpoints
* Geo-replication regions
* Webhooks (name, actions, tags)
* Governance settings (Anonymous Pull, Retention Policy, Content Trust, Quota)

---

## 📂 2. Project Structure

```plaintext
mf_terratest_framework/
│
├── terratest/
│   ├── common/
│   │   └── common.go           # Shared config structures
│   └── modules/
│       └── acr/
│           └── cc_acr_test.go  # ACR validation tests
│
└── configs/
    └── cc_acr_test_config.json # Expected ACR configuration
```

---

## ⚙️ 3. Dependencies

Ensure you have the following installed:

* **Go 1.20+**
* **Terraform >= 1.3**
* **Azure CLI** (logged in: `az login`)
* **Azure Go SDK**

Install Go dependencies:

```bash
go get github.com/Azure/azure-sdk-for-go/sdk/azidentity
go get github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerregistry/armcontainerregistry
go get github.com/stretchr/testify
```

---

## 📌 4. Configuration File

The module consumes a **JSON configuration file** (`cc_acr_test_config.json`) that describes the expected ACR state.

### Example Config

```json
{
  "expected_principal_id": "5d976b48-4340-4c05-ab09-e80ef3751794",
  "registries": {
    "ProdACR": {
      "name": "prodacr001",
      "resource_group_name": "rg-acr-prod",
      "location": "canadacentral",
      "sku": "Premium",
      "admin_enabled": false,
      "encryption": "CMK",
      "tags": {
        "env": "prod",
        "owner": "devsecops"
      },
      "network_rules": {
        "default_action": "Deny",
        "ip_rules": ["10.10.0.0/24", "20.30.40.50"]
      },
      "private_endpoints": [
        "/subscriptions/.../resourceGroups/rg-network/providers/Microsoft.Network/privateEndpoints/pe-acr-prod"
      ],
      "replications": [
        { "location": "eastus" },
        { "location": "westeurope" }
      ],
      "webhooks": [
        {
          "name": "image-push-hook",
          "actions": ["push"],
          "tags": {
            "purpose": "ci-cd"
          }
        }
      ],
      "anonymous_pull": false,
      "content_trust_enabled": true,
      "retention_days": 30,
      "quota_gb": 500
    }
  }
}
```

---

## 🔍 5. Validations Performed

### **Registry Basics**

* ✅ Location
* ✅ SKU
* ✅ Admin User Enabled
* ✅ Resource ID format
* ✅ Tags

### **Encryption**

* ✅ CMK via Key Vault
* ✅ Microsoft Managed

### **Network Rules**

* ✅ Firewall default action (`Allow`/`Deny`)
* ✅ IP whitelist validation
* ✅ Drift detection

### **Private Endpoints**

* ✅ All required private endpoints exist
* ✅ Subset check (allows more, prevents missing ones)

### **Geo-Replications**

* ✅ Validates replication locations via Azure SDK

### **Webhooks**

* ✅ Validates webhook existence
* ✅ Validates actions (`push`, `delete`, etc.)
* ✅ Validates tags

### **Governance Policies (via Azure CLI)**

* ✅ Anonymous Pull Access
* ✅ Content Trust status (`Enabled`/`Disabled`)
* ✅ Retention Policy (enabled + days)
* ✅ Quota (Max capacity in GiB)

---

## 📊 Coverage Summary

| Category                    | Validated | Method    |
| --------------------------- | --------- | --------- |
| Location                    | ✅         | SDK       |
| SKU                         | ✅         | SDK       |
| Admin Enabled               | ✅         | SDK       |
| Resource ID Format          | ✅         | SDK       |
| Tags                        | ✅         | SDK       |
| Encryption (CMK/MMK)        | ✅         | SDK       |
| Firewall Default Rule       | ✅         | SDK       |
| IP Rules                    | ✅         | SDK       |
| Private Endpoints           | ✅         | SDK       |
| Replications                | ✅         | SDK       |
| Webhooks (Name/Action/Tags) | ✅         | SDK       |
| Anonymous Pull              | ✅         | Azure CLI |
| Content Trust               | ✅         | Azure CLI |
| Retention Policy            | ✅         | Azure CLI |
| Quota (GB)                  | ✅         | Azure CLI |

---

## 🚀 6. Running the Tests

### Step 1: Prepare Config File

```bash
/configs/cc_acr_test_config.json
```

### Step 2: Create Test File

```go
package tests

import (
    "path/filepath"
    "testing"

    "github.com/McCainFoods/mf_terratest_framework/terratest/modules/acr"
)

func TestACRValidation(t *testing.T) {
    configPath := filepath.Join("..", "configs", "cc_acr_test_config.json")
    acr.RunACRValidation(t, configPath)
}
```

### Step 3: Run Tests

```bash
go test ./tests -v
```

---

## 📊 7. Sample Output

```bash
=== RUN   TestACRValidation/Validate_ACR_ProdACR
✅ Validated ACR: prodacr001
--- PASS: TestACRValidation (4.23s)
    --- PASS: TestACRValidation/Validate_ACR_ProdACR (4.22s)
PASS
ok   github.com/McCainFoods/mf_terratest_framework/terratest/modules/acr 4.25s
```

If a rule fails:

```bash
Error: Expected IP rule 10.10.0.0/24 not found in registry firewall rules
```

---

## 🔄 8. Automating Config Generation

Instead of manually writing configs:

```bash
terraform show -json > plan.json
go run scripts/gen_config.go plan.json > configs/cc_acr_test_config.json
```

This ensures the test config matches deployed infrastructure.

---

## 🛠️ 9. Integration in Other IaC Repos

1. **Add Dependency**

```bash
go get github.com/McCainFoods/mf_terratest_framework/terratest/modules/acr
```

2. **Import in Test File**

```go
import "github.com/McCainFoods/mf_terratest_framework/terratest/modules/acr"
```

3. **Add Config File**

```bash
/configs/cc_acr_test_config.json
```

4. **Run Tests**

```bash
go test -v
```

---

## 🔒 10. Benefits

* ✅ **Drift Detection**: Matches IaC vs Azure
* 🔁 **Reusable**: Config-driven
* 📊 **Auditable**: CI/CD validation
* ⚡ **Automated**: Reduces manual checks
* 🔒 **Secure**: Validates firewall and governance

---
