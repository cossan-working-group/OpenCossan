#
# Getting Started with Abaqus: Interactive Edition
#
# Script for static crane example
#

import string
def GetBlockPosition(modelName, blockPrefix):
    if blockPrefix == '':
        return len(mdb.models[modelName].keywordBlock.sieBlocks)-1
    pos = 0
    for block in mdb.models[modelName].keywordBlock.sieBlocks:
        if string.lower(block[0:len(blockPrefix)])==string.lower(blockPrefix):
            return pos
        pos=pos+1
    return -1

from abaqus import *
from abaqusConstants import *
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from caeModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()
Mdb()

session.viewports['Viewport: 1'].setValues(displayedObject=None)
##
##  Sketch profile of truss
##
p = mdb.models['Model-1'].Part(name='Truss', dimensionality=THREE_D, 
    type=DEFORMABLE_BODY)
p.ReferencePoint(point=(0.0, 0.0, 0.0))

p = mdb.models['Model-1'].parts['Truss']
session.viewports['Viewport: 1'].setValues(displayedObject=p)

d, r = p.datums, p.referencePoints
p.DatumPointByOffset(point=r[1], vector=(0.0, 1.0, 0.0))
p.DatumPointByOffset(point=r[1], vector=(8.0, 1.5, 0.9))
p.DatumPlaneByThreePoints(point1=r[1], point2=d[3], point3=d[2])
p.DatumAxisByPrincipalAxis(principalAxis=YAXIS)

session.viewports['Viewport: 1'].view.fitView()

t = p.MakeSketchTransform(sketchPlane=d[4], sketchUpEdge=d[5], 
    sketchPlaneSide=SIDE1, sketchOrientation=LEFT, origin=(0.0, 0.0, 0.0))
s = mdb.models['Model-1'].ConstrainedSketch(name='__profile__', 
    sheetSize=683.38, gridSpacing=17.08, transform=t)
g, v, d1, c = s.geometry, s.vertices, s.dimensions, s.constraints
s.setPrimaryObject(option=SUPERIMPOSE)
p = mdb.models['Model-1'].parts['Truss']
p.projectReferencesOntoSketch(sketch=s, filter=COPLANAR_EDGES)
session.viewports['Viewport: 1'].view.setValues(nearPlane=648.075, 
    farPlane=719.271, width=13.6266, height=9.28111, cameraPosition=(-71.5628, 
    0.978423, 679.645), cameraTarget=(4.83613, 0.978423, 0.544065))

s.Line(point1=(0.0, 0.0), point2=(8.05046582503149, 1.5))
s.CoincidentConstraint(entity1=v.findAt((0.0, 0.0)), entity2=g.findAt((0.0, 
    0.5)))

s.Line(point1=(8.05046582503149, 1.5), point2=(0.0, 1.0))

s.Line(point1=(0.0, 1.0), point2=(1.59409310185916, 0.297018794285658))
s.CoincidentConstraint(entity1=v.findAt((1.594093, 0.297019)), 
    entity2=g.findAt((4.025233, 0.75)))

s.Line(point1=(1.59409310185916, 0.297018794285658),
    point2=(2.30592731982451, 1.14321701190598))
s.CoincidentConstraint(entity1=v.findAt((2.305927, 1.143217)), 
    entity2=g.findAt((4.025233, 1.25)))

s.Line(point1=(2.30592731982451, 1.14321701190598),
    point2=(3.26033977276254, 0.607481575033539))
s.CoincidentConstraint(entity1=v.findAt((3.26034, 0.607482)),
    entity2=g.findAt((4.025233, 0.75)))

s.Line(point1=(3.26033977276254, 0.607481575033539),
    point2=(4.16525059699136, 1.25869624736747))
s.CoincidentConstraint(entity1=v.findAt((4.165251, 1.258696)), 
    entity2=g.findAt((4.025233, 1.25)))

s.Line(point1=(4.16525059699136, 1.25869624736747),
    point2=(4.95150583156061, 0.922587451305882))
s.CoincidentConstraint(entity1=v.findAt((4.951506, 0.922587)), 
    entity2=g.findAt((4.025233, 0.75)))

