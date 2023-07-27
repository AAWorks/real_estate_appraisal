open! Core
open! Storage
open! Jsonaf.Export

module QuestionBank : sig
  type t [@@deriving sexp]

  val from_file : filename:string -> t
  val n_random_houses : t -> House.t list
  val to_json : t -> Jsonaf_kernel__.Type.t
end
