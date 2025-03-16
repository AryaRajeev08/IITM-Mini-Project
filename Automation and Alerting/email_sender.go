package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/smtp"

	_ "github.com/lib/pq"
)

// Email configuration
const (
	SMTP_SERVER = "smtp.gmail.com" // Replace with your SMTP server
	SMTP_PORT   = "587"
	SMTP_USER   = "email@gmail.com"
	SMTP_PASS   = "your-password"
	TO_EMAIL    = "email@gmail.com"
)

// PostgreSQL connection details
const (
	DB_USER     = "user"
	DB_PASSWORD = "password"
	DB_NAME     = "DBname"
	DB_HOST     = "localhost"
	DB_PORT     = "5432"
)

// DatabaseStats holds PostgreSQL statistics
type DatabaseStats struct {
	DatabaseName string  `json:"database_name"`
	SizeBytes    float64 `json:"size_bytes"`
}

// TableStats holds table size information
type TableStats struct {
	TableName string  `json:"table_name"`
	SizeBytes float64 `json:"size_bytes"`
}

// QueryStats holds query execution details
type QueryStats struct {
	Query         string  `json:"query"`
	TotalExecTime float64 `json:"total_exec_time"`
	Calls         int     `json:"calls"`
}

// HealthCheck represents overall health of the database
type HealthCheck struct {
	DatabaseSizes []DatabaseStats `json:"database_sizes"`
	TableStats    []TableStats    `json:"table_stats"`
	QueryStats    []QueryStats    `json:"query_stats"`
}

// getDatabaseSizes fetches the size of each database
func getDatabaseSizes(db *sql.DB) ([]DatabaseStats, error) {
	rows, err := db.Query("SELECT datname, pg_database_size(datname) FROM pg_database")
	if err != nil {
		return nil, fmt.Errorf("error getting database sizes: %v", err)
	}
	defer rows.Close()

	var stats []DatabaseStats
	for rows.Next() {
		var dbName string
		var size float64
		if err := rows.Scan(&dbName, &size); err != nil {
			return nil, err
		}
		stats = append(stats, DatabaseStats{DatabaseName: dbName, SizeBytes: size})
	}
	return stats, nil
}

// getTableSizes fetches the size of each table
func getTableSizes(db *sql.DB) ([]TableStats, error) {
	rows, err := db.Query("SELECT relname, pg_total_relation_size(relname::text) FROM pg_class WHERE relkind = 'r'")
	if err != nil {
		return nil, fmt.Errorf("error getting table sizes: %v", err)
	}
	defer rows.Close()

	var stats []TableStats
	for rows.Next() {
		var tableName string
		var size float64
		if err := rows.Scan(&tableName, &size); err != nil {
			return nil, err
		}
		stats = append(stats, TableStats{TableName: tableName, SizeBytes: size})
	}
	return stats, nil
}

// getQueryStats fetches query execution times (requires pg_stat_statements extension)
func getQueryStats(db *sql.DB) ([]QueryStats, error) {
	rows, err := db.Query("SELECT query, total_exec_time, calls FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 5")
	if err != nil {
		return nil, fmt.Errorf("error getting query execution times: %v", err)
	}
	defer rows.Close()

	var stats []QueryStats
	for rows.Next() {
		var query string
		var execTime float64
		var calls int
		if err := rows.Scan(&query, &execTime, &calls); err != nil {
			return nil, err
		}
		stats = append(stats, QueryStats{Query: query, TotalExecTime: execTime, Calls: calls})
	}
	return stats, nil
}

// sendEmail sends an email with the health report
func sendEmail(report HealthCheck) error {
	// Convert report to JSON
	jsonData, err := json.MarshalIndent(report, "", "  ")
	if err != nil {
		return err
	}

	// Email body
	subject := "PostgreSQL Health Report"
	body := fmt.Sprintf("Subject: %s\n\n%s", subject, string(jsonData))

	// SMTP authentication
	auth := smtp.PlainAuth("", SMTP_USER, SMTP_PASS, SMTP_SERVER)

	// Send email
	err = smtp.SendMail(SMTP_SERVER+":"+SMTP_PORT, auth, SMTP_USER, []string{TO_EMAIL}, []byte(body))
	if err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}

	log.Println("Email sent successfully!")
	return nil
}

func main() {
	// Connect to PostgreSQL
	dbConnStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME)
	db, err := sql.Open("postgres", dbConnStr)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Get database sizes
	dbSizes, err := getDatabaseSizes(db)
	if err != nil {
		log.Println(err)
	}

	// Get table sizes
	tableSizes, err := getTableSizes(db)
	if err != nil {
		log.Println(err)
	}

	// Get query execution times
	queryStats, err := getQueryStats(db)
	if err != nil {
		log.Println(err)
	}

	// Generate health report
	report := HealthCheck{
		DatabaseSizes: dbSizes,
		TableStats:    tableSizes,
		QueryStats:    queryStats,
	}

	// Send email
	if err := sendEmail(report); err != nil {
		log.Println(err)
	}
}
