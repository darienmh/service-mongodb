#!/bin/sh

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "${GREEN}Environment variables loaded from .env${NC}"
else
    echo "${RED}Error: .env file not found${NC}"
    exit 1
fi

# Function to create a secret
create_secret() {
    local secret_name=$1
    local secret_value=$2
    
    # Check if secret already exists
    if docker secret ls | grep -q "$secret_name"; then
        echo "${YELLOW}Secret $secret_name already exists. Removing...${NC}"
        docker secret rm "$secret_name"
    fi
    
    # Create the secret
    echo "$secret_value" | docker secret create "$secret_name" - > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "${GREEN}Secret $secret_name created successfully${NC}"
    else
        echo "${RED}Error creating secret $secret_name${NC}"
        exit 1
    fi
}

# Create secrets
echo "Creating secrets for MongoDB..."
create_secret "MONGO_INITDB_ROOT_USERNAME" "$MONGO_INITDB_ROOT_USERNAME"
create_secret "MONGO_INITDB_ROOT_PASSWORD" "$MONGO_INITDB_ROOT_PASSWORD"

echo "\n${GREEN}Verifying created secrets:${NC}"
docker secret ls | grep -E "MONGO_INITDB_ROOT_USERNAME|MONGO_INITDB_ROOT_PASSWORD"

echo "\n${GREEN}Process completed!${NC}"
