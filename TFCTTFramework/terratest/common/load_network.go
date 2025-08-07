package common

import (
	"encoding/json"
	"os"
)

// Subnet Delegation Spec
type DelegationSpec struct {
	Name              string                `json:"name"`
	ServiceDelegation ServiceDelegationSpec `json:"service_delegation"`
}

type ServiceDelegationSpec struct {
	Name    string   `json:"name"`
	Actions []string `json:"actions"`
}

type SubnetSpec struct {
	Name                           string            `json:"name"`
	AddressPrefixes                []string          `json:"address_prefixes"`
	ServiceEndpoints               []string          `json:"service_endpoints"`
	DefaultOutboundAccessEnabled   bool              `json:"default_outbound_access_enabled"`
	NSGName                        string            `json:"nsg_name"`
	PrivateEndpointNetworkPolicies string            `json:"private_endpoint_network_policies"`
	Delegation                     []DelegationSpec  `json:"delegation"`
	Tags                           map[string]string `json:"tags"`
}

type VNetSpec struct {
	Name              string                `json:"name"`
	ResourceGroupName string                `json:"resource_group_name"`
	Location          string                `json:"location"`
	AddressSpace      []string              `json:"address_space"`
	Subnets           map[string]SubnetSpec `json:"subnets"`
}

type SecurityRuleSpec struct {
	Name                     string   `json:"name"`
	Priority                 int      `json:"priority"`
	Direction                string   `json:"direction"`
	Access                   string   `json:"access"`
	Protocol                 string   `json:"protocol"`
	SourcePortRange          string   `json:"source_port_range"`
	DestinationPortRange     string   `json:"destination_port_range"`
	SourceAddressPrefix      string   `json:"source_address_prefix"`
	SourceAddressPrefixes    []string `json:"source_address_prefixes"`
	DestinationAddressPrefix string   `json:"destination_address_prefix"`
}

type NSGSpec struct {
	Location          string                      `json:"location"`
	ResourceGroupName string                      `json:"resource_group_name"`
	SecurityRules     map[string]SecurityRuleSpec `json:"security_rules"`
}

// Route Spec for Route Tables
type RouteSpec struct {
	Name               string `json:"name"`
	AddressPrefix      string `json:"address_prefix"`
	NextHopType        string `json:"next_hop_type"`
	NextHopInIPAddress string `json:"next_hop_in_ip_address"`
}

type RouteTableSpec struct {
	Location          string               `json:"location"`
	ResourceGroupName string               `json:"resource_group_name"`
	Tags              map[string]string    `json:"tags"`
	SubnetResourceIDs map[string]string    `json:"subnet_resource_ids"`
	Routes            map[string]RouteSpec `json:"routes"`
}

type NetworkTestConfig struct {
	ExpectedPrincipalID string                    `json:"expected_principal_id"`
	VNets               map[string]VNetSpec       `json:"cc_vnet"`
	NSGs                map[string]NSGSpec        `json:"nsgs"`
	RouteTables         map[string]RouteTableSpec `json:"route_tables"`
}

// Load config JSON into struct
func LoadNetworkTestConfig(path string) (*NetworkTestConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var cfg NetworkTestConfig
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}
