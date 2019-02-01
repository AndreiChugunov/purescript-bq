module BigQuery.Core
  ( Client
  , Storage
  , createStorage
  , _createClient
  , query
  , queryToTable
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Function.Uncurried (Fn4, Fn9) as Fn
import Data.Function.Uncurried (runFn4, runFn9)
import Effect (Effect)
import Effect.Aff (Aff, Canceler, makeAff)
import Effect.Exception (Error)
import Foreign (Foreign)
import BigQuery.Types (QueryOpts)

foreign import data Client :: Type
foreign import data Storage :: Type

foreign import createStorage :: String -> Effect Storage
foreign import _createClient :: String -> String -> Effect Client
foreign import _query :: Fn.Fn4 (Error -> Effect Unit) (Foreign -> Effect Unit) Client QueryOpts (Effect Canceler)
foreign import _queryToTable :: Fn.Fn9 (Error -> Effect Unit) (Unit -> Effect Unit) Client Storage QueryOpts String String String String (Effect Canceler)

query :: Client -> QueryOpts -> Aff Foreign
query client opts = makeAff (\cb -> runFn4 _query (cb <<< Left) (cb <<< Right) client opts)

queryToTable :: Client -> Storage -> QueryOpts -> String -> String -> String -> String -> Aff Unit
queryToTable client storage opts dataset tablename bucketname filename = makeAff (\cb -> 
    runFn9 _queryToTable (cb <<< Left) (cb <<< Right) client storage opts dataset tablename bucketname filename)
