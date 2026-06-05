---
name: python-style
description: Python coding style guidelines - comprehensions, type hints, structure and design patterns
---

## Style

- NEVER use `map`/`filter`: use comprehensions.
- USE comprehensions for simple transformations; loops for complex ones.
- USE `lambda` only for short inline functions (e.g., sort keys). Named functions otherwise.
- USE built-in generics: `list[int]`, `dict[str, int]`, never `List`/`Dict` from `typing`.
- USE `X | Y` over `Union[X, Y]`; `X | None` over `Optional[X]`.
- USE `pathlib` over `os` for file system operations.
- USE f-strings over `str.format`.
- ONLY use ascii characters.
- NEVER call `tight_layout()` for plots.

## Design

- SEPARATE policy from logic, data from behavior, configuration from implementation.
- Favor data-driven solutions: use dicts, mappings, lookup tables over long if/elif chains.
- AVOID deep nesting: prefer early returns, guard clauses, or `match`.
- AVOID nested loops: consider `itertools` or restructuring data.
- AVOID inheritance: use composition and protocols.
- NEVER swallow exceptions silently.
- AVOID comments. At most, explain *why*, never *what*.
- USE module-level constants for application policy; parameters for caller-controlled behavior.
