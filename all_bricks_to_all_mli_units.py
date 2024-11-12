import os
import pdb
import subprocess

from sub.ovfpy_macro.RunOVF import *

current_file = os.path.dirname(__file__)

# --------------- SCRIPT PARAMETERS --------------- #

HOTSHOES_PATH = os.path.join(current_file, 'assets\\hot-shoes\\ref-2')
GPHS_PATH = os.path.join(current_file, 'assets\\bricks_individual\\ref-18')
MLI_PATH = os.path.join(current_file, 'assets\\mli\\ref-18')
OVFPATH = open('ovf-path.txt').readlines()[0]

# --------------- PROCESS MESHES --------------- #

hotShoes = os.path.join(HOTSHOES_PATH, 'all_shoes-ref-2.stl')
mli_units = os.listdir(MLI_PATH)
gphsBricks = os.listdir(GPHS_PATH)


if not os.path.exists(os.path.join(current_file, 'bricks_to_mli-out')):
  os.mkdir(os.path.join(current_file, 'bricks_to_mli-out'))

for mli in mli_units:
  for brick in gphsBricks:
    process = TwoMeshOneBlocker(os.path.join(GPHS_PATH, brick),
                                os.path.join(MLI_PATH,mli),
                                hotShoes,
                                os.path.join(current_file, os.path.join('bricks_to_mli-out', brick[:-4] + '--' + mli.replace('.stl','.txt'))),
                                os.path.join(current_file, os.path.join('bricks_to_mli-out', brick[:-4] + '--' + mli.replace('.stl','.vtk'))))