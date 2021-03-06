//: Playground - noun: a place where people can play

import UIKit

func == (lhs: Square, rhs: Square) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// ADVANCED:
// When player 1 is about to make a move, start calculating valid moves for player 2.
// Remove and recalculate invalidated ranges

enum Direction: CustomDebugStringConvertible {
    case Prev
    case Next
    var inverse: Direction {
        return self == .Prev ? .Next : .Prev
    }
    var debugDescription: String {
        return self == .Prev ? "Prev" : "Next"
    }
}

enum Axis: CustomDebugStringConvertible {
    case Horizontal(Direction)
    case Vertical(Direction)
    func inverse(direction: Direction) -> Axis {
        switch self {
        case .Horizontal(_): return .Vertical(direction)
        case .Vertical(_): return .Horizontal(direction)
        }
    }
    var direction: Direction {
        switch self {
        case .Horizontal(let dir): return dir
        case .Vertical(let dir): return dir
        }
    }
    var debugDescription: String {
        switch self {
        case .Horizontal(let dir): return "H-\(dir)"
        case .Vertical(let dir): return "V-\(dir)"
        }
    }
}

struct Position: Equatable, Hashable {
    let axis: Axis
    let iterable: Int
    let fixed: Int
    var hashValue: Int {
        return "\(axis.debugDescription),\(iterable),\(fixed)".hashValue
    }
    var isInvalid: Bool {
        return invalid(iterable) || invalid(fixed)
    }
    private func invalid(z: Int) -> Bool {
        return z < 0 || z >= Dimensions
    }
    private func adjust(z: Int, dir: Direction) -> Int {
        let n = dir == .Next ? z + 1 : z - 1
        return invalid(n) ? z : n
    }
    func newPosition() -> Position {
        return Position(axis: axis, iterable: adjust(iterable, dir: axis.direction), fixed: fixed)
    }
    func otherAxis(direction: Direction) -> Position {
        return Position(axis: axis.inverse(direction), iterable: iterable, fixed: fixed)
    }
    var isHorizontal: Bool {
        switch axis {
        case .Horizontal(_): return true
        case .Vertical(_): return false
        }
    }
    static func newPosition(axis: Axis, iterable: Int, fixed: Int) -> Position? {
        let position = Position(axis: axis, iterable: iterable, fixed: fixed)
        if position.isInvalid { return nil }
        return position
    }
}

func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Tile: CustomDebugStringConvertible {
    var letter: Character
    let value: Int
    init(_ letter: Character, _ value: Int) {
        self.letter = letter
        self.value = value
    }
    var debugDescription: String {
        return String(letter)
    }
}

class Square: CustomDebugStringConvertible, Equatable {
    enum Type {
        case None, Letterx2, Letterx3, Center, Wordx2, Wordx3
    }
    let type: Type
    var tile: Tile?
    init(_ type: Type) {
        self.type = type
    }
    var debugDescription: String {
        return String(tile?.letter ?? "_")
    }
}

let Dimensions = 15

var squares = [[Square]]()

// column <-> is horizontal
// row v^ is vertical

for row in 1...Dimensions {
    var line = [Square]()
    for col in 1...Dimensions {
        line.append(Square(.None))
    }
    squares.append(line)
}

squares[2][9].tile = Tile("R", 1)
squares[3][9].tile = Tile("E", 1)
squares[4][9].tile = Tile("S", 1)
squares[5][9].tile = Tile("U", 1)
squares[6][9].tile = Tile("M", 3)
squares[8][9].tile = Tile("S", 1)

squares[7][5].tile = Tile("A", 1)
squares[7][6].tile = Tile("R", 1)
squares[7][7].tile = Tile("C", 3)
squares[7][8].tile = Tile("H", 4)
squares[7][9].tile = Tile("E", 1)
squares[7][10].tile = Tile("R", 1)
squares[7][11].tile = Tile("S", 1)

squares[8][7].tile = Tile("A", 1)
squares[9][7].tile = Tile("R", 1)
squares[10][7].tile = Tile("D", 2)

squares[10][6].tile = Tile("A", 1)
squares[10][5].tile = Tile("E", 1)
squares[10][4].tile = Tile("D", 2)
squares[10][8].tile = Tile("E", 1)
squares[10][9].tile = Tile("R", 1)

squares[8][5].tile = Tile("R", 1)
squares[9][5].tile = Tile("I", 1)

// When a word is played, lets just store the playable boundary, rather than trying to
// calculate it after the fact, it's going to take too much computing power.
//

struct Boundary: CustomDebugStringConvertible {
    let start: Position
    let end: Position
    var debugDescription: String {
        return "\(start.iterable),\(start.fixed) - \(end.iterable), \(end.fixed)"
    }
    
