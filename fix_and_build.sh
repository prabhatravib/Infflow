#!/bin/bash
# Fix line endings and build Infflow
cd /mnt/c/Users/prabh/OneDrive/Documents/GitHub/Infflow

# Run surfer build (this will generate mozconfig)
echo "Generating mozconfig..."
npx surfer build --dry-run 2>/dev/null || true

# Fix line endings in mozconfig after generation
if [ -f "engine/mozconfig" ]; then
    sed -i 's/\r$//' engine/mozconfig
    echo "Fixed line endings in mozconfig"
    
    # Validate syntax
    if bash -n engine/mozconfig; then
        echo "Mozconfig syntax is valid"
    else
        echo "ERROR: Mozconfig still has syntax errors"
        exit 1
    fi
fi

# Run the actual build
echo "Starting build..."
npx surfer build
