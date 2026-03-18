// VadaPav Transpiler — Node.js Tests
// This file gets copied into the Koka JS output directory by run.ps1

import { transpile } from './vadapav.mjs';

const tests = [
  // === Success cases ===
  {
    name: "print simple string",
    input: 'Bhaiya dikhao "namaste duniya"',
    expected: 'console.log("namaste duniya");',
  },
  {
    name: "print another string",
    input: 'Bhaiya dikhao "VadaPav ready hai!"',
    expected: 'console.log("VadaPav ready hai!");',
  },
  {
    name: "empty string",
    input: 'Bhaiya dikhao ""',
    expected: 'console.log("");',
  },

  // === Error cases — exact line:col spans ===
  {
    name: "error: unknown input at 1:1-1:5",
    input: "kuch bhi",
    expected: "error:1:1:1:5: ye suno, aisa kuch nahi milta yahan!",
  },
  {
    name: "error: unclosed quotes at 1:15-1:20",
    input: 'Bhaiya dikhao "oops',
    expected: "error:1:15:1:20: arre idhar se khola udhar se band toh kar!",
  },
  {
    name: "error: nothing after dikhao",
    input: "Bhaiya dikhao",
    expected: "error:1:14:1:14: bhai dikhao bola, par kya? hawa dikhau?",
  },
  {
    name: "error: just Bhaiya — tells you dikhao is missing",
    input: "Bhaiya",
    expected: "error:1:7:1:7: bhai 'dikhao' bolna tha, ye kya bol diya?",
  },
  {
    name: "error: empty input",
    input: "",
    expected: "error:1:1:1:1: ye suno, aisa kuch nahi milta yahan!",
  },
  {
    name: "error: typo in dikhao — squiggle on wrong word not Bhaiya",
    input: 'Bhaiya dikao "hello"',
    expected: "error:1:8:1:13: bhai 'dikhao' bolna tha, ye kya bol diya?",
  },
];

let passed = 0;
let failed = 0;

console.log("VadaPav Transpiler Tests\n");

for (const t of tests) {
  const result = transpile(t.input);
  const ok = result === t.expected;

  const icon = ok ? "PASS" : "FAIL";
  console.log(`  ${icon}  ${t.name}`);
  console.log(`        source:   ${JSON.stringify(t.input)}`);
  console.log(`        output:   ${result}`);
  if (!ok) {
    console.log(`        expected: ${t.expected}`);
    failed++;
  }
  console.log();
  passed += ok ? 1 : 0;
}

console.log(`${passed} passed, ${failed} failed out of ${tests.length}`);
process.exit(failed > 0 ? 1 : 0);
