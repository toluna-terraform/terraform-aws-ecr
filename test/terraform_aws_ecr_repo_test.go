package main

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	tolunacommons "github.com/toluna-terraform/terraform-test-library/modules/commons"
	tolunacoverage "github.com/toluna-terraform/terraform-test-library/modules/coverage"
	"math/rand"
	"strconv"
	"testing"
)

func TestTerraformEcrTest(t *testing.T) {
	const Region = "us-east-1"
	var err error
	var RepoName = "test-ecr-repo-" + strconv.Itoa(rand.Int())
	var moduleName = tolunacommons.GetModName()
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples",
		Vars: map[string]interface{}{
			"ecr_repo_name": RepoName,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	tolunacoverage.WriteCovergeFiles(t, terraformOptions, moduleName)

	Repo, err := aws.GetECRRepoE(t, Region, RepoName)

	assert.NoError(t, err)
	assert.Equal(t, *Repo.RepositoryName, RepoName)
	tolunacoverage.MarkAsCovered("aws_ecr_repository_policy.main", moduleName)

	_, err = aws.NewECRClientE(t, Region)
	assert.NoError(t, err)
}
