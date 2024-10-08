# Technical Details

Bullet speed is 250 per substep, so 25,000 per turn, which is 25% of the map length.

Character hitbox is 1000 x 1000, which is 1% of the map size.

Characters can move 100 per substep, so 10,000 per turn, which is 10% of the map length.

In the move loop first we check if there is a bullet fired this step, then if so we add it to the session bullet array.

Then we loop through the bullet array and advance each bullet, dropping them if out of bounds.

Then we check for collisions and if a bullet hits a player we remove the bullet and player from the session and remove the character from the game.

Note, since bullets travel at 250 per substep and the character hitbox is 1000, a bullet can hit a character in the same step it was fired. This is accounted for in the collision check.



