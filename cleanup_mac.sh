#!/bin/bash

echo "🧹 Starting Mac Cleanup..."

# -----------------------------
# 1. User Cache
# -----------------------------
echo "Clearing user cache..."
rm -rf ~/Library/Caches/*

# -----------------------------
# 2. System Cache
# -----------------------------
echo "Clearing system cache..."
sudo rm -rf /Library/Caches/*

# -----------------------------
# 3. Logs
# -----------------------------
echo "Clearing logs..."
rm -rf ~/Library/Logs/*
sudo rm -rf /private/var/log/*

# -----------------------------
# 4. Go Cleanup
# -----------------------------
if command -v go &> /dev/null
then
  echo "Cleaning Go cache..."
  go clean -cache -modcache -i -r
fi

# -----------------------------
# 5. Maven Cleanup
# -----------------------------
if [ -d "$HOME/.m2/repository" ]; then
  echo "Cleaning Maven repo..."
  rm -rf ~/.m2/repository
fi

# -----------------------------
# 6. Gradle Cleanup
# -----------------------------
if [ -d "$HOME/.gradle/caches" ]; then
  echo "Cleaning Gradle cache..."
  rm -rf ~/.gradle/caches
fi

# -----------------------------
# 7. Node Cleanup
# -----------------------------
if command -v npm &> /dev/null
then
  echo "Cleaning npm cache..."
  npm cache clean --force
fi

# -----------------------------
# 8. Docker Cleanup
# -----------------------------
if command -v docker &> /dev/null
then
  echo "Cleaning Docker..."
  docker system prune -a -f
fi

# -----------------------------
# 9. Trash Cleanup
# -----------------------------
echo "Emptying Trash..."
rm -rf ~/.Trash/*

# -----------------------------
# DONE
# -----------------------------
echo "✅ Cleanup Completed!"
echo "💾 You should now have more free space 🚀"
