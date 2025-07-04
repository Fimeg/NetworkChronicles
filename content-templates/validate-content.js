#!/usr/bin/env node
/**
 * Network Chronicles 2.0 - Content Validation Script
 * Validates quest and discovery JSON files for proper format and content
 */

import fs from 'fs'
import path from 'path'

const COLORS = {
  green: '\033[0;32m',
  red: '\033[0;31m',
  yellow: '\033[1;33m',
  cyan: '\033[0;36m',
  reset: '\033[0m'
}

function log(color, message) {
  console.log(`${COLORS[color]}${message}${COLORS.reset}`)
}

function validateQuest(questData, filename) {
  const errors = []
  const warnings = []
  
  // Required fields
  const required = ['id', 'title', 'description', 'tier', 'objectives', 'rewards']
  required.forEach(field => {
    if (!questData[field]) {
      errors.push(`Missing required field: ${field}`)
    }
  })
  
  // Validate ID format
  if (questData.id && !/^[a-z_]+$/.test(questData.id)) {
    errors.push('ID must be lowercase with underscores only')
  }
  
  // Validate tier
  if (questData.tier && (questData.tier < 1 || questData.tier > 5)) {
    warnings.push('Tier should be between 1-5')
  }
  
  // Validate objectives
  if (questData.objectives && questData.objectives.length === 0) {
    errors.push('Must have at least one objective')
  }
  
  // Validate description length
  if (questData.description && questData.description.length > 120) {
    warnings.push('Description should be under 120 characters')
  }
  
  // Check for author metadata
  if (!questData.metadata || !questData.metadata.author) {
    warnings.push('Consider adding author metadata')
  }
  
  return { errors, warnings }
}

function validateDiscovery(discoveryData, filename) {
  const errors = []
  const warnings = []
  
  // Required fields
  const required = ['id', 'title', 'category', 'content', 'triggers']
  required.forEach(field => {
    if (!discoveryData[field]) {
      errors.push(`Missing required field: ${field}`)
    }
  })
  
  // Validate category
  const validCategories = ['evidence', 'personal', 'technical', 'conspiracy', 'character']
  if (discoveryData.category && !validCategories.includes(discoveryData.category)) {
    errors.push(`Invalid category. Must be one of: ${validCategories.join(', ')}`)
  }
  
  // Validate rarity
  const validRarities = ['common', 'uncommon', 'rare', 'legendary']
  if (discoveryData.rarity && !validRarities.includes(discoveryData.rarity)) {
    warnings.push(`Invalid rarity. Should be one of: ${validRarities.join(', ')}`)
  }
  
  // Validate content structure
  if (discoveryData.content) {
    if (!discoveryData.content.summary) {
      errors.push('Content must include summary')
    }
    if (!discoveryData.content.details) {
      errors.push('Content must include details')
    }
  }
  
  // Validate triggers
  if (discoveryData.triggers) {
    const hasAnyTrigger = ['commands', 'files', 'ports', 'services', 'quest_completion']
      .some(trigger => discoveryData.triggers[trigger] && discoveryData.triggers[trigger].length > 0)
    
    if (!hasAnyTrigger) {
      errors.push('Must have at least one trigger condition')
    }
  }
  
  return { errors, warnings }
}

function validateFile(filePath) {
  const filename = path.basename(filePath)
  const ext = path.extname(filePath)
  
  if (ext !== '.json') {
    log('yellow', `Skipping non-JSON file: ${filename}`)
    return
  }
  
  try {
    const content = fs.readFileSync(filePath, 'utf8')
    const data = JSON.parse(content)
    
    let validation
    if (filePath.includes('quest')) {
      validation = validateQuest(data, filename)
    } else if (filePath.includes('discovery')) {
      validation = validateDiscovery(data, filename)
    } else {
      log('yellow', `Unknown content type for: ${filename}`)
      return
    }
    
    // Report results
    if (validation.errors.length === 0 && validation.warnings.length === 0) {
      log('green', `✓ ${filename} - Valid`)
    } else {
      log('cyan', `\n📁 ${filename}:`)
      
      validation.errors.forEach(error => {
        log('red', `  ✗ Error: ${error}`)
      })
      
      validation.warnings.forEach(warning => {
        log('yellow', `  ⚠ Warning: ${warning}`)
      })
    }
    
    return {
      file: filename,
      valid: validation.errors.length === 0,
      errors: validation.errors.length,
      warnings: validation.warnings.length
    }
    
  } catch (error) {
    log('red', `✗ ${filename} - JSON Parse Error: ${error.message}`)
    return {
      file: filename,
      valid: false,
      errors: 1,
      warnings: 0
    }
  }
}

function main() {
  const args = process.argv.slice(2)
  
  if (args.length === 0) {
    log('cyan', 'Network Chronicles 2.0 - Content Validator')
    log('yellow', 'Usage: node validate-content.js <file-or-directory>')
    log('yellow', 'Example: node validate-content.js content/narrative/quests/')
    process.exit(1)
  }
  
  const target = args[0]
  
  if (!fs.existsSync(target)) {
    log('red', `File or directory not found: ${target}`)
    process.exit(1)
  }
  
  const stats = fs.statSync(target)
  let files = []
  
  if (stats.isDirectory()) {
    files = fs.readdirSync(target)
      .filter(file => file.endsWith('.json'))
      .map(file => path.join(target, file))
  } else {
    files = [target]
  }
  
  if (files.length === 0) {
    log('yellow', 'No JSON files found to validate')
    process.exit(0)
  }
  
  log('cyan', `\nValidating ${files.length} file(s)...\n`)
  
  const results = files.map(validateFile).filter(Boolean)
  
  // Summary
  const valid = results.filter(r => r.valid).length
  const invalid = results.filter(r => !r.valid).length
  const totalErrors = results.reduce((sum, r) => sum + r.errors, 0)
  const totalWarnings = results.reduce((sum, r) => sum + r.warnings, 0)
  
  log('cyan', '\n' + '='.repeat(50))
  log('cyan', 'VALIDATION SUMMARY')
  log('cyan', '='.repeat(50))
  log('green', `✓ Valid files: ${valid}`)
  if (invalid > 0) log('red', `✗ Invalid files: ${invalid}`)
  if (totalErrors > 0) log('red', `Total errors: ${totalErrors}`)
  if (totalWarnings > 0) log('yellow', `Total warnings: ${totalWarnings}`)
  
  if (invalid === 0) {
    log('green', '\n🎉 All content files are valid!')
  } else {
    log('red', '\n❌ Some content files have errors that need fixing')
    process.exit(1)
  }
}

// Run if called directly
if (process.argv[1] === new URL(import.meta.url).pathname) {
  main()
}