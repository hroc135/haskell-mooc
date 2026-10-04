# Set5a

## Ex 1

### 問題

```haskell
-- Ex 1: Define the type Vehicle that has four constructors: Bike,
-- Bus, Tram and Train.
--
-- The constructors don't need any fields.
```

### Step 1

```haskell
data Vehicle = Bike | Bus | Tram | Train
```

### Step 2

ただの構文の練習なので、他の解法を考えるほどの問題じゃない。

### Step 3

```haskell
data Vehicle = Bike | Bus | Tram | Train
```

## Ex 2

### 問題

```haskell
-- Ex 2: Define the type BusTicket that can represent values like these:
--  - SingleTicket
--  - MonthlyTicket "January"
--  - MonthlyTicket "December"
```

### Step 1

```haskell
data BusTicket = SingleTicket | MonthlyTicket String
```

### Step 2

ただの構文の練習なので、他の解法を考えるほどの問題じゃない。

### Step 3

```haskell
data BusTicket = SingleTicket | MonthlyTicket String
```

## Ex 3

### 問題

```haskell
-- Ex 3: Here's the definition for a datatype ShoppingEntry that
-- represents an entry in a shopping basket. It has an item name (a
-- String), an item price (a Double) and a count (an Int). You'll also
-- find two examples of ShoppingEntry values.
--
-- Implement the functions totalPrice and buyOneMore below.

data ShoppingEntry = MkShoppingEntry String Double Int
  deriving Show

threeApples :: ShoppingEntry
threeApples = MkShoppingEntry "Apple" 0.5 3

twoBananas :: ShoppingEntry
twoBananas = MkShoppingEntry "Banana" 1.1 2

-- totalPrice should return the total price for an entry
--
-- Hint: you'll probably need fromIntegral to convert the Int into a
-- Double
--
-- Examples:
--   totalPrice threeApples  ==> 1.5
--   totalPrice twoBananas   ==> 2.2

totalPrice :: ShoppingEntry -> Double
totalPrice = todo

-- buyOneMore should increment the count in an entry by one
--
-- Example:
--   buyOneMore twoBananas    ==> MkShoppingEntry "Banana" 1.1 3

buyOneMore :: ShoppingEntry -> ShoppingEntry
buyOneMore = todo
```

### Step 1

```haskell
totalPrice (MkShoppingEntry _ price count) = price * fromIntegral count

buyOneMore (MkShoppingEntry name price count) = MkShoppingEntry name price (count+1)
```

### Step 2

#### 2a

`ShoppingEntry` をRecord Syntaxで定義し、getterを活用する。

```haskell
data ShoppingEntry = MkShoppingEntry { itemName :: String, itemPrice :: Double, itemCount :: Int }

totalPrice e = (itemPrice e) * (fromIntegral $ itemCount e)

buyOneMore (MkShoppingEntry name price count) = MkShoppingEntry name price (count+1)
```

#### 2b

```haskell
fromIntegral :: (Integral a, Num b) => a -> b

totalPrice e = itemPrice e * fromIntegral (itemCount e)

buyOneMore e = e { itemCount = itemCount e + 1 }
```

### Step 3

```haskell
data ShoppingEntry = MkShoppingEntry { itemName :: String, itemPrice :: Double, itemCount :: Int }
  deriving Show

totalPrice e = itemPrice e * fromIntegral (itemCount e)

buyOneMore e = e { itemCount = itemCount e + 1 }
```

## Ex 4

### 問題

```haskell
-- Ex 4: define a datatype Person, which should contain the age (an
-- Int) and the name (a String) of a person.
--
-- Also define a Person value fred, and the functions getAge, getName,
-- setAge and setName (see below).

data Person = PersonUndefined
  deriving Show

-- fred is a person whose name is Fred and age is 90
fred :: Person
fred = todo

-- getName returns the name of the person
getName :: Person -> String
getName p = todo

-- getAge returns the age of the person
getAge :: Person -> Int
getAge p = todo

-- setName takes a person and returns a new person with the name changed
setName :: String -> Person -> Person
setName name p = todo

-- setAge does likewise for age
setAge :: Int -> Person -> Person
setAge age p = todo
```