s.breakCurve(curve1=g.findAt((4.025233, 0.75)),
    point1=(0.733189206279801, 0.182644009590149),
    curve2=g.findAt((1.95001, 0.720118)),
    point2=(1.62787567272877, 0.433001518249512))

s.breakCurve(curve1=g.findAt((4.822279, 0.898509)),
    point1=(2.34362044857835, 0.415118813514709),
    curve2=g.findAt((2.783134, 0.875349)),
    point2=(3.22040910681461, 0.701241612434387))

s.breakCurve(curve1=g.findAt((5.655403, 1.053741)),
    point1=(4.04351950354929, 0.772772312164307),
    curve2=g.findAt((4.558378, 1.090642)),
    point2=(5.02767302451382, 0.95159912109375))

s.breakCurve(curve1=g.findAt((4.025233, 1.25)),
    point1=(1.55629884485765, 1.09466052055359),
    curve2=g.findAt((1.95001, 0.720118)),
    point2=(2.32572264036564, 1.02312982082367))

s.breakCurve(curve1=g.findAt((5.178197, 1.321609)),
    point1=(3.79300780849022, 1.23772192001343),
    curve2=g.findAt((3.712795, 0.933089)),
    point2=(4.168774592922, 1.18407392501831))

s.VerticalDimension(vertex1=v.findAt((0.0, 1.0)),
    vertex2=v.findAt((0.0, 0.0)), 
    textPoint=(-0.304643334343144, 0.0216999053955078), value=1.0)
s.HorizontalDimension(vertex1=v.findAt((0.0, 0.0)),
    vertex2=v.findAt((8.050466, 1.5)),
    textPoint=(6.26233672422377, -0.443249702453613), value=8.05046582503149)

s.ParallelConstraint(entity1=g.findAt((1.152964, 1.071609)), entity2=g.findAt((
    3.235589, 1.200957)))

s.ParallelConstraint(entity1=g.findAt((3.235589, 1.200957)), entity2=g.findAt((
    6.107858, 1.379348)))

s.ParallelConstraint(entity1=g.findAt((0.797047, 0.148509)), entity2=g.findAt((
    2.427216, 0.45225)))

s.ParallelConstraint(entity1=g.findAt((2.427216, 0.45225)), entity2=g.findAt((
    4.105923, 0.765035)))

s.ParallelConstraint(entity1=g.findAt((4.105923, 0.765035)), entity2=g.findAt((
    6.500986, 1.211294)))

s.EqualLengthConstraint(entity1=g.findAt((0.797047, 0.148509)), 
    entity2=g.findAt((2.427216, 0.45225)))

s.EqualLengthConstraint(entity1=g.findAt((2.39114, 0.445528)), 
    entity2=g.findAt((4.033769, 0.751591)))

s.EqualLengthConstraint(entity1=g.findAt((3.985233, 0.742547)), 
    entity2=g.findAt((6.416373, 1.195528)))

s.EqualLengthConstraint(entity1=g.findAt((1.152964, 1.071609)), 
    entity2=g.findAt((3.235589, 1.200957)))

s.EqualLengthConstraint(entity1=g.findAt((3.458891, 1.214826)), 
    entity2=g.findAt((6.33116, 1.393217)))

mdb.models['Model-1'].ConstrainedSketch(name='Truss', objectToCopy=s)

p = mdb.models['Model-1'].parts['Truss']
d = p.datums
p.Wire(sketchPlane=d[4], sketchUpEdge=d[5], sketchPlaneSide=SIDE1, 
    sketchOrientation=LEFT, sketch=s)
s.unsetPrimaryObject()
del mdb.models['Model-1'].sketches['__profile__']

session.viewports['Viewport: 1'].view.fitView()

p = mdb.models['Model-1'].parts['Truss']
d, r = p.datums, p.referencePoints
p.DatumPointByOffset(point=d[2], vector=(0.0, 0.0, 2.0))
p.DatumPointByOffset(point=r[1], vector=(0.0, 0.0, 2.0))
p.DatumPointByOffset(point=d[3], vector=(0.0, 0.0, 0.2))
p.DatumPlaneByThreePoints(point1=d[8], point2=d[9], point3=d[7])

