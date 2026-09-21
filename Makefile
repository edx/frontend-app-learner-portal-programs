intl_imports = ./node_modules/.bin/intl-imports.js
transifex_utils = ./node_modules/.bin/transifex-utils.js
i18n = ./src/i18n
transifex_input = $(i18n)/transifex_input.json

# This directory must match the formatjs babel plugin config in @openedx/frontend-build.
transifex_temp = ./temp/babel-plugin-formatjs

requirements:  ## install ci requirements
	npm ci

i18n.extract:
	# Pulling display strings from .jsx files into .json files...
	rm -rf $(transifex_temp)
	npm run-script i18n_extract

i18n.concat:
	# Gathering JSON messages into one file...
	mkdir -p $(i18n)
	$(transifex_utils) $(transifex_temp) $(transifex_input)

extract_translations: | requirements i18n.extract i18n.concat

# Despite the name, we actually need this target to detect changes in the incoming translated message files as well.
detect_changed_source_translations:
	# Checking for changed translations...
	git diff --exit-code $(i18n)

# Pulls translations using atlas.
pull_translations:
	rm -rf src/i18n/messages
	mkdir src/i18n/messages
	cd src/i18n/messages \
	   && atlas pull $(ATLAS_OPTIONS) \
	            translations/frontend-platform/src/i18n/messages:frontend-platform \
	            translations/paragon/src/i18n/messages:paragon \
	            translations/frontend-app-learner-portal-programs/src/i18n/messages:frontend-app-learner-portal-programs

	$(intl_imports) frontend-platform paragon frontend-app-learner-portal-programs

shell: ## run a shell on the learner-portal container
	docker exec -it openedx.devstack.learner_portal /bin/bash

build:
	docker-compose build

up: ## bring up learner-portal container
	docker-compose up

up-detached: ## bring up clearner-portal container in detached mode
	docker-compose up -d

logs: ## show logs for learner-portal container
	docker-compose logs -f

down: ## stop and remove learner-portal container
	docker-compose down

npm-install-%: ## install specified % npm package on the learner-portal container
	docker exec npm install $* --save-dev
	git add package.json

restart:
	make down
	make up

restart-detached:
	make down
	make up-detached

validate-no-uncommitted-package-lock-changes:
	git diff --name-only --exit-code package-lock.json
