# Set4a

## Ex 1

### 問題

```haskell
-- Ex 1: implement the function allEqual which returns True if all
-- values in the list are equal.
--
-- Examples:
--   allEqual [] ==> True
--   allEqual [1,2,3] ==> False
--   allEqual [1,1,1] ==> True
--
-- PS. check out the error message you get with your implementation if
-- you remove the Eq a => constraint from the type!

allEqual :: Eq a => [a] -> Bool
allEqual xs = todo
```

### Step 1

```haskell
allEqual (x:rest@(y:xs)) = x == y && allEqual rest
allEqual _ = True
```

関数の型定義から `Eq a =>` をなくした場合、次のようなエラーが出た。

```
Set4a.hs:38:30: error:
    • No instance for (Eq a) arising from a use of ‘==’
      Possible fix:
        add (Eq a) to the context of
          the type signature for:
            allEqual :: forall a. [a] -> Bool
    • In the first argument of ‘(&&)’, namely ‘x == y’
      In the expression: x == y && allEqual rest
      In an equation for ‘allEqual’:
          allEqual (x : rest@(y : xs)) = x == y && allEqual rest
   |
38 | allEqual (x:rest@(y:xs)) = x == y && allEqual rest
   |                              ^^
```

### Step 2

#### 2a

`Eq a` を `Ord a` に変えて `compare` を使ってみた。

```haskell
allEqual :: (Ord a) => [a] -> Bool
allEqual (x:rest@(y:xs)) = compare x y == EQ && allEqual rest
allEqual _ = True
```

#### 2b

`foldr` を使って解く方法を考えてみたが、連続する要素の比較をしないといけない場合に相性が悪そうで、やり方が思いつかなかった。

畳み込みの結果をBoolではなく、a -> Bool、つまり直前の要素を受け取って等しいか判定する関数にすれば情報を運べる。

```haskell
allEqual [] = True
allEqual (x:xs) = foldr step (const True) xs x
  where
    step y k prev = prev == y && k y
```

`foldl` を `foldr` で定義するテクニックと同じ形らしい。

```haskell
foldl :: Foldable t => (b -> a -> b) -> b -> t a -> b

myFoldl f z xs = foldr step id xs z
  where
    step x k = \acc -> k (f acc x)
```

#### 2c

`Data.Foldable.all` を使えば簡単に書ける。

```haskell
all :: Foldable t => (a -> Bool) -> t a -> Bool
```

```haskell
allEqual [] = True
allEqual (x:xs) = all (== x) xs
```

下記のように書いても、xsが空の場合にheadが評価されずに終了するのでエラーにならない。

```haskell
allEqual xs = all (== head xs) xs
```

#### 2d

dropで新しいリストを構築するのでパフォーマンスは倍悪くなる。

```haskell
allEqual xs = and (zipWith (==) xs (drop 1 xs))
```

#### 2e

早期終了しないし、重複要素を除去するので効率は悪い。

```haskell
allEqual xs = length (nub xs) <= 1
```

### Step 3

本当は `all` を使った解答が一番楽に書けるので好きだが、練習問題なので空気を読んで再帰で書いた。

```haskell
allEqual (x:rest@(y:_)) = x == y && allEqual rest
allEqual _ = True
```

## Ex 2

### 問題

```haskell
-- Ex 2: implement the function distinct which returns True if all
-- values in a list are different.
--
-- Hint: a certain function from the lecture material can make this
-- really easy for you.
--
-- Examples:
--   distinct [] ==> True
--   distinct [1,1,2] ==> False
--   distinct [1,2] ==> True

distinct :: Eq a => [a] -> Bool
distinct = todo
```

### Step 1

2回走査しないといけないので効率は悪いが、楽に書ける。

```haskell
distinct xs = length xs == length (nub xs)
```

### Step 2

#### 2a

これも効率悪いけど。

```haskell
distinct xs = length xs == (length $ filter (\p -> fst p == snd p) [(x1, x2) | x1 <- xs, x2 <- xs])
```

#### 2b

`Data.OldList.nub` の内部実装。

