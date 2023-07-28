open! Core
open! Async
open! Real_estate_appraisal

let command =
  Command.async
    ~summary:"summary"
    (let%map_open.Command () = return () in
     fun () ->
       Scrape.photos ~zpid:"37267777";
       return ())
;;

let () = Command_unix.run command
