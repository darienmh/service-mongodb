#!/bin/bash

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -ne 1 ]; then
    echo "${RED}Error: Incorrect number of arguments${NC}"
    echo "Usage: ./create-database.sh <username>"
    echo "Example: ./create-database.sh john"
    echo "This will create the database: john_db"
    exit 1
fi

# Parameters
USER_NAME=$1
DATABASE_NAME="${USER_NAME}_db"

# Load variables from .env file if it exists
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "${GREEN}Environment variables loaded from .env${NC}"
fi

# Set default credentials if not in .env
MONGO_USERNAME=${MONGO_INITDB_ROOT_USERNAME:-admin}
MONGO_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD:-P4ssw0rdS3cur3}
MONGO_HOST=${EXTRA_HOSTS:-localhost}
MONGO_PORT=${EXTERNAL_PORT:-27017}

# Build connection URI
MONGODB_URI="mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}"

echo "${BLUE}Creating database: ${DATABASE_NAME}${NC}"
echo "${YELLOW}Connecting to MongoDB at: ${MONGO_HOST}:${MONGO_PORT}${NC}"

# Check if MongoDB is running
if ! docker ps | grep -q "mongodb"; then
    echo "${YELLOW}MongoDB is not running. Starting container...${NC}"
    docker compose up -d mongodb
    
    # Wait for MongoDB to be ready
    echo "${YELLOW}Waiting for MongoDB to be ready...${NC}"
    sleep 10
fi

# Create database using mongosh
echo "${BLUE}Executing command to create database and user...${NC}"

# Generate random password in bash (style: Caaskr68bqsyeFUujH1jqD8irZBLKM)
USER_PASSWORD=$(openssl rand -base64 30 | tr -dc 'a-zA-Z0-9' | head -c 30)

# Create database and user
mongosh "$MONGODB_URI" --eval "
  // Create the database
  db = db.getSiblingDB('${DATABASE_NAME}');
  
  // Create an initial collection to activate the database
  db.createCollection('users');
  
  // Create user for the database
  db.createUser({
    user: '${USER_NAME}',
    pwd: '${USER_PASSWORD}',
    roles: ['readWrite', 'read']
  });
  
  // Insert a test document
  db.users.insertOne({
    username: '${USER_NAME}',
    created_at: new Date(),
    database: '${DATABASE_NAME}',
    user_created: true
  });
  
  print('Database ${DATABASE_NAME} created successfully');
  print('User ${USER_NAME} created with readWrite and read permissions');
  print('Users collection created with test document');
"
if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Database '${DATABASE_NAME}' created successfully${NC}"
    echo "${GREEN}✅ User '${USER_NAME}' created with readWrite and read permissions${NC}"
    echo "${BLUE}🔑 User password: ${USER_PASSWORD}${NC}"
    echo "${BLUE}📊 Complete connection URI:${NC}"
    echo "   mongodb://${USER_NAME}:${USER_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${DATABASE_NAME}"
else
    echo "${RED}❌ Error creating database${NC}"
    exit 1
fi

# Show additional information
echo "\n${BLUE}📋 Database information:${NC}"
echo "   Name: ${DATABASE_NAME}"
echo "   Owner user: ${USER_NAME}"
echo "   Host: ${MONGO_HOST}"
echo "   Port: ${MONGO_PORT}"
echo "   MongoDB user: ${MONGO_USERNAME}"
echo "   Connection: mongodb://${USER_NAME}:${USER_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${DATABASE_NAME}"