// ログイン済みの専用 Chrome（CDP）のページから秘密の値を読み、Keychain に保存する。
// 値は標準出力・標準エラー・例外メッセージのどこにも出さない。Claude に見えるのは出力だけなので、
// この制約がスキルの存在理由。出力を増やすときも、値を含まないことを必ず確認する。
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { userInfo } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

type Entry = {
  host: string;
  label: string;
  pattern: string;
  keychainService: string;
  // 見出しから maxDistance 個以内の要素だけを探す（既定 30）
  maxDistance?: number;
  // 値が見出しの前にある表の行などでは "before"（既定は "after"）。前方向では、見出しに最も近い一致を取る
  direction?: "after" | "before";
  // 値が伏せ字のとき、見出しの後ろで押す表示ボタンの CSS セレクタ
  revealSelector?: string;
};

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
const [command, name] = args.filter((arg, i) => !arg.startsWith("--") && !args[i - 1]?.startsWith("--"));
const port = flag("--port", "9222");
const registryPath = flag("--registry", join(dirname(fileURLToPath(import.meta.url)), "secrets.json"));

if ((command !== "inspect" && command !== "save") || !name) {
  fail("使い方: save-secret.ts <inspect|save> <登録名> [--port 9222] [--registry <path>]");
}
const registry = JSON.parse(readFileSync(registryPath, "utf8")) as Record<string, Entry>;
const entry = registry[name] ?? fail(`登録名 ${name} が ${registryPath} にありません`);

async function connect(): Promise<{ evaluate: (expression: string) => Promise<unknown>; close: () => void }> {
  const targets = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()) as Target[];
  // 取得元は登録したホストと完全一致するタブだけ。部分一致だと別ドメインを誤って読む
  const target = targets.find((t) => t.type === "page" && new URL(t.url).hostname === entry.host);
  if (!target) fail(`ホスト ${entry.host} のタブが見つかりません。専用 Chrome でそのページを開いてログインしてください`);

  const socket = new WebSocket(target.webSocketDebuggerUrl);
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
  return {
    evaluate: (expression) =>
      new Promise((resolve, reject) => {
        const id = ++nextId;
        pending.set(id, (message) => {
          // message.exceptionDetails にはページ内の値が入りうるので、本文は捨てて固定の文言にする
          if (message.error || message.result?.exceptionDetails) reject(new Error("ページ内のスクリプトが失敗しました"));
          else resolve(message.result?.result?.value);
        });
        socket.send(JSON.stringify({ id, method: "Runtime.evaluate", params: { expression, returnByValue: true, awaitPromise: true } }));
      }),
    close: () => socket.close(),
  };
}

