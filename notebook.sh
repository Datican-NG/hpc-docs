#!/bin/bash

# Parameters
#SBATCH --cpus-per-task=4
#SBATCH --error=notebook.err
#SBATCH --output=notebook.out
#SBATCH --exclude=''
#SBATCH --gpus-per-node=1
#SBATCH --job-name=notebook
#SBATCH --mem-per-gpu=120000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --open-mode=append
#SBATCH --partition=gpuq
#SBATCH --time=1440

# command
sleep 1000000000