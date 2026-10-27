#!/usr/bin/env bash
# 사용법: ~/github_blog 폴더 안에서 `bash apply_blog.sh`
# Jekyll Now 위에 미니멀 구조(Home / Posts / About + Writings 목록 + 페이지 번호)를 덮어씌웁니다.
set -e

if [ ! -d .git ]; then
  echo "여기는 git 레포 폴더가 아니에요. cd ~/github_blog 후 다시 실행하세요."
  exit 1
fi

mkdir -p _layouts _includes _posts posts assets/css

# 옛 Jekyll Now 스타일 파일은 더 이상 쓰지 않으므로 제거 (git 기록에는 남아 있어요)
rm -f style.scss

# ---------------------------------------------------------------- _config.yml
cat > _config.yml <<'EOF_CONFIG'
title: "baba-sy"
description: "보안 공부 기록과 CTF 라이트업"
lang: ko
timezone: Asia/Seoul

url: "https://baba-sy.github.io"
baseurl: ""

# 하단 "Find me on ..." 링크에 쓰여요. email을 비워두면 표시되지 않아요.
github_username: baba-sy
email: ""

markdown: kramdown
highlighter: rouge
permalink: /posts/:title/

paginate: 10
paginate_path: "/posts/page:num/"
plugins:
  - jekyll-paginate

exclude:
  - README.md
  - apply_blog.sh
  - Gemfile
  - Gemfile.lock
  - vendor
EOF_CONFIG

# ---------------------------------------------------------- _layouts/default
cat > _layouts/default.html <<'EOF_DEFAULT'
<!DOCTYPE html>
<html lang="{{ site.lang | default: 'ko' }}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{% if page.url == '/' or page.title == nil %}{{ site.title }}{% else %}{{ page.title }} | {{ site.title }}{% endif %}</title>
  <meta name="description" content="{{ site.description }}">
  <link rel="icon" href="{{ '/favicon.ico' | relative_url }}">
  <link rel="stylesheet" href="{{ '/assets/css/style.css' | relative_url }}">
</head>
<body>
  <div class="wrap">
    <header class="site-nav">
      <nav aria-label="메인 메뉴">
        <a href="{{ '/' | relative_url }}"{% if page.url == '/' %} aria-current="page"{% endif %}>Home</a>
        <a href="{{ '/posts/' | relative_url }}"{% if page.url contains '/posts/' %} aria-current="page"{% endif %}>Posts</a>
        <a href="{{ '/about/' | relative_url }}"{% if page.url contains '/about' %} aria-current="page"{% endif %}>About</a>
      </nav>
    </header>

    <main>
      {{ content }}
    </main>

    <footer class="site-footer">
      <p>Find me on
        <a href="https://github.com/{{ site.github_username }}">GitHub</a>{% if site.email != '' and site.email %} and <a href="mailto:{{ site.email }}">email</a>{% endif %}.
      </p>
    </footer>
  </div>
</body>
</html>
EOF_DEFAULT

# ------------------------------------------------------------ _layouts/post
cat > _layouts/post.html <<'EOF_POST'
---
layout: default
---
<article class="post">
  <h1>{{ page.title }}</h1>
  <p class="meta">
    <time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date: "%Y-%m-%d" }}</time>
  </p>
  <div class="post-body">
    {{ content }}
  </div>
  <p class="back"><a href="{{ '/posts/' | relative_url }}">모든 글 보기</a></p>
</article>
EOF_POST

# ------------------------------------------------------- _includes/post-item
cat > _includes/post-item.html <<'EOF_ITEM'
<li>
  <time datetime="{{ include.post.date | date_to_xmlschema }}">{{ include.post.date | date: "%Y-%m-%d" }}</time>
  <a href="{{ include.post.url | relative_url }}">{{ include.post.title }}</a>
</li>
EOF_ITEM

# --------------------------------------------------------------- index.html
cat > index.html <<'EOF_INDEX'
---
layout: default
title: Home
---
<h1>{{ site.title }}</h1>
<p class="lead">{{ site.description }}</p>

<h2 class="section"><a href="{{ '/posts/' | relative_url }}">Writings</a></h2>
<ul class="post-list">
  {% for post in site.posts limit: 5 %}
    {% include post-item.html post=post %}
  {% endfor %}
</ul>
EOF_INDEX

# ------------------------------------------------------------ posts/index.html
cat > posts/index.html <<'EOF_POSTS'
---
layout: default
title: Posts
---
<h1>Writings</h1>

<ul class="post-list">
  {% for post in paginator.posts %}
    {% include post-item.html post=post %}
  {% endfor %}
</ul>

{% if paginator.total_pages > 1 %}
<nav class="pager" aria-label="페이지 이동">
  {% if paginator.previous_page %}
    <a href="{{ paginator.previous_page_path | relative_url }}">이전</a>
  {% endif %}
  <span>Page {{ paginator.page }} of {{ paginator.total_pages }}</span>
  {% if paginator.next_page %}
    <a href="{{ paginator.next_page_path | relative_url }}">다음</a>
  {% endif %}
</nav>
{% endif %}
EOF_POSTS

# ----------------------------------------------------------------- about.md
cat > about.md <<'EOF_ABOUT'
---
layout: default
title: About
permalink: /about/
---
# About

안녕하세요, baba-sy입니다.
보안을 공부하며 CTF 문제를 풀고, 배운 내용을 이곳에 기록합니다.

