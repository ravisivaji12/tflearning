package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
)

// TerraformPlan defines the structure of a terraform show -json output
type TerraformPlan struct {
	PlannedValues struct {
		RootModule struct {
			Resources []struct {
				Address string                 `json:"address"`
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

	var plan TerraformPlan
	if err := json.Unmarshal(data, &plan); err != nil {
		panic(fmt.Sprintf("Failed to unmarshal plan: %v", err))
	}

	config := common.LogAnalyticsTestConfig{
		Workspaces: map[string]common.LogAnalyticsSpec{},
	}

	for _, res := range plan.PlannedValues.RootModule.Resources {
		if res.Type == "azurerm_log_analytics_workspace" {
			ws := common.LogAnalyticsSpec{
				Name:                getString(res.Values, "name"),
				ResourceGroupName:   getString(res.Values, "resource_group_name"),
				Location:            getString(res.Values, "location"),
				SKU:                 getString(res.Values, "sku"),
				RetentionInDays:     getInt32(res.Values, "retention_in_days"),
				DailyQuotaGB:        getInt(res.Values, "daily_quota_gb"),
				Tags:                getMap(res.Values, "tags"),
				PrivateLinkScopeIDs: getStringSlice(res.Values, "private_link_scope_ids"),
			}

			config.Workspaces[ws.Name] = ws
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

func getInt32(m map[string]interface{}, key string) int32 {
	if val, ok := m[key].(float64); ok {
		return int32(val)
	}
	return 0
}

func getInt(m map[string]interface{}, key string) int {
	if val, ok := m[key].(float64); ok {
		return int(val)
	}
	return 0
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
