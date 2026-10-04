# 04 – Git & GitHub commands (Experiment 5 + sessional)

Open Terminal: **Ctrl+Alt+T**. Paste in terminal: **Ctrl+Shift+V**. Never use `sudo` with git.

## Once per computer
```bash
git config --global user.name "Ritika RP"
git config --global user.email "ritikarpatange@gmail.com"
git config --list
```

## A. Local repository (last year's sessional Q1 – no internet, no token)
Change the names in CAPITALS to whatever the question says.
```bash
mkdir FOLDER_NAME                 # e.g. git-sessional
cd FOLDER_NAME
git init                          # initialise repository

echo "some text" > FILE.txt       # create file  (> = new/overwrite)
cat FILE.txt
git status                        # shows FILE.txt as untracked
git add FILE.txt                  # stage
git status                        # now "changes to be committed"
git commit -m "EXACT MESSAGE FROM QUESTION"

git branch BRANCH_NAME            # create branch, e.g. feature-update
git checkout BRANCH_NAME          # switch to it
git branch                        # * marks the current branch
echo "new line" >> FILE.txt       # >> = add a line at the end
cat FILE.txt
git add FILE.txt
git commit -m "EXACT MESSAGE FROM QUESTION"
git log --oneline --all --graph   # proof: shows all commits
```
Possible extras:
```bash
git diff                          # what changed (before git add)
git checkout master               # back to main branch (could be "main")
git merge BRANCH_NAME             # bring branch changes into master
git branch -d BRANCH_NAME         # delete branch after merge
```

## B. Lab record: fork → clone → edit → commit → push → pull request
1. **Fork** (website): open the given repo → **Fork** → Create fork.
2. **Clone** (terminal) – URL from the green **Code** button on *your* fork:
```bash
git clone https://github.com/riti-rp/REPO_NAME.git
cd REPO_NAME
ls
cat student_name.txt
```
3. **Edit, stage, commit, push**
```bash
echo "Ritika RP" >> student_name.txt
cat student_name.txt              # name must be on its own line
git add student_name.txt
git commit -m "Added student name"
git branch                        # main or master?
git push origin main              # or: git push origin master
```
   Username: `riti-rp` · Password: **paste the token** (nothing shows while pasting – normal).
4. **Pull request** (website): your fork → **Contribute** → **Open pull request** → base = original repo → **Create pull request**.

## C. Put a NEW local folder on GitHub (like this reference repo)
Create an EMPTY repo on github.com first (+ → New repository, no README), then:
```bash
cd FOLDER
git init
git add .
git commit -m "First commit"
git branch -M main
git remote add origin https://github.com/riti-rp/REPO_NAME.git
git push -u origin main
```

## Token (only needed for `git push`)
GitHub → Settings → Developer settings → Personal access tokens → **Tokens (classic)** →
Generate new token (classic) → tick **repo** → Generate → copy (starts with `ghp_`).
Make it once, save it in phone notes, reuse it. A 403 "permission denied" = token missing the **repo** tick.

## Errors
| Error | Fix |
|---|---|
| Author identity unknown | run the two `git config` lines |
| not a git repository | you're in the wrong folder → `cd` into it (`pwd` shows where you are) |
| src refspec main does not match | branch is `master` → `git push origin master` |
| 403 / permission denied | token without **repo** scope → make a new classic token |
| Repository not found | repo not created on GitHub or URL typo (`git remote -v`) |
| vim opened (forgot `-m`) | press Esc, type `:wq`, Enter |
| failed to write .gitconfig.lock | `rm -f ~/.gitconfig.lock` then `sudo chown $USER:$USER ~/.gitconfig` |

## Viva one-liners
Git = version-control software; GitHub = website hosting repos · working dir → `add` → staging → `commit` → repo ·
branch = separate line of work · merge = combine branches · fork = copy on GitHub; clone = copy to PC ·
push = upload commits; pull = download · pull request = ask the owner to merge your changes · origin = remote you cloned from.