    func encompasses(row: Int, column: Int) -> Bool {
        if start.isHorizontal {
            let sameRow = row == start.fixed && row == end.fixed
            let validColumn = column >= start.iterable && column <= end.iterable
            return sameRow && validColumn
        } else {
            let sameColumn = column == start.fixed && column == end.fixed
            let validRow = row >= start.iterable && row <= end.iterable
            return sameColumn && validRow
        }
    }
}

func letterAt(row: Int, _ col: Int) -> Character? {
    return squares[row][col].tile?.letter
}

/// Get string value of letters in a given boundary.
/// Does not currently check for gaps - use another method for gap checking and validation.
func readable(boundary: Boundary) -> String? {
    let start = boundary.start, end = boundary.end
    if start.iterable >= end.iterable { return nil }
    return String((start.iterable...end.iterable).map({ letterAt(
        start.isHorizontal ? start.fixed : $0,
        start.isHorizontal ? $0 : start.fixed)}))
}

//typealias Boundary = (start: Position, end: Position)
typealias Boundaries = [Boundary]
typealias PositionBoundaries = [Position: Boundary]

/// - Returns: False if outside of board boundaries.
private func outOfBounds(z: Int) -> Bool {
    return z < 0 || z >= Dimensions
}

var playedBoundaries = Boundaries()
// ARCHERS
playedBoundaries.append(Boundary(
    start: Position(axis: .Horizontal(.Prev), iterable: 5, fixed: 7),
    end: Position(axis: .Horizontal(.Next), iterable: 11, fixed: 7)))
// DEAD
playedBoundaries.append(Boundary(
    start: Position(axis: .Horizontal(.Prev), iterable: 4, fixed: 10),
    end: Position(axis: .Horizontal(.Next), iterable: 9, fixed: 10)))
// CARD
playedBoundaries.append(Boundary(start:
    Position(axis: .Vertical(.Prev), iterable: 7, fixed: 7), end:
    Position(axis: .Vertical(.Next), iterable: 10, fixed: 7)))
// ARIE
playedBoundaries.append(Boundary(start:
    Position(axis: .Vertical(.Prev), iterable: 7, fixed: 5), end:
    Position(axis: .Vertical(.Next), iterable: 10, fixed: 5)))
// RESUME
playedBoundaries.append(Boundary(start:
    Position(axis: .Vertical(.Prev), iterable: 2, fixed: 9), end:
    Position(axis: .Vertical(.Next), iterable: 8, fixed: 9)))


/// Returns square at given boundary
func squareAt(position: Position?) -> Square? {
    guard let position = position else { return nil }
    if position.isHorizontal {
        return squareAt(position.fixed, position.iterable)
    } else {
        return squareAt(position.iterable, position.fixed)
    }
}

func squareAt(row: Int, _ col: Int) -> Square {
    return squares[row][col]
}

func emptyAt(position: Position?) -> Bool {
    return squareAt(position)?.tile == nil
}

/// Loop while we are fulfilling the validator. 
/// Caveat: first position must pass validation prior to being sent to this method.
func loop(position: Position, validator: (position: Position) -> Bool, fun: ((position: Position) -> ())? = nil) -> Position? {
    // Return nil if square is outside of range (should only occur first time)
    if position.isInvalid { return nil }
    // Check new position.
    let newPosition = position.newPosition()
    let continued = validator(position: newPosition)
    if newPosition.isInvalid || !continued {
        fun?(position: position)
        return position
    } else {
        fun?(position: newPosition)
        return loop(newPosition, validator: validator, fun: fun) ?? newPosition
    }
}

/// Loop while we are fulfilling the empty value
func loop(position: Position, empty: Bool? = false, fun: ((position: Position) -> ())? = nil) -> Position? {
    // Return nil if square is outside of range (should only occur first time)
    // Return nil if this square is empty (should only occur first time)
    if position.isInvalid || emptyAt(position) != empty! { return nil }
    // Check new position.
    let newPosition = position.newPosition()
    if newPosition.isInvalid || emptyAt(newPosition) != empty! {
        fun?(position: position)
        return position
    } else {
        fun?(position: newPosition)
        return loop(newPosition, empty: empty, fun: fun)
    }
}

/*/// Method used to determine intersecting words.
func positionBoundaries(horizontal: Bool, row: Int, col: Int) -> PositionBoundaries {
    // Collect valid places to play
    var collected = PositionBoundaries()
    func collector(position: Position) {
        // Wrap collector when it needs to be moved, use another function to pass in an array
        if collected[position] == nil {
            let a = position.otherAxis(.Prev)
            let b = position.otherAxis(.Next)
            if let first = loop(a), last = loop(b) {
                // Add/update boundary
                collected[position] = Boundary(start: first, end: last)
            }
        }
    }
    
    // Find boundaries of this word
    let a = Position(axis: horizontal ? .Column(.Prev) : .Row(.Prev), row: row, col: col)
    let b = Position(axis: horizontal ? .Column(.Next) : .Row(.Next), row: row, col: col)
    if let first = loop(a, fun: collector), last = loop(b, fun: collector) {
        // Print start and end of word
        print(first)
        print(last)
        // And any squares that are filled around this word (non-recursive)
        print(collected)
    }
    return collected
}
*/


