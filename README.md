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

![Demo](https://user-images.githubusercontent.com/17396689/99578002-7ded7980-2a1f-11eb-9eaa-f6ee81e2389f.gif)

# Advantages

You can search for all TV programs in Japan **at once**.

# Installation

## Requirement

- Ruby (I used Ruby 2.7.2 for development. Probably works on 2.6 as well.)
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

If you don't specify the `-a` option, it will search for all programs in Japan.

# Contributors

- [theoria24](https://github.com/theoria24)

<!-- CREATED_BY_LEADYOU_README_GENERATOR -->
