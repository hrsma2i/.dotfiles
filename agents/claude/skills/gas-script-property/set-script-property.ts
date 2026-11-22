// Keychain の値を、専用 Chrome（CDP）で開いた Apps Script の「プロジェクトの設定」のスクリプトプロパティに入れる。
// 値は標準出力・標準エラー・例外メッセージのどこにも出さない。Claude に見えるのは出力だけなので、
// この制約がスキルの存在理由。出力を増やすときも、値を含まないことを必ず確認する。
// ページ内のスクリプトには値を渡さない（evaluate の式に埋め込まない）。値は CDP の Input.insertText だけで入れる。
// 既存プロパティの値は秘密を含むので、入力欄の値・ページ全体のテキストは読まない（読むのはプロパティ名の欄だけ）。
import { execFileSync } from "node:child_process";
import { userInfo } from "node:os";

type Target = { type: string; url: string; webSocketDebuggerUrl: string };

function fail(message: string): never {
  console.error(message);
  process.exit(1);
}

const args = process.argv.slice(2);
const flag = (name: string, fallback: string): string => {
  const at = args.indexOf(name);
  return at === -1 ? fallback : (args[at + 1] ?? fail(`${name} に値がありません`));
};
const has = (name: string) => args.includes(name);
const valueFlags = ["--port", "--host", "--path-includes"];
const [command, propertyName, keychainService] = args.filter((arg, i) => !arg.startsWith("--") && !valueFlags.includes(args[i - 1]));
const port = flag("--port", "9222");
const host = flag("--host", "script.google.com");
const pathIncludes = flag("--path-includes", "/settings");
const overwrite = has("--overwrite");
// 入力欄を埋めるところまでで止め、保存ボタンは人が押す
const noSave = has("--no-save");

if (command !== "inspect" && !(command === "set" && propertyName && keychainService)) {
  fail("使い方: set-script-property.ts inspect | set <プロパティ名> <Keychain の項目名> [--overwrite] [--no-save] [--port 9222] [--host script.google.com] [--path-includes /settings]");
}

type Cdp = { evaluate: (expression: string) => Promise<any>; send: (method: string, params: object) => Promise<void>; close: () => void };

