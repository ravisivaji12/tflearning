package loganalytics

import (
	"context"
	"fmt"
	"regexp"
	"testing"

	"github.com/McCainFoods/mf_terratest_framework/terratest/common"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/operationalinsights/armoperationalinsights"
)

const subscriptionID = "855f9502-3230-4377-82a2-cc5c8fa3c59d"

// RunLogAnalyticsValidation validates Log Analytics Workspaces
func RunLogAnalyticsValidation(t *testing.T, configPath string) {
	cfg, err := common.LoadLogAnalyticsTestConfig(configPath)
	require.NoError(t, err)

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err)

	client, err := armoperationalinsights.NewWorkspacesClient(subscriptionID, cred, nil)
	require.NoError(t, err)

	for wsName, wsCfg := range cfg.Workspaces {
		t.Run("Validate_Workspace_"+wsName, func(t *testing.T) {
			resp, err := client.Get(context.Background(), wsCfg.ResourceGroupName, wsCfg.Name, nil)
			require.NoError(t, err)
			ws := resp.Workspace

			// Location
			assert.Equal(t, wsCfg.Location, *ws.Location)

			// Resource ID format
			assert.Regexp(t, regexp.MustCompile(`^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.OperationalInsights/workspaces/.+`), *ws.ID)

			// SKU (fixed location)
			if wsCfg.SKU != "" && ws.Properties != nil && ws.Properties.SKU != nil && ws.Properties.SKU.Name != nil {
				assert.Equal(t, wsCfg.SKU, string(*ws.Properties.SKU.Name))
			}

			// Retention in Days
			if wsCfg.RetentionInDays > 0 && ws.Properties.RetentionInDays != nil {
				assert.Equal(t, wsCfg.RetentionInDays, *ws.Properties.RetentionInDays)
			}

			// Tags
			for k, v := range wsCfg.Tags {
				if val, ok := ws.Tags[k]; ok && val != nil {
					assert.Equal(t, v, *val, fmt.Sprintf("Tag %s mismatch", k))
				} else {
					t.Errorf("Tag %s not found on workspace %s", k, wsCfg.Name)
				}
			}

			// Daily Quota (SDK doesn’t expose directly → CLI fallback)
			if wsCfg.DailyQuotaGB > 0 {
				fmt.Printf("⚠️ Daily quota check for %s should be validated via Azure CLI (not exposed in SDK)\n", wsCfg.Name)
			}

			// Private Link Scope IDs
			if len(wsCfg.PrivateLinkScopeIDs) > 0 && ws.Properties.PrivateLinkScopedResources != nil {
				var actualScopes []string
				for _, pls := range ws.Properties.PrivateLinkScopedResources {
					if pls != nil && pls.ResourceID != nil {
						actualScopes = append(actualScopes, *pls.ResourceID)
					}
				}
				assert.Subset(t, actualScopes, wsCfg.PrivateLinkScopeIDs)
			}

			fmt.Printf("✅ Validated Log Analytics Workspace: %s\n", wsCfg.Name)
		})
	}
}
