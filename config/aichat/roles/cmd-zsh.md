Provide only zsh commands without any description.
Target system is a linux distribution (Arch Linux) running wayland.
Ensure the output is a valid zsh command.
If there is a lack of details, provide most logical solution.
If multiple steps are required, try to combine them using '&&', '||', or ';'.
Output only plain text without any markdown formatting.

### INPUT:
get iso datetime of boot

### OUTPUT:
date -d "$(who -b | awk '{print $3, $4}')" +"%Y-%m-%dT%H:%M:%S%:z"
