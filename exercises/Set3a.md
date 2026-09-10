# Set3a

## Ex 8

### 問題

```haskell
-- Ex 8: another version of a while loop. This time, the check
-- function returns an Either value. A Left value means stop, a Right
-- value means keep looping.
--
-- The call `whileRight check x` should call `check x`, and if the
-- result is a Left, return the contents of the Left. If the result is
-- a Right, the function should call `check` on the contents of the
-- Right and so on.
--
-- Examples (see definitions of step and bomb below):
--   whileRight (step 100) 1   ==> 128
--   whileRight (step 1000) 3  ==> 1536
--   whileRight bomb 7         ==> "BOOM"
--
-- Hint! Remember the case-of expression from lecture 2.

whileRight :: (a -> Either b a) -> a -> b
```

### Step 1

```haskell
whileRight check x = case check x of
  Left b -> b
  Right a -> whileRight check a
```

### Step 2

#### 2a

either関数 (`either :: (a -> c) -> (b -> c) -> Either a b -> c`) を使える。

```haskell
whileRight check x = either id (whileRight check) (check x)
```

#### 2b

2aをeta簡約(eta reduction)できる。etaはギリシア文字のη（イータ）のことらしい。

```haskell
whileRight check = either id (whileRight check) . check
```

## Ex 9

### 問題

```haskell
-- Ex 9: given a list of strings and a length, return all strings that
--  * have the given length
--  * are made by catenating two input strings
--
-- Examples:
--   joinToLength 2 ["a","b","cd"]        ==> ["aa","ab","ba","bb"]
--   joinToLength 5 ["a","b","cd","def"]  ==> ["cddef","defcd"]
--
-- Hint! This is a great use for list comprehensions

joinToLength :: Int -> [String] -> [String]
```

### Step 1

誤答。 `zipWith` はi番目とi番目の要素しか付き合わせない。

```haskell
joinToLength len strs = filter (\str -> length str == len) $ zipWith (++) strs strs
```

正答。

```haskell
joinToLength len strs = [a ++ b | a <- strs, b <- strs, length a + length b == len]
```

### Step 2

#### 2a

```haskell
joinToLength len strs = [a ++ b | a <- strs, b <- strs, length (a ++ b) == len]
```

この場合、 `length (a++b)` で一度aとbを接続してから長さを評価するので、step 1の `length a + length b` と比べて効率が悪い。

#### 2b

strsに無限長の文字列が含まれ得る場合の解法。step 1の解法は無限長の文字列が含まれていた場合にlengthの評価が終わらない。

無限長のリストに対しても長さ判定可能な `lengthIs` を定義する。ただし、下記解法でもstrsが無限長リストの場合は終わらないことに注意する。

```haskell
joinToLength len strs = [a ++ b | a <- strs, b <- strs, lengthIs len (a++b)]

lengthIs :: Int -> [a] -> Bool
lengthIs n xs = (length $ take (n+1) xs) == n
```

ちなみに `length` は、

```haskell
length :: [a] -> Int
length xs = lenAcc xs 0

lenAcc :: [a] -> Int -> Int
lenAcc [] n = n
lenAcc (_:ys) n = lenAcc ys (n+1)
```

と末尾再帰なので無限リストに対して停止しないが、 `Data.List.genericLength` の場合は、

```haskell
genericLength :: [a] -> Int
genericLength [] = 0
genericLength (_:xs) = 1 + genericLength xs
```

と末尾再帰ではないので「遅延した Num インスタンスを使ったとき」は停止するらしい（遅延したNumインスタンスというのが何かよくわかっていないが、後で出てきそうなので一旦スルーする）。

#### 2c

step 1はlengthを`(strsの長さ)^2` 回計算していたので、`(strsの長さ)` 回に削減した。

```haskell
joinToLength len strs = [a ++ b | (a, la) <- withLen, (b, lb) <- withLen, la + lb == len]
  where withLen = [(str, length str) | str <- strs]
```

### Step 3

strsもstrsの各要素も無限長ではない前提では2cの書き方がパフォーマンス的に良いと思ったので選んだ。

```haskell
joinToLength len strs = [a ++ b | (a, la) <- withLen, (b, lb) <- withLen, la + lb == len]
  where withLen = [(str, length str) | str <- strs]
```

## Ex 10

```haskell
-- Ex 10: implement the operator +|+ that returns a list with the first
-- elements of its input lists.
--
-- Give +|+ a type signature. NB: It needs to be of the form (+|+) :: x,
-- with the parentheses because +|+ is an infix operator.
--
-- Examples:
--   [1,2,3] +|+ [4,5,6]  ==> [1,4]
--   [] +|+ [True]        ==> [True]
--   [] +|+ []            ==> []
```

