# Set3b

## Ex 1

### 問題

```haskell
-- Ex 1: given numbers start, count and end, build a list that starts
-- with count copies of start and ends with end.
--
-- Use recursion and the : operator to build the list.
--
-- Examples:
--   buildList 1 5 2 ==> [1,1,1,1,1,2]
--   buildList 7 0 3 ==> [3]

buildList :: Int -> Int -> Int -> [Int]
```

### Step 1

末尾再帰。`count` が0以上であることを前提に書いた。

```haskell
buildList start count end = buildList' start count [end]
  where
    buildList' start 0 result = result
    buildList' start count result = buildList' start (count-1) (start:result)
```

### Step 2

#### 2a

非末尾再帰。

```haskell
buildList start 0 end = [end]
buildList start count end = start : buildList start (count-1) end
```

#### 2b

再帰ヘルパー関数に `start` と `end` を引数で取らせる必要はない。

```haskell
buildList start count end = go count
  where
    go 0 = [end]
    go n = start : go (n-1)
```

#### 2c

`count` が負の数の場合のガードを入れる。

```haskell
buildList start count end
  | count <= 0 = [end]
  | otherwise = start : buildList start (count-1) end
```

#### 2d

標準ライブラリが使えるなら `replicate` が便利。

```haskell
replicate :: Int -> a -> [a]
replicate n x = take n (repeat x)

repeat :: a -> [a]
repeat x = xs where xs = x : xs

buildList start count end = replicate count start ++ [end]
```

### Step 3

AIに「Haskellで末尾再帰を使うのは基本的に負けです」と言われてしまった。BangPatternを使ってWHNFにしない限りサンクが無駄に重なることが多いから。例えば `head (末尾再帰で構築するリスト）` はリストを構築し終わってからじゃないと `head` が評価されないけど、 `head (非末尾再帰で構築するリスト)` であれば `head` の評価に必要な最初の要素さえ決まればリストの構築を停止できる。

一番気に入ったのは `count` が負の数の場合もケアできているこちら。

```haskell
buildList start count end = go count
  where
    go n
      | n <= 0 = [end]
      | otherwise = start : go (n-1)
```

## Ex 2

### 問題

```haskell
-- Ex 2: given i, build the list of sums [1, 1+2, 1+2+3, .., 1+2+..+i]
--
-- Use recursion and the : operator to build the list.
--
-- Ps. you'll probably need a recursive helper function

sums :: Int -> [Int]
```

### Step 1

```haskell
sums n = go 1 0
  where
    go i acc
      | i > n = []
      | otherwise = (acc+i) : go (i+1) (acc+i)
```

### Step 2

#### 2a

`(acc+i)` を2回書いていたので変数にまとめる。

```haskell
sums n = go 1 0
  where
    go i acc
      | i > n = []
      | otherwise = let nextAcc = acc+i in nextAcc : go (i+1) nextAcc
```

#### 2b

1+2+...+n = (n(n+1)) / 2 であることを使う。

```haskell
sums n = go 1
  where
    go i
      | i > n = []
      | otherwise = (i * (i+1)) `div` 2 : go (i+1)
```

(復習) `div` は `Int` や `Integer` などの整数用。 `(/)` は `Double` , `Float` , `Rational` などの小数用。

```haskell
div :: Integral => a -> a -> a
(/) :: Fractional => a -> a -> a
```

#### 2c

末尾再帰。

```haskell
sums n = go n []
  where
    go i acc
      | i <= 0 = acc
      | otherwise = go (i-1) (div (i*(i+1)) 2 : acc)
```

### Step 3

```haskell
sums n = go 1 0
  where
    go i acc
      | i > n = []
      | otherwise = let nextAcc = acc+i in nextAcc : go (i+1) nextAcc
```

## Ex 3

### 問題

```haskell
-- Ex 3: define a function mylast that returns the last value of the
-- given list. For an empty list, a provided default value is
-- returned.
--
-- Use only pattern matching and recursion (and the list constructors : and [])
--
-- Examples:
--   mylast 0 [] ==> 0
--   mylast 0 [1,2,3] ==> 3

mylast :: a -> [a] -> a
```

### Step 1

```haskell
mylast def [] = def
mylast _ [x] = x
mylast def (x:xs) = mylast def xs
```

見返したら3行目のxが未使用だった。

### Step 2

#### 2a

標準ライブラリを使えるならこう書く。

```haskell
mylast def xs = if null xs then def else last xs
```

#### 2b

