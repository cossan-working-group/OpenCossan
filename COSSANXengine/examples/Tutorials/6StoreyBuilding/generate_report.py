# -*- coding: utf-8 -*-
from abaqus import *
from abaqusConstants import *
session.Viewport(name='Viewport: 1', origin=(0.0, 0.0), width=262.028137207031, 
    height=216.767578125)
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from caeModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()
session.viewports['Viewport: 1'].setValues(displayedObject=None)
o1 = session.openOdb(
    name='Building.odb')
session.viewports['Viewport: 1'].setValues(displayedObject=o1)
odb = session.odbs['Building.odb']
nf = NumberFormat(numDigits=6, precision=0, format=SCIENTIFIC)
session.fieldReportOptions.setValues(printTotal=OFF, printMinMax=OFF, 
    numberFormat=nf)
session.writeFieldReport(fileName='Building.rpt', append=OFF, 
    sortItem='Element Label', odb=odb, step=1, frame=1, 
    outputPosition=ELEMENT_CENTROID, variable=(('S', INTEGRATION_POINT, ((
    INVARIANT, 'Tresca'), )), ))
