import os
import pdb
import subprocess

from sub.ovfpy_macro.RunOVF import TwoMeshNoBlockers

current_file = os.path.dirname(__file__)

# --------------- SCRIPT PARAMETERS --------------- #

HOTSHOES_PATH = os.path.join(current_file, 'assets\\hot-shoes\\ref-18')
GPHS_PATH = os.path.join(current_file, 'assets\\bricks_individual\\ref-18')
OVFPATH = open('ovf-path.txt').readlines()[0]

# --------------- PROCESS MESHES --------------- #

hotShoes = os.listdir(HOTSHOES_PATH)
gphsBricks = os.listdir(GPHS_PATH)

if not os.path.exists(os.path.join(current_file, 'bricks_to_shoes-out')):
  os.mkdir(os.path.join(current_file, 'bricks_to_shoes-out'))

for hotShoe in hotShoes:
  for brick in gphsBricks:
    process = TwoMeshNoBlockers(os.path.join(GPHS_PATH, brick),
                                os.path.join(HOTSHOES_PATH,hotShoe),
                                os.path.join(current_file, os.path.join('bricks_to_shoes-out', brick[:-4] + '--' + hotShoe.replace('.stl','.txt'))),
                                os.path.join(current_file, os.path.join('bricks_to_shoes-out', brick[:-4] + '--' + hotShoe.replace('.stl','.vtk'))))