# IT Support Documentation Repository

Welcome to the **Guides** repository! This is a collection of step-by-step documentation and quick-start guides for end users, with a primary focus on security and authentication setup procedures.

## 📋 Contents

### 🔐 Authentication Guides

Located in `Windows Hello & Passkeys/src/`:

- **[Windows Hello Setup Guide](Windows%20Hello%20&%20Passkeys/src/Windows%20Hello%20setup%20guide.md)** - Device-level biometric authentication setup for Windows
- **[Google Passkey Setup Guide](Windows%20Hello%20&%20Passkeys/src/Google%20Passkey%20setup%20guide.md)** - Account-level passwordless authentication using Google Passkeys

### 📚 Additional Resources

Root directory contains departmental guides and reference materials:

- JDL UPS Installation guide
- KC VPN connection steps
- SFA Alphabetical Customer ID Entry
- Zebra RMA guide
- And more...

## 🎯 Guide Philosophy

All guides in this repository follow a **quick-start approach** designed for 5-minute setup with:

- ✅ Numbered, easy-to-follow steps
- 🎨 Visual hierarchy with emoji section headers
- 🔧 Troubleshooting tables for common issues
- 📱 Multi-platform coverage (Windows 10 & 11 differences noted)
- 📞 Clear support contact information

## 📝 Creating New Guides

Use the provided **[_TEMPLATE_guide.md](misc/_TEMPLATE_guide.md)** as your starting point for consistency. The template includes:

- Standard structure with numbered sections
- Pre-requisites section
- Troubleshooting table format
- Support contact section

## ⚙️ Repository Setup

### Configuration Files

- **`.markdownlint.jsonc`** - Markdown linting rules (allows HTML tags for PDF generation)

### File Structure

```txt
Guides/
├── README.md                          # This file
├── test.txt                           # CI test artifact
├── Copilot guides/
│   └── MEMORY_MCP_SERVER_FIX.md      # GitHub Copilot MCP memory fix guide
├── Windows Hello & Passkeys/
│   ├── src/                           # Source markdown files
│   │   ├── Windows Hello setup guide.md
│   │   ├── Google Passkey setup guide.md
│   │   └── email.md
│   ├── Windows Hello setup guide.pdf
│   └── Google Passkey setup guide.pdf
├── github/
│   └── rules/
│       ├── README.md                  # Ruleset automation overview
│       ├── Set-Rulesets.ps1           # (legacy copy — see note in #22)
│       ├── Main Branch Ruleset.json   # Reference configuration
│       ├── github-branch-protection-and-status-checks.md
│       ├── Main branch ruleset/
│       │   ├── Set-Rulesets.ps1       # Canonical script (tested by CI)
│       │   └── tests/
│       │       └── Set-Rulesets.Tests.ps1
│       └── Status checks/
│           └── README.md
└── misc/
    ├── _TEMPLATE_guide.md             # Template for new guides
    ├── .markdownlint.jsonc            # Linting configuration
    ├── Gmail labels and filters.pdf
    ├── JDL UPS Installation guide.docx
    ├── KC VPN connection steps.pdf
    ├── New ADP Timesheet.xlsx
    ├── SFA Alphabetical Customer ID Entry_2024.8.29.pdf
    └── Zebra RMA guide.png
```

## 🔄 Development Workflow

### Updating Documentation

1. Edit markdown source files in `src/` directories
2. Generate PDF outputs using pandoc: `pandoc input.md -o output.pdf`
3. Update cross-reference links between related guides
4. Maintain consistent formatting and contact information

### Review Checklist

- ✓ Contact information is current
- ✓ All cross-reference links are valid
- ✓ Steps verified on Windows 10 and Windows 11
- ✓ Following template structure and emoji patterns
- ✓ Troubleshooting section includes common issues

## 📞 Support Contacts

### Primary Contact

**Joey Maffiola** - 650-581-4478

### Secondary Contact

**KMS** - 650-581-4500

## 🔗 Integration Points

- Google Drive for file sharing and PDF hosting
- Windows Hello system capabilities
- Google Passkey service availability

---

**Repository**: [Guides](https://github.com/J-MaFf/Guides)
**Last Updated**: October 2025

## Ruleset Test

This is test content added by running the test PR script.
