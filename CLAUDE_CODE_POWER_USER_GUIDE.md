# Claude Code Power User Reference Guide

**Last Updated:** February 2026

---

## Executive Summary

Claude Code is a terminal-based AI coding assistant that transforms development workflows through agentic capabilities. Power users emphasize these key takeaways:

1. **Context is Currency** — The 200K token context window is your primary constraint. Aggressive management via `/clear`, session resets, and splitting work across conversations yields exponentially better results than fighting token limits.

2. **Workflow Over Features** — Effective Claude Code usage centers on four interdependent patterns: (1) preparation before coding, (2) verification after changes, (3) context discipline, and (4) safe autonomy through explicit constraints.

3. **Git Integration as Primary Interface** — Leverage Claude for all Git operations (commits, branching, bisecting). This offloads context-heavy manual work to the CLI where Claude excels.

4. **CLAUDE.md as Persistent Memory** — Your project's success depends on a living, updated CLAUDE.md file that captures conventions, gotchas, and patterns. Run `/init` on day one, refine continuously.

5. **Parallel Execution & Smart Delegation** — Use worktrees, headless mode, subagents, and multiple sessions to multiply output without proportional token consumption.

---

## Navigation & Shortcuts

### Essential Keyboard Shortcuts

| Shortcut | Action | Use Case |
|----------|--------|----------|
| `Esc + Esc` | Rewind conversation | Jump to previous message to undo changes |
| `Ctrl+C` | Cancel/Exit | Stop current operation (not full exit) |
| `Ctrl+D` | Exit session | Clean shutdown |
| `Ctrl+R` | Reverse history search | Find past commands/prompts interactively |
| `Ctrl+L` | Clear screen | Preserve history, clean visual space |
| `Ctrl+O` | Toggle verbose output | Debug tool execution and context flow |
| `Ctrl+T` | Toggle task list | Monitor background work status |
| `Ctrl+B` | Background task | Run long commands asynchronously (press twice in tmux) |
| `Ctrl+G` | Open text editor | Edit long prompts in `$EDITOR` |
| `Ctrl+V` | Paste images | Add visual content from clipboard |
| `Up/Down arrows` | Navigate history | Cycle through previous inputs per directory |
| `Shift+Tab` | Toggle permission mode | Cycle: Normal → Plan → Auto-Accept → Delegate |
| `Option+P` (Mac) or `Alt+P` | Switch models | Change between Opus/Sonnet/Haiku mid-session |
| `Option+T` (Mac) or `Alt+T` | Toggle extended thinking | Enable/disable reasoning mode |

**Pro Tip:** Terminal configuration matters. Configure Option as Meta in iTerm2, Terminal.app, and VS Code for Alt key shortcuts to work on macOS.

### Essential CLI Commands

```bash
# Start interactive session
claude

# Quick query (print mode, then exit)
claude -p "explain this code"

# Continue most recent conversation
claude -c

# Resume specific session
claude -r "session-name"

# Print mode with initial prompt
claude -p "query"

# Start with specific agent
claude --agent my-agent

# Skip all permissions (use carefully)
claude --dangerously-skip-permissions

# Show usage/status
/usage
/status
/context
```

### In-Session Slash Commands (Top 10)

| Command | Purpose | When to Use |
|---------|---------|------------|
| `/init` | Generate CLAUDE.md from codebase analysis | First session in new project |
| `/clear` | Reset conversation history | Starting unrelated task or cluttered context |
| `/help` | List available commands/skills | Discover features; shows custom commands too |
| `/config` | Open settings UI | Adjust permissions, models, hooks interactively |
| `/context` | Visualize token usage as grid | Identify what's consuming context |
| `/agents` | Create/manage subagents | Delegate specialized tasks (code review, security audit) |
| `/compact` | Force context compaction | Pre-emptively clean context mid-session |
| `/model` | Switch model (Opus/Sonnet/Haiku) | Optimize speed/cost for task difficulty |
| `/terminal-setup` | Configure terminal shortcuts | Enable Shift+Enter for multiline input |
| `/tasks` | View background task queue | Monitor autonomous operations |

---

## Advanced Features

### Plan Mode vs. Auto-Accept Mode

**Plan Mode** (`Shift+Tab` to enable):
- Claude shows its plan before executing
- You review and approve each step
- Useful for: unfamiliar codebases, multi-file changes, high-risk tasks
- Cost: Extra planning turn = more tokens

**Auto-Accept Mode**:
- Claude executes without permission prompts
- Fastest iteration for trusted workflows
- Use in: CI/CD, sandbox containers, well-defined tasks
- Risk: Can break things if unconstrained

