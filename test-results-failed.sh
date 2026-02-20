#!/bin/bash
set -e

TEST_RESULTS_JSON="$1"
OUTPUT_MD="$2"

# Check if there are any failed tests
FAILED_TESTS_COUNT=$(jq '[
  .testNodes[].children[] |
    .children[]? |
      select(.nodeType == "Test Suite") |
      {
        failedTests: [.children[] | select(.result == "Failed") | .name]
      } |
      select(.failedTests | length > 0) |
      .failedTests[]
] | length' "$TEST_RESULTS_JSON")

if [ "$FAILED_TESTS_COUNT" -eq 0 ]; then
  # No failed tests to report
  exit 0
fi

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
