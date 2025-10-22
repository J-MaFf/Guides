# Copilot Instructions for Guides Repository

## Repository Overview

This is an IT support documentation repository containing step-by-step guides for end users. The primary focus is on security and authentication setup guides (Windows Hello, Google Passkeys) with a user-friendly, quick-start approach.

## Content Structure & Patterns

### Documentation Organization
- **Source files**: Markdown files in `src/` directories contain the editable content
- **Generated outputs**: PDF files are generated from markdown sources for distribution
- **Mixed formats**: Repository contains both documentation projects and standalone files (PDFs, Excel, images)

### Writing Style Guidelines
- **Quick-start focus**: All guides follow a "5-minute setup" approach with numbered steps
- **Visual hierarchy**: Use emojis (🚀, 💡, 🔧) for section headers to improve visibility
- **Troubleshooting tables**: Standardized problem/solution format using markdown tables
- **Contact information**: Every guide ends with primary (Joey Maffiola) and secondary (KMS) support contacts

### Markdown Conventions
- **Page breaks**: Use `<div class="page"/>` for PDF generation page breaks
- **Cross-references**: Link to other guides using Google Drive sharing links
- **Step formatting**: Use numbered lists with bold action items ("Open Settings:", "Click 'Set up'")
- **Platform differences**: Document Windows 10 vs 11 UI differences explicitly
- **Template usage**: Use `_TEMPLATE_guide.md` as starting point for new guides
- **Linting**: `.markdownlint.jsonc` allows HTML tags (MD033 disabled) for functional PDF generation

## Key Files & Directories

### Active Documentation Projects
- `Windows Hello & Passkeys/src/`: Contains the main authentication setup guides
  - `Windows Hello setup guide.md`: Device-level biometric authentication setup
  - `Google Passkey setup guide.md`: Account-level passwordless authentication
- `_TEMPLATE_guide.md`: Template for creating new guides with consistent structure (root level)
- `.markdownlint.jsonc`: Linting configuration that allows HTML tags needed for PDF generation

### Legacy/Reference Files
- Root directory contains various departmental guides in different formats
- These are primarily reference materials, not active development

## Development Workflow

### Content Updates
1. Edit markdown files in `src/` directories
2. Generate PDF outputs using pandoc: `pandoc input.md -o output.pdf`
3. Update cross-reference links between related guides
4. Maintain consistent formatting and contact information

### Review Process (Recommended)
- **Contact verification**: Ensure all contact information remains current
- **Cross-reference validation**: Test all Google Drive links and inter-guide references
- **Multi-platform testing**: Verify steps on both Windows 10 and Windows 11
- **User testing**: Have a non-technical user follow the guide before publication

### Quality Standards
- **Accessibility**: Use clear step numbers and descriptive headings
- **Completeness**: Include troubleshooting sections for common issues
- **Accuracy**: Verify steps work on both Windows 10 and Windows 11
- **Maintenance**: Keep contact information and external links current

## Integration Points

### External Dependencies
- Google Drive for file sharing and PDF hosting
- Windows Hello system requirements and capabilities
- Google Passkey service availability and browser support

### Cross-Guide Relationships
- Windows Hello setup is a prerequisite for Google Passkey setup
- Guides reference each other with specific Google Drive links
- Troubleshooting escalation follows consistent support contact hierarchy

## AI Agent Guidelines

When working on documentation in this repository:
1. **Maintain the quick-start format**: Keep guides focused on essential steps only
2. **Update cross-references**: If you change file locations, update all referencing guides
3. **Preserve contact information**: Don't modify support contact details without explicit instruction
4. **Test on multiple Windows versions**: Consider Windows 10 vs 11 UI differences
5. **Follow the emoji pattern**: Use consistent visual indicators for section types
6. **Include troubleshooting**: Every procedural guide should have a troubleshooting section