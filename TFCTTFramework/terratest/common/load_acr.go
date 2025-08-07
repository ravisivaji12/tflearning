package common

import (
	"encoding/json"
	"os"
)

// Network rules for ACR firewall
type NetworkRuleSpec struct {
	DefaultAction string   `json:"default_action"`
	IPRules       []string `json:"ip_rules"`
}

// Geo-replication spec
type ReplicationSpec struct {
	Location string `json:"location"`
}

// Webhooks spec
type WebhookSpec struct {
	Name    string            `json:"name"`
	Actions []string          `json:"actions"`
	Tags    map[string]string `json:"tags"`
}

// Full ACR specification struct
type ACRSpec struct {
	Name              string            `json:"name"`
	ResourceGroupName string            `json:"resource_group_name"`
	Location          string            `json:"location"`
	SKU               string            `json:"sku"`
	AdminEnabled      bool              `json:"admin_enabled"`
	Encryption        string            `json:"encryption"`
	Tags              map[string]string `json:"tags"`
	NetworkRules      NetworkRuleSpec   `json:"network_rules"`
	PrivateEndpoints  []string          `json:"private_endpoints"`
	Replications      []ReplicationSpec `json:"replications"`
	Webhooks          []WebhookSpec     `json:"webhooks"`

	//  Governance & Compliance
	RetentionDays       int  `json:"retention_days"`        // retention policy days
	AnonymousPull       bool `json:"anonymous_pull"`        // allow/disallow anonymous pulls
	ContentTrustEnabled bool `json:"content_trust_enabled"` // enforce trusted content
	QuotaGB             int  `json:"quota_gb"`              // storage quota in GB
}

// Top-level test config object
type ACRTestConfig struct {
	ExpectedPrincipalID string             `json:"expected_principal_id"`
	Registries          map[string]ACRSpec `json:"registries"`
}

// LoadACRTestConfig loads ACR configuration JSON into struct
func LoadACRTestConfig(path string) (*ACRTestConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var cfg ACRTestConfig
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}
