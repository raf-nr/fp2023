(** Copyright 2021-2023, Ilya Syresenkov *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

(* Set of variables *)
type id = string [@@deriving show { with_path = false }]

module VarSet : Set.S with type elt = int

(* Base types *)
type base_type =
  | BInt (** Basic integer type *)
  | BBool (** Basic bool type *)
  | BUnit (** Unit type *)

(* Types *)
type ty =
  | TBase of base_type (** Type of integer *)
  | TVar of int
  | TArrow of ty * ty (** Type of function ty1 -> ty2 *)
  | TTuple of ty * ty * ty list (** Type of tuple *)
  | TList of ty (** Type of list *)

val pp_ty : Format.formatter -> ty -> unit

type error =
  | OccursCheckFailed of int * ty (** OCaml's Occurs check *)
  | UndeclaredVariable of id (** Attempt to use non-initialized variable *)
  | UnificationFailed of ty * ty (** Failed to unify left and right types *)
  | NotImplemented (** Still not implemented features *)

val pp_error : Format.formatter -> error -> unit

type scheme = S of VarSet.t * ty
