#!/bin/bash
# Warm up the fingerprint reader to bypass the first-poll error
# We send a dummy request and immediately kill it or let it fail
timeout 0.5s fprintd-verify > /dev/null 2>&1

