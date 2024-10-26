module Tests exposing (..)
import Array
import Expect
import Test exposing (Test, describe, test)
import Main exposing (..)


prep list = List.sortBy (\a -> cellToInt a) (List.filterMap (\a -> a) (Array.toList list))


example = Array.fromList
        (List.map Array.fromList 
          [[Dead, Dead, Dead, Dead],
           [Alive, Alive, Dead, Dead],
           [Alive, Alive, Alive, Dead],
           [Alive, Alive, Alive, Dead]])



suite : Test
suite =
    describe "Game of Life"
        [ describe "isAlive"
            [ test "an Alive cell is Alive" <|
                \_ ->
                    Expect.equal (isAlive (Just Alive)) True,
              test "a Dead cell is not Alive" <|
                \_ ->
                    Expect.equal (isAlive (Just Dead)) False,
              test "an Nothing cell is Dead" <|
                \_ ->
                    Expect.equal (isAlive (Nothing)) False
                    ],
          describe "getCell"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (getCell 0 0 example) (Just Dead),
              test "second row, second column" <|
                \_ ->
                    Expect.equal (getCell 1 1 example) (Just Alive),
              test "out of bounds" <|
                \_ ->
                    Expect.equal (getCell 42 3432 example) Nothing
                    ],
          describe "willBeAlive"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (willBeAlive 0 0 example) False,
              test "second row, second column" <|
                \_ ->
                    Expect.equal (willBeAlive 1 1 example) False,
              test "second row, third column" <|
                \_ ->
                    Expect.equal (willBeAlive 1 2 example) True,
              test "out of bounds" <|
                \_ ->
                    Expect.equal (willBeAlive 454 1234 example) False
                    ],
          describe "getNeighbors"
            [ test "upper left" <|
                \_ ->
                    Expect.equal 
                        (prep (getNeighbors 1 2 example) )
                        (prep (Array.fromList [Just Alive, Just Alive, Just Alive, Just Dead,Just Dead,Just Dead, Just Dead, Just Dead]))
    
                    ]
        ]
                    
    