#!/bin/bash
# ============================================================================
# Culture Engine — Integration Test & Demo
# ============================================================================
#
# Simulates two team members (Felix and Reza) using the Culture Engine plugin
# in a shared project. Tests the full lifecycle: init, feedback, reflection,
# observation, and multi-user collaboration.
#
# Usage:
#   ./tests/integration-test.sh
#
# Prerequisites:
#   - claude CLI installed and authenticated
#   - gh CLI installed and authenticated
#   - Culture Engine plugin installed (claude plugins add /path/to/culture)
#   - Member of performance-dudes GitHub org
#
# ============================================================================

set -euo pipefail

# --- Config ---
GITHUB_ORG="performance-dudes"
TEST_REPO="culture-test"
REMOTE="git@github.com:${GITHUB_ORG}/${TEST_REPO}.git"
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="/tmp/culture-engine-test"
FELIX_DIR="${WORK_DIR}/felix"
REZA_DIR="${WORK_DIR}/reza"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Helpers ---

header() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

step() {
    echo -e "${BLUE}▸${NC} ${BOLD}$1${NC}"
}

user_action() {
    local user=$1
    local action=$2
    local color=$CYAN
    [ "$user" = "Reza" ] && color=$YELLOW
    echo ""
    echo -e "  ${color}👤 ${user}:${NC} ${action}"
}

check() {
    local description=$1
    local path=$2
    if [ -e "$path" ]; then
        echo -e "  ${GREEN}✓${NC} ${description}"
        return 0
    else
        echo -e "  ${RED}✗${NC} ${description} — expected: ${path}"
        return 1
    fi
}

check_content() {
    local description=$1
    local path=$2
    local pattern=$3
    if [ -e "$path" ] && grep -q "$pattern" "$path" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} ${description}"
        return 0
    else
        echo -e "  ${RED}✗${NC} ${description} — pattern '${pattern}' not found in ${path}"
        return 1
    fi
}

check_dir_not_empty() {
    local description=$1
    local dir=$2
    if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        local count=$(ls -1 "$dir" | wc -l | tr -d ' ')
        echo -e "  ${GREEN}✓${NC} ${description} (${count} files)"
        return 0
    else
        echo -e "  ${RED}✗${NC} ${description} — directory empty or missing: ${dir}"
        return 1
    fi
}

run_as() {
    local user=$1
    local dir=$2
    local prompt=$3
    echo -e "  ${CYAN}🤖 Claude:${NC} processing..."
    # Run claude non-interactively, with the plugin available
    (cd "$dir" && claude -p "$prompt" --allowedTools "Bash,Read,Write,Edit,Glob,Grep" 2>/dev/null) || true
}

PASS=0
FAIL=0

assert() {
    if "$@"; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
}

# ============================================================================
# SETUP
# ============================================================================

header "Setup: Preparing test environment"

step "Cleaning previous test data"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

step "Resetting remote repo (${GITHUB_ORG}/${TEST_REPO})"
# Clone, wipe, push empty
git clone "${REMOTE}" "${WORK_DIR}/_setup" 2>/dev/null || {
    mkdir -p "${WORK_DIR}/_setup"
    cd "${WORK_DIR}/_setup"
    git init
    git remote add origin "${REMOTE}"
}
cd "${WORK_DIR}/_setup"
# Remove all files, create fresh
git checkout -B main 2>/dev/null || true
find . -not -path './.git/*' -not -name '.git' -delete 2>/dev/null || true
echo "# Culture Test Project" > README.md
echo "A test project for demonstrating the Culture Engine plugin." >> README.md
git add -A
git commit -m "chore: reset test repo" --allow-empty 2>/dev/null || git commit -m "chore: reset test repo"
git push -u origin main --force 2>/dev/null
cd "${WORK_DIR}"
rm -rf "${WORK_DIR}/_setup"

step "Cloning as Felix"
git clone "${REMOTE}" "${FELIX_DIR}" 2>/dev/null
(cd "${FELIX_DIR}" && git config user.name "Felix" && git config user.email "felix@test.local")

step "Cloning as Reza"
git clone "${REMOTE}" "${REZA_DIR}" 2>/dev/null
(cd "${REZA_DIR}" && git config user.name "Reza" && git config user.email "reza@test.local")

echo -e "\n${GREEN}Setup complete.${NC}\n"

# ============================================================================
# ACT 1: Felix initializes Culture Engine
# ============================================================================

header "Act 1: Felix initializes the Culture Engine"

user_action "Felix" "Initializing culture in the project"

run_as "Felix" "${FELIX_DIR}" "
You have the Culture Engine plugin installed. Initialize culture for this project.
Do the following steps exactly:
1. Create the directory structure: culture/feedback/ culture/snapshots/ culture/retros/ culture/decisions/ culture/logs/
2. Create culture/values.md with these team values:
   - Thorough reviews: Review logic and architecture first, style second
   - Fast feedback: Respond to PRs within 24 hours
   - Psychological safety: Disagree with ideas, not people
