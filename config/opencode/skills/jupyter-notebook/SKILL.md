---
name: jupyter-notebook
description: Rules and tool usage for working with Jupyter notebooks via Jupytext
---

# Working with Notebooks

- The `.ipynb` is the source of truth. NEVER read or edit it directly.
- The `.py` (Jupytext percent-format mirror) is what you read and edit.
- Cell indices passed to `nb_run` and `nb_outputs` are **0-based, counting ALL cells** (markdown and code), matching the `# %%` markers in the `.py` file.

## Workflow

Use the `bash` tool to call `nb`, a user script available in `PATH`.

- ALWAYS pull before reading or editing a notebook:
```
nb pull /abs/path/to/notebook.ipynb
```

- ALWAYS push after editing the .py mirror:
```
nb push /abs/path/to/notebook.ipynb
```

- ONLY run a notebook if specifically asked by the user:
```
nb run /abs/path/to/notebook.ipynb [first_cell [last_cell]]
```

- ASK the user if the notebook has been recently run before reading outputs:
```
nb output /abs/path/to/notebook.ipynb [first_cell [last_cell]]
```
