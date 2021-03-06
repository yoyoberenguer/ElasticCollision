"""

The following classes can be easily implemented into a 2D game (top down or horizontal/vertical scrolling) to generate
a real time elastic collision engine.

This code comes with a MIT license.

Copyright (c) 2018 Yoann Berenguer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

Please acknowledge and give reference if using the source code for your project

"""

__author__ = "Yoann Berenguer"
__copyright__ = "Copyright 2007."
__credits__ = ["Yoann Berenguer"]
__license__ = "MIT License"
__version__ = "2.0.0"
__maintainer__ = "Yoann Berenguer"
__email__ = "yoyoberenguer@hotmail.com"
__status__ = "Demo"

import math

try:
    import pygame
except ImportError:
    print('\nOn window, try:\nC:\>pip install pygame')
    raise SystemExit

from timeit import *



class TestObject(object):
    """ Create a test object for elastic collision engine"""
    def __init__(self, x, y, mass, centre):
        """
        :param x: component x of a vector
        :param y: component y of a vector
        :param mass: mass of the object in kilograms (must be >0)
        :param centre: centre of the object, (position x, y)
        :type x: float or int
        :type y: float or int
        :type mass: float or int
        :type centre: tuple(x, y)
        """

        assert isinstance(x, (int, float)),\
            'Positional argument x must be int or float, got %s ' % type(x)
        assert isinstance(y, (int, float)),\
           'Positional argument y must be int or float, got %s ' % type(y)
        assert isinstance(mass, (int, float)),\
            'Positional argument mass must be int or float, got %s ' % type(mass)
        if mass <= 0:
            raise ValueError('Positional argument mass must be >0')
        assert isinstance(centre, tuple),\
            'Positional argument centre must be a tuple, got %s ' % type(centre)

        self.vector = pygame.math.Vector2(x, y)
        self.mass = mass
        self.centre = centre


