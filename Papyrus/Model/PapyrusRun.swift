//
//  PapyrusRun.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    typealias Run = [(offset: Offset, tile: Tile?)]
    typealias Runs = [Run]
    
    func currentRuns() -> LazySequence<Runs> {
        return runs(withTiles: tiles.placed(.Rack, owner: player))
    }
    
    /// Return an array of `runs` surrounding tiles played on the board.
    func runs(withTiles userTiles: [Tile]) -> LazySequence<Runs> {
        let fixedTiles = tiles.placed(.Fixed)
        let checkCentre = fixedTiles.count == 0
        let rackAmount = userTiles.count
        var runs = Runs()
        var buffer = Run()
        func validateRun(run: Run) {
            if checkCentre {
                if run.count > 1 && run.count <= rackAmount && run.filter({ $0.0 == PapyrusMiddleOffset }).count > 0 {
                    runs.append(run)
                }
            } else {
                let count = run.mapFilter({ $0.1 }).filter({ fixedTiles.contains($0) }).count
                let diff = run.count - count
                if count > 0 && diff > 0 && diff <= rackAmount {
                    runs.append(run)
                }
            }
        }
        func checkOffset(offset: Offset?) {
            if let o = offset {
                buffer.append((o, fixedTiles.filter({ $0.square?.offset == o }).first))
                validateRun(buffer)
                (1..<buffer.count).map({
                    validateRun(Array(buffer[$0..<buffer.count]))
                })
            }
        }
        
        let range = 1...PapyrusDimensions
        for x in range {
            buffer = Run()
            range.map{ y in checkOffset(Offset.at(x: x, y: y)) }
        }
        for y in range {
            buffer = Run()
            range.map{ x in checkOffset(Offset.at(x: x, y: y)) }
        }
        return lazy(runs)
    }
}