t = p.MakeSketchTransform(sketchPlane=d[10], sketchUpEdge=d[5], 
    sketchPlaneSide=SIDE1, sketchOrientation=LEFT, origin=(4.122203, 0.75, 
    1.536252))
s = mdb.models['Model-1'].ConstrainedSketch(name='__profile__', 
    sheetSize=683.38, gridSpacing=17.08, transform=t)
g, v, d, c = s.geometry, s.vertices, s.dimensions, s.constraints
s.setPrimaryObject(option=SUPERIMPOSE)
p.projectReferencesOntoSketch(sketch=s, filter=COPLANAR_EDGES)
s.retrieveSketch(sketch=mdb.models['Model-1'].sketches['Truss'])
s.move(vector=(-4.14820681508444, -0.75), objectList=(g.findAt((0.0, 0.5)), 
    g.findAt((1.006308, 0.6875)), g.findAt((2.348053, 0.770833)), g.findAt((
    3.354361, 0.958333)), g.findAt((4.696105, 1.041667)), g.findAt((5.702413, 
    1.229167)), g.findAt((1.006308, 0.1875)), g.findAt((3.018925, 0.5625)), 
    g.findAt((5.031541, 0.9375)), g.findAt((7.044158, 1.3125)), g.findAt((
    1.341744, 1.083333)), g.findAt((6.708722, 1.416667)), g.findAt((4.025233, 
    1.25)), v.findAt((8.050466, 1.5)), v.findAt((0.0, 1.0))))
d = p.datums
p.Wire(sketchPlane=d[10], sketchUpEdge=d[5], sketchPlaneSide=SIDE1, 
    sketchOrientation=LEFT, sketch=s)
s.unsetPrimaryObject()
del mdb.models['Model-1'].sketches['__profile__']

##
##  dummy part
##
p = mdb.models['Model-1'].Part(name='Truss-all', 
    objectToCopy=mdb.models['Model-1'].parts['Truss'])
session.viewports['Viewport: 1'].setValues(displayedObject=p)
v = p.vertices
p.WirePolyLine(points=((v.findAt(coordinates=(2.0, 0.375, 1.775)), v.findAt(
    coordinates=(2.0, 0.375, 0.225))), (v.findAt(coordinates=(2.0, 0.375, 
    0.225)), v.findAt(coordinates=(2.666667, 1.166667, 1.7))), (v.findAt(
    coordinates=(2.666667, 1.166667, 1.7)), v.findAt(coordinates=(2.666667, 
    1.166667, 0.3))), (v.findAt(coordinates=(4.0, 0.75, 1.55)), v.findAt(
    coordinates=(4.0, 0.75, 0.45))), (v.findAt(coordinates=(4.0, 0.75, 0.45)), 
    v.findAt(coordinates=(5.333333, 1.333333, 1.4))), (v.findAt(coordinates=(
    5.333333, 1.333333, 1.4)), v.findAt(coordinates=(5.333333, 1.333333, 
    0.6))), (v.findAt(coordinates=(5.333333, 1.333333, 0.6)), v.findAt(
    coordinates=(6.0, 1.125, 1.325))), (v.findAt(coordinates=(6.0, 1.125, 
    1.325)), v.findAt(coordinates=(6.0, 1.125, 0.675)))), mergeWire=OFF, 
    meshable=ON)
##
##  create cross brace part in the assembly module
##

a = mdb.models['Model-1'].rootAssembly
session.viewports['Viewport: 1'].setValues(displayedObject=a)
##  Set coordinate system (done by default)
a.DatumCsysByDefault(CARTESIAN)
p = mdb.models['Model-1'].parts['Truss']
a.Instance(name='Truss-1', part=p, dependent=ON)
p = mdb.models['Model-1'].parts['Truss-all']
a.Instance(name='Truss-all-1', part=p, dependent=ON)
a.PartFromBooleanCut(name='Cross brace', 
    instanceToBeCut=a.instances['Truss-all-1'], 
    cuttingInstances=(a.instances['Truss-1'], ))