なるほど！って思った。

```haskell
mylast def [] = def
mylast _ (x:xs) = mylast x xs
```

### Step 3

```haskell
mylast def [] = def
mylast _ (x:xs) = mylast x xs
```

## Ex 4

### 問題

```haskell
-- Ex 4: safe list indexing. Define a function indexDefault so that
--   indexDefault xs i def
-- gets the element at index i in the list xs. If i is not a valid
-- index, def is returned.
--
-- Use only pattern matching and recursion (and the list constructors : and [])
--
-- Examples:
--   indexDefault [True] 1 False         ==>  False
--   indexDefault [10,20,30] 0 7         ==>  10
--   indexDefault [10,20,30] 2 7         ==>  30
--   indexDefault [10,20,30] 3 7         ==>  7
--   indexDefault ["a","b","c"] (-1) "d" ==> "d"

indexDefault :: [a] -> Int -> a -> a
```

### Step 1

```haskell
indexDefault [] _ def = def
indexDefault (x:_) 0 _ = x
indexDefault (x:xs) i def = indexDefault xs (i-1) def
```

ただし、これだとxsが無限長でiが負の数の場合に停止しない。

### Step 2

#### 2a

標準ライブラリを使えるならこう書く。

```haskell
indexDefault xs i def
  | null rest = def
  | otherwise = head rest
  where rest = drop i xs
```

#### 2b

```haskell
indexDefault xs i def = go xs i
  where
    go [] _ = def
    go (y:_) 0 = y
    go (_:ys) j = go ys (j-1)
```

#### 2c

2aをもっときれいに書く。

```haskell
indexDefault xs i def = case drop i xs of
  [] -> def
  (y:_) -> y
```

#### 2d

step 1と2bが無限長リスト+負のインデックスの場合に停止しない問題を解消する。

```haskell
indexDefault xs i def
  | i < 0 = def
  | otherwise = go xs i
  where
    go [] _ = def
    go (y:_) 0 = y
    go (_:ys) j = go ys (j-1)
```

#### 2e

なるほど！これが好き。

```haskell
indexDefault (x:xs) i def
  | i == 0 = x
  | i > 0 = indexDefault xs (i-1) def
indexDefault _ _ def = def
```

#### 2f

`Maybe` を使う。

```haskell
indexDefault xs i def = case safeIndex xs i of
  Nothing -> def
  Just a -> a
  where
    safeIndex ys j
      | j < 0 = Nothing
      | otherwise = go ys j
      where
        go [] _ = Nothing
        go (y:_) 0 = Just y
        go (_:ys) j = go ys (j-1)
```

### Step 3

```haskell
indexDefault (x:xs) i def
  | i == 0 = x
  | i > 0 = indexDefault xs (i-1) def
indexDefault _ _ def = def
```

## Ex 5

### 問題

```haskell
-- Ex 5: define a function that checks if the given list is in
-- increasing order.
--
-- Use pattern matching and recursion to iterate through the list.
--
-- Examples:
--   sorted [1,2,3] ==> True
--   sorted []      ==> True
--   sorted [2,7,7] ==> True
--   sorted [1,3,2] ==> False
--   sorted [7,2,7] ==> False

sorted :: [Int] -> Bool
```

### Step 1

```haskell
sorted [] = True
sorted [x] = True
sorted (x:x':xs) = x <= x' && sorted (x':xs)
```

2行目のxが未使用の変数になっていた。

### Step 2

#### 2a

```haskell
sorted xs = go Nothing xs
  where
    go _ [] = True
    go Nothing (y:ys) = go (Just y) ys
    go (Just z) (y:ys) = z <= y && go (Just y) ys
```

#### 2b

step 1のように `(x:x':xs)` と書かない方法。 `@` を使うことで変数宣言とパターンマッチを同時にできる。こう書けばstep 1のように `rest` に相当するリストを右辺で再構築する必要がなくなる。

```haskell
sorted [] = True
sorted [_] = True
sorted (x:rest@(y:_)) = x <= y && sorted rest
```

#### 2c

標準ライブラリを使えるならこう書く。 `zipWith` は短い方のリストに合わせる。

```haskell
sorted xs = and (zipWith (<=) xs (drop 1 xs))

zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith f = go f
  where
    go (x:xs) (y:ys) = f x y : go xs ys
    go _ _ = []
```

### Step 3

```haskell
sorted [] = True
sorted [_] = True
sorted (x:rest@(y:ys)) = x <= y && sorted rest
```

