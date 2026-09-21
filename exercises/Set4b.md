# Set4b

## Ex 1

### 問題

```haskell
-- Ex 1: countNothings with a fold. The function countNothings from
-- the course material can be implemented using foldr. Your task is to
-- define countHelper so that the following definition of countNothings
-- works.
--
-- Hint: You can start by trying to add a type signature for countHelper.
--
-- Challenge: look up the maybe function and use it in countHelper.
--
-- Examples:
--   countNothings []  ==>  0
--   countNothings [Just 1, Nothing, Just 3, Nothing]  ==>  2

countNothings :: [Maybe a] -> Int
countNothings xs = foldr countHelper 0 xs

countHelper = todo
```

### Step 1

```haskell
countNothings xs = foldr countHelper 0 xs

countHelper Nothing = (+1)
countHelper _ = id
```

### Step 2

#### 2a

問題で与えられた形式じゃない方法で。

```haskell
import Data.Maybe

countNothings = foldr (\x -> if isNothing x then (+1) else id) 0
```

#### 2b

```haskell
countNothings = step 0
  where
    step count [] = count
    step count (x:xs) = if isNothing x then step (count+1) xs else step count xs
```

#### 2c

`maybe` を使って `Nothing` だったら関数 `(+1)` を、じゃなければ何もせず値をそのまま返す関数を `acc` に適用する。`const id :: b -> a -> a` は第2引数を返す関数。

```haskell
maybe :: b -> (a -> b) -> Maybe a -> b

countHelper :: Maybe a -> Int -> Int
countHelper = maybe (+1) (const id)
```

### Step 3

本当だったら可読性のために2aか2bのような書き方をすると思うけど、練習のために2cで書いた。

```haskell
countNothings xs = foldr countHelper 0 xs

countHelper :: Maybe a -> Int -> Int
countHelper = maybe (+1) (const id)
```

## Ex 2

### 問題

```haskell
-- Ex 2: myMaximum with a fold. Just like in the previous exercise,
-- define maxHelper so that the given definition of myMaximum works.
--
-- Examples:
--   myMaximum []  ==>  0
--   myMaximum [1,3,2]  ==>  3

myMaximum :: [Int] -> Int
myMaximum [] = 0
myMaximum (x:xs) = foldr maxHelper x xs

maxHelper = todo
```

### Step 1

```haskell
myMaximum [] = 0
myMaximum (x:xs) = foldr maxHelper x xs

maxHelper :: Int -> Int -> Int
maxHelper x acc = if acc < x then x else acc
```

### Step 2

#### 2a

```haskell
maxHelper = max

-- myMaximum (x:xs) = foldr max x xs でよい
```

### Step 3

```haskell
maxHelper = max
```

## Ex 3

### 問題

```haskell
-- Ex 3: compute the sum and length of a list with a fold. Define
-- slHelper and slStart so that the given definition of sumAndLength
-- works. This could be used to compute the average of a list.
--
-- Start by giving slStart and slHelper types.
--
-- Examples:
--   sumAndLength []             ==>  (0.0,0)
--   sumAndLength [1.0,2.0,4.0]  ==>  (7.0,3)


sumAndLength :: [Double] -> (Double,Int)
sumAndLength xs = foldr slHelper slStart xs

slStart = todo
slHelper = todo
```

### Step 1

```haskell
sumAndLength xs = foldr slHelper slStart xs

slStart :: (Double, Int)
slStart = (0.0, 0)
slHelper :: Double -> (Double, Int) -> (Double, Int)
slHelper x (acc, count) = (acc+x, count+1)
```

### Step 2

#### 2a

```haskell
import Data.Bifunctor

bimap :: Bifunctor p => (a -> b) -> (c -> d) -> p a c -> p b d

slStart = (0, 0)
slHelper x = bimap (+x) (+1)
```

### Step 3

```haskell
slStart = (0, 0)
slHelper x = bimap (+x) (+1)
```

## Ex 4

### 問題

```haskell
-- Ex 4: implement concat with a fold. Define concatHelper and
-- concatStart so that the given definition of myConcat joins inner
-- lists of a list.
--
-- Examples:
--   myConcat [[]]                ==> []
--   myConcat [[1,2,3],[4,5],[6]] ==> [1,2,3,4,5,6]

myConcat :: [[a]] -> [a]
myConcat xs = foldr concatHelper concatStart xs

concatStart = todo
concatHelper = todo
```

