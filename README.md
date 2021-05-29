# dqxclarity

[Discord](https://discord.gg/bVpNqVjEG5)

Translates the command menu and other misc. text into English for the popular game "Dragon Quest X".

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+)
**NOTE: I forfeit any responsibility if you receive a warning, a ban or a stern talking to while using this program. dqxclarity alters process memory, but only for the intent of allowing English-speaking players to read Japanese menus. No malicious activities are being performed with dqxclarity. The goal of this application is simply to translate the game's UI for non-Japanese fluent players to enjoy.**

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+)
**The way this is being done is not currently very efficient and can be slow to run each time. This is a work in progress of a few days worth of work that I wanted to get out there and share for those that may be considering giving Dragon Quest X a shot.**

In action:

https://user-images.githubusercontent.com/17505625/120054067-5e995f80-bff3-11eb-9bc6-77595985eb10.mp4

## How to use

Download the latest version of `dqxclarity` from the [releases](https://github.com/jmctune/dqxclarity/releases) section. Open a fresh instance of Dragon Quest X and run `dqxclarity.exe` (don't run `run_json.exe` directly). You will be asked how many files you want to simultaenously translate. This option exists for people with slower computers. 10 is the default and is fine. Faster numbers will translate faster, but will likely spike your CPU to 100%. On most machines, it seems to take anywhere between 30-90 seconds to run. In its current state, this number will only increase as more text is added, but tuning this number down is being investigated.

**You really only need to run dqxclarity one time per game session. Running more than once will not hurt, but will not do you any good either (unless you're testing translations)**

**You might see untranslated menus when running from time to time. Yes, it's buggy and yes, I'm aware. Be thrilled it's in the state it's in now -- it will eventually get fixed.**

## How it works

In the `json` folder is a structure of Japanese and English translated text. The Japanese text is converted from a utf-8 string to hex, then searched for in the active process's memory. When found, it replaces the hex values with its English equivalent.

As an example, with a structure like the following:

```
[
  {
    "jp_string": "冒険をする",
    "en_string": "Open Adventure"
  }
]
```

`jp_string` is converted to a utf-8 hex string with the `convertStrToHex()` function, as well as the `en_string` value.

Strings are prepended and appended with `00` (null terminators) as this begins and completes the string.

There are a few different json keys in `strings[]` that can change the behavior of how the script operates. As every string isn't created equally in memory, sometimes you need to alter its behavior. The following flags are also applicable:

`line_break`: In `jp_string`, replace spaces with `0a` (line break). In `en_string`, replace "|" characters with `0a`. This is typically used for menu descriptions.<br>

The above flags are situational, but `jp_string` and `en_string` are always mandatory.

## How to contribute

Thanks for considering to contribute. If you choose to, there are several menu items, menu descriptions, spells and skills that still need to be translated. Additionally, if you can read Japanese, accurate translations are better. No "coding" is required -- just need to be able to understand how the json format works.

With the way this script works, exact translations sometimes won't work -- and here's why:

Suppose I have the text "冒険をする". Each Japanese character consists of 3 bytes of text (冒, 険, を, す, る) equaling 15 bytes total. In the English alphabet, each character uses 1 byte of text (O, p, e, n, , A, d, v, e, n, t, u, r, e) equaling 14 bytes total. The number of English bytes cannot exceed the number of Japanese bytes or there will be trouble. When looking to translate, sometimes you may need to think of shorter or similar words to make the text fit.

When translating descriptions in the command menu (the text on the side of the command menu that describes what the menu item does), each line break needs a space in the Japanese string and a pipe ("|") in the English. Here's an example:

```
[
  {
    "line_break": true,
    "jp_string": "フレンドや チームメンバーに かきおきを書く",
    "en_string": "Write a note to|a friend or|team member."
  }
]
```

In-game, "フレンドや", "チームメンバーに", and "かきおきを書く" are read top to bottom. But because this is a full sentence separated by line breaks, the spaces are replaced with the line break character. For Japanese, ensure you use spaces and for the English, ensure you separate the words with pipe characters. Make sure you don't exceed the character limit (take the number of Japanese characters and multiply it by 3. Don't exceed this many characters when typing it into English, but you can match it).

The format should match what the rest of the files look like. Pay attention to spaces (no tabs) and keep everything indented the same (two spaces per indent).

Preferably, you would fork this repo and submit a pull request, but if you're unfamiliar with git, you can provide your json changes to the #clarity-discussion channel and get them merged.
