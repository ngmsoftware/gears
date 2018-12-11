bl_info = {
    "name": "Gear Pair",
    "author": "allan ninguem",
    "version": (1, 0, 0),
    "blender": (2, 76, 0),
    "location": "View3D > Add > Mesh > Gear Pair",
    "description": "Adds a mesh Pair of Gears to the Add Mesh menu",
    "warning": "",
    "wiki_url": "",
    "tracker_url": "",
    "category": "Add Mesh"}

import os
import bpy
from math import *
from bpy.props import *
from bpy_extras import object_utils

def involute(R1, n_teeth, adendum, slack, dedendum, dt):

    # input:
    #
    # R1 : base radius
    # n_teeth : number of teaath
    # adendum : adendum (percent)
    # slack : spacing between teeth (percent)
    # dedendum : inner radius distance (percent) can be negative
    #
    # Output:
    # [X, Y] : vertices of half involute curve (including adendum and dedendum)
    # teeth_size : depth of the teeth (not including the radius of the gear)


    max_angle = pi/n_teeth

    X = [0]
    Y = [0]

    angle = [0]
    reach = [0]

    i = 0
    t = 0
    while angle[i]<max_angle:
        i = i+1
    
        t = t+dt

        if (angle[i-1]<adendum*max_angle):
            dx_involute = R1*dt*t*cos(t)
            dy_involute = R1*dt*t*sin(t)
        else:
            dx_involute = -(reach[i-1])*dt*sin(angle[i-1])
            dy_involute = (reach[i-1])*dt*cos(angle[i-1])
        
        X.append(X[i-1] + dx_involute)
        Y.append(Y[i-1] + dy_involute)
        
        reach.append(  sqrt(Y[len(Y)-1]*Y[len(Y)-1] + (X[len(X)-1]+R1)*(X[len(X)-1]+R1))  )
        angle.append(  atan2(Y[len(Y)-1],X[len(X)-1]+R1)  )

    for i in range(len(X)):
        if (angle[i]<slack):
            idx = i

    r = R1*(1.0 - dedendum)
    X[idx] = -R1+r*cos(angle[idx])
    Y[idx] = r*sin(angle[idx])

    for i in range(idx-1):
        del(X[0])
        del(Y[0])

    X[0] = -R1+r*cos(angle[0])
    Y[0] = r*sin(angle[0])


    del(X[-1])
    del(Y[-1])

    teeth_size = reach[len(reach)-1]-R1

    return (X, Y, teeth_size)


def gear(R1, n_teeth, adendum, slack, dedendum, dt):

    # input:
    #
    # R1 : base radius
    # n_teeth : number of teaath
    # adendum : adendum (percent)
    # slack : spacing between teeth (percent)
    # dedendum : inner radius distance (percent) can be negative
    #
    # Output:
    # [X, Y] : vertices of the whole teeth curve (external part of the gear)
    # teeth_size : depth of the teeth (not including the radius of the gear)

    [X, Y, teeth_size] = involute(R1,n_teeth, adendum, slack, dedendum, dt)

    do = 2*pi/n_teeth

    X_involute = []
    Y_involute = []

    o = 0
    for i in range(n_teeth):
        R11 = cos(o)
        R12 = -sin(o)
        R21 = sin(o)
        R22 = cos(o)
        
        for j in range(len(X)):
            P1 = R11*X[j] + R12*Y[j]
            P2 = R21*X[j] + R22*Y[j]
            X_ = P1 + R1*cos(o)
            Y_ = P2 + R1*sin(o)
        
            X_involute.append(X_)
            Y_involute.append(Y_)
        
        R11 = cos(o+do)
        R12 = -sin(o+do)
        R21 = sin(o+do)
        R22 = cos(o+do)
        
        for j in range(len(X)-1,-1,-1):
            P1 = R11*X[j] - R12*Y[j]
            P2 = R21*X[j] - R22*Y[j]
            X_ = P1 + R1*cos(o+do)
            Y_ = P2 + R1*sin(o+do)
        
            X_involute.append(X_)
            Y_involute.append(Y_)
        
        o = o + do    

    return (X_involute, Y_involute, teeth_size)





