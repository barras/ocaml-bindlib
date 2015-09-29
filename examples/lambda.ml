open Bindlib

(* Abstract Syntax Tree of the pure λ-calculus using Bindlib variables and
binders. *)
type term =
  | Var of term variable
  | Lam of (term, term) binder
  | App of term * term

(* Terms are built in the [bindbox] type, we define smart constructors for
convenience. *)
let var x   = box_of_var (new_var (fun x -> Var x) x)
let lam x f = box_apply (fun b -> Lam b) (bind (fun x -> Var x) x f)
let app t u = box_apply2 (fun t u -> App(t,u)) t u

(* Function to destruct a binder. *)
let unbind b =
  let x = new_var (fun x -> Var x) (binder_name b) in
  let t = subst b (free_of x) in (x, t)

(* Some example of standard terms. *)
let x     = var "x"
let y     = var "y"
let id    = lam "x" (fun x -> x)
let fst   = lam "x" (fun x -> lam "y" (fun y -> x))
let delta = lam "x" (fun x -> app x x)
let omega = app delta delta
let fsty  = app fst y
let fstyx = app fsty x

(* Printing function. *)
let rec print_term ch = function
  | Var x    -> Printf.fprintf ch "%s" (name_of x)
  | Lam b    -> let (x,t) = unbind b in
                Printf.fprintf ch "λ%s.%a" (name_of x) print_term t
  | App(t,u) -> Printf.fprintf ch "(%a) %a" print_term t print_term u
let print_term t =
  Printf.printf "%a\n%!" print_term t

(* Evaluation function. *)
let rec cbn_step = function
  | App(Lam b, u) -> Some (subst b u)
  | App(t    , u) ->
      begin
        match cbn_step t with
        | None    -> None
        | Some t' -> Some (App(t',u))
      end
  | _             -> None

let rec eval t =
  match cbn_step t with
  | None    -> t
  | Some t' -> eval t'

(* Tests. *)
let _ =
  print_term (unbox x);
  print_term (unbox y);
  print_term (unbox id);
  print_term (unbox fst);
  print_term (unbox delta);
  print_term (unbox omega);
  print_term (unbox fsty);
  print_term (eval (unbox fsty));
  print_term (unbox fstyx);
  print_term (eval (unbox fstyx))