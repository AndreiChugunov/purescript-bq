module BigQuery.Types(QueryOpts) where

import Data.Nullable(Nullable)

type QueryOpts =
  { query :: String
  , useLegacySql :: Boolean
  , destination :: Nullable String
  }
  
