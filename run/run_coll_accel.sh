#!/bin/bash
#SBATCH -J OMB_coll_accel
#SBATCH -o OMB_coll_accel-%j.out
#SBATCH -N 4
#SBATCH -C gpu
#SBATCH -q regular
#SBATCH -t 00:05:00
#SBATCH -A nstaff_g
#SBATCH --gpus-per-node=4
#
#The -N option should be updated
#to use the full-system complement of accelerated nodes

#The number of NICs(j)
#should be specified here
j=4 #NICs per node

#The paths to OMB and its collective benchmarks
#should be specified here
OMB_DIR=../libexec/osu-micro-benchmarks
OMB_COLL=${OMB_DIR}/mpi/collective


#Compute the total number of tasks 
#to run on the full system (n_any),
#and the next smaller odd number (n_odd)
N_any=$(( SLURM_JOB_NUM_NODES     ))
n_any=$(( SLURM_JOB_NUM_NODES * j ))
N_odd=$N_any
n_odd=$n_any
if [ $(( n_any % 2 )) -eq 0 ]; then
    n_odd=$(( n_any - 1 ))
    if [ $j -eq 1 ]; then
	N_odd=$n_odd
    fi
fi

echo -n Nodes:$N_any   Tasks:$n_any
srun -N ${N_any} -n ${n_any} --ntasks-per-node=${j} \
     ${OMB_DIR}/get_local_rank  \
     ${OMB_COLL}/osu_allreduce -m 8:8 -d cuda
echo

echo -n Nodes:$N_any   Tasks:$n_any
srun -N ${N_any} -n ${n_any} --ntasks-per-node=${j} \
     ${OMB_DIR}/get_local_rank  \
     ${OMB_COLL}/osu_allreduce -m 26214400:26214400 -d cuda
echo

echo -n Nodes:$N_odd   Tasks:$n_odd
srun -N ${N_odd} -n ${n_odd} --ntasks-per-node=${j} \
     ${OMB_DIR}/get_local_rank \
     ${OMB_COLL}/osu_alltoall -m 1048576:1048576 -d cuda
echo

