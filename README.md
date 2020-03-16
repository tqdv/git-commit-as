# git-commit-as

## Preview

In shell,
```bash
git commit-as John -m "Work committed by John"
git commit-as Megan -m "Add docs"
```
shows up in the git log as
```git-log
Author: Megan <megan@xkcd.com>
Author: John Doe <john.doe@example.com>
```
without having to modify git config between commands.

## About

> You're on a shared computer, and you're using git. You commit. You notice it was committed under the name of the person that used the computer before you. You realize that's because you forgot to configure your name and email in git.

git-commit-as lets you choose which user to commit as, as specified in your git config

## Installation

Download the shell script, make it executable, and put in in your `$PATH`.

## Configuration and usage

For a user John, you would add this to your git config:
```ini
[users "John"]
    name = "John Doe"
    email = "john.doe@example.com"
```
And they would commit with this command:
```bash
git commit-as John -m "Work committed by John"
```
The syntax is:
```bash
git commit-as <as-user> <arguments>
```
with arguments being the normal git commit arguments.

## How it works

We get data from git config, and modify the environment variables [GIT_AUTHOR_* and GIT_COMMITTER_*][git config var].

[git config var]: https://git-scm.com/docs/git-config#Documentation/git-config.txt-username

## Caveats

It won't override the git commit [--author=\<author\>][git commit author] flag.

[git commit author]: https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---authorltauthorgt

## Contributing

I wrote the perl script first, and then translated it to shell. I tried limiting myself to POSIX commands and shell features, but it isn't an enforced rule.

Use [shellcheck](https://www.shellcheck.net/), and write [good error messages][LTA].

Any contributions are appreciated, be it code, docs, typos or wording.

[LTA]: https://docs.raku.org/language/glossary#LTA

## License

[Artistic License 2.0](LICENSE)