**Recommendation:** Start in Plan Mode on new projects. Graduate to Auto-Accept once patterns stabilize.

### Extended Thinking (Advanced Reasoning)

Enable with `Option+T` (Mac) or toggle in `/config`:
- Claude allocates extra tokens to reasoning steps (you don't see these)
- Solves complex multi-step problems more reliably
- Token overhead: ~30-50% extra for output
- Best for: Architecture decisions, debugging root causes, complex refactors

```bash
# Use in headless mode
claude -p "debug why login fails" --extended-thinking
```

### MCP (Model Context Protocol) Servers

Connect external tools and data sources:

```bash
# List available MCP servers
claude mcp list

# Add a server
claude mcp add postgres  # Direct database queries
claude mcp add notion    # Access workspace knowledge
claude mcp add figma     # Load designs directly

# In session, Claude automatically discovers and uses them
> Update the user schema from the Figma design in Notion
```

**Power User Pattern:** Connect your stack (GitHub via `gh` CLI, Slack via MCP, databases via psql) to make Claude context-aware of real-time project state.

### Hooks (Automation Framework)

Hooks run commands automatically after specific events:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.ts)",
        "hooks": [
          { "type": "command", "command": "npx tsc --noEmit \"$CLAUDE_FILE_PATHS\"" }
        ]
      }
    ]
  }
}
```

**Common Use Cases:**
- Auto-format on write (Prettier, Black)
- Type-check TypeScript/Python
- Run linters (ESLint, Ruff)
- Execute tests for specific files

**Difficulty:** Intermediate | Add to `.claude/settings.json`

### Subagents (Specialized Delegation)

Create focused AI agents for specific roles:

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Bash
model: opus
---

You are a security expert. Review code for:
- SQL injection, XSS, command injection
- Hardcoded secrets, weak crypto
- OWASP Top 10 violations
Provide specific line references and fixes.
```

Save as `.claude/agents/security-reviewer.md`, then invoke:
```
> @security-reviewer audit this authentication module
```

**Benefit:** Specialized focus improves quality and frees main context for coordination.

### Skills (Custom Slash Commands)

Define reusable prompts as `/command`:

```markdown
# .claude/commands/test.md
Analyze this code for test gaps and write comprehensive Jest tests.
- Cover happy path, edge cases, error scenarios
- Mock external dependencies
- Aim for 80%+ coverage
- Use React Testing Library for components
```

Invoke with:
```
/test src/auth/LoginForm.tsx
```

---

## Workflow Optimization

### The "80/20 Review" Pattern

Power users batch code review at checkpoints rather than continuous approval:

1. **Do preparatory work** — Scope out architecture, run `/init`, establish context
2. **Code uninterrupted** — Let Claude work in Auto-Accept mode for 15-30 minutes
3. **Checkpoint review** — Step through git diff, validate patterns, test
4. **Iterate informed** — New context window with clearer requirements

**Token Impact:** 40% less overhead than per-change approval.

### The "Explore-Plan-Code" Workflow

1. **Explore (5 min):** Ask broad questions about codebase
   - "What's the auth architecture?"
   - "Where are database schemas defined?"
   - "What's the test structure?"

2. **Plan (10 min):** Design approach before writing
   - Let Claude interview you: *"What edge cases matter?"*
   - Establish success criteria
   - Identify risky assumptions

3. **Code (20-60 min):** Execute with verification

**Why It Works:** Planning phase is cheap (1000-3000 tokens) and prevents derailed implementations.

### Context Management Hierarchy

**Tier 1 (Free, Do Always):**
- Run `/clear` between unrelated tasks
- Use `/context` to visualize bloat
- Remove completed TODO items from conversation

**Tier 2 (Moderate Token Savings):**
- Split large features across sessions
- Summarize completed sections in CLAUDE.md
- Archive solved problems to external docs

**Tier 3 (Advanced):**
- Use subagents to isolate investigation from main work
- Implement structured note-taking (NOTES.md with progress)
- Employ `/compact` proactively (not just at limit)

**Tier 4 (Extreme Cases):**
- Split work across multiple worktrees with parallel Claude sessions
- Use headless mode to chain operations
- Store intermediate results in JSON files instead of context

### Git Workflow with Claude

**Let Claude handle:**
- Commit messages (no manual writing)
- Branch creation and management
- Merge conflict resolution
- Git bisect for bug hunting
- PR generation and drafting

```
> Commit these changes with a conventional commit message
> Create a feature branch for the payment refactor
> Find the exact commit that broke the login flow
> Generate a comprehensive PR description with before/after
```

**Difficulty:** Beginner | **Token Savings:** 30-40% vs manual git operations

---

## Integration Patterns

### Headless Mode (CI/CD & Automation)