// ページ内で実行する関数。戻り値は呼び出し側（Node）に返るだけで、出力するかは呼び出し側が決める
async function pageScript(mode: "inspect" | "save", entry: Entry) {
  const maxDistance = entry.maxDistance ?? 30;
  const KEY_TOKEN = /[A-Za-z0-9_\-+/=]{16,}/;
  const mask = (text: string) => String(text).replace(/[A-Za-z0-9_\-+/=]{16,}/g, (m) => `<redacted:${m.length}>`);
  const pattern = new RegExp(entry.pattern);
  const all = Array.from(document.querySelectorAll("*"));
  const leafText = (el: Element) => (el.children.length === 0 ? (el.textContent || "").trim() : "");
  // 見出しが子要素（バッジなど）を伴う要素に入っていることがあるため、直下のテキストだけを見る
  const ownText = (el: Element) =>
    Array.from(el.childNodes)
      .filter((node) => node.nodeType === Node.TEXT_NODE)
      .map((node) => node.textContent || "")
      .join("")
      .trim();
  const isLabel = (el: Element) => [leafText(el), ownText(el)].some((text) => text.toLowerCase() === entry.label.toLowerCase());
  const sources = (el: Element): [string, string][] => {
    const out: [string, string][] = [];
    const value = (el as HTMLInputElement).value;
    if (typeof value === "string" && value) out.push(["value", value]);
    const text = leafText(el);
    if (text) out.push(["text", text]);
    for (const attr of Array.from(el.attributes)) if (attr.value) out.push([`attr:${attr.name}`, attr.value]);
    return out;
  };

  if (mode === "save") {
    // 見出しから離れた要素まで探すと、隣のキー（別の権限のもの）を取ってしまう。距離を区切る
    const valueNear = () => {
      const elements = Array.from(document.querySelectorAll("*"));
      const at = elements.findIndex(isLabel);
      if (at === -1) return { error: "label-not-found" };
      const before = entry.direction === "before";
      const range = before ? elements.slice(Math.max(0, at - maxDistance), at).reverse() : elements.slice(at + 1, at + 1 + maxDistance);
      for (const el of range) {
        // 見出しの後ろの最初の入力欄が、この見出しの値。伏せ字のときに次のキーへ進むと別の権限のキーを取ってしまう
        if (!before && (el instanceof HTMLInputElement || el instanceof HTMLTextAreaElement)) {
          return pattern.test(el.value) ? { value: el.value } : { error: "value-not-found", elements, at };
        }
        for (const [from, value] of sources(el)) {
          if (before && !["value", "text"].includes(from)) continue;
          if (pattern.test(value)) return { value };
          // 前方向では、見出しに最も近いキーらしい値が決定的。形式が合わないまま手前へ進むと、別の行のキーを取ってしまう
          if (before && KEY_TOKEN.test(value)) return { error: "nearest-value-mismatch" };
        }
      }
      return { error: "value-not-found", elements, at };
    };
    let found: any = valueNear();
    if (found.error === "value-not-found" && entry.revealSelector) {
      // 伏せ字のときだけ表示ボタンを押す（表示済みで押すと隠れてしまう）。読み取り後に元へ戻す
      const button = found.elements.slice(found.at + 1, found.at + 1 + maxDistance).find((el: Element) => el.matches(entry.revealSelector!));
      if (!button) return { error: "reveal-button-not-found" };
      (button as HTMLElement).click();
      await new Promise((resolve) => setTimeout(resolve, 500));
      found = valueNear();
      (button as HTMLElement).click();
    }
    return found.value === undefined ? { error: found.error } : { value: found.value };
  }

  const labelsBefore = (at: number) => {
    const out: string[] = [];
    for (let j = at - 1; j >= 0 && out.length < 2 && at - j < 60; j--) {
      const text = leafText(all[j]);
      if (text && text.length <= 60 && !KEY_TOKEN.test(text)) out.push(mask(text));
    }
    return out;
  };
  const labelAt = all.findIndex(isLabel);
  const candidates = [];
  for (let i = 0; i < all.length; i++) {
    for (const [from, value] of sources(all[i])) {
      if (!KEY_TOKEN.test(value) && !pattern.test(value)) continue;
      candidates.push({
        tag: all[i].tagName.toLowerCase(),
        id: mask(all[i].id),
        classes: mask(all[i].className?.toString() ?? ""),
        from: from.startsWith("attr:") ? `attr:${from.slice(5)}` : from,
        length: value.length,
        matchesPattern: pattern.test(value),
        afterLabel: labelAt !== -1 && i > labelAt && i <= labelAt + maxDistance,
        labelsBefore: labelsBefore(i),
      });
    }
  }
  return { labelFound: labelAt !== -1, candidates };
}

const session = await connect();
try {
  const result = (await session.evaluate(`(${pageScript.toString()})(${JSON.stringify(command)}, ${JSON.stringify(entry)})`)) as any;

  if (command === "inspect") {
    // 値は含まれない（pageScript で長いトークンを伏せ、value は出さない）
    console.log(JSON.stringify(result, null, 2));
  } else {
    if (result.error) fail(`保存しませんでした: ${result.error}`);
    // 値を引数で渡す。一瞬だけ同じユーザーの ps から見えるが、履歴には残らない
    try {
      execFileSync("security", ["add-generic-password", "-U", "-a", userInfo().username, "-s", entry.keychainService, "-w", result.value], {
        stdio: ["ignore", "ignore", "ignore"],
      });
    } catch {
      fail("security コマンドが失敗しました（Keychain の許可ダイアログが出ていないか確認してください）");
    }
    console.log(`saved ${entry.keychainService} (${result.value.length} chars)`);
  }
} finally {
  session.close();
}