class Momentum(object):

    def __init__(self, obj1, obj2):
        """
        Class providing a set of tools for elastic collision calculations.

        :param obj1: Object 1 with properties define by the class TestOBject
        :param obj2 Object 2 with properties define by class TestObject
        :type obj1: Type TestObject with vector, mass and position.
        :type obj2: Type TestObject with vector mass and position.

        >>> centre1 = (100, 200)
        >>> obj_1 = TestObject(x=0.707, y=0.707, mass=10.0, centre=centre1)
        >>> obj_1.vector.x
        0.707
        >>> obj_1.vector.y
        0.707
        >>> obj_1.mass
        10.0
        >>> obj_1.centre
        (100, 200)
        >>> centre2 = (200, 100)
        >>> obj_2 = TestObject(x=-0.707, y=-0.707, mass=10.0, centre=centre2)
        >>> collision = Momentum(obj_1, obj_2)
        >>> round(collision.distance_from_center(), 7)
        141.4213562
        >>> round(collision.v1v2_difference(), 7)
        1.999698
        >>> round(collision.contact_angle_(), 7)
        0.7853982
        >>> round(collision.contact_angle(pygame.math.Vector2(obj_1.centre),\
         pygame.math.Vector2(obj_2.centre)), 7)
        0.7853982
        >>> round(collision.contact_angle(pygame.math.Vector2(obj_2.centre),\
         pygame.math.Vector2(obj_1.centre)), 7)
        3.9269908
        >>> math.degrees(collision.contact_angle(pygame.math.Vector2(0, 0),\
         pygame.math.Vector2(0, 0)))
        -0.0
        >>> math.degrees(collision.contact_angle(obj=pygame.math.Vector2(-1, 1),\
         reference=pygame.math.Vector2(1, -1)))
        45.0
        >>> math.degrees(collision.contact_angle(obj=pygame.math.Vector2(-1, -1),\
         reference=pygame.math.Vector2(1, 1)))
        315.0
        >>> math.degrees(collision.theta_angle(pygame.math.Vector2(0.707, 0.707)))
        45.0
        >>> math.degrees(collision.theta_angle(pygame.math.Vector2(-0.707, 0.707)))
        135.0
        >>> math.degrees(collision.theta_angle(pygame.math.Vector2(-0.707, -0.707)))
        -135.0
        >>> math.degrees(collision.theta_angle(pygame.math.Vector2(0.707, -0.707)))
        -45.0
        """
        assert isinstance(obj1, TestObject),\
                  "Positional argument obj1 must be a TestObject type, got %s " % type(obj1)
        assert isinstance(obj2, TestObject),\
                  "Positional argument obj2 must be a TestObject type, got %s " % type(obj2)

        for obj in ('obj1', 'obj2'):
            for attrs in ('vector', 'mass', 'centre'):
                if not hasattr(eval(obj), attrs):
                    raise AttributeError('Argument %s (TestObject) is missing attribute %s ' % (obj, attrs))

        self.obj1 = obj1    # Reference object 1 (TestObject)
        self.obj2 = obj2    # Reference object 2 (TestObject)

    def v1v2_difference(self) -> float:
        """ returns the Euclidean length of the vector |v1 - v2|
        :return : Return length |v1 - v2|
        :rtype : float
        """
        return (self.obj1.vector - self.obj2.vector).length()

    def distance_from_center(self) -> float:
        """ Return the distance from objects respective centre.
        :return : Return the distance between object1 and object2
        :rtype: float (distance)
        """
        return math.sqrt((self.obj1.centre[0] - self.obj2.centre[0]) ** 2 +
                         (self.obj1.centre[1] - self.obj2.centre[1]) ** 2)

    def contact_angle_(self) -> float:
        """ Return the contact angle φ [π, -π] in radians between obj1 and obj2.
        :return : contact angle in radians [π, -π]
        :rtype : float (angle φ radians)
        """
        phi = math.atan2(self.obj2.centre[1] - self.obj1.centre[1],
                         self.obj2.centre[0] - self.obj1.centre[0])
        if phi > 0:
            phi -= 2 * math.pi
        phi *= - 1
        return phi

    @staticmethod
    def contact_angle(obj, reference) -> float:
        """ Return the contact angle φ in radians [π, -π] between obj1 and obj2
        :param obj: Object centre (e.g obj1)
        :param reference: Object centre (e.g obj2)
        :type obj: must be a pygame.math.Vector2
        :type reference: must be a pygame.math.Vector2
        :return : return the contact angle in radians
        :rtype : float (angle φ radians)
        """
        assert isinstance(obj, pygame.math.Vector2), \
            'Positional argument obj must be a pygame.math.Vector, got %s ' % type(obj)
        assert isinstance(reference, pygame.math.Vector2), \
            'Positional argument reference must be a pygame.math.Vector, got %s ' % type(reference)
        phi = math.atan2(reference.y - obj.y, reference.x - obj.x)
        if phi > 0:
            phi -= 2 * math.pi
        phi *= - 1
        return phi

    @staticmethod
    def theta_angle(vector) -> float:
        """
        Return theta angle Θ in radians [π, -π]
        :param vector: pygame.math.Vector2
        :return: float (angle Θ in radians)
        """
        assert isinstance(vector, pygame.math.Vector2), \
            'Positional argument vector must be a pygame.math.Vector, got %s ' % type(vector)
        try:
            theta = math.acos(vector.x / vector.length())
            if vector.y < 0:
                theta *= -1
            return theta
        except ZeroDivisionError:
            return 0

    @staticmethod
    def v1_vector_components(v1, v2, theta1, theta2, phi, m1, m2) -> pygame.math.Vector2:
        """
        return scalar size v1 of the original object represented by (v1, theta1, m1)
        where v1 and v2 are the scalar sizes of the two original speeds of the objects, m1 and m2
        are their masses, θ1 and θ2 are their movement angles, that is,v1x = v1.cos(θ1) , v1y = v1.sin(θ1)
        (meaning moving directly down to the right is either a -45° angle, or a 315°angle), and lowercase phi (φ)
        is the contact angle.

        :param v1: object1 vector length
        :param v2: object2 vector length
        :param theta1: Θ1 angle in radians (object1)
        :param theta2: Θ2 angle in radians (object2)
        :param phi: φ contact angle in radians
        :param m1: Mass in kilograms, must be > 0 (object1)
        :param m2: Mass in kilograms, must be > 0(object2)
        :return: Returns a direction vector
        :rtype : pygame.math.Vector2
        """
        assert v1 >= 0 and v2 >= 0, '|v1| and |v2| magnitude must be >= 0'
        assert (m1 + m2) > 0, 'm1 + m2 must be > 0, got %s ' % (m1 + m2)
        numerator = v1 * math.cos(theta1 - phi) * (m1 - m2) + 2 * m2 * v2 * math.cos(theta2 - phi)
        v1x = numerator * math.cos(phi) / (m1 + m2) + v1 * math.sin(theta1 - phi) * math.cos(phi + math.pi / 2)
        v1y = numerator * math.sin(phi) / (m1 + m2) + v1 * math.sin(theta1 - phi) * math.sin(phi + math.pi / 2)

        if math.isclose(v1x, 0.1e-10, abs_tol=1e-10):
            v1x = 0.0
        if math.isclose(v1y, 0.1e-10, abs_tol=1e-10):
            v1y = 0.0

        v1y *= -1 if v1y != 0 else 0.0
        return pygame.math.Vector2(v1x, v1y)

    @staticmethod
    def v2_vector_components(v1, v2, theta1, theta2, phi, m1, m2) -> pygame.math.Vector2:
        """
        return scalar size v2 of the original object represented by (v2, theta2, m2)
        where v1 and v2 are the scalar sizes of the two original speeds of the objects, m1 and m2
        are their masses, θ1 and θ2 are their movement angles, that is,v1x = v1.cos(θ1) , v1y = v1.sin(θ1)
        (meaning moving directly down to the right is either a -45° angle, or a 315°angle), and lowercase phi (φ)
        is the contact angle.

        :param v1: object1 vector length
        :param v2: object2 vector length
        :param theta1: Θ1 angle in radians (object1)
        :param theta2: Θ2 angle in radians (object2)
        :param phi: φ contact angle in radians
        :param m1: Mass in kilograms, must be > 0 (object1)
        :param m2: Mass in kilograms, must be > 0(object2)
        :return: Returns a direction vector
        :return: :rtype : pygame.math.Vector2
        """

        assert v1 >= 0 and v2 >= 0, '|v1| and |v2| magnitude must be >= 0'
        assert (m1 + m2) > 0, 'm1 + m2 must be > 0, got %s ' % (m1 + m2)
        numerator = v2 * math.cos(theta2 - phi) * (m2 - m1) + 2 * m1 * v1 * math.cos(theta1 - phi)
        v2x = numerator * math.cos(phi) / (m2 + m1) + v2 * math.sin(theta2 - phi) * math.cos(phi + math.pi / 2)
        v2y = numerator * math.sin(phi) / (m2 + m1) + v2 * math.sin(theta2 - phi) * math.sin(phi + math.pi / 2)
        if math.isclose(v2x, 0.1e-10, abs_tol=1e-10):
            v2x = 0.0
        if math.isclose(v2y, 0.1e-10, abs_tol=1e-10):
            v2y = 0.0

        v2y *= -1 if v2y != 0 else 0.0  # y-axis inverted
        return pygame.math.Vector2(v2x, v2y)

    @staticmethod
    def process(obj1, obj2) -> tuple:
        """ return scalar sizes for both objects.  """

        phi = Momentum.contact_angle(pygame.math.Vector2(obj1.centre),
                                     pygame.math.Vector2(obj2.centre))

        theta1 = Momentum.theta_angle(obj1.vector)
        theta2 = Momentum.theta_angle(obj2.vector)

        v1 = Momentum.v1_vector_components(obj1.vector.length(), obj2.vector.length(),
                                           theta1, theta2, phi, obj1.mass,
                                           obj2.mass)

        v2 = Momentum.v2_vector_components(obj1.vector.length(), obj2.vector.length(),
                                           theta1, theta2, phi, obj1.mass,
                                           obj2.mass)
        return v1, v2

    # ************************************************************************
    # Same method than above but use objects defined with the TestObject class
    # ************************************************************************
    def collision_calculator(self) -> tuple:
        phi = Momentum.contact_angle(pygame.math.Vector2(self.obj1.centre),
                                     pygame.math.Vector2(self.obj2.centre))

        theta1 = Momentum.theta_angle(self.obj1.vector)
        theta2 = Momentum.theta_angle(self.obj2.vector)

        v1 = Momentum.v1_vector_components(self.obj1.vector.length(), self.obj2.vector.length(),
                                           theta1, theta2, phi, self.obj1.mass,
                                           self.obj2.mass)

        v2 = Momentum.v2_vector_components(self.obj1.vector.length(), self.obj2.vector.length(),
                                           theta1, theta2, phi, self.obj1.mass,
                                           self.obj2.mass)
        return v1, v2


    @staticmethod
    def process_v1(obj1, obj2) -> pygame.math.Vector2:
        """ return scalar size for object 1  """
        assert isinstance(obj1, TestObject),\
                  "Positional argument obj1 must be a TestObject type, got %s " % type(obj1)
        assert isinstance(obj2, TestObject),\
                  "Positional argument obj2 must be a TestObject type, got %s " % type(obj2)
        phi = Momentum.contact_angle(pygame.math.Vector2(obj1.centre),
                                     pygame.math.Vector2(obj2.centre))

        theta1 = Momentum.theta_angle(obj1.vector)
        theta2 = Momentum.theta_angle(obj2.vector)
        v1 = Momentum.v1_vector_components(obj1.vector.length(), obj2.vector.length(),
                                           theta1, theta2, phi, obj1.mass,
                                           obj2.mass)
        return v1


    @staticmethod
    def process_v2(obj1, obj2) -> pygame.math.Vector2:
        """ return scalar size for object 2  """
        assert isinstance(obj1, TestObject),\
                  "Positional argument obj1 must be a TestObject type, got %s " % type(obj1)
        assert isinstance(obj2, TestObject),\
                  "Positional argument obj2 must be a TestObject type, got %s " % type(obj2)
        phi = Momentum.contact_angle(pygame.math.Vector2(obj1.centre),
                                     pygame.math.Vector2(obj2.centre))

        theta1 = Momentum.theta_angle(obj1.vector)
        theta2 = Momentum.theta_angle(obj2.vector)
        v2 = Momentum.v2_vector_components(obj1.vector.length(), obj2.vector.length(),
                                           theta1, theta2, phi, obj1.mass,
                                           obj2.mass)
        return v2

    # ****************************** ANGLE FREE METHOD *******************************************


    # ***************************************************************
    # Angle free representation, the changed velocities are computed
    # using centers x1 and x2 at the time of contact.
    # ***************************************************************
    @staticmethod
    def v1_vector_components_alternative(v1, v2, m1, m2, x1, x2) -> pygame.math.Vector2:
        """
        scalar size v1 of the original object speed represented by (v1, m1, x1 arguments).

        :param v1: pygame.math.Vector2, object1 vector
        :param v2: pygame.math.Vector2, object2 vector
        :param m1: object1 mass in kilograms, must be > 0
        :param m2: object2 mass in kilograms, must be > 0
        :param x1: pygame.math.Vector2, object1 centre
        :param x2: pygame.math.Vector2, object2 centre
        :return: pygame.math.Vector2, resultant vector for object1
        """
        assert (m1 + m2) > 0, 'm1 + m2 must be > 0, got %s ' % (m1 + m2)
        assert (x1 != x2), 'object1 and object2 must have different centre values, x1:%s, x2:%s ' % (x1, x2)
        mass = 2 * m2 / (m1 + m2)
        return v1 - (mass * (v1 - v2).dot(x1 - x2) / pow((x1 - x2).length(), 2)) * (x1 - x2)

    # ***************************************************************
    # Angle free representation, the changed velocities are computed
    # using centers x1 and x2 at the time of contact.
    # ***************************************************************
    @staticmethod
    def v2_vector_components_alternative(v1, v2, m1, m2, x1, x2):
        """
        scalar size v2 of the original object speed represented by (v2, m2, x2 arguments).

        :param v1: pygame.math.Vector2, object1 vector
        :param v2: pygame.math.Vector2, object2 vector
        :param m1: object1 mass in kilograms, must be > 0
        :param m2: object2 mass in kilograms, must be > 0
        :param x1: pygame.math.Vector2, object1 centre
        :param x2: pygame.math.Vector2, object2 centre
        :return: pygame.math.Vector2, resultant vector for object1
        """
        assert (m1 + m2) > 0, 'm1 + m2 must be > 0, got %s ' % (m1 + m2)
        assert (x1 != x2), 'object1 and object2 must have different centre values, x1:%s, x2:%s ' % (x1, x2)
        mass = 2 * m1 / (m1 + m2)
        return v2 - (mass * (v2 - v1).dot(x2 - x1) / pow((x2 - x1).length(), 2)) * (x2 - x1)

    # ************************************************************************
    # Angle free calculation, return V1 and V2
    # ************************************************************************
    @staticmethod
    def angle_free_calculator(v1, v2, m1, m2, x1, x2) -> tuple:
        """
        :param v1: pygame.math.Vector2, object1 vector
        :param v2: pygame.math.Vector2, object2 vector
        :param m1: object1 mass in kilograms, must be > 0
        :param m2: object2 mass in kilograms, must be > 0
        :param x1: pygame.math.Vector2, object1 centre
        :param x2: pygame.math.Vector2, object2 centre
        :return: tuple, (object1 resultant vector, object2 resultant vector)
        """
        v11 = Momentum.v1_vector_components_alternative(v1, v2, m1, m2, x1, x2)
        v22 = Momentum.v2_vector_components_alternative(v1, v2, m1, m2, x1, x2)
        return v11, v22

    # ***************************************************************************************************

