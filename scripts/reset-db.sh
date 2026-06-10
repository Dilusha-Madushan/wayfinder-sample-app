#!/bin/bash
# Resets the Wayfinder SQLite database by deleting it and re-running seed.js.
# Run from anywhere — script resolves paths relative to itself.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")/backend"
DB_PATH="${SQLITE_DB_PATH:-$BACKEND_DIR/wayfinder.sqlite}"

for f in "$DB_PATH" "${DB_PATH}-shm" "${DB_PATH}-wal"; do
  if [ -f "$f" ]; then
    rm "$f"
    echo "Deleted $f"
  fi
done

echo "Re-seeding database..."
node "$BACKEND_DIR/scripts/seed.js"
echo "Database reset complete."