p = mdb.models['Model-1'].parts['Cross brace']
a.Instance(name='Cross brace-1', part=p, dependent=ON)
a.suppressFeatures(('Truss-1', 'Truss-all-1', ))
a.features['Truss-1'].resume()

p = mdb.models['Model-1'].parts['Cross brace']
session.viewports['Viewport: 1'].setValues(displayedObject=p)
##
##  Create beam profiles and beam sections
##
mdb.models['Model-1'].BoxProfile(name='MainBoxProfile', b=0.05, 
    a=0.1, uniformThickness=ON, t1=0.005)
mdb.models['Model-1'].BoxProfile(name='BraceBoxProfile', b=0.03, 
    a=0.03, uniformThickness=ON, t1=0.003)
mdb.models['Model-1'].BeamSection(name='MainMemberSection', 
    profile='MainBoxProfile', poissonRatio=0.25,
    integration=BEFORE_ANALYSIS, table=((2.e11, 8.e10),))
mdb.models['Model-1'].BeamSection(name='BracingSection', 
    profile='BraceBoxProfile', poissonRatio=0.25,
    integration=BEFORE_ANALYSIS, table=((2.e11, 8.e10),))
##
##  Flip tangent directions
##
p = mdb.models['Model-1'].parts['Truss']
e = p.edges
edges = e
regions = regionToolset.Region(edges=edges)
p.flipTangent(regions=regions)
##
edges = e.findAt(((4.5, 0.84375, 0.50625), ), ((2.5, 0.46875, 0.28125), ), ((
    0.5, 0.09375, 0.05625), ), ((4.5, 0.84375, 1.49375), ), ((2.5, 0.46875, 
    1.71875), ), ((0.5, 0.09375, 1.94375), ))
regions = regionToolset.Region(edges=edges)
p.flipTangent(regions=regions)
##
##  Assign beam sections to the cross brace
##
p = mdb.models['Model-1'].parts['Cross brace']
e = p.edges
edges = e.findAt(((2.666667, 1.166667, 1.35), ),
    ((2.166667, 0.572917, 0.59375), ), ((2.0, 0.375, 1.3875), ),
    ((6.0, 1.125, 1.1625), ), ((5.5, 1.28125, 0.78125), ),
    ((5.333333, 1.333333, 1.2), ), ((4.333333, 0.895833, 0.6875), ),
    ((4.0, 0.75, 1.275), ))
region = regionToolset.Region(edges=edges)
p.SectionAssignment(region=region, sectionName='BracingSection')
##
##  Assign beam sections to the internal bracing
##
p = mdb.models['Model-1'].parts['Truss']
e = p.edges
edges = e.findAt(((3.0, 1.0625, 0.3375), ), ((5.5, 1.28125, 0.61875), ),
    ((4.333333, 0.895833, 0.4875), ), ((0.5, 0.84375, 0.05625), ),
    ((2.166667, 0.572917, 0.24375), ), ((3.0, 1.0625, 1.6625), ),
    ((5.5, 1.28125, 1.38125), ), ((4.333333, 0.895833, 1.5125), ),
    ((0.5, 0.84375, 1.94375), ), ((2.166667, 0.572917, 1.75625), ))
region = regionToolset.Region(edges=edges)
p.SectionAssignment(region=region, sectionName='BracingSection')
##
##  Assign beam sections to the main members
##
p = mdb.models['Model-1'].parts['Truss']
e = p.edges
edges = e.findAt(((4.5, 0.84375, 0.50625), ), ((4.666667, 1.291667, 0.525), ), 
    ((6.5, 1.21875, 0.73125), ), ((7.333333, 1.458333, 0.825), ),
    ((2.5, 0.46875, 0.28125), ), ((2.0, 1.125, 0.225), ),
    ((0.5, 0.09375, 0.05625), ), ((4.5, 0.84375, 1.49375), ),
    ((4.666667, 1.291667, 1.475), ), ((6.5, 1.21875, 1.26875), ),
    ((7.333333, 1.458333, 1.175), ), ((2.5, 0.46875, 1.71875), ),
    ((2.0, 1.125, 1.775), ), ((0.5, 0.09375, 1.94375), ))
