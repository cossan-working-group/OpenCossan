

import math

class XSalomeSession(object):
    def __init__(self):
        import runSalome
        import sys
        sys.argv += ["--show-desktop=0"]
        sys.argv += ["--modules=GEOM,SMESH,MED,HOMARD"]
        clt, d = runSalome.main()
        port = d['port']
        self.port = port
        return
    def __del__(self):
        from os import system
        system('killSalomeWithPort.py %s'%(self.port))
        return
    pass

# --

x_salome_session = XSalomeSession()

# --

from geompy import *




# mesh size (grossly)
mesh_size = 2

height_part = 8 # height of the part, also the length of the flanges
thickness_web=3

# data related to the cylinders used for the bcs
radius_cyl = 5 # cyl right
radius_cyl2 = 12 # cyl left
thick_cyl_2 = 10.5
radius_cyl3 = 10 # cyl bottom
diff_length_cyl_2 =4
diff_length_cyl_2b =4.5
thick_cyl_bc = 15




###################################################################################
### arrays containing the coordinates of the centres and radius of the holes 	###
### /!\ there is no detection of the errors at this level 						###
###################################################################################

Vx = [255.1625  ,   255.1625  ,   255.1625  ]
Vy = [302.5872  ,302.5872  ,302.5872        ]
Vr = [ 15.0000  ,   15.0000,   15.0000   ]


# example of syntax, case with two holes
# Array of the x-coordinate of the respective holes:
#Vx = [76.8567 ,   92.2131  ]
# Array of the y-coordinate of the respective holes:
#Vy = [ 124.1334, 176.9461]
# Array of the radius of the respective holes:
#Vr = [10,23]

###############################################################################
###############################################################################
### GEOMETRY ##################################################################
###############################################################################
###############################################################################

#####################################################################################################################
### creation of the data related to the "base" of the geometry, without any hole ####################################
#####################################################################################################################


Vertex_out_1 = MakeVertex(28.61, 22.65, 0)
p_on_line11_2 = MakeVertex(353.245, 310.245, 0)
p_on_line11_3 = MakeVertex(353.245, 310.245+radius_cyl, 0)

addToStudy( p_on_line11_2, 'p_on_line11_2' )


Line_28 = MakeLineTwoPnt(p_on_line11_3, p_on_line11_2)
Vertex_1 = MakeVertexWithRef(p_on_line11_2, 20, 0, 0)
Axis_revolution = MakeLineTwoPnt(p_on_line11_2, Vertex_1)
Revolution_1 = MakeRevolution(Line_28, Axis_revolution, 180*math.pi/180.0)
Extrusion_2 = MakePrism(Revolution_1, p_on_line11_2, Vertex_1)


addToStudy( Axis_revolution, 'Axis_revolution' )

addToStudy( Extrusion_2, 'Extrusion_2' )





# cylinder in the left
Vertex_cylinedr2_1 = MakeVertex(134.44+diff_length_cyl_2, 310.245, 0)
Vertex_cylinedr2_2 = MakeVertex(134.44+diff_length_cyl_2, 310.245 - radius_cyl2, 0)

Vertex_cylinedr2_3 = MakeVertex(134.44+diff_length_cyl_2, 310.245 -radius_cyl2- thick_cyl_2, 0)



addToStudy( Vertex_cylinedr2_1, 'Vertex_cylinedr2_1' )
addToStudy( Vertex_cylinedr2_2, 'Vertex_cylinedr2_2' )
addToStudy( Vertex_cylinedr2_3, 'Vertex_cylinedr2_3' )




Line_cylinedr2 = MakeLineTwoPnt(Vertex_cylinedr2_1, Vertex_cylinedr2_3)
#addToStudy( Line_cylinedr2, 'Line_cylinedr2' )
Revolution_2 = MakeRevolution(Line_cylinedr2, Axis_revolution, -180*math.pi/180.0)
cylindre_left_full = MakePrismDXDYDZ(Revolution_2, -39.21-diff_length_cyl_2-diff_length_cyl_2b, 0, 0)
#addToStudy( Revolution_2, 'Revolution_2' )
addToStudy( cylindre_left_full, 'cylindre_left_full' )



Line_cylinedr2b = MakeLineTwoPnt(Vertex_cylinedr2_1, Vertex_cylinedr2_2)
#addToStudy( Line_cylinedr2, 'Line_cylinedr2' )
Revolution_2b = MakeRevolution(Line_cylinedr2b, Axis_revolution, -180*math.pi/180.0)
cylindre_left_cutting_tool = MakePrismDXDYDZ(Revolution_2b, -39.21-diff_length_cyl_2-diff_length_cyl_2b, 0, 0)
#addToStudy( Revolution_2, 'Revolution_2' )
addToStudy( cylindre_left_cutting_tool, 'cylindre_left_cutting_tool' )




# female cylinder where the load bc is applied
Vertex_cylinedr3_1 = MakeVertex(45.515, 19.35, 0.)
#addToStudy( Vertex_cylinedr3_1, 'Vertex_cylinedr3_1' )



