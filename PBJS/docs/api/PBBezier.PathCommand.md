---
title: PBBezier.PathCommand
---

Commands used in drawing a Display (custom UI component). The origin for drawing is at the lower-left corner of the Display, with the Y-axis increasing upwards.

rule::move

Move the draw cursor to the the XY coordinate specified by the two Floats.

rule::line

Draw a line from the current cursor position to the XY coordinate specified by the two Floats.

rule::curve

Draw a curve from the current cursor position to the XY coordinate specified by the two floats. The optional third Float specifies a weight for the curve.

rule::scale

Scale the entire path by the given X and Y values.