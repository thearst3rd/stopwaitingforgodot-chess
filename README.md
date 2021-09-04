# Simple Godot Chess

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
		* Threefold repetition _might_ be included, I'd love to but that will be the last one
		* Claiming draws will automatically happen, so no 75 move rule or fivefold repetition
	* FEN support
	* But probably, no support for SAN. Maybe UCI
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

* While dragging, the original chess piece stays where it is at full opacity. I would like to make it transparent, which I can easily do while picking up the piece, but I don't know how to undo that transparency if the user decided to cancel the drag. There isn't a `drag_cancelled()` method AFAIK. Will just listening for a global "mouse released" event work well?
* Additionally, the "drag distance" seems pretty high, as in, you need to click and drag pretty far on the square before getting any feedback. Can I shorten that distance? Or, should I just nuke this whole built-in drag/drop system and do it myself? Time shall see :)

I've started with the "chess logic". So far, still no actual logic is implemented, but I've created a `Chess` class which keeps track of an internal position which can be manipulated. I've then hooked up the graphical side of things to draw the textures based on the internal chess data.

First time using groups! I originally had the method `Board.connect_squares_piece_dropped` which took an argument of the parent `Game` object and connected all the signals like that. I didn't like that though, I felt a method wasn't needed on the Board side. So I added the `Square` nodes to a group called "Squares" and connected them up with the `get_tree().call_group` method! Pretty neat. I spent more time than I should have attempting that though, so I should really move on to the legal move generation :)

In my [previous chess implementation](https://github.com/thearst3rd/chesslib), I literally stored a complete copy of every single position that has ever been reached in the game. This is... inefficient, but at least undoing a move is trivial (just revert back to the second to last board state). This time though, I figured, let's not do that. Rather, with each move, I want to store everything that's needed to undo that move. For instance, if there was a captured piece, we need to know what it was so we can put it back. I did some testing, and I'm feeling pretty good that I covered everything, but I might have missed something. Hopefully I'll find out sooner rather than later. Ok, on to legal move generation for real.

I found something that I thought was pretty unintuitive. I want to be able to make duplicate objects of a chess position that can be edited while the original is preserved, to do stuff like calculating if two positions are repetitions during a threefold repetition check. But, a class cannot use its own name since that would create a cyclic dependancy, so for example, my `Chess` class cannot do the following:

```gd
extends Reference
class_name Chess

# ...

func duplicate() -> Chess:
	var new_chess = Chess.new()	# Cannot do this!!
	# ... setup new_chess with the same as current chess
	return new_chess
```

I figured, since that doesn't work, I can probably just replace `Chess.new()` with `new()`, since that should be the equivalent given the current scope. Turns out, that doesn't work. BUT, somehow, just `.new()` DOES work. Not sure what's up with that. Took me a while, but eventually I found that out through the Godot Discord. The current code looks like:

```gd
func duplicate():	# no `-> Chess`
	var new_chess = .new()	# ???
	# ... setup new_chess with the same as current chess
	return new_chess
```

(Also, it looks like [this might be addressed in Godot 4.0](https://github.com/godotengine/godot-proposals/issues/460). Would be nice.)


# Credits/Attributions

See [CREDITS.md](CREDITS.md).