### Step 1

```haskell
data Person = ConstructPerson { age :: Int, name :: String }

fred = ConstructPerson { age = 90, name = "Fred" }

getName p = name p

getAge p = age p

setName name p = p { name = name }

setAge age p = p { age = age }
```

### Step 2

#### 2a

```haskell
data Person = ConstructPerson Int String

fred = ConstructPerson 90 "Fred"

getName (ConstructPerson _ name) = name

getAge (ConstructPerson age _) = age

setName name (ConstructPerson age _) = ConstructPerson age name

setAge age (ConstructPerson _ name) = ConstructPerson age name
```

#### 2b

スタイルを修正した。

* コンストラクタのフィールド名に接頭辞 `person` を付与した
  * step 1の `p { age = age }` のように読みにくい形になるし、同一名前空間で `age` や `name` といった汎用性のある関数名を予約してしまうことになるから
  * Kowainikのスタイルガイドでも接頭辞にコンストラクタ名を付与するよう書かれている
    * > Field names for the record data type should start with the full name of the data type.
    * https://kowainik.github.io/posts/2019-02-06-style-guide#data-types
* 単一のコンストラクタで定義される型においては、型名とコンストラクタ名を一致させる
  * Kowainikのスタイルガイドでもそのように書かれている
    * > Use the data type name as the constructor name for data with single constructor and newtype.
    * https://kowainik.github.io/posts/2019-02-06-style-guide#data-types

```haskell
data Person = Person { personAge :: Int, personName :: String }

fred = Person { personAge = 90, personName = "Fred" }

getName = personName

getAge = personAge

setName name p = p { personName = name }

setAge age p = p { personAge = age }
```

### Step 3

```haskell
data Person = Person { personAge :: Int, personName :: String }

fred = Person { personAge = 90, personName = "Fred" }

getName = personName

getAge = personAge

setName newName p = p { personName = newName }

setAge newAge p = p { personAge = newAge }
```

## Ex 5

### 問題

```haskell
-- Ex 5: define a datatype Position which contains two Int values, x
-- and y. Also define the functions below for operating on a Position.
--
-- Examples:
--   getY (up (up origin))    ==> 2
--   getX (up (right origin)) ==> 1

data Position = PositionUndefined

-- origin is a Position value with x and y set to 0
origin :: Position
origin = todo

-- getX returns the x of a Position
getX :: Position -> Int
getX = todo

-- getY returns the y of a position
getY :: Position -> Int
getY = todo

-- up increases the y value of a position by one
up :: Position -> Position
up = todo

-- right increases the x value of a position by one
right :: Position -> Position
right = todo
```

### Step 1

```haskell
data Position = Position { positionX :: Int, positionY :: Int }

origin = Position { positionX = 0, positionY = 0 }

getX = positionX

getY = positionY

up p = p { positionY = positionY p + 1 }

right p = p { positionX = positionX p + 1 }
```

### Step 2

#### 2a

```haskell
data Position = Position Int Int

origin = Position 0 0

getX (Position x _) = x

getY (Position _ y) = y

up (Position x y) = Position x (y+1)

right (Position x y) = Position (x+1) y
```

#### 2b

```haskell
data Position = Position { positionX, positionY :: Int }

origin = Position { positionX = 0, positionY = 0 }

getX = positionX

getY = positionY

mapPositionX :: (Int -> Int) -> Position -> Position
mapPositionX f p = p { positionX = f (positionX p) }
mapPositionY :: (Int -> Int) -> Position -> Position
mapPositionY f p = p { positionY = f (positionY p) }

up = mapPositionY (+1)

right = mapPositionX (+1)
```

### Step 3

```haskell
data Position = Position { positionX, positionY :: Int }

origin = Position { positionX = 0, positionY = 0 }

getX = positionX

getY = positionY

mapPositionX :: (Int -> Int) -> Position -> Position
mapPositionX f p = p { positionX = f (positionX p) }
mapPositionY :: (Int -> Int) -> Position -> Position
mapPositionY f p = p { positionY = f (positionY p) }

up = mapPositionY (+1)

right = mapPositionX (+1)
```

