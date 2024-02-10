let greet who =
  let open Tyxml.Html in
  html
    (head (
      title (txt "Greeting")) [])
    (body [
      h1 [ txt "Hello, "; txt who; txt "!" ] ])

let html_to_string html =
  Format.asprintf "%a" (Tyxml.Html.pp ()) html

let () =
  Dream.run @@ Dream.logger
  @@ Dream_livereload.inject_script ()
  @@ Dream.router
       [
         Dream.get "/" (fun _req ->
             html_to_string (greet "World") |> Dream.html);
         Dream_livereload.route ();
       ]
