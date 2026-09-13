/*
This bot uses a lawnmower approach to (aggresively) claim nearby empty space early, relying on 
inherited helper methods such as getFreeDirs() and game.isUnclaimed() to make decisions.
When no nearby empty space is available, the bot uses BFS (pathfinding) to find the nearest unclaimed
block and move towards it before resuming the lawnmower method.
This bot stores state with instance variables so it can adapt its behavior over times, including 
switching to a more defensive strategy later in the game by using game.getProgress().
*/

class HernandezArielleBot extends Bot { // my own bot created by inheriting from bot class!
  boolean goingRight = true; // remembers which direction lawnmower is sweeping (stores whether lawnmower is moving right/left)
  // CONSTRUCTOR
  HernandezArielleBot(int startX, int startY, color col, String name) {
    super(startX, startY, col, name); // calls constructor (for parent Bot class to be initialized properly)
  }
  Direction getNextMove(GameInfo game) { // method called every game step (where does the bot move next?)
    // MODE A: FILL (ALWAYS SCORE A POINT)!
    ArrayList<Direction> free = getFreeDirs(); // ask engine for all directions that lead to UNCLAIMED blocks
    if (free.size() > 0) { // if there is at least ONE unclaimed block next to us...
      return free.get(0); // move to it to score a point!
    }
    // MODE B: ESCAPE TO NEAREST UNCLAIMED BLOCKS!
    return bfsStepToNearestUnclaimed(game); // if not, use BFS to escape (finds closest empty block)
  }
  // BFS METHOD: SHORTEST PATH TO UNCLAIMED BLOCKS
  Direction bfsStepToNearestUnclaimed(GameInfo game) { // helper method that uses BFS to find closest unclaimed block
    int rows = game.rows; // # of rows in grid
    int cols = game.cols; // # of columns in grid
    boolean[][] visited = new boolean[rows][cols]; // keeps track of which blocks we already checked
    int[][] firstDir = new int[rows][cols]; // remembers first direction needed to reach each block
    int[] qx = new int[rows * cols]; // arrays that stores BFS queue x positions
    int[] qy = new int[rows * cols]; // arrays that stores BFS queue y positions
    int head = 0; // head points to front of queue (which block to process next?)
    int tail = 0; // tail points to back (where to add new blocks?)
    // LINE THEM UP IN QUEUE
    qx[tail] = this.x; // add starting x position to queue
    qy[tail] = this.y; // add starting y position too
    visited[this.y][this.x] = true; // mark starting block as visited
    firstDir[this.y][this.x] = -1; // -1 means we have NOT moved yet
    tail++; // move tail forward since we added one item
    while (head < tail) { // continue searching while there are no blocks in queue (head < tail means queue is NOT empty)
      int x = qx[head]; // get x value at front of queue
      int y = qy[head]; // get y value at front too
      head++; // move head forward to process next item
      // FOUND AN UNCLAIMED BLOCK!!!
      if (game.isUnclaimed(y, x) && !(x == this.x && y == this.y)) { // if this block is unclaimed (we stop BFS when we find an unclaimed block) & NOT our starting block...
        int d = firstDir[y][x]; // get first direction needed to reach this block
        return DIRS[d]; // return that direction so we move towards it
      }
      for (int d = 0; d < 4; d++) { // check all 4 directions from this block
        Direction dir = DIRS[d]; // get direction object (up/down/left/right)
        int nx = x + dir.dx; // calculate next x position (dx shifts x coordinate)
        int ny = y + dir.dy; // calculate next y position (dy shifts y coordinate)
        if (!game.inBounds(ny, nx)) continue; // skip if block is OUTSIDE grid
        if (visited[ny][nx]) continue; // skip if we already visited block
        visited[ny][nx] = true; // mark this new block as visited so BFS doesn't repeat it
        // if we're just starting, store this direction; otherwise, copy original first direction (bc we must remember first move taken!)
        firstDir[ny][nx] = (firstDir[y][x] == -1) ? d : firstDir[y][x];
        qx[tail] = nx; // add new x position to queue (store to tail index)
        qy[tail] = ny; // add new y position to queue
        tail++; // move tail forward
      }
    }
    // fallback (if no unclaimed blocks exist)
    return goingRight ? RIGHT : LEFT; // if BFS somehow fails, move in lawnmower direction
  }
}
