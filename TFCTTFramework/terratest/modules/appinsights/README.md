
---

# 📘 Terratest Application Insights Validation Module

---

## 📌 1. Overview

The **Azure Application Insights Terratest Validation Module** ensures that Application Insights instances in Azure comply with your defined configurations.

It validates **retention, daily cap, tags, linked workspaces, public access, and continuous export settings** against a JSON-driven configuration.

---

## 📂 2. Project Structure

```plaintext
mf_terratest_framework/
│
├── terratest/
│   ├── common/
│   │   └── common.go                   # Shared structs & config loader
│   └── modules/
│       └── appinsights/
│           └── cc_appinsights_test.go  # App Insights validation tests
│
└── configs/
    └── cc_appinsights_test_config.json # Expected configuration
└── scripts/
    └── gen_config.go                   # Generates config from Terraform plan
```

---

## ⚙️ 3. Dependencies

* **Go 1.20+**
* **Terraform >= 1.3**
* **Azure CLI** (`az login`)
* **Azure Go SDK**

Install Go dependencies:

```bash
go get github.com/Azure/azure-sdk-for-go/sdk/azidentity
go get github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/applicationinsights/armapplicationinsights
go get github.com/stretchr/testify
```

---

## 📌 4. Configuration File

File: `configs/cc_appinsights_test_config.json`

```json
{
  "expected_principal_id": "5d976b48-4340-4c05-ab09-e80ef3751794",
  "insights": {
    "ProdInsights": {
      "name": "prod-ai-001",
      "resource_group_name": "rg-appinsights-prod",
      "location": "canadacentral",
      "kind": "web",
      "tags": {
        "env": "prod",
        "owner": "devsecops"
      },
      "retention_in_days": 90,
      "daily_cap_gb": 100,
      "disable_ip_masking": false,
      "workspace_resource_id": "/subscriptions/.../resourceGroups/rg-log/providers/Microsoft.OperationalInsights/workspaces/prod-law",
      "public_network_access": true,
      "exports": [
        {
          "name": "export-metrics",
          "destination": "https://storage.blob.core.windows.net",
          "export_types": ["Basic", "Audit"],
          "enabled": true
        }
      ]
    }
  }
}
```

---

## 🔍 5. Validations Performed

* **Resource Basics**: Location, kind, ID format, tags
* **Retention & Daily Cap**: Validates log retention days and daily cap in GB
* **Policies**: IP masking enabled/disabled, public network access
* **Linked Workspace**: Ensures correct Log Analytics workspace
* **Continuous Export**: Verifies exports (name, type, destination, enabled flag)

---

## 🚀 6. Running the Tests

### Step 1: Generate Config from Terraform Plan

Instead of writing configs manually, auto-generate them:

```bash
terraform show -json > plan.json
go run scripts/gen_config.go plan.json > configs/cc_appinsights_test_config.json
```

This uses `scripts/gen_config.go` to convert the Terraform plan into the JSON format expected by the test module.

---

### Step 2: Create a Test File

```go
package tests

import (
    "path/filepath"
    "testing"

    "github.com/McCainFoods/mf_terratest_framework/terratest/modules/appinsights"
)

func TestAppInsightsValidation(t *testing.T) {
    configPath := filepath.Join("..", "configs", "cc_appinsights_test_config.json")
    appinsights.RunAppInsightsValidation(t, configPath)
}
```

---

### Step 3: Run the Tests

```bash
go test ./tests -v
```

---

## 📊 7. Sample Test Output

```bash
=== RUN   TestAppInsightsValidation/Validate_AppInsights_ProdInsights
✅ Validated Application Insights: prod-ai-001
--- PASS: TestAppInsightsValidation (6.12s)
    --- PASS: TestAppInsightsValidation/Validate_AppInsights_ProdInsights (6.11s)
PASS
ok   github.com/McCainFoods/mf_terratest_framework/terratest/modules/appinsights  6.3s
```

On failure:

```bash
Error: Expected retention policy 90 days but found 30 days
```

---

## 📊 8. Coverage Summary

| Validation Area         | Covered | Source |
| ----------------------- | ------- | ------ |
| Location                | ✅       | SDK    |
| Kind                    | ✅       | SDK    |
| Tags                    | ✅       | SDK    |
| Retention Policy        | ✅       | SDK    |
| Daily Cap               | ✅       | SDK    |
| IP Masking              | ✅       | SDK    |
| Public Network Access   | ✅       | SDK    |
| Linked Log Analytics    | ✅       | SDK    |
| Continuous Export Rules | ✅       | SDK    |

---

## 🔒 9. Benefits

* ✅ **Drift Detection**: Catch config drift early
* 🔁 **Reusable**: Config-driven across environments
* 📊 **Auditable**: CI/CD pipeline integration
* ⚡ **Automated**: No manual Azure Portal validation
* 🔒 **Secure**: Enforces governance policies

---

## 📌 10. Future Enhancements

* Add **Alert Rules validation**
* Add **Availability Tests validation**
* Add **Smart Detection validation**

---