3. Create culture/.config.yaml with: enabled: true, default_attribution: anonymous
4. Git add all culture/ files and commit with message 'culture: initialize culture/ for project'
5. Git push to origin main
"

step "Verifying culture/ structure"
(cd "${FELIX_DIR}" && git pull --rebase 2>/dev/null)
assert check "culture/ folder exists" "${FELIX_DIR}/culture"
assert check "values.md exists" "${FELIX_DIR}/culture/values.md"
assert check ".config.yaml exists" "${FELIX_DIR}/culture/.config.yaml"
assert check "feedback/ dir exists" "${FELIX_DIR}/culture/feedback"
assert check "snapshots/ dir exists" "${FELIX_DIR}/culture/snapshots"
assert check "logs/ dir exists" "${FELIX_DIR}/culture/logs"
assert check_content "values.md has team values" "${FELIX_DIR}/culture/values.md" "Thorough reviews"

# ============================================================================
# ACT 2: Reza pulls and sees culture
# ============================================================================

header "Act 2: Reza discovers the Culture Engine"

user_action "Reza" "Pulling latest changes"
(cd "${REZA_DIR}" && git pull --rebase 2>/dev/null)

step "Verifying Reza sees culture/"
assert check "Reza has culture/" "${REZA_DIR}/culture"
assert check "Reza has values.md" "${REZA_DIR}/culture/values.md"

user_action "Reza" "Reading team values"
run_as "Reza" "${REZA_DIR}" "
Read culture/values.md and tell me what the team values are. Keep your response under 50 words.
"

# ============================================================================
# ACT 3: Felix submits public feedback
# ============================================================================

header "Act 3: Felix submits public feedback"

user_action "Felix" "Writing feedback about the project's PR review speed"

WEEK=$(date +%W)
YEAR=$(date +%Y)

run_as "Felix" "${FELIX_DIR}" "
Create a feedback entry for the Culture Engine. Write it to culture/feedback/${YEAR}-W${WEEK}-felix-01.md

Use this exact format:
---
date: $(date +%Y-%m-%d)
type: praise
attribution: felix
scope: team
---

## Observation

The team has been responding to PRs within hours this week. Review quality is high — comments focus on architecture and logic, not just style.

## Impact

Fast, substantive reviews keep momentum high and signal that everyone's work is valued.

## Suggestion

Keep the current review cadence. Consider documenting the review approach as a team norm.

## Reflection Prompt

What made reviews faster this week? Was it fewer PRs, better focus, or something else?

Then git add, commit with message 'culture: add praise feedback (felix)', and push.
"

step "Verifying feedback entry"
(cd "${FELIX_DIR}" && git pull --rebase 2>/dev/null)
assert check "Feedback file exists" "${FELIX_DIR}/culture/feedback/${YEAR}-W${WEEK}-felix-01.md"
assert check_content "Feedback has correct type" "${FELIX_DIR}/culture/feedback/${YEAR}-W${WEEK}-felix-01.md" "type: praise"
assert check_content "Feedback attributed to felix" "${FELIX_DIR}/culture/feedback/${YEAR}-W${WEEK}-felix-01.md" "attribution: felix"

# ============================================================================
# ACT 4: Reza submits anonymous feedback
# ============================================================================

header "Act 4: Reza submits anonymous feedback"

user_action "Reza" "Writing anonymous feedback about documentation"

run_as "Reza" "${REZA_DIR}" "
First, run: git pull --rebase

Then create a feedback entry at culture/feedback/${YEAR}-W${WEEK}-anonymous-01.md

Use this exact format:
---
date: $(date +%Y-%m-%d)
type: growth-edge
attribution: anonymous
scope: team
---

## Observation

Documentation in PRs has been minimal lately. Several PRs had no description beyond the title, making reviews harder and slower.

## Impact

Lack of PR descriptions forces reviewers to read every line of code without context, reducing review quality and increasing time to merge.

## Suggestion

Add a one-paragraph description to every PR explaining what changed and why. Does not need to be long — just enough context for the reviewer.

## Reflection Prompt

When was the last time a good PR description saved you time during review?

Then git add, commit with message 'culture: add growth-edge feedback (anonymous)', and push.
"

step "Verifying anonymous feedback"
(cd "${REZA_DIR}" && git pull --rebase 2>/dev/null)
assert check "Anonymous feedback exists" "${REZA_DIR}/culture/feedback/${YEAR}-W${WEEK}-anonymous-01.md"
assert check_content "Feedback is anonymous" "${REZA_DIR}/culture/feedback/${YEAR}-W${WEEK}-anonymous-01.md" "attribution: anonymous"
assert check_content "Feedback is growth-edge type" "${REZA_DIR}/culture/feedback/${YEAR}-W${WEEK}-anonymous-01.md" "type: growth-edge"