def create_gear(n_teeth_1, R1, adendum, slack, dedendum, inner_radius_first, inner_radius_second, hole_radius, support_angle, dt):

    # input:
    #
    #  a lot of stuff... (all the parameters of the gear)
    #
    # Output:
    #   [face, vert] : vertices and faces ready to form a mesh
    #  

    vert = ((inner_radius_first*R1,0,0), (R1, 0, 0))
    face = ()
 
    (X, Y, teeth_size) = gear(R1, n_teeth_1, adendum, slack, dedendum,  dt)

    i = 2
    for j in range(len(X)):
        i = i+2

        angle = atan2(Y[j],X[j])

        if (abs(angle)<support_angle) or (abs(angle-pi/2)<support_angle) or (abs(angle-pi)<support_angle) or (abs(angle+pi)<support_angle) or (abs(angle+pi/2)<support_angle):
            x1 = inner_radius_second*R1*cos(angle)
            y1 = inner_radius_second*R1*sin(angle)
        else:
            x1 = inner_radius_first*R1*cos(angle)
            y1 = inner_radius_first*R1*sin(angle)

        x2 = X[j]
        y2 = Y[j]

        v1 = (x1, y1, 0)
        v2 = (x2, y2, 0)

        vert = vert + (v1, v2,)
        face = face + ((i-4, i-3, i-1, i-2),)


    for j in range(len(X)):
        i = i+2

        angle = atan2(Y[j],X[j])

        x1 = hole_radius*cos(angle)
        y1 = hole_radius*sin(angle)

        x2 = inner_radius_second*R1*cos(angle)
        y2 = inner_radius_second*R1*sin(angle)

        v1 = (x1, y1, 0)
        v2 = (x2, y2, 0)

        vert = vert + (v1, v2,)
        face = face + ((i-4, i-3, i-1, i-2),)


    return ( vert, face, teeth_size )




def createMeshFromData(context, name, verts, faces):
    
    # Create mesh and object
    #
    #  utility function for creation of a blender object from vertices and faces

    me = bpy.data.meshes.new(name+'Mesh')
    ob = bpy.data.objects.new(name, me)
    ob.location = (0,0,0)
    ob.show_name = True 
    me.from_pydata(verts, [], faces)
    me.update()    

    return object_utils.object_data_add(context, me, operator=None)






