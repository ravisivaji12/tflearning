package appinsights

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
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/applicationinsights/armapplicationinsights"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/monitor/armmonitor"
)

const subscriptionID = "855f9502-3230-4377-82a2-cc5c8fa3c59d"

// RunAppInsightsValidation validates Application Insights resources
func RunAppInsightsValidation(t *testing.T, configPath string) {
	cfg, err := common.LoadAppInsightsTestConfig(configPath)
	require.NoError(t, err)

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err)

	client, err := armapplicationinsights.NewComponentsClient(subscriptionID, cred, nil)
	require.NoError(t, err)

	diagClient, err := armmonitor.NewDiagnosticSettingsClient(cred, nil) // ✅ FIXED
	require.NoError(t, err)

	for aiName, aiCfg := range cfg.Insights {
		t.Run("Validate_AppInsights_"+aiName, func(t *testing.T) {
			aiResp, err := client.Get(context.Background(), aiCfg.ResourceGroupName, aiCfg.Name, nil)
			require.NoError(t, err)
			ai := aiResp.Component

			// Basic validation
			assert.Equal(t, aiCfg.Location, *ai.Location)
			assert.Equal(t, aiCfg.Kind, *ai.Kind)
			assert.Regexp(t, regexp.MustCompile(`^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Insights/components/.+`), *ai.ID)

			// Tags
			for k, v := range aiCfg.Tags {
				assert.Equal(t, v, *ai.Tags[k])
			}

			// Retention policy
			if aiCfg.RetentionInDays > 0 && ai.Properties.RetentionInDays != nil {
				assert.Equal(t, int32(aiCfg.RetentionInDays), *ai.Properties.RetentionInDays)
			}

			// Daily Cap
			validateWithAzureCLI(t, aiCfg.Name, aiCfg.ResourceGroupName, aiCfg.RetentionInDays, aiCfg.DailyCapGB)

			// IP Masking
			if ai.Properties.DisableIPMasking != nil {
				assert.Equal(t, aiCfg.DisableIpMasking, *ai.Properties.DisableIPMasking)
			}

			// Linked Workspace
			if aiCfg.WorkspaceResourceID != "" && ai.Properties.WorkspaceResourceID != nil {
				assert.Equal(t, aiCfg.WorkspaceResourceID, *ai.Properties.WorkspaceResourceID)
			}

			// Public Network Access
			if ai.Properties.PublicNetworkAccessForIngestion != nil {
				isEnabled := *ai.Properties.PublicNetworkAccessForIngestion == "Enabled"
				assert.Equal(t, aiCfg.PublicNetworkAccess, isEnabled)
			}

			// Diagnostic Settings Validation (instead of Continuous Exports)
			if len(aiCfg.Exports) > 0 {
				resourceID := fmt.Sprintf(
					"/subscriptions/%s/resourceGroups/%s/providers/microsoft.insights/components/%s",
					subscriptionID, aiCfg.ResourceGroupName, aiCfg.Name,
				)

				pager := diagClient.NewListPager(resourceID, nil)
				var actualExports []string
				for pager.More() {
					page, err := pager.NextPage(context.Background())
					require.NoError(t, err)
					for _, setting := range page.Value {
						actualExports = append(actualExports, *setting.Name)
						for _, expected := range aiCfg.Exports {
							if *setting.Name == expected.Name {
								if setting.Properties.StorageAccountID != nil {
									assert.Equal(t, expected.Destination, *setting.Properties.StorageAccountID)
								}
							}
						}
					}
				}
				var expectedExports []string
				for _, e := range aiCfg.Exports {
					expectedExports = append(expectedExports, e.Name)
				}
				assert.Subset(t, actualExports, expectedExports)
			}

			fmt.Printf("✅ Validated Application Insights: %s\n", aiCfg.Name)
		})
	}
}

// validateWithAzureCLI runs `az monitor app-insights` commands for advanced settings
func validateWithAzureCLI(t *testing.T, name, rg string, expectedRetention int, expectedCapGB int) {
	cmd := exec.Command("az", "monitor", "app-insights", "component", "show",
		"--app", name,
		"--resource-group", rg,
		"-o", "json")
	out, err := cmd.Output()
	require.NoError(t, err, "Failed to execute Azure CLI for App Insights")

	var props map[string]interface{}
	err = json.Unmarshal(out, &props)
	require.NoError(t, err)

	// Retention Policy
	if val, ok := props["retentionInDays"].(float64); ok && expectedRetention > 0 {
		assert.Equal(t, float64(expectedRetention), val)
	}

	// Daily Cap (CLI returns float)
	if val, ok := props["dailyDataCapGB"].(float64); ok && expectedCapGB > 0 {
		assert.Equal(t, float64(expectedCapGB), val)
	}
}