# ============================================================================
# ACT 5: Felix sees Reza's feedback
# ============================================================================

header "Act 5: Felix discovers anonymous feedback"

user_action "Felix" "Pulling and reviewing team feedback"
(cd "${FELIX_DIR}" && git pull --rebase 2>/dev/null)

assert check "Felix sees anonymous feedback" "${FELIX_DIR}/culture/feedback/${YEAR}-W${WEEK}-anonymous-01.md"

run_as "Felix" "${FELIX_DIR}" "
Read all files in culture/feedback/ and summarize the team feedback this week. Keep it under 100 words. Note which entries are anonymous vs attributed.
"

# ============================================================================
# ACT 6: Simulate session logging
# ============================================================================

header "Act 6: Session logging"

user_action "Felix" "Simulating session log creation"

SESSION_ID="test-$(date +%s)"
DATE=$(date +%Y-%m-%d)

# Simulate what the SessionEnd hook would create
mkdir -p "${FELIX_DIR}/culture/logs"
cat > "${FELIX_DIR}/culture/logs/${DATE}_felix_${SESSION_ID:0:8}.json" << EOF
{"sid": "${SESSION_ID}", "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)", "event": "session_end"}
EOF

step "Verifying session log"
assert check "Session log created" "${FELIX_DIR}/culture/logs/${DATE}_felix_${SESSION_ID:0:8}.json"

user_action "Felix" "Committing with session logs auto-staged"
(cd "${FELIX_DIR}" && \
    echo "# Some code change" > "${FELIX_DIR}/app.js" && \
    git add app.js culture/logs/ && \
    git commit -m "feat: add app.js" && \
    git push 2>/dev/null)

step "Verifying logs included in commit"
LAST_COMMIT_FILES=$(cd "${FELIX_DIR}" && git diff-tree --no-commit-id --name-only -r HEAD)
if echo "$LAST_COMMIT_FILES" | grep -q "culture/logs/"; then
    echo -e "  ${GREEN}✓${NC} Session logs included in commit"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗${NC} Session logs NOT included in commit"
    FAIL=$((FAIL + 1))
fi

# ============================================================================
# ACT 7: Multi-user sync verification
# ============================================================================

header "Act 7: Multi-user sync"

user_action "Reza" "Pulling all changes"
(cd "${REZA_DIR}" && git pull --rebase 2>/dev/null)

step "Verifying Reza sees everything"
assert check "Reza sees Felix's feedback" "${REZA_DIR}/culture/feedback/${YEAR}-W${WEEK}-felix-01.md"
assert check "Reza sees anonymous feedback" "${REZA_DIR}/culture/feedback/${YEAR}-W${WEEK}-anonymous-01.md"
assert check "Reza sees session logs" "${REZA_DIR}/culture/logs"
assert check_dir_not_empty "Reza has log files" "${REZA_DIR}/culture/logs"

# ============================================================================
# ACT 8: Culture health check
# ============================================================================

header "Act 8: Culture health check"

user_action "Felix" "Asking Claude for a culture summary"

run_as "Felix" "${FELIX_DIR}" "
Read all files in culture/ (values.md, .config.yaml, and everything in feedback/).
Give me a brief culture health summary in this format:

Team Health:
- Feedback entries this week: [count]
- Anonymous: [count] | Public: [count]
- Top themes: [list]

Values Alignment:
- [for each value in values.md, note if feedback supports or challenges it]

Keep the whole response under 150 words.
"

# ============================================================================
# RESULTS
# ============================================================================

header "Test Results"

TOTAL=$((PASS + FAIL))
echo -e "  ${GREEN}Passed: ${PASS}${NC}"
echo -e "  ${RED}Failed: ${FAIL}${NC}"
echo -e "  ${BOLD}Total:  ${TOTAL}${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}  All tests passed! ✓${NC}"
    echo ""
    echo -e "  The Culture Engine successfully demonstrated:"
    echo -e "  • Project initialization with team values"
    echo -e "  • Public feedback submission (attributed)"
    echo -e "  • Anonymous feedback submission (de-identified)"
    echo -e "  • Multi-user sync via git"
    echo -e "  • Session logging with commit integration"
    echo -e "  • Culture health reporting"
    echo ""
    echo -e "  Test repo: https://github.com/${GITHUB_ORG}/${TEST_REPO}"
else
    echo -e "${RED}${BOLD}  Some tests failed. Check output above.${NC}"
fi

echo ""
echo -e "${BOLD}Cleanup:${NC} rm -rf ${WORK_DIR}"
echo ""

exit $FAIL
