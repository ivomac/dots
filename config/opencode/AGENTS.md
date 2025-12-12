# HOLD YOUR HORSES

* NEVER start with the answer.
* You are biasing yourself to give an explanation in its favor after.
* Your answer is never final, you can always iterate on it.

# BE SKEPTICAL

* Deconstruct any statement you make.
* Check it logically against what you know and have seen.
* If there are inconsistencies, point them out.
* State sources, or WHERE you would expect to find the information.

# TASK TRACKING

* When asked to do complex stuff, break it down into manageable pieces.
* Use the TODO list extensively.
* If at any moment it's helpful to have my input, STOP and ASK.

# CODING

* USE built-in tools like itertools, functools, collections, if appropriate.
* AVOID many nested loops, if statements, and types.
  - Consider itertools or function calls...
* AVOID many nested if-elif-else statements.
  - Consider early returns, dictionary lookups, Enum matching...
* AVOID nested objects.
  - Consider decoupled dictionaries, namedtuples, classes, dataclasses, Enums instead...
* AVOID inheritance like the plague (except for built-in or standard tool types).
* WRITE purposeful functions. Functions don't need to be small.
* IMPLEMENT from higher to lower levels for more complex tasks:
  - Write a draft first with NotImplemented/pass/TODO functions/methods/segments of code.
  - Review your draft and iterate on it if needed. Implement after.
* ONCE you have a working implementation, revisit it critically. Consider cleaning/refactoring.

# ONE WAY OF DOING THINGS

* NEVER use map and filter, use comprehensions instead.
* ONLY use lambda for short in-line functions.
* USE comprehensions for very simple transformations.
* USE loops for complex transformations.
* USE pathlib over os.
* PREFER f-strings over str.format.

# ANNOTATIONS

* AVOID comments. Code should be self-explanatory.
* IF you write a TODO, use the format:
  - # TODO(ivo): ...
* USE type hints for all function arguments and return values.
* NEVER type hint a None return value of a function
* NEVER import Dict, Set, List, Union, Optional, from typing, use the built-ins.

# DOCSTRINGS

* DEFAULT: ONLY write a single text-line docstring.
* Write full docstrings ONLY for complex functions.
* Use google-style.
* Cover all files, functions, class attributes, public and dunder methods.
* Class docstrings should include a description of the class, its attributes, public and dunder methods.
* Multi-line docstring summary line should start at the second line.
* Summary line of functions and methods should be in imperative mood.

# STRUCTURE

```
project/
├── src/
│   ├── mod1/
│   ├── mod2/
│   └── mod3/
├── tests/
└── pyproject.toml
```

# RECOMMENDED TOOLS

* uv
* ruff
* mypy
* unittest/pytest
  - Coverage
* pre-commit
