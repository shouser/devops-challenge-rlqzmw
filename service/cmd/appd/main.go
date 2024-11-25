package main

import (
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli/v2"
	"gopkg.in/yaml.v3"
	"service"
)

func main() {
	// Create a new CLI app
	app := &cli.App{
		Name:  "Appd",
		Usage: "A demo application",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "config",
				Aliases: []string{"c"},
				Usage:   "Path to the configuration file",
				Value:   "/etc/appd/config.yaml",
				EnvVars: []string{"APPD_CONFIG"},
			},
		},
		Action: func(c *cli.Context) error {
			configFile := c.String("config")
			fmt.Printf("Using configuration file: %s\n", configFile)

			configBytes, err := os.ReadFile(configFile)
			if err != nil {
				fmt.Printf("unable to read config file %q: %v", configFile, err)
				os.Exit(1)
			}
			cfg := &service.ConfigFile{}
			err = yaml.Unmarshal(configBytes, &cfg)
			if err != nil {
				fmt.Printf("unable to parse config yaml: %v", err)
				os.Exit(1)
			}

			return service.StartServer(cfg)
		},
	}

	// Run the app
	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}
