---
name: python-project
description: Python project tools and structure - uv, ruff, mypy, pytest, pre-commit
---

# Type Hints

- Annotate all function arguments and return types, including `-> None`.
- Use `typing.TypeAlias` for complex type aliases; name them clearly.

# Docstrings

- **Every module, class, public method, and public function** gets a docstring.
- **Default:** one-line summary in imperative mood (`"""Return the parsed config."""`).
- **Complex functions:** Google-style with `Args:`, `Returns:`, `Raises:`.

# Testing

- Write tests in `pytest`.
- **Test behavior, not implementation.**
- **One concept per test.** Name descriptively: `test_returns_empty_list_when_input_is_none`.
- Use `pytest.mark.parametrize` for data-driven cases.

# Structure

```
project/
├── src/
│   ├── mod1/
│   ├── mod2/
│   └── mod3/
├── tests/
├── scripts/
└── pyproject.toml
```

- Use `__main__` files as CLI entry-points. Register them in `pyproject.toml`.

# Toolchain

- `uv`: dependency and environment management
- `ruff`: linting and formatting
- `mypy --strict`: static type checking
- `pytest` + `pytest-cov`: testing and coverage
- `pre-commit`: enforce all of the above on commit

Configure all tools in `pyproject.toml`. Do not use separate config files unless the tool requires it.