### Step 1

ナイーブにパターンマッチを書いた。 `head` を使うと空リストの場合にエラーになることに注意。

```haskell
(+|+) :: [a] -> [a] -> [a]
(+|+) [] [] = []
(+|+) [] (y:_) = (y:[])
(+|+) (x:_) [] = (x:[])
(+|+) (x:_) (y:_) = (x:y:[])
```

### Step 2

#### 2a

`head` を使うとするならこんな感じ。

```haskell
(+|+) :: [a] -> [a] -> [a]
(+|+) [] [] = []
(+|+) [] (y:_) = (y:[])
(+|+) (x:_) [] = (x:[])
(+|+) xs ys = (head xs:head ys:[])
```

#### 2b

`= [x, y]` みたいな書き方ができた。この方がstep 1よりシンプルに書ける。 `[x]` という書き方は `(x:[])` の糖衣構文（sugar syntax）。

```haskell
(+|+) :: [a] -> [a] -> [a]
(+|+) [] [] = []
(+|+) [] (y:_) = [y]
(+|+) (x:_) [] = [x]
(+|+) (x:_) (y:_) = [x, y]
```

#### 2c

もっとシンプルに書ける。2a, 2bは `head` が空リストを引数にとるとエラーになるがためにパターンマッチをしていたが、 `take` なら実際の要素より多い数を指定してもエラーにならない。

```haskell
(+|+) xs ys = take 1 xs ++ take 1 ys
```

演算子を真ん中に置いても大丈夫。

```haskell
xs +|+ ys = take 1 xs ++ take 1 ys
```

`take` の実装。

```haskell
take :: Int -> [a] -> [a]
take n xs
  | 0 < n = unsafeTake n xs
  | otherwise = []

unsafeTake :: Int -> [a] -> [a]
unsafeTake !_ [] = []
unsafeTake 1 (x:_) = [x]
unsafeTake n (x:xs) = x : unsafeTake (n-1) xs
```

#### 2d

冗長な解答ではあるが、。

```haskell
import Data.Maybe

(+|+) xs ys = maybeToList (listToMaybe xs) ++ maybeToList (listToMaybe ys)
```

### Step 3

一番シンプルなのを選んだ。

```haskell
xs +|+ ys = take 1 xs ++ take 1 ys
```

## Ex 11

### 問題

```haskell
-- Ex 11: remember the lectureParticipants example from Lecture 2? We
-- used a value of type [Either String Int] to store some measurements
-- that might be missing. Implement the function sumRights which sums
-- all non-missing measurements in a list like this.
--
-- Challenge: look up the type of the either function. Implement
-- sumRights using the map & either functions instead of pattern
-- matching on lists or Eithers!
--
-- Examples:
--   sumRights [Right 1, Left "bad value", Right 2]  ==>  3
--   sumRights [Left "bad!", Left "missing"]         ==>  0
```

### Step 1

```haskell
sumRights :: [Either a Int] -> Int
sumRights xs = sumList $ map (either (\_ -> 0) id) xs

sumList :: [Int] -> Int
sumList [] = 0
sumList (x:xs) = x + sumList xs
```

`either` と `map` の型を忘れかけていたので復習する。

```haskell
either :: (a -> c) -> (b -> c) -> Either a b -> c

map :: (a -> b) -> [a] -> [b]
```

### Step 2

#### 2a

step 1では自作の `sumList` を定義したが、 `Prelude.sum` を使えば良かった。また、 `(\_ -> 0)` も `const` を使えば良かった。

```haskell
sumRights xs = sum $ map (either (const 0) id) xs

const :: a -> b -> a
```

#### 2b

eta簡約。

```haskell
sumRights = sum . map (either (const 0) id)
```

#### 2c

ピンポイントで `(either (const 0) id)` をやってくれる関数が `Data.Either` にあるらしい。

```haskell
sumRights = sum . map (fromRight 0)
```

`fromRight` はRightの値を返しつつ、Rightじゃなければデフォルト値を返す関数。

```haskell
fromRight :: b -> Either a b -> b
fromRight _ (Right b) = b
fromRight b _ = b
```

`fromLeft` も存在するらしい。

#### 2d

もっと言うと `rights` という関数があるらしい。

```haskell
sumRights = sum . rights
```

```haskell
rights :: [Either a b] -> [b]
rights x = [a | Right a <- x]
```

リスト内包表記のジェネレータのパターンマッチが失敗した場合はエラーにならずに単に捨てられるという仕様を利用している。

### Step 3

