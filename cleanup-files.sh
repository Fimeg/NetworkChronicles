#!/bin/bash
# Cleanup script for Network Chronicles
# This will rename unused files with .old extension

# List of files to mark as old
echo "Marking unused files with .old extension..."

# Helper scripts we created as workarounds
if [ -f "bin/nc-discover-network.sh" ]; then
  echo "Marking bin/nc-discover-network.sh as old"
  mv "bin/nc-discover-network.sh" "bin/nc-discover-network.sh.old"
fi

if [ -f "bin/nc-test-commands.sh" ]; then
  echo "Marking bin/nc-test-commands.sh as old"
  mv "bin/nc-test-commands.sh" "bin/nc-test-commands.sh.old"
fi

if [ -f "bin/nc-add-network-discoveries.sh" ]; then
  echo "Marking bin/nc-add-network-discoveries.sh as old"
  mv "bin/nc-add-network-discoveries.sh" "bin/nc-add-network-discoveries.sh.old"
fi

# Manual setup scripts
if [ -f "manual-setup.sh" ]; then
  echo "Marking manual-setup.sh as old"
  mv "manual-setup.sh" "manual-setup.sh.old"
fi

if [ -f "manual-setup-enhanced.sh" ]; then
  echo "Marking manual-setup-enhanced.sh as old"
  mv "manual-setup-enhanced.sh" "manual-setup-enhanced.sh.old"
fi

echo "Clean-up complete!"
echo "You can now run these files manually if needed:"
echo "  chmod +x cleanup-files.sh"
echo "  ./cleanup-files.sh"
echo
echo "Or you can safely delete files with .old extension if they are no longer needed."