---
name: writing-commit-messages
description: Use when creating a git commit, writing a commit message, or preparing a squash-merge message
---

# Writing Commit Messages

## Overview

In a mostly monolithic codebase shared by multiple teams, commit history is read by people outside the original author's team, often long after the change was made, and is critical during incidents. Write every message with that audience in mind.

Once a PR is merged, commits are squashed into one. Treat that final squash message as permanent project history and make it count.

## Workflow

1. Review the full diff. Identify the key modifications, enhancements, or fixes — note critical details and possible mistakes.
2. Only change code if it's required for functionality or to fix mistakes; don't refactor or polish surrounding code.
3. For logically distinct changes within the same PR, use separate commits to keep them isolated and easier to review.
4. Write the message following the rules below.

## Title (first line)

- Around 50 characters
- Imperative mood: "Fix bug", not "Fixed bug" or "Fixes bug"
- Concise, descriptive, capitalized
- Examples: `Add new feature`, `Correct a bug`, `Improve build system performance`

## Body

- Write in paragraph form, not bullet points
- Wrap lines at 72 characters
- Explain WHAT changed and WHY — focus on motivation and context, not implementation details
- Separate paragraphs with blank lines
- Add a body whenever the reason or impact isn't obvious from the title; ask "would this make sense to someone six months from now?"

## General Rules

- Don't add `Co-authored-by`
- Don't copy-paste from the Linear ticket. The ticket describes the problem; the commit explains how it was solved.
- Describe overall impact and motivation in prose
- Be direct and to the point

## Example

```
Capitalized, short (50 chars or less) summary

More detailed explanatory text, if necessary.  Wrap it to about 72
characters or so.  In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body.  The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Write your commit message in the imperative: "Fix bug" and not "Fixed bug"
or "Fixes bug."  This convention matches up with commit messages generated
by commands like git merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Typically a hyphen or asterisk is used for the bullet, followed by a
  single space, with blank lines in between, but conventions vary here
- Use a hanging indent
```
