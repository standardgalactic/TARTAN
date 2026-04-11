module Tartan.Trajectory
  ( summarizeRSVP
  ) where

import qualified Data.Vector as V
import Tartan.Grid
import Tartan.Defect (velocityMagnitudeMean)
import Tartan.Types

meanScalar :: ScalarField -> Double
meanScalar (ScalarField v)
  | V.null v = 0
  | otherwise = V.sum v / fromIntegral (V.length v)

summarizeRSVP :: Grid -> RSVP -> Summary
summarizeRSVP gr st =
  Summary
    { summaryPhiMean = meanScalar (phiField st)
    , summaryEntropyMean = meanScalar (entField st)
    , summaryVelocityMean = velocityMagnitudeMean gr (velField st)
    }
