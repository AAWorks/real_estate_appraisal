open! Core
open! Cohttp
(* open! Cohttp_lwt_unix *)

val house_data: location:string -> view:string -> n_houses:int -> string list list 
val json_practice: file_name:string -> unit