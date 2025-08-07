package acr

import (
	"context"
	"encoding/json"
	"fmt"
	"os/exec"
	"regexp"
	"testing"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerregistry/armcontainerregistry"
)

const subscriptionID = "855f9502-3230-4377-82a2-cc5c8fa3c59d"

// Struct for Azure CLI JSON responses
type ACRCLI struct {
	Policies struct {
		TrustPolicy struct {
			Status string `json:"status"`
		} `json:"trustPolicy"`
		RetentionPolicy struct {
			Enabled bool `json:"enabled"`
			Days    int  `json:"days"`
		} `json:"retentionPolicy"`
		AnonymousPullEnabled bool `json:"anonymousPullEnabled"`
	} `json:"policies"`
	Quota struct {
		MaxCapacityInGiB int `json:"maxCapacityInGiB"`
	} `json:"quota"`
}

// Helper function to call `az acr show`
func getACRPolicies(name, rg string) (*ACRCLI, error) {
	cmd := exec.Command("az", "acr", "show", "--name", name, "--resource-group", rg, "-o", "json")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	var result ACRCLI
	err = json.Unmarshal(output, &result)
	return &result, err
}

// RunACRValidation validates Azure Container Registries against config
func RunACRValidation(t *testing.T, configPath string) {
	cfg, err := common.LoadACRTestConfig(configPath)
	require.NoError(t, err)

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err)

	acrClient, err := armcontainerregistry.NewRegistriesClient(subscriptionID, cred, nil)
	require.NoError(t, err)

	replicationClient, err := armcontainerregistry.NewReplicationsClient(subscriptionID, cred, nil)
	require.NoError(t, err)

	webhookClient, err := armcontainerregistry.NewWebhooksClient(subscriptionID, cred, nil)
	require.NoError(t, err)

	for acrName, acrCfg := range cfg.Registries {
		t.Run("Validate_ACR_"+acrName, func(t *testing.T) {
			acrResp, err := acrClient.Get(context.Background(), acrCfg.ResourceGroupName, acrCfg.Name, nil)
			require.NoError(t, err)
			acr := acrResp.Registry

			// Basic Validation
			assert.Equal(t, acrCfg.Location, *acr.Location)
			assert.Equal(t, acrCfg.SKU, string(*acr.SKU.Name))
			assert.Equal(t, acrCfg.AdminEnabled, *acr.Properties.AdminUserEnabled)
			assert.Regexp(t, regexp.MustCompile(`^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.ContainerRegistry/registries/.+`), *acr.ID)

			// Tags
			for k, v := range acrCfg.Tags {
				assert.Equal(t, v, *acr.Tags[k], fmt.Sprintf("Tag %s mismatch", k))
			}

			// Encryption
			if acrCfg.Encryption != "" {
				if acr.Properties.Encryption != nil && acr.Properties.Encryption.KeyVaultProperties != nil {
					assert.Equal(t, acrCfg.Encryption, "CMK")
				} else {
					assert.Equal(t, acrCfg.Encryption, "MicrosoftManaged")
				}
			}

			// Network Rules
			if acrCfg.NetworkRules.DefaultAction != "" {
				nrp := acr.Properties.NetworkRuleSet
				require.NotNil(t, nrp)
				assert.Equal(t, acrCfg.NetworkRules.DefaultAction, string(*nrp.DefaultAction))

				if len(acrCfg.NetworkRules.IPRules) > 0 {
					var actualIPs []string
					for _, ip := range nrp.IPRules {
						actualIPs = append(actualIPs, *ip.IPAddressOrRange)
					}
					assert.ElementsMatch(t, acrCfg.NetworkRules.IPRules, actualIPs)
				}
			}

			// Private Endpoints
			if len(acrCfg.PrivateEndpoints) > 0 {
				var actualPEs []string
				for _, pe := range acr.Properties.PrivateEndpointConnections {
					actualPEs = append(actualPEs, *pe.ID)
				}
				assert.Subset(t, actualPEs, acrCfg.PrivateEndpoints)
			}

			// Geo-Replications
			if len(acrCfg.Replications) > 0 {
				pager := replicationClient.NewListPager(acrCfg.ResourceGroupName, acrCfg.Name, nil)
				var actualReplicas []string
				for pager.More() {
					page, err := pager.NextPage(context.Background())
					require.NoError(t, err)
					for _, rep := range page.Value {
						actualReplicas = append(actualReplicas, *rep.Location)
					}
				}
				var expectedReplicas []string
				for _, rep := range acrCfg.Replications {
					expectedReplicas = append(expectedReplicas, rep.Location)
				}
				assert.ElementsMatch(t, expectedReplicas, actualReplicas)
			}

			// Webhooks (name, actions, tags only)
			if len(acrCfg.Webhooks) > 0 {
				pager := webhookClient.NewListPager(acrCfg.ResourceGroupName, acrCfg.Name, nil)
				var actualHooks []string
				for pager.More() {
					page, err := pager.NextPage(context.Background())
					require.NoError(t, err)
					for _, hook := range page.Value {
						actualHooks = append(actualHooks, *hook.Name)
						for _, expectedHook := range acrCfg.Webhooks {
							if *hook.Name == expectedHook.Name {
								// Actions
								var actualActions []string
								for _, a := range hook.Properties.Actions {
									actualActions = append(actualActions, string(*a))
								}
								assert.ElementsMatch(t, expectedHook.Actions, actualActions)

								// Tags
								for k, v := range expectedHook.Tags {
									assert.Equal(t, v, *hook.Tags[k])
								}
							}
						}
					}
				}
				var expectedHooks []string
				for _, h := range acrCfg.Webhooks {
					expectedHooks = append(expectedHooks, h.Name)
				}
				assert.Subset(t, actualHooks, expectedHooks)
			}

			//  Extra Governance Checks via Azure CLI
			cliInfo, err := getACRPolicies(acrCfg.Name, acrCfg.ResourceGroupName)
			require.NoError(t, err)

			// Anonymous Pull
			assert.Equal(t, acrCfg.AnonymousPull, cliInfo.Policies.AnonymousPullEnabled, "Anonymous pull mismatch")

			// Content Trust
			expectedTrust := "Disabled"
			if acrCfg.ContentTrustEnabled {
				expectedTrust = "Enabled"
			}
			assert.Equal(t, expectedTrust, cliInfo.Policies.TrustPolicy.Status, "Content Trust mismatch")

			// Retention Policy
			if acrCfg.RetentionDays > 0 {
				assert.True(t, cliInfo.Policies.RetentionPolicy.Enabled, "Retention policy must be enabled")
				assert.Equal(t, acrCfg.RetentionDays, cliInfo.Policies.RetentionPolicy.Days, "Retention days mismatch")
			}

			// Quota
			if acrCfg.QuotaGB > 0 {
				assert.Equal(t, acrCfg.QuotaGB, cliInfo.Quota.MaxCapacityInGiB, "Quota mismatch")
			}
			fmt.Printf("✅ Validated ACR: %s\n", acrCfg.Name)
		})
	}
}
