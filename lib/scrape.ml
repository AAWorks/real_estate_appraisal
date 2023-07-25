open! Core
open! Lwt
open! Cohttp
open! Cohttp_lwt_unix

let uri = Uri.of_string "https://zillow56.p.rapidapi.com/search?location=houston%2C%20tx&status=forSale&isMultiFamily=false&isApartment=false&isCondo=false&isLotLand=false&price_min=300000&singleStory=false&onlyWithPhotos=true" 
in let headers = Header.add_list (Header.init ()) [
	("X-RapidAPI-Key", "d5e24caf94msh2bb98840b2ae31fp155012jsn616b1320df3b");
	("X-RapidAPI-Host", "zillow56.p.rapidapi.com");
] in Client.call ~headers `GET uri >>= fun (res, body_stream) -> ()


def zpids(location, view, n_houses)
  -> list of zpids 

def house_data(zpid) -> hashmap(strings : datastuff)