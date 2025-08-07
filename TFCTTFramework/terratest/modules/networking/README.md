
---

# 📘 Terratest Networking Validation Framework

A reusable **Go module** for validating Azure networking resources (**VNets, Subnets, NSGs, and Route Tables**) using **Terratest** and the **Azure Go SDK**.
It ensures your IaC deployments match expected configurations, preventing drift and enforcing compliance.

---

## 🚀 Features

* **VNet Validation**: Location, ID format, address spaces
* **Subnet Validation**: CIDR prefixes, NSG association, service endpoints, delegations, outbound access, tags
* **NSG Validation**: Rule existence and properties (direction, access, priority, protocol, ports, prefixes)
* **Route Table Validation**: Location, tags, routes (prefix, next hop, next hop IP), subnet associations
* **Config-driven**: Update JSON instead of Go code
* **CI/CD Ready**: Detects infra drift in pipelines

---

## 📂 Module Structure

```
mf_terratest_framework/
│
├── terratest/
│   ├── common/
│   │   └── common.go               # Shared structs & config loader
│   └── modules/
│       └── networking/
│           └── cc_network_test.go  # Networking validation test logic
│
└── configs/
    └── cc_network_test_config.json # Expected infrastructure config
```

---

## ⚙️ Dependencies

* Go 1.20+
* Terraform >= 1.3
* Azure CLI authenticated (`az login`)
* Go libraries:

  * `github.com/Azure/azure-sdk-for-go/sdk/azidentity`
  * `github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork`
  * `github.com/stretchr/testify`

---

## 📑 Configuration

Each team defines a JSON file with expected infrastructure.

### Example (`configs/cc_network_test_config.json`)

```json
{
  "expected_principal_id": "5d976b48-4340-4c05-ab09-e80ef3751794",
  "cc_vnet": {
    "MyVNet": {
      "address_space": ["10.0.0.0/16"],
      "location": "canadacentral",
      "name": "MyVNet",
      "resource_group_name": "my-rg",
      "subnets": {
        "MySubnet": {
          "name": "MySubnet",
          "address_prefixes": ["10.0.1.0/24"],
          "nsg_name": "MySubnet-NSG",
          "default_outbound_access_enabled": true,
          "delegation": [],
          "service_endpoints": []
        }
      }
    }
  },
  "nsgs": {
    "MySubnet-NSG": {
      "location": "canadacentral",
      "resource_group_name": "my-rg",
      "security_rules": {
        "AllowHTTPS": {
          "access": "Allow",
          "direction": "Inbound",
          "priority": 100,
          "protocol": "Tcp",
          "source_address_prefix": "*",
          "source_port_range": "*",
          "destination_address_prefix": "*",
          "destination_port_range": "443",
          "name": "AllowHTTPS",
          "source_address_prefixes": []
        }
      }
    }
  },
  "route_tables": {}
}
```

---

## 🧪 Usage

### 1. Install the Module

```bash
go get github.com/McCainFoods/mf_terratest_framework/terratest/modules/networking
go mod tidy
```

### 2. Write a Test

`tests/networking_test.go`:

```go
package tests

import (
    "path/filepath"
    "testing"

    "github.com/McCainFoods/mf_terratest_framework/terratest/modules/networking"
)

func TestNetworkingValidation(t *testing.T) {
    configPath := filepath.Join("..", "configs", "cc_network_test_config.json")
    networking.RunNetworkingValidation(t, configPath)
}
```

### 3. Run the Tests

```bash
go test ./tests -v
```

**Sample Output**

```
=== RUN   TestNetworkingValidation/Validate_VNet_MyVNet
=== RUN   TestNetworkingValidation/Validate_Subnet_MySubnet
=== RUN   TestNetworkingValidation/Validate_NSG_MySubnet-NSG
--- PASS: TestNetworkingValidation (12.4s)
```

If there’s a mismatch, the test fails with details:

```
Error: Expected NSG rule AllowHTTPS not found in NSG MySubnet-NSG
```

---

## 🔗 CI/CD Integration

### GitHub Actions Example

```yaml
jobs:
  networking-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.20'
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - run: go test ./tests -v
```

---

## 🔧 Advanced Usage

### Auto-Generate Config from Terraform

```bash
terraform show -json > plan.json
go run scripts/gen_config.go plan.json > configs/cc_network_test_config.json
```

Note: Config generation is in Beta and please use this as an interim till it is completely tested and release for general use.

---

## ❗ Troubleshooting

* **Error: parameter subnetName cannot be empty**
  → Ensure every subnet in JSON includes `"name"`.

* **json: cannot unmarshal object into Go struct**
  → Verify JSON structure matches `common/common.go`.

* **ResourceGroupNotFound**
  → Check the resource group exists in Azure or leave `route_tables` empty.

---

## 📊 Benefits

* 🔒 Ensures NSG and network compliance
* ⚡ Automated drift detection in CI/CD
* 📑 JSON configs double as architecture docs
* 🔁 Reusable across dev, QA, and prod environments

---

Maintained by **McCain Foods DevSecOps Team**
📩 Contact: [devsecops@mccain.com](mailto:devsecops@mccain.com)

---

✅ This version eliminates duplication, flows logically from setup → config → test → CI/CD, and is easy for other teams to follow.

---

Do you want me to also create a **minimal `RunNetworkingValidation` helper function** in the module, so teams only need to call one function without writing the boilerplate test?