region = regionToolset.Region(edges=edges)
p.SectionAssignment(region=region, sectionName='MainMemberSection')
##
##  Assign beam section orientations to truss 'B'
##
p = mdb.models['Model-1'].parts['Truss']
e = p.edges
edges = e.findAt(((4.5, 0.84375, 0.50625), ), ((3.0, 1.0625, 0.3375), ),
    ((4.666667, 1.291667, 0.525), ), ((5.5, 1.28125, 0.61875), ),
    ((6.5, 1.21875, 0.73125), ), ((7.333333, 1.458333, 0.825), ),
    ((4.333333, 0.895833, 0.4875), ), ((2.5, 0.46875, 0.28125), ),
    ((0.5, 0.84375, 0.05625), ), ((2.0, 1.125, 0.225), ),
    ((2.166667, 0.572917, 0.24375), ), ((0.5, 0.09375, 0.05625), ))
region=regionToolset.Region(edges=edges)
p.assignBeamSectionOrientation(region=region, method=N1_COSINES, n1=(-0.1118, 
    0.0, 0.9936))
##
##  Assign beam section orientations to truss 'A'
##
p = mdb.models['Model-1'].parts['Truss']
e = p.edges
edges = e.findAt(((4.5, 0.84375, 1.49375), ), ((3.0, 1.0625, 1.6625), ),
    ((4.666667, 1.291667, 1.475), ), ((5.5, 1.28125, 1.38125), ),
    ((6.5, 1.21875, 1.26875), ), ((7.333333, 1.458333, 1.175), ),
    ((4.333333, 0.895833, 1.5125), ), ((2.5, 0.46875, 1.71875), ),
    ((0.5, 0.84375, 1.94375), ), ((2.0, 1.125, 1.775), ),
    ((2.166667, 0.572917, 1.75625), ), ((0.5, 0.09375, 1.94375), ))
region=regionToolset.Region(edges=edges)
p.assignBeamSectionOrientation(region=region, method=N1_COSINES, n1=(-0.1118, 
    0.0, -0.9936))
##
##  Assign beam section orientations to 'Cross brace'
##
p = mdb.models['Model-1'].parts['Cross brace']
e = p.edges
edges = e.findAt(((2.666667, 1.166667, 1.35), ), ((2.166667, 0.572917, 
    0.59375), ), ((2.0, 0.375, 1.3875), ), ((6.0, 1.125, 1.1625), ), ((5.5, 
    1.28125, 0.78125), ), ((5.333333, 1.333333, 1.2), ), ((4.333333, 0.895833, 
    0.6875), ), ((4.0, 0.75, 1.275), ))
region=regionToolset.Region(edges=edges)
p.assignBeamSectionOrientation(region=region, method=N1_COSINES,
    n1=(0.0, 1.0, 0.0))

session.viewports['Viewport: 1'].setValues(displayedObject=a)
a.regenerate()
##
##
session.viewports['Viewport: 1'].assemblyDisplay.setValues(
    visibleInstances=('Truss-1', 'Cross brace-1'))
session.viewports['Viewport: 1'].assemblyDisplay.geometryOptions.setValues(
    geometryEdgesInShaded=OFF, datumPoints=OFF, datumAxes=OFF, datumPlanes=OFF,
    datumCoordSystems=OFF, referencePointLabels=OFF, referencePointSymbols=OFF)
##
##  Translate the truss
##
p = a.instances['Truss-1']
p.translate(vector=(0.0, -0.5, -1.0))
##
##  Translate the cross brace
##
p = a.instances['Cross brace-1']
p.translate(vector=(0.0, -0.5, -1.0))


##
##  Create geometry sets
##
session.viewports['Viewport: 1'].assemblyDisplay.setValues(
    visibleInstances=('Truss-1', ))
session.viewports['Viewport: 1'].assemblyDisplay.geometryOptions.setValues(
    datumPoints=OFF)

