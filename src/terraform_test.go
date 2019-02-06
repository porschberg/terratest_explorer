package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
  "github.com/gruntwork-io/terratest/modules/aws"
  "github.com/gruntwork-io/terratest/modules/ssh"
  //"github.com/gruntwork-io/terratest/modules/test-structure"
  "time"
  "fmt"
  "github.com/gruntwork-io/terratest/modules/retry"
  "strings"
  "github.com/gruntwork-io/terratest/modules/logger"
  "github.com/gruntwork-io/terratest/modules/http-helper"
  "regexp"
  "github.com/gruntwork-io/terratest/modules/test-structure"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformExplorer(t *testing.T) {
  t.Parallel()

  terraformOptions := &terraform.Options{
    // The path to where our Terraform code is located
    TerraformDir: "./terraform",
    NoColor: true,
  }

  test_structure.RunTestStage(t, "setup", func() {
    terraform.RunTerraformCommand(t, terraformOptions, "workspace", "select", "ws1" )
    workspaceList := terraform.RunTerraformCommand(t, terraformOptions, "workspace", "list")
    logger.Logf(t, "WORKSPACE_LIST: %s", workspaceList)
    terraform.InitAndApply(t, terraformOptions)
  })

  defer test_structure.RunTestStage(t, "teardown", func() {
    terraform.Destroy(t, terraformOptions)
  })

  test_structure.RunTestStage(t, "validate", func() {
    testIPLookup(t, terraformOptions)
    testSSHToPublicHost(t, terraformOptions)
    testHTTPGETRequest(t)
  })

  }

func testIPLookup(t *testing.T, terraformOptions *terraform.Options) {
  outputIP := terraform.Output(t, terraformOptions, "terratest_explorer_compute_public_ip")
  actualInstanceID := terraform.Output(t, terraformOptions, "terratest_explorer_compute_id")
  instanceIP := aws.GetPublicIpOfEc2Instance(t, actualInstanceID, "eu-central-1")
  assert.Equal(t, instanceIP, outputIP)
}

func testHTTPGETRequest(t *testing.T) {
  maxRetries := 30
  timeBetweenRetries := 5 * time.Second
  // Verify that we get back a 200 OK with the expected instanceText

  http_helper.HttpGetWithRetryWithCustomValidation(t, "https://ws1.terratestexplorer.beyondtouch.io/", maxRetries, timeBetweenRetries,
    func(statusCode int, body string) bool {
    matched, _ := regexp.MatchString(`this is a simple page for terratest explorer`, body)
    logger.Logf(t, "HTTP statusCode: %s", statusCode)
    logger.Logf(t, "HTTP Response-BODY: %s", body)
    return statusCode == 200 && matched
  })
}

func testSSHToPublicHost(t *testing.T, terraformOptions *terraform.Options) {
  backendIP := terraform.Output(t, terraformOptions, "terratest_explorer_compute_public_ip")
  sshKeypair, err := extractKeypair(t, terraformOptions)
  if err != nil {
    logger.Logf(t, "ERROR on extracting sshKeyPair: %s", err)
    t.Fatal(err)
  }
  testSSHToPublicHostInternal(t, sshKeypair, backendIP)
}

func testSSHToPublicHostInternal(t *testing.T, sshKeyPair *ssh.KeyPair, publicInstanceIP string) {
  // Run `terraform output` to get the value of an output variable
  // publicInstanceIP := terraform.Output(t, terraformOptions, "public_instance_ip")

  // We're going to try to SSH to the instance IP, using the Key Pair we created earlier, and the user "ubuntu",
  // as we know the Instance is running an Ubuntu AMI that has such a user
  publicHost := ssh.Host{
    Hostname:    publicInstanceIP,
    SshKeyPair:  sshKeyPair,
    SshUserName: "ec2-user",
  }

  // It can take a minute or so for the Instance to boot up, so retry a few times
  maxRetries := 30
  timeBetweenRetries := 5 * time.Second
  description := fmt.Sprintf("SSH to public host %s", publicInstanceIP)

  // Run a simple echo command on the server
  expectedText := "Hello Terratest!"
  command := fmt.Sprintf("echo -n '%s'", expectedText)

  // Verify that we can SSH to the Instance and run commands
  retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
    actualText, err := ssh.CheckSshCommandE(t, publicHost, command)

    if err != nil {
      return "", err
    }

    if strings.TrimSpace(actualText) != expectedText {
      return "", fmt.Errorf("expected SSH command to return '%s' but got '%s'", expectedText, actualText)
    }

    return "", nil
  })
}

// GenerateRSAKeyPairE generates an RSA Keypair and return the public and private keys.
func extractKeypair(t *testing.T, terraformOptions *terraform.Options) (*ssh.KeyPair, error) {
  publicKey := terraform.Output(t, terraformOptions, "terratest_explorer_public_key")
  privateKey := terraform.Output(t, terraformOptions, "terratest_explorer_private_key")
  return &ssh.KeyPair{ PublicKey: publicKey, PrivateKey: privateKey}, nil
}