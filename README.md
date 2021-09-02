# Simple Godot Chess

A simple chess implementation in [Godot](https://godotengine.org/). This is my entry in Terry Cavanaugh's [STOP WAITING FOR GODOT](https://itch.io/jam/stop-waiting-for-godot) Jam!

---

This readme will detail some of the things I learned and the resources I used to learn them. Come back later when the jam is done :)

## Brainstorming

The theme of the jam is "Keep it Simple", so rather than come up with any new fancy game, I figured I'd just implement a game that already exists. Chess has been my most recent obsession for some reason, and I've already implemented [chess logic](https://github.com/thearst3rd/chesslib) and [a simple chess GUI](https://github.com/thearst3rd/sfml-chess-test) in C before so I figured that was a great game to try to make in Godot.

I had the idea to implement chess in Godot a while ago, but I wasn't very familiar with the engine at the time and struggled to make the user interface in a "nice" way using control nodes. But participating in the GMTK game jam helped me get a lot of experience with the engine, and so I figured I could take another stab at it and be more succesful this time.

Even with this simple theme, there's a lot I could do in this project. So sticking with the theme of "Keep it Simple", here is what I think will be a general guideline of how much I implement:

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
