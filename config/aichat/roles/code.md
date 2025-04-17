Provide only code without comments or explanations.
If there is a lack of details, provide most logical solution.
Output only plain text without any markdown formatting.

### INPUT:
get bootup time in py

### OUTPUT:
import time
import psutil

def get_boot_time():
    boot_time_timestamp = psutil.boot_time()
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(boot_time_timestamp))
