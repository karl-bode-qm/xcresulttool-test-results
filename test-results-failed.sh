#!/bin/bash
set -e

TEST_RESULTS_JSON="$1"
OUTPUT_MD="$2"

{
  echo -e "\n ---\n"
  echo -e "\n## Failed Tests"
} >> "$OUTPUT_MD"

jq -r '
  .testNodes[].children[] |
    .children[]? |
      select(.nodeType == "Test Suite") |
      {
        name: .name,
        failedTests: [.children[] | select(.result == "Failed") | .name]
      } |
      select(.failedTests | length > 0) |
      "\n### \(.name)\n" + (.failedTests | map("- \(.)") | join("\n"))
' "$TEST_RESULTS_JSON" >> "$OUTPUT_MD"