# create a vector from two points
p0 = MakeVertex(0., 0., 0.)
pz = MakeVertex(0.  , 0.  , 1.)
vz  = MakeVector(p0, pz)
addToStudy( vz, 'vz' )

Circle_1 = MakeCircle(Vertex_cylinedr3_1, vz, thick_cyl_bc+radius_cyl3)
Face_1 = MakeFaceWires([Circle_1], 1)


## removing the hole for bc
Circle_2 = MakeCircle(Vertex_cylinedr3_1, vz, radius_cyl3)
Face_2 = MakeFaceWires([Circle_2], 1)
cylindre_bc_cutting_tool = MakePrismDXDYDZ(Face_2, 0, 0, height_part+5)

addToStudy( cylindre_bc_cutting_tool, 'cylindre_bc_cutting_tool' )

# ok

#####################################################################################################################
### end of creation of the data related to the "base" of the geometry, without any hole   ###########################
#####################################################################################################################


### geometries for the groups of nodes

# create a cylindrical face to define a set of nodes for the embedding bc (right) 
Revolution_for_group_of_nd_1 = MakeRevolution(p_on_line11_3, Axis_revolution, 180*math.pi/180.0)
face_bc_emb = MakePrismDXDYDZ(Revolution_for_group_of_nd_1, 20, 0, 0)
#addToStudy( Revolution_for_group_of_nd_1, 'Revolution_for_group_of_nd_1' )
addToStudy( face_bc_emb, 'face_bc_emb' )





# create a cylindrical face to define a set of nodes for the embedding bc (left) 
Revolution_for_group_of_nd_2 = MakeRevolution(Vertex_cylinedr2_2, Axis_revolution, 180*math.pi/180.0)
face_bc_emb2 = MakePrismDXDYDZ(Revolution_for_group_of_nd_2, -20, 0, 0)
#addToStudy( Revolution_for_group_of_nd_1, 'Revolution_for_group_of_nd_1' )
addToStudy( face_bc_emb2, 'face_bc_emb2' )



# create a cylindrical face to define a set of nodes for the displacement bc
#Circle_2 = MakeCircle(Vertex_cylinedr3_1, vz, radius_cyl)
#Face_2 = MakeFaceWires([Circle_2], 1)
face_bc_displ  = MakePrismDXDYDZ(Circle_2, 0, 0, height_part)
addToStudy( face_bc_displ, 'face_bc_displ' )

#ok
Plane_symmetry = MakePlane(Vertex_out_1, vz, 2000)
addToStudy( Plane_symmetry, 'Plane_symmetry' )



Vertex_Planexbc_1 = MakeVertex(373.2450, 300.2450, 0)
Vertex_Planexbc_2 = MakeVertex(373.2450, 310.245, 0)
Vertex_Planexbc_3 = MakeVertex(373.2450, 310.2450, 10)

Planexbc = MakePlaneThreePnt(Vertex_Planexbc_1, Vertex_Planexbc_2, Vertex_Planexbc_3, 2000)

addToStudy( Planexbc, 'Planexbc' )






####################################################################################################################
### removing ALL the hollow parts (holes)  #########################################################################
####################################################################################################################


Part_wo_hole = ImportFile("./Part_wo_hole.step", "STEP")
Part_w_hole = Part_wo_hole

for i in range(len(Vx)):
	x1 = Vx[i]
	y1 = Vy[i]
	r1 = Vr[i]
	CenterCircle1 = MakeVertex(x1, y1, thickness_web+10.0001)
	#addToStudy( CenterCircle1, 'CenterCircle1' )
	Circle_1_1 = MakeCircle(CenterCircle1, vz, r1)
	Face_1_1 = MakeFaceWires([Circle_1_1], 1)
	Extrusion_1_1 = MakePrismDXDYDZ(Face_1_1, 0, 0, -thickness_web-20)



	Part_w_hole = MakeCut(Part_w_hole, Extrusion_1_1)


####################################################################################################################
### end removing ALL the hollow parts (holes) ######################################################################
####################################################################################################################




addToStudy( Part_w_hole, 'Part_w_hole' )





###############################################################################
###############################################################################
### MESH ######################################################################
###############################################################################
###############################################################################



import smesh, SMESH, SALOMEDS


import StdMeshers
import NETGENPlugin


################################################
####     Meshing the part    ###################
################################################

