from odbAccess import *
odb = openOdb(path='./crane.odb')
x=session.XYDataFromHistory(name='Temp-1',odb=odb,outputVariableName='Spatial displacement: U1 at Node 104 in NSET TIP');
x0 = session.xyDataObjects['Temp-1']
session.writeXYReport(fileName='results.txt', xyData=(x0, ), appendMode=0)