## Ex 6

### 問題

```haskell
-- Ex 6: Here's a datatype that represents a student. A student can
-- either be a freshman, a nth year student, or graduated.

data Student = Freshman | NthYear Int | Graduated
  deriving (Show,Eq)

-- Implement the function study, which changes a Freshman into a 1st
-- year student, a 1st year student into a 2nd year student, and so
-- on. A 7th year student gets changed to a graduated student. A
-- graduated student stays graduated even if he studies.

study :: Student -> Student
study = todo
```

### Step 1

```haskell
study Freshman = NthYear 1
study Graduated = Graduated
study (NthYear 7) = Graduated
study (NthYear n) = NthYear (n+1)
```

### Step 2

#### 2a

step 1だと `7` がマジックナンバーになっていた。

```haskell
maxYear = 7

study s = case s of
  Freshman -> NthYear 1
  Graduated -> Graduated
  NthYear n
    | n >= maxYear -> Graduated
    | otherwise -> NthYear (n+1)
```

#### 2b

```haskell
maxYear = 7

study :: Student -> Student
study Freshman = NthYear 1
study Graduated = Graduated
study (NthYear n)
  | n >= maxYear = Graduated
  | otherwise = NthYear (n+1)
```

### Step 3

```haskell
maxYear = 7

study s = case s of
  Freshman -> NthYear 1
  Graduated -> Graduated
  NthYear n
    | n >= maxYear -> Graduated
    | otherwise -> NthYear (n+1)
```

## Ex 7

### 問題

```haskell
-- Ex 7: define a datatype UpDown that represents a counter that can
-- either be in increasing or decreasing mode. Also implement the
-- functions zero, toggle, tick and get below.
--
-- NB! Define _two_ constructors for your datatype (feel free to name the
-- constructors however you want)
--
-- Examples:
--
-- get (tick zero)
--   ==> 1
-- get (tick (tick zero))
--   ==> 2
-- get (tick (tick (toggle (tick zero))))
--   ==> -1

data UpDown = UpDownUndefined1 | UpDownUndefined2

-- zero is an increasing counter with value 0
zero :: UpDown
zero = todo

-- get returns the counter value
get :: UpDown -> Int
get ud = todo

-- tick increases an increasing counter by one or decreases a
-- decreasing counter by one
tick :: UpDown -> UpDown
tick ud = todo

-- toggle changes an increasing counter into a decreasing counter and
-- vice versa
toggle :: UpDown -> UpDown
toggle ud = todo
```

### Step 1

```haskell
data UpDown = Increasing Int | Decreasing Int

zero = Increasing 0

get (Increasing count) = count
get (Decreasing count) = count

tick (Increasing count) = Increasing (count+1)
tick (Decreasing count) = Decreasing (count-1)

toggle (Increasing count) = Decreasing count
toggle (Decreasing count) = Increasing count
```

### Step 2

#### 2a

```haskell
data UpDown = Increasing { upDownCount :: Int }
            | Decreasing { upDownCount :: Int }

zero = Increasing { upDownCount = 0 }

get = upDownCount

tick ud = ud { upDownCount = upDownCount ud + tickStep ud }

tickStep :: UpDown -> Int
tickStep (Increasing _) = 1
tickStep (Decreasing _) = -1

toggle (Increasing count) = Decreasing count
toggle (Decreasing count) = Increasing count
```

### Step 3

```haskell
data UpDown = Increasing Int | Decreasing Int

zero = Increasing 0

get (Increasing count) = count
get (Decreasing count) = count

tick (Increasing count) = Increasing (count+1)
tick (Decreasing count) = Decreasing (count-1)

toggle (Increasing count) = Decreasing count
toggle (Decreasing count) = Increasing count
```

## Ex 8

### 問題