smeshObj_1 = smesh.CreateHypothesis('NETGEN_Parameters_3D', 'NETGENEngine')
NETGEN_3D_Parameters = smesh.CreateHypothesis('NETGEN_Parameters_3D', 'NETGENEngine')
NETGEN_3D_Parameters.SetMaxSize(mesh_size )
NETGEN_3D_Parameters.SetSecondOrder( 255 )
NETGEN_3D_Parameters.SetOptimize( 1 )
NETGEN_3D_Parameters.SetFineness( 3 )
NETGEN_3D_Parameters.SetMinSize( 0.053447 )
NETGEN_3D_Parameters.SetSecondOrder( 77 )
NETGEN_2D_Parameters = smesh.CreateHypothesis('NETGEN_Parameters_2D_ONLY', 'NETGENEngine')
NETGEN_2D_Parameters.SetMaxSize( mesh_size )
NETGEN_2D_Parameters.SetSecondOrder( 255 )
NETGEN_2D_Parameters.SetOptimize( 1 )
NETGEN_2D_Parameters.SetFineness( 3 )
NETGEN_2D_Parameters.SetMinSize( 0.053447 )
NETGEN_2D_Parameters.SetQuadAllowed( 0 )
NETGEN_2D_Parameters.SetSecondOrder( 77 )
Part_2_hole_1 = smesh.Mesh(Part_w_hole)
Regular_1D = Part_2_hole_1.Segment()
Max_Size_1 = Regular_1D.MaxSize(mesh_size)
status = Part_2_hole_1.AddHypothesis(NETGEN_2D_Parameters)
NETGEN_2D_ONLY = Part_2_hole_1.Triangle(algo=smesh.NETGEN_2D)
status = Part_2_hole_1.AddHypothesis(NETGEN_3D_Parameters)
NETGEN_3D = Part_2_hole_1.Tetrahedron(algo=smesh.NETGEN)
isDone = Part_2_hole_1.Compute()


################################################
#   Creation of the group on nodes/elements    #
################################################


Embeddinf =smesh.GetFilter(SMESH.NODE, smesh.FT_BelongToCylinder, face_bc_emb)
Embeddin = Part_2_hole_1.GroupOnFilter( SMESH.NODE, "Embeddin", Embeddinf )

Embeddinf2 =smesh.GetFilter(SMESH.NODE, smesh.FT_BelongToCylinder, face_bc_emb2)
Embeddi2 = Part_2_hole_1.GroupOnFilter( SMESH.NODE, "Embeddi2", Embeddinf2 )

LoadGrouf =smesh.GetFilter(SMESH.NODE, smesh.FT_BelongToCylinder, face_bc_displ)
LoadGrou = Part_2_hole_1.GroupOnFilter( SMESH.NODE, "LoadGrou", LoadGrouf )


filter_symm =smesh.GetFilter(SMESH.NODE, smesh.FT_BelongToPlane, Plane_symmetry)
Symmetr = Part_2_hole_1.GroupOnFilter( SMESH.NODE, "Symmetr", filter_symm )

filter_Planexbc =smesh.GetFilter(SMESH.NODE, smesh.FT_BelongToPlane, Planexbc)
xbc = Part_2_hole_1.GroupOnFilter( SMESH.NODE, "xbc", filter_Planexbc )


# this group will be used only in code aster, in order to set the load bc
filter_load =smesh.GetFilter(SMESH.FACE, smesh.FT_BelongToCylinder, face_bc_displ)
LoadFa = Part_2_hole_1.GroupOnFilter( SMESH.FACE, "LoadFa", filter_load )

Part_2_hole_1.ExportMED( r'./Part_w_hole.med', 0, SMESH.MED_V2_2, 1 )




###
### HOMARD component
###

"""
Python script for HOMARD
Copyright EDF-R&D 2010
"""
__revision__ = "V1.2"
import HOMARD
homard = lcc.FindOrLoadComponent('FactoryServer','HOMARD')
homard.SetCurrentStudy(myStudy)

Hypo_1 = homard.CreateHypothesis('Hypo_1')
Hypo_1.SetAdapRefinUnRef(0, 1, 0)


for i in range(len(Vx)):
	x1 = Vx[i]
	y1 = Vy[i]
	r1 = Vr[i]
	Zone_2 = homard.CreateZoneCylinder( 'Zone_'+str(i+3), x1, y1, -10, 0, 0, 1, r1+10, 176.364)
	homard.AssociateHypoZone('Zone_'+str(i+3), 'Hypo_1')




Hypo_1.SetTypeFieldInterp(0)
Hypo_1.SetNivMax(10)
Hypo_1.SetDiamMin(0)



from commands import getstatusoutput
aa = getstatusoutput("pwd")
print aa[1]


#
# Creation of the cases
# =====================
# Creation of the case Case_1
Case_1 = homard.CreateCase('Case_1', 'Part_w_hole', aa[1]+'/Part_w_hole.med')
Case_1.SetDirName(aa[1])
Case_1.SetConfType(1)
#
# Creation of the iterations
# ==========================
# Creation of the iteration Iter_1
Iter_1 = homard.CreateIteration('Iter_1', Case_1.GetIter0Name() )
Iter_1.SetMeshName('Part_w_hole2')
Iter_1.SetMeshFile(aa[1]+'/Part_w_hole_ref.med')
homard.AssociateIterHypo('Iter_1', 'Hypo_1')
result = homard.Compute('Iter_1', 1)

# Creation of the iteration Iter_2
#Iter_2 = homard.CreateIteration('Iter_2', 'Iter_1')
#Iter_2.SetMeshName('Part_w_hole_ref')
#Iter_2.SetMeshFile(aa[1]+'/Part_w_hole_ref.med')
#homard.AssociateIterHypo('Iter_2', 'Hypo_1')
#result = homard.Compute('Iter_2', 1)
 



