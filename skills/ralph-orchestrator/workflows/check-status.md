# Workflow: Check Status

<objective>
View current Ralph pipeline progress with detailed status breakdown.
</objective>

<process>

<step name="1_check_prd_json">
**Story status**

```bash
# Project info
cat tasks/prd.json | jq '{project: .project, branch: .branchName, description: .description}'

# Story summary (new schema)
echo "=== Story Status ==="
cat tasks/prd.json | jq '.userStories[] | "\(.id): \(.title) - status: \(.status // (if .passes then "done" else "pending" end)) | attempts: \(.attempts // "n/a") / \(.maxAttempts // "n/a")"'

# Status breakdown
echo ""
echo "=== Summary ==="
cat tasks/prd.json | jq '{
  total: (.userStories | length),
  done: ([.userStories[] | select(.status == "done" or .passes == true)] | length),
  pending: ([.userStories[] | select(.status == "pending" or (.passes == false and .status == null))] | length),
  failed: ([.userStories[] | select(.status == "failed")] | length),
  blocked: ([.userStories[] | select(.status == "blocked")] | length),
  in_progress: ([.userStories[] | select(.status == "in_progress")] | length),
  exhausted: ([.userStories[] | select(.status == "failed" and .attempts >= .maxAttempts)] | length)
}'
```
</step>

<step name="2_check_failures">
**Failed and exhausted stories**

```bash
echo "=== Failed Stories ==="
cat tasks/prd.json | jq '.userStories[] | select(.status == "failed") | {id, title, attempts, maxAttempts, lastAttemptLog}'

echo ""
echo "=== Blocked Stories ==="
cat tasks/prd.json | jq '.userStories[] | select(.status == "blocked" or (.blockedBy | length > 0)) | {id, title, blockedBy}'
```
</step>

<step name="3_check_progress">
**Learnings from iterations**

```bash
echo "=== Recent Learnings ==="
tail -30 tasks/progress.txt 2>/dev/null || echo "No tasks/progress.txt yet"
```
</step>

<step name="3b_check_test_log">
**Tests created**

```bash
echo "=== Test Log ==="
tail -40 tasks/test-log.md 2>/dev/null || echo "No tasks/test-log.md yet"
```
</step>

<step name="3c_check_review_notes">
**Review notes and suggestions**

```bash
echo "=== Review Notes ==="
tail -40 tasks/review-notes.md 2>/dev/null || echo "No tasks/review-notes.md yet"
```
</step>

<step name="4_check_git">
**Recent commits**

```bash
echo "=== Recent Commits ==="
git log --oneline -10

echo ""
echo "=== Current Branch ==="
git branch --show-current
```
</step>

<step name="5_next_actions">
**Suggest next steps**

Based on status:
- If all done: "All stories complete! Review the implementation and consider opening a PR."
- If some failed with attempts remaining: "Would you like to continue Ralph execution? Some stories can be retried."
- If exhausted stories exist: "Some stories exceeded maxAttempts. Review their lastAttemptLog and consider revising the stories or acceptance criteria."
- If blocked stories exist: "Some stories are blocked. Check their blockedBy dependencies."
- If no prd.json: "No tasks/prd.json found. Start with full pipeline or from-prd workflow."
</step>

</process>

<success_criteria>
- [ ] Status displayed with full detail (status, attempts, blockers)
- [ ] Failed/exhausted stories highlighted
- [ ] Next steps suggested based on current state
</success_criteria>