```haskell
nub :: Eq a => [a] -> [a]
nub = nubBy (==)

nubBy :: (a -> a -> Bool) -> [a] -> [a]
nubBy eq l = nubBy' l []
  where
    nubBy' [] _ = []
    nubBy' (y:ys) xs
      | elem_by eq y xs = nubBy' ys xs
      | otherwise = y : nubBy' ys (y:xs)

elem_by :: (a -> a -> Bool) -> a -> [a] -> Bool
elem_by _ _ [] = False
elem_by eq x (y:ys) = x `eq` y || elem_by eq x ys
```

時間計算量は `O(n^2)` 。

#### 2c

step 1同様に `O(n^2)` だが、短絡評価が走るし、 `==` の実行回数は半分の `(n^2) / 2` 。

```haskell
distinct [] = True
distinct (x:xs) = notElem x xs && distinct xs
```

#### 2d

既出要素を保持する。

```haskell
distinct = go []
  where
    go _ [] = True
    go ys (x:xs) = notElem x ys && go (x:ys) xs
```

#### 2e

`Data.Set` を使う。

```haskell
distinct :: Ord a => [a] -> Bool
distinct = go Set.empty
  where
    go _ [] = True
    go seen (x:xs) = not (Set.member x seen) && go (Set.insert x seen) xs
```

### Step 3

```haskell
distinct [] = True
distinct (x:xs) = notElem x xs && distinct xs
```

## Ex 3

### 問題

```haskell
-- Ex 3: implement the function middle that returns the middle value
-- (not the smallest or the largest) out of its three arguments.
--
-- The function should work on all types in the Ord class. Give it a
-- suitable type signature.
--
-- Examples:
--   middle 'b' 'a' 'c'  ==> 'b'
--   middle 1 7 3        ==> 3

middle = todo
```

### Step 1

```haskell
middle x y z = go [x, y, z]
  where
    go xs = sort xs !! 1
```

無駄に冗長に書いていた。

```haskell
middle x y z = sort [x, y, z] !! 1
```

### Step 2

#### 2a

```haskell
middle x y z = case x < y of
  True -> case y < z of
    True -> y
    otherwise -> max x z
  otherwise -> case x < z of
    True -> x
    otherwise -> max y z
```

`case of` の場合、ガードを使うときと違って `otherwise` はBoolを返す関数ではなく変数として扱われてしまう。

```haskell
middle x y z = case x < y of
  True -> case y < z of
    True -> y
    _ -> max x z
  _ -> case x < z of
    True -> x
    _ -> max y z
```

#### 2b

バブルソート。末尾再帰になっている。

```haskell
middle x y z
  | y > z = middle x z y
  | x > y = middle y x z
  | otherwise = y
```

停止性を証明できると尚よい。順序が逆転している箇所（転倒数と言うらしい）が0になれば停止し、毎回1減少するので停止する。

#### 2c

```haskell
middle x y z
  | isBetween x y z = y
  | isBetween y z x = z
  | otherwise = x
  where isBetween a b c = (a <= b && b <= c) || (c <= b && b <= a)
```

### Step 3

```haskell
middle x y z = case sort [x, y, z] of
  (_:m:_) -> m
```

## Ex 4

### 問題

```haskell
-- Ex 4: return the range of an input list, that is, the difference
-- between the smallest and the largest element.
--
-- Your function should work on all suitable types, like Float and
-- Int. You'll need to add _class constraints_ to the type of range.
--
-- It's fine if your function doesn't work for empty inputs.
--
-- Examples:
--   rangeOf [4,2,1,3]          ==> 3
--   rangeOf [1.5,1.0,1.1,1.2]  ==> 0.5

rangeOf :: [a] -> a
rangeOf = todo
```

### Step 1

エラーが出てしまった。

```haskell
rangeOf :: Num a => [a] -> a
rangeOf [] = 0
rangeOf [x] = 0
rangeOf xs = maximum xs - minimum xs
```

```
Set4a.hs:88:14: error:
    • Could not deduce (Ord a) arising from a use of ‘maximum’
      from the context: Num a
        bound by the type signature for:
                   rangeOf :: forall a. Num a => [a] -> a
        at Set4a.hs:85:1-28
      Possible fix:
        add (Ord a) to the context of
          the type signature for:
            rangeOf :: forall a. Num a => [a] -> a
    • In the first argument of ‘(-)’, namely ‘maximum xs’
      In the expression: maximum xs - minimum xs
      In an equation for ‘rangeOf’: rangeOf xs = maximum xs - minimum xs
   |
88 | rangeOf xs = maximum xs - minimum xs
   |              ^^^^^^^
```

