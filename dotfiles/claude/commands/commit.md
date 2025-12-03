Assume the reviewer mode from superpower plugin or review agent. Go though the git diff and analyse the changes made.
Identify the key modifications, enhancements, or fixes introduced in the code and look for critical details and possible mistakes.
Make sure to only change if it required for the functionality or to fix mistakes.

Create a Git commit for the current changes making sure to follow:

**Title (first line):**
- Use Conventional Commits format: `type(scope): brief description`
- Keep it concise and descriptive
- It must contain around 50 characters
- Use imperative mood (e.g., "Fix bug" not "Fixed bug" or "Fixes bug")
- Examples: `feat: add new feature`, `fix: correct a bug`, `refactor(schemas): build system performance`

**Body (subsequent paragraphs):**
- Write in paragraph form, not bullet points
- Ensure lines wrap at 72 characters
- Explain WHAT changed and WHY it changed
- Focus on the motivation and context, not the implementation details
- Keep paragraphs concise but descriptive
- Separate paragraphs with blank lines for readability

**General rules:**
- Don't add Co-authored-by
- Do describe the overall impact and motivation in prose
- Be direct and to the point

Here is a self descriptive example commit message following these guidelines:

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
