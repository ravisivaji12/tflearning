package common

import (
	"encoding/json"
	"os"
)

type LogAnalyticsTestConfig struct {
	Workspaces map[string]LogAnalyticsSpec `json:"workspaces"`
}

type LogAnalyticsSpec struct {
	Name                string            `json:"name"`
	ResourceGroupName   string            `json:"resource_group_name"`
	Location            string            `json:"location"`
	SKU                 string            `json:"sku"`
	RetentionInDays     int32             `json:"retention_in_days"`
	DailyQuotaGB        int               `json:"daily_quota_gb"`
	Tags                map[string]string `json:"tags"`
	PrivateLinkScopeIDs []string          `json:"private_link_scope_ids"`
}

func LoadLogAnalyticsTestConfig(path string) (*LogAnalyticsTestConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var cfg LogAnalyticsTestConfig
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}
