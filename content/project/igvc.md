
+++
title = "IGVC"
date = "2017-12-01"
summary = "Autonomous Navigation Vehicle"
# View.
#   1 = List
#   2 = Compact
#   3 = Card
view = 1

# Optional featured image (relative to `static/img/` folder).
[header]
image = ""
caption = ""
+++

Designed the real-time vision subsystem for an autonomous navigation vehicle. This subsystem included a lane detection algorithm for which we used a segmentation algorithm on the input image. Since the lanes were white and were drawn on grass the lighting effects made it really difficult to just pick out the lanes with just hue thresholds. We used the segmentation algorithm to  