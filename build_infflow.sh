#!/bin/bash
# Build Infflow with automatic mozconfig fixing
cd /mnt/c/Users/prabh/OneDrive/Documents/GitHub/Infflow

echo "Starting Infflow build process..."

# Step 1: Let surfer generate the mozconfig (it will fail, but that's ok)
echo "Generating mozconfig..."
timeout 30s npx surfer build 2>/dev/null || true

# Step 2: Fix the generated mozconfig
if [ -f "engine/mozconfig" ]; then
    echo "Fixing mozconfig line endings..."
    sed -i 's/\r$//' engine/mozconfig
    
    # Validate syntax
    if bash -n engine/mozconfig; then
        echo "✓ Mozconfig syntax is valid"
    else
        echo "✗ ERROR: Mozconfig still has syntax errors"
        echo "Checking for issues..."
        bash -n engine/mozconfig 2>&1 | head -5
        exit 1
    fi
else
    echo "✗ ERROR: No mozconfig file generated"
    exit 1
fi

# Step 3: Run the actual build
echo "Starting build process..."
npx surfer build
