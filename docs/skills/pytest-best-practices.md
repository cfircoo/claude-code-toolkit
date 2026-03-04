# pytest-best-practices Skill

Expert pytest patterns for writing maintainable, high-quality tests.

## Overview

This skill provides comprehensive guidance on pytest best practices, including fixture design, parametrization, mocking, and advanced patterns.

## When to Use

Use this skill when:
- Writing new test files or test suites
- Improving existing test coverage
- Setting up test fixtures or parametrized tests
- Implementing mocks, stubs, or patches
- Designing test structure for a project

## Key Topics

### Fixtures

Learn about:
- Fixture scope (function, class, module, session)
- Fixture parametrization
- Fixture dependencies
- Fixture cleanup with `yield`
- Indirect parametrization

### Parametrization

Learn about:
- `@pytest.mark.parametrize` syntax
- Multiple parameter sets
- Indirect parametrization
- Dynamic ID generation
- Skip/xfail with parameters

### Mocking

Learn about:
- `unittest.mock.patch` usage
- Mock objects and assertions
- MagicMock for complex scenarios
- Monkeypatch for simple cases
- Spying on function calls

### Patterns

Learn about:
- Project structure best practices
- Conftest.py organization
- Test data management
- Testing async code
- Testing database code with fixtures

## Usage Example

```
> Use the pytest-best-practices skill to add comprehensive tests for src/models/user.py
```

This will:
1. Analyze the code to test
2. Design appropriate test structure
3. Create fixtures for common scenarios
4. Write parametrized tests
5. Include edge cases

## Integration with Agents

The pytest-writer agent uses this skill:
- [pytest-writer](../agents/pytest-writer.md) — Writes high-quality pytest tests

## Integration with Commands

Available as background knowledge for:
- `/db` — Database testing patterns
- Manual test writing

## Best Practices Covered

### Naming
- Test file names: `test_*.py` or `*_test.py`
- Test function names: `test_<feature>_<scenario>`
- Fixture names: descriptive, lowercase with underscores

### Organization
- One test file per module
- Group related tests with classes
- Use conftest.py for shared fixtures
- Separate fixtures by scope

### Fixtures
- One responsibility per fixture
- Use `autouse=True` sparingly
- Document fixture purpose
- Clean up with `yield` or `finally`

### Parametrization
- Use for testing multiple scenarios
- Keep parameter count reasonable
- Use descriptive IDs
- Group related parameters

### Assertions
- One logical assertion per test
- Use `assert` for clarity
- Use pytest's assertion introspection
- Add helpful assertion messages

### Async Tests
- Use `pytest-asyncio` for async fixtures
- Mark async tests with `@pytest.mark.asyncio`
- Handle event loop properly
- Test concurrent scenarios

## Advanced Topics

### Database Testing
- Using SQLAlchemy with pytest
- Transaction rollback for test isolation
- Fixtures for test data
- Testing migrations

### Mocking External Services
- Mock HTTP requests
- Mock database queries
- Mock file I/O
- Verify call counts and arguments

### Coverage Analysis
- Running with coverage: `pytest --cov`
- Identifying untested code paths
- Setting coverage thresholds
- Excluding code from coverage

## Related Skills

- [sqlalchemy-postgres](sqlalchemy-postgres.md) — Database layer testing
- [debug-like-expert](debug-like-expert.md) — Debugging test failures
- [manage-skills](manage-skills.md) — Creating custom test skills

## Related Agents

- [pytest-writer](../agents/pytest-writer.md) — Automated test generation

## Resources

- [pytest documentation](https://docs.pytest.org/)
- [pytest fixtures](https://docs.pytest.org/en/stable/fixture.html)
- [pytest parametrize](https://docs.pytest.org/en/stable/how-to-parametrize.html)
- [unittest.mock](https://docs.python.org/3/library/unittest.mock.html)
