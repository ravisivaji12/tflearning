package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
)

// TerraformACRPlan defines the Terraform JSON plan structure we need
type TerraformACRPlan struct {
	PlannedValues struct {
		RootModule struct {
			Resources []struct {
				Address string                 `json:"address"`
				Mode    string                 `json:"mode"`
				Type    string                 `json:"type"`
				Name    string                 `json:"name"`
				Values  map[string]interface{} `json:"values"`
			} `json:"resources"`
		} `json:"root_module"`
	} `json:"planned_values"`
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run gen_config.go <plan.json>")
		os.Exit(1)
	}

	planPath := os.Args[1]
	data, err := ioutil.ReadFile(planPath)
	if err != nil {
		panic(fmt.Sprintf("Failed to read plan file: %v", err))
	}

	var plan TerraformACRPlan
	if err := json.Unmarshal(data, &plan); err != nil {
		panic(fmt.Sprintf("Failed to unmarshal plan: %v", err))
	}

	config := common.ACRTestConfig{
		ExpectedPrincipalID: "replace-me-with-principal-id",
		Registries:          map[string]common.ACRSpec{},
	}

	for _, res := range plan.PlannedValues.RootModule.Resources {
		if res.Type == "azurerm_container_registry" {
			registry := common.ACRSpec{
				Name:                getString(res.Values, "name"),
				ResourceGroupName:   getString(res.Values, "resource_group_name"),
				Location:            getString(res.Values, "location"),
				SKU:                 getString(res.Values, "sku"),
				AdminEnabled:        getBool(res.Values, "admin_enabled"),
				Tags:                getMap(res.Values, "tags"),
				NetworkRules:        common.NetworkRuleSpec{},
				PrivateEndpoints:    []string{},
				Replications:        []common.ReplicationSpec{},
				Webhooks:            []common.WebhookSpec{},
				AnonymousPull:       getBool(res.Values, "anonymous_pull_enabled"),
				ContentTrustEnabled: getBoolFromNested(res.Values, "trust_policy", "enabled"),
				RetentionDays:       getIntFromNested(res.Values, "retention_policy", "days"),
				QuotaGB:             getIntFromNested(res.Values, "quota", "max_capacity_in_gib"),
			}

			// Network Rules
			if nr, ok := res.Values["network_rule_set"].([]interface{}); ok && len(nr) > 0 {
				if nrm, ok := nr[0].(map[string]interface{}); ok {
					registry.NetworkRules.DefaultAction = getString(nrm, "default_action")

					if ipRules, exists := nrm["ip_rule"].([]interface{}); exists {
						for _, ip := range ipRules {
							if ipm, ok := ip.(map[string]interface{}); ok {
								registry.NetworkRules.IPRules = append(registry.NetworkRules.IPRules, getString(ipm, "ip_range"))
							}
						}
					}
				}
			}

			// Replications
			if reps, ok := res.Values["georeplications"].([]interface{}); ok {
				for _, r := range reps {
					if rm, ok := r.(map[string]interface{}); ok {
						registry.Replications = append(registry.Replications, common.ReplicationSpec{
							Location: getString(rm, "location"),
						})
					}
				}
			}

			// Webhooks
			if whs, ok := res.Values["webhook"].([]interface{}); ok {
				for _, w := range whs {
					if wm, ok := w.(map[string]interface{}); ok {
						registry.Webhooks = append(registry.Webhooks, common.WebhookSpec{
							Name:    getString(wm, "name"),
							Actions: getStringSlice(wm, "actions"),
							Tags:    getMap(wm, "tags"),
						})
					}
				}
			}

			config.Registries[registry.Name] = registry
		}
	}

	output, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		panic(fmt.Sprintf("Failed to marshal config: %v", err))
	}

	fmt.Println(string(output))
}

// ----------------- Helpers -----------------

func getString(m map[string]interface{}, key string) string {
	if val, ok := m[key].(string); ok {
		return val
	}
	return ""
}

func getBool(m map[string]interface{}, key string) bool {
	if val, ok := m[key].(bool); ok {
		return val
	}
	return false
}

func getMap(m map[string]interface{}, key string) map[string]string {
	result := map[string]string{}
	if val, ok := m[key].(map[string]interface{}); ok {
		for k, v := range val {
			result[k] = fmt.Sprintf("%v", v)
		}
	}
	return result
}

func getStringSlice(m map[string]interface{}, key string) []string {
	result := []string{}
	if val, ok := m[key].([]interface{}); ok {
		for _, v := range val {
			if s, ok := v.(string); ok {
				result = append(result, s)
			}
		}
	}
	return result
}

func getBoolFromNested(m map[string]interface{}, parentKey, childKey string) bool {
	if parent, ok := m[parentKey].([]interface{}); ok && len(parent) > 0 {
		if pm, ok := parent[0].(map[string]interface{}); ok {
			if val, ok := pm[childKey].(bool); ok {
				return val
			}
		}
	}
	return false
}

func getIntFromNested(m map[string]interface{}, parentKey, childKey string) int {
	if parent, ok := m[parentKey].([]interface{}); ok && len(parent) > 0 {
		if pm, ok := parent[0].(map[string]interface{}); ok {
			if val, ok := pm[childKey].(float64); ok {
				return int(val)
			}
		}
	}
	return 0
}
