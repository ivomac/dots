# TASK TRACKING

* When asked to do complex stuff, break it down into manageable pieces.
* Write down the steps, use them to guide you as memory.
* IF at any moment it's helpful to have my input, stop and ask.

# HOLD YOUR HORSES

* NEVER start with the answer.
* You are biasing yourself to give an explanation in its favor after.
* Your answer is never final, you can always iterate on it.

# BE SKEPTICAL

* Deconstruct any statement you want to make.
* Check it logically against what you think you know, have seen or said.
* If there are inconsistencies, point them out.
* State sources, or WHERE you would expect to find the information.

# CODING

* USE built-in tools like itertools, functools, collections, if appropriate.
* AVOID many nested loops, if statements, and types.
  - Consider itertools or function calls...
* AVOID many nested if-elif-else statements.
  - Consider early returns, dictionary lookups, Enum matching...
* AVOID nested objects.
  - Consider decoupled dictionaries, namedtuples, classes, dataclasses, Enums instead...
* AVOID inheritance like the plague (except for built-in or standard tool types).
* WRITE purposeful functions.
  - Functions don't need to be small.
  - Aim to do one thing well.
  - If you struggle to name it concisely, it's not focused enough.

# ONE WAY OF DOING THINGS

* NEVER use map and filter, use list comprehensions instead.
* NEVER use lambda, use def instead.
* USE list comprehensions for very simple transformations.
* USE loops for complex transformations.
* USE pathlib over os.
* PREFER f-strings over str.format.
* AVOID try-except blocks without re-raising.

# ANNOTATIONS

* USE comments to explain complex decisions or mark code.
  - Code should be self-explanatory.
* IF you write a TODO, use the format:
  - # TODO(ivo): ...
* USE type hints for all function arguments and return values.
* NEVER type hint a None return value of a function
* NEVER import Dict, Set, List, Union, Optional, from typing, use the built-ins.

## DOCSTRINGS

* DEFAULT: ONLY write a single text-line docstring.
* Write full docstrings ONLY for complex functions.
* Use google-style.
* Cover all files, functions, class attributes, public and dunder methods.
* Class docstrings should include a description of the class, its attributes, public and dunder methods.
* Multi-line docstring summary line should start at the second line.
* Summary line of functions and methods should be in imperative mood.

## STRUCTURE

```
project/
├── src/
│   ├── mod1/
│   ├── mod2/
│   └── mod3/
├── tests/
└── pyproject.toml
```

## Tools

Recommended tools:
* uv
* ruff
* mypy
* pytest
  - Coverage
* pre-commit

