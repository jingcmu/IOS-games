//
//  Grid.m
//  GameOfLife
//
//  Created by 靖 陈 on 5/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Creature.h"

static const int GRID_ROWS = 8;
static const int GRID_COLUMNS = 10;

@implementation Grid {
    NSMutableArray *_gridArray;
    float _cellWidth;
    float _cellHeight;
    int _generation;
    int _totalAlive;
}

- (void)onEnter
{
    [super onEnter];
    
    [self setupGrid];
    
    // accept touches on the grid
    self.userInteractionEnabled = TRUE;
}

- (void)setupGrid
{
    // divide the grid's size by the number of columns/rows to figure out the right width and height of each cell
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    
    float x = 0;
    float y = 0;
    
    // initialize the array as a blank NSMutableArray
    _gridArray = [NSMutableArray array];
    
    // initialize Creatures
    for (int i = 0; i < GRID_ROWS; i++) {
        // this is how you create two dimensional arrays in Objective-C. You put arrays into arrays.
        _gridArray[i] = [NSMutableArray array];
        x = 0;
        
        for (int j = 0; j < GRID_COLUMNS; j++) {
            Creature *creature = [[Creature alloc] initCreature];
            creature.anchorPoint = ccp(0, 0);
            creature.position = ccp(x, y);
            [self addChild:creature];
            
            // this is shorthand to access an array inside an array
            _gridArray[i][j] = creature;
            
            // make creatures visible to test this method, remove this once we know we have filled the grid properly
            creature.isAlive = false;
            
            x+=_cellWidth;
        }
        
        y += _cellHeight;
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //get the x,y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];
    
    //get the Creature at that location
    Creature *creature = [self creatureForTouchPosition:touchLocation];
    
    //invert it's state - kill it if it's alive, bring it to life if it's dead.
    creature.isAlive = !creature.isAlive;
}

- (Creature *)creatureForTouchPosition:(CGPoint)touchPosition
{
    NSInteger y = (NSInteger)(touchPosition.y/_cellWidth);
    NSInteger x = (NSInteger)(touchPosition.x/_cellWidth);
    //get the row and column that was touched, return the Creature inside the corresponding cell
    return _gridArray[y][x];
}

- (BOOL)isIndexValidForX:(int)x andY:(int)y
{
    BOOL isIndexValid = TRUE;
    if(x < 0 || y < 0 || y >= GRID_ROWS || x >= GRID_COLUMNS)
    {
        isIndexValid = FALSE;
    }
    return isIndexValid;
}

- (void)countNeighbors
{
    // iterate through the rows
    // note that NSArray has a method 'count' that will return the number of elements in the array
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            // access the creature in the cell that corresponds to the current row/column
            Creature *currentCreature = _gridArray[i][j];
            
            // remember that every creature has a 'livingNeighbors' property that we created earlier
            currentCreature.livingNeighbors = 0;
            
            // now examine every cell around the current one
            
            // go through the row on top of the current cell, the row the cell is in, and the row past the current cell
            for (int y = (i-1); y <= (i+1); y++)
            {
                // go through the column to the left of the current cell, the column the cell is in, and the column to the right of the current cell
                for (int x = (j-1); x <= (j+1); x++)
                {
                    // check that the cell we're checking isn't off the screen
                    BOOL isIndexValid;
                    isIndexValid = [self isIndexValidForX:x andY:y];
                    
                    // skip over all cells that are off screen AND the cell that contains the creature we are currently updating
                    if (!((y == i) && (x == j)) && isIndexValid)
                    {
                        Creature *neighbor = _gridArray[y][x];
                        if (neighbor.isAlive)
                        {
                            currentCreature.livingNeighbors += 1;
                        }
                    }
                }
            }
        }
    }
}

- (void)updateCreatures
{
    _totalAlive = 0;
    // iterate through the rows
    // note that NSArray has a method 'count' that will return the number of elements in the array
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            // access the creature in the cell that corresponds to the current row/column
            Creature *currentCreature = _gridArray[i][j];
            if(currentCreature.isAlive == true && (currentCreature.livingNeighbors < 2 || currentCreature.livingNeighbors > 3)) {
                currentCreature.isAlive = false;
            }
            else if(currentCreature.isAlive == false && currentCreature.livingNeighbors == 3) {
                currentCreature.isAlive = true;
            }
            if(currentCreature.isAlive == true) {
                _totalAlive++;
            }
        }
    }
}

- (void)evolveStep
{
    //update each Creature's neighbor count
    [self countNeighbors];
    
    //update each Creature's state
    [self updateCreatures];
    
    //update the generation so the label's text will display the correct generation
    _generation++;
}

@end
