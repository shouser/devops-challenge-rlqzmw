package service

import (
	"fmt"
	"net/http"
	"strings"
)

type ConfigFile struct {
	ShopName string `yaml:"shopName"`
}

type Shop struct {
	Name string
}

func (s *Shop) Handler(w http.ResponseWriter, r *http.Request) {
	// Define the HTML content
	htmlTemplate := `
		<!DOCTYPE html>
		<html>
		<head>
			<title>$SHOPNAME</title>
			<style>
				body {
					font-family: Arial, sans-serif;
					line-height: 1.6;
					margin: 20px;
					background-color: #f4f4f9;
				}
				h1 {
					color: #333;
				}
				p {
					color: #666;
				}
			</style>
		</head>
		<body>
			<h1>$SHOPNAME</h1>
			<p>Welcome to $SHOPNAME! We have a wide selection of the finest products from around the world.</p>
			<p>Browse our collection and find the perfect product for any occasion.</p>
		</body>
		</html>
	`
	html := strings.Replace(htmlTemplate, "$SHOPNAME", s.Name, -1)

	// Write the HTML content as the response
	w.Header().Set("Content-Type", "text/html")
	fmt.Fprint(w, html)
}

func StartServer(cfg *ConfigFile) error {
	if len(cfg.ShopName) == 0 {
		cfg.ShopName = "UnsetShopName"
	}

	srv := &Shop{
		Name: cfg.ShopName,
	}
	// Route all requests to the shopfront
	http.HandleFunc("/", srv.Handler)

	// Start the server on port 80
	fmt.Println("Starting server on port 80...")
	err := http.ListenAndServe(":80", nil)
	return err
}
