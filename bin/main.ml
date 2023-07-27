open! Core
open! Async
open! Real_estate_appraisal

let command = 
  Command.async
  ~summary:"summary"
  (let%map_open.Command () = return ()
in
fun () -> Scrape.house_data ~location:"bethesda" ~view:" " ~n_houses:4 ;
return ()
)

let () = Command_unix.run command

(* let house_data ~(location:string) ~(view:string) =
  ignore location;
  ignore view;
	print_endline "Testing";; *)
	(* let _location = String.substr_replace_all location ~pattern:" " ~with_:"%20" in 
	let _view_link = match view with 
	| "water" -> "isWaterfront=true"
	| "city"	-> "isCityView=true"
	| _ -> "" in
(* in let _link = "https://zillow56.p.rapidapi.com/search?location=" ^ location ^ "&status=forSale&isSingleFamily=true&isMultiFamily=false&isApartment=false&isCondo=false&isManufactured=false&isTownhouse=false&isLotLand=false&price_min=300000&" ^ view_link ^ "&singleStory=false&onlyWithPhotos=true" in  *)
let uri = "https://zillow56.p.rapidapi.com/search?location=houston%2C%20tx" in
let string = Curl.get_exn uri in 
print_s[%message string];; *)
