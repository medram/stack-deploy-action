#!/bin/bash

# Add Summary
markdown_summary="# 🚀 Deployment Summary"

markdown_summary+="
| Key             | Value                                 |
|-----------------|---------------------------------------|
| **Stack Name**  | \`${{ inputs.stack_name }}\`          |
| **Stack File**  | \`${{ inputs.stack_file }}\`          |
| **Deployed At** | $(date -u +"%Y-%m-%dT%H:%M:%SZ")      |
"
echo -e "$markdown_summary" >> "${GITHUB_STEP_SUMMARY}" || echo "::error::Failed to Write Job Summary!"