### Step 1

```haskell
myConcat xs = foldr concatHelper concatStart xs

concatStart :: [a]
concatStart = []
concatHelper :: [a] -> [a] -> [a]
concatHelper x acc = x ++ acc
```

### Step 2

#### 2a

eta簡約した。

```haskell
concatStart :: [a]
concatStart = []
concatHelper :: [a] -> [a] -> [a]
concatHelper = (++)
```

#### 2b

```haskell
concatStart :: [a]
concatStart = []
concatHelper :: [a] -> [a] -> [a]
concatHelper x acc = foldr (:) acc x
```

### Step 3

## Ex 5

### 問題

```haskell
-- Ex 5: get all occurrences of the largest number in a list with a
-- fold. Implement largestHelper so that the given definition of largest works.
--
-- Examples:
--   largest [] ==> []
--   largest [1,3,2] ==> [3]
--   largest [1,3,2,3] ==> [3,3]

largest :: [Int] -> [Int]
largest xs = foldr largestHelper [] xs

largestHelper = todo
```

### Step 1

```haskell
largestHelper :: Int -> [Int] -> [Int]
largestHelper x [] = [x]
largestHelper x acc = case compare x (head acc) of
    GT -> [x]
    EQ -> x:acc
    LT -> acc
```

### Step 2

#### 2a

```haskell
largestHelper :: Int -> [Int] -> [Int]
largestHelper x [] = [x]
largestHelper x acc@(y:_) = case compare x y of
    GT -> [x]
    EQ -> x:acc
    LT -> acc
```

### Step 3

```haskell
largestHelper :: Int -> [Int] -> [Int]
largestHelper x [] = [x]
largestHelper x rest@(y:_) = case compare x y of
  GT -> [x]
  EQ -> x:rest
  LT -> rest
```

## Ex 6

### 問題

```haskell
-- Ex 6: get the first element of a list with a fold. Define
-- headHelper so that the given definition of myHead works.
--
-- Start by giving headHelper a type.
--
-- Examples:
--   myHead []  ==>  Nothing
--   myHead [1,2,3]  ==>  Just 1

myHead :: [a] -> Maybe a
myHead xs = foldr headHelper Nothing xs

headHelper = todo
```

### Step 1

```haskell
myHead xs = foldr headHelper Nothing xs

headHelper :: a -> Maybe a -> Maybe a
headHelper x _ = Just x
```

### Step 2

#### 2a

eta簡約した。

```haskell
headHelper = const . Just
```

### Step 3

```haskell
headHelper :: a -> Maybe a -> Maybe a
headHelper x _ = Just x
```

## Ex 7

### 問題

```haskell
-- Ex 7: get the last element of a list with a fold. Define lasthelper
-- so that the given definition of myLast works.
--
-- Start by giving lastHelper a type.
--
-- Examples:
--   myLast [] ==> Nothing
--   myLast [1,2,3] ==> Just 3

myLast :: [a] -> Maybe a
myLast xs = foldr lastHelper Nothing xs

lastHelper = todo
```

### Step 1

```haskell
myLast xs = foldr lastHelper Nothing xs

lastHelper :: a -> Maybe a -> Maybe a
lastHelper x Nothing = Just x
lastHelper _ lst = lst
```

### Step 2

#### 2a

型 `a` にEq制約はないので、 `lst == Nothing` とは書けない。

```haskell
import Data.Maybe

lastHelper x lst = if isNothing lst then Just x else lst
```

#### 2b

```haskell
lastHelper x lst = maybe (Just x) Just lst
```

#### 2c

2bと比べてデフォルト値が何なのか分かりやすい。

```haskell
lastHelper x lst = Just $ fromMaybe x lst
```

eta簡約しても可読性が落ちるだけのように見える。

```haskell
lastHelper x = Just . fromMaybe x
```

### Step 3

シンプルなパターンマッチが一番読みやすい。

```haskell
lastHelper :: a -> Maybe a -> Maybe a
lastHelper x Nothing = Just x
lastHelper _ lst = lst
```
