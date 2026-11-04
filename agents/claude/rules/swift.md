---
description: Swift のコードを書く・改修するときに適用するルール
paths:
  - "**/*.swift"
---

- URL のドメイン判定は `absoluteString.contains` ではなく `url.host` で行う。部分一致だと別のドメインに誤マッチする（例: `netflix.com` が `x.com` に一致する）
