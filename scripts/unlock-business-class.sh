#!/bin/bash
# Demo script: makes all Business class flights available and triggers upgrade processing.
# By default, Business class flights require CIBA async approval (available = 0).

BACKEND_URL="${WAYFINDER_BACKEND_URL:-http://localhost:8787}"
AGENT_URL="${WAYFINDER_AGENT_URL:-http://localhost:8790}"

echo "Unlocking Business class flights..."
curl -s -X POST "${BACKEND_URL}/api/demo/unlock-business-class" \
  -H "Content-Type: application/json" | jq .

#Demo purpose only: trigger upgrade processing immediately after unlocking Business class flights. In a real-world scenario, this would typically be triggered by user actions or scheduled tasks.
curl -s -X POST "${AGENT_URL}/api/demo/process-upgrades" \
  -H "Content-Type: application/json" | jq .


