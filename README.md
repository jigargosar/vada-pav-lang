# 🌶️ VadaPav Lang

A programming language that sounds like ordering at a Mumbai street food stall.

Written in [Koka](https://koka-lang.github.io/) — compiled to JavaScript. Errors yell at you in Hindi.

## What it looks like

```
Bhaiya dikhao "namaste duniya!"
Bhaiya dikhao "ek aur plate laga bhai"
```

Transpiles to:

```js
console.log("namaste duniya!");
console.log("ek aur plate laga bhai");
```

## When you mess up

```
Bhaiya dikhao "oops
// → error:1:15:1:20: arre idhar se khola udhar se band toh kar!

kuch bhi
// → error:1:1:1:5: ye suno, aisa kuch nahi milta yahan!

Bhaiya dikhao
// → error:1:14:1:14: bhai dikhao bola, par kya? hawa dikhau?
```

Errors report exact `startLine:startCol:endLine:endCol` spans — ready for editor squiggles.

## Architecture

The transpiler is written in Koka using algebraic effects — no try/catch, no Result types, no monads. Just effects.

```
source string
    → lexer   (uses: input, fail effects)
    → parser  (uses: fail effect)
    → codegen (pure — no effects)
    → JavaScript string
```

Each phase declares only the effects it needs. The `transpile` function wires up handlers:

```koka
pub fun transpile(source : string)
  with ctl fail(msg, spn) /* format error string */
  var cs := source.list
  val tokens =
    with handler
      fun remaining() cs
      fun advance()  /* consume + track position */
      fun pos()      Position(ln, cl)
    lex-all()
  val ast = parse-expr(tokens)
  codegen(ast)
```

The outer handler catches `fail` from any phase. The inner handler provides `input` state for the lexer only. When the parser calls `fail`, it punches through the inner handler and hits the outer one. That's effect composition.

Koka compiles to JS via `--target=js`. The transpiler ships as a `.mjs` file — no Koka runtime needed at runtime.

## Try it

```powershell
# Build + run tests
.\run.ps1

# Launch playground (builds first, opens browser)
.\serve.ps1
```

The playground is a browser-based editor at `http://localhost:7777/editor.html` — type VadaPav, see transpiled JS and output live.

## Project structure

```
vadapav.kk    — the transpiler (Koka source)
test.mjs      — Node.js test suite
editor.html   — browser playground
run.ps1       — build + test
serve.ps1     — build + serve playground
hello.kk      — the probe that proved Koka→JS works
```

## Language roadmap

| Feature | Syntax | Status |
|---------|--------|--------|
| Print | `Bhaiya dikhao "hello"` | ✅ |
| Booleans | `Tikha` / `Feeka` | planned |
| If/else | `Agar ... toh` / `Nahi toh` / `Bas` | planned |
| Variables | `x mein daal 5` | planned |
| Loops | `Jab tak x chhota 10` | planned |
| Program wrapper | `Ek plate VadaPav` / `Bill de bhaiya` | planned |
| Errors | `Extra mirchi "kya hua?"` | planned |
| Editor autocomplete | snippet expansion with tab | planned |
| Editor error squiggles | inline Monaco markers | planned |

## Why

Because every language has boring error messages and this one doesn't.

## Built with

- [Koka](https://koka-lang.github.io/) — algebraic effects + handlers, compiled to JS
- [Monaco Editor](https://microsoft.github.io/monaco-editor/) — coming soon for the playground
- Stall bhaiya energy — priceless