```bash
# One-off analysis
claude -p "Analyze this error: $ERROR" --output-format json

# Structured output for scripts
claude -p "List API endpoints" --output-format json | jq '.endpoints'

# Streaming for real-time processing
claude -p "Analyze logs" --output-format stream-json | while read line; do
  # Process JSON as it arrives
done
```

**Use In:**
- Pre-commit hooks: Check code before staging
- CI pipelines: Auto-review PRs, fix lint errors
- Monitoring: Analyze logs, alert on anomalies
- Batch jobs: Generate reports, translate content

### Parallel Sessions & Worktrees

**Local Parallel (CLI):**
```bash
# Terminal 1: Work on feature
claude

# Terminal 2: Review code in parallel
claude --agent code-reviewer
```

**Cloud Parallel (Desktop App or Web):**
- Launch new sessions for independent work streams
- Share findings via git (push to feature branch)
- Merge results when complete

**Worktree Pattern (Advanced):**
```bash
git worktree add -b feature/auth ../auth-branch
cd ../auth-branch
claude  # Fresh context for this branch
```

**Benefit:** 3-4 parallel sessions = 2-2.5x throughput (super-linear gains due to reduced context collision).

### Multi-Agent Orchestration

Use Plan Mode + subagents for complex workflows:

1. **Main session** (Coordinator): Breaks down task
2. **@security-reviewer**: Audits code
3. **@test-generator**: Writes tests
4. **@documentation**: Updates docs

Each agent works in isolation with fresh context. Main session combines results.

```
> Split this refactor:
> - @security-reviewer audit for vulnerabilities
> - @test-generator write comprehensive tests
> - I'll handle the implementation
```

---

## Troubleshooting

### "Claude is getting worse mid-session"

**Root Cause:** Context pollution (lost-in-middle effect)

**Solutions:**
- Run `/clear` and restart with lesson learned
- Use `/compact` proactively at 60% token usage
- Switch to fresh worktree with cleaner context

### "Permission prompts are slowing me down"

**Quick Fix:**
```bash
claude --dangerously-skip-permissions  # In sandbox only
```

**Better Fix:**
```json
{
  "permissions": {
    "allowedTools": ["Read", "Write(src/**)", "Bash(git *)", "Bash(npm *)"],
    "deny": ["Write(/etc/*)", "Bash(rm -rf *)"]
  }
}
```

Explicitly allow safe operations, deny dangerous ones. Requires ~1s setup, saves 30s+ per session.

### "CLAUDE.md is outdated / not working"

**Common Issues:**
1. **File too long** → Exceeds token budget. Trim to essentials (code style, common gotchas, key files)
2. **Information stale** → Environment changed. Regenerate: `/init` → review/merge with existing
3. **Not being loaded** → Verify: `/config` → check "Project instructions" or "CLAUDE.md" setting

**Maintenance Ritual:**
- Weekly: Review and update CLAUDE.md
- End of session: "Add new findings to CLAUDE.md"
- After major refactors: Run `/init` and integrate changes

### "I hit context limits constantly"

**Diagnosis Steps:**
1. Run `/context` to see what's consuming space
2. Check if MCP servers have stale state
3. Verify hooks aren't creating artifact pollution

**Structural Fix:**
- Reduce MCP server count to active ones only
- Limit CLAUDE.md to <2000 tokens
- Split features across sessions
- Use `/compact` at 70% to preempt hard limits

### "Model switched to Sonnet unexpectedly"

This is intentional: Pro/Max subscriptions automatically use Sonnet at 50% usage to manage cost. Switch to Opus with `/model` if you need continuous high-capability, or upgrade to Max tier.

---

## Real-World Workflows

### Workflow 1: Onboarding New Codebase (30 minutes)

```
1. cd /path/to/project && claude
2. /init  # Generate CLAUDE.md
3. Review CLAUDE.md, add custom sections
4. Ask codebase questions:
   - "How does authentication work?"
   - "What does the test structure look like?"
   - "Where are database migrations?"
5. /clear
6. Now ready for productive work
```

### Workflow 2: Feature Implementation with Quality Gates

```
1. Scope feature with Claude: "Design a user notification system"
2. Create tests first: "Write Jest tests for notifications"
3. Implement with Auto-Accept mode enabled
4. Quality checks (new context window):
   - @security-reviewer audit
   - @test-generator: Write integration tests
   - Manual code review
5. /commit with generated message
```

### Workflow 3: Emergency Debugging

```
1. claude -c  # Continue previous session to preserve context
2. Share error: [paste full stack trace]
3. Ask: "What's the root cause? Use git bisect if needed"
4. Let Claude run bisect autonomously (provide test command)
5. Once found: fix and verify
6. /clear before moving to new task
```

