
---

# 📘 Terratest Module for Azure Log Analytics Workspaces

---

## 📌 1. Overview

The **Azure Log Analytics Terratest Module** provides an automated way to validate **Azure Log Analytics Workspaces** against predefined configurations.
It ensures that your deployed resources match the **expected state**, preventing infrastructure drift.

This module validates:

* Workspace properties (Location, SKU, Retention)
* Daily data quota
* Tags
* Private Link Scopes
* Integration with Terraform-generated configs

---

## 📂 2. Project Structure

```plaintext
mf_terratest_framework/
│
├── terratest/
│   ├── common/
│   │   └── common.go                  # Shared structs & config loaders
│   └── modules/
│       └── loganalytics/
│           └── cc_loganalytics_test.go # Log Analytics validation tests
│
└── configs/
    └── log_analytics_test_config.json # Expected configuration
```

---

## ⚙️ 3. Dependencies

Before running the tests, ensure you have:

* **Go 1.20+**
* **Terraform >= 1.3**
* **Azure CLI** (logged in: `az login`)
* **Azure Go SDK**
* **Testify for Go testing**

Install dependencies:

```bash
go get github.com/Azure/azure-sdk-for-go/sdk/azidentity
go get github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/operationalinsights/armoperationalinsights
go get github.com/stretchr/testify
```

---

## 📌 4. Config File

The tests use a JSON config (`configs/log_analytics_test_config.json`) to define expected values.

### Example Config

```json
{
  "workspaces": {
    "prod-law": {
      "name": "prod-law",
      "resource_group_name": "rg-observability",
      "location": "canadacentral",
      "sku": "PerGB2018",
      "retention_in_days": 30,
      "daily_quota_gb": 100,
      "tags": {
        "env": "prod",
        "owner": "platform-team"
      },
      "private_link_scope_ids": [
        "/subscriptions/.../resourceGroups/rg-network/providers/Microsoft.Insights/privateLinkScopes/prod-scope"
      ]
    }
  }
}
```

---

## 🔍 5. Validations Performed

The module validates:

### **1. Workspace Properties**

* ✅ Location matches config
* ✅ SKU matches config
* ✅ Retention period in days
* ✅ Daily quota (GB)
* ✅ Resource ID format check

### **2. Tags**

* ✅ Ensures all expected tags exist

### **3. Private Link Scope**

* ✅ Confirms assigned scopes match expected IDs

---

## 🚀 6. Running the Tests

### Step 1: Generate Config File from Terraform

Instead of writing JSON manually, generate it from Terraform:

```bash
terraform show -json > plan.json
go run scripts/gen_config.go plan.json > configs/log_analytics_test_config.json
```

This will produce a valid config JSON.

### Step 2: Write Your Test

Create `tests/log_analytics_test.go` in your repo:

```go
package tests

import (
    "path/filepath"
    "testing"

    "github.com/McCainFoods/mf_terratest_framework/terratest/modules/loganalytics"
)

func TestLogAnalyticsValidation(t *testing.T) {
    configPath := filepath.Join("..", "configs", "log_analytics_test_config.json")
    loganalytics.RunLogAnalyticsValidation(t, configPath)
}
```

### Step 3: Run the Tests

```bash
go test ./tests -v
```

---

## 📊 7. Sample Output

```bash
=== RUN   TestLogAnalyticsValidation/Validate_Workspace_prod-law
✅ Validated Log Analytics Workspace: prod-law
--- PASS: TestLogAnalyticsValidation (5.48s)
PASS
ok   github.com/McCainFoods/mf_terratest_framework/terratest/modules/loganalytics  5.49s
```

If a mismatch occurs:

```bash
Error: Expected retention_in_days = 30, got 7
```

---

## 🔄 8. Config Generator

The module includes a **config generator** (`gen_config.go`) to convert Terraform plan JSON to the expected config.

### Usage

```bash
terraform show -json > plan.json
go run scripts/gen_config.go plan.json > configs/log_analytics_test_config.json
```

---

## 🔒 9. Benefits

* ✅ **Drift Detection** – ensures Log Analytics workspaces match expected state
* ✅ **Reusable** – config-driven, works across multiple environments
* ✅ **CI/CD Ready** – can fail pipelines if infra drifts
* ✅ **Audit Friendly** – keeps compliance checks automated

---
