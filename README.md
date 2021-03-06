# #StopWaitingForGodot Chess

A simple chess implementation in [Godot](https://godotengine.org/). This is [my submission](https://itch.io/jam/stop-waiting-for-godot/rate/1188240) to Terry Cavanaugh's [STOP WAITING FOR GODOT](https://itch.io/jam/stop-waiting-for-godot) Jam!

You can play this in your web browser or download builds for Linux, Windows, or macOS on [the itch.io page](https://thearst3rd.itch.io/stopwaitingforgodot-chess)!

This readme details some of the thought and development process, including some of the brainstorming I did at the beginning, and the features I added as I went along. Enjoy!

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

I've added a random-mover bot, and that's the last feature I'm adding before submitting this. I'd say, the end result turned out pretty well compared to what I was expecting! I still think that the SAN display is my favorite feature, it makes it look really nice and makes it feel like a much more official chess project. I had a pretty big hiccup towards the end - hitting the "New Game" button didn't work when I exported the project!! After a bit, I figured it out - I had the functionality that reset the board in an `assert` statement, since it uses another function to setup the board and it should always return successful. It looked like:

```gd
assert(set_fen(INITIAL_FEN))
```

That worked in debug mode, which is what happens run you run the game in the editor. But it turns out, when you build the game in _release_ mode, it strips out the assert statements! That makes sense - you don't want the release game to seemingly randomly crash if some assert doesn't return what it expected, if the game could go on without it. All I needed do to make that work was replace that code with:

```gd
var success = set_fen(INITIAL_FEN)
assert(success)
```

Very simple - it now runs that code even in release mode, and I can still catch potential regressions when running the game in debug mode! I had to make similar changes to a few other assert statements.

And with that, I'm submitting!! I still might come back and add new features (having a button to copy the current game's PGN seems like a feasible and nice option), but I probably won't touch it again for a few days at least. I hope you all enjoy, and please let me know if you find any bugs!!

## Post-Jam Log

It's been a few weeks! While I did make some small touch ups and bug fixes shortly after the jam ended, nothing was really too notable. But about a week or so after, I started trying to write an actual chess engine into my program. I had some hiccups, but after a bit, I'm unexpectedly happy with the results so far! It's not _great_, and it certainly should be _way_ _**wayy**_ faster, but honestly... it can beat me basically every time ~~which means almost nothing because I'm complete trash at chess :D~~

Most of the engine I wrote a few weeks ago, so it's not all quite fresh in my mind. That said, I'll try to go over it.

The base of my AI is [negamax](https://en.wikipedia.org/wiki/Negamax) (variant of [minimax](https://en.wikipedia.org/wiki/Minimax)) with alpha beta pruning up to depth 3, followed by [quiescense search](https://en.wikipedia.org/wiki/Quiescence_search) up to depth 5. For the evaluation function, I am using the [simplified evaluation function](https://www.chessprogramming.org/Simplified_Evaluation_Function) (except currently I'm assuming we're always in a midgame). Really, that's most of it. I spent a lot of time mashing my head at the keyboard because some of this stuff is quite confusing, and the ending result is something that _really slow_ considering it's only searching to depth 3. A large portion of the slowness is due to my laziness in move generation - I'm doing quite a few things the naive way at the moment and could probably get a sizeable performance boost by optimizing that code.

On to smaller things: this week, I also updated what version of Godot I was using from 3.3.3 to 3.4 beta 5. That doesn't really affect much, but there were a few QOL improvements that I noticed that even affect the exported games (notably, in the game's settings menu, if you uncheck "Play Sounds", then the checkbox for "Play Sound on Check" gets properly dimmed. Neat).

Another thing I needed to do with the program was to make sure that the engine ran on another thread, since without it the entire program would freeze when the bot was thinking. For the desktop versions, that wasn't too hard - I could move the code where the bot was thinking into its own thread, add a nice little spinning animation, and that's it! I did have to make sure that you can't change the board state (undo, reset, make the bot start thinking again) while the bot is currently thinking, or else things would crash. But by disabling some buttons when you shouldn't be able to press them, that should all be mitigated.

Unfortunately I ran into a roadblock when exporting to the web. In order for Godot on the web to support threads, you need to [supply the web page with specific headers](https://docs.godotengine.org/en/3.4/getting_started/workflow/export/exporting_for_web.html#threads) for security reasons. Currently, [itch.io does not support that](https://itch.io/t/1028526/cross-origin-policies-for-webassembly), so I cannot use threading. For now, I've added some if statements that if you're running on HTML5, just use a blocking method. That causes the sound to absolutely freak out (so I disabled it during AI moves), but at least it works..... I'll be very happy when CORS gets implemented on itch and I can just use threading.

It's been a hot minute since the last time I updated this project. Since then, I've been working on smaller Godot project and become more familiar with the Godot practices, the style guide, and other recommendations. I felt it would be a good idea to fully refactor the code to conform to the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html), and while it might not be fully perfect, it's definitely better than it was before. Additionally, itch.io now [experimentally supports SharedArrayBuffer](https://itch.io/t/2025776/experimental-sharedarraybuffer-support) meaning that the multithreaded version of the program should work online now!! While it only seems to support chromium-based browsers at the moment, hopefully that changes in the future, and I uploaded a seperate version with SharedArrayBuffer support disabled in the meantime. There are still a few things I want to do with this project in the future, we'll see where I go with this!

# Credits/Attributions

See [CREDITS.md](CREDITS.md).
