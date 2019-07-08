from abaqus import *
from abaqusConstants import *
from caeModules import *

o1 = session.openOdb(name='./crane.odb')
session.viewports['Viewport: 1'].setValues(displayedObject=o1)
odbName=session.viewports[session.currentViewportName].odbDisplay.name
session.odbData[odbName].setValues(activeFrames=(('Step-2', ('0:-1', )), ))
odb = session.odbs['./crane.odb']
session.xyDataListFromField(odb=odb, outputPosition=NODAL, variable=(('U', 
    NODAL, ((INVARIANT, 'Magnitude'), )), ), nodeSets=('PART-1-1.TIP', ))
xy1 = session.xyDataObjects['U:Magnitude PI: PART-1-1 N: 104']
session.writeXYReport(fileName='results.txt', xyData=(xy1, ))