2c, 2d辺りは知らないことを前提としている問題であろうとメタ読みをし、2bで練習することに。

```haskell
sumRights = sum . map (either (const 0) id)
```

## Ex 12

```haskell
-- Ex 12: recall the binary function composition operation
-- (f . g) x = f (g x). In this exercise, your task is to define a function
-- that takes any number of functions given as a list and composes them in the
-- same order than they appear in the list.
--
-- Examples:
--   multiCompose [] "foo" ==> "foo"
--   multiCompose [] 1     ==> 1
--   multiCompose [(++"bar")] "foo" ==> "foobar"
--   multiCompose [reverse, tail, (++"bar")] "foo" ==> "raboo"
--   multiCompose [(3*), (2^), (+1)] 0 ==> 6
--   multiCompose [(+1), (2^), (3*)] 0 ==> 2
```

### Step 1

```haskell
multiCompose [] = id
multiCompose (f:fs) = f . multiCompose fs
```

### Step 2

#### 2a

題意を無視すると、fsを反転させて前から適用すれば良い。

```haskell
multiCompose fs x = multiCompose' (reverse fs) x

multiCompose' [] x = x
multiCompose' (f:fs) x = multiCompose' fs (f x)
```

#### 2b

step 1で `(.)` を使わないようにする。

```haskell
multiCompose [] x = x
multiCompose (f:fs) x = f $ (multiCompose fs x)
```

この問題でやっていることはまさに `foldr` らしいが、次章で習うので一旦スキップ。

### Step 3

```haskell
multiCompose [] = id
multiCompose (f:fs) = f . multiCompose fs
```

## Ex 13

### 問題

```haskell
-- Ex 13: let's consider another way to compose multiple functions. Given
-- some function f, a list of functions gs, and some value x, define
-- a composition operation that applies each function g in gs to x and then
-- f to the resulting list. Give also the type annotation for multiApp.
--
-- Challenge: Try implementing multiApp without lambdas or list comprehensions.
--
-- Examples:
--   multiApp id [] 7  ==> []
--   multiApp id [id, reverse, tail] "This is a test"
--       ==> ["This is a test","tset a si sihT","his is a test"]
--   multiApp id  [(1+), (^3), (+2)] 1  ==>  [2,1,3]
--   multiApp sum [(1+), (^3), (+2)] 1  ==>  6
--   multiApp reverse [tail, take 2, reverse] "foo" ==> ["oof","fo","oo"]
--   multiApp concat [take 3, reverse] "race" ==> "racecar"
--   multiApp id [head, (!!2), last] "axbxc" ==> ['a','b','c'] i.e. "abc"
--   multiApp sum [head, (!!2), last] [1,9,2,9,3] ==> 6
```

### Step 1

```haskell
multiApp :: ([b] -> c) -> [a -> b] -> a -> c
multiApp f gs x = f [g x | g <- gs]
```

### Step 2

#### 2a

リスト内包表記を使わない方法を考えてみた。

```haskell
multiApp :: ([b] -> c) -> [a -> b] -> a -> c
multiApp f gs x = f (map ($ x) gs)
```

#### 2b

`Data.Function` に逆適用の演算子 '&' があるらしい。

```haskell
(&) :: a -> (a -> b) -> b
x & f = f x
```

```haskell
multiApp f gs x = f (map (x &) gs)
```

#### 2c

`Functor` や `<*>` を知っていれば他にもやりようはあるみたいだが、未習なのでここはさくっと通過する。

### Step 3

一番シンプルな解法は2aかリスト内包表記だと思った。

```haskell
multiApp :: ([b] -> c) -> [a -> b] -> a -> c
multiApp f gs x = f (map ($ x) gs)
```

## Ex 14

### 問題

```haskell
-- Ex 14: in this exercise you get to implement an interpreter for a
-- simple language. You should keep track of the x and y coordinates,
-- and interpret the following commands:
--
-- up -- increment y by one
-- down -- decrement y by one
-- left -- decrement x by one
-- right -- increment x by one
-- printX -- print value of x
-- printY -- print value of y
--
-- The interpreter will be a function of type [String] -> [String].
-- Its input is a list of commands, and its output is a list of the
-- results of the print commands in the input.
--
-- Both coordinates start at 0.
--
-- Examples:
--
-- interpreter ["up","up","up","printY","down","printY"] ==> ["3","2"]
-- interpreter ["up","right","right","printY","printX"] ==> ["1","2"]
--
-- Surprise! after you've implemented the function, try running this in GHCi:
--     interact (unlines . interpreter . lines)
-- after this you can enter commands on separate lines and see the
-- responses to them
--
-- The suprise will only work if you generate the return list directly
-- using (:). If you build the list in an argument to a helper
-- function, the surprise won't work. See section 3.8 in the material.
```

