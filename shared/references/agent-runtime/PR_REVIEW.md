# PR Review Comments

Purpose: reusable guidance for posting code-review findings to a pull request
(or merge request) as review comments.

## Trigger semantics

Read and apply this document when:
- posting review findings to a pull request or merge request
- drafting review comments for the user to approve before posting

## Verifying findings

- Treat findings from automated or delegated review as candidates. Check each
  against the code at the PR head before drafting, and correct or narrow the
  wording where the code disagrees, telling the user what changed.
- Before claiming a file, test, or symbol is missing, check the PR's earlier
  pushes too; after a force-push, existing review comments' original commit IDs
  still identify them.
- When a finding's impact depends on deployment facts the repository does not
  show (replica counts, engine versions, traffic), state the assumption and ask
  the user. Re-rate or drop the finding based on the answer.

## Severity

Lead each comment with `**Severity: <level>.**` and present drafts most severe
first:

- High: likely outage, data loss, or security breach; blocks merge.
- Medium: fix before merge or soon after.
- Low: worth fixing; limited impact or unlikely trigger.
- Nit: optional, including best-practice notes for conditions that don't exist
  yet.

## Anchoring

Anchor each finding as precisely as the host allows, in this order:

1. A changed line in the PR diff, using a multi-line range when the finding
   spans several lines. Choose the line that introduces or most directly
   embodies the problem.
2. An unchanged context line inside a diff hunk, only when that line is the
   real subject and no changed line fits.
3. A file-level comment on the PR file the finding most concerns. This
   includes a line outside the diff hunks of a PR file: cite the line in a
   file-level comment on that file, not in the review body.
4. The review's top-level body, only for findings not tied to any file in
   the PR.

When the cause or fix lives in a file outside the PR, still anchor on the
closest PR line or file, and link the outside file with a permalink pinned to
the reviewed commit.

## Posting

- Post findings as one batched review pinned to the reviewed head commit,
  not as separate comments.
- Use a non-blocking comment review unless the user asks to approve or
  request changes.
- Before posting, deduplicate against what is already on the PR: the
  description, and every finding already posted by other reviewers, human or
  automated (for example CodeRabbit), in inline comments, review bodies, and
  resolved or outdated threads. Drop findings already acknowledged or already
  raised, or mention them briefly in the summary. When you have new evidence or
  a materially different severity for an existing finding, reply on its thread
  rather than opening a duplicate. If that thread is resolved and the remaining
  issue sits on different lines, a new comment that links the thread is
  allowed instead.
- When an automated reviewer such as CodeRabbit is active on the PR, end each
  code finding with a request for it to validate the finding, for example
  `@coderabbitai please consider this finding and validate it against the
  current code.` Leave it off documentation findings: those fixed only by
  editing comments or docs, even when the stakes are security or audit.
- Show the full comment text and wait for approval before posting; posting is
  outward-facing.
- Immediately before posting, confirm the PR head is still the reviewed
  commit; if it moved, re-verify the findings first.
- After posting, read the comments back and confirm each landed on the
  intended line. On GitHub, read anchors from the PR's review-comments
  listing; a single review's comments endpoint omits line fields.
