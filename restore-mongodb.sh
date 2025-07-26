#!/bin/bash

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: ./restore-mongodb.sh <backup_directory> <mongodb_uri>"
    echo "Example: ./restore-mongodb.sh ./mongodb-backup/backup_midb_20240321_123456 'mongodb://user:password@host:port/target_database'"
    exit 1
fi

# Parameters
BACKUP_DIR=$1
MONGODB_URI=$2

# Check if directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Directory $BACKUP_DIR does not exist"
    exit 1
fi

# Detect source database (looking for the single directory in the backup)
SOURCE_DATABASE=$(ls "$BACKUP_DIR" | head -n 1)

if [ -z "$SOURCE_DATABASE" ]; then
    echo "Error: No database found in backup directory"
    exit 1
fi

# Extract target database name from URI
TARGET_DATABASE=$(echo $MONGODB_URI | sed -n 's/.*\/\([^?]*\).*/\1/p')

if [ -z "$TARGET_DATABASE" ]; then
    echo "Error: Could not extract database name from destination URI"
    exit 1
fi

echo "Starting restoration..."
echo "Source database: $SOURCE_DATABASE"
echo "Target database: $TARGET_DATABASE"

# Execute mongorestore with URI
mongorestore \
    --uri "$MONGODB_URI" \
    --gzip \
    --drop \
    --nsFrom="$SOURCE_DATABASE.*" \
    --nsTo="$TARGET_DATABASE.*" \
    "$BACKUP_DIR/$SOURCE_DATABASE"

if [ $? -eq 0 ]; then
    echo "Restoration completed successfully"
else
    echo "Error during restoration"
    exit 1
fi 