型aの制約が `Num` だけじゃ足りなくて、 `maximum` , `minimum` を使うために `Ord` も必要だった。

```haskell
rangeOf :: (Ord a, Num a) => [a] -> a
rangeOf [] = 0
rangeOf [x] = 0
rangeOf xs = maximum xs - minimum xs
```

### Step 2

#### 2a

step 1は `maximum` と `minimum` で2回走査しないといけないので、一回で済むように書く。

```haskell
rangeOf :: (Ord a, Num a) => [a] -> a
rangeOf = go Nothing Nothing
  where
    go Nothing Nothing [] = 0
    go (Just mx) (Just mn) [] = mx - mn
    go Nothing Nothing (x:xs) = go (Just x) (Just x) xs
    go (Just mx) (Just mn) (x:xs) = go (Just (max mx x)) (Just (min mn x)) xs
```

このままだとmax/minのサンクが蓄積してしまう問題があるので、WHNFまで評価するようにする。

```haskell
rangeOf (x:xs) = go x x xs
  where
    go !mx !mn [] = mx - mn
    go !mx !mn (y:ys) = go (max mx y) (min mn y) ys
```

#### 2b

step 1の改善。問題文では空リストが入力にならないことが保証されているのに、空リストでもエラーにならずに0を返すように実装していた。 `Data.List.NonEmpty` を使って全域性を保証する。ただし、 `NonEmpty` はテストで渡されるリストとは型が異なるのでテストは通らない。

```haskell
import Data.List.NonEmpty (NonEmpty)
rangeOf :: (Ord a, Num a) => NonEmpty a -> a
rangeOf xs = maximum xs - minimum xs
```

### Step 3

```haskell
rangeOf :: (Ord a, Num a) => [a] -> a
rangeOf (x:xs) = go x x xs
  where
    go mx mn [] = mx - mn
    go !mx !mn (y:ys) = go (max mx y) (min mn y) ys
```

## Ex 5

### 問題

```haskell
-- Ex 5: given a (non-empty) list of (non-empty) lists, return the longest
-- list. If there are multiple lists of the same length, return the list that
-- has the smallest _first element_.
--
-- (If multiple lists have the same length and same first element,
-- you can return any one of them.)
--
-- Give the function "longest" a suitable type.
--
-- Challenge: Can you solve this exercise without sorting the list of lists?
--
-- Examples:
--   longest [[1,2,3],[4,5],[6]] ==> [1,2,3]
--   longest ["bcd","def","ab"] ==> "bcd"

longest = todo
```

### Step 1

```haskell
longest (x:xs) = go (length x) x xs
  where
    go _ y [] = y
    go ly y (z:zs) = let lz = length z in case compare ly lz of
      LT -> go lz z zs
      GT -> go ly y zs
      EQ -> case compare (head y) (head z) of
        GT -> go lz z zs
        _ -> go ly y zs
```

### Step 2

#### 2a

```haskell
longest :: Ord a => [[a]] -> [a]
longest = head . sortBy go
  where
    go x y = case compare (length x) (length y) of
      EQ -> compare (head x) (head y)
      LT -> GT
      GT -> LT
```

#### 2b

```haskell
longest :: Ord a => [[a]] -> [a]
longest = head . sortBy (comparing (Down . length) <> comparing head)
```

```haskell
comparing :: (b -> a) -> b -> b -> Ordering

sortBy :: (a -> a -> Ordering) -> [a] -> [a]
```

#### 2c

```haskell
-- Defined in Data.Foldable
maximumBy :: Foldable t => (a -> a -> Ordering) -> t a -> a

longest = maximumBy (comparing length <> comparing (Down . head))
```

### Step 3

```haskell
longest :: Ord a => [[a]] -> [a]
longest = maximumBy (comparing length <> comparing (Down . head))
```

## Ex 6

### 問題

