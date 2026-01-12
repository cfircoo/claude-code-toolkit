# Workflow: Check Status

<objective>
View current Ralph pipeline progress.
</objective>

<process>

<step name="1_check_prd_json">
**Story status**

```bash
# Project info
cat prd.json | jq '{project: .project, branch: .branchName, description: .description}'

# Story summary
echo "=== Story Status ==="
cat prd.json | jq '.userStories[] | "\(.id): \(.title) - \(if .passes then "✓ PASS" else "○ pending" end)"'

# Counts
echo ""
echo "=== Summary ==="
cat prd.json | jq '{
  total: (.userStories | length),
  passed: ([.userStories[] | select(.passes == true)] | length),
  remaining: ([.userStories[] | select(.passes == false)] | length)
}'
```
</step>

<step name="2_check_progress">
**Learnings from iterations**

```bash
echo "=== Recent Learnings ==="
tail -30 progress.txt 2>/dev/null || echo "No progress.txt yet"
```
</step>

<step name="3_check_git">
**Recent commits**

```bash
echo "=== Recent Commits ==="
git log --oneline -10

echo ""
echo "=== Current Branch ==="
git branch --show-current
```
</step>

<step name="4_next_actions">
**Suggest next steps**

Based on status:
- If all passed: "All stories complete! Review the implementation and consider opening a PR."
- If some pending: "Would you like to continue Ralph execution?"
- If no prd.json: "No prd.json found. Start with full pipeline or from-prd workflow."
</step>

</process>

<success_criteria>
- [ ] Status displayed clearly
- [ ] Next steps suggested
</success_criteria>