/// Returns all 'readable' values for a given array of position boundaries.
/// Essentially, all words.
/*func readable(positionBoundaries: PositionBoundaries) -> [String] {
    var output = [String]()
    for (position, range) in positionBoundaries {
        if position != range.start || position != range.end {
            if let word = readable(range) {
                output.append(word)
            }
        }
    }
    var sorted = positionBoundaries.keys.sort { (lhs, rhs) -> Bool in
        if lhs.isHorizontal {
            return lhs.row < rhs.row
        } else {
            return lhs.col < rhs.col
        }
    }
    if let first = sorted.first, last = sorted.last where first != last {
        if let word = readable(Boundary(start: first, end: last)) {
            output.append(word)
        }
    }
    return output
}
*/
/*
// Determine boundaries of words on the board (hard coded positions)

positionBoundaries(true, row: 8, col: 6)

let arcWords = readable(positionBoundaries(true, row: 7, col: 7))

let arieWords = readable(positionBoundaries(true, row: 10, col: 4))

let deadWords = readable(positionBoundaries(false, row: 10, col: 7))

validate(deadWords)

validate(arieWords)
*/

var playableBoundaries = Boundaries()

/// - Parameter: Initial position to begin this loop, will call position's axis->direction to determine next position.
/// - Returns: Furthest possible position from initial position usign rackCount.
func getPositionLoop(initial: Position) -> Position {
    var counter = rackCount
    func decrementer(position: Position) -> Bool {
        if emptyAt(position) { counter-- }
        return counter > -1
    }
    let position = loop(initial, validator: decrementer) ?? initial
    return position
}

/// This method will be used by AI to determine location where play is allowed.
/// - Parameter boundaries: Boundaries to use for intersection.
/// - Returns: Areas where play may be possible intersecting the given boundaries.
func findPlayableBoundaries(boundaries: Boundaries) -> Boundaries {
    var allBoundaries = Boundaries()
    for boundary in boundaries {
        var currentBoundaries = Boundaries()
        let startPosition = getPositionLoop(boundary.start)
        let endPosition = getPositionLoop(boundary.end)
        let start = boundary.start
        let end = boundary.end
        for i in startPosition.iterable...endPosition.iterable {
            assert(!outOfBounds(i))
            let s = i > start.iterable ? start.iterable : i
            let e = i < end.iterable ? end.iterable : i
            if e - s < 11 {
                guard let iterationStart = Position.newPosition(boundary.start.axis, iterable: s, fixed: start.fixed),
                    iterationEnd = Position.newPosition(boundary.end.axis, iterable: e, fixed: end.fixed) else { continue }
                let boundary = Boundary(start: iterationStart, end: iterationEnd)
                if currentBoundaries.filter({$0.start == iterationStart && $0.end == iterationStart}).count == 0 {
                    currentBoundaries.append(boundary)
                }
            }
        }
        
        let inverseAxisStart = boundary.start.axis.inverse(.Prev)
        let inverseAxisEnd = boundary.end.axis.inverse(.Next)
        
        for i in boundary.start.iterable...boundary.end.iterable {
            guard let startPosition = Position.newPosition(inverseAxisStart, iterable: start.fixed, fixed: i),
                endPosition = Position.newPosition(inverseAxisEnd, iterable: end.fixed, fixed: i) else { continue }
            
            let iterationStart = getPositionLoop(startPosition)
            let iterationEnd = getPositionLoop(endPosition)
            let boundary = Boundary(start: iterationStart, end: iterationEnd)
            if currentBoundaries.filter({$0.start == iterationStart && $0.end == iterationEnd}).count == 0 {
                currentBoundaries.append(boundary)
            }
        }

        allBoundaries.extend(currentBoundaries)
    }
    return allBoundaries
}

// Now determine playable boundaries
let rackCount = 2
playableBoundaries = findPlayableBoundaries(playedBoundaries)

for row in 0...Dimensions-1 {
    var line = [Character]()
    for col in 0...Dimensions-1 {
        var letter: Character = "_"
        for boundary in playableBoundaries {
            if boundary.encompasses(row, column: col) {
                letter = letterAt(row, col) ?? "#"
                break
            }
        }
        line.append(letter)
    }
    print(line)
}
print(playableBoundaries.count)
