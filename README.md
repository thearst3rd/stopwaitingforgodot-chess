# #StopWaitingForGodot Chess

A simple chess implementation in [Godot](https://godotengine.org/). This is my entry in Terry Cavanaugh's [STOP WAITING FOR GODOT](https://itch.io/jam/stop-waiting-for-godot) Jam!

---

This readme will detail some of the things I learned and the resources I used to learn them. Come back later when the jam is done :)

## Brainstorming

The theme of the jam is "Keep it Simple", so rather than come up with any new fancy game, I figured I'd just implement a game that already exists. Chess has been my most recent obsession for some reason, and I've already implemented [chess logic](https://github.com/thearst3rd/chesslib) and [a simple chess GUI](https://github.com/thearst3rd/sfml-chess-test) in C before so I figured that was a great game to try to make in Godot.

I had the idea to implement chess in Godot a while ago, but I wasn't very familiar with the engine at the time and struggled to make the user interface in a "nice" way using control nodes. But participating in the GMTK game jam helped me get a lot of experience with the engine, and so I figured I could take another stab at it and be more succesful this time.

Even with this simple project idea, there's a lot I could end up doing and I need to keep my scope in check. So sticking with the theme of "Keep it Simple", here is what I think will be a general guideline of how much I implement:

* Chess logic
	* Legal move generation
		* Castling, en passant, pawn promotion
	* Game end conditions
		* Checkmate, stalemate, insufficient material, 50 move rule
		* Threefold repetition ~~_might_ be~~ _is :)_ included, ~~I'd love to but that will be the last one~~ _it was the last one and it is done!_
		* Claiming draws will automatically happen, so no 75 move rule or fivefold repetition
	* FEN support
	* ~~But probably, no support for SAN. Maybe UCI~~ _SAN implemented :)_
	* I'm aiming for ease-of-programming, not high performance, so I'll be doing a lot of things the naive way :)
* Graphical chess interface
	* Drag and drop to move the pieces
	* Button to flip the board to view from black's perspective
	* Functionality to undo moves
	* Pawn promotion in the GUI will probably be limited to queen only. We'll see though
* Enemy AI
	* For now, the AI will probably just be a simple random move AI. Creating an actual AI using game tree search is probably out of scope for this weekend :)
	* If it isn't too hard though, I can add support for UCI engine communication

## Log

So I'll admit, I did a bit of prep work before hand. Particularly, this week I watched and followed along with the following tutorials by [Game Development Center](https://www.youtube.com/channel/UClseGZiVmeHamsjYmpbiAmQ):

* [Grid Based Inventory System | Godot Inventory Tutorial](https://www.youtube.com/watch?v=lrAwX2t1mGY)
* [Drag and Drop Inventory System | Godot Tutorial](https://www.youtube.com/watch?v=dZYlwmBCziM)

These tutorials helped me get setup with a grid based 8x8 chess board, and a system where I can pick up the chess pieces and drag them to other squares.

I still have a few questions though -

* ~~While dragging, the original chess piece stays where it is at full opacity. I would like to make it transparent, which I can easily do while picking up the piece, but I don't know how to undo that transparency if the user decided to cancel the drag. There isn't a `drag_cancelled()` method AFAIK. Will just listening for a global "mouse released" event work well?~~ Looks like listening for global mouse released events works pretty well! I can make the piece transparent, and show legal move indicators, and when you're done (whether you made a move or not) it'll all be reset.
* Additionally, the "drag distance" seems pretty high, as in, you need to click and drag pretty far on the square before getting any feedback. Can I shorten that distance? Or, should I just nuke this whole built-in drag/drop system and do it myself? Time shall see :)

I've started with the "chess logic". So far, still no actual logic is implemented, but I've created a `Chess` class which keeps track of an internal position which can be manipulated. I've then hooked up the graphical side of things to draw the textures based on the internal chess data.

First time using groups! I originally had the method `Board.connect_squares_piece_dropped` which took an argument of the parent `Game` object and connected all the signals like that. I didn't like that though, I felt a method wasn't needed on the Board side. So I added the `Square` nodes to a group called "Squares" and connected them up with the `get_tree().call_group` method! Pretty neat. I spent more time than I should have attempting that though, so I should really move on to the legal move generation :)