```haskell
-- Ex 8: you'll find a Color datatype below. It has the three basic
-- colours Red, Green and Blue, and two color transformations, Mix and
-- Invert.
--
-- Mix means the average of the two colors in each rgb channel.
--
-- Invert means subtracting all rgb values from 1.
--
-- Implement the function rgb :: Color -> [Double] that returns a list
-- of length three that represents the rgb value of the given color.
--
-- Examples:
--
-- rgb Red   ==> [1,0,0]
-- rgb Green ==> [0,1,0]
-- rgb Blue  ==> [0,0,1]
--
-- rgb (Mix Red Green)                    ==> [0.5,0.5,0]
-- rgb (Mix Red (Mix Red Green))          ==> [0.75,0.25,0]
-- rgb (Invert Red)                       ==> [0,1,1]
-- rgb (Invert (Mix Red (Mix Red Green))) ==> [0.25,0.75,1]
-- rgb (Mix (Invert Red) (Invert Green))  ==> [0.5,0.5,1]

data Color = Red | Green | Blue | Mix Color Color | Invert Color
  deriving Show

rgb :: Color -> [Double]
rgb col = todo
```

### Step 1

`subtract` の定義を誤解していてハマった。

```haskell
subtract x y = y - x
```

なので、 `subtract 1` は引数から1引く部分関数になる。

```haskell
rgb Red = [1, 0, 0]
rgb Green = [0, 1, 0]
rgb Blue = [0, 0, 1]
rgb (Mix c1 c2) = zipWith (\a b -> (a+b)/2) (rgb c1) (rgb c2)
rgb (Invert c) = map (\x -> subtract x 1) (rgb c)
```

### Step 2

#### 2a

step 1だと固定長のリストを扱っており、頑健ではないので、RGB型を定義する。

```haskell
rgb = fromRGB . toRGB

data RGB = RGB Double Double Double

toRGB :: Color -> RGB
toRGB Red = RGB 1 0 0
toRGB Green = RGB 0 1 0
toRGB Blue = RGB 0 0 1
toRGB (Mix c1 c2) = zipRGB (\a b -> (a+b)/2) (toRGB c1) (toRGB c2)
toRGB (Invert c) = mapRGB (1-) (toRGB c)

fromRGB :: RGB -> [Double]
fromRGB (RGB r g b) = [r, g, b]

zipRGB :: (Double -> Double -> Double) -> RGB -> RGB -> RGB
zipRGB f (RGB r1 g1 b1) (RGB r2 g2 b2) = RGB (f r1 r2) (f g1 g2) (f b1 b2)

mapRGB :: (Double -> Double) -> RGB -> RGB
mapRGB f (RGB r g b) = RGB (f r) (f g) (f b)
```

### Step 3

```haskell
rgb = fromRGB . toRGB

data RGB = RGB Double Double Double

toRGB :: Color -> RGB
toRGB Red = RGB 1 0 0
toRGB Green = RGB 0 1 0
toRGB Blue = RGB 0 0 1
toRGB (Mix c1 c2) = zipRGB (\x y -> (x+y)/2) (toRGB c1) (toRGB c2)
toRGB (Invert c) = mapRGB (1-) (toRGB c)

fromRGB :: RGB -> [Double]
fromRGB (RGB r g b) = [r, g, b]

zipRGB :: (Double -> Double -> Double) -> RGB -> RGB -> RGB
zipRGB f (RGB r1 g1 b1) (RGB r2 g2 b2) = RGB (f r1 r2) (f g1 g2) (f b1 b2)

mapRGB :: (Double -> Double) -> RGB -> RGB
mapRGB f (RGB r g b) = RGB (f r) (f g) (f b)
```

## Ex 9

### 問題

```haskell
-- Ex 9: define a parameterized datatype OneOrTwo that contains one or
-- two values of the given type. The constructors should be called One and Two.
--
-- Examples:
--   One True         ::  OneOrTwo Bool
--   Two "cat" "dog"  ::  OneOrTwo String
```

### Step 1

```haskell
data OneOrTwo a = One a | Two a a
```

### Step 2

これ以上やることはほとんどないのでこれで良しとする。 `deriving` をどうするかの議論もあって良いが、どのように使われる型なのか定義されていないと分からない。

### Step 3

## Ex 10

### 問題

