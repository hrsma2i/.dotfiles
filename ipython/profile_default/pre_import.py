%load_ext autoreload
%autoreload 2
# display without print
from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"
# often used packages
import os
import sys
import numpy as np
import pandas as pd
from pathlib import Path
import seaborn as sns
from tqdm._tqdm_notebook import tqdm_notebook as tqdm
import matplotlib.pyplot as plt
%matplotlib inline
plt.rcParams["font.size"] = 12
plt.rcParams["figure.figsize"] = (107)
