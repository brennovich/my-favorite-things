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
