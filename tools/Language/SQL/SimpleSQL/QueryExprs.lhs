
These are the tests for the queryExprs parsing which parses multiple
query expressions from one string.

>{-# LANGUAGE OverloadedStrings #-}
> module Language.SQL.SimpleSQL.QueryExprs (queryExprsTests) where

> import Language.SQL.SimpleSQL.TestTypes
> import Language.SQL.SimpleSQL.Syntax

> queryExprsTests :: TestItem
> queryExprsTests = Group "query exprs" $ map (uncurry (TestStatements ansi2011))
>     [("select 1",[ms])
>     ,("select 1;",[ms])
>     ,("select 1;select 1",[ms,ms])
>     ,(" select 1;select 1; ",[ms,ms])
>     ,("SELECT CURRENT_TIMESTAMP;"
>      ,[SelectStatement $ makeSelect
>       {qeSelectList = [(Iden [Name Nothing "CURRENT_TIMESTAMP"],Nothing)]}])
>     ,("SELECT \"CURRENT_TIMESTAMP\";"
>      ,[SelectStatement $ makeSelect
>       {qeSelectList = [(Iden [Name (Just ("\"","\"")) "CURRENT_TIMESTAMP"],Nothing)]}])
>     ,("(with x as (with y as select 1) union select 1;", [ms])
>     ]
>   where
>     ms = SelectStatement $ makeSelect {qeSelectList = [(NumLit "1",Nothing)]}
