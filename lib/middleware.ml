open! Core
open! Storage
open! Async

module QuestionBank = struct
  type t = House.t list [@@deriving sexp]

  let from_file ~filename = 
    let reader = Reader.open_file filename in
    Deferred.bind reader ~f:(fun reader -> 
      let pipe = Reader.read_sexps reader in 
      
    )

  (* let new_random_house (t: t) ~used = 
    t |> List.filter ~f:(fun house -> not (List.mem used house ~equal:(fun house1 house2 -> House.equal house1 house2))) |> List.random_element_exn
  ;;

  let n_random_houses t ~n_houses = 
    let houses: House.t list = [] in
    List.fold (List.range 0 n_houses) ~init:houses ~f:(
      fun acc _ ->
        let house = new_random_house t ~used:acc in 
        acc @ [house]
    )
  ;; *)

  let n_random_houses (t: House.t list) ~n_houses = 
    let shuffled_houses = List.permute t in 
    List.take shuffled_houses n_houses
  ;;

end

let get_questions () = 
  let questionbank = QuestionBank.from_file ~filename:"resources/house_data.txt" in 
  QuestionBank.n_random_houses questionbank ~n_houses:10
