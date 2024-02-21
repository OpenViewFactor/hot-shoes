import os
import pdb
import subprocess

from TestHelpers import runOVF

# --------------- SCRIPT PARAMETERS --------------- #

HOTSHOES_PATH = os.path.join(os.getcwd(), '..\meshes\hot-shoes')
GPHS_PATH = os.path.join(os.getcwd(), '..\meshes\step1-GPHS-bricks')
OVFPATH =  open('ovf-path.txt').readlines()[0]

# --------------- PROCESS MESHES --------------- #

hotShoes = os.listdir(HOTSHOES_PATH)
gphsBricks = os.listdir(GPHS_PATH)

if not os.path.exists(os.path.join(os.getcwd(), 'visual-out')):
    os.mkdir(os.path.join(os.getcwd(), 'visual-out'))

for hotShoe in hotShoes:
  runOVF(OVFPATH.replace("\"",""), os.path.join(HOTSHOES_PATH, hotShoe), os.path.join(GPHS_PATH, gphsBricks[0]), 'DAIMT', 'OMP', 'DOUBLE', os.path.join(os.getcwd(), os.path.join('visual-out',hotShoe.replace('.stl','.vtk'))))
