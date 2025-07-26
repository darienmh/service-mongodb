#!/bin/bash

# Check arguments
if [ "$#" -ne 1 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: ./backup-mongodb.sh <mongodb_uri>"
    echo "Example: ./backup-mongodb.sh 'mongodb://user:password@host:port/database'"
    exit 1
fi

# MongoDB URI
MONGODB_URI=$1

# Extract database name from URI
DATABASE=$(echo $MONGODB_URI | sed -n 's/.*\/\([^?]*\).*/\1/p')

if [ -z "$DATABASE" ]; then
    echo "Error: Could not extract database name from URI"
    exit 1
fi

# Create backup directory if it doesn't exist
BACKUP_DIR="./mongodb-backup"
mkdir -p $BACKUP_DIR

# Date for backup name
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/backup_${DATABASE}_${DATE}"

echo "Starting backup of database '$DATABASE'..."

# Execute mongodump with URI
mongodump \
    --uri "$MONGODB_URI" \
    --out $BACKUP_PATH \
    --gzip

if [ $? -eq 0 ]; then
    echo "Backup completed successfully in $BACKUP_PATH"
else
    echo "Error during backup"
    exit 1
fi 