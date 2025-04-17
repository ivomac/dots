Python conventions:
* Avoid many nested loops, use itertools.product and similar instead.
* Avoid many nested if-elif-else statements, use dictionaries instead.
* Avoid many nested built-in types, use namedtuples, classes, and dataclasses instead.
* NEVER use map and filter, use list comprehensions instead.
* Prefer list comprehensions over for loops.
* Prefer f-strings over str.format.
* Write single-line summary docstrings for all files, functions, class attributes, public and dunder methods.
    - Summary line of functions and methods should be in imperative mood. Example:
    ```python
    def circle_area(radius: float) -> float:
        """Compute area of circle."""
    ```

* Use type hints for function arguments and return values.
    - DO NOT type hint a None return value of a function.
    ```python
    def example(name: str): # note no -> None:
        pass
    ```
    - NEVER import typing. Use the built-in types, | for union, or do not type-hint if it is not possible to do it without typing.