```haskell
-- Ex 10: define a recursive datatype KeyVals for storing a set of
-- key-value pairs. There should be two constructors: Empty and Pair.
--
-- Empty represents an empty collection. It should have no fields.
--
-- Pair should have three fields, one for the key, one for the value,
-- and one for the rest of the collection (of type KeyVals)
--
-- The KeyVals datatype is parameterized by the key type k and
-- the value type v.
--
-- For example:
--
--  Pair "cat" True (Pair "dog" False Empty)  ::  KeyVals String Bool
--
-- Also define the functions toList and fromList that convert between
-- KeyVals and lists of pairs.

data KeyVals k v = KeyValsUndefined
  deriving Show

toList :: KeyVals k v -> [(k,v)]
toList = todo

fromList :: [(k,v)] -> KeyVals k v
fromList = todo
```

### Step 1

```haskell
data KeyVals k v = Empty | Pair k v (KeyVals k v)
  deriving Show

toList :: KeyVals k v -> [(k,v)]
toList = go []
  where
    go ps Empty = ps
    go ps (Pair key1 value1 kvs) = go (ps ++ [(key1, value1)]) kvs

fromList :: [(k,v)] -> KeyVals k v
fromList [] = Empty
fromList ((key, value):kvs) = Pair key value (fromList kvs)
```

`toList` は `++` を使っているので `O(n^2)` 時間。

下記のような順に並べている。

```
Pair k1 v1 (Pair k2 v2 (Pair k3 v3 Empty))
↓
toList
[(k1, v1), (k2, v2), (k3, v3)]

[(k1, v1), (k2, v2), (k3, v3)]
↓
fromList
Pair k1 v1 (Pair k2 v2 (Pair k3 v3 Empty))
```

### Step 2

#### 2a

`fromList` を `foldr` を使って書いた。

```haskell
foldr f x (y:ys) = f y1 (f y2 (f y3 x))

fromList :: [(k,v)] -> KeyVals k v
fromList = foldr (\(key, value) acc -> Pair key value acc) Empty
```

#### 2b

`foldl'` を使う。step 1とは逆の順に `toList` と `fromList` を実装することで、 `toList` で `++` を `:` に置き換えることができ、パフォーマンスが向上する。

`foldl'` はもともと `Prelude` になく、 `Data.List` に置かれていて、 `Prelude` には `foldl / foldl1 / foldr / foldr1` の4つしかなかった。GHC 9.10から `Prelude` に置かれるようになったが、このリポジトリではGHC 9.2.8を使用しているため、 `import Data.List (foldl')` が必要。

```haskell
foldl' f x (y:ys) = let x' = f x y
                    in x' `seq` foldl' x' ys

import Data.List (foldl')

toList :: KeyVals k v -> [(k,v)]
toList = go []
  where
    go ps Empty = ps
    go ps (Pair key1 value1 kvs) = go ((key1, value1) : ps) kvs

fromList :: [(k,v)] -> KeyVals k v
fromList = foldl' (\acc (key, value) -> Pair key value acc) Empty
```

#### 2c

2bみたいに反転させなくても `++` を `:` に置き換えられた。

```haskell
toList :: KeyVals k v -> [(k,v)]
toList Empty = []
toList (Pair key value rest) = (key, value) : toList rest

fromList :: [(k,v)] -> KeyVals k v
fromList = foldr (\(key, value) acc -> Pair key value acc) Empty
```

### Step 3

```haskell
data KeyVals k v = Empty | Pair k v (KeyVals k v)
  deriving Show

toList :: KeyVals k v -> [(k, v)]
toList Empty = []
toList (Pair key value rest) = (key, value) : toList rest

fromList :: [(k, v)] -> KeyVals k v
fromList = foldr (\(key, value) acc -> Pair key value acc) Empty
```

## Ex 11

### 問題

