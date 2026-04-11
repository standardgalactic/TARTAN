module Tartan.Types
  ( ScalarField(..)
  , VectorField(..)
  , RSVP(..)
  , Tile(..)
  , Overlap(..)
  , Defect(..)
  , DefectClass(..)
  , ClassifiedDefect(..)
  , RepairAction(..)
  , Summary(..)
  , SummaryKey(..)
  , LogEntry(..)
  , ObstructionLog
  , Params(..)
  , Theta(..)
  , defaultParams
  , emptyLog
  ) where

import Data.Map.Strict (Map)
import Data.Vector (Vector)
import Tartan.Grid (Rect)

type Scalar = Double

newtype ScalarField = ScalarField { unScalar :: Vector Scalar }
  deriving (Eq, Show)

data VectorField = VectorField
  { vxField :: ScalarField
  , vyField :: ScalarField
  } deriving (Eq, Show)

data RSVP = RSVP
  { phiField :: ScalarField
  , velField :: VectorField
  , entField :: ScalarField
  } deriving (Eq, Show)

data Tile = Tile
  { tileId    :: Int
  , tileRect  :: Rect
  , tileState :: RSVP
  } deriving (Eq, Show)

data Overlap = Overlap
  { ovLeft  :: Int
  , ovRight :: Int
  , ovRect  :: Rect
  } deriving (Eq, Show)

data Defect = Defect
  { defectLeft      :: Int
  , defectRight     :: Int
  , defectPhi       :: Double
  , defectVelocity  :: Double
  , defectEntropy   :: Double
  , defectMagnitude :: Double
  } deriving (Eq, Show)

data DefectClass
  = GaugeLike
  | ResolutionLike
  | StructuralLike
  deriving (Eq, Ord, Show)

data RepairAction
  = GaugeAlign
  | RefineCover
  | ExtendOntology
  deriving (Eq, Ord, Show)

data ClassifiedDefect = ClassifiedDefect
  { classifiedDefect  :: Defect
  , defectClass       :: DefectClass
  , suggestedRepair   :: RepairAction
  } deriving (Eq, Show)

data Summary = Summary
  { summaryPhiMean      :: Double
  , summaryEntropyMean  :: Double
  , summaryVelocityMean :: Double
  } deriving (Eq, Ord, Show)

data SummaryKey = SummaryKey
  { keyClass    :: DefectClass
  , keyPhiBin   :: Int
  , keyVelBin   :: Int
  , keyEntBin   :: Int
  } deriving (Eq, Ord, Show)

data LogEntry = LogEntry
  { entryCount        :: Int
  , entryLastMagnitude :: Double
  , entryClass        :: DefectClass
  , entryRepair       :: RepairAction
  } deriving (Eq, Show)

type ObstructionLog = Map SummaryKey LogEntry

emptyLog :: ObstructionLog
emptyLog = mempty

data Params = Params
  { dt    :: Double
  , dPhi  :: Double
  , dVel  :: Double
  , dEnt  :: Double
  , gamma :: Double
  , kappa :: Double
  } deriving (Eq, Show)

newtype Theta = Theta { defectSmoothing :: Double }
  deriving (Eq, Show)

defaultParams :: Params
defaultParams = Params
  { dt = 0.05
  , dPhi = 0.08
  , dVel = 0.05
  , dEnt = 0.04
  , gamma = 0.08
  , kappa = 0.20
  }
