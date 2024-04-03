# Slurm and Computing Clusters

## Table of contents

- [Slurm and Computing Clusters](#slurm-and-computing-clusters)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Part I: Prerequisites](#part-i-prerequisites)
  - [Part II:](#part-ii)
    - [Step I: Enable OpenSSH (Windows users only)](#step-i-enable-openssh-windows-users-only)
    - [Step 2: Create SSH keys](#step-2-create-ssh-keys)
    - [Step 3: Enable SSH key authentication on the cluster](#step-3-enable-ssh-key-authentication-on-the-cluster)
      - [For Mac/Linux:](#for-maclinux)
      - [For Windows:](#for-windows)
    - [Step 4: Configure SSH](#step-4-configure-ssh)
  - [Part III: Connecting to the cluster](#part-iii-connecting-to-the-cluster)
    - [Step I: The cluster](#step-i-the-cluster)
    - [Step 2: Slurm](#step-2-slurm)
  - [Part IV: Set up VSCode](#part-iv-set-up-vscode)
    - [Step 1: Prerequisites](#step-1-prerequisites)
    - [Step 2: Connect to the login node with VSCode](#step-2-connect-to-the-login-node-with-vscode)
    - [Step 3: Connect to a compute node with VSCode](#step-3-connect-to-a-compute-node-with-vscode)
  - [Part V: Enable SSH keys for GitHub (optional, but strongly recommended)](#part-v-enable-ssh-keys-for-github-optional-but-strongly-recommended)
    - [Step 1:](#step-1)
    - [Step 2:](#step-2)
  - [Part VI: Install Conda for environment management (optional, but strongly recommended)](#part-vi-install-conda-for-environment-management-optional-but-strongly-recommended)
  - [Troubleshooting](#troubleshooting)
    - [Common Errors](#common-errors)
  - [Appendix](#appendix)
    - [WSL](#wsl)
  - [Acknowledgements](#acknowledgements)

## Introduction

Research institutions often use computing clusters for resource-intensive tasks. A computing cluster is a collection of computers (nodes) accessed remotely via [ssh](https://en.wikipedia.org/wiki/Secure_Shell) by logging into the head node.

If you have an account you can use `ssh username_here@address_of_machine` to connect and authenticate with a password or private [key](https://en.wikipedia.org/wiki/Public-key_cryptography). Upon successful authentication, your command prompt will change to show the username and hostname of the machine's login node (e.g., `username@cri22in00n` for the randi cluster, where n is a digit)-- this is [fully customizable](https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt/). 

The login node should only be used for low-computation tasks like file management, writing code, runnning simple programs, and plotting, as everyone shares the same login nodes. Running complex programs will slow it down for everyone.

We will use a VSCode extension to connect your VSCode window to the cluster, allowing you to use its features and extensions.

## Part I: Prerequisites

This guide is tailored to the University of Chicago's `randi` cluster but should be generally applicable to most slurm clusters. It assumes you have:

- An HPC account
- A computer running Windows, Mac, or Linux
- An internet connection
- VSCode
- A GitHub account
- UChicago VPN enabled (follow instructions [here](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000719) for Windows and [here](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000725) for MacOS)
 
## Part II: 

### Step I: Enable OpenSSH (Windows users only)

If you are using Windows 10 or 11, you can use OpenSSH like Mac and Linux users. If you use WSL2, please see [specific instructions](#wsl). To ensure it is set up correctly:
1. Open Manage Optional Features from the Start Menu and ensure Open SSH Client enabled. If not, you should be able to add it.
2. Open Services from the start Menu, scroll down to OpenSSH Authentication Agent > right click > properties, and set Startup type to Automatic.
3. Open Command Prompt and type `where ssh` to confirm that the top listed path is in System32. Mine is installed at `C:\Windows\System32\OpenSSH\ssh.exe`. If it's not in the list you may need to close and reopen Command Prompt.
4. Verify `ssh` command works in Command Prompt.

### Step 2: Create SSH keys

1. In your local terminal (or Command Prompt on Windows), run `ssh-keygen -t ed25519` to generate an SSH key pair. Press enter to use the default suggested location for storing the keys. Press enter when prompted for an optional password (this skips adding a password-- the key is already secure without one). 
2. Two files will be created: `KEYNAME` (private key) and `KEYNAME.pub` (public key). Never share your private key.
3. Add the private key to ssh-agent with `ssh-add PATH_TO_KEYNAME`.
4. Verify the key was added with `ssh-add -l`.

### Step 3: Enable SSH key authentication on the cluster
1. In Command Prompt (windows) or terminal (Mac/Linux) on your local machine, run `ssh YOUR-CNET-ID@randi.cri.uchicago.edu "mkdir -p ~/.ssh && chmod 700 ~/.ssh"`

#### For Mac/Linux:
1. From your local machine, run `ssh-copy-id -i ~/.ssh/KEYNAME.pub randi.cri.uchicago.edu` to copy your public key to the cluster. Enter your CNET password when prompted.
2. Verify by running `ssh randi.cri.uchicago.edu`. You should connect without a password.

#### For Windows:
1. Print your public key: on your local machine, in Command Prompt, run `type C:\Users\USERNAME\.ssh\KEYNAME.pub`
1. Connect to the cluster with `ssh randi.cri.uchicago.edu` and enter your CNET password. 
2. Run `mkdir .ssh` to ensure the `.ssh` directory exists.
3. Add your public key to authorized keys with `echo "PUBLIC_KEY_HERE" >> .ssh/authorized_keys` (maintain the quotes).
4. Type `exit` to disconnect from the cluster.
5. Verify by running `ssh randi.cri.uchicago.edu`. You should connect without a password.


### Step 4: Configure SSH

1. Create or modify your SSH config file on your local machine:
   - **Windows**: In Command Prompt, run `code C:\Users\USERNAME\.ssh\config` 
   - **Mac**: In Terminal, run `touch ~/.ssh/config` to create the file and `open ~/.ssh/config` to open it
   - **Linux**: In Terminal, run `code ~/.ssh/config`
2. Add the following to your config file, replacing `YOUR_CNET_ID` and `PATH_TO_PRIVATE_KEY`:

```
Host randi
  HostName randi.cri.uchicago.edu
  IdentityFile INSERT_PATH_TO_PRIVATE_KEY
  ForwardAgent yes
  User INSERT_YOUR_CNET_ID

Host cri22cn*
  IdentityFile INSERT_PATH_TO_PRIVATE_KEY
  ForwardAgent yes
  ProxyJump randi
  User INSERT_YOUR_CNET
```

## Part III: Connecting to the cluster
Any time you connect to the cluster, you need to have the UChicago VPN enabled (follow instructions [here](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000719) for Windows and [here](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000725) for MacOS)

### Step I: The cluster

1. Connect to the cluster using `ssh randi`.
2. Run `ls /` to view the root directory. This system is shared by many users and may be spread across many physical machines.
3. Run `ls /gpfs/data` to view shared project directories (labshares) for storing large data. 
   - On `randi`, the University of Chicago Center for Research Informatics HPC, each home directory has a usage quota of 10 GB. If you reach the limit, you will no longer be able to edit files until you've deleted something. 
   - Data should be stored in the DATICAN project directory (also called a labshare), located at `/gpfs/data/datican-lab/`. The DATICAN labshare has a 4 TB quota, which can be expanded if needed. All DATICAN users have access to the DATICAN labshare.
4. Run `htop` to see resource usage on the login node. Be courteous as intensive processes can slow it down for everyone. Press q to exit.
 
### Step 2: Slurm

When you want to run an intensive job, use a compute node. These are powerful computers with GPUs, CPUs, and/or lots of memory. Slurm manages a queue system to fairly share them among users. 

1. Run `sinfo` to see available nodes on the cluster. 
2. Run `squeue` to see the state of the queue.
3. To submit an interactive job request, use `srun` with options like:
    - `-t` or time. The duration of the allocation (e.g., `-t 240:00` for 240 minutes). 
    - `--mem` or memory. The amount of RAM in KB or GB (e.g., `--mem 16G` for 16 gigabytes).
    - `-p` or partition. Use `gpuq` for interactive jobs with GPUs. 
    - `--gres` for gpus (e.g., `--gres=gpu:1` for a single gpu).
    - `--pty` to attach in a pseudoterminal.
4. Run `srun -p gpuq -t 640:00 --cpus-per-task 4 --gres=gpu:1 --pty /bin/bash` to request a compute node. 
5. Your terminal is now connected to the compute node. Type `exit` to end your job or run `scancel JOB_ID` to cancel it.

## Part IV: Set up VSCode

VSCode is a code editor with useful extensions. `Remote - SSH` allows you to open a connection to a remote machine in VSCode.

### Step 1: Prerequisites

1. Install the `Remote - SSH` extension in VSCode.

2. (optional but strongly recommended) Add useful extensions to always be installed in remote connections. Open the command palette (ctrl+shift+p / command+shift+p / View -> Command Palette...) and search for `Open User Settings`. If it is empty, paste:
```
{
    "remote.SSH.defaultExtensions": [
        "ms-toolsai.jupyter",
        "ms-toolsai.jupyter-renderers",
        "ms-python.python",
        "ms-python.vscode-pylance"
    ]
}
```
otherwise, make sure to add a comma to the end of the current last item and add the following before the `}`:
```
    "remote.SSH.defaultExtensions": [
        "ms-toolsai.jupyter",
        "ms-toolsai.jupyter-renderers",
        "ms-python.python",
        "ms-python.vscode-pylance"
    ]
```

### Step 2: Connect to the login node with VSCode

1. Click the green box in the lower left corner of VSCode. This opens the command palette. Select `Connect to Host`. Select `randi`.
2. Once connected, you can open your project folder and use VSCode normally. The bottom-left corner green box will show `SSH: randi` to indicate you are connected.

### Step 3: Connect to a compute node with VSCode
VSCode will automatically run Jupyter notebooks for you when you open them for editing. If you are doing any heavy computation in a Jupyter notebook, connect your entire VSCode session to a compute node as follows.

1. In a terminal (Mac/Linux) or Command Prompt (Windows), `ssh randi` to connect to the cluster login node. 
2. Request a compute node, e.g. `srun -p gpuq -t 640:00 --cpus-per-task 4 --pty /bin/bash`. Your prompt will change to `USERNAME@hostname` upon success.
3. Click the green box in the lower left corner of VSCode. This opens the command palette. Select `Connect to Host`. Enter `HOSTNAME`, replacing `HOSTNAME` from step 2.

VSCode is now connected to the compute node. Open your repository folder to use `randi` compute power with VSCode features.

## Part V: Enable SSH keys for GitHub (optional, but strongly recommended)
### Step 1:
Repeat [Step 2: Create SSH keys](#step-2-create-ssh-keys), except this time create the keys on `randi` instead of your local machine.

### Step 2: 
1. Print your public key: in the terminal on `randi`, run `cat ~/.ssh/KEYNAME.pub`.
2. Copy the entire output.
3. Add the public key to your GitHub account at https://github.com/settings/keys. Click 'New SSH key'. Give it a name relating to the machine it is stored on, like 'randi' and paste in the full contents of the public key.
4.  Verify GitHub authentication by running `ssh git@github.com`. You should see a greeting message.


## Part VI: Install Conda for environment management (optional, but strongly recommended)
Conda is a package and environment management system that allows you to create isolated environments with specific package versions, making it easy to manage dependencies and reproduce results across different systems.

1. Connect to cluster
2. In a terminal on the cluster:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh
```
You can accept the defaults. Make sure you select yes when it asks to run conda init. This will ensure conda is activated by default. Re-open and close your terminal.

3. Create a new environment
```bash
conda create --name PROJECT_NAME python=3.9
conda activate PROJECT_NAME
```
Where `PROJECT_NAME` is the name of the project you are working on. Now when you log into `randi`, just make sure you run `conda activate PROJECT_NAME`.

4. Ensure VSCode uses the correct python environment. When a python file is open and selected, click the Python version number on the bottom right and select the interpreter for PROJECT_NAME. If it is not listed, the path is: `/home/USERNAME/miniconda3/envs/PROJECT_NAME/bin/python` where `USERNAME` is your CNET ID. 

5. Install `ipykernel` in the `PROJECT_NAME` environment:
```bash
conda install -n PROJECT_NAME ipykernel --update-deps --force-reinstall
```
6. In an open notebook, select the kernel for PROJECT_NAME. Refresh available kernels if needed.

You can now connect to `randi` with VSCode, use jupyter notebooks, and attach to compute nodes for more intensive jobs.


## Troubleshooting

### Common Errors

Error: `CUDA out of memory`
<br>Cause: The GPU you were using ran out of RAM.
<br>Solution: Could be difficult to solve completely, but there are few things that usually work:
 - Easy: Simple refactoring. Use less GPU by reducing batch sizes, for example. 
 - Harder: Major refactoring of your code to use less memory. Share your code with chatGPT or ClaudeAI and ask for advice on reducing your memory consumption.

Error: `Killed` or `Out of Memory` on compute node
<br>Cause: Most likely, you ran out of CPU memory
<br>Solution: Request more memory! Use the `--mem` flag on `srun`

Error: `Disk quota exceeded`
<br>Symptom: VS code fails to connect to login node
<br>Cause: Each home directory has a quota of disk storage space (10 GB) and you are above it.
<br>Solution: You need to move or delete some files. If you are working on a project with a `/net/projects/` directory, move any data files or checkpoints into that directory (and update your code accordingly!). To check you disk usage, run `du -sh ~`

Error: `git@github.com: Permission denied (publickey). fatal: Could not read from remote repository.`
<br>Cause: GitHub can not access a private key that matches the public key stored on GitHub.
<br>Solution: If you are on the cluster, make sure that you are forwarding your ssh agent. `ssh-add -l` should return the appropriate key. If no identities are found, your ssh-agent has no identities or is not being forwarded. If `ssh-add -l` locally also returns no identities, you must run `ssh-add PATH_TO_KEY` as specified in Part II, [Step 2](#step-2-create--manage-ssh-keys). If the correct identity is found locally, make sure your ssh config matches the one in this document. Finally make sure you have added the appropriate public key to your GitHub account.

## Appendix
### WSL

Using WSL2 on Windows is a great way to have access to a linux system on a Windows OS. The convience of 'pretending' to have two separate operating systems on one, however, can lead to complications. One is with SSH keys. The `.ssh` directory used on your normal Windows system and your WSL will be different from each other. This is fine in most cases, but can lead to headaches when using VSCode. If you wish to connect to a remote SSH machine in VS code, it will use your Windows configuration. So even if you only use WSL2 and the VSCode extension (WSL) to code in WSL2, you must follw the [Windows ssh instructions](#windows-specific-instructions). If you wish use the same keys on each system, you can copy them. See [this article](https://devblogs.microsoft.com/commandline/sharing-ssh-keys-between-windows-and-wsl-2/) for more information.

## Acknowledgements

This document is adapted from the excellent tutorial [here](https://github.com/dsi-clinic/the-clinic/blob/main/tutorials/slurm.md).