이 글은 `about.md`에서 수정할 수 있어요.
EOF_ABOUT

# -------------------------------------------------------------- 샘플 글
cat > _posts/2026-10-27-hello-world.md <<'EOF_SAMPLE'
---
layout: post
title: "첫 글"
---

블로그를 시작했습니다.

```python
print("hello, blog")
```
EOF_SAMPLE

# ------------------------------------------------------ assets/css/style.css
cat > assets/css/style.css <<'EOF_CSS'
:root {
  --bg: #ffffff;
  --fg: #1b1b1b;
  --muted: #6a6a6a;
  --line: #e6e6e6;
  --accent: #2457c5;
  --code-bg: #f5f5f5;
  --hl-comment: #7a7a7a;
  --hl-keyword: #7b3fa0;
  --hl-string: #1f7a4d;
  --hl-number: #b35c00;
  --hl-func: #2457c5;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: #141414;
    --fg: #e8e8e8;
    --muted: #9a9a9a;
    --line: #2c2c2c;
    --accent: #8ab4ff;
    --code-bg: #1e1e1e;
    --hl-comment: #8a8a8a;
    --hl-keyword: #c9a0e8;
    --hl-string: #8fd1a8;
    --hl-number: #f0b070;
    --hl-func: #8ab4ff;
  }
}

* { box-sizing: border-box; }

html { -webkit-text-size-adjust: 100%; }

body {
  margin: 0;
  background: var(--bg);
  color: var(--fg);
  font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo",
    "Malgun Gothic", "Noto Sans KR", "Segoe UI", system-ui, sans-serif;
  font-size: 17px;
  line-height: 1.75;
}

.wrap {
  max-width: 42rem;
  margin: 0 auto;
  padding: 1.5rem 1.25rem 4rem;
}

a {
  color: inherit;
  text-decoration: underline;
  text-decoration-color: var(--line);
  text-underline-offset: 0.2em;
}
a:hover { color: var(--accent); text-decoration-color: currentColor; }
a:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; border-radius: 2px; }

/* 상단 메뉴 */
.site-nav { margin-bottom: 3rem; }
.site-nav nav { display: flex; gap: 1.5rem; }
.site-nav a { text-decoration: none; color: var(--muted); }
.site-nav a:hover { color: var(--fg); }
.site-nav a[aria-current="page"] {
  color: var(--fg);
  font-weight: 600;
}

h1, h2, h3, h4 { line-height: 1.3; font-weight: 650; }
h1 { font-size: 1.75rem; margin: 0 0 1rem; }
h2 { font-size: 1.3rem; margin: 2.2rem 0 0.8rem; }
h3 { font-size: 1.1rem; margin: 1.8rem 0 0.6rem; }
.section { margin-top: 2.5rem; }
.section a { text-decoration: none; }

.lead { color: var(--muted); margin: 0 0 1rem; }

/* 글 목록 */
.post-list { list-style: none; margin: 0; padding: 0; }
.post-list li {
  display: flex;
  gap: 1.25rem;
  padding: 0.45rem 0;
}
.post-list time {
  flex: 0 0 6.5rem;
  color: var(--muted);
  font-variant-numeric: tabular-nums;
}
.post-list a { text-decoration: none; }
.post-list a:hover { text-decoration: underline; }

/* 페이지 번호 */
.pager {
  display: flex;
  gap: 1.25rem;
  align-items: baseline;
  margin-top: 2rem;
  color: var(--muted);
}

/* 글 본문 */
.post .meta { color: var(--muted); margin: -0.4rem 0 2rem; }
.post-body img { max-width: 100%; height: auto; }
.post-body blockquote {
  margin: 1.2rem 0;
  padding-left: 1rem;
  border-left: 3px solid var(--line);
  color: var(--muted);
}
.post-body table { display: block; overflow-x: auto; border-collapse: collapse; }
.post-body th, .post-body td { border: 1px solid var(--line); padding: 0.4rem 0.7rem; }
.back { margin-top: 3rem; }

/* 코드 */
code, pre {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, "D2Coding", monospace;
  font-size: 0.9em;
}
code { background: var(--code-bg); padding: 0.1em 0.35em; border-radius: 4px; }
pre {
  background: var(--code-bg);
  padding: 1rem;
  border-radius: 6px;
  overflow-x: auto;
  line-height: 1.55;
}
pre code { background: none; padding: 0; }

.highlight span[class^="c"] { color: var(--hl-comment); font-style: italic; }
.highlight span[class^="k"] { color: var(--hl-keyword); }
.highlight span[class^="s"] { color: var(--hl-string); }
.highlight span[class^="m"] { color: var(--hl-number); }
.highlight .nf, .highlight .nc, .highlight .nb { color: var(--hl-func); }

/* 하단 */
.site-footer {
  margin-top: 4rem;
  padding-top: 1.25rem;
  border-top: 1px solid var(--line);
  color: var(--muted);
}
.site-footer p { margin: 0; }

@media (max-width: 30rem) {
  body { font-size: 16px; }
  .post-list li { flex-direction: column; gap: 0; padding: 0.6rem 0; }
  .post-list time { flex-basis: auto; }
}
EOF_CSS

echo
echo "완료! 생성/덮어쓴 파일:"
git status --short
echo
echo "다음 단계: _config.yml에서 title/description/email을 고친 뒤"
echo "  git add . && git commit -m 'minimal layout' && git push"
