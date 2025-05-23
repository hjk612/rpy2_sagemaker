## Installation 🚀

Follow these steps to install R, rpy2, and necessary dependencies in your SageMaker environment:

1.  **Open Terminal**:
    In your SageMaker Jupyter or JupyterLab environment, open a terminal window.

2.  **Create Bash Script**:
    Create a new script file named `install_r_rpy2.sh` using vim (or your preferred editor):
    ```bash
    vim install_r_rpy2.sh
    ```

3.  **Edit Script**:
    * Press `i` to enter insert mode in vim.
    * Paste the contents from `install_r_rpy2.sh`.
    * Press `Esc`, then type `:x` and press Enter to save and exit.

4.  **Make Script Executable**:
    ```bash
    chmod +x install_r_rpy2.sh
    ```

5.  **Run Script**:
    ```bash
    ./install_r_rpy2.sh
    ```

6.  **Initialize Environment**:
    After the script completes, open a Jupyter notebook and run the following in a cell:
    ```python
    %run ~/setup_r2py.py
    ```

7.  **Done!** 🎉
    You should now be able to use R from within your Python notebook using rpy2. The included notebook also contains a simple matching example and helper functions to install R packages directly from the notebook.
