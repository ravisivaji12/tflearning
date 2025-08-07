package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
)

// TerraformPlan parses terraform show -json output
type TerraformPlan struct {
	Values struct {
		RootModule struct {
			Resources []struct {
				Address string                 `json:"address"`
				Type    string                 `json:"type"`
				Name    string                 `json:"name"`
				Values  map[string]interface{} `json:"values"`
			} `json:"resources"`
		} `json:"root_module"`
	} `json:"values"`
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run gen_config.go <plan.json>")
		os.Exit(1)
	}

	planFile := os.Args[1]
	data, err := ioutil.ReadFile(planFile)
	if err != nil {
		panic(fmt.Errorf("failed to read plan file: %w", err))
	}

	var plan TerraformPlan
	if err := json.Unmarshal(data, &plan); err != nil {
		panic(fmt.Errorf("failed to parse plan.json: %w", err))
	}

	config := common.NetworkTestConfig{
		ExpectedPrincipalID: "",
		VNets:               make(map[string]common.VNetSpec),
		NSGs:                make(map[string]common.NSGSpec),
		RouteTables:         make(map[string]common.RouteTableSpec),
	}

	for _, r := range plan.Values.RootModule.Resources {
		switch r.Type {

		case "azurerm_virtual_network":
			name := r.Values["name"].(string)
			vnet := common.VNetSpec{
				Name:              name,
				ResourceGroupName: r.Values["resource_group_name"].(string),
				Location:          r.Values["location"].(string),
				AddressSpace:      toStringSlice(r.Values["address_space"].([]interface{})),
				Subnets:           make(map[string]common.SubnetSpec),
			}
			config.VNets[name] = vnet

		case "azurerm_subnet":
			vnetName := r.Values["virtual_network_name"].(string)
			subnetName := r.Values["name"].(string)

			subnet := common.SubnetSpec{
				Name:                           subnetName,
				AddressPrefixes:                toStringSlice(r.Values["address_prefixes"].([]interface{})),
				ServiceEndpoints:               toStringSliceSafe(r.Values["service_endpoints"]),
				DefaultOutboundAccessEnabled:   getBoolSafe(r.Values, "default_outbound_access_enabled"),
				NSGName:                        extractNSGName(r.Values),
				PrivateEndpointNetworkPolicies: getStringSafe(r.Values, "private_endpoint_network_policies"),
				Delegation:                     parseDelegations(r.Values["delegation"]),
				Tags:                           toStringMapSafe(r.Values["tags"]),
			}

			vnet := config.VNets[vnetName]
			vnet.Subnets[subnetName] = subnet
			config.VNets[vnetName] = vnet

		case "azurerm_network_security_group":
			nsgName := r.Values["name"].(string)
			nsg := common.NSGSpec{
				Location:          r.Values["location"].(string),
				ResourceGroupName: r.Values["resource_group_name"].(string),
				SecurityRules:     make(map[string]common.SecurityRuleSpec),
			}
			config.NSGs[nsgName] = nsg

		case "azurerm_route_table":
			rtName := r.Values["name"].(string)
			rt := common.RouteTableSpec{
				Location:          r.Values["location"].(string),
				ResourceGroupName: r.Values["resource_group_name"].(string),
				Tags:              toStringMapSafe(r.Values["tags"]),
				SubnetResourceIDs: make(map[string]string),
				Routes:            make(map[string]common.RouteSpec),
			}
			config.RouteTables[rtName] = rt
		}
	}

	out, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		panic(fmt.Errorf("failed to marshal config: %w", err))
	}

	if err := ioutil.WriteFile("configs/cc_network_test_config.json", out, 0644); err != nil {
		panic(fmt.Errorf("failed to write config file: %w", err))
	}

	fmt.Println("✅ Config generated: configs/cc_network_test_config.json")
}

// Helpers

func toStringSlice(input []interface{}) []string {
	out := []string{}
	for _, v := range input {
		out = append(out, v.(string))
	}
	return out
}

func toStringSliceSafe(input interface{}) []string {
	if input == nil {
		return []string{}
	}
	arr, ok := input.([]interface{})
	if !ok {
		return []string{}
	}
	return toStringSlice(arr)
}

func toStringMapSafe(input interface{}) map[string]string {
	out := map[string]string{}
	if input == nil {
		return out
	}
	m, ok := input.(map[string]interface{})
	if !ok {
		return out
	}
	for k, v := range m {
		out[k] = fmt.Sprintf("%v", v)
	}
	return out
}

func getStringSafe(values map[string]interface{}, key string) string {
	if val, ok := values[key]; ok && val != nil {
		return val.(string)
	}
	return ""
}

func getBoolSafe(values map[string]interface{}, key string) bool {
	if val, ok := values[key]; ok && val != nil {
		return val.(bool)
	}
	return false
}

func extractNSGName(values map[string]interface{}) string {
	if id, ok := values["network_security_group_id"].(string); ok && id != "" {
		parts := strings.Split(id, "/")
		return parts[len(parts)-1]
	}
	return ""
}

func parseDelegations(input interface{}) []common.DelegationSpec {
	if input == nil {
		return []common.DelegationSpec{}
	}

	arr, ok := input.([]interface{})
	if !ok {
		return []common.DelegationSpec{}
	}

	var result []common.DelegationSpec
	for _, item := range arr {
		deleg, ok := item.(map[string]interface{})
		if !ok {
			continue
		}

		spec := common.DelegationSpec{
			Name: getStringFromMap(deleg, "name"),
		}

		if sd, ok := deleg["service_delegation"].(map[string]interface{}); ok {
			spec.ServiceDelegation = common.ServiceDelegationSpec{
				Name:    getStringFromMap(sd, "name"),
				Actions: toStringSliceSafe(sd["actions"]),
			}
		}

		result = append(result, spec)
	}

	return result
}

func getStringFromMap(m map[string]interface{}, key string) string {
	if val, ok := m[key]; ok && val != nil {
		return fmt.Sprintf("%v", val)
	}
	return ""
}