## Ex 6

### 問題

```haskell
-- Ex 6: compute the partial sums of the given list like this:
--
--   sumsOf [a,b,c]  ==>  [a,a+b,a+b+c]
--   sumsOf [a,b]    ==>  [a,a+b]
--   sumsOf []       ==>  []
--
-- Use pattern matching and recursion (and the list constructors : and [])

sumsOf :: [Int] -> [Int]
```

### Step 1

```haskell
sumsOf xs = go xs 0
  where
    go [] _ = []
    go (y:ys) acc = let nextAcc = acc+y in nextAcc : go ys nextAcc
```

### Step 2

#### 2a

直感的ではないので進んで書きたいとは思わないが、なるほどとなった。

```haskell
sumsOf [] = []
sumsOf [x] = [x]
sumsOf (x:y:xs) = x : sumsOf (x+y:xs)
```

#### 2b

step 1をポイントフリーで書く。

```haskell
sumsOf = go 0
  where
    go _ [] = []
    go acc (x:xs) = let nextAcc = acc+x in nextAcc : go nextAcc xs
```

### Step 3

```haskell
sumsOf = go 0
  where
    go _ [] = []
    go !acc (x:xs) = let nextAcc = acc+x in nextAcc : go nextAcc xs
```

## Ex 7

### 問題

```haskell
-- Ex 7: implement the function merge that merges two sorted lists of
-- Ints into a sorted list
--
-- Use only pattern matching and recursion (and the list constructors : and [])
--
-- Examples:
--   merge [1,3,5] [2,4,6] ==> [1,2,3,4,5,6]
--   merge [1,1,6] [1,2]   ==> [1,1,1,2,6]
--   merge [1,2,3,20] [7]  ==> [1,2,3,7,20]
--   merge [1] [2,3,4,5,6] ==> [1,2,3,4,5,6]

merge :: [Int] -> [Int] -> [Int]
```

### Step 1

単純なパターンマッチ。@を使うことでリストの再構築をしないで済むようにしている。

```haskell
merge xs [] = xs
merge [] ys = ys
merge xs@(x:restX) ys@(y:restY)
  | x <= y = x : merge restX ys
  | otherwise = y : merge xs restY
```

### Step 2

#### 2a

末尾再帰で書いてみた。 `++` が使えないのでコンパイルエラーになる。

```haskell
merge = go []
  where
    go merged xs [] = merged ++ xs
    go merged [] ys = merged ++ ys
    go merged (x:xs) (y:ys)
      | x <= y = go (merged ++ [x]) xs (y:ys)
      | otherwise = go (merged ++ [y]) (x:xs) ys
```

### Step 3

```haskell
merge xs [] = xs
merge [] ys = ys
merge xs@(x:restX) ys@(y:restY)
  | x <= y = x : merge restX ys
  | otherwise = y : merge xs restY
```

## Ex 8

### 問題

```haskell
-- Ex 8: compute the biggest element, using a comparison function
-- passed as an argument.
--
-- That is, implement the function mymaximum that takes
--
-- * a function `bigger` :: a -> a -> Bool
-- * a value `initial` of type a
-- * a list `xs` of values of type a
--
-- and returns the biggest value it sees, considering both `initial`
-- and all element in `xs`.
--
-- Examples:
--   mymaximum (>) 3 [] ==> 3
--   mymaximum (>) 0 [1,3,2] ==> 3
--   mymaximum (>) 4 [1,3,2] ==> 4    -- initial value was biggest
--   mymaximum (<) 4 [1,3,2] ==> 1    -- note changed biggerThan
--   mymaximum (\(a,b) (c,d) -> b > d) ("",0) [("Banana",7),("Mouse",8)]
--     ==> ("Mouse",8)

mymaximum :: (a -> a -> Bool) -> a -> [a] -> a
```

### Step 1

```haskell
mymaximum _ initial [] = initial
mymaximum bigger initial (x:xs)
  | bigger x initial = mymaximum bigger x xs
  | otherwise = mymaximum bigger initial xs
```

### Step 2

#### 2a

`bigger` はBoolを返すが、 `a -> a -> a` のような型の比較関数があった方がありがたいなと思ったところからの発想。

```haskell
mymaximum _ initial [] = initial
mymaximum bigger initial (x:xs) = mymaximum bigger biggerV xs
  where biggerV = if bigger x initial then x else initial
```

### Step 3