class AddGear(bpy.types.Operator):
    """Add a gear pair mesh"""
    bl_idname = "mesh.primitive_gear"
    bl_label = "Add Gear Pair"
    bl_options = {'REGISTER', 'UNDO', 'PRESET'}
    radius_2 = 0.0


    # main class of the addon


    def reset_angle(self, context):
        self.angle = 0

    dt = FloatProperty(name="dt",
        description="integration step size",
        min=0.01,
        max=0.1,
        step=0.001,
        precision=3,
        unit='LENGTH',
        default=0.02)
    angle = FloatProperty(name="angle",
        description="angle",
        min=-pi,
        max=pi,
        precision=3,
        unit='ROTATION',
        default=0.0)
    distance = FloatProperty(name="distance",
        description="distance",
        min=0,
        max=1.0,
        step=0.01,
        precision=3,
        unit='LENGTH',
        default=0.94)

    number_of_teeth_1 = IntProperty(name="# Teeth 1",
        description="# teeth on the first gear",
        min=3,
        max=265,
        default=24,
        update=reset_angle)
    radius_1 = FloatProperty(name="Radius 1",
        description="Radius of the first gear",
        min=1.0,
        max=100.0,
        precision=3,
        unit='LENGTH',
        default=10.0)
    adendum_1 = FloatProperty(name="Adendum 1",
        description="Adendum percentage of the first gear",
        min=0.0,
        max=1.0,
        step=0.01,
        precision=3,
        unit='LENGTH',
        default=0.8)
    slack_1 = FloatProperty(name="Dedendum 1",
        precision=3,
        description="Dedendum percentage of the first gear",
        min=0.0001,
        max=1.0,
        step=0.005,
        unit='LENGTH',
        default=0.02)
    dedendum_1 = FloatProperty(name="Dedendum 1 extra",
        precision=3,
        description="Dedendum extra of first gear",
        min=-0.5,
        max=1.0,
        unit='LENGTH',
        default=-0.03)
    inner_radius_1_first = FloatProperty(name="First inner radius 1",
        precision=3,
        description="First inner radius percentage of the first gear",
        min=0.0,
        max=1.0,
        step=0.005,
        unit='LENGTH',
        default=0.79)
    inner_radius_1_second = FloatProperty(name="Second inner radius 1",
        precision=3,
        description="Second inner radius percentage of the first gear",
        min=0.0,
        max=1.0,
        step=0.005,
        unit='LENGTH',
        default=0.33)
    hole_radius_1 = FloatProperty(name="Hole radius 1",
        precision=3,
        description="Hole radius percentage of the first gear",
        min=0.0,
        max=100,
        step=0.1,
        unit='LENGTH',
        default=1)
    support_angle_1 = FloatProperty(name="Thicness support 1",
        precision=3,
        description="Thicness of the first gear support",
        min=0.0,
        max=pi/4,
        unit='ROTATION',
        default=pi/12)


    number_of_teeth_2 = IntProperty(name="# Teeth 2",
        description="# teeth on the second gear",
        min=3,
        max=265,
        default=12,
        update=reset_angle)
    adendum_2 = FloatProperty(name="Adendum 2",
        precision=3,
        description="Adendum percentage of the second gear",
        min=0.0,
        max=1.0,
        step=0.01,
        unit='LENGTH',
        default=0.8)
    slack_2 = FloatProperty(name="Dedendum 2",
        precision=3,
        description="Dedendum percentage of the second gear",
        min=0.0001,
        max=1.0,
        step=0.005,
        unit='LENGTH',
        default=0.06)
    dedendum_2 = FloatProperty(name="Dedendum 2 extra",
        precision=3,
        description="Dedendum extra of second gear",
        min=-0.5,
        max=1.0,
        unit='LENGTH',
        default=-0.09)
    inner_radius_2_first = FloatProperty(name="First inner radius 2",
        precision=3,
        description="First inner radius percentage of the second gear",
        min=0.0,
        max=1.0,
        step=0.005,
        unit='LENGTH',
        default=0.79)
    inner_radius_2_second = FloatProperty(name="Second inner radius 2",
        precision=3,
        description="Second inner radius percentage of the second gear",
        min=0.0,
        max=1.0,
        step=0.005,
        unit='LENGTH',
        default=0.33)
    hole_radius_2 = FloatProperty(name="Hole radius 2",
        precision=3,
        description="Hole radius percentage of the second gear",
        min=0.0,
        max=100,
        step=0.1,
        unit='LENGTH',
        default=1)
    support_angle_2 = FloatProperty(name="Thicness support 2",
        precision=3,
        description="Thicness of the second gear support",
        min=0.0,
        max=pi/4,
        unit='ROTATION',
        default=pi/10)



    def draw(self, context):
        layout = self.layout

        layout.label('General parameters')
        box = layout.box()
        box.prop(self, 'dt')
        box.prop(self, 'angle')
        box.prop(self, 'distance')

        layout.label('First Gear')
        box = layout.box()
        box.prop(self, 'number_of_teeth_1')
        box.prop(self, 'radius_1')
        box.prop(self, 'adendum_1')
        box.prop(self, 'slack_1')
        box.prop(self, 'dedendum_1')
        box.prop(self, 'inner_radius_1_first')
        box.prop(self, 'inner_radius_1_second')
        box.prop(self, 'hole_radius_1')
        box.prop(self, 'support_angle_1')

        layout.label('Second Gear')
        box = layout.box()
        box.prop(self, 'number_of_teeth_2')
        box.label('radius2 = %.4f'%self.radius_2)
        box.prop(self, 'adendum_2')
        box.prop(self, 'slack_2')
        box.prop(self, 'dedendum_2')
        box.prop(self, 'inner_radius_2_first')
        box.prop(self, 'inner_radius_2_second')
        box.prop(self, 'hole_radius_2')
        box.prop(self, 'support_angle_2')
        


    def execute(self, context):

        dt = self.dt
        angle = self.angle
        distance = self.distance

        n_teeth_1 = self.number_of_teeth_1
        R1 = self.radius_1
        adendum_1 = self.adendum_1
        slack_1 = self.slack_1
        dedendum_1 = self.dedendum_1
        inner_radius_1_first = self.inner_radius_1_first
        inner_radius_1_second = self.inner_radius_1_second
        hole_radius_1 = self.hole_radius_1
        support_angle_1 = self.support_angle_1

        n_teeth_2 = self.number_of_teeth_2
        R2 = R1*n_teeth_2/n_teeth_1
        self.radius_2 = R2
        adendum_2 = self.adendum_2
        slack_2 = self.slack_2
        dedendum_2 = self.dedendum_2
        inner_radius_2_first = self.inner_radius_2_first
        inner_radius_2_second = self.inner_radius_2_second
        hole_radius_2 = self.hole_radius_2
        support_angle_2 = self.support_angle_2

        (verts1, faces1, teeth_size_1) = create_gear(n_teeth_1, R1, adendum_1, slack_1, dedendum_1, inner_radius_1_first, inner_radius_1_second, hole_radius_1, support_angle_1, dt)
        (verts2, faces2, teeth_size_2) = create_gear(n_teeth_2, R2, adendum_2, slack_2, dedendum_2, inner_radius_2_first, inner_radius_2_second, hole_radius_2, support_angle_2, dt)

        cx = R1+R2+teeth_size_1+teeth_size_2
        if (n_teeth_2%2==0):
            phase1 = pi/n_teeth_1
        else:
            phase1 = 0

        R11_1 = cos(phase1-angle*R2/R1)
        R12_1 = -sin(phase1-angle*R2/R1)
        R21_1 = sin(phase1-angle*R2/R1)
        R22_1 = cos(phase1-angle*R2/R1);
        R11_2 = cos(angle)
        R12_2 = -sin(angle)
        R21_2 = sin(angle)
        R22_2 = cos(angle)

        verts1_L = list(verts1)
        for i in range(len(verts1_L)):
            x = verts1_L[i][0]
            y = verts1_L[i][1]
            z = verts1_L[i][2]
            verts1_L[i] = (R11_1*x + R12_1*y, R21_1*x + R22_1*y, z)
        verts1 = tuple(verts1_L)
        verts2_L = list(verts2)
        for i in range(len(verts2_L)):
            x = verts2_L[i][0]
            y = verts2_L[i][1]
            z = verts2_L[i][2]
            verts2_L[i] = (distance*cx + R11_2*x + R12_2*y, R21_2*x + R22_2*y, z)
        verts2 = tuple(verts2_L)

        obj = createMeshFromData(context, 'gearPair.1', verts1, faces1)
        obj = createMeshFromData(context, 'gearPair.2', verts2, faces2)

        return {'FINISHED'}


def menu(self, context):
    self.layout.operator(AddGear.bl_idname, text="Gear Pair", icon="MESH_CUBE")

def register():
    bpy.utils.register_module(__name__)
    bpy.types.INFO_MT_mesh_add.append(menu)

def unregister():
    bpy.utils.unregister_module(__name__)
    bpy.types.INFO_MT_mesh_add.remove(menu)

if __name__ == "__main__":
    register()
