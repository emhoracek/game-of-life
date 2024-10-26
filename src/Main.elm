module Main exposing (..)

import Debug
import Browser
import Browser.Events
import List
import List exposing (range)
import Array exposing (Array, get, fromList, toList)
import Array 
import Maybe 
import Time
import Random
import Html exposing (Html, button, div, text, table, tr,  td, ul, li)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Cell = Alive | Dead

cellToInt : Cell -> Int
cellToInt cell =
  case cell of
    Alive  -> 1
    Dead -> 0

type alias Grid = Array (Array Cell)

type alias Model = {
    grid: Array (Array Cell),
    liveliness: Int
  }

defaultRows = 20
defaultColumns = 20
defaultTiming = 100

usuallyAliveCell = Random.weighted (50, Alive) [ (50, Dead) ]

usuallyAliveRow : Random.Generator (Array Cell)
usuallyAliveRow =
  Random.map fromList (Random.list defaultColumns usuallyAliveCell)
  
usuallyAlive =
  Random.map fromList (Random.list defaultRows usuallyAliveRow)

makeGrid : Cmd Msg
makeGrid =
  Random.generate NewGrid usuallyAlive

rows grid = Array.length grid
columns grid = Array.length (Maybe.withDefault Array.empty (get 0 grid))

init : () -> (Model, Cmd Msg)
init _ = ( {
           grid = Array.repeat defaultRows (Array.repeat defaultColumns Dead),
           liveliness = 0 } , 
            makeGrid)

type Msg = Increment | NewGrid Grid | MkNewGrid | Decrement

getCell : Int -> Int -> Grid ->  Maybe Cell
getCell r c grid = Maybe.andThen (get c) (get r grid)
getNeighbors : Int -> Int -> Grid -> Array (Maybe Cell)
getNeighbors r c grid = fromList
    [ getCell (r-1) c grid, getCell (r-1) (c+1) grid,
      getCell (r-1) (c-1) grid, 
      getCell (r+1) c grid, getCell (r+1) (c+1) grid,
      getCell (r+1) (c-1) grid,
      getCell r (c+1) grid,    getCell r (c-1) grid ]

isAlive cell = if cell == Just Alive then True else False
aliveNeighbors r c grid = Array.length (Array.filter (isAlive) (getNeighbors r c grid))

willBeAlive r c grid = 
  if isAlive (getCell r c grid) 
    then
        aliveNeighbors r c grid == 2 ||
        aliveNeighbors r c grid == 3
    else 
        aliveNeighbors r c grid == 3


updateCell r c grid = if (willBeAlive r c grid) then Alive else Dead

updateRow r grid = 
  Array.map 
    (\n -> updateCell r n grid ) 
    (fromList (range 0 ((columns grid) - 1)))

updateRows : Grid -> Grid
updateRows grid = 
  Array.map 
    (\n -> updateRow n grid )
    (fromList (range 0 ((rows grid) - 1)))
    
incrementModel : Model -> Model
incrementModel model = 
   { grid = updateRows model.grid,
          liveliness = defaultTiming }

decrementModel : Model -> Model
decrementModel model = 
   { grid = model.grid,
          liveliness = model.liveliness - 1}

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Decrement -> 
      (decrementModel model, Cmd.none)

    Increment ->
      (incrementModel model, Cmd.none)

    MkNewGrid ->
      (model, makeGrid)
      
    NewGrid newGrid ->
      ({ grid = newGrid, liveliness = model.liveliness }, Cmd.none)

showCell2 color =
  td 
    [ style "background" color, 
      style "width" "1em",
      style "height" "1em"]
    [ text " "] 
showCell n cell =
  let min = 20
      max = 100
      p = min + (round ((toFloat n/100) * (max - min))) in 
  if cell == Alive 
  then showCell2 ("hsl(150 " ++ Debug.toString p ++ "% " ++ Debug.toString p ++ "%)")
  else  showCell2 "#333333"
showRow n row = tr [] (toList (Array.map (\c -> showCell n c) row))

view : Model -> Html Msg
view model =
  div []
    [ table [] (toList (Array.map (\r -> showRow model.liveliness r) model.grid))
     , button [ onClick Increment ] [ text "MARCH!" ]
     , button [ onClick MkNewGrid ] [ text "Generate!" ] ]
     

subscriptions : Model -> Sub Msg
subscriptions model =
  Browser.Events.onAnimationFrame 
    (
        \p ->
          if (model.liveliness == 0) then Increment else Decrement
    )