## MovaBar

Rearrange status bar icons. Reverse engineered from Moveable9

My concerns regarding the method I decided to use are in the comments of the code. The status bar on iOS has items, and each item should have a unique identifier. The way I rearranged the order was using these identifier. I have a list of icons I want of the left and right respectively. The issue is that if an icon that I have not mentioned is added to the status bar, it won't show up at all. 
