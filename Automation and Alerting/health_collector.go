package collector

import (
	"database/sql"
	"log"
	"os/exec"
	"strconv"
	"strings"
	"sync"

	"github.com/prometheus/client_golang/prometheus"
)

type PostgresMetricsCollector struct {
	DB             *sql.DB
	CPUUsageMetric prometheus.Gauge
	ReplicationLag prometheus.Gauge
	SlowQueryTime  prometheus.Gauge
	mutex          sync.Mutex
}

func NewPostgresMetricsCollector(db *sql.DB) *PostgresMetricsCollector {
	return &PostgresMetricsCollector{
		DB: db,
		CPUUsageMetric: prometheus.NewGauge(
			prometheus.GaugeOpts{
				Namespace: "pg",
				Name:      "cpu_usage_percentage",
				Help:      "Actual CPU usage of PostgreSQL process",
			},
		),
		ReplicationLag: prometheus.NewGauge(
			prometheus.GaugeOpts{
				Namespace: "pg",
				Name:      "replication_lag_seconds",
				Help:      "Replication lag in seconds",
			},
		),
		SlowQueryTime: prometheus.NewGauge(
			prometheus.GaugeOpts{
				Namespace: "pg",
				Name:      "slow_query_time_seconds",
				Help:      "Execution time of the slowest query in the last period",
			},
		),
	}
}

func (c *PostgresMetricsCollector) Describe(ch chan<- *prometheus.Desc) {
	c.CPUUsageMetric.Describe(ch)
	c.ReplicationLag.Describe(ch)
	c.SlowQueryTime.Describe(ch)
}

func (c *PostgresMetricsCollector) Collect(ch chan<- prometheus.Metric) {
	c.mutex.Lock()
	defer c.mutex.Unlock()

	// --- Fetch PostgreSQL CPU Usage ---
	out, err := exec.Command("sh", "-c", "ps -C postgres -o %cpu= | awk '{s+=$1} END {print s}'").Output()
	if err != nil {
		log.Printf("Error fetching PostgreSQL CPU usage: %v", err)
		return
	}

	cpuUsageStr := strings.TrimSpace(string(out))
	cpuUsage, err := strconv.ParseFloat(cpuUsageStr, 64)
	if err != nil {
		log.Printf("Error converting CPU usage to float: %v", err)
		return
	}

	c.CPUUsageMetric.Set(cpuUsage)
	ch <- c.CPUUsageMetric

	if cpuUsage > 70 { // Adjust threshold as needed
		log.Printf("ALERT: PostgreSQL CPU usage is high! Current: %.2f%%", cpuUsage)
	}

	// Fetch Replication Lag
	var replicationLag sql.NullFloat64
	err = c.DB.QueryRow(`
    SELECT EXTRACT(EPOCH FROM now() - pg_last_xact_replay_timestamp()) AS lag_seconds;
`).Scan(&replicationLag)

	if err != nil {
		log.Printf("Error fetching replication lag: %v", err)
		replicationLag = sql.NullFloat64{Valid: false} // Mark it as invalid to avoid using a null value
	}

	// If the result is not NULL, update the ReplicationLag metric
	if replicationLag.Valid {
		c.ReplicationLag.Set(replicationLag.Float64)
		ch <- c.ReplicationLag
		if replicationLag.Float64 > 10 { // Adjust threshold as needed
			log.Printf("ALERT: Replication lag is high! Current: %.2f seconds", replicationLag.Float64)
		}
	} else {
		log.Println("No replication lag data available (NULL value).")
	}

	// --- Fetch Slowest Query Execution Time ---
	var slowestQueryTime float64
	err = c.DB.QueryRow(`
		SELECT max(total_exec_time / calls) FROM pg_stat_statements;
	`).Scan(&slowestQueryTime)

	if err != nil {
		log.Printf("Error fetching slow query time: %v", err)
		slowestQueryTime = -1 // Indicate error
	}

	c.SlowQueryTime.Set(slowestQueryTime / 1000.0)
	ch <- c.SlowQueryTime

	if slowestQueryTime/1000.0 > 3.0 { // Threshold for slow queries (3 seconds)
		log.Printf("ALERT: Slow query detected! Max execution time: %.2f seconds", slowestQueryTime/1000.0)
	}
}
