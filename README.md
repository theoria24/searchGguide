### 現在、正常に動作しません。無限ループになるので修正以外で使用しないでください。

### 修正の際も負荷をかけないよう細心の注意をお願いいたします。

# searchGguide

<!-- # Short Description -->

Search all TV programs in Japan.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/theoria24/searchGguide)](https://github.com/theoria24/searchGguide/issues)
[![Github forks](https://img.shields.io/github/forks/theoria24/searchGguide)](https://github.com/theoria24/searchGguide/network/members)
[![Github stars](https://img.shields.io/github/stars/theoria24/searchGguide)](https://github.com/theoria24/searchGguide/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/theoria24/searchGguide)](https://github.com/theoria24/searchGguide/)
[![Github license](https://img.shields.io/github/license/theoria24/searchGguide)](https://github.com/theoria24/searchGguide/)

# Demo

![Demo](https://user-images.githubusercontent.com/17396689/106942485-912efc00-6767-11eb-9958-552172b60cdb.gif)

# Advantages

You can search for all TV programs in Japan **at once**.

# Installation

## Requirement

- Ruby (I used Ruby 3.0.0 for development. Probably works on 2.6, 2.7 as well.)
- Bundler

```
git clone https://github.com/theoria24/searchGguide.git
cd searchGguide
bundle install
```

# Minimal Example

```
bundle exec ruby main.rb -a miyagi,bs -f "%m/%d %H:%M" search word
```

If you don't specify the `-a` option, it will search for programs in all prefectures in Japan.

# Contributors

- [theoria24](https://github.com/theoria24)

<!-- CREATED_BY_LEADYOU_README_GENERATOR -->
