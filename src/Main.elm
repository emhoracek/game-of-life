module Main exposing (..)

-- import TakeOne exposing (takeOneMain)
-- import TakeTwo exposing (takeTwoMain)
-- import TakeThree exposing (takeThreeMain)
import CellTeams.CellTeams exposing (cellTeamsMain)


main : Program () CellTeams.CellTeams.Model CellTeams.CellTeams.Msg
main =
    cellTeamsMain
