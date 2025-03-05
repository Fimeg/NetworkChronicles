# Network Chronicles: Code Cleanup TODO List

## Overview

This document outlines the key areas for code cleanup and streamlining in the Network Chronicles project, focusing on ensuring Tier 1 remains fully playable while improving code quality and maintainability.

## Completed Tasks

### 1. Consolidate Directory Creation Logic ✅
- **Issue**: The Documents directory creation is duplicated in multiple scripts
- **Solution**: Created `/bin/utils/directory-management.sh` with `ensure_player_documents` function
- **Status**: Implemented and applied to all scripts that create the Documents directory

### 2. Standardize Player Data Path ✅
- **Issue**: The player data path `/opt/network-chronicles/data/players/player` is hardcoded in multiple places
- **Solution**: Implemented centralized configuration in `/bin/utils/config.sh` with functions like `get_player_state_dir`
- **Status**: Applied to all core scripts

### 3. Normalize Shell Script Headers ✅
- **Issue**: Inconsistent headers, permissions, and execution settings across shell scripts
- **Solution**: Created script template in `/bin/utils/script-template.sh` and updated script headers
- **Status**: Applied to all refactored scripts

### 4. Address Duplicate Setup Logic ✅
- **Issue**: Similar setup logic is repeated in `setup-demo.sh`, `install.sh`, and other installation scripts
- **Solution**: Refactored installation scripts to use `ensure_game_directories` function
- **Status**: Applied to setup-demo.sh and manual-setup-enhanced.sh

### 5. Standardize JSON Operations ✅
- **Issue**: Inconsistent approaches to JSON manipulation with `jq`
- **Solution**: Created `/bin/utils/json-helpers.sh` with standardized functions
- **Status**: Applied to all core scripts that handle JSON data

## Remaining Tasks

### 1. Improve Error Handling
- **Issue**: Limited error handling in critical operations like file creation/modification
- **Solution**: Add robust error checking and reporting, especially for file system operations
- **Status**: Partially implemented in utility functions; needs to be expanded to all scripts

### 2. Standardize Logging
- **Issue**: Inconsistent logging across different scripts
- **Solution**: Create a standardized logging utility
- **Status**: Not yet implemented

### 3. Refactor Challenge Scripts
- **Issue**: Challenge scripts in content/challenges/ follow different patterns
- **Solution**: Update to use utility functions and consistent structure
- **Status**: Not yet refactored

### 4. Improve Documentation
- **Issue**: Limited inline documentation in some scripts
- **Solution**: Add comprehensive inline comments
- **Status**: Utility functions are documented; other scripts need improvement

### 5. Automated Testing
- **Issue**: No automated testing for utility functions or main functionality
- **Solution**: Create test scripts for utility functions
- **Status**: Not yet implemented

## Medium Priority Tasks

### 1. Reorganize Game Content Structure
- **Issue**: Content organization could be more intuitive, particularly for quests and narrative elements.
- **Solution**: Implement a more structured folder hierarchy for game content, with clear separation of data, narrative, and game mechanics.

### 2. Extract Common Functions
- **Issue**: Common functionality (e.g., JSON handling, notification display) is duplicated across scripts.
- **Solution**: Create a utility library for common functions that can be sourced by other scripts.

### 3. Improve Documentation
- **Issue**: Limited inline documentation for complex functions.
- **Solution**: Add comprehensive comments and documentation, particularly for game engine and shell integration functions.

### 4. Standardize JSON Handling
- **Issue**: Inconsistent approaches to JSON manipulation with `jq`.
- **Solution**: Create standardized functions for common JSON operations used throughout the codebase.

### 5. Consolidate Script Logic
- **Issue**: Multiple small scripts with overlapping functionality (e.g., `check-add-documents.sh`, `fix-documents.sh`, etc.).
- **Solution**: Consolidate these into more comprehensive scripts with clear responsibilities.

## Low Priority Tasks

### 1. Improve Visual Styling Consistency
- **Issue**: Inconsistent use of colors, formatting, and ASCII art across different UI components.
- **Solution**: Create a visual styling module that defines standard colors, borders, and text styling.

### 2. Optimize Command Processing
- **Issue**: The command interception and processing in shell integration could be more efficient.
- **Solution**: Refine the command processing logic to reduce overhead and improve terminal responsiveness.

### 3. Enhanced Player Profile Management
- **Issue**: Player profile data structure could be more flexible and extensible.
- **Solution**: Refactor player profile data model to be more modular and easier to extend with new features.

### 4. Refactor Challenge System
- **Issue**: Challenge creation and processing could be more streamlined.
- **Solution**: Implement a more structured challenge definition system with clearer trigger/reward mechanics.

### 5. Improve Installation UX
- **Issue**: Installation process requires multiple manual steps.
- **Solution**: Create a streamlined installation script with better user feedback and configuration options.

## Implementation Plan

### Phase 1: Consolidation
1. Create utility scripts for common operations
2. Consolidate directory creation logic
3. Standardize configuration and path management
4. Fix immediate duplication issues

### Phase 2: Modularization
1. Extract common functions into libraries
2. Refactor script organization
3. Standardize error handling
4. Improve JSON handling

### Phase 3: Enhancement
1. Improve documentation
2. Enhance visual styling
3. Optimize performance
4. Refine installation experience

## Tracking Progress

As tasks are completed, they should be updated here with completion dates and implementation notes. This will help maintain a clear picture of progress and ensure no tasks are overlooked during the refactoring process.