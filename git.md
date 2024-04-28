```bash
# all ignored and untracked files are stashed then cleanup with git clean
git config --globacl alias.staash 'stash --all'

git config --global alias.lg "log --graph --pretty=tformat:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --decorate=full"
```
