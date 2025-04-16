#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2025 Andreas Krüger

commit_hash=$(git rev-parse --verify HEAD)
if ! git verify-commit "$commit_hash" >/dev/null 2>&1; then
  echo "✘ Commit $commit_hash is not GPG-signed."
  echo "✓ Use: git commit -S -m 'your message'"
  exit 1
fi
