SpriteKit Physics Collisions
============================

This example illustrates a few physics concepts:


1. Connecting game controls to physics effects.

The example spawns two ships, one of which is under the control of the player:

w or forward arrow :  accelerate forward
a or left arrow    :  turn left
d or right arrow   :  turn right
s or back arrow    :  accelerate backwards
space bar          :  fire a missile

r                  :  reset the simulation

When keys are pressed, the scene records the key state. Then, when the next frame is updated, the scene uses the recorded key state and uses it to apply physics forces or perform other game logic.


2. Using collision and hit detection masks to drive gameplay.

There are four kinds of game objects in this simulation: missiles, ships, asteroids, and planets. Each game object has a corresponding physics body used to simulate how it moves. A physics body defines how it interacts with other physics bodies in the simulation. 

In Sprite Kit there are two kinds of interactions:

* Collisions, where the physics system calculates new trajectories for the colliding objects.
* Contacts, where a delegate is called to adjust the simulation.

In this example, each physics body is configured so that only the minimum number of collisions and contacts are observed. This careful design improves game performance.

3. Tying in particle effects into the physics subsystem

When effect nodes are moving within the scene (and subject to forces and collisions), particles should be spawned in the scene, not in the effect node. This allows existing particles to move independently of node that spawned them.

In this example, many effects were pre-built using the particle emitter editor built into Xcode. This example shows how to load those effects as well as how to change the configuration of those nodes at runtime. This is not only used to place the particles in the scene, but also to adjust the appearance of those particles at runtime.



Architecture:
============

The majority of the work is done by the APLSpaceScene class. It builds the initial game state and is responsible for creating most of the common game objects, as well as performing simulation effects. Notably, it acts as the physics contact delegate, meaning that whenever two physics bodies interact with each other, it is called to adjust the game logic.

The rules it follows are simple:
* Missiles that interact with other game objects explode.
* Ships that strike other objects take damage based on the force of the impact.
* Asteroids that collide with planets are destroyed.

The APLShipSprite class shows how to add game logic to a sprite node object. In this example, the APLShipSprite class keeps track of ship damage as well as the state of the ship. For example, when the player accelerates the ship forward, the ship class turns on a particle effect to show the ship's exhaust.


=============================

Copyright (c) 2013 Apple Inc. All rights reserved.