```haskell
-- Ex 11: The data type Nat is the so called Peano
-- representation for natural numbers. Define functions fromNat and
-- toNat that convert natural numbers to Ints and vice versa.
--
-- Examples:
--   fromNat (PlusOne (PlusOne (PlusOne Zero)))  ==>  3
--   toNat 3    ==> Just (PlusOne (PlusOne (PlusOne Zero)))
--   toNat (-3) ==> Nothing
--

data Nat = Zero | PlusOne Nat
  deriving (Show,Eq)

fromNat :: Nat -> Int
fromNat n = todo

toNat :: Int -> Maybe Nat
toNat z = todo
```

### Step 1

```haskell
fromNat :: Nat -> Int
fromNat Zero = 0
fromNat (PlusOne n) = 1 + fromNat n

toNat :: Int -> Maybe Nat
toNat z = case compare z 0 of
  LT -> Nothing
  _ -> Just (toNatUnsafe z)

toNatUnsafe :: Int -> Nat
toNatUnsafe 0 = Zero
toNatUnsafe z = PlusOne (toNatUnsafe (z-1))
```

### Step 2

#### 2a

```haskell
fromNat :: Nat -> Int
fromNat Zero = 0
fromNat (PlusOne n) = 1 + fromNat n

toNat :: Int -> Maybe Nat
toNat z = case compare z 0 of
  LT -> Nothing
  _ -> Just (go z)
  where
    go 0 = Zero
    go z = PlusOne (go (z-1))
```

#### 2b

`iterate` を使う。

```haskell
iterate :: (a -> a) -> a -> [a]
iterate f x = x : iterate f (f x)

fromNat :: Nat -> Int
fromNat Zero = 0
fromNat (PlusOne n) = 1 + fromNat n

toNat :: Int -> Maybe Nat
toNat z = if z < 0 then Nothing else Just (iterate PlusOne Zero !! z)
```

#### 2c

`fromNat` の方は `foldr` のような畳み込みで書き換えられる。

```haskell
foldNat :: (a -> a) -> a -> Nat -> a
foldNat _ x Zero = x
foldNat f x (PlusOne n) = f (foldNat f x n)

fromNat :: Nat -> Int
fromNat = foldNat (+1) 0
```

### Step 3

```haskell
fromNat :: Nat -> Int
fromNat Zero = 0
fromNat (PlusOne n) = 1 + fromNat n

toNat :: Int -> Maybe Nat
toNat i = if i < 0 then Nothing else Just (go i)
  where
    go 0 = Zero
    go j = PlusOne (go (j-1))
```

## Ex 12

### 問題

```haskell
-- Ex 12: While pleasingly simple in its definition, the Nat datatype is not
-- very efficient computationally. Instead of the unary Peano natural numbers,
-- computers use binary numbers.
--
-- Binary numbers are like decimal numbers, except that binary numbers have
-- only two digits (called bits), 0 and 1. The table below gives some
-- examples:
--
--   decimal | binary
--   --------+-------
--         0 |      0
--         1 |      1
--         2 |     10
--         7 |    111
--        44 | 101100
--
-- For allowing arbitrarily long binary numbers, our representation, the
-- datatype Bin, includes a special End constructor for denoting the end of
-- the binary number. In order to make computation with Bin easier, the bits
-- are represented in increasing order by significance (i.e. "backwards").
-- Consider the Bin numbers O (I (I End)), representing 110 in binary or
-- 6 in decimal, and I (I (O End)) that represents 011 in binary or 3 in
-- decimal. The most significant (last) bit, the bit I, of O (I (I End)) is
-- greater than the bit O, which is the most significant bit of I (I (O End)).
-- Therefore, O (I (I End)) is greater than I (I (O End)).
--
-- Your task is to write functions prettyPrint, fromBin, and toBin that
-- convert Bin to human-readable string, Bin to Int, and Int to Bin
-- respectively.
--
-- Examples:
--   prettyPrint End                     ==> ""
--   prettyPrint (O End)                 ==> "0"
--   prettyPrint (I End)                 ==> "1"
--   prettyPrint (O (O (I (O (I End))))) ==> "10100"
--   map fromBin [O End, I End, O (I End), I (I End), O (O (I End)),
--                  I (O (I End))]
--     ==> [0, 1, 2, 3, 4, 5]
--   fromBin (I (I (O (O (I (O (I (O End)))))))) ==> 83
--   fromBin (I (I (O (O (I (O (I End)))))))     ==> 83
--   map toBin [0..5] ==>
--     [O End,I End,O (I End),I (I End),O (O (I End)),I (O (I End))]
--   toBin 57 ==> I (O (O (I (I (I End)))))
--
-- Challenge: Can you implement toBin by directly converting its input into a
-- sequence of bits instead of repeatedly applying inc?
--
data Bin = End | O Bin | I Bin
  deriving (Show, Eq)

-- This function increments a binary number by one.
inc :: Bin -> Bin
inc End   = I End
inc (O b) = I b
inc (I b) = O (inc b)

prettyPrint :: Bin -> String
prettyPrint = todo

fromBin :: Bin -> Int
fromBin = todo

toBin :: Int -> Bin
toBin = todo
```

