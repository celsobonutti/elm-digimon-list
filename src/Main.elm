module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, p, text)
import Html.Attributes exposing (alt, src)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)
import Http
import Json.Decode exposing (Decoder, field, list, string)



---- MODEL ----


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


init : ( Model, Cmd Msg )
init =
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


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            viewLoading

        Error ->
            viewError

        Data digimon ->
            viewData digimon


viewLoading : Html msg
viewLoading =
    div []
        [ h1 [] [ text "Loading your Digimons!" ]
        ]


viewError : Html msg
viewError =
    div []
        [ h1 [] [ text "Oops, there was an error loading your Digimons :(" ]
        ]


viewData : List Digimon -> Html msg
viewData digimonList =
    Keyed.node "div" [] (List.map viewKeyedDigimon digimonList)


viewKeyedDigimon : Digimon -> ( String, Html msg )
viewKeyedDigimon digimon =
    ( digimon.name, lazy viewDigimon digimon )


viewDigimon : Digimon -> Html msg
viewDigimon digimon =
    div []
        [ img [ src digimon.img, alt digimon.name ] []
        , h1 [] [ text digimon.name ]
        , p [] [ text digimon.level ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
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
