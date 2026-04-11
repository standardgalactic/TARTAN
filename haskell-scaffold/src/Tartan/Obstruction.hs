module Tartan.Obstruction
  ( quantizeDefect
  , classifyDefect
  , classifyDefects
  , updateObstructionLog
  , noveltyCount
  , classHistogram
  ) where

import qualified Data.Map.Strict as M
import Tartan.Types

bucket :: Double -> Int
bucket x = floor (x * 10.0)

quantizeDefect :: ClassifiedDefect -> SummaryKey
quantizeDefect ClassifiedDefect{classifiedDefect = d, defectClass = cls} =
  SummaryKey
    { keyClass = cls
    , keyPhiBin = bucket (defectPhi d)
    , keyVelBin = bucket (defectVelocity d)
    , keyEntBin = bucket (defectEntropy d)
    }

classifyDefect :: Defect -> ClassifiedDefect
classifyDefect d
  | defectMagnitude d < 0.12 || (defectPhi d > defectVelocity d + defectEntropy d && defectMagnitude d < 0.35) =
      ClassifiedDefect d GaugeLike GaugeAlign
  | defectVelocity d >= defectPhi d && defectMagnitude d < 0.85 =
      ClassifiedDefect d ResolutionLike RefineCover
  | otherwise =
      ClassifiedDefect d StructuralLike ExtendOntology

classifyDefects :: [Defect] -> [ClassifiedDefect]
classifyDefects = map classifyDefect

updateObstructionLog :: [ClassifiedDefect] -> ObstructionLog -> ObstructionLog
updateObstructionLog cds = foldr step
  where
    step cd = M.alter (Just . updateEntry cd) (quantizeDefect cd)
    updateEntry cd Nothing =
      LogEntry
        { entryCount = 1
        , entryLastMagnitude = defectMagnitude (classifiedDefect cd)
        , entryClass = defectClass cd
        , entryRepair = suggestedRepair cd
        }
    updateEntry cd (Just old) =
      old
        { entryCount = entryCount old + 1
        , entryLastMagnitude = defectMagnitude (classifiedDefect cd)
        , entryClass = defectClass cd
        , entryRepair = suggestedRepair cd
        }

noveltyCount :: [ClassifiedDefect] -> ObstructionLog -> Int
noveltyCount cds logMap = length [ cd | cd <- cds, M.notMember (quantizeDefect cd) logMap ]

classHistogram :: [ClassifiedDefect] -> (Int, Int, Int)
classHistogram = foldr step (0,0,0)
  where
    step cd (g,r,s) = case defectClass cd of
      GaugeLike      -> (g+1,r,s)
      ResolutionLike -> (g,r+1,s)
      StructuralLike -> (g,r,s+1)
