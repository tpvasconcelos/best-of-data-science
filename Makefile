.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT



.PHONY: help
help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


.PHONY: init
init: clean-all ## initialise development environment
	python3.7 -m pip install --upgrade pip virtualenv
	python3.7 -m virtualenv -p python3.7 .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install --upgrade best-of


.PHONY: build
build: ## build best-of list
	.venv/bin/best-of generate --github-key "${GITHUB_API_TOKEN}" --libraries-key "${LIBRARIES_API_KEY}" ./projects.yaml


.PHONY: publish
publish: ## publish new best-of list
	git add -A
	git commit -m "publish new best-of list"
	git push

# ==============================================================
# ---  Clean
# ==============================================================

.PHONY: clean-all
clean-all: clean-pyc clean-venv ## remove all artifacts


.PHONY: clean-pyc
clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +


.PHONY: clean-venv
clean-venv: ## remove venv artifacts
	rm -fr .venv
