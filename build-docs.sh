#!/bin/bash

echo "🚀 Building CDC Documentation..."

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

# Build documentation
echo "🔨 Building MkDocs site..."
mkdocs build

# Serve locally (optional)
if [ "$1" = "serve" ]; then
    echo "🌐 Starting local server..."
    mkdocs serve
fi

echo "✅ Documentation build complete!"
echo "📁 Site generated in: site/"