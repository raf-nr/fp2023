(** Copyright 2023, Danil S, Andrei *)

(** SPDX-License-Identifier: MIT *)

open! Base
open Ast

(** Parse string and pretty print the output *)
let run string =
  match Parse.parse string with
  | Some str ->
      pp_structure Stdlib.Format.std_formatter str
  | None ->
      Stdlib.print_endline "syntax error"

let%expect_test "parse_let_binding_pattern1" =
  run "let ft::sc::tr = sc" ;
  [%expect
    {|
    [(Str_value (Nonrecursive,
        [{ pat =
           (Pat_construct ((Ident "::"),
              (Some (Pat_tuple
                       [(Pat_var "ft");
                         (Pat_construct ((Ident "::"),
                            (Some (Pat_tuple [(Pat_var "sc"); (Pat_var "tr")]))))
                         ]))
              ));
           expr = (Exp_ident (Ident "sc")) }
          ]
        ))
      ] |}]

let%expect_test "parse_let_binding_pattern2" =
  run "let (f, s) = (f + s, f - s)" ;
  [%expect
    {|
    [(Str_value (Nonrecursive,
        [{ pat = (Pat_tuple [(Pat_var "f"); (Pat_var "s")]);
           expr =
           (Exp_tuple
              [(Exp_apply (
                  (Exp_apply ((Exp_ident (Ident "+")), (Exp_ident (Ident "f")))),
                  (Exp_ident (Ident "s"))));
                (Exp_apply (
                   (Exp_apply ((Exp_ident (Ident "-")), (Exp_ident (Ident "f")))),
                   (Exp_ident (Ident "s"))))
                ])
           }
          ]
        ))
      ] |}]

let%expect_test "parse_custom_operator1" =
  run "let (>>=) a b = a ** b" ;
  [%expect
    {|
    [(Str_value (Nonrecursive,
        [{ pat = (Pat_var ">>=");
           expr =
           (Exp_fun ([(Pat_var "a"); (Pat_var "b")],
              (Exp_apply (
                 (Exp_apply ((Exp_ident (Ident "**")), (Exp_ident (Ident "a")))),
                 (Exp_ident (Ident "b"))))
              ))
           }
          ]
        ))
      ] |}]

let%expect_test "parse_custom_operator2" =
  run "let (++) a b = a + b" ;
  [%expect
    {|
    [(Str_value (Nonrecursive,
        [{ pat = (Pat_var "++");
           expr =
           (Exp_fun ([(Pat_var "a"); (Pat_var "b")],
              (Exp_apply (
                 (Exp_apply ((Exp_ident (Ident "+")), (Exp_ident (Ident "a")))),
                 (Exp_ident (Ident "b"))))
              ))
           }
          ]
        ))
      ] |}]

let%expect_test "parse_comments" =
  run
    "let(*sas*)rec(*firstcomment*)f n = (* second comment *) (* third \
     comment*) n + 1" ;
  [%expect
    {|
    [(Str_value (Recursive,
        [{ pat = (Pat_var "f");
           expr =
           (Exp_fun ([(Pat_var "n")],
              (Exp_apply (
                 (Exp_apply ((Exp_ident (Ident "+")), (Exp_ident (Ident "n")))),
                 (Exp_constant (Const_integer 1))))
              ))
           }
          ]
        ))
      ] |}]

let%expect_test "parse_let_rec_without_whitespaces1" =
  run "letrec f n = n + 1" ;
  [%expect
    {|
    [(Str_eval
        (Exp_apply (
           (Exp_apply ((Exp_ident (Ident "=")),
              (Exp_apply (
                 (Exp_apply ((Exp_ident (Ident "letrec")),
                    (Exp_ident (Ident "f")))),
                 (Exp_ident (Ident "n"))))
              )),
           (Exp_apply (
              (Exp_apply ((Exp_ident (Ident "+")), (Exp_ident (Ident "n")))),
              (Exp_constant (Const_integer 1))))
           )))
      ] |}]

let%expect_test "parse_let_rec_without_whitespaces2" =
  run "let reca = 1" ;
  [%expect
    {|
    [(Str_value (Nonrecursive,
        [{ pat = (Pat_var "reca"); expr = (Exp_constant (Const_integer 1)) }]))
      ] |}]

let%expect_test "parse_fact" =
  run "let rec fact n = if n < 2 then 1 else n * fact (n - 1)" ;
  [%expect
    {|
    [(Str_value (Recursive,
        [{ pat = (Pat_var "fact");
           expr =
           (Exp_fun ([(Pat_var "n")],
              (Exp_ifthenelse (
                 (Exp_apply (
                    (Exp_apply ((Exp_ident (Ident "<")), (Exp_ident (Ident "n"))
                       )),
                    (Exp_constant (Const_integer 2)))),
                 (Exp_constant (Const_integer 1)),
                 (Some (Exp_apply (
                          (Exp_apply ((Exp_ident (Ident "*")),
                             (Exp_ident (Ident "n")))),
                          (Exp_apply ((Exp_ident (Ident "fact")),
                             (Exp_apply (
                                (Exp_apply ((Exp_ident (Ident "-")),
                                   (Exp_ident (Ident "n")))),
                                (Exp_constant (Const_integer 1))))
                             ))
                          )))
                 ))
              ))
           }
          ]
        ))
      ] |}]