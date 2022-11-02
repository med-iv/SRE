#!/bin/bash

TEXTFILE_DIRECTORY=/opt/prometheus_exporters/textfile

#echo 'SELECT table_schema "DB Name", ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" FROM information_schema.tables WHERE table_schema="oncall"  GROUP BY table_schema;' | mysql -u root -p1234
DATA=$(echo 'SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) FROM information_schema.tables WHERE table_schema="oncall"  GROUP BY table_schema;' | mysql -N -u root -p1234)
cat << EOF > "$TEXTFILE_DIRECTORY/oncall_db_size.prom"
oncall_db_size $DATA
EOF