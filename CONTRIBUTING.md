# Contributing to Network Chronicles

Thank you for your interest in contributing to Network Chronicles! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check the existing issues to see if the problem has already been reported. If it has and the issue is still open, add a comment to the existing issue instead of opening a new one.

When creating a bug report, please include as much detail as possible:

- **Use a clear and descriptive title** for the issue
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** to demonstrate the steps
- **Describe the behavior you observed** after following the steps
- **Explain the behavior you expected to see instead**
- **Include screenshots or animated GIFs** if possible
- **Include details about your environment** (OS, shell, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title** for the issue
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **Include any relevant examples or mockups**

### Creating Content

Network Chronicles thrives on community-created content! You can contribute:

- **Quests**: New storylines and missions
- **Challenges**: Technical puzzles and tasks
- **Discoveries**: Hidden elements for players to find
- **Documentation**: Improvements to the game's documentation

See the [Content Creation Guide](docs/content-creation.md) for detailed instructions.

### Pull Requests

- Fill in the required template
- Follow the style guidelines
- Include appropriate tests
- Update documentation as needed
- End all files with a newline

## Style Guidelines

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line

### Bash Scripting

- Use 2-space indentation
- Use `#!/bin/bash` shebang
- Include comments for complex logic
- Use meaningful variable names
- Quote variables to prevent word splitting

### JavaScript

- Use 2-space indentation
- Use semicolons
- Use camelCase for variables and functions
- Use PascalCase for classes
- Use UPPER_CASE for constants

### Documentation

- Use Markdown for all documentation
- Use proper headings and lists
- Include code examples where appropriate
- Keep language clear and concise

## Development Process

### Setting Up Your Development Environment

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/network-chronicles.git`
3. Add the upstream repository: `git remote add upstream https://github.com/original/network-chronicles.git`
4. Install dependencies: `./install-dev.sh`

### Testing

- Run unit tests: `npm test`
- Run integration tests: `npm run test:integration`
- Test your changes in a Docker container: `docker-compose up`

### Submitting Changes

1. Create a new branch: `git checkout -b my-branch-name`
2. Make your changes
3. Run tests: `npm test`
4. Commit your changes: `git commit -am 'Add some feature'`
5. Push to the branch: `git push origin my-branch-name`
6. Submit a pull request

## Content Guidelines

When creating content for Network Chronicles, please follow these guidelines:

### Narrative Voice

- Use second-person perspective for quest descriptions ("You discover..." not "The player discovers...")
- Use first-person perspective for journal entries ("I found..." not "You found...")
- The Architect should have a distinct voice: technical, slightly cryptic, and occasionally philosophical

### Technical Accuracy

- All commands and technical references should be accurate and functional
- Network configurations should follow standard conventions
- Security concepts should be realistic and educational

### Difficulty Progression

- Tier 1 content should be accessible to beginners
- Tier 2-3 content should require basic technical knowledge
- Tier 4-5 content should challenge experienced administrators
- Provide hints for difficult challenges

### Narrative Themes

- Mystery: The disappearance of The Architect
- Paranoia: Trust issues and potential insider threats
- Discovery: Uncovering the network's secrets
- Growth: The player's journey from novice to expert

## Additional Resources

- [Development Guide](docs/development.md)
- [Content Creation Guide](docs/content-creation.md)
- [API Documentation](docs/api.md)
- [Architecture Overview](docs/architecture.md)

## Questions?

If you have any questions or need help, please:

1. Check the [documentation](docs/)
2. Search for existing issues
3. Open a new issue with your question

Thank you for contributing to Network Chronicles!
