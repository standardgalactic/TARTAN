module Tartan.Consistency
  ( stepTile
  , tartanStep
  ) where

import RSVP.Dynamics (stepRSVP)
import Tartan.Grid
import Tartan.Repair (repairSweepClassified)
import Tartan.Types

stepTile :: Params -> Tile -> Tile
stepTile p tile =
  let tr = tileRect tile
      localGr = Grid (rw tr) (rh tr)
  in tile { tileState = stepRSVP p localGr (tileState tile) }

tartanStep :: Params -> Double -> Grid -> [Tile] -> [Overlap] -> [ClassifiedDefect] -> [Tile]
tartanStep p alpha gr ts ovs cds =
  let evolved = map (stepTile p) ts
  in repairSweepClassified alpha gr evolved ovs cds
