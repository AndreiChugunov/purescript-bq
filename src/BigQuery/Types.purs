module BigQuery.Types(QueryOpts) where

data QueryOpts = 
  BaseOptions
  { query :: String
  , useLegacySql :: Boolean
  }
  |
  CsvOptions
  { query :: String
  , useLegacySql :: Boolean
  , destination :: String
  }
