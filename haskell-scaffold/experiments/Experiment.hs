module Experiment (runExperiment) where

import qualified Data.Map.Strict as M
import Text.Printf (printf)
import RSVP.Dynamics (syntheticTruth)
import Tartan.CLIO (updateTheta)
import Tartan.Consistency (tartanStep)
import Tartan.Defect (allDefects, totalDefect)
import Tartan.Grid
import Tartan.Obstruction
import Tartan.Overlap (buildOverlaps)
import Tartan.Retiling (maybeRetile)
import Tartan.Tile (initTilesFromTruth, zerosRSVP, embedRSVPAverage)
import Tartan.Types
import Tartan.Trajectory (summarizeRSVP)
import Visualization.PPM (writeSnapshot)

consensus :: Grid -> [Tile] -> RSVP
consensus gr = foldl place (zerosRSVP gr)
  where
    place acc tile = embedRSVPAverage gr acc (tileRect tile) (tileState tile)

runExperiment :: IO ()
runExperiment = do
  let gr = Grid 80 60
      truth = syntheticTruth gr
      rects = tileGrid gr 4 3
      tiles0 = initTilesFromTruth gr rects truth
      overlaps0 = buildOverlaps gr 2 tiles0
      theta0 = Theta 0.25
  putStrLn "Running staged-closure TARTAN scaffold..."
  go gr defaultParams theta0 emptyLog overlaps0 0 20 tiles0

go :: Grid -> Params -> Theta -> ObstructionLog -> [Overlap] -> Int -> Int -> [Tile] -> IO ()
go gr params theta logMap ovs step maxSteps ts
  | step >= maxSteps = putStrLn "Done."
  | otherwise = do
      let ds = allDefects gr ts ovs
          cds = classifyDefects ds
          td = totalDefect ds
          novel = noveltyCount cds logMap
          logMap' = updateObstructionLog cds logMap
          theta' = updateTheta theta td cds
          alpha = defectSmoothing theta'
          ts1 = tartanStep params alpha gr ts ovs cds
          ts2 = maybeRetile gr cds ts1
          ovs' = buildOverlaps gr 2 ts2
          world = consensus gr ts2
          sig = summarizeRSVP gr world
          (gaugeN, refineN, structuralN) = classHistogram cds
      printf "iteration %02d | tiles = %2d | overlaps = %3d | defect = %.6f | alpha = %.4f | G/R/S = %d/%d/%d | novel = %d | log = %d | phiMean = %.4f\n"
        step (length ts2) (length ovs') td alpha gaugeN refineN structuralN novel (M.size logMap') (summaryPhiMean sig)
      writeSnapshot "out" step gr world
      go gr params theta' logMap' ovs' (step + 1) maxSteps ts2