### Step 1

```haskell
prettyPrint :: Bin -> String
prettyPrint End = ""
prettyPrint (O b) = prettyPrint b ++ "0"
prettyPrint (I b) = prettyPrint b ++ "1"

fromBin :: Bin -> Int
fromBin = go 0 1
  where
    go res _ End = res
    go res x (O b) = go res (x*2) b
    go res x (I b) = go (res+x) (x*2) b

toBin :: Int -> Bin
toBin 0 = O End
toBin 1 = I End
toBin n = let nextN = div n 2 in
  if mod n 2 == 1
    then I (toBin nextN)
    else O (toBin nextN)
```

リトルエンディアンで表現している

* リトルエンディアン
  * アドレス番地の若いところから、小さい桁のデータから順に並べる
  * 桁上がりのある計算などを実行しやすいため、多くのCPUがリトルエンディアンを使用している
* ビッグエンディアン
  * アドレス番地の若いところから、大きい桁のデータから順に並べる
  * 人間が数字を書くときと同じ順
  * TCP/IPなどネットワークの標準規格で採用されている
  * ネットワークバイトオーダーとも呼ばれる
* LSB: Least Significant Bit
* MSB: Most Significant Bit

### Step 2

#### 2a

`++` の時間計算量は左辺の長さに比例するので、consに置き換える。

`fromBin` はHorner法に書き換える。

`toBin` の偶奇判定は `odd` 関数に置き換えられる。

```haskell
(++) [] ys = ys
(++) (x:xs) ys = x : xs ++ ys

prettyPrint = go ""
  where
    go acc End = acc
    go acc (O b) = go ('0' : acc) b
    go acc (I b) = go ('1' : acc) b

fromBin End = 0
fromBin (O b) = 2 * fromBin b
fromBin (I b) = 1 + 2 * fromBin b

toBin 0 = O End
toBin 1 = I End
toBin n = (if odd n then I else O) (toBin (div n 2))
```

#### 2b

```haskell
prettyPrint = reverse . go
  where
    go End = ""
    go (O b) = '0' : go b
    go (I b) = '1' : go b
```

#### 2c

`foldBin` を定義して `prettyPrint / fromBin` を書き換える。

```haskell
prettyPrint :: Bin -> String
prettyPrint b = foldBin (\s -> s . ('0':)) (\s -> s . ('1':)) id b ""

fromBin :: Bin -> Int
fromBin = foldBin (2*) ((1+) . (2*)) 0

foldBin :: (a -> a) -> (a -> a) -> a -> Bin -> a
foldBin o i x = go
  where
    go End = x
    go (O b) = o (foldBin o i x b)
    go (I b) = i (foldBin o i x b)
```

### Step 3

```haskell
prettyPrint :: Bin -> String
prettyPrint = go ""
  where
    go acc End = acc
    go acc (O b) = go ('0':acc) b
    go acc (I b) = go ('1':acc) b

fromBin :: Bin -> Int
fromBin End = 0
fromBin (O b) = 2 * fromBin b
fromBin (I b) = 1 + 2 * fromBin b

toBin :: Int -> Bin
toBin 0 = O End
toBin 1 = I End
toBin n = if even n then O (toBin nextN) else I (toBin nextN)
  where
    nextN = div n 2
```