```haskell
-- Ex 6: Implement the function incrementKey, that takes a list of
-- (key,value) pairs, and adds 1 to all the values that have the given key.
--
-- You'll need to add _class constraints_ to the type of incrementKey
-- to make the function work!
--
-- The function needs to be generic and handle all compatible types,
-- see the examples.
--
-- Examples:
--   incrementKey True [(True,1),(False,3),(True,4)] ==> [(True,2),(False,3),(True,5)]
--   incrementKey 'a' [('a',3.4)] ==> [('a',4.4)]

incrementKey :: k -> [(k,v)] -> [(k,v)]
incrementKey = todo
```

### Step 1

```haskell
incrementKey :: (Eq k, Num v) => k -> [(k,v)] -> [(k,v)]
incrementKey _ [] = []
incrementKey key (x:xs) = case fst x == key of
  True -> (key, snd x + 1) : incrementKey key xs
  _ -> x : incrementKey key xs
```

### Step 2

#### 2a

```haskell
incrementKey :: (Eq k, Num v) => k -> [(k,v)] -> [(k,v)]
incrementKey key = foldr go []
  where
    go (k, v) acc = case k == key of
      True -> (k, v+1) : acc
      _ -> (k, v) : acc
```

#### 2b

`foldr` なんか使わなくても `map` で十分だった。

```haskell
incrementKey key = map go
  where
    go (k, v) = if k == key
      then (k, v+1)
      else (k, v)
```

キーと一致しないペアに関しては展開する必要がないのでasパターンを使用して新しいペアを割り当てないようにする。

```haskell
incrementKey key = map step
  where
    step p@(k, v) = if k == key then (k, v+1) else p
```

#### 2c

リスト内包表記。

```haskell
incrementKey key kvs = [if k == key then (k, v+1) else (k, v) | (k, v) <- kvs]
```

### Step 3

```haskell
incrementKey key = map step
  where step p@(k, v) = if k == key then (k, v+1) else p
```

## Ex 7

### 問題

```haskell
-- Ex 7: compute the average of a list of values of the Fractional
-- class.
--
-- There is no need to handle the empty list case.
--
-- Hint! since Fractional is a subclass of Num, you have all
-- arithmetic operations available
--
-- Hint! you can use the function fromIntegral to convert the list
-- length to a Fractional

average :: Fractional a => [a] -> a
average xs = todo
```

### Step 1

```haskell
average xs = (sum xs) / (fromIntegral (length xs))
```

Haskellで小数を表現する代表的な型。

* `Float` : IEEE 754単精度2進浮動小数
  * プリミティブ型
* `Double` : IEEE 754倍精度2進浮動小数
  * プリミティブ型
* `Rational` : 有理数。 `Integer` の分数として表現される
  * `Data.Ratio` モジュール

```haskell
(/) :: Fractional a => a -> a -> a

div :: Integral a => a -> a -> a

fromIntegral :: (Integral a, Num b) => a -> b
```

### Step 2

#### 2a

全体の長さで割った値を積み上げる方法で書いてみた。割り算の回数が増え、丸められた値同士の加算で近似値と実際の値の誤差が積みあがってしまった。割り算の回数が多いことはパフォーマンスも劣化させる。一方、step 1と比べてsumが非常に大きい値でもオーバーフローしないという利点がある。

```haskell
average xs = let l = fromIntegral (length xs) in foldr (\x acc -> (x / l) + acc) 0.0 xs
```

```
===== EXERCISE 7
*** Failed! Falsified (after 3 tests):
average [1.0,2.0,3.0]
  Expected: 2.0
  Was: 1.9999999999999998

----- Fail
```

### Step 3

```haskell
average xs = sum xs / fromIntegral (length xs)
```

## Ex 8

### 問題

```haskell
-- Ex 8: given a map from player name to score and two players, return
-- the name of the player with more points. If the players are tied,
-- return the name of the first player (that is, the name of the
-- player who comes first in the argument list, player1).
--
-- If a player doesn't exist in the map, you can assume they have 0 points.
--
-- Hint: Map.findWithDefault can make this simpler
--
-- Examples:
--   winner (Map.fromList [("Bob",3470),("Jane",2130),("Lisa",9448)]) "Jane" "Lisa"
--     ==> "Lisa"
--   winner (Map.fromList [("Mike",13607),("Bob",5899),("Lisa",5899)]) "Lisa" "Bob"
--     ==> "Lisa"

winner :: Map.Map String Int -> String -> String -> String
winner scores player1 player2 = todo
```