if __name__ == '__main__':

    import doctest
    doctest.testmod()


    centre1 = (100, 200)
    obj_1 = TestObject(x=0.707, y=0.707, mass=10.0, centre=centre1)
    rect2 = pygame.Rect(10, 10, 50, 50)
    centre2 = (200, 100)
    obj_2 = TestObject(x=-0.707, y=-0.707, mass=10.0, centre=centre2)
    c = Momentum(obj_1, obj_2)
    print('Object 1 center : ', centre1)
    print('Object 2 center : ', centre2)
    print('Testing method process : ', Momentum.process(obj_1, obj_2))
    v1, v2 = c.collision_calculator()
    print('Testing method collision_calculator : V1 ', v1, ' V2 ', v2)

    # ***************************************************************
    # Testing angle free representation v1 calculation
    # ***************************************************************
    print('Object 1 center : ', pygame.math.Vector2(100, 0))
    print('Object 2 center : ', pygame.math.Vector2(200, 0))
    print('Angle free v1 : ', Momentum.v1_vector_components_alternative(pygame.math.Vector2(0.707, 0.707),
                                                    pygame.math.Vector2(-0.707, -0.707), 10.0, 10.0,
                                                    pygame.math.Vector2(100, 0), pygame.math.Vector2(200, 0)))

    # ***************************************************************
    # Angle free representation v2 calculation
    # ***************************************************************
    print('Angle free v2 : ', Momentum.v2_vector_components_alternative(pygame.math.Vector2(0.707, 0.707),
                                                    pygame.math.Vector2(-0.707, -0.707), 10.0, 10.0,
                                                    pygame.math.Vector2(100, 0), pygame.math.Vector2(200, 0)))

    print('Timing result for 100000 iterations :', Timer("c.collision_calculator()", "from __main__ import c")\
        .timeit(100000))

    # Angle free method is much faster
    # Timing result  for 100000 iterations : 2.093596862793334
    # Angle free - timing result for 100000 iterations : 0.4719169265488081
    v1 = pygame.math.Vector2(0.707, 0)
    v2 = pygame.math.Vector2(-0.707, 0)
    m1 = 10.0
    m2 = 10.0
    x1 = pygame.math.Vector2(100, 0)
    x2 = pygame.math.Vector2(200, 0)

    print(Momentum.angle_free_calculator(v1, v2, m1, m2, x1, x2))

    print('Angle free - timing result for 100000 iterations :', 
                Timer("Momentum.angle_free_calculator(v1, v2, m1, m2, x1, x2)",
                "from __main__ import Momentum, v1, v2, m1, m2, x1, x2").timeit(100000))


    pass
