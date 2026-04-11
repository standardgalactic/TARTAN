module Tartan.Retiling (maybeRetile) where

import Tartan.Grid
import Tartan.Tile
import Tartan.Types

maybeRetile :: Grid -> [ClassifiedDefect] -> [Tile] -> [Tile]
maybeRetile gr cds ts
  | resolutionCount >= 3 || severeResolution =
      let finer = tileGrid gr 5 4
          consensus = foldl place (zerosRSVP gr) ts
          place acc tile = embedRSVPAverage gr acc (tileRect tile) (tileState tile)
      in initTilesFromTruth gr finer consensus
  | otherwise = ts
  where
    resMags = [ defectMagnitude (classifiedDefect cd) | cd <- cds, defectClass cd == ResolutionLike ]
    resolutionCount = length resMags
    severeResolution = not (null resMags) && sum resMags / fromIntegral resolutionCount > 0.45