### Step 1

```haskell
winner scores player1 player2 = if go player1 < go player2 then player2 else player1
  where
    go p = case Map.lookup p scores of
      Just i -> i
      _ -> 0
```

### Step 2

#### 2a

`Map.findWithDefault` で簡潔にした。

```haskell
winner scores player1 player2 = if go player1 < go player2 then player2 else player1
  where
    go p = Map.findWithDefault 0 p scores
```

#### 2b

`compare` において引数が `Maybe` 型のとき、 `Nothing` が最小として扱われることを利用する。

```haskell
> compare Nothing (Just 1)
LT
> compare Nothing (Just (-1))
LT
```

```haskell
winner scores player1 player2 = if compare (Map.lookup player1 scores) (Map.lookup player2 scores) == LT
  then player2
  else player1
```

ただし、マップの値に負の数が入り得る場合、キーのないプレーヤーより負の得点のプレーヤーの方が得点数が多いと扱われてしなうことに注意する。

#### 2c

```haskell
winner scores player1 player2
  | playerScore player1 scores < playerScore player2 scores = player2
  | otherwise = player1

playerScore :: String -> Map.Map String Int -> Int
playerScore p = Map.findWithDefault 0 p
```

### Step 3

デフォルト値を定義してルックアップする関数は他にも用途がありそうなので、関数内ヘルパーではなく、モジュールレベルの関数として定義した。

```haskell
winner scores player1 player2 = if playerScore scores player1 < playerScore scores player2 then player2 else player1

playerScore :: Map.Map String Int -> String -> Int
playerScore scores player = Map.findWithDefault 0 player scores
```

## Ex 9

### 問題

```haskell
-- Ex 9: compute how many times each value in the list occurs. Return
-- the frequencies as a Map from value to Int.
--
-- Challenge 1: try using Map.alter for this
--
-- Challenge 2: use foldr to process the list
--
-- Example:
--   freqs [False,False,False,True]
--     ==> Map.fromList [(False,3),(True,1)]

freqs :: (Eq a, Ord a) => [a] -> Map.Map a Int
freqs xs = todo
```

### Step 1

```haskell
freqs xs = go xs Map.empty
  where
    go [] map = map
    go (y:ys) map = go ys (Map.alter (\z -> Just (fromMaybe 0 z + 1)) y map)
```

```haskell
Map.alter :: Ord k => (Maybe a -> Maybe a) -> k -> Map.Map k a -> Map.Map k a
```

### Step 2

#### 2a

step 1の `Map.alter` の第一引数の関数がMaybe型を解除してからまたMaybeに戻しているのが冗長だったのでパターンマッチに変えた。その代わり、ヘルパーが増えて可読性が落ちたかも。

```haskell
freqs xs = step xs Map.empty
  where
    step [] map = map
    step (y:ys) map = step ys (Map.alter go y map)
    go Nothing = Just 1
    go (Just n) = Just (n+1)
```

#### 2b

`foldr` を使う。step 1や2aよりシンプルになった。 `Data.Map` は `Data.Map.Lazy` なので平衡二分木の各ノードの値が遅延評価される。今回は(((1+1)+1)+1)のようにサンクが積み上がる。

```haskell
foldr :: (a -> b -> b) -> b -> [a] -> b

freqs = foldr (\x map -> Map.alter go x map) Map.empty
  where
    go Nothing = Just 1
    go (Just n) = Just (n+1)
```

#### 2c

`Data.Maybe` の `maybe` を使えばもっとシンプルに書けた。

```haskell
maybe :: b -> (a -> b) -> Maybe a -> b

freqs = foldr (\x map -> Map.alter go x map) Map.empty
  where go = Just . maybe 1 (+1)
```

#### 2d

`Map.insertWith` を使えばもっとシンプルに書けた。 `insertWith f key value map` は `key` が `map` になければ `(key, value)` を挿入し、既にあれば `f new_value old_value` で `key` の値を上書きする。

