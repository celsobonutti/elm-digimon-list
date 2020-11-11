module Main exposing (..)

import Browser
import Element exposing (Element, centerX, centerY, column, el, fill, image, layout, padding, paragraph, spacing, text, width, wrappedRow)
import Element.Font exposing (Font, bold)
import Element.Keyed as Keyed
import Element.Lazy exposing (lazy)
import Html
import Http
import Json.Decode exposing (Decoder, field, list, string)



---- MODEL ----


type alias Flags =
    {}


type alias Digimon =
    { name : String
    , img : String
    , level : String
    }


type State
    = Loading
    | Data (List Digimon)
    | Error


type alias Model =
    State


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , loadDigimon
    )



---- UPDATE ----


type Msg
    = GotDigimon (Result Http.Error (List Digimon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotDigimon result ->
            case result of
                Ok digimonList ->
                    ( Data digimonList
                    , Cmd.none
                    )

                Err _ ->
                    ( Error, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "Digimon List"
    , body =
        [ layout
            []
            (case model of
                Loading ->
                    viewLoading

                Error ->
                    viewError

                Data digimonList ->
                    viewData digimonList
            )
        ]
    }


viewData : List Digimon -> Element msg
viewData digimonList =
    wrappedRow [ centerY, spacing 15, padding 15 ] (List.map viewDigimon digimonList)


viewDigimon : Digimon -> Element msg
viewDigimon digimon =
    column [ spacing 15 ]
        [ image [] { src = digimon.img, description = digimon.name }
        , el [ bold ] (text digimon.name)
        , text digimon.level
        ]


viewLoading : Element msg
viewLoading =
    text "Loading your Digimons!"


viewError : Element msg
viewError =
    text "Oops, there was an error loading your Digimons :("



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }


loadDigimon : Cmd Msg
loadDigimon =
    Http.get
        { url = "https://digimon-api.vercel.app/api/digimon"
        , expect = Http.expectJson GotDigimon digimonListDecoder
        }


digimonDecoder : Decoder Digimon
digimonDecoder =
    Json.Decode.map3 Digimon
        (field "name" string)
        (field "img" string)
        (field "level" string)


digimonListDecoder : Decoder (List Digimon)
digimonListDecoder =
    list digimonDecoder
