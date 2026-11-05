# Pull Requests

Purpose: reusable guidance for the text an agent posts to a pull request (or
merge request): review comments, replies to review feedback, and the
description.

## Trigger semantics

Read and apply this document when:
- posting review findings to a pull request or merge request
- drafting review comments for the user to approve before posting
- drafting or posting a reply to review feedback on a pull request, for
  example a summary of what was addressed and what wasn't
- drafting, writing, or editing a pull request's description

## Any text posted to a pull request

- Show the full text and wait for approval before posting; posting is
  outward-facing.
- On GitHub, `#` followed by a number links to that issue or pull request, and
  `@name` notifies that user. Write `#N` only for a real issue or pull
  request. Label numbered findings or items "Finding 2", or put the number in
  a code span, including when referring to another review's numbering. Put a
  role or placeholder such as `@reviewer` in a code span. Before posting, scan
  the draft for `#` followed by a digit, and for `@`.
- After posting, read the text back and confirm it landed as approved.

## Reviewing

### Verifying findings

- Treat findings from automated or delegated review as candidates. Check each
  against the code at the PR head before drafting, and correct or narrow the
  wording where the code disagrees, telling the user what changed.
- Before claiming a file, test, or symbol is missing, check the PR's earlier
  pushes too; after a force-push, existing review comments' original commit IDs
  still identify them.
- When a finding's impact depends on deployment facts the repository does not
  show (replica counts, engine versions, traffic), state the assumption and ask
  the user. Re-rate or drop the finding based on the answer.

### Severity

Lead each comment with `**Severity: <level>.**` and present drafts most severe
first:

- High: likely outage, data loss, or security breach; blocks merge.
- Medium: fix before merge or soon after.
- Low: worth fixing; limited impact or unlikely trigger.
- Nit: optional, including best-practice notes for conditions that don't exist
  yet.

### Anchoring

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

### Posting a review

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
- Immediately before posting, confirm the PR head is still the reviewed
  commit; if it moved, re-verify the findings first.
- After posting, read the comments back and confirm each landed on the
  intended line. On GitHub, read anchors from the PR's review-comments
  listing; a single review's comments endpoint omits line fields.

## Replying to review feedback

- Refer to each item by the review's own label, for example "Finding 2" for
  the second row of its findings table, so the reviewer can match each answer
  to an item.
- Say what was addressed, with the commits that address it, and what wasn't,
  each with a brief reason. Don't describe a partial response as complete.
- Explain, in a few words, any reference the reviewer can't resolve from the
  pull request alone, such as an earlier pull request's decision.

## Descriptions

- When editing a description, start from the current text on the host, not a
  local draft, so changes made there (for example added screenshots) are kept.
- Paste logs and command output in fenced blocks, with terminal colour codes
  and carriage returns removed.
- For a stacked pull request, say which pull request it stacks on and which
  branch it targets, and that it moves to the default branch once that one
  merges.
- When the agent bootstrap enables a separate context system with its own
  rule for description links (for example Branch Context's first-line link),
  follow that rule.
