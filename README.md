# git-commitas

**Use case:** You're on a shared computer, and you're using git. You want the commit to be made by you, but you forget to set your name and email. git-commitas lets you set which user to commit as based on your git config.

For a user John, they would have this in their git config:
```ini
[users "John"]
    name = "John Doe"
    email = "john.doe@example.com"
```
And they would commit with this command:
```bash
git commitas John -m "Work committed by John"
```