```haskell
insertWith :: Ord k => (a -> a -> a) -> k -> a -> Map k a -> Map k a

freqs = foldr (\x -> Map.insertWith (+) x 1) Map.empty
```

#### 2e

`foldr` はMapの構築とは相性が悪いので `foldl'` に変える。

```haskell
foldl' :: (b -> a -> b) -> b -> [a] -> b
foldl' _ z [] = z
foldl' f z (x:xs) = let z' = f z x
                    in z' `seq` foldl' f z' xs

-- seq は第2引数を評価する前に第1引数をWHNFまで評価させる
seq :: a -> b -> b

freqs = foldl' (\map x -> Map.insertWith (+) x 1 map) Map.empty
```

### Step 3

```haskell
freqs = foldl' (\m x -> Map.insertWith (+) x 1 m) Map.empty
```

## Ex 10

### 問題

```haskell
-- Ex 10: recall the withdraw example from the course material. Write a
-- similar function, transfer, that transfers money from one account
-- to another.
--
-- However, the function should not perform the transfer if
-- * the from account doesn't exist,
-- * the to account doesn't exist,
-- * the sum is negative,
-- * or the from account doesn't have enough money.
--
-- Hint: there are many ways to implement this logic. Map.member or
-- Map.notMember might help.
--
-- Examples:
--   let bank = Map.fromList [("Bob",100),("Mike",50)]
--   transfer "Bob" "Mike" 20 bank
--     ==> fromList [("Bob",80),("Mike",70)]
--   transfer "Bob" "Mike" 120 bank
--     ==> fromList [("Bob",100),("Mike",50)]
--   transfer "Bob" "Lisa" 20 bank
--     ==> fromList [("Bob",100),("Mike",50)]
--   transfer "Lisa" "Mike" 20 bank
--     ==> fromList [("Bob",100),("Mike",50)]

transfer :: String -> String -> Int -> Map.Map String Int -> Map.Map String Int
transfer from to amount bank = todo
```

### Step 1

最初にO(1)時間で `amount` の0未満判定をすることによって、O(log n)時間かかる `fromBalance` , `toBalance` を評価しなくて済むケースを作っている（効果はかなり限定的）。

`Just (fromJust x + amount)` などMaybe型の扱いがぎこちない部分がある。

```haskell
transfer from to amount bank
  | amount < 0 = bank -- 送金金額が0未満
  | fromBalance == Nothing = bank
  | toBalance == Nothing = bank
  | fromJust fromBalance - amount < 0 = bank -- 送金側のお金が足りない
  | otherwise = Map.alter (\x -> Just (fromJust x + amount)) to (Map.alter (\x -> Just (fromJust x - amount)) from bank)
  where
    fromBalance = Map.lookup from bank
    toBalance = Map.lookup to bank
```

### Step 2

#### 2a

step 1をブラッシュアップする。

* `fromBalance == Nothing` より `isNothing fromBalance`
  * `==` 演算子を使う場合は `fromBalance` に `Eq` 制約を要求することになる
* `(\x -> Just (fromJust x + amount))` は `fmap` を使えば `fmap (+ amount)` のようにシンプルに書き換えられる
  * `fmap` は `Functor` 型クラスに対して使える。 `Functor` は箱のイメージ。 `Maybe` 型は `Just a` のように `Just` という箱の中に値を入れると解釈できる
  * `fmap :: Functor f => (a -> b) -> f a -> f b`
  * ただし、 `fmap (- amount)` のようには書けないことに注意する！！
    * `(- amount)` は `(negate amount)` と解釈されてしまう
    * 代わりに `(subtract amount)` か `(+ (-amount))` と書けばよい

```haskell
transfer from to amount bank
  | amount < 0 = bank -- 送金金額が0未満
  | isNothing fromBalance = bank
  | isNothing toBalance = bank
  | fromJust fromBalance - amount < 0 = bank -- 送金側のお金が足りない
  | otherwise = Map.alter (fmap (+ amount)) to (Map.alter (fmap (subtract amount)) from bank)
  where
    fromBalance = Map.lookup from bank
    toBalance = Map.lookup to bank
```

#### 2b

