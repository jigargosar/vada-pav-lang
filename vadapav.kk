// VadaPav Transpiler v0.4 — full spans (start+end) for editor squiggles
// Handles: Bhaiya dikhao "string"

// === Position & Span ===

struct position
  line : int
  col  : int

struct span
  start : position
  end   : position

// === Effects ===

effect ctl fail(msg : string, spn : span) : a

effect input
  fun remaining() : list<char>
  fun advance() : char
  fun pos() : position

// === Tokens ===

type token
  TKeyword(s : string, spn : span)
  TString(s : string, spn : span)
  TEof(spn : span)

fun token-span(t : token) : span
  match t
    TKeyword(_, s) -> s
    TString(_, s)  -> s
    TEof(s)        -> s

// === AST ===

type expr
  EPrint(value : expr)
  ELitString(s : string)

// === Parser Combinators ===

fun peek()
  match remaining()
    Cons(c, _) -> Just(c)
    Nil        -> Nothing

fun spaces()
  match peek()
    Just(c) | c.is-white -> { advance(); spaces() }
    _ -> ()

fun take-while(pred : (char) -> bool)
  fun go(acc : list<char>)
    match peek()
      Just(c) | pred(c) -> { advance(); go(Cons(c, acc)) }
      _ -> acc.reverse.string
  go([])

fun string-lit()
  val start = pos()
  val ch = advance()
  if ch != '"' then fail("bhai pehle kholo toh sahi!", Span(start, start))
  fun go(acc : list<char>)
    match remaining()
      Nil -> fail("arre idhar se khola udhar se band toh kar!", Span(start, pos()))
      _ ->
        val ch1 = advance()
        if ch1 == '"' then acc.reverse.string
        else go(Cons(ch1, acc))
  go([])

// === Lexer ===

fun lex-one()
  spaces()
  val start = pos()
  match peek()
    Nothing   -> TEof(Span(start, start))
    Just('"') ->
      val s = string-lit()
      val end = pos()
      TString(s, Span(start, end))
    _ ->
      val w = take-while(fn(ch) !ch.is-white)
      val end = pos()
      TKeyword(w, Span(start, end))

fun lex-all()
  fun go(acc : list<token>)
    val t = lex-one()
    match t
      TEof -> Cons(t, acc).reverse
      _    -> go(Cons(t, acc))
  go([])

// === Parser ===

fun parse-expr(tokens : list<token>)
  match tokens
    // Bhaiya dikhao "..." — valid print
    Cons(TKeyword("Bhaiya", _), Cons(TKeyword("dikhao", _), Cons(TString(s, _), _))) ->
      EPrint(ELitString(s))
    // Bhaiya dikhao <nothing useful> — missing value
    Cons(TKeyword("Bhaiya", _), Cons(TKeyword("dikhao", ds), rest)) ->
      val spn = match rest
        Cons(t, _) -> token-span(t)
        Nil        -> ds
      fail("bhai dikhao bola, par kya? hawa dikhau?", spn)
    // Bhaiya <wrong word> — squiggle on the wrong word
    Cons(TKeyword("Bhaiya", _), Cons(t, _)) ->
      fail("bhai 'dikhao' bolna tha, ye kya bol diya?", token-span(t))
    // Anything else
    Cons(t, _) ->
      fail("ye suno, aisa kuch nahi milta yahan!", token-span(t))
    Nil ->
      fail("kya be, muh khola aur bolna bhool gaya?", Span(Position(1, 1), Position(1, 1)))

// === Codegen (pure) ===

fun codegen(e : expr) : string
  match e
    EPrint(value) -> "console.log(" ++ codegen(value) ++ ");"
    ELitString(s) -> "\"" ++ s ++ "\""

// === Transpile ===

pub fun transpile(source : string)
  with ctl fail(msg, spn)
    "error:" ++ spn.start.line.show ++ ":" ++ spn.start.col.show ++
    ":" ++ spn.end.line.show ++ ":" ++ spn.end.col.show ++
    ": " ++ msg

  var cs := source.list
  var ln := 1
  var cl := 1
  val tokens =
    with handler
      fun remaining() cs
      fun advance()
        match cs
          Cons(c, rest) ->
            cs := rest
            val prev-col = cl
            if c == '\n' then { ln := ln + 1; cl := 1 }
            else { cl := cl + 1 }
            c
          Nil -> fail("kya be, muh khola aur bolna bhool gaya?", Span(Position(ln, cl), Position(ln, cl)))
      fun pos() Position(ln, cl)
    lex-all()

  val ast = parse-expr(tokens)
  codegen(ast)

// === Entry point ===

fun main()
  println(transpile("Bhaiya dikhao \"namaste duniya\""))
  println(transpile("Bhaiya dikhao \"\""))
  println(transpile("kuch bhi"))
  println(transpile("Bhaiya dikhao"))
  println(transpile("Bhaiya dikhao \"oops"))
  println(transpile("Bhaiya dikao \"hello\""))
