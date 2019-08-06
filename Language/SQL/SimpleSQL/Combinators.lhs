
> -- | This module contains some generic combinators used in the
> -- parser. None of the parsing which relies on the local lexers is
> -- in this module. Some of these combinators have been taken from
> -- other parser combinator libraries other than Parsec.

> module Language.SQL.SimpleSQL.Combinators
>     (optionSuffix
>     ,(<??>)
>     ,(<??.>)
>     ,(<??*>)
>     ,(<$$>)
>     ,(<$$$>)
>     ,(<$$$$>)
>     ,(<$$$$$>)
>     ,(<$$$$$$>)
>     ) where

> import Control.Applicative ((<$>), (<*>), (<**>), pure, Applicative)
> import Text.Parsec (option,many)
> import Text.Parsec.String (GenParser)


a possible issue with the option suffix is that it enforces left
associativity when chaining it recursively. Have to review
all these uses and figure out if any should be right associative
instead, and create an alternative suffix parser

This function style is not good, and should be replaced with chain and
<??> which has a different type

> optionSuffix :: (a -> GenParser t s a) -> a -> GenParser t s a
> optionSuffix p a = option a (p a)


parses an optional postfix element and applies its result to its left
hand result, taken from uu-parsinglib

TODO: make sure the precedence higher than <|> and lower than the
other operators so it can be used nicely

> (<??>) :: GenParser t s a -> GenParser t s (a -> a) -> GenParser t s a
> p <??> q = p <**> option id q


Help with left factored parsers. <$$> is like an analogy with <**>:

f <$> a <*> b

is like

a <**> (b <$$> f)

f <$> a <*> b <*> c

is like

a <**> (b <**> (c <$$$> f))

> (<$$>) :: Applicative f =>
>       f b -> (a -> b -> c) -> f (a -> c)
> (<$$>) pa c = pa <**> pure (flip c)

> (<$$$>) :: Applicative f =>
>           f c -> (a -> b -> c -> t) -> f (b -> a -> t)
> p <$$$> c = p <**> pure (flip3 c)

> (<$$$$>) :: Applicative f =>
>           f d -> (a -> b -> c -> d -> t) -> f (c -> b -> a -> t)
> p <$$$$> c = p <**> pure (flip4 c)

> (<$$$$$>) :: Applicative f =>
>           f e -> (a -> b -> c -> d -> e -> t) -> f (d -> c -> b -> a -> t)
> p <$$$$$> c = p <**> pure (flip5 c)
>
> (<$$$$$$>) :: Applicative f' =>
>           f' f -> (a -> b -> c -> d -> e -> f -> t) -> f' (e -> d -> c -> b -> a -> t)
> p <$$$$$$> c = p <**> pure (flip6 c)


Surely no-one would write code like this seriously?


composing suffix parsers, not sure about the name. This is used to add
a second or more suffix parser contingent on the first suffix parser
succeeding.

> (<??.>) :: GenParser t s (a -> a) -> GenParser t s (a -> a) -> GenParser t s (a -> a)
> (<??.>) pa pb = (.) `c` pa <*> option id pb
>   -- todo: fix this mess
>   where c = (<$>) . flip


0 to many repeated applications of suffix parser

> (<??*>) :: GenParser t s a -> GenParser t s (a -> a) -> GenParser t s a
> p <??*> q = foldr ($) <$> p <*> (reverse <$> many q)


These are to help with left factored parsers:

a <**> (b <**> (c <**> pure (flip3 ctor)))

Not sure the names are correct, but they follow a pattern with flip
a <**> (b <**> pure (flip ctor))

> flip3 :: (a -> b -> c -> t) -> c -> b -> a -> t
> flip3 f a b c = f c b a

> flip4 :: (a -> b -> c -> d -> t) -> d -> c -> b -> a -> t
> flip4 f a b c d = f d c b a

> flip5 :: (a -> b -> c -> d -> e -> t) -> e -> d -> c -> b -> a -> t
> flip5 f a b c d e = f e d c b a

> flip6 :: (a -> b -> c -> d -> e -> f -> t) -> f -> e -> d -> c -> b -> a -> t
> flip6 f' a b c d e f = f' f e d c b a
