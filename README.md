# MongoDB Service

A collection of scripts for managing MongoDB databases with Docker.

## Features

- 🐳 Docker-based MongoDB setup
- 🔄 Database backup and restore functionality
- 👤 User and database creation
- 🔐 Docker secrets management

## Quick Start

1. **Clone the repository**
   ```bash
   git clone git@github.com:darienmh/service-mongodb.git
   cd service-mongodb
   ```

2. **Set up environment**
   ```bash
   cp example.env .env
   # Edit .env with your configuration
   ```

3. **Start MongoDB**
   ```bash
   docker compose up -d
   ```

## Scripts

### Database Management
- `create-database.sh <username>` - Create a new database and user
- `backup-mongodb.sh <mongodb_uri>` - Create a backup of a database
- `restore-mongodb.sh <backup_dir> <mongodb_uri>` - Restore a database from backup

### Docker Swarm Management
- `create-secrects.sh` - Create Docker secrets for MongoDB credentials

## Docker Compose

### Development
```bash
docker compose up -d
```

### Production (with secrets)
```bash
docker stack deploy -c docker-compose-stack.yml mongodb
```

## Contributing

1. Follow conventional commit format
2. Use English for all code and documentation
3. Test your changes before committing
4. Update documentation as needed

## License

MIT License 