`Map.adjust` を使用する。キーが存在しない場合は何もしない。

```haskell
adjust :: Ord k => (a -> a) -> k -> Map.Map k a -> Map.Map k a

transfer from to amount bank
  | amount < 0 = bank -- 送金金額が0未満
  | isNothing fromBalance = bank
  | isNothing toBalance = bank
  | fromJust fromBalance - amount < 0 = bank -- 送金側のお金が足りない
  | otherwise = Map.adjust (+ amount) to (Map.adjust (subtract amount) from bank)
  where
    fromBalance = Map.lookup from bank
    toBalance = Map.lookup to bank
```

### Step 3

```haskell
transfer from to amount bank
  | amount < 0 = bank
  | isNothing fromBalance = bank
  | isNothing toBalance = bank
  | fromJust fromBalance < amount = bank
  | otherwise = Map.adjust (+ amount) to (Map.adjust (subtract amount) from bank)
  where
    fromBalance = Map.lookup from bank
    toBalance = Map.lookup to bank
```

## Ex 11

### 問題

```haskell
-- Ex 11: given an Array and two indices, swap the elements in the indices.
--
-- Example:
--   swap 2 3 (array (1,4) [(1,"one"),(2,"two"),(3,"three"),(4,"four")])
--         ==> array (1,4) [(1,"one"),(2,"three"),(3,"two"),(4,"four")]

swap :: Ix i => i -> i -> Array i a -> Array i a
swap i j arr = todo
```

### Step 1

```haskell
(!) :: Ix i => Array i e -> i -> e
(//) :: Ix i => Array i e -> [(i, e)] -> Array i e

swap i j arr = arr // [(i, jElem), (j, iElem)]
  where
    iElem = arr ! i
    jElem = arr ! j
```

### Step 2

#### 2a

step 1を1行で書いた。

```haskell
swap i j arr = arr // [(i, arr ! j), (j, arr ! i)]
```

`Data.Array` の内部実装。

* メモリ上で連続した領域に要素を並べた配列。連結リストの `[a]` とは異なる
* イミュータブル
* `(!)` は `O(1)` 時間
* `(//)` は元の配列をコピーしてから指定された位置の要素を書き換えるので時間・空間どちらも `O(n)` の計算量がかかる

### Step 3

```haskell
swap i j arr = arr // [(i, arr ! j), (j, arr ! i)]
```

## Ex 12

### 問題

```haskell
-- Ex 12: given an Array, find the index of the largest element. You
-- can assume the Array isn't empty.
--
-- You may assume that the largest element is unique.
--
-- Hint: check out Data.Array.indices or Data.Array.assocs

maxIndex :: (Ix i, Ord a) => Array i a -> i
maxIndex = todo
```

### Step 1

引数の配列が空の場合はエラーにする。

```haskell
indices :: Ix i => Array i a -> [i]
bounds :: Ix i => Array i a -> (i, i)

maxIndex arr = go (indices arr) (firstIndex arr) (firstElem arr)
  where
    go [] j _ = j
    go (i:is) j jElem = let iElem = arr ! i in case jElem < iElem of
      True -> go is i iElem
      _ -> go is j jElem

firstIndex :: (Ix i) => Array i a -> i
firstIndex arr = fst (bounds arr)

firstElem :: (Ix i) => Array i a -> a
firstElem arr = arr ! (firstIndex arr)
```

### Step 2

#### 2a

```haskell
assocs :: Ix i => Array i e -> [(i, e)]

maxIndex arr = let l = assocs arr in go l (head l)
  where
    go [] (j, _) = j
    go ((i,iElem):es) (j, largest) = if largest < iElem
      then go es (i, iElem)
      else go es (j, largest)
```

#### 2b

綺麗だなぁ。こういうの思いつけるようになりたい。

```haskell
maximumBy :: Foldable t => (a -> a -> Ordering) -> t a -> a
comparing :: Ord a => (b -> a) -> b -> b -> Ordering

maxIndex = fst . maximumBy (comparing snd) . assocs
```

#### 2c

`Data.Array` にソート関数はないみたい。ソートするならリストに直す必要がある。

### Step 3

```haskell
maxIndex = fst . maximumBy (comparing snd) . assocs
```