v = a.instances['Truss-1'].vertices
verts = v.findAt(((0.0, 0.5, -1.0), ), ((0.0, -0.5, -1.0), ), ((0.0, 0.5, 
    1.0), ), ((0.0, -0.5, 1.0), ))
a.Set(vertices=verts, name='Attach')

verts = v.findAt(((8.0, 1.0, 0.1), ))
a.Set(vertices=verts, name='Tip-a')

verts = v.findAt(((8.0, 1.0, -0.1), ))
a.Set(vertices=verts, name='Tip-b')

e = a.instances['Truss-1'].edges
edges = e.findAt(((6.5, 0.71875, 0.26875), ))
a.Set(edges=edges, name='Leg-a')

edges = e.findAt(((6.5, 0.71875, -0.26875), ))
a.Set(edges=edges, name='Leg-b')

edges = e.findAt(((4.333333, 0.395833, 0.5125), ))
a.Set(edges=edges, name='Inner-a')

edges = e.findAt(((4.333333, 0.395833, -0.5125), ))
a.Set(edges=edges, name='Inner-b')

session.viewports['Viewport: 1'].assemblyDisplay.setValues(
    visibleInstances=('Cross brace-1', ))
session.viewports['Viewport: 1'].view.setValues(
    cameraPosition=(7.4736, 8.3559, 20.002),
    cameraUpVector=(-0.34023, 0.72044, -0.60432))

session.viewports['Viewport: 1'].assemblyDisplay.setValues(
    visibleInstances=('Truss-1', 'Cross brace-1'))
session.viewports['Viewport: 1'].view.setValues(session.views['Iso'])

##
##  Create a static general step
##
mdb.models['Model-1'].StaticStep(name='Tip load', 
    previous='Initial', description='Static tip load on crane', 
    timePeriod=1, adiabatic=OFF, maxNumInc=100, 
    stabilization=None, timeIncrementationMethod=AUTOMATIC, initialInc=1, 
    minInc=1e-05, maxInc=1, matrixSolver=SOLVER_DEFAULT, amplitude=RAMP, 
    extrapolation=LINEAR, fullyPlastic="")
session.viewports['Viewport: 1'].assemblyDisplay.setValues(step='Tip load')
##
##  Modify output requests
##
mdb.models['Model-1'].fieldOutputRequests['F-Output-1'].setValues(
    variables=('U', 'RF', 'SF'))
mdb.models['Model-1'].historyOutputRequests['H-Output-1'].setValues(
    variables=PRESELECT)

##
##  Create constraints between the tips of the truss
##
session.viewports['Viewport: 1'].assemblyDisplay.setValues(interactions=ON)
mdb.models['Model-1'].Equation(name='TipConstraint-1', 
    terms=((1.0, 'Tip-a', 1), (-1.0, 'Tip-b', 1)))
mdb.models['Model-1'].Constraint('TipConstraint-2', 
    mdb.models['Model-1'].constraints['TipConstraint-1'])
mdb.models['Model-1'].constraints['TipConstraint-2'].setValues(
    terms=((1.0, 'Tip-a', 2), (-1.0, 'Tip-b', 2)))
##
##  Create JOIN connectors between truss and bracing
##

v1 = a.instances['Cross brace-1'].vertices
v2 = a.instances['Truss-1'].vertices