async function connect(): Promise<Cdp> {
  const targets = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()) as Target[];
  // 対象は登録したホストと完全一致し、設定ページのパスを含むタブだけ。別のプロジェクトや別ドメインへ書き込まない
  const matched = targets.filter((t) => t.type === "page" && new URL(t.url).hostname === host && new URL(t.url).pathname.includes(pathIncludes));
  if (matched.length === 0) fail(`ホスト ${host} の ${pathIncludes} を含むタブが見つかりません。専用 Chrome で「プロジェクトの設定」を開いてください`);
  if (matched.length > 1) fail(`該当するタブが ${matched.length} 個あります。対象のプロジェクトだけ残してください`);

  const socket = new WebSocket(matched[0].webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    socket.onopen = resolve;
    socket.onerror = () => reject(new Error("CDP に接続できません"));
  });
  let nextId = 0;
  const pending = new Map<number, (message: any) => void>();
  socket.onmessage = (event) => {
    const message = JSON.parse(String(event.data));
    pending.get(message.id)?.(message);
  };
  const call = (method: string, params: object) =>
    new Promise<any>((resolve, reject) => {
      const id = ++nextId;
      pending.set(id, (message) => {
        // message の本文にはページ内の値が入りうるので捨てて、固定の文言にする
        if (message.error || message.result?.exceptionDetails) reject(new Error(`${method} が失敗しました`));
        else resolve(message.result);
      });
      socket.send(JSON.stringify({ id, method, params }));
    });
  return {
    evaluate: async (expression) => (await call("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true })).result?.value,
    send: async (method, params) => void (await call(method, params)),
    close: () => socket.close(),
  };
}

// ページ内で実行する関数。戻り値は呼び出し側に返るだけ。入力欄の value は読まない
const pageFunctions = `
const visible = (el) => !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length);
const fields = () => Array.from(document.querySelectorAll("input, textarea")).filter((el) => visible(el) && el.type !== "hidden" && el.type !== "checkbox");
const buttonByText = (text) =>
  Array.from(document.querySelectorAll("button, [role=button]")).find((el) => visible(el) && ((el.getAttribute("aria-label") || "") + (el.textContent || "")).includes(text));
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
`;

async function inspectPage(session: Cdp) {
  // 値は一切含めない。ボタンの文言、入力欄の属性（type / aria-label / placeholder）と個数だけ
  const result = await session.evaluate(`(async () => { ${pageFunctions}
    const text = (el) => ((el.getAttribute("aria-label") || "") + "|" + (el.textContent || "").trim()).slice(0, 40);
    return {
      buttons: Array.from(document.querySelectorAll("button, [role=button]")).filter(visible).map(text),
      fields: fields().map((el) => ({ tag: el.tagName.toLowerCase(), type: el.type, label: (el.getAttribute("aria-label") || "").slice(0, 30), placeholder: (el.placeholder || "").slice(0, 30) })),
    };
  })()`);
  console.log(JSON.stringify(result, null, 2));
}

// 編集を開き、追加ボタンで空の行を足す。名前の欄の中身（プロパティ名）だけを読み、既存の行の数を返す
async function openRow(session: Cdp) {
  const state = await session.evaluate(`(async () => { ${pageFunctions}
    const edit = buttonByText("スクリプト プロパティを編集");
    if (edit) { edit.click(); await sleep(500); }
    const add = buttonByText("スクリプト プロパティを追加");
    if (!add) return { error: "add-button-not-found" };
    const before = fields();
    // 行は「名前, 値」の 2 欄ずつの並びと仮定する
    if (before.length % 2 !== 0) return { error: "unexpected-field-count" };
    const names = before.filter((_, i) => i % 2 === 0).map((el) => el.value);
    const existing = names.indexOf(${JSON.stringify(propertyName)});
    if (existing !== -1) return { existing, count: before.length / 2 };
    add.click();
    await sleep(500);
    const after = fields();
    if (after.length !== before.length + 2) return { error: "row-not-added" };
    return { existing: -1, count: after.length / 2 };
  })()`);
  return state as { error?: string; existing?: number; count?: number };
}

async function fill(session: Cdp, rowIndex: number, kind: "name" | "value", text: string) {
  const ok = await session.evaluate(`(() => { ${pageFunctions}
    const el = fields()[${rowIndex * 2 + (kind === "name" ? 0 : 1)}];
    if (!el) return false;
    el.focus(); el.select();
    return true;
  })()`);
  if (!ok) fail("入力欄が見つかりません");
  // select() の直後に挿入するので、既存の値は置き換わる
  await session.send("Input.insertText", { text });
}

const session = await connect();
try {
  if (command === "inspect") {
    await inspectPage(session);
  } else {
    let secret: string;
    try {
      secret = execFileSync("security", ["find-generic-password", "-a", userInfo().username, "-s", keychainService!, "-w"], {
        encoding: "utf8",
        stdio: ["ignore", "pipe", "ignore"],
      }).replace(/\n$/, "");
    } catch {
      fail("Keychain の項目を読めませんでした（項目名と、Keychain の許可ダイアログが出ていないか確認してください）");
    }
    if (!secret) fail("Keychain の値が空です");

    const state = await openRow(session);
    if (state.error) fail(`行を用意できませんでした: ${state.error}。inspect で画面の構造を確認してください`);
    if (state.existing !== -1 && !overwrite) fail(`プロパティ ${propertyName} は既にあります。上書きするなら --overwrite を付けてください`);

    const row = state.existing !== -1 ? state.existing! : state.count! - 1;
    if (state.existing === -1) await fill(session, row, "name", propertyName!);
    await fill(session, row, "value", secret);

    if (noSave) {
      console.log(`filled ${propertyName} (${secret.length} chars). 保存ボタンは押していません`);
    } else {
      const saved = await session.evaluate(`(async () => { ${pageFunctions}
        const save = buttonByText("スクリプト プロパティを保存");
        if (!save) return false;
        save.click();
        await sleep(800);
        return true;
      })()`);
      if (!saved) fail("保存ボタンが見つかりません。入力欄は埋まっています。画面で保存してください");
      console.log(`saved ${propertyName} (${secret.length} chars)`);
    }
  }
} finally {
  session.close();
}
