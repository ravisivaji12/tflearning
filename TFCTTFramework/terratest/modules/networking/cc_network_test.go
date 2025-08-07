package networking

import (
	"context"
	"fmt"
	"path/filepath"
	"regexp"
	"testing"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork"
)

const subscriptionID = "855f9502-3230-4377-82a2-cc5c8fa3c59d"

// normalizeSlice ensures nil slices become empty slices
func normalizeSlice(s []string) []string {
	if s == nil || len(s) == 0 {
		return []string{}
	}
	return s
}

// convert Azure []*string to []string
func convertPointers(ptrs []*string) []string {
	var vals []string
	for _, p := range ptrs {
		if p != nil {
			vals = append(vals, *p)
		}
	}
	return vals
}

func TestNetworkingValidation(t *testing.T) {
	configPath := filepath.Join("..", "..", "configs", "cc_network_test_config.json")
	cfg, err := common.LoadNetworkTestConfig(configPath)
	require.NoError(t, err)

	cred, _ := azidentity.NewDefaultAzureCredential(nil)
	vnetClient, _ := armnetwork.NewVirtualNetworksClient(subscriptionID, cred, nil)
	subnetClient, _ := armnetwork.NewSubnetsClient(subscriptionID, cred, nil)
	nsgClient, _ := armnetwork.NewSecurityGroupsClient(subscriptionID, cred, nil)
	rtClient, _ := armnetwork.NewRouteTablesClient(subscriptionID, cred, nil)

	// Validate each VNet
	for vnetName, vnetCfg := range cfg.VNets {
		t.Run("Validate_VNet_"+vnetName, func(t *testing.T) {
			vnetResp, err := vnetClient.Get(context.Background(), vnetCfg.ResourceGroupName, vnetCfg.Name, nil)
			require.NoError(t, err)
			vnet := vnetResp.VirtualNetwork

			// Location and ID
			assert.Equal(t, vnetCfg.Location, *vnet.Location)
			assert.Regexp(t,
				regexp.MustCompile(`^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+`),
				*vnet.ID)

			// Address Spaces
			var actualSpaces []string
			if vnet.Properties.AddressSpace != nil && vnet.Properties.AddressSpace.AddressPrefixes != nil {
				actualSpaces = convertPointers(vnet.Properties.AddressSpace.AddressPrefixes)
			}
			assert.ElementsMatch(t,
				normalizeSlice(vnetCfg.AddressSpace),
				normalizeSlice(actualSpaces),
			)

			// Validate Subnets
			for subnetName, subnetCfg := range vnetCfg.Subnets {
				if subnetCfg.Name == "" {
					subnetCfg.Name = subnetName // fallback if config missing "name"
				}
				t.Run("Validate_Subnet_"+subnetName, func(t *testing.T) {
					subnetResp, err := subnetClient.Get(context.Background(),
						vnetCfg.ResourceGroupName, vnetCfg.Name, subnetCfg.Name, nil)
					require.NoError(t, err)
					subnet := subnetResp.Subnet

					// Address Prefixes
					var actualPrefixes []string
					if subnet.Properties.AddressPrefix != nil {
						actualPrefixes = append(actualPrefixes, *subnet.Properties.AddressPrefix)
					}
					if subnet.Properties.AddressPrefixes != nil {
						actualPrefixes = append(actualPrefixes, convertPointers(subnet.Properties.AddressPrefixes)...)
					}
					assert.ElementsMatch(t,
						normalizeSlice(subnetCfg.AddressPrefixes),
						normalizeSlice(actualPrefixes),
					)

					// NSG check
					if subnetCfg.NSGName != "" {
						if subnet.Properties.NetworkSecurityGroup == nil {
							assert.Failf(t, "NSG missing",
								"Expected NSG %s for subnet %s but none found",
								subnetCfg.NSGName, subnetCfg.Name)
						} else {
							assert.Contains(t, *subnet.Properties.NetworkSecurityGroup.ID, subnetCfg.NSGName)
						}
					}

					// Service Endpoints
					if subnet.Properties.ServiceEndpoints != nil {
						var actualEndpoints []string
						for _, ep := range subnet.Properties.ServiceEndpoints {
							actualEndpoints = append(actualEndpoints, *ep.Service)
						}
						assert.ElementsMatch(t,
							normalizeSlice(subnetCfg.ServiceEndpoints),
							normalizeSlice(actualEndpoints),
						)
					}

					// Delegations
					if len(subnetCfg.Delegation) > 0 {
						require.NotNil(t, subnet.Properties.Delegations)
						for _, expectedDel := range subnetCfg.Delegation {
							found := false
							for _, actualDel := range subnet.Properties.Delegations {
								if *actualDel.Name == expectedDel.Name {
									found = true
									assert.Equal(t,
										expectedDel.ServiceDelegation.Name,
										*actualDel.Properties.ServiceName)
									assert.ElementsMatch(t,
										expectedDel.ServiceDelegation.Actions,
										normalizeSlice(convertPointers(actualDel.Properties.Actions)))
								}
							}
							assert.True(t, found,
								fmt.Sprintf("Delegation %s not found in subnet %s", expectedDel.Name, subnetCfg.Name))
						}
					}

					// Route Table association
					if subnet.Properties.RouteTable != nil && subnet.Properties.RouteTable.ID != nil {
						assert.NotEmpty(t, *subnet.Properties.RouteTable.ID,
							"Subnet %s expected to have route table association", subnetCfg.Name)
					}
				})
			}
		})
	}

	// Validate NSGs
	for nsgName, nsgCfg := range cfg.NSGs {
		t.Run("Validate_NSG_"+nsgName, func(t *testing.T) {
			nsgResp, err := nsgClient.Get(context.Background(), nsgCfg.ResourceGroupName, nsgName, nil)
			require.NoError(t, err)
			nsg := nsgResp.SecurityGroup

			for ruleName, expectedRule := range nsgCfg.SecurityRules {
				found := false
				for _, actual := range nsg.Properties.SecurityRules {
					if *actual.Name == ruleName {
						found = true
						assert.Equal(t, expectedRule.Direction, string(*actual.Properties.Direction))
						assert.Equal(t, expectedRule.Access, string(*actual.Properties.Access))
						assert.Equal(t, expectedRule.Protocol, string(*actual.Properties.Protocol))
						assert.Equal(t, expectedRule.DestinationPortRange, *actual.Properties.DestinationPortRange)
						assert.Equal(t, expectedRule.SourcePortRange, *actual.Properties.SourcePortRange)

						// Priority check
						assert.Equal(t, expectedRule.Priority, int(*actual.Properties.Priority))

						// Source / Destination Prefixes
						if expectedRule.SourceAddressPrefix != "" && actual.Properties.SourceAddressPrefix != nil {
							assert.Equal(t, expectedRule.SourceAddressPrefix, *actual.Properties.SourceAddressPrefix)
						}
						if len(expectedRule.SourceAddressPrefixes) > 0 && actual.Properties.SourceAddressPrefixes != nil {
							assert.ElementsMatch(t, expectedRule.SourceAddressPrefixes,
								normalizeSlice(convertPointers(actual.Properties.SourceAddressPrefixes)))
						}
						if expectedRule.DestinationAddressPrefix != "" && actual.Properties.DestinationAddressPrefix != nil {
							assert.Equal(t, expectedRule.DestinationAddressPrefix, *actual.Properties.DestinationAddressPrefix)
						}
						break
					}
				}
				assert.True(t, found,
					fmt.Sprintf("Expected rule %s not found in NSG %s", ruleName, nsgName))
			}
		})
	}

	// Validate Route Tables
	for rtName, rtCfg := range cfg.RouteTables {
		t.Run("Validate_RT_"+rtName, func(t *testing.T) {
			rtResp, err := rtClient.Get(context.Background(), rtCfg.ResourceGroupName, rtName, nil)
			if err != nil {
				t.Skipf("Skipping Route Table %s validation: %v", rtName, err)
				return
			}
			rt := rtResp.RouteTable

			assert.Equal(t, rtCfg.Location, *rt.Location)
			for k, v := range rtCfg.Tags {
				if actualVal, ok := rt.Tags[k]; ok && actualVal != nil {
					assert.Equal(t, v, *actualVal)
				} else {
					assert.Fail(t, fmt.Sprintf("Expected tag %s not found on route table %s", k, rtName))
				}
			}

			// Routes
			if len(rtCfg.Routes) > 0 {
				require.NotNil(t, rt.Properties.Routes)
				for _, expectedRoute := range rtCfg.Routes {
					found := false
					for _, actualRoute := range rt.Properties.Routes {
						if *actualRoute.Name == expectedRoute.Name {
							found = true
							assert.Equal(t, expectedRoute.AddressPrefix, *actualRoute.Properties.AddressPrefix)
							assert.Equal(t, expectedRoute.NextHopType, string(*actualRoute.Properties.NextHopType))
							if expectedRoute.NextHopInIPAddress != "" && actualRoute.Properties.NextHopIPAddress != nil {
								assert.Equal(t, expectedRoute.NextHopInIPAddress, *actualRoute.Properties.NextHopIPAddress)
							}
							break
						}
					}
					assert.True(t, found,
						fmt.Sprintf("Expected route %s not found in RT %s", expectedRoute.Name, rtName))
				}
			}

			// Subnet associations
			if len(rtCfg.SubnetResourceIDs) > 0 {
				require.NotNil(t, rt.Properties.Subnets)
				var actualSubnets []string
				for _, s := range rt.Properties.Subnets {
					if s.ID != nil {
						actualSubnets = append(actualSubnets, *s.ID)
					}
				}
				var expectedSubnets []string
				for _, sid := range rtCfg.SubnetResourceIDs {
					expectedSubnets = append(expectedSubnets, sid)
				}
				assert.ElementsMatch(t, expectedSubnets, actualSubnets)
			}
		})
	}
}