a.WirePolyLine(points=((v1.findAt(coordinates=(2.0, -0.125, 0.775)), v2.findAt(
    coordinates=(2.0, -0.125, 0.775))), (v1.findAt(coordinates=(2.666667, 
    0.666667, 0.7)), v2.findAt(coordinates=(2.666667, 0.666667, 0.7))), (
    v1.findAt(coordinates=(2.0, -0.125, -0.775)), v2.findAt(coordinates=(2.0, 
    -0.125, -0.775))), (v1.findAt(coordinates=(2.666667, 0.666667, -0.7)), 
    v2.findAt(coordinates=(2.666667, 0.666667, -0.7))), (v1.findAt(
    coordinates=(4.0, 0.25, -0.55)), v2.findAt(coordinates=(4.0, 0.25, 
    -0.55))), (v1.findAt(coordinates=(4.0, 0.25, 0.55)), v2.findAt(
    coordinates=(4.0, 0.25, 0.55))), (v1.findAt(coordinates=(5.333333, 
    0.833333, 0.4)), v2.findAt(coordinates=(5.333333, 0.833333, 0.4))), (
    v1.findAt(coordinates=(5.333333, 0.833333, -0.4)), v2.findAt(coordinates=(
    5.333333, 0.833333, -0.4))), (v1.findAt(coordinates=(6.0, 0.625, -0.325)), 
    v2.findAt(coordinates=(6.0, 0.625, -0.325))), (v1.findAt(coordinates=(6.0, 
    0.625, 0.325)), v2.findAt(coordinates=(6.0, 0.625, 0.325)))), 
    mergeWire=OFF, meshable=OFF)

e1 = a.edges
edges1 = e1.findAt(((6.000025, 0.625, 0.325), ), ((6.000025, 0.625, -0.325), ), 
    ((5.333358, 0.833333, -0.4), ), ((5.333358, 0.833333, 0.4), ), ((4.000025, 
    0.25, 0.55), ), ((4.000025, 0.25, -0.55), ), ((2.666692, 0.666667, -0.7), 
    ), ((2.000025, -0.125, -0.775), ), ((2.666692, 0.666667, 0.7), ), ((
    2.000025, -0.125, 0.775), ))
a.Set(edges=edges1, name='Wire-1-Edge-1')

mdb.models['Model-1'].ConnectorSection(name='ConnSect-1', 
    translationalType=JOIN)

region=a.sets['Wire-1-Edge-1']
a.SectionAssignment(sectionName='ConnSect-1', region=region)

session.viewports['Viewport: 1'].assemblyDisplay.setValues(loads=ON, bcs=ON,
    predefinedFields=ON, interactions=OFF)
##
##  Apply encastre bc to set 'Attach'
##
region = a.sets['Attach']
mdb.models['Model-1'].EncastreBC(name='Fixed end', createStepName='Tip load', 
    region=region)
##
##  Apply concentrated force to set 'Tip-b'
##
region = a.sets['Tip-b']
mdb.models['Model-1'].ConcentratedForce(name='Tip load', 
    createStepName='Tip load', region=region, cf2=-10000.0)
##
##  Assign global seed
##
p = mdb.models['Model-1'].parts['Truss']
p.seedPart(size=2.0)
p = mdb.models['Model-1'].parts['Cross brace']
p.seedPart(size=2.0)
##
##  Assign element type
##
elemType1 = mesh.ElemType(elemCode=B33)

p = mdb.models['Model-1'].parts['Cross brace']
e = p.edges
edges = e
pickedRegions =(edges, )
p.setElementType(regions=pickedRegions, elemTypes=(elemType1, ))

p = mdb.models['Model-1'].parts['Truss']
e = p.edges
edges = e
pickedRegions =(edges, )
p.setElementType(regions=pickedRegions, elemTypes=(elemType1, ))
##
##  Generate mesh
##
p = mdb.models['Model-1'].parts['Truss']
p.generateMesh()
p = mdb.models['Model-1'].parts['Cross brace']
p.generateMesh()

##
##  Add keywords
##
mdb.models['Model-1'].keywordBlock.synchVersions()
mdb.models['Model-1'].keywordBlock.insert(GetBlockPosition('Model-1', '*End Assembly')-1, """*NORMAL, TYPE=ELEMENT
Inner-a,  Inner-a, -0.3962,  0.9171,  0.0446
Inner-b,  Inner-b,  0.3962, -0.9171,  0.0446
Leg-a,    Leg-a,   -0.1820,  0.9829,  0.0205
Leg-b,    Leg-b,    0.1820, -0.9829,  0.0205""")
##
##  Create job
##
mdb.Job(name='Crane', model='Model-1', 
    description='3-D model of light-service cargo crane')

a.regenerate()
session.viewports['Viewport: 1'].setValues(displayedObject=a)
##
##  Save model database
##
mdb.saveAs('Crane.cae')

