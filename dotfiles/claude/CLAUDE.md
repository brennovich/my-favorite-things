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

### Makefile

- Use tabs for indentation.
- Use idiomatic Makefile conventions, like file targets and variables.
- Don't comment tasks.

## Tool Specific Instructions

### Github Actions

- Make sure to use the latest stable versions of actions.
- Use `id`s to name steps. Skip `name`.
- Add line break between jobs, but keep the steps of a job together.
