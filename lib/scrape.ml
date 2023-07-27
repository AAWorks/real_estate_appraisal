[@@@disable_unused_warnings]

open! Core
open! Async
open! Jsonaf

module Curl = struct
  let writer accum data =
    Buffer.add_string accum data;
    String.length data
  ;;

  let get_exn url rapid =
    let error_buffer = ref "" in
    let result = Buffer.create 16384 in
    let fail error = failwithf "Curl failed on %s: %s" url error () in
    try
      let connection = Curl.init () in
      Curl.set_errorbuffer connection error_buffer;
      Curl.set_writefunction connection (writer result);
      Curl.set_followlocation connection true;
      Curl.set_url connection url;
      let test = Curl.get_effectiveurl connection in
      Curl.set_httpheader connection rapid;
      Curl.perform connection;
      let result = Buffer.contents result in
      Curl.cleanup connection;
      result
    with
    | Curl.CurlException (_reason, _code, _str) -> fail !error_buffer
    | Failure s -> fail s
  ;;
end

let house_data ~(location : string) ~(view : string) ~(n_houses : int) =
  let location =
    String.substr_replace_all location ~pattern:" " ~with_:"%20"
  in
  let view_link =
    match view with
    | "water" -> "isWaterfront=true"
    | "city" -> "isCityView=true"
    | _ -> ""
  in
  let link =
    "https://zillow56.p.rapidapi.com/search?location="
    ^ location
    ^ "&status=forSale&isSingleFamily=true&isMultiFamily=false&isApartment=false&isCondo=false&isManufactured=false&isTownhouse=false&isLotLand=false&price_min=300000&"
    ^ view_link
    ^ "&singleStory=false&onlyWithPhotos=true"
  in
  let rapid =
    [ "X-RapidAPI-Key: 89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847"
    ; "X-RapidAPI-Host: zillow56.p.rapidapi.com"
    ]
  in
  let json = Jsonaf.of_string (Curl.get_exn link rapid) in
  let results = json |> member_exn "results" |> list_exn in
  let results, _ = List.split_n results n_houses in
  (* Results >> For key in range of n_houses >> [zpid, city, state, bedroom,
     bathroom, price] *)
  List.map results ~f:(fun house ->
    let bathroom = house |> member_exn "bathrooms" |> to_string_hum in
    let zpid = house |> member_exn "zpid" |> to_string_hum in
    let city = house |> member_exn "city" |> to_string_hum in
    let state = house |> member_exn "state" |> to_string_hum in
    let bedroom = house |> member_exn "bedrooms" |> to_string_hum in
    let price = house |> member_exn "price" |> to_string_hum in
    [ zpid; city; state; bedroom; bathroom; price ])
;;

let photos ~(zpid : string) =
  let link =
    "https://zillow-data-v2.p.rapidapi.com/properties/detail/photos?zpid=2080998890"
  in
  let rapid =
    [ "X-RapidAPI-Key: 89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847"
    ; "X-RapidAPI-Host: zillow-data-v2.p.rapidapi.com"
    ]
  in
  let file = Curl.get_exn link rapid in
  let json = Jsonaf.of_string file in
  let photos = json |> member_exn "data" |> list_exn in
  print_s [%message "" (photos : t list)];
  let final =
    List.map photos ~f:(fun key ->
      let webp =
        key |> member_exn "mixedSources" |> member_exn "webp" |> list_exn
      in
      let photo = List.nth_exn webp 3 in
      photo |> member_exn "url" |> to_string_hum)
  in
  print_s [%message "" (final : string list)]
;;

(* [zpid, city, state, bedroom, bathroom, price] *)
let json_practice ~(file_name : string) =
  let file = In_channel.read_all file_name in
  let json = Jsonaf.of_string file in
  let results = json |> member_exn "results" |> list_exn in
  let results, _ = List.split_n results 4 in
  let final =
    List.map results ~f:(fun house ->
      let bathroom = house |> member_exn "bathrooms" |> to_string_hum in
      let zpid = house |> member_exn "zpid" |> to_string_hum in
      let city = house |> member_exn "city" |> to_string_hum in
      let state = house |> member_exn "state" |> to_string_hum in
      let bedroom = house |> member_exn "bedrooms" |> to_string_hum in
      let price = house |> member_exn "price" |> to_string_hum in
      [ zpid; city; state; bedroom; bathroom; price ])
  in
  print_s [%message "" (final : string list list)]
;;

(* let photos ~(zpid:String.t) = let uri = Uri.of_string
   "https://zillow-data-v2.p.rapidapi.com/properties/detail/photos?zpid=" ^
   zpid in let headers = Header.add_list (Header.init ()) [
   ("X-RapidAPI-Key", "89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847");
   ("X-RapidAPI-Host", "zillow-data-v2.p.rapidapi.com"); ] in

   Client.call ~headers `GET uri >>= fun (res, body_stream) -> (* Return
   Photo Link *) (* Photos >> Each key >> Mixed Sources >> webp >> Key 3 >
   url *) (* append url to list *) (* return list *) ;; *)