```haskell
mymaximum bigger initial [] = initial
mymaximum bigger initial (x:xs)
  | bigger initial x = mymaximum bigger initial xs
  | otherwise = mymaximum bigger x xs
```

## Ex 9

### 問題

```haskell
-- Ex 9: define a version of map that takes a two-argument function
-- and two lists. Example:
--
--   map2 f [x,y,z,w] [a,b,c]  ==> [f x a, f y b, f z c]
--
-- If the lists have differing lengths, ignore the trailing elements
-- of the longer list.
--
-- Use recursion and pattern matching. Do not use any library functions.

map2 :: (a -> b -> c) -> [a] -> [b] -> [c]
```

### Step 1

```haskell
map2 f as [] = []
map2 f [] bs = []
map2 f (a:as) (b:bs) = f a b : map2 f as bs
```

1,2行目の`f` がunusedだった。

### Step 2

#### 2a

`++` が使えないのでコンパイルエラーになるが、末尾再帰で書いてみた。

```haskell
map2 f as bs = go f as bs []
  where
    go f as [] cs = cs
    go f [] bs cs = cs
    go f (a:as) (b:bs) cs = go f as bs (cs ++ f a b)
```

#### 2b

癖でstep 1のようなearly returnをしてしまっていたけど、順番を逆にしたら2行で書ける。

```haskell
map2 f (a:as) (b:bs) = f a b : map2 f as bs
map2 _ _ _ = []
```

#### 2c

`map2` は `zipWith` そのもの。

```hakell
map2 = zipWith

zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith f = go
  where
    go [] _ = []
    go _ [] = []
    go (x:xs) (y:ys) = f x y : go xs ys
```

#### 2d

Static Argument Transformation (SAT)。step 1はすべてのパターンで静的引数fを引数で渡している。これを渡さないように書き換えることで、fがインラインかされることが期待される。

```haskell
map2 f = go
  where
    go (x:xs) (y:ys) = f x y : go xs ys
    go _ _ = []
```


### Step 3

```haskell
map2 f = go
  where
    go (x:xs) (y:ys) = f x y : go xs ys
    go _ _ = []
```

## Ex 10

### 問題

```haskell
-- Ex 10: implement the function maybeMap, which works a bit like a
-- combined map & filter.
---
-- maybeMap is given a list ([a]) and a function of type a -> Maybe b.
-- This function is called for all values in the list. If the function
-- returns Just x, x will be in the result list. If the function
-- returns Nothing, no value gets added to the result list.
--
-- Examples:
--
-- let f x = if x>0 then Just (2*x) else Nothing
-- in maybeMap f [0,1,-1,4,-2,2]
--   ==> [2,8,4]
--
-- maybeMap Just [1,2,3]
--   ==> [1,2,3]
--
-- maybeMap (\x -> Nothing) [1,2,3]
--   ==> []

maybeMap :: (a -> Maybe b) -> [a] -> [b]
```

### Step 1

構文がわからなくなってできなかった。

```haskell
-- f x == Nothing の箇所で型エラー
maybeMap f = go
  where
    go [] = []
    go (x:xs)
      | f x == Nothing = go xs
      | otherwise = y : go xs
      where Just y = f x
```

```haskell
-- これは通る
maybeMap f = go
  where
    go [] = []
    go (x:xs) = case f x of
      Nothing -> go xs
      Just y -> y : go xs
```

### Step 2

#### 2a

最初に書きたかった解法はこれ。

```haskell
maybeMap f = go
  where
    go [] = []
    go (x:xs)
      | Just y <- f x = y : go xs
      | otherwise = go xs
```

#### 2b

なるほどと思ったが、可読性は高くない。 `prepend` と `maybeMap` の二つの再帰関数を同時に扱わないといけないのでわかりにくい。

```haskell
maybeMap _ [] = []
maybeMap f (x:xs) = prepend (f x) (maybeMap f xs)
  where
    prepend Nothing ys = ys
    prepend (Just y) ys = y : ys
```

#### 2c

```haskell
maybeMap f = catMaybes . map f

catMaybes :: [Maybe a] -> [a]
catMaybes xs = [x | Just x <- xs]
```

#### 2d

リスト内包表記でやる。ただし、[f x]で余計にリストを作成してしまうことに注意。

```haskell
maybeMap f xs = [y | x <- xs, Just y <- [f x]]
```

### Step 3

```haskell
maybeMap f = go
  where
    go [] = []
    go (x:xs) = case f x of
      Just y -> y : go xs
      otherwise -> go xs
```
