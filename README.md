# atlas_demo
This repository demonstrates how to manage database schemas using [Atlas](https://atlasgo.io/).

## Project Structure
- `.env`: Environment variables containing database connection strings.
- `retail_db/`: A demo retail database project.
    - `atlas.hcl`: Atlas configuration file defining environments (dev, uat, prod).
    - `*_schema.sql`: Desired state SQL files for each environment.
    - `migrations/`: Environment-specific versioned migrations.

## Setup Local Environment

### 1. Create a Docker Network
Atlas needs to communicate with your local database container.
```bash
docker network create db-network
```

### 2. Run a Local Postgres Instance
This container (`atlas_local`) is used as a "dev database" for Atlas to calculate migration diffs.
```bash
docker run --name atlas_local \
  --network db-network \
  -e POSTGRES_PASSWORD=pass \
  -p 5432:5432 \
  -d postgres:16
```

## Workflow Instructions

### 1. Change to the Project Folder
```bash
cd retail_db
```

### 2. Update the Schema
Edit `dev_schema.sql` to your desired state.

### 3. Generate a Migration (migrate diff)
Run this command to detect changes between your SQL file and the database, generating a new migration file:

```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" \
  -w /workspace/retail_db \
  arigaio/atlas migrate diff add_new_feature --env dev
```

### 4. Apply Migrations (migrate apply)
Apply the generated migrations to your database:

```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" \
  -w /workspace/retail_db \
  arigaio/atlas migrate apply --env dev
```

### 5. Inspect the Current Database
To dump the current database schema to a file:

```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" \
  -w /workspace/retail_db \
  arigaio/atlas schema inspect --env dev --format "{{ sql . }}" > current_schema.sql
```
