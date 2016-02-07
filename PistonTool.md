# Introduction #

Piston tool allows you create pistons in gmod. It has some settings.

### Basic Usage ###
Select the model.
Give a cylinder length value. ( Note: Piston will not go further than this length. )
Select necessary options like sound effect etc.

## Left Click ##
  * If you clicked while looking another prop it will spawns piston.
  * If you clicked while looking another "Piston" it will update it's options.

## Right Click ##
  * If you clicked while looking anything, It will give you local positions of where you looking. ( Debug purposes )
  * If you clicked while looking a piston, it will give you piston options. Like cylinder length. ( Good for fetching info from duplicated or forgotten settings )

## Reload ##
If you press reload button while you are looking a engine block or another model, it will update all the pistons inside the hull of Engine block. This means if you put every piston inside a large container and press reload while looking container, it will update all the pistons inside that container.

Good for mass switching between sound effects, cylinder lengths, force multipliers.


---


# Hidden Options #
There is hidden options for console using.
  * wire\_piston\_alwaysreverse : this option makes tool to always spawn pistons reversed.
  * wire\_piston\_dontreverse : this option makes tool to never spawn reversed models.
  * wire\_piston\_model : you can switch to any other model via this command.
  * wire\_piston\_modelflags : you can give a model flags to models, which was not defined in database.

### Model Flags ###

This flags used for deciding where to create constraint for model.
  * "c" flag means CENTER. So it will create constraints center of given axis.
  * "X" flag means X axis gonna be used for creating constraints.
  * "Y" flag means Y axis gonna be used for creating constraints.
  * "Z" flag means Z axis gonna be used for creating constraints.

So if you using a vertical model, then "cZ" should work for it. ( which is default flag )
But if it's modeled in another axis you can try "cX" or "cY" to find proper axis.

Currently only center and axis is coded so you should always put a "c" and a axis flag "X","Y" or "Z".

So current valid options are "cX" "cY" "cZ"

This maybe change in future versions. I may add another flags upon requests.