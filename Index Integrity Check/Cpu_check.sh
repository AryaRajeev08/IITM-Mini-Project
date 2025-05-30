#Contributed by ARYA RAJEEV

#!/bin/bash

# Set variables
DB_NAME="mydb"
TABLE_NAME="country"
CPU_LOG="/home/alan/Mini Project/Index Integrity Check/cpulog.log"

# Change to a safe directory
#cd //home/alan/Mini Project/Index Integrity Check

# Start CPU monitoring in the background
echo "Starting CPU monitoring..."
mpstat 1 > "$CPU_LOG" &
MPSTAT_PID=$!
echo "CPU monitoring started with PID $MPSTAT_PID"

# Wait for a second to ensure mpstat starts logging
sleep 1

# Run the PostgreSQL function
echo "Running check_and_reindex on table: $TABLE_NAME"
psql -U postgres -d "$DB_NAME" -c "SELECT check_and_reindex('$TABLE_NAME');"

# Stop CPU monitoring
echo "Stopping CPU monitoring..."
kill $MPSTAT_PID
wait $MPSTAT_PID 2>/dev/null

# Show CPU usage log
echo "CPU usage during operation:"
cat "$CPU_LOG"

# Show the corruption log from PostgreSQL
echo "Fetching corruption log from database..."
psql -U postgres -d "$DB_NAME" -c "SELECT * FROM corruption_log;"

echo "Process completed."


#!/bin/bash

# Set variables
DB_NAME="world"
TABLES=("city" "country" "countrylanguage")
CPU_LOG="/tmp/cpu_usage.log"

# Change to a safe directory
cd /tmp

# Start CPU monitoring in the background
echo "Starting CPU monitoring..."
mpstat 1 > "$CPU_LOG" &
MPSTAT_PID=$!
echo "CPU monitoring started with PID $MPSTAT_PID"

# Wait for a second to ensure mpstat starts logging
sleep 1

# Run the PostgreSQL function for each table
for TABLE_NAME in "${TABLES[@]}"; do
    echo "Running check_and_reindex on table: $TABLE_NAME"
    psql -U postgres -d "$DB_NAME" -c "SELECT check_and_reindex('$TABLE_NAME');"
done

# Stop CPU monitoring
echo "Stopping CPU monitoring..."
kill $MPSTAT_PID
wait $MPSTAT_PID 2>/dev/null

# Show CPU usage log
echo "CPU usage during operation:"
cat "$CPU_LOG"

# Show the corruption log from PostgreSQL
echo "Fetching corruption log from database..."
psql -U postgres -d "$DB_NAME" -c "SELECT * FROM corruption_log;"

echo "Process completed."