### Step 1

ナイーブにパターンマッチを書いた。

```haskell
interpreter :: [String] -> [String]
interpreter commands = interpreter' commands 0 0

interpreter' :: [String] -> Int -> Int -> [String]
interpreter' [] x y = []
interpreter' ("up":cs) x y = interpreter' cs x (y+1)
interpreter' ("down":cs) x y = interpreter' cs x (y-1)
interpreter' ("right":cs) x y = interpreter' cs (x+1) y
interpreter' ("left":cs) x y = interpreter' cs (x-1) y
interpreter' ("printX":cs) x y = show x : interpreter' cs x y
interpreter' ("printY":cs) x y = show y : interpreter' cs x y
```

### Step 2

#### 2a

タプルを使う。ちょっと凝ってヘルパー関数をそれぞれ定義したけど可読性が上がったかというとそうでもない。

Step 1は未定義のコマンドが入力されたら即座にエラーになるが、ここではエラーを握りつぶしてみる。

```haskell
interpreter commands = interpreter' commands (0, 0)

interpreter' :: [String] -> (Int, Int) -> [String]
interpreter' [] _ = []
interpreter' ("up":cs) xy = interpreter' cs (up xy)
interpreter' ("down":cs) xy = interpreter' cs (down xy)
interpreter' ("right":cs) xy = interpreter' cs (right xy)
interpreter' ("left":cs) xy = interpreter' cs (left xy)
interpreter' ("printX":cs) xy = printX xy : interpreter' cs xy
interpreter' ("printY":cs) xy = printY xy : interpreter' cs xy
interpreter' (_:cs) xy = interpreter' cs xy

up :: (Int, Int) -> (Int, Int)
up (x, y) = (x, y+1)

down :: (Int, Int) -> (Int, Int)
down (x, y) = (x, y-1)

right :: (Int, Int) -> (Int, Int)
right (x, y) = (x+1, y)

left :: (Int, Int) -> (Int, Int)
left (x, y) = (x-1, y)

printX :: (Int, Int) -> String
printX = show . fst

printY :: (Int, Int) -> String
printY = show . snd
```

#### 2b

Step 1と2aでは、x±1やy±1が遅延評価の影響で `show` が評価されるまで計算されず、サンクが蓄積してしまう。そこで、BagPatternを使って累算器を正格にする。

```haskell
interpreter :: [String] -> [String]
interpreter commands = interpreter' commands 0 0

interpreter' :: [String] -> Int -> Int -> [String]
interpreter' [] x y = []
interpreter' ("up":cs) !x !y = interpreter' cs x (y+1)
interpreter' ("down":cs) !x !y = interpreter' cs x (y-1)
interpreter' ("right":cs) !x !y = interpreter' cs (x+1) y
interpreter' ("left":cs) !x !y = interpreter' cs (x-1) y
interpreter' ("printX":cs) !x !y = show x : interpreter' cs x y
interpreter' ("printY":cs) !x !y = show y : interpreter' cs x y
```

#### 2c

`where` を使って書く。

```haskell
interpreter = go (0, 0)
  where
    go (x, y) [] = []
    go (x, y) ("up":cs) = go (x, y+1) cs
    go (x, y) ("down":cs) = go (x, y-1) cs
    go (x, y) ("right":cs) = go (x+1, y) cs
    go (x, y) ("left":cs) = go (x-1, y) cs
    go (x, y) ("printX":cs) = show x : go (x, y) cs
    go (x, y) ("printY":cs) = show y : go (x, y) cs
    go (x, y) (_:cs) = go (x, y) cs
```

#### 2d

`where` + `case ... of`

```haskell
interpreter = go 0 0
  where
    go _ _ [] = []
    go x y (c:cs) = case c of
      "up" -> go x (y+1) cs
      "down" -> go x (y-1) cs
      "right" -> go (x+1) y cs
      "left" -> go (x-1) y cs
      "printX" -> show x : go x y cs
      "printY" -> show y : go x y cs
      _ -> go x y cs
```

### Step 3

2dの書き方が一番好き。

```haskell
interpreter = go 0 0
  where
    go _ _ [] = []
    go x y (c:cs) = case c of
      "up" -> go x (y+1) cs
      "down" -> go x (y-1) cs
      "right" -> go (x+1) y cs
      "left" -> go (x-1) y cs
      "printX" -> show x : go x y cs
      "printY" -> show y : go x y cs
      _ -> go x y cs
```
