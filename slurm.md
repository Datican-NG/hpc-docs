# Slurm and Computing Clusters

## Table of contents

- [Slurm and Computing Clusters](#slurm-and-computing-clusters)
  - [Table of contents](#table-of-contents)
  - [Using this document](#using-this-document)
  - [Introduction](#introduction)
  - [Part I: Prerequisites](#part-i-prerequisites)
  - [Part II: Configure OpenSSH](#part-ii-configure-openssh)
    - [Step I: Enable OpenSSH (Windows users only)](#step-i-enable-openssh-windows-users-only)
    - [Step 2: Configure SSH](#step-2-configure-ssh)
  - [Part III: Connecting to the cluster](#part-iii-connecting-to-the-cluster)
    - [The Cluster](#the-cluster)
    - [Step 2: Slurm](#step-2-slurm)
  - [Part IV: Set up VSCode](#part-iv-set-up-vscode)
    - [Step 1: Connect to the login node with VSCode](#step-1-connect-to-the-login-node-with-vscode)
    - [Step 2: Connect to a compute node with VSCode](#step-2-connect-to-a-compute-node-with-vscode)
  - [Part III: SSH keys](#part-iii-ssh-keys)
    - [Step 1: Create SSH keys](#step-1-create-ssh-keys)
    - [Step 2: Enable SSH key authentication](#step-2-enable-ssh-key-authentication)
      - [Enabling keys for the cluster](#enabling-keys-for-the-cluster)
        - [For Mac/Linux:](#for-maclinux)
        - [For Windows:](#for-windows)
      - [Enabling keys for GitHub](#enabling-keys-for-github)
  - [Part VI: Install Conda for environment management](#part-vi-install-conda-for-environment-management)
  - [Troubleshooting](#troubleshooting)
    - [Common Errors](#common-errors)
    - [Troubleshooting Tests](#troubleshooting-tests)
  - [Appendix](#appendix)
    - [WSL](#wsl)
  - [Acknowledgements](#acknowledgements)

## Using this document

If you encounter issues, check the [Troubleshooting](#troubleshooting) section.

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
- UChicago VPN enabled (follow instructions [here](https://uchicago.service-now.com/it?id=kb_article&kb=KB06000719))
 
## Part II: Configure OpenSSH

### Step I: Enable OpenSSH (Windows users only)

If you are using Windows 10 or 11, you can use OpenSSH like Mac and Linux users. If you use WSL2, please see [specific instructions](#wsl). To ensure it is set up correctly:
1. Open Manage Optional Features from the Start Menu and ensure Open SSH Client enabled. If not, you should be able to add it.
2. Open Services from the start Menu, scroll down to OpenSSH Authentication Agent > right click > properties, and set Startup type to Automatic.
3. Open Command Prompt and type `where ssh` to confirm that the top listed path is in System32. Mine is installed at `C:\Windows\System32\OpenSSH\ssh.exe`. If it's not in the list you may need to close and reopen Command Prompt.
4. Verify `ssh` command works in Command Prompt.

### Step 2: Configure SSH

1. Create or modify your SSH config file:
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

### The Cluster

1. Connect to the cluster using `ssh randi.cri.uchicago.edu`.
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
4. Run `srun -p gpuq -t 640:00 --cpus-per-task 4 --pty /bin/bash` to request a compute node. 
5. Your terminal is now connected to the compute node. Type `exit` to end your job or run `scancel JOB_ID` to cancel it.

## Part IV: Set up VSCode

VSCode is a code editor with useful extensions. `Remote - SSH` allows you to open a connection to a remote machine in VSCode.

### Step 1: Connect to the login node with VSCode

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
3. Open the Command Palette (Ctrl+Shift+P or View -> Command Palette) and select `Remote-SSH: Connect to Host...`. Choose `randi`.
4. Once connected, you can open your project folder and use VSCode normally. The bottom-left corner green box will show `SSH: randi` to indicate you are connected.

### Step 2: Connect to a compute node with VSCode
If you are doing any heavy computation in a Jupyter notebook, connect your entire VSCode session to a compute node as follows.

1. In a terminal (Mac/Linux) or Command Prompt (Windows), `ssh randi` to connect to the cluster login node. 
2. Request a compute node, e.g. `srun -p gpuq -t 640:00 --cpus-per-task 4 --pty /bin/bash`. Your prompt will change to `USERNAME@hostname` upon success.
3. In VSCode, open the Command Palette, search for `Remote-SSH: Connect to Host...`, and enter `HOSTNAME.ds` replacing `HOSTNAME` from step 2.
4. VSCode is now connected to the compute node. Open your repository folder to use `randi` compute power with VSCode features.

## Part III: SSH keys

### Step 1: Create SSH keys

1. In your local terminal (or Command Prompt on Windows), run `ssh-keygen -t ed25519` to generate an SSH key pair. Do not set a password when prompted. 
2. Two files will be created: `KEYNAME` (private key) and `KEYNAME.pub` (public key). Never share your private key.
3. Add the private key to ssh-agent with `ssh-add PATH_TO_KEYNAME`.
4. Verify the key was added with `ssh-add -l`.

### Step 2: Enable SSH key authentication 

#### Enabling keys for the cluster

##### For Mac/Linux:
1. Run `ssh-copy-id -i ~/.ssh/KEYNAME.pub randi` to copy your public key to the cluster. Enter your CNET password when prompted.
2. Verify by running `ssh randi`. You should connect without a password.

##### For Windows:
1. Connect to the cluster with `ssh randi` and enter your CNET password. 
2. Run `mkdir .ssh` to ensure the `.ssh` directory exists.
3. Add your public key to authorized keys with `echo "PUBLIC_KEY_HERE" >> .ssh/authorized_keys` (maintain the quotes).
4. Type `exit` to disconnect from the cluster.
5. Verify by running `ssh randi`. You should connect without a password.

#### Enabling keys for GitHub
1. Print your public key:
    - **Windows**: In Command Prompt, run `type C:\Users\USERNAME\.ssh\KEYNAME.pub`
    - **Mac/Linux**: In Terminal, run `cat ~/.ssh/KEYNAME.pub`

2. Copy the entire output.
3. Add the public key to your GitHub account at https://github.com/settings/keys. Click 'New SSH key'. Give it a name relating to the machine it is storeed on, like 'randi' and paste in the full contents of the public key.
4.  Verify GitHub authentication by running `ssh git@github.com`. You should see a greeting message.


## Part VI: Install Conda for environment management
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

### Troubleshooting Tests

Whenever an error comes up, think about all the potential points of failure. Then try to isolate each and see if they work on their own. For example if you are trying to connect to a compute node with VS code using the steps in these instructions, potential points of failure are: VSCode `Remote - SSH` extension, VSCode, your internet connection, ssh config file, ssh keys, slurm, the cluster. Below find some methods to check if different components are working correctly.

Test: run `ssh randi` locally
<br>Expected Result: successful connection to login node.

Test: run `ssh -v randi` locally for verbose output (add up to 3 v's for more verbosity). 
<br>Expected Result: Close to the start, you should see something like: 
```
debug1: Reading configuration data /home/USERNAME/.ssh/config
debug1: /home/USERNAME/.ssh/config line 20: Applying options for fe.ds*
debug1: /home/USERNAME/.ssh/config line 26: Skipping Host block because of negated match for fe.ds
```
where `USERNAME` is your username on your computer. Check that the path after `Reading configuration data` is to the config file you expect and that the right Host blocks are being used. Further down you should see something like: 
```
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Offering public key: /home/USERNAME/.ssh/id_ed25519 ED25519 SHA256:asdkfh298r9283hkdsjfn23rhdf9284 explicit agent
debug1: Server accepts key: /home/USERNAME/.ssh/id_ed25519 ED25519 SHA256:a;sldfkj2oiefjowihoweflkdfjslfkjksld0923 explicit agent
debug1: Authentication succeeded (publickey).
```

Test: run `ssh-add -l` locally
<br>Expected Result: You should see something like `256 SHA256:<a bunch of characters> USERNAME@HOSTNAME (KEY_TYPE)`. If you see `The agent has no identities`, you must `ssh-add PATH_TO_KEY`.

Test: run `ssh-add -l` on a login node
<br>Expected Result: You should see something like `256 SHA256:<a bunch of characters> USERNAME@HOSTNAME (KEY_TYPE)`. If you see `The agent has no identities`, you must `ssh-add PATH_TO_KEY`.

Test: run `ssh git@github.com` locally and on a login node to test GitHub ssh keys
<br>Expected Result: `Hi GITHUB_USERNAME! You've successfully authenticated, but GitHub does not provide shell access.`

Test: request compute node and `ssh COMPUTE_NODE.ds` where `COMPUTE_NODE` is the node name (like `g004`)
<br>Expected Result: connection to the compute node

## Appendix
### WSL

Using WSL2 on Windows is a great way to have access to a linux system on a Windows OS. The convience of 'pretending' to have two separate operating systems on one, however, can lead to complications. One is with SSH keys. The `.ssh` directory used on your normal Windows system and your WSL will be different from each other. This is fine in most cases, but can lead to headaches when using VSCode. If you wish to connect to a remote SSH machine in VS code, it will use your Windows configuration. So even if you only use WSL2 and the VSCode extension (WSL) to code in WSL2, you must follw the [Windows ssh instructions](#windows-specific-instructions). If you wish use the same keys on each system, you can copy them. See [this article](https://devblogs.microsoft.com/commandline/sharing-ssh-keys-between-windows-and-wsl-2/) for more information.

## Acknowledgements

This document is based on the excellent tutorial [here](https://github.com/dsi-clinic/the-clinic/blob/main/tutorials/slurm.md).
