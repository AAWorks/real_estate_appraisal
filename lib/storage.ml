open! Core
open! Scrape
open! Async
(* open! postgresql *)

module House = struct
  type t = {
    zpid: string
    ; city: string
    ; state: string
    ; bedrooms: string
    ; bathrooms: string
    ; price: int
    ; images: string list
  } [@@deriving sexp]

  let string_price t = Int.to_string (t.price) 

  let address t = t.city ^ ", " ^ t.state

  let specs t = t.bedrooms ^ " bed, " ^ t.bathrooms ^ " bath"

  let fields = ["zpid"; "city"; "state"; "bedrooms"; "bathrooms"; "price"; "images"]

  let from_scraped_data ~mapped_details ~images = 
    {
      zpid = Map.find_exn mapped_details "zpid"
      ; city = Map.find_exn mapped_details "city"
      ; state = Map.find_exn mapped_details "state"
      ; bedrooms = Map.find_exn mapped_details "bedrooms"
      ; bathrooms = Map.find_exn mapped_details "bathrooms"
      ; price = Int.of_string (Map.find_exn mapped_details "price")
      ; images = images
    }

end

let get_location_data ~location ~(houses_per_view:int) : string list list= 
  let water_data = house_data ~location ~view:"water" ~n_houses:houses_per_view in 
  let city_data = house_data ~location ~view:"city" ~n_houses:houses_per_view in 
  water_data @ city_data
;;

let store_houses ~locations ~(houses_per_view:int) : unit Deferred.t = 
  Deferred.List.iter locations ~how:`Sequential ~f:(
    fun location -> 
      let location_details = get_location_data ~location ~houses_per_view in 
      Deferred.List.iter location_details ~how:`Sequential ~f:(
        fun house_details -> 
          let mapped_details = house_details |> List.zip_exn House.fields |> String.Map.of_alist_exn in
          let images: string list = photos ~zpid:(List.nth_exn house_details 0) in 
          let house = House.from_scraped_data ~mapped_details ~images in 
          Writer.save_sexp "placeholder.txt" (House.sexp_of_t house)
      )
  )
;;

(* Scheduler.go store_houses *)

let pull_data () = 
  let locations = ["new york city"; "los angeles"; "houston"; "calabasas"; "chicago"; "montreal"; "greenwich"; "bethesda"; "potomac"; "martha%Cs vineyard"; "hollywood hills"; "palo alto"; "east palo alto"; "miami"; "seattle"] in 
  let houses_per_view = 180 / (List.length locations) / 2 in
  store_houses ~locations ~houses_per_view
;;