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
	SMTP_SERVER = "smtp.gmail.com"
	SMTP_PORT   = "587"
	SMTP_USER   = "abc@gmail.com" // sender email
	SMTP_PASS   = "password"             // password
	TO_EMAIL    = "abc@gmail.com"	//receiver email
)

// PostgreSQL connection details
const (
	DB_USER     = "user" //postgres-user
	DB_PASSWORD = "password" //password
	DB_NAME     = "dbname" //database-name
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

// LockStats holds information about locks in the system
type LockStats struct {
	LockType   string `json:"lock_type"`
	BlockedBy  int    `json:"blocked_by"`
	BlockedFor string `json:"blocked_for"`
}

// HealthCheck represents overall health of the database
type HealthCheck struct {
	DatabaseSizes   []DatabaseStats `json:"database_sizes"`
	TableStats      []TableStats    `json:"table_stats"`
	QueryStats      []QueryStats    `json:"query_stats"`
	PostgresVersion string          `json:"postgres_version"`
	ActiveConnCount int             `json:"active_connections"`
	IndexBloat      float64         `json:"index_bloat"`
	DiskUsage       string          `json:"disk_usage"`
	LockStats       []LockStats     `json:"lock_stats"`
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

// getPostgresVersion fetches the PostgreSQL version
func getPostgresVersion(db *sql.DB) (string, error) {
	var version string
	err := db.QueryRow("SELECT version()").Scan(&version)
	if err != nil {
		return "", fmt.Errorf("error getting PostgreSQL version: %v", err)
	}
	return version, nil
}

// getActiveConnections fetches the count of active connections
func getActiveConnections(db *sql.DB) (int, error) {
	var count int
	err := db.QueryRow("SELECT count(*) FROM pg_stat_activity WHERE state = 'active'").Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("error getting active connections: %v", err)
	}
	return count, nil
}

// getIndexBloat fetches the index bloat percentage
func getIndexBloat(db *sql.DB) (float64, error) {
	var bloat float64
	err := db.QueryRow(`
		SELECT round(100 * sum(pg_column_size(indexrelid)) / sum(pg_table_size(indexrelid))) 
		FROM pg_stat_user_indexes`).Scan(&bloat)
	if err != nil {
		return 0, fmt.Errorf("error getting index bloat: %v", err)
	}
	return bloat, nil
}

// getDiskUsage fetches the disk usage of PostgreSQL
func getDiskUsage(db *sql.DB) (string, error) {
	var usage string
	err := db.QueryRow(`SELECT pg_size_pretty(pg_tablespace_size('pg_default'))`).Scan(&usage)
	if err != nil {
		return "", fmt.Errorf("error getting disk usage: %v", err)
	}
	return usage, nil
}

// getLockStats fetches lock-related information
func getLockStats(db *sql.DB) ([]LockStats, error) {
	rows, err := db.Query(`
		SELECT locktype, blocked_by, blocked_for
		FROM pg_locks 
		WHERE granted = false`)
	if err != nil {
		return nil, fmt.Errorf("error getting lock stats: %v", err)
	}
	defer rows.Close()

	var stats []LockStats
	for rows.Next() {
		var lockType string
		var blockedBy int
		var blockedFor string
		if err := rows.Scan(&lockType, &blockedBy, &blockedFor); err != nil {
			return nil, err
		}
		stats = append(stats, LockStats{LockType: lockType, BlockedBy: blockedBy, BlockedFor: blockedFor})
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

	// Get PostgreSQL version
	postgresVersion, err := getPostgresVersion(db)
	if err != nil {
		log.Println(err)
	}

	// Get active connection count
	activeConnCount, err := getActiveConnections(db)
	if err != nil {
		log.Println(err)
	}

	// Get index bloat percentage
	indexBloat, err := getIndexBloat(db)
	if err != nil {
		log.Println(err)
	}

	// Get disk usage
	diskUsage, err := getDiskUsage(db)
	if err != nil {
		log.Println(err)
	}

	// Get lock stats
	lockStats, err := getLockStats(db)
	if err != nil {
		log.Println(err)
	}

	// Generate health report
	report := HealthCheck{
		DatabaseSizes:   dbSizes,
		TableStats:      tableSizes,
		QueryStats:      queryStats,
		PostgresVersion: postgresVersion,
		ActiveConnCount: activeConnCount,
		IndexBloat:      indexBloat,
		DiskUsage:       diskUsage,
		LockStats:       lockStats,
	}

	// Send email
	if err := sendEmail(report); err != nil {
		log.Println(err)
	}
}
