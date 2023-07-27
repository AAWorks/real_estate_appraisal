[@@@disable_unused_warnings]

open! Core
open! Async
open! Jsonaf
open! Yojson

module Curl = struct
  let writer accum data =
    Buffer.add_string accum data;
    String.length data
  ;;

  let get_exn url =
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
			Curl.set_httpheader connection ["X-RapidAPI-Key: 89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847";"X-RapidAPI-Host: zillow56.p.rapidapi.com"];
      Curl.perform connection;
      let result = Buffer.contents result in
      Curl.cleanup connection;
			result
    with
    | Curl.CurlException (_reason, _code, _str) -> fail !error_buffer
    | Failure s -> fail s
  ;;
end

let house_data ~(location:string) ~(view:string) ~(n_houses:int) =
	let location = String.substr_replace_all location ~pattern:" " ~with_:"%20" in 
	let view_link = match view with 
	| "water" -> "isWaterfront=true"
	| "city"	-> "isCityView=true"
	| _ -> "" in
 let link = "https://zillow56.p.rapidapi.com/search?location=" ^ location ^ "&status=forSale&isSingleFamily=true&isMultiFamily=false&isApartment=false&isCondo=false&isManufactured=false&isTownhouse=false&isLotLand=false&price_min=300000&" ^ view_link ^ "&singleStory=false&onlyWithPhotos=true" in 
	let json = Jsonaf.of_string (Curl.get_exn link) in 
	let results = json |> member_exn "results" |> list_exn in 
	let results, _ = List.split_n results n_houses in
	let final =
	List.map results ~f:(fun house -> 
	let bathroom = house |> member_exn "bathrooms" |> to_string_hum in 
	let zpid = house |> member_exn "zpid" |> to_string_hum in 
	let city = house |> member_exn "city" |> to_string_hum in 
	let state = house |> member_exn "state" |> to_string_hum in 
	let bedroom = house |> member_exn "bedrooms" |> to_string_hum in 
	let price = house |> member_exn "price" |> to_string_hum in [zpid; city; state; bedroom; bathroom; price]) in
	print_s[%message "" (final:string list list)]
	;;

(* [zpid, city, state, bedroom, bathroom, price] *)
let json_practice ~(file_name:string) = 
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
	let price = house |> member_exn "price" |> to_string_hum in [zpid; city; state; bedroom; bathroom; price]) in
	print_s[%message "" (final:string list list)];
(* 

	List.map results ~f:(fun house -> let bathroom = house |> member_exn "bathrooms" |> to_string_hum in 
	let zpid = house |> member_exn "zpid" |> to_string_hum in 
	let city = house |> member_exn "city" |> to_string_hum in 
	let state = house |> member_exn "state" |> to_string_hum in 
	let bedroom = house |> member_exn "bedrooms" |> to_string_hum in 
	let price = house |> member_exn "price" |> to_string_hum in 
	let final = [zpid; city; state; bedroom; bathroom; price]);

	let bathroom = first |> member_exn "bathrooms" |> to_string_hum in 
	let zpid = first |> member_exn "zpid" |> to_string_hum in 
	let city = first |> member_exn "city" |> to_string_hum in 
	let state = first |> member_exn "state" |> to_string_hum in 
	let bedroom = first |> member_exn "bedrooms" |> to_string_hum in 
	let price = first |> member_exn "price" |> to_string_hum in 
	let final = [zpid; city; state; bedroom; bathroom; price] in 
	print_s[%message "" (final:string list)]; *)
	(* print_s [%message "" (first:t)]; *)
	(* print_s [%message "" (results:t list)] *)
	
;;


(* let json_practice ~(file_name:string) =
	try
		let file = In_channel.read_all file_name in 
		let json = Yojson.Safe.from_string file in
		
	with 
	| Yojson.Json_error msg ->
		print_endline msg 
	;; *)

(* let handle_json_input json_str =
  try
    let json = from_string json_str in
    let json_object = Util.to_assoc json in
    (* Do something with the JSON object here *)
    print_endline "JSON parsing successful!";
  with
  | Yojson.Json_error msg ->
      (* Handle JSON parsing errors *)
      Printf.printf "JSON parsing error: %s\n" msg *)

(* let uri = Uri.of_string link in
let headers = Cohttp.Header.add_list (Cohttp.Header.init ()) [
	("X-RapidAPI-Key", "89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847");
	("X-RapidAPI-Host", "zillow56.p.rapidapi.com");
]  in 
let response, body = Cohttp.Client.GET ~headers uri in 
response  *)
(* let headers = Cohttp.Header.init () in
let response, body = Cohttp.  ~headers (Uri.of_string link) in  *)

(* let uri = Uri.of_string link in 
let headers = Header.add_list (Header.init ()) [
	("X-RapidAPI-Key", "89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847");
	("X-RapidAPI-Host", "zillow56.p.rapidapi.com");
] () *)


(* Client.call ~headers `GET uri
>>= fun (res, body_stream) ->

	let first = Cohttp_lwt.Body.to_string body_stream in 
	first >>= fun (first ) ->
	print_s[%message "testing" (first:string)];
	print_s[%message "testing" (res:Response.t)];
	return () *)
	(* Results >> For key in range of n_houses >> 
		 [zpid, city, state, bedroom, bathroom, price] *)





(* let photos ~(zpid:String.t) = 
	let uri = Uri.of_string "https://zillow-data-v2.p.rapidapi.com/properties/detail/photos?zpid=" ^ zpid in
	let headers = Header.add_list (Header.init ()) [
		("X-RapidAPI-Key", "89e8d18db2msh750cb1be8006c38p19c402jsne47214e05847");
		("X-RapidAPI-Host", "zillow-data-v2.p.rapidapi.com");
	] in
	
	Client.call ~headers `GET uri
	>>= fun (res, body_stream) ->
		(* Return Photo Link *)
		(* Photos >> Each key >> Mixed Sources >> webp >> Key 3 > url *)
		(* append url to list *)
		(* return list *)
;; *)
