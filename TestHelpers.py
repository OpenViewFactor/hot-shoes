import os, subprocess
import xml.etree.ElementTree as ET

def PercentDiff(result, expected):
    percentDifference = (result - expected) / expected * 100
    return(percentDifference)

def ValidateNear(result, expected, tolerance):
    percentDifference = PercentDiff(result, expected)
    if abs(percentDifference) > tolerance:
        return False
    else:
        return True
    
def XMLParse(root, testName, testOutputsDir):
    INFORMATION = root.findall('TEST-DESCRIPTION')
    CONFIG = INFORMATION[0][0].text

    TARGETS = root.findall('TARGETS')
    ANALYTIC = float(TARGETS[0][0].text)
    EXPECTED = float(TARGETS[0][1].text)
    TOLERANCE = float(TARGETS[0][2].text)

    NUMERICS = [ANALYTIC, EXPECTED, TOLERANCE]
    
    MESHES = root.findall('MESHES')
    EMITTER = MESHES[0][0].text
    RECEIVER = MESHES[0][1].text
    BLOCKERS = MESHES[0][2:]

    SURFACES = [EMITTER, RECEIVER]
    
    SETTINGS = root.findall('SETTINGS')
    SELFINT = SETTINGS[0][0].text
    METHOD = SETTINGS[0][1].text
    PRECISION = SETTINGS[0][2].text

    ARGS = [SELFINT, METHOD, PRECISION]

    data = [NUMERICS, SURFACES, ARGS]
    return data, BLOCKERS

def runCmd(ovfExecutable, ARGUMENTS, BLOCKERS, COMPUTE, outputPath):
    breakpoint()
    if BLOCKERS[0].text == 'NONE':
        proc = subprocess.run([ovfExecutable, '-i' , ARGUMENTS[1][0], ARGUMENTS[1][1], '-s', ARGUMENTS[2][0], '-m', ARGUMENTS[2][1], '-c', COMPUTE, '-p', ARGUMENTS[2][2]], stdout = subprocess.PIPE, text=True)
    else:
        blockerArg = ''.join([(blocker.text + ' ') for blocker in BLOCKERS])
        proc = subprocess.run([ovfExecutable, '-i' ,ARGUMENTS[1][0], ARGUMENTS[1][1], '-b', blockerArg,'-s', ARGUMENTS[2][0], '-m', ARGUMENTS[2][1], '-c', COMPUTE, '-p', ARGUMENTS[2][2]], stdout = subprocess.PIPE, text=True)
    testoutput = proc.stdout
    with open(outputPath, 'w') as out:
        out.write(testoutput)

def runOVF(exe, em, re, method, comp, prec, vis):
    proc = subprocess.run([exe, '-i', em, re, '-s', 'NONE', '-m', method, '-c', comp, '-p', prec, '-o', 'NONE', '-g', vis], stdout = subprocess.PIPE, text=True)
    procoutput = proc.stdout
    with open(vis.replace('.vtk','.txt'), 'w') as out:
        out.write(procoutput)

def logStart(testLog, message):
    testLog.write(''.join(['\n< ----- ', message, ' ----- >']))
    # print(''.join(['< ----- ', message, ' ----- >']))

def logUpdate(testLog, message):    
    testLog.write(''.join(['\n',message]))
    # print(message)
    
def logEnd(testLog):
    testLog.write('\n< ----- LOG BREAK ----- >\n')
    # print('< ----- LOG BREAK ----- >')