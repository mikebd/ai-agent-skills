# PR Review Comments

Purpose: reusable guidance for posting code-review findings to a pull request
(or merge request) as review comments.

## Trigger semantics

Read and apply this document when:
- posting review findings to a pull request or merge request
- drafting review comments for the user to approve before posting

## Anchoring

Anchor each finding as precisely as the host allows, in this order:

1. A changed line in the PR diff, using a multi-line range when the finding
   spans several lines. Choose the line that introduces or most directly
   embodies the problem.
2. An unchanged context line inside a diff hunk, only when that line is the
   real subject and no changed line fits.
3. A file-level comment on the PR file the finding most concerns.
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
- Before posting, drop findings the PR description already acknowledges, or
  mention them briefly in the summary.
- Show the full comment text and wait for approval before posting; posting is
  outward-facing.
- After posting, read the comments back and confirm each landed on the
  intended line.
