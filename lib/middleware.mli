open! Core
open! Storage

module QuestionBank : sig
    type t [@@deriving sexp]

    val from_file : filename:string -> t

    val houses : t
    val random_house : House.t

end


