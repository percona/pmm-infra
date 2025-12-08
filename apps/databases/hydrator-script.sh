#!/bin/sh

# Exit on error
set -e

# Read the generator's output from stdin
input=$(cat)

# Find the kustomization.yaml in the app's source directory and extract commonLabels.
# The ARGOCD_APP_SOURCE_PATH env var is provided by Argo CD.
kustomization_path="$ARGOCD_APP_SOURCE_PATH/../../kustomization.yaml"

# Use yq to extract commonLabels as JSON. If it's empty, default to an empty JSON object.
labels_json=$(yq e '.commonLabels' -o=json "$kustomization_path" | jq 'select(. != null) // {}')

# Use jq to merge the extracted labels into each generated element.
echo "$input" | jq --argjson labels "$labels_json" \
  '.elements[] |= . + { "commonLabels": $labels }'
