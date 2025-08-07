package common

import (
	"encoding/json"
	"os"
)

// ----------------- Application Insights -----------------

type ExportSpec struct {
	Name        string            `json:"name"`
	Destination string            `json:"destination"`
	ExportTypes []string          `json:"export_types"`
	Enabled     bool              `json:"enabled"`
	Tags        map[string]string `json:"tags,omitempty"`
}

type AppInsightsSpec struct {
	Name                string            `json:"name"`
	ResourceGroupName   string            `json:"resource_group_name"`
	Location            string            `json:"location"`
	Kind                string            `json:"kind"` // Application type: web/other
	Tags                map[string]string `json:"tags"`
	RetentionInDays     int               `json:"retention_in_days"`
	DailyCapGB          int               `json:"daily_cap_gb"`
	DisableIpMasking    bool              `json:"disable_ip_masking"`
	WorkspaceResourceID string            `json:"workspace_resource_id"`
	PublicNetworkAccess bool              `json:"public_network_access"`
	Exports             []ExportSpec      `json:"exports"`
}

// Top-level config for Application Insights validation
type AppInsightsTestConfig struct {
	ExpectedPrincipalID string                     `json:"expected_principal_id"`
	Insights            map[string]AppInsightsSpec `json:"insights"`
}

// Loader function
func LoadAppInsightsTestConfig(path string) (*AppInsightsTestConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var cfg AppInsightsTestConfig
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}
