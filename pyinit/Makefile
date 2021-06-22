base: .gitignore .flake8 .pre-commit-config.yaml

.gitignore:
	git init
	gibo dump python >.gitignore_
	sed 's/# .python-version/.python-version/g' .gitignore_ >.gitignore
	/bin/rm .gitignore_

.python-version:
	~/.dotfiles/pyinit/pyenv_local.sh

pyproject.toml: .python-version
	poetry init
	poetry add -D flake8 black mypy


define FLAKE8
[flake8]
max-line-length = 88
extend-ignore = E203
endef

SRCS = $(wildcard [a-z]*.c)
EXES = $(SRCS:.c=)

export FLAKE8
.flake8: $(SRCS)
	echo $(EXES) | sed 's/ /\n/g' > $@
	echo "$$FLAKE8" >> $@


.pre-commit-config.yaml: pyproject.toml
	~/.dotfiles/pyinit/make_pre_commit_config.sh
