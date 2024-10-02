package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type InfisicalConfig struct {
	SecretPath  string `json:"secretPath"`
	WorkspaceID string `json:"workspaceId"`
}

func main() {
	// Set default values
	infisicalPaths := []string{"/"}
	var infisicalProjectID string

	// Check for .infisical.json
	if _, err := os.Stat(".infisical.json"); err == nil {
		config, err := readInfisicalConfig(".infisical.json")
		if err != nil {
			fmt.Println("Error reading .infisical.json:", err)
			os.Exit(1)
		}

		if config.SecretPath != "" {
			infisicalPaths = strings.Split(config.SecretPath, ",")
		}
		if config.WorkspaceID != "" {
			infisicalProjectID = config.WorkspaceID
		}
	}

	// Override with environment variables if set
	if envPath := os.Getenv("INFISICAL_PATH"); envPath != "" {
		infisicalPaths = strings.Split(envPath, ",")
	}
	if envProjectID := os.Getenv("INFISICAL_PROJECT_ID"); envProjectID != "" {
		infisicalProjectID = envProjectID
	}

	if infisicalProjectID == "" {
		fmt.Println("PROJECT_ID needs to be set in the workflow or in .infisical.json (with \"workspaceId\")")
		os.Exit(1)
	}

	// Login and get Infisical token
	clientID := os.Getenv("INFISICAL_CLIENT_ID")
	clientSecret := os.Getenv("INFISICAL_CLIENT_SECRET")
	token, err := getInfisicalToken(clientID, clientSecret)
	if err != nil {
		fmt.Println("Error getting Infisical token:", err)
		os.Exit(1)
	}
	os.Setenv("INFISICAL_TOKEN", token)

	fmt.Println("Got token")

	// Export environment variables
	infisicalEnv := os.Getenv("INFISICAL_ENV")
	err = exportEnvVariables(infisicalProjectID, infisicalPaths, infisicalEnv)
	if err != nil {
		fmt.Println("Error exporting environment variables:", err)
		os.Exit(1)
	}

	fmt.Println("Environment variables exported to env.json")
}

func readInfisicalConfig(filename string) (InfisicalConfig, error) {
	var config InfisicalConfig
	data, err := os.ReadFile(filename)
	if err != nil {
		return config, err
	}
	err = json.Unmarshal(data, &config)
	return config, err
}

func getInfisicalToken(clientID, clientSecret string) (string, error) {
	cmd := exec.Command("./infisical", "login", "--method=universal-auth",
		"--client-id="+clientID, "--client-secret="+clientSecret, "--silent", "--plain")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(output)), nil
}

func exportEnvVariables(projectID string, paths []string, env string) error {
	envSlice := []any{}
	for _, path := range paths {
		args := []string{"export", "--projectId", projectID, "--path", path, "--format", "json"}
		if env != "" {
			args = append(args, "--env", env)
		}

		cmd := exec.Command("./infisical", args...)
		output, err := cmd.Output()
		if err != nil {
			return err
		}

		var envSlice0 []any
		err = json.Unmarshal(output, &envSlice0)
		if err != nil {
			return err
		}

		envSlice = append(envSlice, envSlice0...)
	}

	data, err := json.Marshal(envSlice)
	if err != nil {
		return err
	}

	err = os.WriteFile("env.json", data, 0644)
	if err != nil {
		return err
	}
	return nil
}
