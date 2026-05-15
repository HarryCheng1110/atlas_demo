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
Edit `dev_schema.sql` (or `uat`/`prod`) to your desired state.

### 3. Generate a Migration (migrate diff)
Run this command to detect changes between your SQL file and the database, generating a new migration file:

**macOS / Linux:**
```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" \
  -w /workspace/retail_db \
  arigaio/atlas migrate diff add_feature_name --env dev
```

**Windows (CMD):**
```cmd
docker run --rm --network db-network ^
  -v %cd%\..:/workspace ^
  -w /workspace/retail_db ^
  arigaio/atlas migrate diff add_feature_name --env dev
```

### 4. Apply Migrations (migrate apply)
Apply the generated migrations to your database:

**macOS / Linux:**
```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" \
  -w /workspace/retail_db \
  arigaio/atlas migrate apply --env dev
```

**Windows (CMD):**
```cmd
docker run --rm --network db-network ^
  -v %cd%\..:/workspace ^
  -w /workspace/retail_db ^
  arigaio/atlas migrate apply --env dev
```

---

## Handling Manual Schema Changes

If a change was applied directly to the database without using Atlas, follow these steps to sync Atlas back up:

### 1. Inspect the Live Database
Dump the actual live DB schema to a temporary file:
```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" -w /workspace/retail_db arigaio/atlas \
  schema inspect --env dev --format "{{ sql . }}" > current_schema.sql
```

### 2. Create an Empty Migration File
```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" -w /workspace/retail_db arigaio/atlas \
  migrate new add_manual_change --env dev
```

### 3. Compare and Update
Run `schema diff` to see exactly what changed:
```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" -w /workspace/retail_db arigaio/atlas \
  schema diff \
  --from file://dev_schema.sql \
  --to file://current_schema.sql \
  --dev-url "postgres://postgres:pass@atlas_local:5432/postgres?sslmode=disable"
```
- Copy the output changes into your `dev_schema.sql`.
- Copy the same changes into the empty migration file created in Step 2.

### 4. Recalculate Hashes
Run `migrate hash` to update the `atlas.sum` file (see section below).

### 5. Synchronize Migration Version
Tell Atlas that the database is already at the latest version:
```bash
docker run --rm --network db-network \
  -v "$(pwd)/..:/workspace" -w /workspace/retail_db arigaio/atlas \
  migrate set --env dev
```

---

## Understanding `atlas migrate hash`

### What is it?
The `atlas migrate hash` command recalculates the integrity checksums for your migration directory. It updates the `atlas.sum` file.

### When to use it?
- **Manual Edits**: If you manually edit an existing migration SQL file (e.g., fixing a typo in a comment).
- **Manual Sync**: When following the "Manual Schema Changes" procedure above.
- **Merge Conflicts**: If two developers created migrations with the same version number or if `atlas.sum` has conflicts.

### Why is it important?
Atlas uses the `atlas.sum` file to ensure that migration files haven't been tampered with or accidentally changed after they were applied. If the file contents don't match the hash, Atlas will refuse to run to prevent database corruption or inconsistent states.
