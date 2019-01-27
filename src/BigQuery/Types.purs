module BigQuery.Types(QueryOpts(..)) where

type QueryOpts = forall a. 
  { query :: String
  , useLegacySql :: Boolean
  | a
  }
  
