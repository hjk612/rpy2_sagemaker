#!/bin/bash
# Turnkey R and rpy2 Installation Script for SageMaker
# Usage: bash install_r_rpy2.sh
# Author: Hatim Kagalwala (hatim.kagalwala@gmail.com)
# Description: Installs R and rpy2 using conda for reliable integration

set -e

echo "======================================================="
echo "       R and rpy2 Installation for SageMaker"
echo "======================================================="

# Create a log file
LOG_FILE="$HOME/r_rpy2_install_log.txt"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Installation started at: $(date)"
echo "Installing in directory: $HOME"

# Install Miniconda if not already present
if [ ! -d "$HOME/miniconda3" ]; then
    echo "Step 1: Installing Miniconda..."
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
    rm Miniconda3-latest-Linux-x86_64.sh
else
    echo "Step 1: Miniconda already installed."
fi

# Set up conda in this shell
echo "Step 2: Setting up conda environment..."
source $HOME/miniconda3/bin/activate

# Add conda to bashrc if not already there
if ! grep -q "miniconda3/bin/activate" $HOME/.bashrc; then
    echo 'source $HOME/miniconda3/bin/activate' >> $HOME/.bashrc
    echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> $HOME/.bashrc
fi

# Create a conda environment with R and rpy2
echo "Step 3: Creating conda environment with R and rpy2..."
conda create -y -n r_env python=3.8 || echo "Environment may already exist, continuing..."
conda activate r_env

echo "Step 4: Installing R and rpy2 packages..."
conda install -y -c conda-forge r-base=4.2 rpy2

echo "Step 5: Creating helper scripts for notebooks..."

# Create a helper script for SageMaker notebooks
cat > $HOME/setup_rpy2.py << 'EOFSETUP'
#!/usr/bin/env python
"""
R and rpy2 setup script for SageMaker notebooks
Usage: %run ~/setup_rpy2.py
"""
import os
import sys
import subprocess
import warnings

print("Setting up R and rpy2 environment...")

# Function to run shell commands and return output
def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True).strip()
    except:
        return None

# Add conda environment to sys.path if needed
conda_path = os.path.expanduser('~/miniconda3/envs/r_env/lib/python3.8/site-packages')
if os.path.exists(conda_path) and conda_path not in sys.path:
    sys.path.insert(0, conda_path)
    print(f"Added conda environment to Python path: {conda_path}")

# Set R_HOME from conda environment
r_home = run_cmd('~/miniconda3/envs/r_env/bin/R RHOME')
if r_home:
    os.environ['R_HOME'] = r_home
    print(f"Set R_HOME to {r_home}")
else:
    warnings.warn("Could not determine R_HOME. R might not be properly installed.")
    r_home = os.path.expanduser('~/miniconda3/envs/r_env/lib/R')
    os.environ['R_HOME'] = r_home
    print(f"Falling back to {r_home}")

# Set R executable in PATH
r_bin_dir = os.path.join(os.path.dirname(r_home), 'bin')
if os.path.exists(r_bin_dir):
    os.environ['PATH'] = f"{r_bin_dir}:{os.environ.get('PATH', '')}"
    print(f"Added R to PATH: {r_bin_dir}")

# Try importing rpy2
try:
    import rpy2
    print(f"rpy2 version: {rpy2.__version__}")
    
    import rpy2.robjects as ro
    print("Successfully imported rpy2.robjects")
    
    # Basic test
    result = ro.r('1+1')
    print(f"Basic R test: 1+1 = {result[0]}")
    
    print("\nR and rpy2 setup successful!")
    print("\nExample usage:")
    print("import rpy2.robjects as ro")
    print("from rpy2.robjects.packages import importr")
    print("from rpy2.robjects import pandas2ri")
    print("pandas2ri.activate()")  # For pandas integration
    print("result = ro.r('rnorm(10)')")
    print("print(result)")
    
    # Test pandas integration
    try:
        from rpy2.robjects import pandas2ri
        pandas2ri.activate()
        print("\nPandas integration activated successfully!")
    except:
        print("\nPandas integration not available.")
        
except Exception as e:
    print(f"\nError setting up rpy2: {e}")
    print("\nTroubleshooting steps:")
    print("1. Make sure conda environment is activated: conda activate r_env")
    print("2. Verify R is installed: ~/miniconda3/envs/r_env/bin/R --version")
    print("3. Check if rpy2 is installed: pip list | grep rpy2")
    print("4. Try reinstalling: conda install -y -c conda-forge rpy2")
EOFSETUP

# Create a minimal R test script
cat > $HOME/test_r.py << 'EOFTEST'
#!/usr/bin/env python
"""
Quick test script for R and rpy2
Usage: python ~/test_r.py
"""
import os
import sys

# Add conda environment to path if needed
conda_path = os.path.expanduser('~/miniconda3/envs/r_env/lib/python3.8/site-packages')
if os.path.exists(conda_path) and conda_path not in sys.path:
    sys.path.insert(0, conda_path)

# Try to get R_HOME
r_home = os.path.expanduser('~/miniconda3/envs/r_env/lib/R')
os.environ['R_HOME'] = r_home

try:
    import rpy2.robjects as ro
    result = ro.r('1+1')
    print(f"R test successful! 1+1 = {result[0]}")
    
    # Display R version
    print("\nR version information:")
    print(ro.r('R.version.string')[0])
except Exception as e:
    print(f"Error: {e}")
    print("\nPlease run: conda activate r_env")
EOFTEST

chmod +x $HOME/setup_rpy2.py
chmod +x $HOME/test_r.py

# Create R startup file
mkdir -p $HOME/.R
cat > $HOME/.R/Rprofile.site << 'EOFRPROF'
# Default repository
local({r <- getOption("repos")
      r["CRAN"] <- "https://cloud.r-project.org"
      options(repos=r)})

# Disable interactive install prompts
options(install.packages.check.source = "no")
options(install.packages.compile.from.source = "never")
EOFRPROF

# Create a quick reference guide
cat > $HOME/R_RPY2_GUIDE.md << 'EOFGUIDE'
# R and rpy2 Quick Reference Guide

## Using R and rpy2 in SageMaker Notebooks

### Step 1: Set Up Environment
Add this to the first cell of your notebook:
```python
%run ~/setup_rpy2.py
EOFGUIDE