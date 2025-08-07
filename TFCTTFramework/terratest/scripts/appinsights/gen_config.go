package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
)

// Terraform plan structure for Application Insights
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

	config := common.AppInsightsTestConfig{
		ExpectedPrincipalID: "replace-me-with-principal-id",
		Insights:            map[string]common.AppInsightsSpec{},
	}

	for _, res := range plan.PlannedValues.RootModule.Resources {
		if res.Type == "azurerm_application_insights" {
			ai := common.AppInsightsSpec{
				Name:                getString(res.Values, "name"),
				ResourceGroupName:   getString(res.Values, "resource_group_name"),
				Location:            getString(res.Values, "location"),
				Kind:                getString(res.Values, "application_type"),
				Tags:                getMap(res.Values, "tags"),
				RetentionInDays:     getInt(res.Values, "retention_in_days"),
				DailyCapGB:          getInt(res.Values, "daily_data_cap_gb"),
				DisableIpMasking:    getBool(res.Values, "disable_ip_masking"),
				WorkspaceResourceID: getString(res.Values, "workspace_id"),
				PublicNetworkAccess: getBool(res.Values, "internet_ingestion_enabled"),
				Exports:             []common.ExportSpec{},
			}

			// Continuous Export (if defined in plan)
			if exports, ok := res.Values["export"].([]interface{}); ok {
				for _, e := range exports {
					if em, ok := e.(map[string]interface{}); ok {
						ai.Exports = append(ai.Exports, common.ExportSpec{
							Name:        getString(em, "name"),
							Destination: getString(em, "destination_storage_location_id"),
							ExportTypes: getStringSlice(em, "export_type"),
							Enabled:     getBool(em, "enabled"),
						})
					}
				}
			}

			config.Insights[ai.Name] = ai
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
