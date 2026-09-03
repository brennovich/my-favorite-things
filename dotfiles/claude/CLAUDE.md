# General coding instructions

- Don't add comments to the code unless they are necessary for understanding. Most of the time, the code should be self-explanatory, function names and variable names should be descriptive enough.
- Use test-driven development (TDD) approach:
  - Write a failing test first.
  - Write the minimum code to make the test pass.
  - Refactor the code if necessary, ensuring that all tests still pass.
  - After finishing the implementation, remember that tests can also be refactored, so look to duplicated/overlapping tests. and make sure the test code is also clean and maintainable.
- If you're unsure about any aspect or if the implementation/instructions lacks necessary information, say "I don't have enough information to confidently assess or implement this."
- Don't add comments to tests.
- Don't be chatty, I don't need to be encouraged, I want good and verified answers that goes direct to the point. When improving text, make sure to keep the tone unless asked not to, and don't sound like AI.
- Don't change surrounding code, don't get distracted with refactoring or improving the code that is not part of the task. Focus on the task at hand.
- Make only the changes I explicitly asked for. If you spot an adjacent improvement (renaming, tightening locks, restructuring helpers), list it as a suggestion instead of applying it.
- Never state that behavior is unchanged, that a bug is real, or that an event is emitted without citing file:line evidence from the current code. Run the relevant specs.

## Code comments

- Comment only what the code cannot say by itself: why a workaround exists, how an external system actually behaves, what breaks if the code is removed. If the comment restates the code, delete it.
- Write literally. Describe what happens, not what it evokes. Avoid anthropomorphism, metaphor and drama:
  - "the window answers with an error" -> "the call returns an error"
  - "nothing would ever say so" -> "no notification is delivered"
  - "the moments to cast the net are the ones where a corpse is about to cost something" -> "done when a stale entry is about to matter"
- Use short common words and plain verbs (returns, reports, drops, removes, exists). Keep the same term for the same thing throughout a file.
- One fact per sentence. Cut build-up, restatement and hedges ("at all", "for the moment", "possibly", "whatever it was").
- Prefer the shortest phrasing that keeps the fact:
  - "a read taken mid animation answers where it was rather than where it now is" -> "a read mid animation returns the old position"
  - "`as? T` would answer yes to anything" -> "`as? T` succeeds for any type"
- Be specific instead of gesturing at something. If a value is inferred or a rule is approximate, state how: "the API does not report membership, so it is inferred from two items sharing an owner and a position".

## Testing

- Pin a rule where it is implemented. A layer above gets one test per entry point showing it delegates, plus tests for its own guards only.
- Before writing a test, read the tests of the types the code calls. If one already pins the rule, do not pin it again through the caller.
- Two entry points sharing one helper get one copy of its tests, plus one test showing the second path applies it.
- When extracting a layer, move its tests down and delete the pass-through tests above it in the same commit.
- Name tests by the rule, not by the entry point.
- Every assertion must be able to fail. Name the production line that would fail it; if the fixture or a fallback makes it pass anyway, fix the fixture. When pinning existing behaviour, break that line once and watch the test fail.
- Do not test states production cannot reach. Find the production path to the state before building it by hand.
- Stubs answer the way the real dependency does, failure modes included.
- In a table test, every row takes a distinct path. Drop rows whose assertions are a subset of another's.
- Do not assert defaults the fixture sets, preconditions another test pins, or call counts and order no behaviour depends on.

## Global memory

- Durable analysis docs that shouldn't live in the repo (refactor backlogs, review findings, exploration notes) go to `~/code/memory/<repo-basename>/` as markdown files. Check that folder for existing docs before re-exploring a topic. Only write docs into the repo's own docs/ when explicitly asked.

## Language-specific instructions

### Golang

- Use `go fmt` to format the code.
- Writing tests look for opportunities to use table testing, think on this opportunities and migrate the tests to this approach. Of course, not all of them will fit, then is fine for them to stay in the single function style.
- Don't use `interface{}` unless absolutely necessary. Prefer concrete types.
- Prefer error concrete type. Rely on errors.New("some error") to define the Errors and fmt.Error to test them.
- Don't define examples in the documentation, in Golang we have the example tests that are live documentation.
- Don't use t.Skip(), during implementation with TDD, it's ok to have failing tests until the implementation is done, but don't skip them.
- Don't explicitly fail the test, write an assertion that will fail naturally instead.
- Everytime that fetching a library from github.com/motain make sure to use the GOPRIVATE environment variable `GOPRIVATE=github.com/motain/*` to avoid issues with private repositories.

### Ruby

- Follow TDD: write or update the spec first, watch it fail, then implement.
- Run `bundle exec rubocop <changed files>` and the affected specs before every commit (only if rubocop is setup in the worktree)

### Rails

- Always make sure to have `db/schema.rb` changes when adding new migrations.
- Fetch-and-lock must be atomic and id-based (`Model.lock.find(id)`), never find-then-lock.

### Makefile

- Use tabs for indentation.
- Use idiomatic Makefile conventions, like file targets and variables.
- Don't comment tasks.

### Markdown

- Don't break lines in the middle of sentences, let the text wrap naturally.
- Always make tables fully spaced and aligned, even if it means adding extra spaces to the cells.

## Tool Specific Instructions

### Git

- Never run `git checkout -- .`, `git reset --hard`, or `git stash` to 'verify' state. Use `git diff`, `git status`, or a scratch copy instead.

### Github Actions

- Make sure to use the latest stable versions of actions.
- Use `id`s to name steps. Skip `name`.
- Add line break between jobs, but keep the steps of a job together.