### Workflow 4: Large Refactor Across Multiple Files

```
1. Plan phase (stay in one session):
   - "Interview me on this refactor scope"
   - Establish success criteria
   - Identify risky areas

2. Execution (multiple sessions):
   - Session A: Implement core changes
   - Session B: Update tests
   - Session C: Update documentation
   - Main session: Review & integrate

3. Verification:
   - Full test suite run
   - Type check
   - Visual review of diffs
   - Merge to branch
```

---

## Performance Tuning by Task Type

| Task | Best Model | Plan Mode | Context Strategy |
|------|-----------|-----------|-------------------|
| Code generation | Sonnet | Plan first | Reset every 30 min |
| Bug fixing | Opus | Yes, always | Keep recent stack trace |
| Code review | Opus | Yes | Lean on /subagents |
| Refactoring | Sonnet | Plan, then Auto-Accept | /clear between sections |
| Testing | Sonnet | No | Batch write tests in Auto-Accept |
| Architecting | Opus | Extended Thinking | Plan-heavy, code-light |
| Documentation | Sonnet | No | Stream output to file |

---

## Environment Setup for Power Users

### Recommended Settings (.claude/settings.json)

```json
{
  "model": "claude-sonnet-4-20250514",
  "permissions": {
    "allowedTools": [
      "Read",
      "Write",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npm run test*)"
    ],
    "deny": ["Bash(rm *)"]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.ts|*.tsx)",
        "hooks": [
          { "type": "command", "command": "npx prettier --write \"$CLAUDE_FILE_PATHS\"" },
          { "type": "command", "command": "npx tsc --noEmit --skipLibCheck" }
        ]
      }
    ]
  }
}
```

### Alias for Speed

```bash
# ~/.bashrc or ~/.zshrc
alias c='claude'
alias cc='claude -c'  # Continue last session
alias cp='claude -p'  # Print mode

# More advanced
function cc-branch() {
  # Continue session on different branch
  git checkout "$1"
  claude -c
}
```

---

## Sources & Further Reading

**Official Documentation:**
- [Claude Code Docs](https://code.claude.com/docs/en/overview)
- [Best Practices Guide](https://code.claude.com/docs/en/best-practices)
- [Interactive Mode Reference](https://code.claude.com/docs/en/interactive-mode)
- [Common Workflows](https://code.claude.com/docs/en/common-workflows)

**Community Guides:**
- [Pro Workflow GitHub](https://github.com/rohitg00/pro-workflow) — Self-correcting memory, wrap-up rituals
- [Claude Code Tips GitHub](https://github.com/ykdojo/claude-code-tips) — 40+ tips from 11 months of heavy use
- [egghead.io Essentials](https://egghead.io/the-essential-claude-code-shortcuts~dgsee) — Video course on shortcuts
- [r/ClaudeAI Discussions](https://www.reddit.com/r/ClaudeAI/) — Real user workflows and troubleshooting

**Advanced Topics:**
- [Tool Use Overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- [Prompt Engineering Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Context Windows & Management](https://platform.claude.com/docs/en/build-with-claude/context-windows)
- [AWS Bedrock Deployment](https://aws.amazon.com/blogs/machine-learning/claude-code-deployment-patterns-and-best-practices-with-amazon-bedrock/)

---

## Quick Reference: Decision Tree

```
Starting work on code?
├─ New to codebase? → Run /init, explore, then /clear before productive work
├─ Small bug fix? → Quick question + fix, no planning needed
├─ Medium feature? → Plan mode (15 min) → Auto-Accept implementation
├─ Large refactor? → Split across multiple sessions + subagents
└─ Not sure scope? → Have Claude interview you

Context getting full?
├─ <70% usage? → Continue working
├─ 70-85% usage? → Run /compact proactively
├─ >85% usage? → Wrap up task, /clear, fresh context
└─ Stuck? → Rewind (Esc+Esc) and try different approach

Permission prompts frustrating?
├─ Local development? → Set explicit allowlist in settings
├─ Sandbox container? → --dangerously-skip-permissions OK
├─ Production? → Keep strict; set up explicit deny rules
└─ Team project? → Check .claude/settings.json in git

Session dragging?
├─ Have you /clear'd recently? → Do it now
├─ Is CLAUDE.md >2000 tokens? → Trim to essentials
├─ Many MCP servers connected? → Disconnect unused ones
└─ Does it need different model? → Switch with /model
```

---

**Last Updated:** February 2026  
**Difficulty Levels:** Beginner | Intermediate | Advanced

For the latest features and updates, consult official Claude Code documentation at [code.claude.com/docs](https://code.claude.com/docs).