In my [previous chess implementation](https://github.com/thearst3rd/chesslib), I literally stored a complete copy of every single position that has ever been reached in the game. This is... inefficient, but at least undoing a move is trivial (just revert back to the second to last board state). This time though, I figured, let's not do that. Rather, with each move, I want to store everything that's needed to undo that move. For instance, if there was a captured piece, we need to know what it was so we can put it back. I did some testing, and I'm feeling pretty good that I covered everything, but I might have missed something. Hopefully I'll find out sooner rather than later. Ok, on to legal move generation for real.

~~I found something that I thought was pretty unintuitive. I want to be able to make duplicate objects of a chess position that can be edited while the original is preserved, to do stuff like calculating if two positions are repetitions during a threefold repetition check. But, a class cannot use its own name since that would create a cyclic dependancy, so for example, my `Chess` class cannot do the following:~~

```gd
extends Reference
class_name Chess

# ...

func duplicate() -> Chess:
	var new_chess = Chess.new()	# Cannot do this!!
	# ... setup new_chess with the same as current chess
	return new_chess
```

~~I figured, since that doesn't work, I can probably just replace `Chess.new()` with `new()`, since that should be the equivalent given the current scope. Turns out, that doesn't work. BUT, somehow, just `.new()` DOES work. Not sure what's up with that. Took me a while, but eventually I found that out through the Godot Discord. The current code looks like:~~

```gd
func duplicate():	# no `-> Chess`
	var new_chess = .new()	# ???
	# ... setup new_chess with the same as current chess
	return new_chess
```

~~(Also, it looks like [this might be addressed in Godot 4.0](https://github.com/godotengine/godot-proposals/issues/460). Would be nice.)~~ *GAH, just kidding!! That also doesn't work! It shows no errors in the editor, but doesn't actually work. Should have figured, and you know, maybe tested it... More info a few paragraphs below.*

I got pseudo chess all implemented (minus castling, I'll handle that in full legal chess since it involves checks in the conditions). From there, I improved the interface to show legal moves so I could see if I did anything wrong (I did!!!), for which I had to answer some of my earlier questions along the way. I had to make the indicators squares instead of the originally-planned circles... looks like I'll have to add code to draw circles if I really want them. But so far, this is turning out great! Especially considering it's still Friday night (well, it's Saturday morning at 2:56 AM EDT but that doesn't count...)

Check is now implemented! The code is (probably?) more efficient than my method in chesslib - before, I would generate all pseudo legal moves and see if any of them ended at our king. This was terribly inefficient, but works at least. This time, it's still not very good, but better. Rather than look at all of the opponent's pieces and generate all their moves to see if they can capture our king, just start at our king and move outwards for pieces that could capture it. So, look a knight's move away to check for knights, start sliding in the rook's directions to check for rooks/queens, etc. I had a bug where pawns "attacked" the wrong direction according to my function, but after fixing that, I think I got it all working! Some more testing needs to be done be sure, but AFAIK, all moves are now fully legal moves! I just need to handle the game end conditions.

The (almost) last piece of the puzzle has been implemented - the game termination condtions! I have all of them implemented with the exception of threefold repetition, which I plan on getting to. While testing, I encountered a strange bug with my move generation where it claimed there was no stalemate when it was clearly stalemate (`k7/8/4B3/2B1B3/8/2B5/2K2B2/8 w - - 12 7`, move `Bc8`). It turned out to do with castling - even though the castling flags were turned off, somehow it still generated a castling move which brought the king off the board :) I found the bug, it had to do with how I wrote the ternary statements to look at a the castling flags for whose turn it is. I wrote it out to be more explicit, and the problem went away. I also found another place there might have been a bug and made that more explicit too. Regardless, once again, this project is starting to really shape up and it's super satisfying to be able to play out entire legal games of chess and watch it calculate the end result!

GAHH!! So I was working on getting threefold repetition to work, and discovered that the whole paragraph I wrote about `Chess.new()` vs `new()` vs `.new()` was wrong! I, uhhh, should've tested it :) Regardless, after scouring through discord again, I found that the ACTUAL way to do it is to call `get_script().new()`. THAT WORKED and I was able to implement threefold repetition!!! To make things easier, I also now prune the en passant target square - that is, if a pawn moved two squares, but there aren't actually any pawns that can capture en passant (or those pawns are pinned), then remove the en passant target square. This makes checking if two positions are repetitions easier since I don't need to do it there. I even included some small optimizations! Now, truly, legal chess (with claimable draws getting auto-claimed) should be _fully_ implemented (so long as there are no bugs!).

And it's only Saturday night! I've got potentially all of Sunday and most of Monday to add more features. I'll work on UI improvements for sure, and maybe, _just maybe_, I can do game tree search and make an AI that isn't just a random mover? _Maybe!!??_

Implemented SAN :) Had some hiccups - it overly disambiguated pawn promotions (ex, `h8xg7=Q` instead of `hxg7=Q`), but I figured that was because each pawn promotion was counting as a conflict with all the rest, and once I started comparing starting squares instead, that worked out. I also forgot about castling at first, so `Kf1` would be moving white's king one square to the right, and... `Kg1` was white castling kingside :) I fixed that as well.

Not only that, but I added a SAN display as well! It's Lichess-inspired, and it looks really nice, _definitely_ better than I expected out of a one-weekend project.

Man, I need to get better at constructing GUIs in the 2D scene view. I always end up with 10 billion VBoxes and HBoxes and CenterContainers and such, when I'm sure there's a simpler way to achieve the exact same result. That's something I should focus on learning soon. At least I've figured out about `find_node()`, that way I don't need to change the hard-coded node path every time I alter the structure. I'm not sure - is using `find_node` on everything bad practice? Anyways, I created a simple settings menu which lets you toggle some settings, which get saved to disk. Nice!

It's about time, but I added proper attributions for everything that requires it. I probably should have done that earlier :) Regardless, [CREDITS.md](CREDITS.md) should be fully up to date, as well as a new fancy in game credits screen (that took me a really long time to make!!!). I will probably upload the project as it is now to itch.io, since I think it's in a really nice state! The one major feature I still want to add is some form of AI. I'm definitely not going to get to making a real minimax-powered game tree search AI which _tries_ to play well, but at least I should include a random-mover so that someone can play a single player game without needing to supply the moves of both sides :)

# Credits/Attributions

See [CREDITS.md](CREDITS.md).
