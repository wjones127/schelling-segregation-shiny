This is a variation of [Thomas C. Schelling's agent-based models of segregation]
(http://wayback.archive.org/web/20140801170215/http://www.stat.berkeley.edu/~aldous/157/Papers/Schelling_Seg_Models.pdf).
The concept is simple: Randomly distribute points in the unit square. Each point
is said to be "happy" if some portion of their nearest neighbors are of the
same color. Then on each iteration, for each unhappy point, offer them a random
new location and have them move only if they would be happy in that new location.

In the situation where points are happy when half of their ten nearest neighbors
are of the same type, it's clear that segregation happens quite quickly; after
only a few iterations, most of the points have mostly neighbors of the same
color. 